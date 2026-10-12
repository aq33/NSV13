// Okno konsoli promu w TGUI (zamiast listy HTML z nsv13/code/modules/shuttle/computer.dm).
// Przyciski idą przez dawny Topic(), więc podtypy dalej działają: prom Syndykatu (deklaracja wojny),
// prośba o prom z CentComu, własne lądowisko.

/obj/machinery/computer/shuttle_flight/ui_interact(mob/user, datum/tgui/ui)
	//Ash walkers cannot use the console because they are unga bungas
	if(user.mind?.has_antag_datum(/datum/antagonist/ashwalker))
		to_chat(user, "<span class='warning'>This computer has been designed to keep the natives like you from meddling with it, you have no hope of using it.</span>")
		return
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "ShuttleConsole", name)
		ui.open()

/obj/machinery/computer/shuttle_flight/ui_static_data(mob/user)
	return list()

/obj/machinery/computer/shuttle_flight/ui_data(mob/user)
	var/list/data = list()
	var/obj/docking_port/mobile/shuttle = SSshuttle.getShuttle(shuttleId)
	data["shuttle_name"] = shuttle?.name
	data["status"] = shuttle?.getStatusText()
	data["mode"] = shuttle?.mode
	data["custom_landing"] = allow_custom_landing
	data["admin_controlled"] = admin_controlled
	data["can_request"] = istype(src, /obj/machinery/computer/shuttle_flight/ferry/request)
	var/list/destinations = list()
	if(shuttle)
		var/list/options = params2list(possible_destinations)
		for(var/obj/docking_port/stationary/port in SSshuttle.stationary)
			if(!options.Find(port.id) || !shuttle.check_dock(port, silent = TRUE))
				continue
			destinations += list(list("id" = port.id, "name" = port.name))
	data["destinations"] = destinations
	return data

/obj/machinery/computer/shuttle_flight/ui_act(action, list/params)
	switch(action)
		if("move")
			Topic(null, list("move" = params["id"]))
			return TRUE
		if("designate")
			Topic(null, list("designate" = 1))
			return TRUE
		if("request")
			Topic(null, list("request" = 1))
			return TRUE
	return ..()
