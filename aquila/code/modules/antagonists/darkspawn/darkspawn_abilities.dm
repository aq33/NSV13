// AQUILA - darkspawn: zdolności

/// Kanałowana zdolność, która zamienia darkspawna w jego prawdziwą postać
/datum/action/innate/darkspawn/divulge
	name = "Objawienie"
	id = "divulge"
	desc = "Zrzuca ludzkie przebranie. To bardzo widowiskowe, więc zrób to w ustronnym miejscu. Nie da się tego cofnąć."
	button_icon_state = "divulge"
	check_flags = AB_CHECK_STUN | AB_CHECK_CONSCIOUS | AB_CHECK_LYING
	blacklisted = TRUE

/datum/action/innate/darkspawn/divulge/Activate()
	set waitfor = FALSE
	var/mob/living/carbon/human/user = owner
	if(!ishuman(user))
		to_chat(user, "<span class='warning'>Musisz być bardziej człowiekiem, żeby to zrobić!</span>")
		return FALSE
	var/turf/spot = get_turf(user)
	if(isethereal(user))
		user.set_light(0)
	if(spot.get_lumcount() > DARKSPAWN_DIM_LIGHT)
		to_chat(user, "<span class='warning'>Skórę możesz zrzucić tylko w ciemności!</span>")
		return FALSE
	if(alert(user, "Jesteś gotów zrzucić skórę. Na pewno?", name, "Tak", "Nie") != "Tak")
		return FALSE
	if(QDELETED(src) || in_use)
		return FALSE
	in_use = TRUE
	if(ispodperson(user))
		to_chat(user, "<span class='notice'>Objawienie stabilizuje twoje przebranie...</span>")
		user.reagents.add_reagent(/datum/reagent/medicine/salbutamol, 20)
	if(isplasmaman(user))
		to_chat(user, "<span class='notice'>Twoje kości twardnieją, żeby chronić cię przed atmosferą...</span>")
		user.set_species(/datum/species/skeleton)
	user.visible_message("<b>[user]</b> trzepocze skrzydłami.", "<span class='velvet'>Zaczynasz tworzyć wokół siebie barierę psioniczną...</span>")
	if(!do_after(user, 3 SECONDS, target = user))
		in_use = FALSE
		return FALSE
	var/image/alert_overlay = image('aquila/icons/mob/darkspawn/actions_darkspawn.dmi', "divulge")
	notify_ghosts("Darkspawn [user.real_name] zaczął zrzucać skórę w [get_area(user)]!", ghost_sound = 'aquila/sound/darkspawn/devour_will_victim.ogg', source = user, alert_overlay = alert_overlay, action = NOTIFY_ORBIT)
	user.visible_message("<span class='warning'>Wokół [user] wiruje fioletowa energia!</span>", "<span class='velvet'>Bariera do pewnego stopnia cię osłoni...</span>")
	user.visible_message("<span class='danger'>[user] powoli unosi się w powietrze, gubiąc swoje rzeczy, i zaczyna migotać...</span>", \
		"<span class='velvet big'><b>Zaczynasz zrzucać ludzkie przebranie. Do końca będziesz zupełnie bezbronny.</b></span>")
	user.setDir(SOUTH)
	user.unequip_everything()
	for(var/turf/T in RANGE_TURFS(1, user))
		new /obj/structure/psionic_barrier(T, 500)
	for(var/stage in 1 to 3)
		switch(stage)
			if(1)
				user.visible_message("<span class='userdanger'>Powietrze drży. Oczy [user] zaczynają świecić głębokim fioletem.</span>", \
					"<span class='velvet'>Psi zalewa twoją świadomość. Czujesz, jak umysł rośnie w siłę... <i>rozszerza się.</i></span>")
				playsound(user, 'aquila/sound/darkspawn/divulge_01.ogg', 30, FALSE)
			if(2)
				user.visible_message("<span class='userdanger'>Grawitacja faluje. Psychiczne macki wysuwają się i na ślepo obmacują okolicę.</span>", \
					"<span class='velvet'>Grawitacja wokół ciebie faluje. Ostrożnie sięgasz umysłem na zewnątrz.</span>")
				user.Shake(0, 3, 750)
				playsound(user, 'aquila/sound/darkspawn/divulge_02.ogg', 40, FALSE)
			if(3)
				user.visible_message("<span class='userdanger'>Na ciele [user] pojawiają się sigile. Skóra czernieje, a całe ciało jarzy się oślepiającym fioletem.</span>", \
					"<span class='velvet'>Twoje ciało zaczyna się wykrzywiać. Sigile wyżłabiają się w twoim ciele.</span>")
				animate(user, color = list(rgb(0, 0, 0), rgb(0, 0, 0), rgb(0, 0, 0), rgb(0, 0, 0)), time = 15 SECONDS)
				playsound(user, 'aquila/sound/darkspawn/divulge_03.ogg', 50, FALSE)
		if(!do_after(user, 15 SECONDS, target = user))
			user.visible_message("<span class='warning'>[user] spada na ziemię!</span>", "<span class='userdanger'>Przemiana została przerwana!</span>")
			animate(user, color = initial(user.color), pixel_y = initial(user.pixel_y), time = 1 SECONDS)
			in_use = FALSE
			return FALSE
	playsound(user, 'aquila/sound/darkspawn/divulge_ending.ogg', 50, FALSE)
	user.visible_message("<span class='userdanger'>[user] wznosi się w powietrze, trzeszcząc od mocy!</span>", "<span class='velvet bold'>Twój umysł...! nie może--- MYŚLEĆ--</span>")
	animate(user, pixel_y = user.pixel_y + 8, time = 6 SECONDS)
	sleep(4.5 SECONDS)
	user.Shake(5, 5, 11 SECONDS)
	for(var/i in 1 to 20)
		to_chat(user, "<span class='velvet bold'>[pick("J- J- J-", "Umysł-", "Sigile-", "Nie mogę myśleć-", "<i>MOC-</i>", "<i>BRAĆ-</i>", "W-W-WIĘĘĘCEJ-")]</span>")
		sleep(0.11 SECONDS)
	user.visible_message("<span class='userdanger'>Od [user] rozchodzi się potężna fala uderzeniowa!</span>", "<span class='velvet big'><b>JESTEŚ WOLNY!!</b></span>")
	playsound(user, 'aquila/sound/darkspawn/divulge_end.ogg', 50, FALSE)
	animate(user, color = initial(user.color), pixel_y = initial(user.pixel_y), time = 3 SECONDS)
	for(var/mob/living/L in view(7, user))
		if(L == user)
			continue
		L.flash_act(1, 1)
		L.Knockdown(5 SECONDS)
	var/old_name = user.real_name
	var/datum/antagonist/darkspawn/our_darkspawn = darkspawn
	in_use = FALSE
	our_darkspawn.divulge() // usuwa tę zdolność
	var/processed_message = "<span class='velvet'><b>\[Mindlink\] [old_name] zrzucił ludzkie przebranie i jest teraz [user.real_name].</b></span>"
	for(var/mob/M as anything in GLOB.alive_mob_list)
		if(is_darkspawn_or_veil(M))
			to_chat(M, processed_message)
	deadchat_broadcast(processed_message, user)

