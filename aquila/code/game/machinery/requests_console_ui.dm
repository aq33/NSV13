// Okno konsoli zgłoszeń w TGUI (zamiast HTML z code/game/machinery/requests_console.dm).
// Ekrany i akcje jak dawniej (zmienna screen, Topic()), więc wiadomości, ogłoszenia, alarmy i drużyny NSV działają bez zmian.
// Numery ekranów z requests_console.dm (tam są #undef na końcu pliku):
// 0 główny, 1 pomoc, 2 zaopatrzenie, 3 informacje, 6 wysłano, 7 błąd, 8 wiadomości, 9 potwierdzenie, 10 ogłoszenie, 11 drużyny

/obj/machinery/requests_console/ui_interact(mob/user, datum/tgui/ui)
	if(open)
		return
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "RequestsConsole", name)
		ui.set_autoupdate(TRUE)
		ui.open()

/obj/machinery/requests_console/ui_data(mob/user)
	var/list/data = list()
	data["screen"] = screen
	data["department"] = department
	data["new_priority"] = newmessagepriority
	data["emergency"] = emergency
	data["announcement_console"] = announcementConsole
	data["silent"] = silent
	data["hacked"] = hackState
	data["has_squads"] = (lowertext(department) in departments_with_squads)
	data["message"] = message
	data["to_department"] = to_department
	data["verified"] = strip_html_simple(msgVerified)
	data["stamped"] = strip_html_simple(msgStamped)
	data["announce_auth"] = announceAuth || IsAdminGhost(user)
	var/list/department_list
	switch(screen)
		if(1)
			department_list = GLOB.req_console_assistance
		if(2)
			department_list = GLOB.req_console_supplies
		if(3)
			department_list = GLOB.req_console_information
	var/list/departments = list()
	for(var/target_department in department_list)
		if(target_department != department)
			departments += list(list("name" = target_department, "key" = ckey(target_department)))
	data["departments"] = departments
	var/list/message_list = list()
	if(screen == 8)
		// Najnowsze na górze, jak w dawnym oknie
		for(var/i in length(messages) to 1 step -1)
			message_list += messages[i]
	data["messages"] = message_list
	return data

/obj/machinery/requests_console/ui_act(action, list/params)
	. = ..()
	if(.)
		return
	switch(action)
		if("set_screen")
			var/new_screen = text2num(params["screen"])
			if(new_screen == 0)
				announceAuth = FALSE
			Topic(null, list("setScreen" = new_screen))
			if(screen == 8)
				mark_messages_read()
		if("write")
			Topic(null, list("write" = params["department"], "priority" = params["priority"]))
		if("send")
			Topic(null, list("send" = TRUE))
		if("write_announcement")
			Topic(null, list("writeAnnouncement" = TRUE))
		if("send_announcement")
			Topic(null, list("sendAnnouncement" = TRUE))
		if("emergency")
			Topic(null, list("emergency" = params["type"]))
		if("silent")
			Topic(null, list("setSilent" = silent ? 0 : 1))
		if("write_squad")
			Topic(null, list("writeSquad" = TRUE))
		if("send_squad")
			Topic(null, list("sendSquadMessage" = TRUE))
		else
			return
	return TRUE

/// Odczytanie wiadomości gasi lampkę na wszystkich konsolach działu (wcześniej robiło to rysowanie okna HTML)
/obj/machinery/requests_console/proc/mark_messages_read()
	for(var/obj/machinery/requests_console/console in GLOB.allConsoles)
		if(console.department == department)
			console.newmessagepriority = REQ_NO_NEW_MESSAGE
			console.update_icon()
