// AQUILA - pad i konsola zleceń cywilnych, port z tgstation (civilian_bounty/bounty_machinery.dm)

/// Pad, na który kładzie się przedmioty do zleceń cywilnych
/obj/machinery/piratepad/civilian
	name = "civilian bounty pad"
	desc = "Pad wysyłający przedmioty do zleceń cywilnych prosto do Centrali."
	layer = TABLE_LAYER
	resistance_flags = FIRE_PROOF
	circuit = /obj/item/circuitboard/machine/bountypad
	/// O ile krócej czeka się na nowe propozycje zleceń (lepsze części)
	var/cooldown_reduction = 0

/obj/machinery/piratepad/civilian/RefreshParts()
	var/tiers = -2
	for(var/obj/item/stock_parts/micro_laser/laser in component_parts)
		tiers += laser.rating
	for(var/obj/item/stock_parts/scanning_module/scanner in component_parts)
		tiers += scanner.rating
	cooldown_reduction = max(0, tiers) * (30 SECONDS)

/obj/machinery/piratepad/civilian/attackby(obj/item/I, mob/living/user, params)
	if(default_deconstruction_screwdriver(user, idle_state, idle_state, I))
		return TRUE
	if(default_deconstruction_crowbar(I))
		return TRUE
	return ..()

/// Konsola przypisująca zlecenia do kart i wysyłająca rzeczy z padu
/obj/machinery/computer/piratepad_control/civilian
	name = "civilian bounty control terminal"
	desc = "Konsola przypisująca zlecenia cywilne do włożonej karty identyfikacyjnej i sterująca padem zleceń."
	status_report = "Gotowe do wysyłki."
	icon_screen = "civ_bounty"
	icon_keyboard = "id_key"
	warmup_time = 3 SECONDS
	circuit = /obj/item/circuitboard/computer/bountypad
	light_color = "#E2853D"
	/// Włożona karta; zlecenia trzyma konto z karty
	var/obj/item/card/id/inserted_scan_id
	COOLDOWN_DECLARE(sheet_printer_cooldown)

/obj/machinery/computer/piratepad_control/civilian/Destroy()
	if(inserted_scan_id)
		inserted_scan_id.forceMove(drop_location())
		inserted_scan_id = null
	return ..()

/obj/machinery/computer/piratepad_control/civilian/LateInitialize()
	if(cargo_hold_id)
		for(var/obj/machinery/piratepad/civilian/civ_pad in GLOB.machines)
			if(civ_pad.cargo_hold_id == cargo_hold_id)
				set_pad(civ_pad)
				return
	else
		set_pad(locate(/obj/machinery/piratepad/civilian) in range(4, src))

/// Ekran konsoli leży w ikonie Aquili, a podstawa w zwykłym computer.dmi
/obj/machinery/computer/piratepad_control/civilian/update_overlays()
	var/real_screen = icon_screen
	icon_screen = null
	. = ..()
	icon_screen = real_screen
	if(machine_stat & (NOPOWER|BROKEN))
		return
	. += mutable_appearance('aquila/icons/obj/economy/bounty_market.dmi', icon_screen)
	. += emissive_appearance('aquila/icons/obj/economy/bounty_market.dmi', icon_screen)

/obj/machinery/computer/piratepad_control/civilian/attackby(obj/item/I, mob/living/user, params)
	if(istype(I, /obj/item/card/id))
		id_insert(user, I)
		return TRUE
	if(I.GetID())
		to_chat(user, "<span class='warning'>Wyjmij kartę z [I] i włóż ją do konsoli.</span>")
		return TRUE
	return ..()

/obj/machinery/computer/piratepad_control/civilian/AltClick(mob/user)
	if(!user.canUseTopic(src, BE_CLOSE))
		return
	id_eject(user)

/obj/machinery/computer/piratepad_control/civilian/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "CivCargoHoldTerminal")
		ui.open()

