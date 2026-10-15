#define CONSTRUCTION_COMPLETE 0 //No construction done - functioning as normal
#define CONSTRUCTION_PANEL_OPEN 1 //Maintenance panel is open, still functioning
#define CONSTRUCTION_WIRES_EXPOSED 2 //Cover plate is removed, wires are available
#define CONSTRUCTION_GUTTED 3 //Wires are removed, circuit ready to remove
#define CONSTRUCTION_NOCIRCUIT 4 //Circuit board removed, can safely weld apart

#define RECLOSE_DELAY 5 SECONDS // How long until a firelock tries to shut itself if it's blocking a vacuum.
#define FIRE_ALARM 2
/obj/machinery/door/firedoor
	name = "firelock"
	desc = "A convenable firelock. It has a card reader and a set of indicator lights on the side."
	icon = 'icons/obj/doors/doorfireglass.dmi'
	icon_state = "door_open"
	opacity = FALSE
	density = FALSE
	max_integrity = 300
	resistance_flags = FIRE_PROOF
	heat_proof = TRUE
	glass = TRUE
	sub_door = TRUE
	explosion_block = 1
	safe = FALSE
	layer = BELOW_OPEN_DOOR_LAYER
	closingLayer = CLOSED_FIREDOOR_LAYER
	assemblytype = /obj/structure/firelock_frame
	armor = list("melee" = 30, "bullet" = 30, "laser" = 20, "energy" = 20, "bomb" = 10, "bio" = 100, "rad" = 100, "fire" = 95, "acid" = 70, "stamina" = 0, "bleed" = 0)
	interaction_flags_machine = INTERACT_MACHINE_WIRES_IF_OPEN | INTERACT_MACHINE_ALLOW_SILICON | INTERACT_MACHINE_OPEN_SILICON | INTERACT_MACHINE_REQUIRES_SILICON | INTERACT_MACHINE_OPEN
	air_tight = TRUE
	open_speed = 2
	req_one_access = list(ACCESS_ENGINE, ACCESS_ATMOSPHERICS)
	processing_flags = START_PROCESSING_MANUALLY
	var/emergency_close_timer = 0
	var/nextstate = null
	var/boltslocked = TRUE
	var/list/affecting_areas
	var/list/access_log
	var/process_ticker //Ratelimit process to one check ~5 process ticks

/obj/machinery/door/firedoor/Initialize(mapload)
	. = ..()
	CalculateAffectingAreas()
	UpdateAdjacencyFlags()

/obj/machinery/door/firedoor/examine(mob/user)
	. = ..()
	if(!density)
		. += "<span class='notice'>Jest otwarta, ale można ją <b>zamknąć</b> łomem.</span>"
	else if(!welded)
		. += "<span class='notice'>Jest zamknięta, ale można ją <i>otworzyć</i> łomem. Rozbiórka wymaga jej <b>zaspawania</b>.</span>"
	else if(boltslocked)
		. += "<span class='notice'>Jest <i>zaspawana</i>. Rygle podłogowe są zablokowane <b>wkrętami</b>.</span>"
	else
		. += "<span class='notice'>Blokady rygli zostały <i>odkręcone</i>, ale same rygle wciąż są <b>przykręcone</b> do podłogi.</span>"

/obj/machinery/door/firedoor/proc/CalculateAffectingAreas()
	remove_from_areas()
	affecting_areas = get_adjacent_open_areas(src) | get_area(src)
	for(var/I in affecting_areas)
		var/area/A = I
		LAZYADD(A.firedoors, src)

/obj/machinery/door/firedoor/proc/UpdateAdjacencyFlags()
	var/turf/T = get_turf(src)
	if(flags_1 & ON_BORDER_1)
		for(var/t in T.atmos_adjacent_turfs)
			if(get_dir(loc, t) == dir)
				var/turf/open/T2 = t
				if(T2 in T.atmos_adjacent_turfs)
					T.atmos_adjacent_turfs[T2] |= ATMOS_ADJACENT_FIRELOCK
				if(T in T2.atmos_adjacent_turfs)
					T2.atmos_adjacent_turfs[T] |= ATMOS_ADJACENT_FIRELOCK
	else
		for(var/t in T.atmos_adjacent_turfs)
			var/turf/open/T2 = t
			if(T2 in T.atmos_adjacent_turfs)
				T.atmos_adjacent_turfs[T2] |= ATMOS_ADJACENT_FIRELOCK
			if(T in T2.atmos_adjacent_turfs)
				T2.atmos_adjacent_turfs[T] |= ATMOS_ADJACENT_FIRELOCK

/obj/machinery/door/firedoor/closed
	icon_state = "door_closed"
	opacity = TRUE
	density = TRUE
	processing_flags = START_PROCESSING_ON_INIT

//see also turf/AfterChange for adjacency shennanigans

/obj/machinery/door/firedoor/proc/remove_from_areas()
	if(affecting_areas)
		for(var/I in affecting_areas)
			var/area/A = I
			LAZYREMOVE(A.firedoors, src)

