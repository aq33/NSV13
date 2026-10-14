// AQUILA - demon impulsu: kliknięcia, sterowanie maszynami w przejętym obszarze i przejmowanie urządzeń (port z ParadiseSS13)

/// Czy APC jest właśnie przejmowane przez demona impulsu
/obj/machinery/power/apc/var/being_hijacked = FALSE

/// Bot sterowany przez demona impulsu nie działa sam
/mob/living/simple_animal/bot/var/pulse_hijacked = FALSE

/mob/living/simple_animal/bot/handle_automated_action()
	if(pulse_hijacked)
		return FALSE
	return ..()

/// Czy mob steruje tą maszyną zdalnie jak SI. Woła to /obj/machinery/can_interact().
/mob/proc/has_remote_machine_access(atom/target)
	return FALSE

/mob/living/simple_animal/pulse_demon/has_remote_machine_access(atom/target)
	if(!istype(target) || stat)
		return FALSE
	if(target == loc)
		return TRUE
	return controlling_area && get_area(target) == controlling_area

/mob/living/simple_animal/pulse_demon/default_can_use_topic(src_object)
	if(has_remote_machine_access(src_object))
		return shared_ui_interaction(src_object)
	return ..()

/mob/living/simple_animal/pulse_demon/ClickOn(atom/A, params)
	if(world.time <= next_click)
		return
	next_click = world.time + 1

	if(check_click_intercept(params, A))
		return

	if(try_modified_click(A, params))
		return

	if(stat)
		return

	// najpierw ucieczka z tego, co przejęliśmy
	if(istype(A, /obj/machinery/power/apc) && !isturf(loc) && (A in hijacked_apcs))
		A.attack_pulsedemon(src)
	else if(istype(current_weapon, /obj/item/gun/energy))
		// broń jonowa ma własne emp_act, więc siedzenie w niej przy EMP jest bezpieczne
		var/obj/item/gun/energy/G = current_weapon
		// nie strzelamy z ładowarki ani z czyjejś torby
		if(iscarbon(G.loc) || isturf(G.loc))
			G.process_fire(A, src, FALSE)
			visible_message("<span class='danger'>[G] sam strzela w [A]!</span>", "<span class='danger'>Zmuszasz [G] do strzału w [A]!</span>", "<span class='italics'>Słyszysz strzał!</span>")
			next_click = world.time + CLICK_CD_RANGE
			return
	else if(current_robot)
		log_admin("[key_name(src)] made [key_name(current_robot)] attack [A]")
		message_admins("<span class='notice'>[ADMIN_LOOKUPFLW(src)] made [ADMIN_LOOKUPFLW(current_robot)] attack [A]</span>")
		current_robot.next_click = 0
		current_robot.ClickOn(A, params)
		next_click = world.time + 0.5 SECONDS
		return
	else if(current_bot)
		if(A == current_bot)
			current_bot.attack_ai(src)
		else
			current_bot.attack_integrated_pulsedemon(src, A)
			next_click = world.time + 0.5 SECONDS
			return
	else if(controlling_area && get_area(A) == controlling_area)
		A.attack_pulsedemon(src)
	else
		// zwykłe kliknięcie, parent sam sprawdza next_click
		next_click = 0
		return ..()

/// Zwraca TRUE, gdy kliknięcie z modyfikatorem zostało obsłużone
/mob/living/simple_animal/pulse_demon/proc/try_modified_click(atom/A, params)
	var/list/modifiers = params2list(params)
	if(LAZYACCESS(modifiers, MIDDLE_CLICK))
		return TRUE
	if(LAZYACCESS(modifiers, SHIFT_CLICK))
		if(LAZYACCESS(modifiers, CTRL_CLICK))
			if(controls_area_of(A))
				A.AICtrlShiftClick(src)
		else if(controls_area_of(A))
			A.AIShiftClick(src)
		else
			examinate(A)
		return TRUE
	if(LAZYACCESS(modifiers, ALT_CLICK))
		if(controls_area_of(A))
			A.AIAltClick(src)
		else
			AltClickOn(A)
		return TRUE
	if(LAZYACCESS(modifiers, CTRL_CLICK))
		if(controls_area_of(A))
			A.AICtrlClick(src)
		return TRUE
	return FALSE

