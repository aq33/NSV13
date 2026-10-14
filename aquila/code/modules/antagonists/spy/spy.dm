// Spy antagonist (port of tgstation code/modules/antagonists/spy/spy.dm)

/datum/antagonist/spy
	name = "Szpieg"
	roundend_category = "szpiedzy"
	antagpanel_category = "Spy"
	banning_key = ROLE_SPY
	antag_moodlet = /datum/mood_event/focused
	hijack_speed = 1
	ui_name = "AntagInfoSpy"
	/// Whether an uplink has been created (successfully or at all)
	var/uplink_created = FALSE
	/// String displayed in the antag panel pointing the spy to where their uplink is.
	var/uplink_location
	/// Whether we give them some random objetives to aim for.
	var/spawn_with_objectives = TRUE
	/// Tracks number of bounties claimed, for roundend
	var/bounties_claimed = 0
	/// Tracks all loot items the spy has claimed, for roundend
	var/list/all_loot = list()
	/// Weakref to our spy uplink
	/// Only exists for the sole purpose of letting admins see it
	var/datum/weakref/uplink_weakref

/datum/antagonist/spy/on_gain()
	if(!uplink_created)
		auto_create_spy_uplink(owner.current)
	if(spawn_with_objectives)
		give_random_objectives()
	owner.special_role = ROLE_SPY
	. = ..()
	SEND_SOUND(owner.current, sound('aquila/sound/ambience/antag/spy.ogg'))

/datum/antagonist/spy/on_removal()
	if(owner)
		owner.special_role = null
	var/datum/component/spy_uplink/uplink = uplink_weakref?.resolve()
	if(uplink)
		qdel(uplink)
	return ..()

/datum/antagonist/spy/apply_innate_effects(mob/living/mob_override)
	. = ..()
	var/mob/living/spy = mob_override || owner.current
	var/datum/atom_hud/antag/traitorhud = GLOB.huds[ANTAG_HUD_TRAITOR]
	traitorhud.join_hud(spy)
	set_antag_hud(spy, "traitor")

/datum/antagonist/spy/remove_innate_effects(mob/living/mob_override)
	. = ..()
	var/mob/living/spy = mob_override || owner.current
	var/datum/atom_hud/antag/traitorhud = GLOB.huds[ANTAG_HUD_TRAITOR]
	traitorhud.leave_hud(spy)
	set_antag_hud(spy, null)

/datum/antagonist/spy/greet()
	to_chat(owner.current, "<span class='alertsyndie'>Jesteś szpiegiem.</span>")
	to_chat(owner.current, "<span class='notice'>Twój uplink szpiega jest ukryty jako: [uplink_location || "coś przy tobie"]. Użyj go w ręce, żeby zobaczyć zlecenia, i kliknij go <b>prawym przyciskiem</b> na celu zlecenia, żeby go ukraść.</span>")
	owner.announce_objectives()
	owner.current.client?.tgui_panel?.give_antagonist_popup("Szpieg",
		"Kradnij cele zleceń i odbieraj nagrody.")

/datum/antagonist/spy/ui_static_data(mob/user)
	var/list/data = ..()
	data["uplink_location"] = uplink_location
	return data

/datum/antagonist/spy/get_admin_commands()
	. = ..()
	.["Zobacz zlecenia (wszyscy szpiedzy)"] = CALLBACK(src, PROC_REF(see_bounties))
	.["Odśwież zlecenia (wszyscy szpiedzy)"] = CALLBACK(src, PROC_REF(refresh_bounties))
	.["Daj uplink szpiega"] = CALLBACK(src, PROC_REF(admin_create_spy_uplink))
	.["VV handlera zleceń"] = CALLBACK(src, PROC_REF(bounty_handler_vv))

/datum/antagonist/spy/proc/see_bounties(mob/admin)
	if(!check_rights(R_ADMIN|R_DEBUG))
		return

	var/datum/component/spy_uplink/uplink = uplink_weakref?.resolve()
	if(isnull(uplink))
		tgui_alert(admin, "Brak uplinku szpiega!", "Misja nieudana")
		return

	uplink.ui_interact(admin)

/datum/antagonist/spy/proc/refresh_bounties(mob/admin)
	if(!check_rights(R_ADMIN|R_DEBUG))
		return

	var/datum/component/spy_uplink/uplink = uplink_weakref?.resolve()
	if(isnull(uplink))
		tgui_alert(admin, "Brak uplinku szpiega!", "Misja nieudana")
		return

	uplink.handler.force_refresh()
	tgui_alert(admin, "Zlecenia odświeżone.", "Misja udana")

/datum/antagonist/spy/proc/admin_create_spy_uplink(mob/admin)
	if(!check_rights(R_ADMIN|R_DEBUG))
		return

	if(!auto_create_spy_uplink(owner.current, give_backup = FALSE))
		tgui_alert(admin, "Nie udało się dać uplinku szpiega [owner.current]. Pewnie nie ma przedmiotu, w którym dałoby się go ukryć.", "Misja nieudana")

/datum/antagonist/spy/proc/bounty_handler_vv(mob/admin)
	if(!check_rights(R_ADMIN|R_DEBUG))
		return

	var/datum/component/spy_uplink/uplink = uplink_weakref?.resolve()
	if(isnull(uplink))
		tgui_alert(admin, "Brak uplinku szpiega!", "Misja nieudana")
		return

	admin.client?.debug_variables(uplink.handler)