/// Zamienia darkspawna w Potomka i kończy rundę
/datum/action/innate/darkspawn/sacrament
	name = "Sakrament"
	id = "sacrament"
	desc = "Wznosisz się do postaci Potomka. Jeśli nikt wcześniej nie odprawił Sakramentu, musisz najpierw pożreć wolę 15-30 różnych osób (sprawdź cel) i kupić wszystkie ulepszenia pasywne."
	button_icon_state = "sacrament"
	check_flags = AB_CHECK_STUN | AB_CHECK_CONSCIOUS
	blacklisted = TRUE
	var/datum/looping_sound/sacrament/soundloop

/datum/action/innate/darkspawn/sacrament/Destroy()
	QDEL_NULL(soundloop)
	return ..()

/datum/action/innate/darkspawn/sacrament/Activate()
	set waitfor = FALSE
	var/datum/team/darkspawn/team = darkspawn.team
	if(team.sacrament_done)
		darkspawn.sacrament()
		return FALSE
	if(darkspawn.lucidity_drained < team.required_succs)
		to_chat(owner, "<span class='warning'>Masz za mało unikalnej lucidity! ([darkspawn.lucidity_drained] / [team.required_succs])</span>")
		return FALSE
	var/list/unpurchased_upgrades = list()
	for(var/datum/darkspawn_upgrade/upgrade_type as anything in subtypesof(/datum/darkspawn_upgrade))
		if(!darkspawn.has_upgrade(initial(upgrade_type.id)))
			unpurchased_upgrades += initial(upgrade_type.name)
	if(length(unpurchased_upgrades))
		to_chat(owner, "<span class='warning'>Nie kupiłeś wszystkich ulepszeń pasywnych! Brakuje:</span> <span class='danger'>[unpurchased_upgrades.Join(", ")].</span>")
		return FALSE
	if(alert(owner, "Sakrament jest gotowy! Jesteś przygotowany?", name, "Tak", "Nie") != "Tak")
		return FALSE
	if(QDELETED(src) || in_use)
		return FALSE
	in_use = TRUE
	var/mob/living/carbon/human/user = owner
	user.visible_message("<span class='warning'>Sigile [user] rozbłyskują, a wokół wiruje energia...</span>", "<span class='velvet'>Zaczynasz tworzyć wokół siebie barierę psioniczną...</span>")
	playsound(user, 'aquila/sound/darkspawn/sacrament_begin.ogg', 50, FALSE)
	if(!do_after(user, 3 SECONDS, target = user))
		in_use = FALSE
		return FALSE
	var/image/alert_overlay = image('aquila/icons/mob/darkspawn/actions_darkspawn.dmi', "sacrament")
	notify_ghosts("Darkspawn [user.real_name] rozpoczął Sakrament w [get_area(user)]!", ghost_sound = 'aquila/sound/darkspawn/devour_will_victim.ogg', source = user, alert_overlay = alert_overlay, action = NOTIFY_ORBIT)
	user.visible_message("<span class='warning'>Wokół [user] wiruje fioletowa energia!</span>", "<span class='velvet'>Bariera cię ochroni.</span>")
	user.visible_message("<span class='danger'>[user] gwałtownie wzlatuje w powietrze, pulsując wrzeszczącym, fioletowym światłem.</span>", \
		"<span class='velvet big'><b>Rozpoczynasz Sakrament.</b></span>")
	soundloop = new(GLOB.player_list, TRUE, TRUE)
	for(var/turf/T in RANGE_TURFS(2, user))
		new /obj/structure/psionic_barrier(T, 340)
	for(var/stage in 1 to 2)
		soundloop.stage = stage
		switch(stage)
			if(1)
				user.visible_message("<span class='userdanger'>Sigile [user] wyją światłem. Kończyny wyginają się, a chitynę przecinają jarzące się pęknięcia.</span>", \
					"<span class='velvet'>Moc... <i>moc...</i> płynie przez ciebie, a sny i myśli tych, których dotknąłeś, szepczą ci do ucha...</span>")
				for(var/mob/M as anything in GLOB.player_list)
					M.playsound_local(M, 'aquila/sound/darkspawn/sacrament_01.ogg', 20, FALSE, pressure_affected = FALSE)
					if(M != user)
						to_chat(M, "<span class='warning'>Co to za dźwięk...?</span>")
			if(2)
				user.visible_message("<span class='userdanger'>[user] zaczyna... <i>rosnąć.</i></span>", \
					"<span class='velvet'>Tak! <font size=3>Tak! Czujesz, jak słaba, śmiertelna powłoka się rozpada!</font></span>")
				for(var/mob/M as anything in GLOB.player_list)
					M.playsound_local(M, 'aquila/sound/darkspawn/sacrament_02.ogg', 20, FALSE, pressure_affected = FALSE)
				animate(user, transform = matrix() * 2, time = 15 SECONDS)
		if(!do_after(user, 15 SECONDS, target = user))
			user.visible_message("<span class='warning'>[user] spada na ziemię!</span>", "<span class='userdanger'>Przemiana została przerwana!</span>")
			animate(user, transform = matrix(), pixel_y = initial(user.pixel_y), time = 3 SECONDS)
			in_use = FALSE
			QDEL_NULL(soundloop)
			return FALSE
	for(var/mob/M as anything in GLOB.player_list)
		M.playsound_local(M, 'aquila/sound/darkspawn/sacrament_ending.ogg', 75, FALSE, pressure_affected = FALSE)
	soundloop.stage = 3
	user.visible_message("<span class='userdanger'>[user] wznosi się w powietrze, trzeszcząc od mocy!</span>", "<span class='velvet bold'>A SŁABI POZNAJĄ <i>STRACH--</i></span>")
	for(var/turf/T in range(7, user))
		if(prob(25))
			addtimer(CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(darkspawn_unleashed_psi), T), rand(1, 40))
	addtimer(CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(darkspawn_shatter_lights), darkspawn.team), 3.5 SECONDS)
	QDEL_IN(soundloop, 3.9 SECONDS)
	soundloop = null
	animate(user, pixel_y = user.pixel_y + 20, time = 4 SECONDS)
	addtimer(CALLBACK(darkspawn, TYPE_PROC_REF(/datum/antagonist/darkspawn, sacrament)), 4 SECONDS)