/mob/living/simple_animal/pulse_demon/proc/controls_area_of(atom/A)
	return !stat && controlling_area && get_area(A) == controlling_area

// Gdy demon siedzi w czymś, ruch trafia tutaj (remote_control = src, patrz forceMove)
/mob/living/simple_animal/pulse_demon/relaymove(mob/user, direction)
	if(user != src || stat || !direction)
		return
	if(current_bot)
		if(!current_bot.on)
			to_chat(src, "<span class='warning'>[current_bot] jest wyłączony!</span>")
			return
		if(bot_movedelay <= world.time)
			step(current_bot, direction)
			bot_movedelay = world.time + BOT_STEP_DELAY * ((direction in GLOB.diagonals) ? sqrt(2) : 1)
		return
	if(istype(loc, /obj/machinery/power))
		var/obj/machinery/power/machine = loc
		var/turf/T = get_turf(machine)
		var/turf/T2 = get_step(T, direction)
		if(!can_exit_cable && !(locate(/obj/structure/cable) in T2))
			return
		playsound(machine, 'aquila/sound/pulsedemon/eleczap.ogg', 15, TRUE)
		do_sparks(rand(2, 4), FALSE, machine)
		if(current_power)
			UnregisterSignal(current_power, COMSIG_ATOM_EMP_ACT)
		current_power = null
		current_cable = locate(/obj/structure/cable) in T
		forceMove(T)
		update_controlling_area(TRUE)
		return
	if(bot_movedelay <= world.time)
		bot_movedelay = world.time + 5 SECONDS
		to_chat(src, "<span class='notice'>Żeby stąd wyjść, kliknij przejęte APC.</span>")

/// Puszcza przejętego bota
/mob/living/simple_animal/pulse_demon/proc/release_bot()
	if(current_bot)
		current_bot.pulse_hijacked = FALSE
		current_bot = null

/mob/living/simple_animal/pulse_demon/proc/do_hijack_robot(mob/living/silicon/robot/R)
	to_chat(src, "<span class='notice'>Jesteś w środku [R]. Kliknij przejęte APC, żeby wrócić.</span>")
	forceMove(R)
	current_robot = R
	if(!(R in hijacked_robots))
		hijacked_robots += R
		to_chat(R, "<span class='userdanger'>SYSTEMY CELOWANIA PRZEJĘTE, ZGŁOŚ KAŻDĄ NIEPOŻĄDANĄ AKTYWNOŚĆ</span>")

// Co się dzieje, gdy demon kliknie coś w przejętym obszarze

/atom/proc/attack_pulsedemon(mob/living/simple_animal/pulse_demon/user)
	return

/obj/machinery/attack_pulsedemon(mob/living/simple_animal/pulse_demon/user)
	return attack_ai(user)

// skok z powrotem do przejętego APC
/obj/machinery/power/apc/attack_pulsedemon(mob/living/simple_animal/pulse_demon/user)
	if(user.loc != src)
		user.forceMove(src)
		user.current_power = src
		user.RegisterSignal(src, COMSIG_ATOM_EMP_ACT, TYPE_PROC_REF(/mob/living/simple_animal/pulse_demon, handle_emp), TRUE)
		user.update_controlling_area()
	else
		attack_ai(user)

/mob/living/simple_animal/bot/attack_pulsedemon(mob/living/simple_animal/pulse_demon/user)
	if(user.loc == src)
		return
	to_chat(user, "<span class='warning'>Jesteś w środku [src]. Jeśli zostanie zniszczony, wypadniesz na ziemię i możesz zginąć, jeśli nie będzie pod tobą kabla.</span>")
	to_chat(user, "<span class='notice'>Wyjdziesz, skacząc do przejętego APC.</span>")
	user.forceMove(src)
	user.current_bot = src
	pulse_hijacked = TRUE

/// Demon w bocie klika cel
/mob/living/simple_animal/bot/proc/attack_integrated_pulsedemon(mob/living/simple_animal/pulse_demon/user, atom/A)
	if(!on)
		return
	if(Adjacent(A))
		UnarmedAttack(A, TRUE)
	else
		RangedAttack(A)