/obj/machinery/computer/piratepad_control/civilian/recalc()
	if(sending)
		return FALSE
	if(!inserted_scan_id)
		status_report = "Najpierw włóż kartę identyfikacyjną."
		playsound(loc, 'sound/machines/synth_no.ogg', 30, TRUE)
		return FALSE
	if(!inserted_scan_id.registered_account?.civilian_bounty)
		status_report = "Najpierw weź nowe zlecenie."
		playsound(loc, 'sound/machines/synth_no.ogg', 30, TRUE)
		return FALSE
	status_report = "Zlecenie: "
	for(var/atom/movable/possible_shippable in get_turf(pad))
		if(!can_ship(possible_shippable))
			continue
		if(inserted_scan_id.registered_account.civilian_bounty.applies_to(possible_shippable))
			status_report += "przedmiot pasuje."
			playsound(loc, 'sound/machines/synth_yes.ogg', 30, TRUE)
			return TRUE
	status_report += "nic nie pasuje."
	playsound(loc, 'sound/machines/synth_no.ogg', 30, TRUE)
	return FALSE

/obj/machinery/computer/piratepad_control/civilian/proc/can_ship(atom/movable/possible_shippable)
	if(possible_shippable == pad)
		return FALSE
	if(possible_shippable.flags_1 & HOLOGRAM_1)
		return FALSE
	if(isitem(possible_shippable))
		var/obj/item/possible_shippable_item = possible_shippable
		if(possible_shippable_item.item_flags & ABSTRACT)
			return FALSE
	return TRUE

/obj/machinery/computer/piratepad_control/civilian/start_sending(check_global = FALSE)
	if(sending || !pad)
		return
	if(!inserted_scan_id?.registered_account)
		status_report = "Najpierw włóż kartę z kontem bankowym."
		playsound(loc, 'sound/machines/synth_no.ogg', 30, TRUE)
		return
	sending = TRUE
	status_report = "Wysyłanie..."
	pad.visible_message("<span class='notice'>[pad] zaczyna się ładować.</span>")
	pad.icon_state = pad.warmup_state
	sending_timer = addtimer(CALLBACK(src, PROC_REF(send), check_global), warmup_time, TIMER_STOPPABLE)

/// Przepisuje send() padu piratów: liczą się tylko przedmioty do zleceń
/obj/machinery/computer/piratepad_control/civilian/send(check_global = FALSE)
	if(!sending)
		return FALSE
	status_report = ""
	var/datum/bank_account/id_account = inserted_scan_id?.registered_account
	if(!pad || !id_account)
		stop_sending()
		return FALSE

	var/list/datum/bounty/bounty_stack = list()
	if(check_global)
		bounty_stack = GLOB.shared_crew_bounties.Copy()
	else if(id_account.civilian_bounty)
		bounty_stack += id_account.civilian_bounty

	if(!length(bounty_stack))
		status_report = check_global ? "Brak zleceń dla statku." : "Najpierw weź nowe zlecenie."
		stop_sending()
		return FALSE

	playsound(loc, 'sound/machines/terminal_alert.ogg', 50, TRUE)
	var/active_count = 0
	for(var/atom/movable/possible_shippable in get_turf(pad))
		if(!can_ship(possible_shippable))
			continue
		for(var/datum/bounty/stack_item as anything in bounty_stack)
			if(!stack_item.applies_to(possible_shippable))
				continue
			active_count++
			LAZYADDASSOC(stack_item.contribution, id_account, stack_item.contribution_amount(possible_shippable))
			stack_item.ship(possible_shippable)
			qdel(possible_shippable)
			break

	if(active_count)
		status_report += "Wysłano przedmioty do zleceń: [active_count]. "
	else
		status_report = "Nie znaleziono pasujących przedmiotów. Przerwano wysyłkę."
		stop_sending()
		return FALSE

	var/claimed_count = 0
	for(var/datum/bounty/stack_item as anything in bounty_stack)
		if(!stack_item.can_claim())
			continue
		claimed_count++
		SSblackbox.record_feedback("tally", "civ_bounties_completed", 1, stack_item.type)
		stack_item.claimed = TRUE
		stack_item.on_claimed(inserted_scan_id)
		if(check_global)
			// ukończone zlecenie statku zalicza też takie samo zlecenie osobiste pomocników
			SSeconomy.civ_bounty_tracker++
			for(var/datum/bank_account/helper as anything in stack_item.contribution)
				if(istype(helper?.civilian_bounty, stack_item.type))
					helper.reset_bounty()
					helper.bank_card_talk("Twoje zlecenie [stack_item.name] zostało zaliczone razem z ukończonym zleceniem statku!")
		else
			id_account.reset_bounty(inserted_scan_id)

		var/obj/item/bounty_cube/reward = new /obj/item/bounty_cube(drop_location())
		reward.set_up(stack_item, inserted_scan_id)

	if(claimed_count)
		status_report += "Ukończono zlecenia: [claimed_count]! Oddaj kostki zleceń do zaopatrzenia, by dostać wypłatę."

	if(check_global)
		update_global_bounty_list(round(CIV_BOUNTY_BASELINE + (SSeconomy.civ_bounty_tracker / 3)))

	pad.visible_message("<span class='notice'>[pad] uruchamia się!</span>")
	flick(pad.sending_state, pad)
	pad.icon_state = pad.idle_state
	playsound(loc, 'sound/machines/synth_yes.ogg', 30, TRUE)
	sending = FALSE
	ui_update()
	return TRUE