/proc/darkspawn_unleashed_psi(turf/T)
	playsound(T, 'aquila/sound/darkspawn/divulge_end.ogg', 25, FALSE)
	new /obj/effect/temp_visual/revenant/cracks(T)

/proc/darkspawn_shatter_lights(datum/team/darkspawn/team)
	if(team?.sacrament_done)
		return
	for(var/obj/machinery/light/light in GLOB.machines)
		light.break_light_tube()
		CHECK_TICK

/// Na minutę zamienia w niewidoczny w ciemności cień, który przechodzi przez wentylację i drzwi
/datum/action/innate/darkspawn/crawling_shadows
	name = "Pełzające cienie"
	id = "crawling_shadows"
	desc = "Na minutę przybierasz cienistą postać, która przechodzi przez wentylację i szpary w drzwiach. Atakując ludzi, możesz ich ogłuszyć."
	button_icon_state = "crawling_shadows"
	check_flags = AB_CHECK_STUN | AB_CHECK_CONSCIOUS
	psi_cost = 60
	lucidity_price = 2

/datum/action/innate/darkspawn/crawling_shadows/IsAvailable()
	var/mob/living/L = owner
	if(!istype(L) || L.has_status_effect(/datum/status_effect/darkspawn_tagalong) || istype(L, /mob/living/simple_animal))
		return FALSE
	return ..()