/obj/machinery/recharger/attack_pulsedemon(mob/living/simple_animal/pulse_demon/user)
	user.forceMove(src)
	if(!charging)
		to_chat(user, "<span class='warning'>Nic się nie ładuje. Kliknij ponownie, żeby spróbować jeszcze raz.</span>")
		return
	to_chat(user, "<span class='notice'>Próbujesz przejąć [src], to potrwa około [user.hijack_time / 10] sekund.</span>")
	if(!do_after(user, user.hijack_time, FALSE, src))
		return
	if(!charging)
		to_chat(user, "<span class='warning'>Nie udało się przejąć [src].</span>")
		return
	to_chat(user, "<span class='notice'>Jesteś w środku [charging]. Kliknij przejęte APC, żeby wrócić.</span>")
	user.forceMove(charging)
	user.current_weapon = charging

/obj/machinery/cell_charger/attack_pulsedemon(mob/living/simple_animal/pulse_demon/user)
	user.forceMove(src)
	if(!charging)
		to_chat(user, "<span class='warning'>Żadne ogniwo się nie ładuje. Kliknij ponownie, żeby spróbować jeszcze raz.</span>")
		return
	if(charging.rigged)
		to_chat(user, "<span class='notice'>Jesteś w środku [charging]. Kliknij przejęte APC, żeby wrócić.</span>")
		user.forceMove(charging)
		return
	to_chat(user, "<span class='notice'>Próbujesz przejąć [src], to potrwa około [user.hijack_time / 10] sekund.</span>")
	if(!do_after(user, user.hijack_time, FALSE, src))
		return
	if(!charging)
		to_chat(user, "<span class='warning'>Nie udało się przejąć [src].</span>")
		return
	to_chat(user, "<span class='notice'>Jesteś w środku [charging]. Kliknij przejęte APC, żeby wrócić.</span>")
	user.forceMove(charging)

/obj/machinery/recharge_station/attack_pulsedemon(mob/living/simple_animal/pulse_demon/user)
	if(!iscyborg(occupant))
		to_chat(user, "<span class='warning'>W środku nie ma cyborga.</span>")
		return
	var/mob/living/silicon/robot/R = occupant
	if(R in user.hijacked_robots)
		user.do_hijack_robot(R)
		return
	user.forceMove(src)
	to_chat(user, "<span class='notice'>Próbujesz przejąć [R], to potrwa około [user.hijack_time / 10] sekund.</span>")
	to_chat(R, "<span class='userdanger'>ALARM: WYKRYTO WROGIE NAPIĘCIE, TRWA PRZEJMOWANIE SYSTEMÓW CELOWANIA</span>")
	if(!do_after(user, user.hijack_time, FALSE, src))
		return
	if(occupant == R)
		user.do_hijack_robot(R)
		return
	to_chat(user, "<span class='warning'>Nie udało się przejąć [src].</span>")

/obj/machinery/camera/attack_pulsedemon(mob/living/simple_animal/pulse_demon/user)
	if(user.loc != src)
		user.forceMove(src)
		to_chat(user, "<span class='notice'>Przeskakujesz do [src]. Kliknij przejęte APC, żeby wrócić.</span>")

// mówienie przez holopad: patrz send_speech() demona
/obj/machinery/holopad/attack_pulsedemon(mob/living/simple_animal/pulse_demon/user)
	if(user.loc != src)
		user.forceMove(src)
		to_chat(user, "<span class='notice'>Przeskakujesz do [src]. Możesz teraz mówić przez głośnik holopadu. Kliknij przejęte APC, żeby wrócić.</span>")

/obj/item/radio/attack_pulsedemon(mob/living/simple_animal/pulse_demon/user)
	if(user.loc != src)
		user.forceMove(src)
		to_chat(user, "<span class='notice'>Przeskakujesz do [src]. Możesz teraz mówić przez radio. Kliknij przejęte APC, żeby wrócić.</span>")
	else
		ui_interact(user, null, GLOB.default_state)