/obj/machinery/door/firedoor/Destroy()
	remove_from_areas()
	affecting_areas.Cut()
	air_update_turf()
	return ..()

/obj/machinery/door/firedoor/Bumped(atom/movable/AM)
	if(panel_open || operating)
		return
	//NSV13 - allow bump to open if powered
	if(welded || (machine_stat & NOPOWER))
		return
	if(ismob(AM))
		var/mob/user = AM
		if(check_safety(user))
			add_fingerprint(user)
			open()
			return TRUE
	if(ismecha(AM))
		var/obj/mecha/M = AM
		if(M.occupant && check_safety(M.occupant))
			open()
			return TRUE
	//end NSV13
	if(!density)
		return ..()
	return FALSE


/obj/machinery/door/firedoor/power_change()
	if(powered(power_channel))
		set_machine_stat(machine_stat & ~NOPOWER)
		INVOKE_ASYNC(src, PROC_REF(latetoggle))
	else
		set_machine_stat(machine_stat | NOPOWER)

/obj/machinery/door/firedoor/attack_hand(mob/user, list/modifiers)
	. = ..()
	if(.)
		return

	//NSV13 - allow manual operation of unpowered firelocks
	if (!welded && !operating)
		if (machine_stat & NOPOWER)
			user.visible_message("[user] próbuje ręcznie otworzyć [src].",
						 "Używasz ręcznej dźwigni [src].")
			if (!do_after(user, 30, TRUE, src))
				return FALSE
		else if (density && !check_safety(user))
			return FALSE

		add_fingerprint(user)
		if(density)
			emergency_close_timer = world.time + RECLOSE_DELAY // prevent it from instaclosing again if in space
			open()
		else
			close()
		return TRUE
	//end NSV13
	if(operating || !density)
		return

	user.changeNext_move(CLICK_CD_MELEE)

	user.visible_message("[user] wali w [src].",
						 "Walisz w [src].")
	playsound(loc, 'sound/effects/glassknock.ogg', 10, FALSE, frequency = 32000)

/obj/machinery/door/firedoor/attackby(obj/item/C, mob/user, params)
	add_fingerprint(user)
	if(operating)
		return

	if(istype(C, /obj/item/modular_computer/tablet/pda))
		var/attack_verb = pick("przyciska","pociera","uderza","dociska","przykłada")
		visible_message("<span class='warning'>[user] [attack_verb] [C] do czytnika kart [src].</span>", "<span class='warning'>Przykładasz [C] do czytnika kart [src]. Nic się nie dzieje.</span>", "Słyszysz stukot plastiku o metal.")
		return

	if(welded)
		if(C.tool_behaviour == TOOL_WRENCH)
			if(boltslocked)
				to_chat(user, "<span class='notice'>Rygle blokują wkręty!</span>")
				return
			C.play_tool_sound(src)
			user.visible_message("<span class='notice'>[user] zaczyna odkręcać rygle [src]...</span>", \
								 "<span class='notice'>Zaczynasz odkręcać rygle podłogowe [src]...</span>")
			if(!C.use_tool(src, user, 50))
				return
			playsound(get_turf(src), 'sound/items/deconstruct.ogg', 50, 1)
			user.visible_message("<span class='notice'>[user] unfastens [src]'s bolts.</span>", \
								 "<span class='notice'>Odkręcasz rygle podłogowe [src].</span>")
			deconstruct(TRUE)
			return
		if(C.tool_behaviour == TOOL_SCREWDRIVER)
			user.visible_message("<span class='notice'>[user] [boltslocked ? "unlocks" : "locks"] [src]'s bolts.</span>", \
								 "<span class='notice'>[boltslocked ? "Odblokowujesz" : "Blokujesz"] rygle podłogowe [src].</span>")
			C.play_tool_sound(src)
			boltslocked = !boltslocked
			return
	if(C.tool_behaviour == TOOL_MULTITOOL)
		if(!access_log)
			to_chat(user, "<span class='warning'>\t[C] pika: 'Log dostępu pusty.'</span>")
			return
		to_chat(user, "<span class='notice'>\t[C] pika: 'Zrzucanie logu dostępu...'</span>")
		for(var/entry in access_log)
			to_chat(user, "<span class='notice robot'>[entry]</span>")

	return ..()

/obj/machinery/door/firedoor/try_to_activate_door(obj/item/I, mob/user)
	if(!density || welded)
		return

	if(isidcard(I))
		if((check_safety(user) == TRUE) || check_access(I))
			log_opening(I, user, check_safety(user))
			playsound(src, 'sound/machines/beep.ogg', 50, 1)
			open()
			return
		else
			log_opening(I, user, -1)
			to_chat(user, "<span class='danger'>Odmowa dostępu, użytkownik nie ma uprawnień do nadpisywania alarmów ani kontroli ciśnienia.</span>")
			playsound(src, 'sound/machines/terminal_error.ogg', 50, 1)
			return
	to_chat("<span class='warning'>Próbujesz pociągnąć czytnik kart. Nic się nie dzieje.</span>")
	return