/// Daje kontu z karty nowe propozycje zleceń dla jego pracy
/obj/machinery/computer/piratepad_control/civilian/proc/add_bounties(mob/user)
	var/datum/bank_account/id_account = inserted_scan_id?.registered_account
	if(!id_account)
		say("Włożona karta nie ma konta bankowego!")
		return FALSE
	if((id_account.civilian_bounty || id_account.bounties) && !COOLDOWN_FINISHED(id_account, bounty_timer))
		var/time_left = DisplayTimeText(COOLDOWN_TIMELEFT(id_account, bounty_timer), round_seconds_to = 1)
		balloon_alert(user, "spróbuj za [time_left]!")
		return FALSE
	var/datum/job/card_job = SSjob.GetJob(inserted_scan_id.assignment) || id_account.account_job
	if(!card_job)
		say("Karta nie ma przypisanej pracy!")
		return FALSE

	var/obj/machinery/piratepad/civilian/civ_pad = pad
	var/cooldown_reduction = istype(civ_pad) ? civ_pad.cooldown_reduction : 0
	COOLDOWN_START(id_account, bounty_timer, (5 MINUTES) - cooldown_reduction)
	id_account.bounties = generate_civ_bounty_list(card_job.bounty_types)
	return TRUE

/// Przypina wybraną propozycję do konta
/obj/machinery/computer/piratepad_control/civilian/proc/pick_bounty(choice)
	var/datum/bank_account/id_account = inserted_scan_id?.registered_account
	if(!id_account || !LAZYLEN(id_account.bounties) || choice < 1 || choice > length(id_account.bounties))
		playsound(loc, 'sound/machines/synth_no.ogg', 40, TRUE)
		return
	id_account.set_bounty(id_account.bounties[choice], inserted_scan_id)
	id_account.bounties = null
	SSblackbox.record_feedback("tally", "civ_bounties_assigned", 1, id_account.civilian_bounty.type)
	return id_account.civilian_bounty

/obj/machinery/computer/piratepad_control/civilian/ui_data(mob/user)
	var/list/data = list()
	data["points"] = points
	data["pad"] = pad ? TRUE : FALSE
	data["sending"] = sending
	data["status_report"] = status_report
	data["id_inserted"] = inserted_scan_id ? TRUE : FALSE
	data["claimed_bounties"] = SSeconomy.civ_bounty_tracker
	data["cut_percent"] = CIV_BOUNTY_SPLIT
	data["picking"] = FALSE

	var/datum/bank_account/id_account = inserted_scan_id?.registered_account
	if(id_account)
		if(id_account.civilian_bounty)
			data["id_bounty_info"] = id_account.civilian_bounty.description
			data["id_bounty_num"] = id_account.bounty_num()
			data["id_bounty_value"] = round(id_account.civilian_bounty.get_bounty_reward() * (CIV_BOUNTY_SPLIT / 100))
		if(LAZYLEN(id_account.bounties))
			data["picking"] = TRUE
			var/list/picks = list()
			for(var/datum/bounty/bounty as anything in id_account.bounties)
				picks += list(list(
					"name" = bounty.name,
					"description" = bounty.description,
					"value" = round(bounty.get_bounty_reward() * (CIV_BOUNTY_SPLIT / 100)),
				))
			data["id_bounty_picks"] = picks

	var/list/global_bounties = list()
	for(var/datum/bounty/global_bounty as anything in GLOB.shared_crew_bounties)
		global_bounties += list(list(
			"name" = global_bounty.name,
			"description" = global_bounty.description,
			"reward" = global_bounty.get_bounty_reward(),
			"claimed" = global_bounty.claimed,
			"shipped" = global_bounty.get_total(),
			"maximum" = global_bounty.get_max(),
			"priority" = global_bounty.high_priority,
			"unique" = global_bounty.unique,
			"ref" = REF(global_bounty),
		))
	data["listBounty"] = global_bounties
	return data

