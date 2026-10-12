// Okna monitorów telekomunikacji w TGUI (zamiast HTML z code/game/machinery/telecomms/computers/logbrowser.dm i telemonitor.dm).
// Logika jak w dawnym Topic(): skan w promieniu 25 kratek, bufor serwerów, kasowanie wpisów wymaga dostępu.

/obj/machinery/computer/telecomms/server/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "TelecommsLogBrowser", name)
		ui.set_autoupdate(TRUE)
		ui.open()

/obj/machinery/computer/telecomms/server/ui_data(mob/user)
	var/list/data = list()
	data["network"] = network
	data["notice"] = temp
	var/list/found_servers = list()
	for(var/obj/machinery/telecomms/server in servers)
		found_servers += list(list("id" = server.id, "name" = server.name, "ref" = REF(server)))
	data["servers"] = found_servers
	data["selected"] = null
	if(SelectedServer)
		var/list/logs = list()
		var/index = 0
		for(var/datum/comm_log_entry/entry in SelectedServer.log_entries)
			index++
			logs += list(telecomms_log_data(entry, index, user))
		data["selected"] = list(
			"id" = SelectedServer.id,
			"traffic" = SelectedServer.totaltraffic,
			"logs" = logs,
		)
	return data

/// Jeden wpis logu do okna, z tłumaczeniem mowy jak w dawnym oknie HTML
/obj/machinery/computer/telecomms/server/proc/telecomms_log_data(datum/comm_log_entry/entry, index, mob/user)
	var/list/log = list("index" = index, "name" = entry.name, "type" = entry.input_type)
	switch(entry.input_type)
		if("Speech File")
			var/mobtype = entry.parameters["mobtype"]
			var/race
			if(ispath(mobtype, /mob/living/carbon/human) || ispath(mobtype, /mob/living/brain))
				race = "Humanoid"
			else if(ispath(mobtype, /mob/living/simple_animal/slime))
				race = "Szlam"
			else if(ispath(mobtype, /mob/living/carbon/monkey))
				race = "Małpa"
			else if(ispath(mobtype, /mob/living/silicon) || entry.parameters["job"] == JOB_NAME_AI)
				race = "Sztuczne życie"
			else if(isobj(mobtype))
				race = "Maszyna"
			else if(ispath(mobtype, /mob/living/simple_animal))
				race = "Zwierzę domowe"
			else
				race = "Nieznana"
			var/message = entry.parameters["message"]
			var/language = entry.parameters["language"]
			if(!universal_translate && !user.has_language(language))
				var/datum/language/language_datum = GLOB.language_datum_instances[language]
				message = language_datum ? language_datum.scramble(message) : null
			log["source"] = entry.parameters["name"]
			log["job"] = entry.parameters["job"]
			log["race"] = race
			log["message"] = message
		if("Execution Error")
			log["message"] = entry.parameters["message"]
	return log

/obj/machinery/computer/telecomms/server/ui_act(action, list/params)
	. = ..()
	if(.)
		return
	add_fingerprint(usr)
	temp = ""
	switch(action)
		if("view")
			for(var/obj/machinery/telecomms/server in servers)
				if(REF(server) == params["ref"])
					SelectedServer = server
					break
			return TRUE
		if("main_menu")
			SelectedServer = null
			return TRUE
		if("release")
			servers = list()
			SelectedServer = null
			return TRUE
		if("scan")
			if(length(servers))
				temp = "Nie można skanować przy pełnym buforze."
				return TRUE
			for(var/obj/machinery/telecomms/server/server in urange(25, src))
				if(server.network == network)
					servers += server
			temp = length(servers) ? "Znaleziono serwery: [length(servers)]." : "Brak serwerów w sieci [network]."
			return TRUE
		if("delete")
			if(!allowed(usr) && !(obj_flags & EMAGGED))
				to_chat(usr, "<span class='danger'>ACCESS DENIED.</span>")
				return
			if(!SelectedServer)
				return
			var/index = text2num(params["index"])
			if(!index || index > length(SelectedServer.log_entries))
				return
			var/datum/comm_log_entry/entry = SelectedServer.log_entries[index]
			temp = "Usunięto wpis: [entry.name]."
			SelectedServer.log_entries -= entry
			qdel(entry)
			return TRUE
		if("network")
			var/new_network = stripped_input(usr, "Którą sieć chcesz przeglądać?", "Monitor serwerów", network)
			if(!new_network || !(get_dist(usr, src) <= 1 || issilicon(usr)))
				return
			if(length(new_network) > 15)
				temp = "Nazwa sieci jest za długa."
				return TRUE
			network = new_network
			servers = list()
			SelectedServer = null
			temp = "Ustawiono sieć [network]."
			return TRUE

// Monitor sieci (code/game/machinery/telecomms/computers/telemonitor.dm): lista maszyn w sieci i ich połączenia

/obj/machinery/computer/telecomms/monitor/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "TelecommsMonitor", name)
		ui.set_autoupdate(TRUE)
		ui.open()

/obj/machinery/computer/telecomms/monitor/ui_data(mob/user)
	var/list/data = list()
	data["network"] = network
	data["notice"] = temp
	var/list/machines = list()
	for(var/obj/machinery/telecomms/machine in machinelist)
		machines += list(list("id" = machine.id, "name" = machine.name, "ref" = REF(machine)))
	data["machines"] = machines
	data["selected"] = null
	if(SelectedMachine)
		var/list/links = list()
		for(var/obj/machinery/telecomms/machine in SelectedMachine.links)
			if(!machine.hide)
				links += list(list("id" = machine.id, "name" = machine.name, "ref" = REF(machine)))
		data["selected"] = list(
			"id" = SelectedMachine.id,
			"name" = SelectedMachine.name,
			"on" = SelectedMachine.on,
			"links" = links,
		)
	return data

/obj/machinery/computer/telecomms/monitor/ui_act(action, list/params)
	. = ..()
	if(.)
		return
	add_fingerprint(usr)
	temp = ""
	switch(action)
		if("view")
			var/list/candidates = machinelist.Copy()
			if(SelectedMachine)
				candidates |= SelectedMachine.links
			for(var/obj/machinery/telecomms/machine in candidates)
				if(REF(machine) == params["ref"])
					SelectedMachine = machine
					break
			return TRUE
		if("main_menu")
			SelectedMachine = null
			return TRUE
		if("release")
			machinelist = list()
			SelectedMachine = null
			return TRUE
		if("probe")
			if(length(machinelist))
				temp = "Nie można skanować przy pełnym buforze."
				return TRUE
			for(var/obj/machinery/telecomms/machine in urange(25, src))
				if(machine.network == network)
					machinelist += machine
			temp = length(machinelist) ? "Znaleziono maszyny: [length(machinelist)]." : "Brak maszyn w sieci [network]."
			return TRUE
		if("network")
			var/new_network = stripped_input(usr, "Którą sieć chcesz przeglądać?", "Monitor telekomunikacji", network)
			if(!new_network || !(get_dist(usr, src) <= 1 || issilicon(usr)))
				return
			if(length(new_network) > 15)
				temp = "Nazwa sieci jest za długa."
				return TRUE
			network = new_network
			machinelist = list()
			SelectedMachine = null
			temp = "Ustawiono sieć [network]."
			return TRUE