/datum/action/innate/darkspawn/crawling_shadows/Activate()
	owner.visible_message("<span class='warning'>[owner] pada na ziemię i zamienia się w cienistą istotę!</span>", "<span class='velvet bold'>sa iahz sepd zwng</span>\n\
		<span class='notice'>Przybierasz bardziej skrytą postać.</span>")
	playsound(owner, 'aquila/sound/darkspawn/devour_will_end.ogg', 50, TRUE)
	var/mob/living/simple_animal/hostile/crawling_shadows/shadows = new(get_turf(owner))
	shadows.darkspawn_mob = owner
	shadows.check_darkspawn()
	return TRUE

/// Dopóki działa, chroni przed paleniem przez światło. Zżera 5 Psi na sekundę.
/datum/action/innate/darkspawn/creep
	name = "Całun"
	id = "creep"
	desc = "Dopóki działa, daje odporność na palenie przez światło. Włącza się i wyłącza. Zużywa 5 Psi na sekundę."
	button_icon_state = "creep"
	check_flags = AB_CHECK_CONSCIOUS
	psi_cost = 5
	psi_addendum = " na włączenie i na sekundę"
	lucidity_price = 2

/datum/action/innate/darkspawn/creep/IsAvailable()
	if(istype(owner, /mob/living/simple_animal))
		return FALSE
	return ..()

/datum/action/innate/darkspawn/creep/process()
	var/mob/living/L = owner
	active = istype(L) && L.has_status_effect(/datum/status_effect/darkspawn_creep)
	return ..()

/datum/action/innate/darkspawn/creep/Activate()
	var/mob/living/L = owner
	owner.visible_message("<span class='warning'>Wokół [owner] gęstnieją aksamitne cienie!</span>", "<span class='velvet'><b>odeahz</b><br>Zaczynasz osłaniać się Psi przed paleniem przez światło.</span>")
	playsound(owner, 'aquila/sound/darkspawn/devour_will_victim.ogg', 50, TRUE)
	L.apply_status_effect(/datum/status_effect/darkspawn_creep, darkspawn)
	active = TRUE
	return TRUE

/datum/action/innate/darkspawn/creep/Deactivate()
	var/mob/living/L = owner
	to_chat(owner, "<span class='velvet'>Puszczasz cienie.</span>")
	playsound(owner, 'aquila/sound/darkspawn/devour_will_end.ogg', 50, TRUE)
	L.remove_status_effect(/datum/status_effect/darkspawn_creep)
	active = FALSE
	return FALSE

/// Fala uderzeniowa, która odrzuca wszystko w pobliżu. Bliscy są ogłuszeni i głusi.
/datum/action/innate/darkspawn/demented_outburst
	name = "Obłąkany wybuch"
	id = "demented_outburst"
	desc = "Po pięciu sekundach ładowania ogłusza i dezorientuje słyszących, odrzucając wszystkich w pobliżu. Kosztuje 50 Psi."
	button_icon_state = "demented_outburst"
	check_flags = AB_CHECK_CONSCIOUS
	psi_cost = 50
	lucidity_price = 2

/datum/action/innate/darkspawn/demented_outburst/IsAvailable()
	if(istype(owner, /mob/living/simple_animal))
		return FALSE
	return ..()

/datum/action/innate/darkspawn/demented_outburst/Activate()
	in_use = TRUE
	owner.visible_message("<span class='boldwarning'>[owner] zaczyna warczeć, a chityna twardnieje...</span>", "<span class='velvet bold'>cap...</span><br>\
		<span class='danger'>Zaczynasz zbierać moc...</span>")
	playsound(owner, 'aquila/sound/darkspawn/demented_outburst_charge.ogg', 50, FALSE)
	addtimer(CALLBACK(src, PROC_REF(outburst)), 5 SECONDS)
	return TRUE

