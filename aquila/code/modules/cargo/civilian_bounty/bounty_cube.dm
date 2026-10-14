// AQUILA - kostka zleceń, port z tgstation (civilian_bounty/bounty_cube.dm)
// Po ukończeniu zlecenia cywilnego powstaje kostka. Zaopatrzenie sprzedaje ją promem:
// wykonawcy dostają 77% wartości, 23% idzie jako VAT do budżetów działów,
// a zaopatrzenie zarabia premię za szybką wysyłkę (minus napiwek dla skanującego).

/// Ogłasza wiadomość na kanale zaopatrzenia przez automatyczny system ogłoszeń
/proc/supply_channel_announce(message)
	if(!length(GLOB.announcement_systems))
		return FALSE
	var/obj/machinery/announcement_system/announcer = pick(GLOB.announcement_systems)
	if(!announcer.is_operational)
		return FALSE
	announcer.radio.talk_into(announcer, message, RADIO_CHANNEL_SUPPLY)
	return TRUE

/obj/item/bounty_cube
	name = "bounty cube"
	desc = "Pakiet skompresowanych danych w twardym świetle, zawierający ukończone zlecenie. Sprzedaj go promem zaopatrzenia, by je rozliczyć!"
	icon = 'aquila/icons/obj/economy/bounty_market.dmi'
	icon_state = "bounty_cube"
	w_class = WEIGHT_CLASS_SMALL
	/// Wartość zlecenia
	var/bounty_value = 0
	/// Premia dla zaopatrzenia za wysłanie kostki przed pierwszym przypomnieniem
	var/speed_bonus = 0.2
	/// Część wartości dla wykonawców, dzielona przy zleceniach globalnych
	var/holder_cut = BOUNTY_CUT_STANDARD
	/// Część wartości, która jako VAT idzie po równo do budżetów działów statku
	var/station_vat = BOUNTY_VAT
	/// Napiwek dla osoby, która zarejestrowała się skanerem eksportu
	var/handler_tip = 0.1
	/// Czas do kolejnego przypomnienia
	var/nag_cooldown = 5 MINUTES
	/// O ile wydłuża się czas między przypomnieniami
	var/nag_cooldown_multiplier = 1.25
	COOLDOWN_DECLARE(next_nag_time)
	/// Kto ukończył zlecenie
	var/bounty_holder
	/// Jego praca
	var/bounty_holder_job
	/// Nazwa zlecenia
	var/bounty_name
	/// Konta wykonawców; konto => udział
	var/list/datum/bank_account/bounty_holder_accounts
	/// Konto osoby, która dostanie napiwek za obsługę
	var/datum/bank_account/bounty_handler_account

/obj/item/bounty_cube/Destroy()
	STOP_PROCESSING(SSobj, src)
	bounty_holder_accounts = null
	bounty_handler_account = null
	return ..()

/obj/item/bounty_cube/examine(mob/user)
	. = ..()
	if(speed_bonus)
		. += "<span class='notice'>Zostało <b>[DisplayTimeText(COOLDOWN_TIMELEFT(src, next_nag_time), round_seconds_to = 1)]</b>, zanim przepadnie premia za szybką dostawę: <b>[round(bounty_value * speed_bonus)]</b> kr.</span>"
	if(station_vat && bounty_value)
		. += "<span class='notice'>Przy sprzedaży [round(station_vat * 100)]% wartości (<b>[round(bounty_value * station_vat)]</b> kr) trafi jako VAT do budżetów działów statku.</span>"
	if(handler_tip && !bounty_handler_account)
		. += "<span class='notice'>Zeskanuj kostkę skanerem eksportu, by zarejestrować swoje konto do napiwku za obsługę: <b>[round(bounty_value * handler_tip)]</b> kr.</span>"