/// Finds the item the spy uplink goes into, following the uplink location preference like the traitor uplink does.
/datum/antagonist/spy/proc/find_uplink_host(mob/living/carbon/spy)
	var/list/all_contents = spy.GetAllContents()
	var/obj/item/modular_computer/tablet/pda/pda = locate() in all_contents
	var/obj/item/radio/radio = locate() in all_contents
	var/obj/item/pen/pen
	if(pda)
		pen = locate() in pda
	if(!pen)
		pen = locate() in all_contents

	var/spy_uplink_loc = spy.client?.prefs?.active_character?.uplink_spawn_loc
	if(isnull(spy_uplink_loc) || spy_uplink_loc == UPLINK_IMPLANT)
		spy_uplink_loc = pick(UPLINK_PEN, UPLINK_PDA)

	switch(spy_uplink_loc)
		if(UPLINK_PEN)
			return pen || pda || radio
		if(UPLINK_RADIO)
			return radio || pda || pen
	return pda || pen || radio

/datum/antagonist/spy/proc/auto_create_spy_uplink(mob/living/carbon/spy, give_backup = TRUE)
	if(!iscarbon(spy))
		return FALSE

	var/obj/item/spy_uplink = find_uplink_host(spy)
	if(isnull(spy_uplink) || !create_spy_uplink(spy, spy_uplink))
		if(give_backup)
			var/datum/action/backup_uplink/backup = new(src)
			backup.Grant(spy)
			to_chat(spy, "<span class='boldnotice'>Nie dało się wyposażyć cię w uplink, więc możesz zrobić go sam.</span>")
		return FALSE

	return TRUE

/datum/antagonist/spy/proc/create_spy_uplink(mob/living/carbon/spy, obj/item/spy_uplink)
	var/datum/component/spy_uplink/uplink = spy_uplink.AddComponent(/datum/component/spy_uplink, src)
	if(!uplink)
		return FALSE

	uplink_weakref = WEAKREF(uplink)
	uplink_created = TRUE

	if(istype(spy_uplink, /obj/item/modular_computer/tablet/pda))
		uplink_location = "twoje PDA"

	else if(istype(spy_uplink, /obj/item/pen))
		if(istype(spy_uplink.loc, /obj/item/modular_computer/tablet/pda))
			uplink_location = "długopis w twoim PDA"
		else
			uplink_location = "długopis"

	else if(istype(spy_uplink, /obj/item/radio))
		uplink_location = "twoje słuchawki"

	return TRUE

/datum/antagonist/spy/proc/give_random_objectives()
	load_strings_file(SPY_OBJECTIVE_FILE, "aquila/strings")
	for(var/i in 1 to rand(1, 3))
		var/datum/objective/custom/your_mission = new()
		your_mission.owner = owner
		your_mission.explanation_text = pick_list_replacements(SPY_OBJECTIVE_FILE, "objective_body")
		objectives += your_mission

	if((length(objectives) < 3) && prob(25))
		var/datum/objective/protect/save_the_person = prob(50) ? new /datum/objective/protect() : new /datum/objective/protect/nonhuman()
		save_the_person.owner = owner
		save_the_person.find_target()
		objectives += save_the_person

	if(prob(10))
		var/datum/objective/martyr/leave_no_trace = new()
		leave_no_trace.owner = owner
		objectives += leave_no_trace

	else if(prob(3)) //3% chance on 90% chance
		var/datum/objective/hijack/steal_the_shuttle = new()
		steal_the_shuttle.owner = owner
		objectives += steal_the_shuttle

	else
		var/datum/objective/escape/gtfo = new()
		gtfo.owner = owner
		objectives += gtfo

/datum/antagonist/spy/antag_panel_data()
	return "Wykonane zlecenia: [bounties_claimed]"

/datum/antagonist/spy/roundend_report()
	var/list/report = list()
	report += printplayer(owner)
	report += " - Wykonane zlecenia: <b>[bounties_claimed]</b>."
	if(bounties_claimed > 0)
		report += " - Zdobyte nagrody: [english_list(all_loot)]"
	report += printobjectives(objectives)
	return report.Join("<br>")

/datum/action/backup_uplink
	name = "Zrób uplink"
	desc = "Przerób PDA, długopis albo słuchawki na elegancki uplink szpiega."
	var/list/valid_types = list(
		/obj/item/modular_computer/tablet/pda,
		/obj/item/pen,
		/obj/item/radio,
	)

/datum/action/backup_uplink/New(Target)
	. = ..()
	if(!istype(Target, /datum/antagonist/spy))
		stack_trace("[type] created on invalid target [Target || "null"]")
		qdel(src)

/datum/action/backup_uplink/Trigger()
	. = ..()
	if(!.)
		return

	var/mob/living/spy = owner
	var/obj/item/held_thing = spy.get_active_held_item()
	if(isnull(held_thing))
		spy.balloon_alert(spy, "weź coś do ręki!")
		return

	if(!is_type_in_list(held_thing, valid_types))
		held_thing.balloon_alert(spy, "nie ten przedmiot!")
		return

	var/datum/antagonist/spy/spy_datum = target
	spy_datum.create_spy_uplink(spy, held_thing)
	held_thing.balloon_alert(spy, "uplink gotowy")

	qdel(src)

/datum/role_preference/antagonist/spy
	name = "Szpieg"
	antag_datum = /datum/antagonist/spy