/obj/machinery/door/firedoor/proc/log_opening(obj/item/card/id/I, mob/user, safe)
	var/safestate = "UNK_STATE:"
	switch(safe)
		if(-1)//Rejected
			safestate = "USR_NOACC:"
		if(FALSE)//Unsafe, Atmos
			safestate = "OVER_SENS:"
		if(TRUE)//Safe.
			safestate = "SAFE_OPEN:"
		if(FIRE_ALARM)
			safestate = "OVER_ALRM:"
	LAZYADD(access_log, "[safestate]|N:[I.registered_name]|A:[I.assignment]|T_OFFSET:[DisplayTimeText(world.time - SSticker.round_start_time)]")
	if(length(access_log) > 20) //Unless this is getting spammed this shouldn't happen.
		access_log.Remove(access_log[1])
	if(!check_safety(user))
		log_game("[key_name(user)] has opened a firelock with a pressure difference or a fire alarm at [AREACOORD(loc)], using [I]")
		user.log_message("has opened a firelock with a pressure difference or a fire alarm at [AREACOORD(loc)], using [I]", LOG_ATTACK)


/obj/machinery/door/firedoor/try_to_weld_secondary(obj/item/weldingtool/W, mob/user)
	if(!W.tool_start_check(user, amount=0))
		return
	user.visible_message("<span class='notice'>[user] starts [welded ? "unwelding" : "welding"] [src].</span>", "<span class='notice'>Zaczynasz spawać [src].</span>")
	if(W.use_tool(src, user, 40, volume=50))
		welded = !welded
		user.visible_message("<span class='danger'>[user] [welded?"zaspawuje":"rozspawuje"] [src].</span>", "<span class='notice'>[welded ? "Zaspawujesz" : "Rozspawujesz"] [src].</span>")
		log_game("[key_name(user)] [welded ? "welded":"unwelded"] firedoor [src] with [W] at [AREACOORD(src)]")
		update_icon()


/obj/machinery/door/firedoor/try_to_crowbar(obj/item/I, mob/user)
	if(welded || operating)
		return

	if(density)
		if(!(machine_stat & NOPOWER))
			LAZYADD(access_log, "MOTOR_ERR:|MOTOR CONTROLLER REPORTED BACKDRIVE|T_OFFSET:[DisplayTimeText(world.time - SSticker.round_start_time)]")
			if(length(access_log) > 20) //Unless this is getting spammed this shouldn't happen.
				access_log.Remove(access_log[1])
			to_chat(user, "<span class='warning'>Zaczynasz forsować [src], silniki wyją...</span>")
			playsound(src, 'sound/machines/airlock_alien_prying.ogg', 100, TRUE)
			if(!do_after(user, 10 SECONDS, TRUE, src))
				return
		else
			to_chat(user, "<span class='notice'>Zaczynasz forsować [src], silniki nie stawiają oporu...</span>")
			playsound(src, 'sound/machines/airlock_alien_prying.ogg', 100, TRUE)
			if(!do_after(user, 1 SECONDS, TRUE, src))
				return
		if(!check_safety(user))
			log_game("[key_name(user)] has opened a firelock with a pressure difference or a fire alarm at [AREACOORD(loc)], using a crowbar")
			user.log_message("has opened a firelock with a pressure difference or a fire alarm at [AREACOORD(loc)], using a crowbar", LOG_ATTACK)
		open()
	else
		close()


/obj/machinery/door/firedoor/proc/check_safety(mob/user, check_alarm = TRUE)
	var/area/A = get_area(src)
	if(check_alarm && A && A.fire)
		return FIRE_ALARM
	return !is_holding_pressure()

/obj/machinery/door/firedoor/allowed(mob/M)
	if(check_safety(M))//Passing the mob here is cargo cult programming, I can't see what wants it.
		return TRUE
	update_icon()
	return ..()


/obj/machinery/door/firedoor/attack_ai(mob/user)
	add_fingerprint(user)
	if(welded || operating || machine_stat & NOPOWER)
		return TRUE
	if(density)
		open()
	else
		close()
	return TRUE

/obj/machinery/door/firedoor/attack_robot(mob/user)
	return attack_ai(user)

/obj/machinery/door/firedoor/attack_alien(mob/user)
	add_fingerprint(user)
	if(welded)
		to_chat(user, "<span class='warning'>[src] ani drgnie!</span>")
		return
	open()

/obj/machinery/door/firedoor/do_animate(animation)
	switch(animation)
		if("opening")
			flick("door_opening", src)
		if("closing")
			flick("door_closing", src)

/obj/machinery/door/firedoor/update_icon()
	cut_overlays()
	if(density)
		icon_state = "door_closed"
		if(welded)
			add_overlay("welded")
		switch(check_safety()) //TODO: Check Global Override here. Find some way to update the icon without making firedoors process?
			if(FALSE) //Unsafe, Atmos.
				add_overlay("overlay_pressure")
			if(FIRE_ALARM) //Unsafe, Alarm.
				add_overlay("overlay_alarm")
	else
		icon_state = "door_open"
		if(welded)
			add_overlay("welded_open")
	air_update_turf()