/datum/action/innate/darkspawn/demented_outburst/proc/outburst()
	in_use = FALSE
	if(!owner || owner.stat)
		return
	owner.visible_message("<span class='userdanger'>[owner] wydaje ogłuszający wrzask!</span>", "<span class='velvet bold italics'>WSWU!</span><br>\
		<span class='danger'>Wydajesz ogłuszający wrzask!</span>")
	playsound(owner, 'aquila/sound/darkspawn/demented_outburst_scream.ogg', 75, FALSE)
	var/list/thrown_atoms = list()
	for(var/turf/T in view(5, owner))
		for(var/atom/movable/AM in T)
			thrown_atoms += AM
	for(var/atom/movable/AM as anything in thrown_atoms)
		if(AM == owner || AM.anchored)
			continue
		var/distance = get_dist(owner, AM)
		var/turf/target = get_edge_target_turf(owner, get_dir(owner, get_step_away(AM, owner)))
		AM.throw_at(target, clamp(5 - clamp(distance - 2, 0, distance), 3, 5), 1, owner)
		if(iscarbon(AM))
			var/mob/living/carbon/C = AM
			if(distance <= 1)
				C.visible_message("<span class='warning'>Wybuch odrzuca [C]!</span>", "<span class='userdanger'>Siła odrzuca cię w powietrze!</span>")
				C.Paralyze(5 SECONDS)
				C.Knockdown(5 SECONDS)
				C.adjustBruteLoss(10)
				C.soundbang_act(1, 5, 15, 5)
			else if(distance <= 3)
				C.visible_message("<span class='warning'>Wybuch zbija [C] z nóg!</span>", "<span class='userdanger'>Siła cię przewraca!</span>")
				C.Paralyze(2.5 SECONDS)
				C.Knockdown(3 SECONDS)
				C.soundbang_act(1, 3, 5, 0)
		else if(iscyborg(AM))
			var/mob/living/silicon/robot/R = AM
			R.visible_message("<span class='warning'>Wybuch odrzuca [R]!</span>", "<span class='userdanger'>Siła odrzuca cię w powietrze!</span>")
			R.Paralyze(10 SECONDS)
			R.soundbang_act(1, 5, 15, 5)

/// Tworzy ciemny koralik, którym pożera się wolę człowieka
/datum/action/innate/darkspawn/devour_will
	name = "Pożarcie woli"
	id = "devour_will"
	desc = "Tworzy ciemny koralik. Użyty na człowieku w pełni odnawia Psi, daje jedną lucidity i pozbawia ofiarę przytomności. Ofiara jest unieruchomiona przez cały czas wysysania, a przerwanie przewraca was oboje. Kosztuje 5 Psi."
	button_icon_state = "devour_will"
	check_flags = AB_CHECK_RESTRAINED | AB_CHECK_STUN | AB_CHECK_LYING | AB_CHECK_CONSCIOUS
	psi_cost = 5
	blacklisted = TRUE
	/// Ofiary wyssane niedawno (TRUE) albo dawniej (FALSE)
	var/list/victims = list()
	/// ckey ostatniej ofiary; nie można jej wyssać dwa razy z rzędu
	var/last_victim

/datum/action/innate/darkspawn/devour_will/IsAvailable()
	if(!owner || istype(owner, /mob/living/simple_animal) || !length(owner.get_empty_held_indexes()))
		return FALSE
	return ..()

/datum/action/innate/darkspawn/devour_will/Activate()
	owner.visible_message("<span class='warning'>W dłoni [owner] pojawia się świecąca czarna kula!</span>", "<span class='velvet'><b>pwga...iejz</b><br>\
		Formujesz w dłoni ciemny koralik.</span>")
	playsound(owner, 'aquila/sound/darkspawn/devour_will_form.ogg', 50, TRUE)
	var/obj/item/dark_bead/bead = new
	owner.put_in_hands(bead)
	bead.linked_ability = src
	return TRUE

/datum/action/innate/darkspawn/devour_will/proc/make_eligible(mob/living/L)
	if(QDELETED(L) || !victims[L])
		return
	victims[L] = FALSE
	if(owner)
		to_chat(owner, "<span class='notice'>[L] doszedł do siebie po wyssaniu i znów jest podatny na Pożarcie woli.</span>")

/// Zamienia rękę w macki o wielu zastosowaniach
/datum/action/innate/darkspawn/pass
	name = "Przejście"
	id = "pass"
	desc = "Zamienia wolną rękę w macki o wielu zastosowaniach. Obejrzyj je, żeby zobaczyć listę."
	button_icon_state = "pass"
	check_flags = AB_CHECK_RESTRAINED | AB_CHECK_CONSCIOUS
	blacklisted = TRUE

/datum/action/innate/darkspawn/pass/IsAvailable()
	if(istype(owner, /mob/living/simple_animal) || (!length(owner?.get_empty_held_indexes()) && !active))
		return FALSE
	return ..()

/datum/action/innate/darkspawn/pass/process()
	active = !!(owner && (locate(/obj/item/umbral_tendrils) in owner))
	if(darkspawn?.has_upgrade("twin_tendrils"))
		name = "Podwójne przejście"
		desc = "Zamienia jedną albo obie ręce w macki o wielu zastosowaniach."
	return ..()

