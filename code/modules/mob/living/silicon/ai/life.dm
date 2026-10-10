#define POWER_RESTORATION_OFF 0
#define POWER_RESTORATION_START 1
#define POWER_RESTORATION_SEARCH_APC 2
#define POWER_RESTORATION_APC_FOUND 3

/mob/living/silicon/ai/Life()
	if (stat == DEAD)
		return
	else //I'm not removing that shitton of tabs, unneeded as they are. -- Urist
		//Being dead doesn't mean your temperature never changes

		update_gravity(has_gravity())

		handle_status_effects()

		if(malfhack && malfhack.aidisabled)
			deltimer(malfhacking)
			// This proc handles cleanup of screen notifications and
			// messenging the client
			malfhacked(malfhack)

		if(isturf(loc) && (QDELETED(eyeobj) || !eyeobj.loc))
			view_core()

		if(machine)
			machine.check_eye(src)

		// Handle power damage (oxy)
		if(aiRestorePowerRoutine)
			// Lost power
			if (!battery)
				to_chat(src, "<span class='warning'>Moc wyjściowa baterii zapasowej spada poniżej użytecznego poziomu. Po chwili twoje systemy zawodzą, uszkodzone i bezużyteczne.</span>")
				adjustOxyLoss(200)
			else
				battery --
		else
			// Gain Power
			if (battery < 200)
				battery ++

		if(!lacks_power())
			var/area/home = get_area(src)
			if(home.powered(AREA_USAGE_EQUIP))
				home.use_power(1000, AREA_USAGE_EQUIP)

			if(aiRestorePowerRoutine >= POWER_RESTORATION_SEARCH_APC)
				ai_restore_power()
				return

		else if(!aiRestorePowerRoutine)
			ai_lose_power()

/mob/living/silicon/ai/proc/lacks_power()
	var/turf/T = get_turf(src)
	var/area/A = get_area(src)
	switch(requires_power)
		if(NONE)
			return FALSE
		if(POWER_REQ_ALL)
			return !T || !A || ((!A.power_equip || isspaceturf(T)) && !is_type_in_list(loc, list(/obj/item, /obj/mecha)))

/mob/living/silicon/ai/updatehealth()
	if(status_flags & GODMODE)
		return
	health = maxHealth - getOxyLoss() - getToxLoss() - getBruteLoss() - getFireLoss()
	update_stat()
	diag_hud_set_health()
	disconnect_shell()

/mob/living/silicon/ai/update_stat()
	if(status_flags & GODMODE)
		return
	if(stat != DEAD)
		if(health <= HEALTH_THRESHOLD_DEAD)
			death()
			return
		else if(stat == UNCONSCIOUS)
			set_stat(CONSCIOUS)
			adjust_blindness(-1)
	diag_hud_set_status()

/mob/living/silicon/ai/update_sight()
	see_invisible = initial(see_invisible)
	see_in_dark = initial(see_in_dark)
	sight = initial(sight)
	if(aiRestorePowerRoutine)
		sight = sight&~SEE_TURFS
		sight = sight&~SEE_MOBS
		sight = sight&~SEE_OBJS
		see_in_dark = 0

	if(see_override)
		see_invisible = see_override
	sync_lighting_plane_alpha()


/mob/living/silicon/ai/proc/start_RestorePowerRoutine()
	to_chat(src, "Bateria zapasowa aktywna. Skanery, kamera i interfejs radiowy wyłączone. Rozpoczynanie wykrywania usterek.")
	end_multicam()
	sleep(50)
	var/turf/T = get_turf(src)
	var/area/AIarea = get_area(src)
	if(AIarea?.power_equip)
		if(!isspaceturf(T))
			ai_restore_power()
			return
	to_chat(src, "Usterka potwierdzona: brak zewnętrznego zasilania. Wyłączanie głównego systemu sterowania w celu oszczędzania energii.")
	sleep(20)
	to_chat(src, "Awaryjny system sterowania aktywny. Weryfikacja połączenia z siecią energetyczną.")
	sleep(50)
	T = get_turf(src)
	if(isspaceturf(T))
		to_chat(src, "Weryfikacja niemożliwa! Nie wykryto połączenia z zasilaniem!")
		aiRestorePowerRoutine = POWER_RESTORATION_SEARCH_APC
		return
	to_chat(src, "Połączenie zweryfikowane. Wyszukiwanie APC w sieci energetycznej.")
	sleep(50)
	var/obj/machinery/power/apc/theAPC = null

	var/PRP //like ERP with the code, at least this stuff is no more 4x sametext
	for (PRP=1, PRP<=4, PRP++)
		T = get_turf(src)
		AIarea = get_area(src)
		if(AIarea)
			for (var/obj/machinery/power/apc/APC in AIarea)
				if (!(APC.machine_stat & BROKEN))
					theAPC = APC
					break
		if (!theAPC)
			switch(PRP)
				if(1)
					to_chat(src, "Nie można zlokalizować APC!")
				else
					to_chat(src, "Utracono połączenie z APC!")
			aiRestorePowerRoutine = POWER_RESTORATION_SEARCH_APC
			return
		if(AIarea.power_equip)
			if(!isspaceturf(T))
				ai_restore_power()
				return
		switch(PRP)
			if (1)
				to_chat(src, "Zlokalizowano APC. Optymalizacja trasy do APC w celu uniknięcia strat energii.")
			if (2)
				to_chat(src, "Wyznaczono najlepszą trasę. Hakowanie wyłączonego portu zasilania APC.")
			if (3)
				to_chat(src, "Potwierdzono dostęp do portu zasilania. Wgrywanie programu sterującego do oprogramowania portu zasilania APC.")
			if (4)
				to_chat(src, "Transfer zakończony. Wymuszanie wykonania programu przez APC.")
				sleep(50)
				to_chat(src, "Odbieranie informacji sterujących z APC.")
				sleep(2)
				apc_override = theAPC
				theAPC.ui_interact(src)
				aiRestorePowerRoutine = POWER_RESTORATION_APC_FOUND
		sleep(50)
		theAPC = null

/mob/living/silicon/ai/proc/ai_restore_power()
	if(aiRestorePowerRoutine)
		if(aiRestorePowerRoutine == POWER_RESTORATION_APC_FOUND)
			to_chat(src, "Alarm odwołany. Zasilanie zostało przywrócone.")
		else
			to_chat(src, "Alarm odwołany. Zasilanie zostało przywrócone bez naszej pomocy.")
		aiRestorePowerRoutine = POWER_RESTORATION_OFF
		set_blindness(0)
		update_sight()

/mob/living/silicon/ai/proc/ai_lose_power()
	disconnect_shell()
	aiRestorePowerRoutine = POWER_RESTORATION_START
	blind_eyes(1)
	update_sight()
	to_chat(src, "Straciłeś zasilanie!")
	addtimer(CALLBACK(src, PROC_REF(start_RestorePowerRoutine)), 20)

#undef POWER_RESTORATION_OFF
#undef POWER_RESTORATION_START
#undef POWER_RESTORATION_SEARCH_APC
#undef POWER_RESTORATION_APC_FOUND
