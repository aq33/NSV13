// AQUILA - rzeczy kupowane za aquilosy, które trzeba pamiętać między rundami:
// bilety na pracę, ubezpieczenia (liczniki do zużycia) i odznaki w rankingu.
// Liczniki trzyma tabela SS13_aquila_perks w bazie; bez bazy plik data/aquila_perks.json.

#define AQUILA_PERKS_FALLBACK_FILE "data/aquila_perks.json"
/// Ile salda wypłaca ubezpieczenie
#define INSURANCE_PAYOUT 0.5

/// Czy tabela perków istnieje (sprawdzane raz na rundę)
GLOBAL_VAR_INIT(aquila_perks_table_ready, FALSE)
/// ckey => TRUE dla graczy, którzy w lobby użyli biletu na pracę w tej rundzie
GLOBAL_LIST_EMPTY(armed_job_tickets)

/proc/aquila_perks_db_ready()
	if(!SSdbcore.Connect())
		return FALSE
	if(GLOB.aquila_perks_table_ready)
		return TRUE
	var/datum/DBQuery/query_create = SSdbcore.NewQuery({"
		CREATE TABLE IF NOT EXISTS [format_table_name("aquila_perks")] (
			`ckey` VARCHAR(32) NOT NULL,
			`perk` VARCHAR(32) NOT NULL,
			`amount` INT NOT NULL DEFAULT 0,
			PRIMARY KEY (`ckey`, `perk`)
		) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4
	"})
	GLOB.aquila_perks_table_ready = query_create.Execute()
	qdel(query_create)
	return GLOB.aquila_perks_table_ready

/proc/aquila_perks_load_fallback()
	if(!fexists(AQUILA_PERKS_FALLBACK_FILE))
		return list()
	var/list/data = json_decode(rustg_file_read(AQUILA_PERKS_FALLBACK_FILE))
	return islist(data) ? data : list()

/// Ile gracz ma danego perka
/proc/aquila_perk_get(player_ckey, perk)
	if(!player_ckey)
		return 0
	if(aquila_perks_db_ready())
		var/amount = 0
		var/datum/DBQuery/query_get = SSdbcore.NewQuery(
			"SELECT amount FROM [format_table_name("aquila_perks")] WHERE ckey = :ckey AND perk = :perk",
			list("ckey" = player_ckey, "perk" = perk)
		)
		if(query_get.Execute() && query_get.NextRow())
			amount = text2num(query_get.item[1])
		qdel(query_get)
		return amount
	var/list/player_perks = aquila_perks_load_fallback()[player_ckey]
	return player_perks?[perk] || 0

/// Ustawia perka na wartość (np. wybraną odznakę)
/proc/aquila_perk_set(player_ckey, perk, amount)
	if(!player_ckey)
		return
	if(aquila_perks_db_ready())
		var/datum/DBQuery/query_set = SSdbcore.NewQuery({"
			INSERT INTO [format_table_name("aquila_perks")] (ckey, perk, amount) VALUES (:ckey, :perk, :amount)
			ON DUPLICATE KEY UPDATE amount = :amount
		"}, list("ckey" = player_ckey, "perk" = perk, "amount" = amount))
		query_set.Execute()
		qdel(query_set)
		return
	var/list/data = aquila_perks_load_fallback()
	var/list/player_perks = data[player_ckey] || list()
	player_perks[perk] = amount
	data[player_ckey] = player_perks
	rustg_file_write(json_encode(data), AQUILA_PERKS_FALLBACK_FILE)

/// Dodaje (albo odejmuje) sztuki perka; nigdy poniżej zera
/proc/aquila_perk_adjust(player_ckey, perk, delta)
	aquila_perk_set(player_ckey, perk, max(0, aquila_perk_get(player_ckey, perk) + delta))

/// Odznaki wszystkich graczy: ckey => numer odznaki
/proc/aquila_all_badges()
	var/list/badges = list()
	if(aquila_perks_db_ready())
		var/datum/DBQuery/query_badges = SSdbcore.NewQuery(
			"SELECT ckey, amount FROM [format_table_name("aquila_perks")] WHERE perk = :perk AND amount > 0",
			list("perk" = PERK_BADGE)
		)
		if(query_badges.Execute())
			while(query_badges.NextRow())
				badges[query_badges.item[1]] = text2num(query_badges.item[2])
		qdel(query_badges)
		return badges
	var/list/data = aquila_perks_load_fallback()
	for(var/player_ckey in data)
		var/badge = data[player_ckey][PERK_BADGE]
		if(badge)
			badges[player_ckey] = badge
	return badges

// Sklep: przedmioty do kupowania wiele razy

/datum/gear
	/// Można kupować wiele razy (towar zużywalny, nie trafia do purchased_gear)
	var/multi_purchase = FALSE

/datum/gear/ooc/real_antagtoken
	cost = 10000
	multi_purchase = TRUE

/datum/gear/ooc/job_ticket
	display_name = "bilet na pracę"
	description = "Jednorazowe pierwszeństwo do pracy z najwyższym priorytetem. Użyj go w lobby przed startem rundy (OOC -> Użyj biletu na pracę) - zużywa się tylko, gdy dostaniesz tę pracę."
	cost = 3000
	multi_purchase = TRUE

/datum/gear/ooc/job_ticket/purchase(client/C)
	aquila_perk_adjust(C.ckey, PERK_JOB_TICKET, 1)
	to_chat(C, "<span class='notice'>Masz biletów na pracę: [aquila_perk_get(C.ckey, PERK_JOB_TICKET)].</span>")

/datum/gear/ooc/insurance
	display_name = "ubezpieczenie salda"
	description = "Jeśli zginiesz albo się nie ewakuujesz, połowa salda z karty i tak zamieni się na aquilosy. Zużywa się tylko wtedy, gdy wypłaci pieniądze."
	cost = 2000
	multi_purchase = TRUE

/datum/gear/ooc/insurance/purchase(client/C)
	aquila_perk_adjust(C.ckey, PERK_INSURANCE, 1)
	to_chat(C, "<span class='notice'>Masz ubezpieczeń: [aquila_perk_get(C.ckey, PERK_INSURANCE)].</span>")

/datum/gear/ooc/event_token
	display_name = "event token"
	description = "Odpal dowolny event w trakcie rundy (OOC -> Użyj event tokena). Admini mają 10 sekund, żeby go anulować - wtedy token wraca."
	cost = 5000
	multi_purchase = TRUE

/datum/gear/ooc/event_token/purchase(client/C)
	aquila_perk_adjust(C.ckey, PERK_EVENT_TOKEN, 1)
	to_chat(C, "<span class='notice'>Masz event tokenów: [aquila_perk_get(C.ckey, PERK_EVENT_TOKEN)].</span>")

/// ckey => TRUE, gdy gracz właśnie odpala event (żeby nie zużyć dwóch tokenów naraz)
GLOBAL_LIST_EMPTY(event_tokens_in_use)

/// Event token: wybór eventu z listy i odpalenie go tak jak przez admina (z 10 s na anulowanie)
/client/verb/use_event_token()
	set name = "Użyj event tokena"
	set category = "OOC"
	set desc = "Odpala wybrany event za event token kupiony za aquilosy."

	if(SSticker.current_state != GAME_STATE_PLAYING)
		to_chat(src, "<span class='warning'>Event token działa tylko w trakcie rundy.</span>")
		return
	if(GLOB.event_tokens_in_use[ckey])
		to_chat(src, "<span class='warning'>Już odpalasz event.</span>")
		return
	if(aquila_perk_get(ckey, PERK_EVENT_TOKEN) < 1)
		to_chat(src, "<span class='warning'>Nie masz event tokenów - kupisz je w loadoucie, w kategorii OOC.</span>")
		return

	var/list/choices = list()
	for(var/datum/round_event_control/event_control as anything in SSevents.control)
		if(event_control.holidayID && !(event_control.holidayID in SSevents.holidays))
			continue
		choices["[event_control.name]"] = event_control
	var/choice = tgui_input_list(src, "Który event odpalić?", "Event token", sortList(choices))
	var/datum/round_event_control/chosen = choices[choice]
	if(!chosen || GLOB.event_tokens_in_use[ckey])
		return
	if(tgui_alert(src, "Odpalić „[chosen.name]”? To zużyje event token.", "Event token", list("Tak", "Nie")) != "Tak")
		return
	if(aquila_perk_get(ckey, PERK_EVENT_TOKEN) < 1 || SSticker.current_state != GAME_STATE_PLAYING)
		return

	GLOB.event_tokens_in_use[ckey] = TRUE
	message_admins("[key_name_admin(src)] używa event tokena: [chosen.name].")
	log_game("[key_name(src)] used an event token: [chosen.name] ([chosen.type])")
	chosen.random = FALSE
	var/result = chosen.preRunEvent() // daje adminom 10 s na anulowanie
	if(result == EVENT_READY)
		aquila_perk_adjust(ckey, PERK_EVENT_TOKEN, -1)
		chosen.runEvent()
		to_chat(src, "<span class='notice'>Event „[chosen.name]” odpalony. Zostało ci tokenów: [aquila_perk_get(ckey, PERK_EVENT_TOKEN)].</span>")
	else
		to_chat(src, "<span class='warning'>Event „[chosen.name]” nie wystartował (anulowany albo warunki nie są spełnione). Token wraca do ciebie.</span>")
	GLOB.event_tokens_in_use -= ckey

/datum/gear/ooc/admin_item_token
	display_name = "admin item token"
	description = "Przywołaj jeden zabawny przedmiot, który normalnie mają tylko admini (OOC -> Przywołaj przedmiot admina): deskorolka Board Of Directors, nieskończona pizza, wódka Badminka, aparat widzący duchy, mundury i pościel CentComu, wieczna świeca."
	cost = 5000
	multi_purchase = TRUE

/datum/gear/ooc/admin_item_token/purchase(client/C)
	aquila_perk_adjust(C.ckey, PERK_ADMIN_ITEM_TOKEN, 1)
	to_chat(C, "<span class='notice'>Masz admin item tokenów: [aquila_perk_get(C.ckey, PERK_ADMIN_ITEM_TOKEN)].</span>")

/// Przedmioty adminowskie do przywołania za token: tylko zabawne i kosmetyczne (nazwa => typ)
GLOBAL_LIST_INIT(admin_item_token_items, list(
	"Board Of Directors (deskorolka admina)" = /obj/item/melee/skateboard/hoverboard/admin,
	"Nieskończone pudełko pizzy" = /obj/item/pizzabox/infinite,
	"Wódka Badminka" = /obj/item/reagent_containers/food/drinks/bottle/vodka/badminka,
	"Aparat widzący duchy" = /obj/item/camera/spooky/badmin,
	"Mundur oficera CentComu" = /obj/item/clothing/under/rank/centcom/commander,
	"Mundur funkcjonariusza CentComu" = /obj/item/clothing/under/rank/centcom/officer,
	"Mundur stażysty CentComu" = /obj/item/clothing/under/rank/centcom/intern,
	"Pościel CentComu" = /obj/item/bedsheet/centcom,
	"Podwójna pościel CentComu" = /obj/item/bedsheet/double/centcom,
	"Wieczna świeca" = /obj/item/candle/infinite,
))

/// Admin item token: wybrany przedmiot z listy ląduje w ręce postaci
/client/verb/use_admin_item_token()
	set name = "Przywołaj przedmiot admina"
	set category = "OOC"
	set desc = "Przywołuje zabawny przedmiot adminowski za admin item token kupiony za aquilosy."

	var/mob/living/carbon/human/user = mob
	if(SSticker.current_state != GAME_STATE_PLAYING || !ishuman(user) || user.stat == DEAD)
		to_chat(src, "<span class='warning'>Przedmiot możesz przywołać tylko żywą postacią w trakcie rundy.</span>")
		return
	if(aquila_perk_get(ckey, PERK_ADMIN_ITEM_TOKEN) < 1)
		to_chat(src, "<span class='warning'>Nie masz admin item tokenów - kupisz je w loadoucie, w kategorii OOC.</span>")
		return
	var/choice = tgui_input_list(src, "Który przedmiot przywołać?", "Admin item token", GLOB.admin_item_token_items)
	var/item_type = GLOB.admin_item_token_items[choice]
	if(!item_type || mob != user || user.stat == DEAD)
		return
	if(aquila_perk_get(ckey, PERK_ADMIN_ITEM_TOKEN) < 1)
		return
	aquila_perk_adjust(ckey, PERK_ADMIN_ITEM_TOKEN, -1)
	var/obj/item/summoned = new item_type(get_turf(user))
	user.put_in_hands(summoned)
	playsound(user, 'sound/magic/summonitems_generic.ogg', 50, TRUE)
	user.visible_message("<span class='notice'>W rękach [user] pojawia się [summoned]!</span>", "<span class='notice'>Przywołujesz [summoned].</span>")
	message_admins("[key_name_admin(src)] przywołał przedmiot za admin item token: [summoned] ([item_type]).")
	log_game("[key_name(src)] summoned [item_type] with an admin item token")

// Odznaki w rankingu

/// Odznaki: numer => list(nazwa, ikona Font Awesome 5, kolor)
GLOBAL_LIST_INIT(aquila_badges, list(
	list("name" = "Rekin biznesu", "icon" = "dollar-sign", "color" = "#4caf50"),
	list("name" = "Wieczny ewakuowany", "icon" = "space-shuttle", "color" = "#4fc3f7"),
	list("name" = "Złota karta", "icon" = "credit-card", "color" = "#ffd54f"),
	list("name" = "Kapitan przemysłu", "icon" = "industry", "color" = "#ff8a65"),
	list("name" = "Magnat", "icon" = "crown", "color" = "#ce93d8"),
))

/// Dane odznaki dla UI albo null
/proc/aquila_badge_data(badge_id)
	if(!isnum(badge_id) || badge_id < 1 || badge_id > length(GLOB.aquila_badges))
		return null
	return GLOB.aquila_badges[badge_id]

/datum/gear/ooc/badge
	subtype_path = /datum/gear/ooc/badge
	cost = 10000
	description = "Odznaka przy twoim ckey w rankingu zarobków i w raporcie końca rundy. Kupiona odznaka od razu staje się aktywna; zmienisz ją w OOC -> Wybierz odznakę."
	/// Numer odznaki w GLOB.aquila_badges
	var/badge_id = 0

/datum/gear/ooc/badge/purchase(client/C)
	aquila_perk_set(C.ckey, PERK_BADGE, badge_id)
	to_chat(C, "<span class='notice'>Twoja odznaka w rankingu to teraz: [aquila_badge_data(badge_id)?["name"]].</span>")

/datum/gear/ooc/badge/shark
	display_name = "odznaka w rankingu: Rekin biznesu"
	badge_id = 1
	cost = 10000

/datum/gear/ooc/badge/evacuee
	display_name = "odznaka w rankingu: Wieczny ewakuowany"
	badge_id = 2
	cost = 10000

/datum/gear/ooc/badge/gold_card
	display_name = "odznaka w rankingu: Złota karta"
	badge_id = 3
	cost = 15000

/datum/gear/ooc/badge/industry
	display_name = "odznaka w rankingu: Kapitan przemysłu"
	badge_id = 4
	cost = 20000

/datum/gear/ooc/badge/magnate
	display_name = "odznaka w rankingu: Magnat"
	badge_id = 5
	cost = 30000

/// Zmiana aktywnej odznaki spośród kupionych
/client/verb/choose_ranking_badge()
	set name = "Wybierz odznakę"
	set category = "OOC"
	set desc = "Wybierz, którą z kupionych odznak pokazywać w rankingu zarobków."

	var/list/owned = list("Bez odznaki" = 0)
	for(var/badge_type in subtypesof(/datum/gear/ooc/badge))
		var/datum/gear/ooc/badge/badge = new badge_type
		if(badge.id in prefs?.purchased_gear)
			owned[aquila_badge_data(badge.badge_id)["name"]] = badge.badge_id
		qdel(badge)
	if(length(owned) == 1)
		to_chat(src, "<span class='warning'>Nie masz jeszcze żadnej odznaki - kupisz je w loadoucie, w kategorii OOC.</span>")
		return
	var/choice = tgui_input_list(src, "Którą odznakę pokazywać w rankingu?", "Odznaka w rankingu", owned)
	if(isnull(choice) || !(choice in owned))
		return
	aquila_perk_set(ckey, PERK_BADGE, owned[choice])
	GLOB.economy_leaderboard_loaded = FALSE
	to_chat(src, "<span class='notice'>Odznaka w rankingu: [choice].</span>")

// Bilet na pracę

/// Użycie biletu w lobby: daje pierwszeństwo do pracy z najwyższym priorytetem w tej rundzie
/client/verb/use_job_ticket()
	set name = "Użyj biletu na pracę"
	set category = "OOC"
	set desc = "Pierwszeństwo do pracy z najwyższym priorytetem przy starcie tej rundy."

	if(SSticker.current_state > GAME_STATE_PREGAME)
		to_chat(src, "<span class='warning'>Bilet można użyć tylko w lobby, przed startem rundy.</span>")
		return
	if(GLOB.armed_job_tickets[ckey])
		GLOB.armed_job_tickets -= ckey
		to_chat(src, "<span class='notice'>Bilet na pracę nie zostanie użyty w tej rundzie.</span>")
		return
	var/tickets = aquila_perk_get(ckey, PERK_JOB_TICKET)
	if(tickets < 1)
		to_chat(src, "<span class='warning'>Nie masz biletów na pracę - kupisz je w loadoucie, w kategorii OOC.</span>")
		return
	GLOB.armed_job_tickets[ckey] = TRUE
	to_chat(src, "<span class='notice'>Bilet na pracę gotowy (masz [tickets]). Zużyje się tylko, jeśli dzięki niemu dostaniesz pracę z najwyższym priorytetem. Użyj czasownika jeszcze raz, by zrezygnować.</span>")

/// Przed zwykłym losowaniem prac: gracze z biletem dostają pracę z najwyższym priorytetem, jeśli jest miejsce
/datum/controller/subsystem/job/proc/assign_job_tickets()
	for(var/mob/dead/new_player/player in unassigned)
		var/client/player_client = player.client
		if(!player_client || !GLOB.armed_job_tickets[player_client.ckey])
			continue
		var/wanted_title
		for(var/title in player_client.prefs.active_character.job_preferences)
			if(player_client.prefs.active_character.job_preferences[title] == JP_HIGH)
				wanted_title = title
				break
		var/datum/job/job = GetJob(wanted_title)
		if(!job || (job.spawn_positions != -1 && job.current_positions >= job.spawn_positions))
			to_chat(player_client, "<span class='warning'>Bilet na pracę nie został użyty - praca z najwyższym priorytetem jest niedostępna albo zajęta.</span>")
			continue
		if(player.mind && (job.title in player.mind.restricted_roles))
			continue
		if(!AssignRole(player, job.title))
			continue
		aquila_perk_adjust(player_client.ckey, PERK_JOB_TICKET, -1)
		to_chat(player_client, "<span class='notice'>Bilet na pracę użyty: dostajesz pracę [job.title].</span>")
	GLOB.armed_job_tickets.Cut()

// Ubezpieczenie

/// Na koniec rundy: jeśli saldo nie zamienia się na aquilosy (śmierć, brak ewakuacji), ubezpieczenie wypłaca połowę
/client/proc/process_aquila_insurance()
	if(!CONFIG_GET(flag/allow_endround_bank_balance_metacoin_conversion))
		return
	if(get_endround_bank_account())
		return // saldo i tak przechodzi w całości
	var/mob/living/carbon/human/body = mob?.mind?.current
	if(!ishuman(body))
		return
	var/datum/bank_account/account = body.get_bank_account() || find_bank_account_by_id(body.account_id)
	if(!account || account.account_balance <= 0)
		return
	if(aquila_perk_get(ckey, PERK_INSURANCE) < 1)
		return
	var/coeff = CONFIG_GET(number/bank_balance_metacoin_conversion_coefficient) || 0
	var/payout = FLOOR(account.account_balance * coeff * INSURANCE_PAYOUT, 1)
	if(payout <= 0)
		return
	aquila_perk_adjust(ckey, PERK_INSURANCE, -1)
	inc_metabalance(payout, reason="Ubezpieczenie wypłaciło połowę salda konta.")

#undef AQUILA_PERKS_FALLBACK_FILE
#undef INSURANCE_PAYOUT