/datum/action/innate/darkspawn/pass/Activate()
	var/mob/living/carbon/C = owner
	if(!(C.mobility_flags & MOBILITY_STAND))
		to_chat(owner, "<span class='warning'>Najpierw wstań!</span>")
		return FALSE
	var/list/hands_free = owner.get_empty_held_indexes()
	if(!darkspawn.has_upgrade("twin_tendrils") || length(hands_free) < 2)
		owner.visible_message("<span class='warning'>Ręka [owner] wykrzywia się w macki!</span>", "<span class='velvet bold'>ikna</span><br>\
			<span class='notice'>Zamieniasz rękę w macki cienia. Obejrzyj je, żeby zobaczyć, do czego służą.</span>")
		playsound(owner, 'aquila/sound/darkspawn/pass_create.ogg', 50, TRUE)
		owner.put_in_hands(new /obj/item/umbral_tendrils(owner, darkspawn))
	else
		owner.visible_message("<span class='warning'>Ręce [owner] wykrzywiają się w macki!</span>", "<span class='velvet'><b>ikna ikna</b><br>\
			Zamieniasz obie ręce w macki cienia. Obejrzyj je, żeby zobaczyć, do czego służą.</span>")
		playsound(owner, 'aquila/sound/darkspawn/pass_create.ogg', 50, TRUE)
		addtimer(CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(playsound), owner, 'aquila/sound/darkspawn/pass_create.ogg', 50, TRUE), 1)
		for(var/i in 1 to 2)
			owner.put_in_hands(new /obj/item/umbral_tendrils(owner, darkspawn))
	active = TRUE
	return TRUE

/datum/action/innate/darkspawn/pass/Deactivate()
	owner.visible_message("<span class='warning'>Macki [owner] wracają do dawnej postaci!</span>", "<span class='velvet bold'>haoo</span><br>\
		<span class='notice'>Rozpraszasz macki.</span>")
	playsound(owner, 'aquila/sound/darkspawn/pass_dispel.ogg', 50, TRUE)
	for(var/obj/item/umbral_tendrils/T in owner)
		qdel(T)
	active = FALSE
	return FALSE

/// Przy konsoli komunikacyjnej odwołuje prom. Zostawia ślady.
/datum/action/innate/darkspawn/silver_tongue
	name = "Srebrny język"
	id = "silver_tongue"
	desc = "Przy konsoli komunikacyjnej pozwala siłą przesłać do Centrali wiadomość, która odwołuje prom ratunkowy. Działa tylko, gdy prom jest w drodze. Kosztuje 60 Psi."
	button_icon_state = "silver_tongue"
	check_flags = AB_CHECK_CONSCIOUS | AB_CHECK_STUN
	psi_cost = 60
	lucidity_price = 1

/datum/action/innate/darkspawn/silver_tongue/IsAvailable()
	if(SSshuttle.emergency.mode != SHUTTLE_CALL)
		return FALSE
	return ..()

/datum/action/innate/darkspawn/silver_tongue/Activate()
	set waitfor = FALSE
	var/obj/machinery/computer/communications/C = locate() in range(1, owner)
	if(!C)
		to_chat(owner, "<span class='warning'>W pobliżu nie ma konsoli komunikacyjnej.</span>")
		return FALSE
	if(C.machine_stat & (NOPOWER|BROKEN))
		to_chat(owner, "<span class='warning'>[C] nie ma zasilania.</span>")
		return FALSE
	if(!darkspawn.use_psi(psi_cost))
		return FALSE
	in_use = TRUE
	owner.visible_message("<span class='warning'>[owner] dotyka ekranu [C], a klawisze zaczynają ruszać się same!</span>", \
		"<span class='velvet bold'>[pick("Oknnu. Pda ywlpwej swo hkccaz ej.", "Pda aiancajyu eo kran. Oknnu bkn swopejc ukqn peia.", "We swo knzanaz xu Hws Psk. Whh ckkz jks.")]</span><br>\
		<span class='velvet'>Zaczynasz przesyłać do Centrali wiadomość odwołującą prom...</span>")
	play_recall_sounds(C)
	if(!do_after(owner, 8 SECONDS, target = C))
		in_use = FALSE
		return FALSE
	in_use = FALSE
	if(QDELETED(C) || (C.machine_stat & (NOPOWER|BROKEN)))
		to_chat(owner, "<span class='warning'>[C] straciła zasilanie.</span>")
		return FALSE
	SSshuttle.emergency.cancel()
	to_chat(owner, "<span class='velvet'>Podstęp się udał. Prom zawraca.</span>")
	return FALSE // Psi już pobrane na początku