/obj/machinery/door/firedoor/open()
	if(density && !operating) //This is hacky but gets the sound to play on time.
		playsound(src, 'sound/machines/firedoor_open.ogg', 30, 1)
	. = ..()
	if(.)
		STOP_PROCESSING(SSmachines, src)
	latetoggle()


/obj/machinery/door/firedoor/close()
	if(HAS_TRAIT(loc, TRAIT_FIREDOOR_STOP))
		return
	if(!density && !operating) //This is hacky but gets the sound to play on time.
		playsound(src, 'sound/machines/firedoor_close.ogg', 30, 1)
	. = ..()
	if(.)
		START_PROCESSING(SSmachines, src)
	latetoggle()

/obj/machinery/door/firedoor/process(delta_time)
	process_ticker += delta_time
	if(process_ticker < 5*delta_time)
		return
	process_ticker = 0
	update_icon()

/obj/machinery/door/firedoor/proc/whack_a_mole()
	for(var/cdir in GLOB.cardinals)
		if((flags_1 & ON_BORDER_1) && cdir != dir)
			continue
		whack_a_mole_part(get_step(src, cdir))
	if(flags_1 & ON_BORDER_1)
		whack_a_mole_part(get_turf(src))

/obj/machinery/door/firedoor/proc/whack_a_mole_part(turf/start_point)
	set waitfor = 0
	var/list/doors_to_close = list()
	var/list/turfs = list()
	turfs[start_point] = 1
	for(var/i = 1; (i <= turfs.len && i <= 11); i++) // check up to 11 turfs.
		var/turf/open/T = turfs[i]
		if(istype(T, /turf/open/space))
			return -1
		for(var/T2 in T.atmos_adjacent_turfs)
			if(turfs[T2])
				continue
			var/is_cut_by_unopen_door = FALSE
			for(var/obj/machinery/door/firedoor/FD in T2)
				if((FD.flags_1 & ON_BORDER_1) && get_dir(T2, T) != FD.dir)
					continue
				if(FD.operating || FD == src || FD.welded || FD.density)
					continue
				doors_to_close += FD
				is_cut_by_unopen_door = TRUE

			for(var/obj/machinery/door/firedoor/FD in T)
				if((FD.flags_1 & ON_BORDER_1) && get_dir(T, T2) != FD.dir)
					continue
				if(FD.operating || FD == src || FD.welded || FD.density)
					continue
				doors_to_close += FD
				is_cut_by_unopen_door= TRUE
			if(!is_cut_by_unopen_door)
				turfs[T2] = 1
	if(turfs.len > 10)
		return // too big, don't bother
	for(var/obj/machinery/door/firedoor/FD in doors_to_close)
		FD.emergency_pressure_stop(FALSE)

/obj/machinery/door/firedoor/proc/emergency_pressure_stop(consider_timer = TRUE)
	if(density || operating || welded)
		return
	if(world.time >= emergency_close_timer || !consider_timer)
		emergency_pressure_close()

//this is here to prevent sleeps from messing with decomp, by closing firedoors instantly
/obj/machinery/door/firedoor/proc/emergency_pressure_close()
	density = TRUE
	air_update_turf()
	layer = closingLayer
	update_icon()
	if(visible && !glass)
		set_opacity(1)
	update_freelook_sight()
	if(!(flags_1 & ON_BORDER_1))
		crush()

/obj/machinery/door/firedoor/deconstruct(disassembled = TRUE)
	if(!(flags_1 & NODECONSTRUCT_1))
		var/obj/structure/firelock_frame/F = new assemblytype(get_turf(src))
		F.dir = src.dir
		if(disassembled)
			F.constructionStep = CONSTRUCTION_PANEL_OPEN
		else
			F.constructionStep = CONSTRUCTION_WIRES_EXPOSED
			F.obj_integrity = F.max_integrity * 0.5
		F.update_icon()
	qdel(src)


/obj/machinery/door/firedoor/proc/latetoggle()
	if(operating || machine_stat & NOPOWER || !nextstate)
		return
	switch(nextstate)
		if(FIREDOOR_OPEN)
			nextstate = null
			open()
		if(FIREDOOR_CLOSED)
			nextstate = null
			close()

/obj/machinery/door/firedoor/border_only
	icon = 'icons/obj/doors/edge_Doorfire.dmi'
	flags_1 = ON_BORDER_1
	CanAtmosPass = ATMOS_PASS_PROC
	assemblytype = /obj/structure/firelock_frame/border
	opacity = FALSE
	var/ini_dir

/obj/machinery/door/firedoor/border_only/Initialize(mapload, loc, set_dir)
	. = ..()
	if(set_dir)
		setDir(set_dir)
	ini_dir = dir

	var/static/list/loc_connections = list(
		COMSIG_ATOM_EXIT = PROC_REF(on_exit),
	)

	AddElement(/datum/element/connect_loc, loc_connections)

