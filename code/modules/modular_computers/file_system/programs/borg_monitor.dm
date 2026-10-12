/datum/computer_file/program/borg_monitor
	filename = "cyborgmonitor"
	filedesc = "Zdalny monitoring cyborgów"
	category = PROGRAM_CATEGORY_ROBO
	ui_header = "borg_mon.gif"
	program_icon_state = "generic"
	extended_desc = "Ten program pozwala zdalnie monitorować cyborgi stacji."
	requires_ntnet = TRUE
	transfer_access = list(ACCESS_ROBOTICS)
	network_destination = "zdalny monitoring cyborgów"
	size = 5
	tgui_id = "NtosCyborgRemoteMonitor"
	program_icon = "project-diagram"
	var/emagged = FALSE

/datum/computer_file/program/borg_monitor/run_emag()
	if(emagged)
		return FALSE
	emagged = TRUE
	return TRUE



/datum/computer_file/program/borg_monitor/ui_data(mob/user)
	var/list/data = list()

	// Syndicate version doesn't require an ID - so we use this proc instead of computer.GetID()
	data["card"] = !!get_id_name()

	data["cyborgs"] = list()
	var/linked_overmap = computer.get_overmap() //nsv13 - shipwide monitoring
	for(var/mob/living/silicon/robot/R in GLOB.silicon_mobs)
		if(!evaluate_borg(R, linked_overmap)) //nsv13 - shipwide monitoring
			continue

		var/list/upgrade
		for(var/obj/item/borg/upgrade/I in R.upgrades)
			upgrade += "\[[I.name]\] "

		var/shell = FALSE
		if(R.shell && !R.ckey)
			shell = TRUE

		var/list/cyborg_data = list(
			name = R.name,
			locked_down = R.lockcharge,
			status = R.stat,
			shell_discon = shell,
			charge = R.cell ? round(R.cell.percent()) : null,
			module = R.module ? "[R.module.name] Module" : "Nie wykryto modułu",
			upgrades = upgrade,
			ref = REF(R)
		)
		data["cyborgs"] += list(cyborg_data)
	return data

/datum/computer_file/program/borg_monitor/ui_act(action, params)
	if(..())
		return

	switch(action)
		if("messagebot")
			var/mob/living/silicon/robot/R = locate(params["ref"]) in GLOB.silicon_mobs
			if(!istype(R))
				return TRUE
			var/sender_name = get_id_name()
			if(!sender_name)
				// This can only happen if the action somehow gets called as UI blocks this action with no ID
				computer.visible_message("<span class='notice'>Włóż identyfikator, by wysyłać wiadomości.</span>")
				playsound(usr, 'sound/machines/terminal_error.ogg', 15, TRUE)
				return TRUE
			if(R.stat == DEAD) //Dead borgs will listen to you no longer
				to_chat(usr, "<span class='warn'>Błąd – nie udało się nawiązać połączenia z jednostką: [R]</span>")
			var/message = stripped_input(usr, message = "Wpisz wiadomość do wysłania do zdalnego cyborga.", title = "Wyślij wiadomość")
			if(!message)
				return
			if(CHAT_FILTER_CHECK(message))
				to_chat(usr, "<span class='warning'>BŁĄD: w wiadomości wykryto zakazane słowa.</span>")
				return
			to_chat(usr, "<br><br><span class='notice'>Wiadomość do [R] (jako [sender_name]) – \"[message]\"</span><br>")
			computer.send_sound()
			to_chat(R, "<br><br><span class='notice'>Wiadomość od [sender_name] – \"[message]\"</span><br>")
			SEND_SOUND(R, 'sound/machines/twobeep_high.ogg')
			if(R.connected_ai)
				to_chat(R.connected_ai, "<br><br><span class='notice'>Wiadomość od [sender_name] do [R] – \"[message]\"</span><br>")
				SEND_SOUND(R.connected_ai, 'sound/machines/twobeep_high.ogg')
			R.logevent("Wiadomość od [sender_name] – \"[message]\"")
			usr.log_talk(message, LOG_PDA, tag="Cyborg Monitor Program: ID name \"[sender_name]\" to [R]")
			return TRUE

///This proc is used to determin if a borg should be shown in the list (based on the borg's scrambledcodes var). Syndicate version overrides this to show only syndicate borgs.
/datum/computer_file/program/borg_monitor/proc/evaluate_borg(mob/living/silicon/robot/R, linked_overmap) //nsv13 - call adjusted for shipwide monitoring
	var/turf/computer_turf = get_turf(computer)
	var/turf/robot_turf = get_turf(R)
	if(!(linked_overmap && R.last_overmap == linked_overmap) && computer_turf.get_virtual_z_level() != robot_turf.get_virtual_z_level()) //nsv13 - shipwide monitoring.
		return FALSE
	if(R.scrambledcodes)
		return FALSE
	return TRUE

///Gets the ID's name, if one is inserted into the device. This is a seperate proc solely to be overridden by the syndicate version of the app.
/datum/computer_file/program/borg_monitor/proc/get_id_name()
	var/obj/item/card/id/ID = computer.GetID()
	if(!istype(ID))
		return emagged ? "STDERR:UNDF" : FALSE
	return ID.registered_name

/datum/computer_file/program/borg_monitor/syndicate
	filename = "scyborgmonitor"
	filedesc = "Zdalny monitoring cyborgów misji"
	extended_desc = "Ten program pozwala zdalnie monitorować cyborgi przydzielone do misji."
	requires_ntnet = FALSE
	available_on_ntnet = FALSE
	available_on_syndinet = TRUE
	transfer_access = null
	tgui_id = "NtosCyborgRemoteMonitorSyndicate"

/datum/computer_file/program/borg_monitor/syndicate/run_emag()
	return FALSE

/datum/computer_file/program/borg_monitor/syndicate/evaluate_borg(mob/living/silicon/robot/R, linked_overmap) //nsv13 - call adjusted for shipwide monitoring
	if(!(linked_overmap && R.last_overmap == linked_overmap) && (get_turf(computer)).get_virtual_z_level() != (get_turf(R)).get_virtual_z_level()) //nsv13 - shipwide monitoring.
		return FALSE
	if(!R.scrambledcodes)
		return FALSE
	return TRUE

/datum/computer_file/program/borg_monitor/syndicate/get_id_name()
	return "\[REDACTED\]" //no ID is needed for the syndicate version's message function, and the borg will see "[REDACTED]" as the message sender.