/datum/action/innate/darkspawn/silver_tongue/proc/play_recall_sounds(obj/machinery/C)
	set waitfor = FALSE
	for(var/i in 1 to 4)
		sleep(1 SECONDS)
		if(QDELETED(C) || (C.machine_stat & (NOPOWER|BROKEN)))
			return
		playsound(C, "terminal_type", 50, TRUE)
		if(prob(25))
			playsound(C, 'sound/machines/terminal_alert.ogg', 50, FALSE)
			do_sparks(5, TRUE, get_turf(C))
	playsound(C, 'sound/machines/terminal_prompt.ogg', 50, FALSE)
	sleep(0.5 SECONDS)
	if(QDELETED(C) || (C.machine_stat & (NOPOWER|BROKEN)))
		return
	playsound(C, 'sound/machines/terminal_prompt_confirm.ogg', 50, FALSE)

/// Iluzja darkspawna, która przez dziesięć sekund biegnie przed siebie
/datum/action/innate/darkspawn/simulacrum
	name = "Symulakrum"
	id = "simulacrum"
	desc = "Tworzy iluzję łudząco podobną do ciebie. Przez dziesięć sekund biegnie przed siebie. Kosztuje 20 Psi."
	button_icon_state = "simulacrum"
	check_flags = AB_CHECK_CONSCIOUS
	psi_cost = 20
	lucidity_price = 1

/datum/action/innate/darkspawn/simulacrum/Activate()
	if(isliving(owner.loc))
		var/mob/living/L = owner.loc
		L.visible_message("<span class='warning'>[owner] odrywa się od cienia [L]!</span>", \
			"<span class='userdanger'>Czujesz, jak przenika cię lodowaty chłód!</span>")
		to_chat(owner, "<span class='velvet'><b>zayaera</b><br>Tworzysz swoją iluzję.</span>")
	else
		owner.visible_message("<span class='warning'>[owner] rozdziela się na dwoje!</span>", \
			"<span class='velvet'><b>zayaera</b><br>Tworzysz swoją iluzję.</span>")
	playsound(owner, 'aquila/sound/darkspawn/devour_will_form.ogg', 50, TRUE)
	var/obj/effect/simulacrum/simulacrum = new(get_turf(owner))
	simulacrum.mimic(owner)
	return TRUE

/// Wtapia się w cień celu i niewidocznie za nim podąża, dopóki ten jest w świetle
/datum/action/innate/darkspawn/tagalong
	name = "Wtopienie w cień"
	id = "tagalong"
	desc = "Wtapiasz się w cień celu i niewidocznie za nim podążasz. Działa tylko w oświetlonych miejscach, a wzięcie czegoś do ręki cię wyrzuci. Kosztuje 30 Psi."
	button_icon_state = "tagalong"
	check_flags = AB_CHECK_CONSCIOUS
	psi_cost = 30
	psi_addendum = ", ale przerwanie jest darmowe"
	lucidity_price = 2
	var/datum/status_effect/darkspawn_tagalong/tagalong

/datum/action/innate/darkspawn/tagalong/IsAvailable()
	if(istype(owner, /mob/living/simple_animal))
		return FALSE
	return ..()

/datum/action/innate/darkspawn/tagalong/process()
	if(QDELETED(tagalong))
		tagalong = null
	psi_cost = tagalong ? 0 : 30
	return ..()

/datum/action/innate/darkspawn/tagalong/Activate()
	if(tagalong)
		QDEL_NULL(tagalong)
		return FALSE
	if(owner.get_active_held_item() || owner.get_inactive_held_item())
		to_chat(owner, "<span class='warning'>Musisz mieć puste ręce, żeby komuś towarzyszyć!</span>")
		return FALSE
	var/list/targets = list()
	for(var/mob/living/L in range(7, owner) - owner)
		var/turf/T = get_turf(L)
		if(!isdarkspawn(L) && L.stat != DEAD && T.get_lumcount() >= DARKSPAWN_DIM_LIGHT)
			targets += L
	if(!length(targets))
		to_chat(owner, "<span class='warning'>W pobliżu nie ma nikogo w oświetlonym miejscu!</span>")
		return FALSE
	var/mob/living/target
	if(length(targets) == 1)
		target = targets[1]
	else
		target = input(owner, "Komu chcesz towarzyszyć?", name) as null|anything in targets
		if(!target || QDELETED(src))
			return FALSE
	// Okno wyboru mogło wisieć długo, więc wszystko sprawdzamy jeszcze raz
	if(QDELETED(target) || target.stat == DEAD || !(target in range(7, owner)) || owner.stat || tagalong)
		return FALSE
	var/turf/target_turf = get_turf(target)
	if(!target_turf || target_turf.get_lumcount() < DARKSPAWN_DIM_LIGHT)
		to_chat(owner, "<span class='warning'>[target] nie stoi już w świetle!</span>")
		return FALSE
	if(owner.get_active_held_item() || owner.get_inactive_held_item())
		to_chat(owner, "<span class='warning'>Musisz mieć puste ręce, żeby komuś towarzyszyć!</span>")
		return FALSE
	var/mob/living/L = owner
	tagalong = L.apply_status_effect(/datum/status_effect/darkspawn_tagalong, target)
	if(!tagalong)
		return FALSE
	to_chat(owner, "<span class='velvet'><b>iahz</b><br>Wślizgujesz się w cień [target]. Potrwa to pięć minut, aż przerwiesz albo zostaniesz wyrzucony.</span>")
	owner.forceMove(target)
	return TRUE