/obj/machinery/door/firedoor/border_only/Destroy()
	density = FALSE
	return ..()

/obj/machinery/door/firedoor/border_only/closed
	icon_state = "door_closed"
	opacity = 1
	density = TRUE

/obj/machinery/door/firedoor/border_only/close()
	if(density)
		return TRUE
	set_opacity(1)
	if(operating || welded)
		return
	check_pulls()
	..()

/obj/machinery/door/firedoor/border_only/emergency_pressure_close()
	check_pulls()
	. = ..()

/obj/machinery/door/firedoor/border_only/proc/check_pulls()
	var/turf/T1 = get_turf(src)
	var/turf/T2 = get_step(T1, dir)
	for(var/mob/living/M in T1)
		if(M.stat == CONSCIOUS && M.pulling && M.pulling.loc == T2 && !M.pulling.anchored && M.pulling.move_resist <= M.move_force)
			var/mob/living/M2 = M.pulling
			if(!istype(M2) || !M2.buckled || !M2.buckled.buckle_prevents_pull)
				to_chat(M, "<span class='notice'>Przeciągasz [M.pulling] przez [src] w ostatniej chwili, gdy się zamyka.</span>")
				M.pulling.forceMove(T1)
				M.start_pulling(M2)
	for(var/mob/living/M in T2)
		if(M.stat == CONSCIOUS && M.pulling && M.pulling.loc == T1 && !M.pulling.anchored && M.pulling.move_resist <= M.move_force)
			var/mob/living/M2 = M.pulling
			if(!istype(M2) || !M2.buckled || !M2.buckled.buckle_prevents_pull)
				to_chat(M, "<span class='notice'>Przeciągasz [M.pulling] przez [src] w ostatniej chwili, gdy się zamyka.</span>")
				M.pulling.forceMove(T2)
				M.start_pulling(M2)

/obj/machinery/door/firedoor/border_only/check_safety(mob/user)
	var/area/A = get_area(src)
	if((!A || !A.fire) && !is_holding_pressure())
		return TRUE
	whack_a_mole(TRUE) // WOOP WOOP SIDE EFFECTS
	var/turf/T = loc
	var/turf/T2 = get_step(T, dir)
	if(!T || !T2)
		return
	var/status1 = check_door_side(T)
	var/status2 = check_door_side(T2)
	if((status1 == 1 && status2 == -1) || (status1 == -1 && status2 == 1))
		return FALSE
	return TRUE

/obj/machinery/door/firedoor/border_only/proc/check_door_side(turf/open/start_point)
	var/list/turfs = list()
	turfs[start_point] = 1
	for(var/i = 1; (i <= turfs.len && i <= 11); i++) // check up to 11 turfs.
		var/turf/open/T = turfs[i]
		if(istype(T, /turf/open/space))
			return -1
		for(var/T2 in T.atmos_adjacent_turfs)
			turfs[T2] = 1
	if(turfs.len <= 10)
		return 0 // not big enough to matter
	return start_point.air.return_pressure() < 20 ? -1 : 1

/obj/machinery/door/firedoor/border_only/CanAllowThrough(atom/movable/mover, turf/target)
	. = ..()
	if(!(get_dir(loc, target) == dir)) //Make sure looking at appropriate border
		return TRUE

/obj/machinery/door/firedoor/border_only/proc/on_exit(datum/source, atom/movable/leaving, direction)
	SIGNAL_HANDLER

	if(direction == dir && density)
		leaving.Bump(src)
		return COMPONENT_ATOM_BLOCK_EXIT

//NSV13 - knpcs can into firelock
/obj/machinery/door/firedoor/CanAStarPass(obj/item/card/id/ID, to_dir, atom/movable/caller)
	if(istype(caller) && (caller.pass_flags & pass_flags_self))
		return TRUE
	if(!density)
		return TRUE
	if(welded)
		return FALSE
	if(!hasPower())
		return isknpc(caller)
	return TRUE

/obj/machinery/door/firedoor/border_only/CanAtmosPass(turf/T)
	if(get_dir(loc, T) == dir)
		return !density
	else
		return 1

/obj/machinery/door/firedoor/border_only/BlockThermalConductivity(opp_dir)
	if(opp_dir == dir)
		return density
	return FALSE
//NSV13 end

/obj/machinery/door/firedoor/heavy
	name = "heavy firelock"
	icon = 'icons/obj/doors/doorfire.dmi'
	glass = FALSE
	explosion_block = 2
	assemblytype = /obj/structure/firelock_frame/heavy
	max_integrity = 550

/obj/machinery/door/firedoor/window
	name = "firelock window shutter"
	icon = 'icons/obj/doors/doorfirewindow.dmi'
	desc = "A second window that slides in when the original window is broken, designed to protect against hull breaches. Truly a work of genius by NT engineers."
	glass = TRUE
	explosion_block = 0
	max_integrity = 100
	resistance_flags = 0 // not fireproof
	heat_proof = FALSE
	assemblytype = /obj/structure/firelock_frame/window

