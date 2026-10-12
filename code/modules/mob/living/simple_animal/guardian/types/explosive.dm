#define UNREGISTER_BOMB_SIGNALS(A) \
	do { \
		UnregisterSignal(A, boom_signals); \
		UnregisterSignal(A, COMSIG_PARENT_EXAMINE); \
	} while (0)

//Bomb
/mob/living/simple_animal/hostile/guardian/bomb
	melee_damage = 15
	damage_coeff = list(BRUTE = 0.6, BURN = 0.6, TOX = 0.6, CLONE = 0.6, STAMINA = 0, OXY = 0.6)
	range = 13
	playstyle_string = "<span class='holoparasite'>Jako typ <b>explosive</b> masz umiarkowane zdolności w walce wręcz, możesz atakiem wybuchowo teleportować cele i potrafisz alt-kliknięciem zamieniać pobliskie przedmioty i obiekty w zamaskowane bomby.</span>"
	magic_fluff_string = "<span class='holoparasite'>...I wyciągasz Naukowca, mistrza wybuchowej śmierci.</span>"
	tech_fluff_string = "<span class='holoparasite'>Sekwencja startowa zakończona. Moduły wybuchowe aktywne. Rój holoparazytów aktywny.</span>"
	carp_fluff_string = "<span class='holoparasite'>KARP KARP KARP! Złowiony! To wybuchowy karp! Bum, rybka.</span>"
	hive_fluff_string = "<span class='holoparasite'>Masa wydaje się generować wybuchową energię, niszcząc wszystko na swojej drodze.</span>"
	var/bomb_cooldown = 0
	var/static/list/boom_signals = list(COMSIG_PARENT_ATTACKBY, COMSIG_ATOM_BUMPED, COMSIG_ATOM_ATTACK_HAND)

/mob/living/simple_animal/hostile/guardian/bomb/get_stat_tab_status()
	var/list/tab_data = ..()
	if(bomb_cooldown >= world.time)
		tab_data["Odnowienie bomby"] = GENERATE_STAT_TEXT("[DisplayTimeText(bomb_cooldown - world.time)]")

/mob/living/simple_animal/hostile/guardian/bomb/AttackingTarget()
	. = ..()
	if(. && prob(40) && isliving(target))
		var/mob/living/M = target
		if(!M.anchored && M != summoner && !hasmatchingsummoner(M))
			new /obj/effect/temp_visual/guardian/phase/out(get_turf(M))
			do_teleport(M, M, 10, channel = TELEPORT_CHANNEL_BLUESPACE)
			for(var/mob/living/L in range(1, M))
				if(hasmatchingsummoner(L)) //if the summoner matches don't hurt them
					continue
				if(L != src && L != summoner)
					L.apply_damage(15, BRUTE)
			new /obj/effect/temp_visual/explosion(get_turf(M))

/mob/living/simple_animal/hostile/guardian/bomb/AltClickOn(atom/movable/A)
	if(!istype(A))
		return
	if(loc == summoner)
		to_chat(src, "<span class='danger'><B>Musisz się zmaterializować, by tworzyć bomby!</B></span>")
		return
	if(isobj(A) && Adjacent(A))
		if(bomb_cooldown <= world.time && !stat)
			to_chat(src, "<span class='danger'><B>Sukces! Bomba uzbrojona!</B></span>")
			bomb_cooldown = world.time + 200
			RegisterSignal(A, COMSIG_PARENT_EXAMINE, PROC_REF(display_examine))
			RegisterSignal(A, boom_signals, PROC_REF(kaboom))
			addtimer(CALLBACK(src, PROC_REF(disable), A), 600, TIMER_UNIQUE|TIMER_OVERRIDE)
		else
			to_chat(src, "<span class='danger'><B>Twoje moce się odnawiają! Między bombami musisz odczekać 20 sekund.</B></span>")

/mob/living/simple_animal/hostile/guardian/bomb/proc/kaboom(atom/source, mob/living/explodee)
	SIGNAL_HANDLER

	if(!istype(explodee))
		return
	if(explodee == src || explodee == summoner || hasmatchingsummoner(explodee))
		return
	to_chat(explodee, "<span class='danger'><B>[source] był pułapką!</B></span>")
	to_chat(src, "<span class='danger'><B>Sukces! Twoja pułapka dopadła [explodee]</B></span>")
	var/turf/T = get_turf(source)
	playsound(T,'sound/effects/explosion2.ogg', 200, 1)
	new /obj/effect/temp_visual/explosion(T)
	explodee.ex_act(EXPLODE_HEAVY)
	UNREGISTER_BOMB_SIGNALS(source)

/mob/living/simple_animal/hostile/guardian/bomb/proc/disable(atom/A)
	to_chat(src, "<span class='danger'><B>Porażka! Tym razem twoja pułapka nikogo nie dopadła.</B></span>")
	UNREGISTER_BOMB_SIGNALS(A)

/mob/living/simple_animal/hostile/guardian/bomb/proc/display_examine(datum/source, mob/user, text)
	SIGNAL_HANDLER

	text += "<span class='holoparasite'>Świeci dziwnym <font color=\"[guardiancolor]\">światłem</font>!</span>"

#undef UNREGISTER_BOMB_SIGNALS