/obj/machinery/computer/piratepad_control/civilian/ui_act(action, params)
	if(machine_stat & (NOPOWER|BROKEN))
		return
	switch(action)
		if("pick")
			pick_bounty(text2num(params["value"]))
			return TRUE
		if("bounty")
			add_bounties(usr)
			return TRUE
		if("eject")
			id_eject(usr)
			return TRUE
		if("update_list")
			if(length(GLOB.shared_crew_bounties))
				return TRUE
			playsound(src, 'sound/machines/ping.ogg', 50)
			var/bonus_bounties = clamp(round(length(GLOB.player_list) / 8), 0, 5)
			looped_global_update(1, CIV_BOUNTY_BASELINE + bonus_bounties, first_time = TRUE)
			return TRUE
		if("print")
			print_sheet(usr)
			return TRUE
		if("send_global")
			if(pad)
				start_sending(TRUE)
			return TRUE
	return ..()

/obj/machinery/computer/piratepad_control/civilian/proc/id_insert(mob/user, obj/item/card/id/card_to_insert)
	if(!user.transferItemToLoc(card_to_insert, src))
		return FALSE
	var/obj/item/card/id/old_card = inserted_scan_id
	inserted_scan_id = card_to_insert
	if(old_card)
		old_card.forceMove(drop_location())
		user.put_in_hands(old_card)
	user.visible_message("<span class='notice'>[user] wkłada [card_to_insert] do [src].</span>", \
		"<span class='notice'>Wkładasz [card_to_insert] do [src].</span>")
	playsound(src, 'sound/machines/terminal_insert_disc.ogg', 50, FALSE)
	ui_interact(user)
	ui_update()
	return TRUE

/obj/machinery/computer/piratepad_control/civilian/proc/id_eject(mob/user)
	if(!inserted_scan_id)
		to_chat(user, "<span class='warning'>W konsoli nie ma karty!</span>")
		return FALSE
	var/obj/item/card/id/ejected = inserted_scan_id
	inserted_scan_id = null
	ejected.forceMove(drop_location())
	if(user && Adjacent(user))
		user.put_in_hands(ejected)
	user?.visible_message("<span class='notice'>[user] wyjmuje [ejected] z [src].</span>", \
		"<span class='notice'>Wyjmujesz [ejected] z [src].</span>")
	playsound(src, 'sound/machines/terminal_insert_disc.ogg', 50, FALSE)
	ui_update()
	return TRUE

/**
 * Czyści ukończone zlecenia z globalnej listy i dolosowuje nowe do limitu.
 *
 * * update_up_to - docelowa liczba zleceń (zlecenia specjalne się nie liczą)
 * * enable_high_priority - nowe zlecenia mogą zostać priorytetowe
 * * running_jobs - kategorie już wylosowane w tej serii, żeby się nie powtarzały
 */
/obj/machinery/computer/piratepad_control/civilian/proc/update_global_bounty_list(update_up_to = CIV_BOUNTY_BASELINE, enable_high_priority = FALSE, list/running_jobs)
	for(var/datum/bounty/complete_or_unique as anything in GLOB.shared_crew_bounties)
		if(complete_or_unique.claimed)
			GLOB.shared_crew_bounties -= complete_or_unique
			continue
		if(complete_or_unique.unique)
			update_up_to++

	var/list/jobs_picked = running_jobs || list()
	var/attempts = 50
	while(length(GLOB.shared_crew_bounties) < update_up_to && attempts-- > 0)
		var/job_code = rand(1, MAXIMUM_BOUNTY_JOBS)
		if(job_code in jobs_picked)
			if(length(jobs_picked) >= MAXIMUM_BOUNTY_JOBS)
				jobs_picked.Cut()
			continue
		jobs_picked += job_code

		var/datum/bounty/new_bounty = random_civ_bounty(job_code)
		if(!new_bounty)
			continue
		if(new_bounty.global_exempt)
			qdel(new_bounty)
			continue

		GLOB.shared_crew_bounties.Insert(1, new_bounty)

		if(enable_high_priority && prob(HIGH_PRIORITY_BOUNTY_ODDS))
			new_bounty.high_priority = TRUE
			new_bounty.description += "<br>To zlecenie jest <b>priorytetowe</b> i płaci <b>1,5x</b> więcej!"
	ui_update()
	return jobs_picked