/obj/machinery/door/firedoor/window/attack_alien(mob/living/carbon/alien/humanoid/user)
	playsound(src.loc, 'sound/weapons/slash.ogg', 100, 1)
	return attack_generic(user, 60, BRUTE, "melee", 0)

/obj/machinery/door/firedoor/window/process(delta_time)
	set waitfor = FALSE
	return PROCESS_KILL

/obj/item/electronics/firelock
	name = "firelock circuitry"
	custom_price = 5
	desc = "A circuit board used in construction of firelocks."
	icon_state = "mainboard"

/obj/structure/firelock_frame
	name = "firelock frame"
	desc = "A partially completed firelock."
	icon = 'icons/obj/doors/doorfire.dmi'
	icon_state = "frame1"
	anchored = FALSE
	density = TRUE
	var/constructionStep = CONSTRUCTION_NOCIRCUIT
	var/reinforced = 0
	var/firelock_type = /obj/machinery/door/firedoor

/obj/structure/firelock_frame/examine(mob/user)
	. = ..()
	switch(constructionStep)
		if(CONSTRUCTION_PANEL_OPEN)
			. += "<span class='notice'>Jest <i>odkręcona</i> od podłogi. Przewody zakrywa <b>luźno przymocowana</b> metalowa płytka.</span>"
			if(!reinforced)
				. += "<span class='notice'>Można ją wzmocnić plastalą.</span>"
		if(CONSTRUCTION_WIRES_EXPOSED)
			. += "<span class='notice'>Płytka serwisowa została <i>zdjęta</i>, a <b>przewody</b> zwisają.</span>"
		if(CONSTRUCTION_GUTTED)
			. += "<span class='notice'>W panelu serwisowym brakuje <i>przewodów</i>, a płytka drukowana jest <b>luźno podłączona</b>.</span>"
		if(CONSTRUCTION_NOCIRCUIT)
			. += "<span class='notice'>W ramie nie ma <i>elektroniki grodzi przeciwpożarowej</i>. Ramę można <b>rozciąć</b>.</span>"

/obj/structure/firelock_frame/update_icon()
	..()
	icon_state = "frame[constructionStep]"