/obj/item/bounty_cube/process(delta_time)
	if(!COOLDOWN_FINISHED(src, next_nag_time) || is_centcom_level(z) || is_reserved_level(z))
		return
	var/nag_message = "Kostka zlecenia warta [bounty_value] kr wciąż czeka na wysyłkę w: [get_area_name(src)]."
	if(speed_bonus)
		supply_channel_announce("[nag_message] Przepadła premia za szybką dostawę: [round(bounty_value * speed_bonus)] kr.")
	else
		supply_channel_announce(nag_message)
	speed_bonus = 0

	for(var/datum/bank_account/holder_account as anything in bounty_holder_accounts)
		holder_account.bank_card_talk(nag_message)
	bounty_handler_account?.bank_card_talk(nag_message)

	nag_cooldown = nag_cooldown * nag_cooldown_multiplier
	COOLDOWN_START(src, next_nag_time, nag_cooldown)

/// Ustawia nazwę, wartość i wykonawców kostki, po czym ogłasza ją zaopatrzeniu
/obj/item/bounty_cube/proc/set_up(datum/bounty/my_bounty, obj/item/card/id/holder_id)
	bounty_value = my_bounty.get_bounty_reward()
	bounty_name = my_bounty.name
	bounty_holder = holder_id.registered_name
	bounty_holder_job = holder_id.assignment
	bounty_holder_accounts = my_bounty.contribution.Copy()
	if(!length(bounty_holder_accounts) && holder_id.registered_account)
		bounty_holder_accounts[holder_id.registered_account] = 1

	name = "\improper [bounty_value] kr [name]"
	desc += " Metka mówi, że to nagroda dla <i>[bounty_holder] ([bounty_holder_job])</i> za zlecenie <i>[bounty_name]</i>."
	AddComponent(/datum/component/gps, "[src]")

	START_PROCESSING(SSobj, src)
	COOLDOWN_START(src, next_nag_time, nag_cooldown)
	supply_channel_announce("Kostka zlecenia warta [bounty_value] kr powstała w: [get_area_name(src)]. \
		Wykonawca: [bounty_holder] ([bounty_holder_job]). Premia za szybką dostawę przepada za [DisplayTimeText(nag_cooldown, round_seconds_to = 1)].")

/**
 * Rozdziela wypłatę z kostki. Zwraca to, co zostaje dla zaopatrzenia.
 *
 * * dry_run - tylko policz, nie wypłacaj
 */
/obj/item/bounty_cube/proc/pay_out(dry_run = FALSE)
	var/total_value = round(bounty_value + (bounty_value * speed_bonus))
	var/cargo_share = total_value

	var/holders_cut = round(bounty_value * holder_cut)
	var/total_contribution = 0
	for(var/datum/bank_account/holder_account as anything in bounty_holder_accounts)
		total_contribution += max(bounty_holder_accounts[holder_account], 1)
	if(total_contribution)
		for(var/datum/bank_account/holder_account as anything in bounty_holder_accounts)
			var/payee_cut = round(holders_cut * (max(bounty_holder_accounts[holder_account], 1) / total_contribution))
			cargo_share -= payee_cut
			if(dry_run || !payee_cut)
				continue
			holder_account.adjust_money(payee_cut)
			holder_account.bank_card_talk("Sprzedano [src]. Na konto wpłynęło [payee_cut] kr.")

	if(bounty_handler_account)
		var/tip = round(bounty_value * handler_tip)
		cargo_share -= tip
		if(!dry_run && tip)
			bounty_handler_account.adjust_money(tip)
			bounty_handler_account.bank_card_talk("Sprzedano [src]. Napiwek za obsługę: [tip] kr.")

	// VAT: część wartości dzielona po równo między budżety działów statku, potrącana z części zaopatrzenia
	var/vat = round(bounty_value * station_vat)
	cargo_share -= vat
	if(!dry_run && vat)
		pay_station_vat(vat)

	return max(0, cargo_share)