/// Bardzo przyspiesza odruchy i działania za dużo Psi
/datum/action/innate/darkspawn/time_dilation
	name = "Dylatacja czasu"
	id = "time_dilation"
	desc = "Znacznie skraca czas reakcji i przyspiesza działania, a do tego daje odporność na spowolnienie. Trwa minutę. Kosztuje 75 Psi."
	button_icon_state = "time_dilation"
	check_flags = AB_CHECK_CONSCIOUS
	psi_cost = 75
	lucidity_price = 3

/datum/action/innate/darkspawn/time_dilation/IsAvailable()
	var/mob/living/L = owner
	if(!istype(L) || istype(L, /mob/living/simple_animal) || L.has_status_effect(/datum/status_effect/darkspawn_time_dilation))
		return FALSE
	return ..()

/datum/action/innate/darkspawn/time_dilation/Activate()
	var/mob/living/L = owner
	L.apply_status_effect(/datum/status_effect/darkspawn_time_dilation)
	L.visible_message("<span class='warning'>[L] wyje, a ciało porusza się z dziką prędkością!</span>", \
		"<span class='velvet'><b>ckppw ck bwop</b><br>Twoje sigile wyją światłem, a ciało porusza się z niewiarygodną prędkością!</span>")
	playsound(L, 'aquila/sound/darkspawn/darkspawn_howl.ogg', 50, TRUE)
	return TRUE

/// Zamienia pobliskie, świeżo wyssane osoby w welony. Pozostałych dezorientuje, a borgi ogłusza.
/datum/action/innate/darkspawn/veil_mind
	name = "Zasłona umysłu"
	id = "veil_mind"
	desc = "Zamienia pobliskie osoby w welony. Muszą żyć i być niedawno wyssane Pożarciem woli."
	button_icon_state = "veil_mind"
	check_flags = AB_CHECK_STUN | AB_CHECK_CONSCIOUS
	psi_cost = 60
	lucidity_price = 2

/datum/action/innate/darkspawn/veil_mind/Activate()
	set waitfor = FALSE
	var/mob/living/carbon/human/H = owner
	if(!istype(H) || !H.can_speak_vocal())
		to_chat(owner, "<span class='warning'>Nie możesz mówić!</span>")
		return FALSE
	if(in_use)
		return FALSE
	owner.visible_message("<span class='warning'>Sigile [owner] rozbłyskują, gdy bierze wdech...</span>", "<span class='velvet bold'>dawn kqn okjc...</span><br>\
		<span class='notice'>Bierzesz głęboki wdech...</span>")
	playsound(owner, 'aquila/sound/darkspawn/veil_mind_gasp.ogg', 25)
	in_use = TRUE
	if(!do_after(owner, 1 SECONDS, target = owner))
		in_use = FALSE
		return FALSE
	in_use = FALSE
	if(!darkspawn.use_psi(psi_cost))
		return FALSE
	owner.visible_message("<span class='boldwarning'>[owner] wydaje mrożący krew w żyłach krzyk!</span>", "<span class='velvet bold'>...wjz oanra</span><br>\
		<span class='notice'>Zasłaniasz umysły wszystkich w pobliżu.</span>")
	playsound(owner, 'aquila/sound/darkspawn/veil_mind_scream.ogg', 100)
	for(var/mob/living/L in view(3, owner))
		if(L == owner)
			continue
		if(issilicon(L))
			to_chat(L, "<span class='userdanger'>$@!) ERR: PRZECIĄŻENIE RECEPTORÓW ^!</</span>")
			SEND_SOUND(L, sound('sound/misc/interference.ogg', volume = 50))
			L.emote("alarm")
			L.Stun(2 SECONDS)
			L.overlay_fullscreen("flash", /atom/movable/screen/fullscreen/flash/static)
			L.clear_fullscreen("flash", 10)
		else if(HAS_TRAIT(L, TRAIT_DEAF))
			to_chat(L, "<span class='warning'>...ale nic nie słyszysz!</span>")
		else if(L.has_status_effect(/datum/status_effect/broken_will))
			if(L.add_veil())
				to_chat(owner, "<span class='velvet'><b>[L.real_name]</b> stał się welonem!</span>")
		else
			to_chat(L, "<span class='boldwarning'>...i miesza ci w myślach!</span>")
			L.setDir(pick(GLOB.cardinals))
			L.confused += 2
	return FALSE // Psi pobrane po wdechu