/obj/structure/firelock_frame/attackby(obj/item/C, mob/user)
	switch(constructionStep)
		if(CONSTRUCTION_PANEL_OPEN)
			if(C.tool_behaviour == TOOL_CROWBAR)
				C.play_tool_sound(src)
				user.visible_message("<span class='notice'>[user] zaczyna coś wyważać z [src]...</span>", \
									 "<span class='notice'>Zaczynasz wyważać osłonę przewodów...</span>")
				if(!C.use_tool(src, user, 50))
					return
				if(constructionStep != CONSTRUCTION_PANEL_OPEN)
					return
				playsound(get_turf(src), 'sound/items/deconstruct.ogg', 50, 1)
				user.visible_message("<span class='notice'>[user] wyważa metalową płytkę z [src], odsłaniając przewody.</span>", \
									 "<span class='notice'>Zdejmujesz płytkę osłonową z [src], odsłaniając przewody.</span>")
				constructionStep = CONSTRUCTION_WIRES_EXPOSED
				update_icon()
				return
			if(C.tool_behaviour == TOOL_WRENCH)
				var/obj/machinery/door/firedoor/A = locate(/obj/machinery/door/firedoor) in get_turf(src)
				if(A && A.dir == src.dir)
					to_chat(user, "<span class='warning'>Tam już jest gródź przeciwpożarowa.</span>")
					return
				C.play_tool_sound(src)
				user.visible_message("<span class='notice'>[user] zaczyna przykręcać [src]...</span>", \
									 "<span class='notice'>Zaczynasz przykręcać [src]...</span>")
				if(!C.use_tool(src, user, 30))
					return
				var/obj/machinery/door/firedoor/D = locate(/obj/machinery/door/firedoor) in get_turf(src)
				if(D && D.dir == src.dir)
					return
				user.visible_message("<span class='notice'>[user] kończy gródź przeciwpożarową.</span>", \
									 "<span class='notice'>Kończysz gródź przeciwpożarową.</span>")
				playsound(get_turf(src), 'sound/items/deconstruct.ogg', 50, 1)
				var/obj/machinery/door/firedoor/F = new firelock_type(get_turf(src))
				F.dir = src.dir
				F.update_icon()
				qdel(src)
				return
			if(istype(C, /obj/item/stack/sheet/plasteel))
				var/obj/item/stack/sheet/plasteel/P = C
				if(reinforced)
					to_chat(user, "<span class='warning'>[src] jest już wzmocniona.</span>")
					return
				if(P.get_amount() < 2)
					to_chat(user, "<span class='warning'>Do wzmocnienia [src] potrzebujesz więcej plastali.</span>")
					return
				user.visible_message("<span class='notice'>[user] zaczyna wzmacniać [src]...</span>", \
									 "<span class='notice'>Zaczynasz wzmacniać [src]...</span>")
				playsound(get_turf(src), 'sound/items/deconstruct.ogg', 50, 1)
				if(do_after(user, 60, target = src))
					if(constructionStep != CONSTRUCTION_PANEL_OPEN || reinforced || P.get_amount() < 2 || !P)
						return
					user.visible_message("<span class='notice'>[user] reinforces [src].</span>", \
										 "<span class='notice'>Wzmacniasz [src].</span>")
					playsound(get_turf(src), 'sound/items/deconstruct.ogg', 50, 1)
					P.use(2)
					reinforced = TRUE
					firelock_type = /obj/machinery/door/firedoor/heavy
				return

		if(CONSTRUCTION_WIRES_EXPOSED)
			if(C.tool_behaviour == TOOL_WIRECUTTER)
				C.play_tool_sound(src)
				user.visible_message("<span class='notice'>[user] zaczyna wycinać przewody z [src]...</span>", \
									 "<span class='notice'>Zaczynasz wyjmować przewody z [src]...</span>")
				if(!C.use_tool(src, user, 60))
					return
				if(constructionStep != CONSTRUCTION_WIRES_EXPOSED)
					return
				user.visible_message("<span class='notice'>[user] wyjmuje przewody z [src].</span>", \
									 "<span class='notice'>Wyjmujesz okablowanie z [src], odsłaniając płytkę drukowaną.</span>")
				new/obj/item/stack/cable_coil(get_turf(src), 5)
				constructionStep = CONSTRUCTION_GUTTED
				update_icon()
				return
			if(C.tool_behaviour == TOOL_CROWBAR)
				C.play_tool_sound(src)
				user.visible_message("<span class='notice'>[user] zaczyna wsadzać łomem metalową płytkę do [src]...</span>", \
									 "<span class='notice'>Zaczynasz wsadzać płytkę osłonową z powrotem na [src]...</span>")
				if(!C.use_tool(src, user, 80))
					return
				if(constructionStep != CONSTRUCTION_WIRES_EXPOSED)
					return
				playsound(get_turf(src), 'sound/items/deconstruct.ogg', 50, 1)
				user.visible_message("<span class='notice'>[user] wsadza metalową płytkę do [src].</span>", \
									 "<span class='notice'>Wsadzasz płytkę osłonową [src] na miejsce, ukrywając przewody.</span>")
				constructionStep = CONSTRUCTION_PANEL_OPEN
				update_icon()
				return
		if(CONSTRUCTION_GUTTED)
			if(C.tool_behaviour == TOOL_CROWBAR)
				user.visible_message("<span class='notice'>[user] zaczyna wyjmować płytkę drukowaną z [src]...</span>", \
									 "<span class='notice'>Zaczynasz wyważać płytkę drukowaną z [src]...</span>")
				if(!C.use_tool(src, user, 50, volume=50))
					return
				if(constructionStep != CONSTRUCTION_GUTTED)
					return
				user.visible_message("<span class='notice'>[user] wyjmuje płytkę drukowaną z [src].</span>", \
									 "<span class='notice'>Wyjmujesz płytkę drukowaną z [src].</span>")
				new /obj/item/electronics/firelock(drop_location())
				constructionStep = CONSTRUCTION_NOCIRCUIT
				update_icon()
				return
			if(istype(C, /obj/item/stack/cable_coil))
				var/obj/item/stack/cable_coil/B = C
				if(B.get_amount() < 5)
					to_chat(user, "<span class='warning'>Do okablowania [src] potrzebujesz więcej przewodów.</span>")
					return
				user.visible_message("<span class='notice'>[user] zaczyna okablowywać [src]...</span>", \
									 "<span class='notice'>Zaczynasz podłączać przewody do [src]...</span>")
				playsound(get_turf(src), 'sound/items/deconstruct.ogg', 50, 1)
				if(do_after(user, 60, target = src))
					if(constructionStep != CONSTRUCTION_GUTTED || B.get_amount() < 5 || !B)
						return
					user.visible_message("<span class='notice'>[user] podłącza przewody do [src].</span>", \
										 "<span class='notice'>Okablowujesz [src].</span>")
					playsound(get_turf(src), 'sound/items/deconstruct.ogg', 50, 1)
					B.use(5)
					constructionStep = CONSTRUCTION_WIRES_EXPOSED
					update_icon()
				return
		if(CONSTRUCTION_NOCIRCUIT)
			if(C.tool_behaviour == TOOL_WELDER)
				if(!C.tool_start_check(user, amount=1))
					return
				user.visible_message("<span class='notice'>[user] zaczyna rozcinać ramę [src]...</span>", \
									 "<span class='notice'>Zaczynasz rozcinać [src]...</span>")

				if(C.use_tool(src, user, 40, volume=50, amount=1))
					if(constructionStep != CONSTRUCTION_NOCIRCUIT)
						return
					var/turf/T = get_turf(src)
					switch(firelock_type)
						if(/obj/machinery/door/firedoor/heavy)
							user.visible_message("<span class='notice'>[user] rozcina [src]!</span>", \
										 "<span class='notice'>Rozcinasz [src] na żelazo i plastal.</span>")
							new /obj/item/stack/sheet/plasteel(T, 2)
							new /obj/item/stack/sheet/iron(T, 3)
						if(/obj/machinery/door/firedoor/window)
							user.visible_message("<span class='notice'>[user] rozcina [src]!</span>", \
										 "<span class='notice'>Rozcinasz [src] na wzmocnione szkło.</span>")
							new /obj/item/stack/sheet/rglass(T,2)
						else
							user.visible_message("<span class='notice'>[user] rozcina [src]!</span>", \
										 "<span class='notice'>Rozcinasz [src] na żelazo.</span>")
							new /obj/item/stack/sheet/iron(T, 3)
					qdel(src)
				return
			if(istype(C, /obj/item/electronics/firelock))
				user.visible_message("<span class='notice'>[user] zaczyna dodawać [C] do [src]...</span>", \
									 "<span class='notice'>Zaczynasz dodawać płytkę drukowaną do [src]...</span>")
				playsound(get_turf(src), 'sound/items/deconstruct.ogg', 50, 1)
				if(!do_after(user, 40, target = src))
					return
				if(constructionStep != CONSTRUCTION_NOCIRCUIT)
					return
				qdel(C)
				user.visible_message("<span class='notice'>[user] dodaje płytkę do [src].</span>", \
									 "<span class='notice'>Wkładasz i mocujesz [C].</span>")
				playsound(get_turf(src), 'sound/items/deconstruct.ogg', 50, 1)
				constructionStep = CONSTRUCTION_GUTTED
				update_icon()
				return
			if(istype(C, /obj/item/electroadaptive_pseudocircuit))
				var/obj/item/electroadaptive_pseudocircuit/P = C
				if(!P.adapt_circuit(user, 30))
					return
				user.visible_message("<span class='notice'>[user] wytwarza płytkę i umieszcza ją w [src].</span>", \
				"<span class='notice'>Dostosowujesz płytkę grodzi przeciwpożarowej i wsuwasz ją do zespołu.</span>")
				constructionStep = CONSTRUCTION_GUTTED
				update_icon()
				return
	return ..()

