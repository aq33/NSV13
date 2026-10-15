/obj/machinery/computer/shuttle_flight/ui_interact(mob/user)
	//Ash walkers cannot use the console because they are unga bungas
	if(user.mind?.has_antag_datum(/datum/antagonist/ashwalker))
		to_chat(user, "<span class='warning'>Ten komputer zaprojektowano tak, by tubylcy tacy jak ty nie mogli przy nim majstrować, nie masz szans go użyć.</span>")
		return
	var/list/options = params2list(possible_destinations)
	var/obj/docking_port/mobile/M = SSshuttle.getShuttle(shuttleId)
	var/dat = "Status: [M ? M.getStatusText() : "*Missing*"]<br><br>"
	if(M)
		var/destination_found
		for(var/obj/docking_port/stationary/S in SSshuttle.stationary)
			if(!options.Find(S.id))
				continue
			if(!M.check_dock(S, silent=TRUE))
				continue
			destination_found = 1
			dat += "<A href='byond://?src=[REF(src)];move=[S.id]'>Wyślij do [S.name]</A><br>"
		if(allow_custom_landing) // AQ EDIT START - custom landing spot, see aquila/code/modules/shuttle/computer.dm
			destination_found = 1
			dat += "<A href='byond://?src=[REF(src)];designate=1'>Wyznacz miejsce lądowania</A><br>" // AQ EDIT END
		if(!destination_found)
			dat += "<B>Prom zablokowany</B><br>"
			if(admin_controlled)
				dat += "Tylko dla upoważnionego personelu<br>"
				dat += "<A href='byond://?src=[REF(src)];request=1]'>Poproś o autoryzację</A><br>"
	dat += "<a href='byond://?src=[REF(user)];mach_close=computer'>Close</a>"

	var/datum/browser/popup = new(user, "computer", M ? M.name : "shuttle", 300, 200)
	popup.set_content("<center>[dat]</center>")
	popup.open()

/obj/machinery/computer/shuttle_flight/Topic(href, href_list)
	if(..())
		return
	usr.set_machine(src)
	src.add_fingerprint(usr)
	if(!allowed(usr))
		to_chat(usr, "<span class='danger'>Odmowa dostępu.</span>")
		return

	if(href_list["designate"] && allow_custom_landing) // AQ EDIT START - custom landing spot
		designate_landing(usr)
		return // AQ EDIT END

	if(href_list["move"])
		var/obj/docking_port/mobile/M = SSshuttle.getShuttle(shuttleId)
		if(M.launch_status == ENDGAME_LAUNCHED)
			to_chat(usr, "<span class='warning'>Już uciekłeś. Nigdy więcej nie wracasz do tamtego miejsca!</span>")
			return
		if(M.mode == SHUTTLE_RECHARGING)
			to_chat(usr, "<span class='warning'>Silniki promu nie są gotowe do użycia.</span>")
			return
		if(M.mode != SHUTTLE_IDLE)
			to_chat(usr, "<span class='warning'>Prom jest już w tranzycie.</span>")
			return
		if(!(href_list["move"] in params2list(possible_destinations)))
			log_admin("[usr] attempted to forge a target location through a href exploit on [src]")
			message_admins("[ADMIN_FULLMONTY(usr)] attempted to forge a target location through a href exploit on [src]")
			return
		switch(SSshuttle.moveShuttle(shuttleId, href_list["move"], 1))
			if(0)
				say("Prom odlatuje. Prosimy odsunąć się od drzwi.")
			if(1)
				to_chat(usr, "<span class='warning'>Zażądano nieprawidłowego promu.</span>")
			else
				to_chat(usr, "<span class='notice'>Nie można wykonać.</span>")

/obj/machinery/computer/shuttle_flight/connect_to_shuttle(obj/docking_port/mobile/port, obj/docking_port/stationary/dock, idnum, override=FALSE)
	if(port && (shuttleId == initial(shuttleId) || override))
		shuttleId = port.id
