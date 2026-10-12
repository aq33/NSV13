// Okno konsoli zarządzania więźniami w TGUI (zamiast HTML z code/game/machinery/computer/prisoner/management.dm).
// Przyciski idą przez dawny Topic(), więc sprawdzanie dostępu, limity i logi zostają bez zmian.

/obj/machinery/computer/prisoner/management/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		if(isliving(user))
			playsound(src, 'sound/machines/terminal_prompt_confirm.ogg', 50, FALSE)
		ui = new(user, src, "PrisonerManagement", name)
		ui.set_autoupdate(TRUE)
		ui.open()

/obj/machinery/computer/prisoner/management/ui_data(mob/user)
	var/list/data = list()
	data["logged_in"] = !!screen
	if(!screen)
		return data
	data["prisoner_id"] = null
	if(contained_id)
		data["prisoner_id"] = list(
			"name" = contained_id.name,
			"points" = contained_id.points,
			"goal" = contained_id.goal,
			"permanent" = contained_id.permanent,
		)
	var/our_z = get_virtual_z_level()
	var/list/chem_implants = list()
	for(var/obj/item/implant/chem/implant in GLOB.tracked_chem_implants)
		var/turf/implant_turf = get_turf(implant)
		if(implant_turf && implant_turf.get_virtual_z_level() != our_z)
			continue
		if(!implant.imp_in)
			continue
		chem_implants += list(list(
			"name" = implant.imp_in.name,
			"volume" = implant.reagents.total_volume,
			"ref" = REF(implant),
		))
	data["chem_implants"] = chem_implants
	var/list/tracking_implants = list()
	for(var/obj/item/implant/tracking/implant in GLOB.tracked_implants)
		if(!isliving(implant.imp_in))
			continue
		var/turf/implant_turf = get_turf(implant)
		if(implant_turf && implant_turf.get_virtual_z_level() != our_z)
			continue
		var/location = "Nieznane"
		var/mob/living/carrier = implant.imp_in
		if(implant_turf && is_station_level(implant_turf.z) && !isspaceturf(carrier.loc))
			var/turf/carrier_turf = get_turf(carrier)
			location = "[carrier_turf.loc]"
		tracking_implants += list(list(
			"name" = carrier.name,
			"location" = location,
			"ref" = REF(implant),
		))
	data["tracking_implants"] = tracking_implants
	return data

/obj/machinery/computer/prisoner/management/ui_act(action, list/params)
	. = ..()
	if(.)
		return
	switch(action)
		if("lock")
			Topic(null, list("lock" = 1))
		if("id")
			var/id_action = params["action"]
			if(!(id_action in list("insert", "eject", "reset", "setgoal", "setpermanent")))
				return
			Topic(null, list("id" = id_action))
		if("inject")
			var/amount = text2num(params["amount"])
			if(!(amount in list(1, 5, 10)))
				return
			Topic(null, list("inject[amount]" = params["ref"]))
		if("warn")
			Topic(null, list("warn" = params["ref"]))
		else
			return
	return TRUE