/obj/structure/firelock_frame/rcd_vals(mob/user, obj/item/construction/rcd/the_rcd)
	if(the_rcd.mode == RCD_DECONSTRUCT)
		return list("mode" = RCD_DECONSTRUCT, "delay" = 50, "cost" = 16)
	else if((constructionStep == CONSTRUCTION_NOCIRCUIT) && (the_rcd.upgrade & RCD_UPGRADE_SIMPLE_CIRCUITS))
		return list("mode" = RCD_UPGRADE_SIMPLE_CIRCUITS, "delay" = 20, "cost" = 1)
	return FALSE

/obj/structure/firelock_frame/rcd_act(mob/user, obj/item/construction/rcd/the_rcd, passed_mode)
	switch(passed_mode)
		if(RCD_UPGRADE_SIMPLE_CIRCUITS)
			user.visible_message("<span class='notice'>[user] wytwarza płytkę i umieszcza ją w [src].</span>", \
			"<span class='notice'>Dostosowujesz płytkę grodzi przeciwpożarowej i wsuwasz ją do zespołu.</span>")
			constructionStep = CONSTRUCTION_GUTTED
			update_icon()
			return TRUE
		if(RCD_DECONSTRUCT)
			to_chat(user, "<span class='notice'>Rozbierasz [src].</span>")
			qdel(src)
			return TRUE
	return FALSE

/obj/structure/firelock_frame/heavy
	name = "heavy firelock frame"
	reinforced = TRUE
	firelock_type = /obj/machinery/door/firedoor/heavy

/obj/structure/firelock_frame/border
	name = "firelock frame"
	icon = 'icons/obj/doors/edge_Doorfire.dmi'
	icon_state = "door_frame"
	density = FALSE
	firelock_type = /obj/machinery/door/firedoor/border_only

/obj/structure/reagent_dispensers/plumbed/storage/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/simple_rotation)

/obj/structure/firelock_frame/border/update_icon()
	return

/obj/structure/firelock_frame/window
	name = "window firelock frame"
	icon = 'icons/obj/doors/doorfirewindow.dmi'
	icon_state = "door_frame"
	firelock_type = /obj/machinery/door/firedoor/window

/obj/structure/firelock_frame/window/update_icon()
	return

#undef CONSTRUCTION_COMPLETE
#undef CONSTRUCTION_PANEL_OPEN
#undef CONSTRUCTION_WIRES_EXPOSED
#undef CONSTRUCTION_GUTTED
#undef CONSTRUCTION_NOCIRCUIT

#undef FIRE_ALARM
