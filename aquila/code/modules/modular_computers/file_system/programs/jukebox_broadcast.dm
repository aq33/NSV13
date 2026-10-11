// AQUILA EDIT - program nagłośnienia: kapitan puszcza muzykę z wybranego jukeboxa przez głośniki nagłośnienia na korytarzach.

/datum/computer_file/program/jukebox_broadcast
	filename = "pa_system"
	filedesc = "Nagłośnienie statku"
	category = PROGRAM_CATEGORY_CREW
	program_icon_state = "generic"
	program_icon = "volume-up"
	extended_desc = "Puszcza muzykę z wybranego jukeboxa przez głośniki nagłośnienia na korytarzach statku. Wymaga dostępu kapitana."
	requires_ntnet = TRUE
	size = 4
	required_access = list(ACCESS_CAPTAIN)
	transfer_access = list(ACCESS_CAPTAIN)
	tgui_id = "NtosJukeboxBroadcast"

/// Jukeboxy na tym samym statku co komputer (tylko te, które mogą nadawać - bez radia i głośnika Syndykatu)
/datum/computer_file/program/jukebox_broadcast/proc/ship_jukeboxes()
	. = list()
	var/obj/structure/overmap/ship = computer?.get_overmap()
	if(!ship)
		return
	for(var/obj/machinery/jukebox/J in GLOB.machines)
		if(J.can_broadcast && J.get_overmap() == ship)
			. += J

/datum/computer_file/program/jukebox_broadcast/ui_data(mob/user)
	var/list/data = list()
	var/list/jukeboxes = list()
	for(var/obj/machinery/jukebox/J as anything in ship_jukeboxes())
		var/title = (J.yt_active && J.yt_index) ? J.yt_tracks[J.yt_index]["title"] : null
		jukeboxes += list(list(
			"ref" = REF(J),
			"name" = "[J]",
			"area" = get_area_name(J, TRUE),
			"playing" = J.yt_active,
			"title" = title,
			"shipwide" = J.shipwide,
		))
	data["jukeboxes"] = jukeboxes
	data["on_ship"] = !!computer?.get_overmap()
	return data

/datum/computer_file/program/jukebox_broadcast/ui_act(action, list/params)
	. = ..()
	if(.)
		return
	switch(action)
		if("toggle")
			var/obj/machinery/jukebox/J = locate(params["ref"]) in ship_jukeboxes()
			if(!J)
				return
			SSjukeboxes.set_shipwide(J, !J.shipwide)
			log_game("[key_name(usr)] [J.shipwide ? "enabled" : "disabled"] shipwide broadcast of [J] at [AREACOORD(J)]")
			message_admins("[ADMIN_LOOKUPFLW(usr)] [J.shipwide ? "włączył(a)" : "wyłączył(a)"] nadawanie [J] na cały statek [ADMIN_JMP(J)]")
			return TRUE

/// Program nagłośnienia od razu na konsolach dowodzenia
/obj/machinery/modular_computer/console/preset/command/install_programs()
	. = ..()
	var/obj/item/computer_hardware/hard_drive/hard_drive = cpu.all_components[MC_HDD]
	hard_drive.store_file(new /datum/computer_file/program/jukebox_broadcast())