/// Dodaje globalne zlecenia po jednym, z małym odstępem - dla efektu
/obj/machinery/computer/piratepad_control/civilian/proc/looped_global_update(current_count, update_to, list/inherited_list, first_time = FALSE)
	var/list/jobs_picked = update_global_bounty_list(current_count, TRUE, inherited_list)
	if(current_count >= update_to)
		if(first_time)
			for(var/special_type in civ_bounty_specials())
				var/datum/bounty/special = new special_type
				special.unique = TRUE
				GLOB.shared_crew_bounties += special
			ui_update()
		return TRUE
	addtimer(CALLBACK(src, PROC_REF(looped_global_update), current_count + 1, update_to, jobs_picked, first_time), 0.8 SECONDS)
	return FALSE

/obj/machinery/computer/piratepad_control/civilian/proc/print_sheet(mob/living/user)
	if(!COOLDOWN_FINISHED(src, sheet_printer_cooldown))
		balloon_alert(user, "drukarka zajęta!")
		return FALSE

	var/obj/item/paper/paper = new(loc)
	paper.name = "paper - Zlecenia"
	var/list/printout_text = list("<center><h2>Zlecenia Nanotrasen dla załogi</h2></center>")
	for(var/datum/bounty/current_bounty as anything in GLOB.shared_crew_bounties)
		if(current_bounty.claimed)
			continue
		printout_text += {"<h3>[current_bounty.name]</h3>
			<ul>
			<li>Wymagane: <i>[current_bounty.print_required()]</i></li>
			<li>Nagroda: <b>[current_bounty.get_bounty_reward()]</b> kr</li>
			<li>Udział wykonawców: <b>[round(BOUNTY_CUT_STANDARD * current_bounty.get_bounty_reward())]</b> kr</li>
			</ul>"}
	paper.add_raw_text(printout_text.Join(""))
	paper.update_appearance()

	playsound(src, 'sound/machines/copier.ogg', 50, TRUE)
	COOLDOWN_START(src, sheet_printer_cooldown, 4 SECONDS)
	return TRUE

/datum/controller/subsystem/economy
	/// Ile globalnych zleceń cywilnych ukończono; co 3 lista rośnie o jedno zlecenie
	var/civ_bounty_tracker = 0

/// Beacon zrzucający pad i konsolę zleceń cywilnych
/obj/item/civ_bounty_beacon
	name = "civilian bounty beacon"
	desc = "Zatwierdzony przez NT beacon zleceń cywilnych. Użyj go, a dostarczy pad i konsolę zleceń."
	icon = 'icons/obj/device.dmi'
	icon_state = "beacon"
	var/uses = 2
	/// Czeka na zrzut - bez tego szybkie klikanie zrzuciłoby kilka padów
	var/launching = FALSE

/obj/item/civ_bounty_beacon/attack_self(mob/user)
	if(launching)
		return
	launching = TRUE
	loc.visible_message("<span class='warning'>[src] zaczyna głośno piszczeć!</span>")
	addtimer(CALLBACK(src, PROC_REF(launch_payload)), 1 SECONDS)

/obj/item/civ_bounty_beacon/proc/launch_payload()
	launching = FALSE
	playsound(src, "sparks", 80, TRUE)
	switch(uses)
		if(2)
			new /obj/machinery/piratepad/civilian(drop_location())
		if(1)
			new /obj/machinery/computer/piratepad_control/civilian(drop_location())
			qdel(src)
	uses--

/obj/item/circuitboard/machine/bountypad
	name = "civilian bounty pad (Machine Board)"
	icon_state = "supply"
	build_path = /obj/machinery/piratepad/civilian
	req_components = list(
		/obj/item/stack/sheet/glass = 1,
		/obj/item/stock_parts/scanning_module = 1,
		/obj/item/stock_parts/micro_laser = 1,
	)

/obj/item/circuitboard/computer/bountypad
	name = "civilian bounty control terminal (Computer Board)"
	icon_state = "supply"
	build_path = /obj/machinery/computer/piratepad_control/civilian