/// Dzieli VAT po równo między budżety działów statku
/obj/item/bounty_cube/proc/pay_station_vat(vat)
	var/list/station_budgets = list()
	for(var/department_id in SSeconomy.department_accounts)
		var/datum/bank_account/budget = SSeconomy.get_dep_account(department_id)
		if(budget)
			station_budgets += budget
	if(!length(station_budgets))
		return
	var/per_department = round(vat / length(station_budgets))
	for(var/datum/bank_account/budget as anything in station_budgets)
		budget.adjust_money(per_department)

/// Kostka do testów - użyj w ręce, by ustawić ją z losowym zleceniem
/obj/item/bounty_cube/debug_cube
	name = "debug bounty cube"
	desc = "Użyj w ręce, by ustawić losowe zlecenie. Wymaga karty z kontem bankowym."
	var/is_set_up = FALSE

/obj/item/bounty_cube/debug_cube/attack_self(mob/user)
	if(is_set_up || !isliving(user))
		return ..()
	var/mob/living/squeezer = user
	var/obj/item/card/id/id_card = squeezer.get_idcard(TRUE)
	if(!id_card?.registered_account)
		to_chat(user, "<span class='notice'>Kostka nie wykrywa twojego konta bankowego.</span>")
		return ..()
	var/datum/bounty/test_bounty = random_civ_bounty(CIV_JOB_BASIC)
	LAZYADDASSOC(test_bounty.contribution, id_card.registered_account, 1)
	set_up(test_bounty, id_card)
	is_set_up = TRUE
	return ..()

/datum/export/bounty_box
	cost = 1
	k_elasticity = 0
	unit_name = "kostka zlecenia"
	export_types = list(/obj/item/bounty_cube)

/datum/export/bounty_box/get_cost(obj/O, allowed_categories = NONE, apply_elastic = TRUE)
	var/obj/item/bounty_cube/cube = O
	if(!istype(cube) || !cube.bounty_value)
		return 0
	return cube.pay_out(dry_run = TRUE)

/datum/export/bounty_box/sell_object(obj/O, datum/export_report/report, dry_run = TRUE, allowed_categories = EXPORT_CARGO, apply_elastic = TRUE)
	var/obj/item/bounty_cube/cube = O
	if(!istype(cube) || !cube.bounty_value)
		return FALSE
	var/cargo_share = cube.pay_out(dry_run)
	report.total_value[src] += cargo_share
	report.total_amount[src] += 1
	if(!dry_run)
		SSblackbox.record_feedback("nested tally", "export_sold_cost", 1, list("[O.type]", "[cargo_share]"))
	return TRUE

/// Skaner eksportu rejestruje konto do napiwku za obsługę kostki
/obj/item/export_scanner/afterattack(obj/O, mob/user, proximity)
	if(!proximity || !istype(O, /obj/item/bounty_cube) || !isliving(user))
		return ..()
	var/obj/item/bounty_cube/cube = O
	var/mob/living/scanner_user = user
	var/obj/item/card/id/scanner_id = scanner_user.get_idcard(TRUE)
	var/datum/bank_account/scanner_account = scanner_id?.registered_account

	if(!cube.bounty_value)
		to_chat(user, "<span class='warning'>[cube] nie zawiera żadnego zlecenia.</span>")
	else if(!scanner_account)
		to_chat(user, "<span class='warning'>Brak konta bankowego do rejestracji napiwku.</span>")
	else if(cube.bounty_handler_account)
		to_chat(user, "<span class='warning'>Do [cube] zarejestrowano już konto [cube.bounty_handler_account.account_holder].</span>")
	else
		cube.bounty_handler_account = scanner_account
		scanner_account.bank_card_talk("Zarejestrowano konto do napiwku za obsługę: [round(cube.bounty_value * cube.handler_tip)] kr.")
		for(var/datum/bank_account/holder_account as anything in cube.bounty_holder_accounts)
			if(holder_account != scanner_account)
				holder_account.bank_card_talk("[cube] jest w rękach [scanner_account.account_holder].")
	return ..()
