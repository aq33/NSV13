/datum/computer_file/program/ntnet_dos
	filename = "ntn_dos"
	filedesc = "Generator ruchu DoS"
	category = PROGRAM_CATEGORY_MISC
	program_icon_state = "hostile"
	extended_desc = "Ten zaawansowany skrypt potrafi przeprowadzać ataki odmowy usługi na przekaźniki kwantowe NTNet. Administrator systemu pewnie to zauważy. Kilka urządzeń może uruchomić ten program razem przeciwko temu samemu przekaźnikowi, by zwiększyć efekt"
	size = 20
	requires_ntnet = TRUE
	available_on_ntnet = FALSE
	available_on_syndinet = TRUE
	tgui_id = "NtosNetDos"
	program_icon = "satellite-dish"



	var/obj/machinery/ntnet_relay/target = null
	var/dos_speed = 0
	var/error = ""
	var/executed = 0

/datum/computer_file/program/ntnet_dos/process_tick()
	dos_speed = 0
	switch(ntnet_status)
		if(1)
			dos_speed = NTNETSPEED_LOWSIGNAL * 10
		if(2)
			dos_speed = NTNETSPEED_HIGHSIGNAL * 10
		if(3)
			dos_speed = NTNETSPEED_ETHERNET * 10
	if(target && executed)
		target.dos_overload += dos_speed
		if(!target.is_operational)
			target.dos_sources.Remove(src)
			target = null
			error = "Utracono połączenie z docelowym przekaźnikiem."

/datum/computer_file/program/ntnet_dos/kill_program(forced = FALSE)
	if(target)
		target.dos_sources.Remove(src)
	target = null
	executed = FALSE

	..()

/datum/computer_file/program/ntnet_dos/ui_act(action, params)
	if(..())
		return
	switch(action)
		if("PRG_target_relay")
			for(var/obj/machinery/ntnet_relay/R in SSnetworks.relays)
				if(R.uid == params["targid"])
					target = R
					break
			return TRUE
		if("PRG_reset")
			if(target)
				target.dos_sources.Remove(src)
				target = null
			executed = FALSE
			error = ""
			return TRUE
		if("PRG_execute")
			if(target)
				executed = TRUE
				target.dos_sources.Add(src)
				if(SSnetworks.station_network.intrusion_detection_enabled)
					var/obj/item/computer_hardware/network_card/network_card = computer.all_components[MC_NET]
					SSnetworks.add_log("OSTRZEŻENIE IDS – wykryto nadmierny zalew ruchu na przekaźnik [target.uid] z urządzenia: [network_card.get_network_tag()]")
					SSnetworks.station_network.intrusion_detection_alarm = TRUE
			return TRUE

/datum/computer_file/program/ntnet_dos/ui_data(mob/user)
	if(!SSnetworks.station_network)
		return

	var/list/data = list()

	data["error"] = error
	if(target && executed)
		data["target"] = TRUE
		data["speed"] = dos_speed

		data["overload"] = target.dos_overload
		data["capacity"] = target.dos_capacity
	else
		data["target"] = FALSE
		data["relays"] = list()
		for(var/obj/machinery/ntnet_relay/R in SSnetworks.relays)
			data["relays"] += list(list("id" = R.uid))
		data["focus"] = target ? target.uid : null

	return data
