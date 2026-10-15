//Ranged
/obj/item/projectile/guardian
	name = "crystal spray"
	icon_state = "guardian"
	damage = 5
	damage_type = BRUTE
	armour_penetration = 100

/mob/living/simple_animal/hostile/guardian/ranged
	combat_mode = FALSE
	friendly = "po cichu ocenia"
	melee_damage = 10
	damage_coeff = list(BRUTE = 0.9, BURN = 0.9, TOX = 0.9, CLONE = 0.9, STAMINA = 0, OXY = 0.9)
	projectiletype = /obj/item/projectile/guardian
	ranged_cooldown_time = 1 //fast!
	projectilesound = 'sound/effects/hit_on_shattered_glass.ogg'
	ranged = 1
	range = 13
	playstyle_string = "<span class='holoparasite'>Jako typ <b>ranged</b> masz tylko niewielką odporność na obrażenia, ale potrafisz z ogromną prędkością wystrzeliwać odłamki kryształu. Możesz też rozstawiać sidła obserwacyjne, by śledzić ruchy wrogów. Wreszcie możesz przejść w tryb zwiadowczy, w którym nie możesz atakować, ale poruszasz się bez ograniczeń.</span>"
	magic_fluff_string = "<span class='holoparasite'>...I wyciągasz Wartownika, obcego mistrza walki dystansowej.</span>"
	tech_fluff_string = "<span class='holoparasite'>Sekwencja startowa zakończona. Moduły walki dystansowej aktywne. Rój holoparazytów aktywny.</span>"
	carp_fluff_string = "<span class='holoparasite'>KARP KARP KARP! Złowiony! To karp dystansowy. Ta rybka widzi, jak ludzie sikają do oceanu.</span>"
	hive_fluff_string = "<span class='holoparasite'>Masa wydaje się zdolna tworzyć więcej masy i ukrywać się do woli.</span>"
	see_invisible = SEE_INVISIBLE_LIVING
	see_in_dark = 8
	toggle_button_type = /atom/movable/screen/guardian/ToggleMode
	var/list/snares = list()
	var/toggle = FALSE

/mob/living/simple_animal/hostile/guardian/ranged/ToggleMode()
	if(src.loc == summoner)
		if(toggle)
			ranged = initial(ranged)
			melee_damage = initial(melee_damage)
			obj_damage = initial(obj_damage)
			environment_smash = initial(environment_smash)
			alpha = 255
			range = initial(range)
			to_chat(src, "<span class='danger'><B>Przełączasz się w tryb bojowy.</span></B>")
			toggle = FALSE
		else
			ranged = 0
			melee_damage = 0
			obj_damage = 0
			environment_smash = ENVIRONMENT_SMASH_NONE
			alpha = 45
			range = 255
			to_chat(src, "<span class='danger'><B>Przełączasz się w tryb zwiadowczy.</span></B>")
			toggle = TRUE
	else
		to_chat(src, "<span class='danger'><B>Musisz wrócić do użytkownika, by zmienić tryb!</span></B>")

/mob/living/simple_animal/hostile/guardian/ranged/Shoot(atom/targeted_atom)
	. = ..()
	if(istype(., /obj/item/projectile))
		var/obj/item/projectile/P = .
		if(guardiancolor)
			P.color = guardiancolor

/mob/living/simple_animal/hostile/guardian/ranged/ToggleLight()
	var/msg
	switch(lighting_alpha)
		if (LIGHTING_PLANE_ALPHA_VISIBLE)
			lighting_alpha = LIGHTING_PLANE_ALPHA_MOSTLY_VISIBLE
			msg = "Włączasz noktowizję."
		if (LIGHTING_PLANE_ALPHA_MOSTLY_VISIBLE)
			lighting_alpha = LIGHTING_PLANE_ALPHA_MOSTLY_INVISIBLE
			msg = "Zwiększasz noktowizję."
		if (LIGHTING_PLANE_ALPHA_MOSTLY_INVISIBLE)
			lighting_alpha = LIGHTING_PLANE_ALPHA_INVISIBLE
			msg = "Maksymalizujesz noktowizję."
		else
			lighting_alpha = LIGHTING_PLANE_ALPHA_VISIBLE
			msg = "Wyłączasz noktowizję."

	to_chat(src, "<span class='notice'>[msg]</span>")


/mob/living/simple_animal/hostile/guardian/ranged/verb/Snare()
	set name = "Set Surveillance Snare"
	set category = "Guardian"
	set desc = "Set an invisible snare that will alert you when living creatures walk over it. Max of 5"
	if(src.snares.len <6)
		var/turf/snare_loc = get_turf(src.loc)
		var/obj/effect/snare/S = new /obj/effect/snare(snare_loc)
		S.spawner = src
		S.name = "[get_area(snare_loc)] snare ([rand(1, 1000)])"
		src.snares |= S
		to_chat(src, "<span class='danger'><B>Sidła obserwacyjne rozstawione!</span></B>")
	else
		to_chat(src, "<span class='danger'><B>Masz rozstawionych za dużo sideł. Najpierw usuń niektóre.</span></B>")

/mob/living/simple_animal/hostile/guardian/ranged/verb/DisarmSnare()
	set name = "Remove Surveillance Snare"
	set category = "Guardian"
	set desc = "Disarm unwanted surveillance snares."
	var/picked_snare = input(src, "Wybierz sidła do usunięcia", "Usuń sidła") as null|anything in sortNames(src.snares)
	if(picked_snare)
		src.snares -= picked_snare
		qdel(picked_snare)
		to_chat(src, "<span class='danger'><B>Sidła rozbrojone.</span></B>")

/obj/effect/snare
	name = "snare"
	desc = "You shouldn't be seeing this!"
	var/mob/living/simple_animal/hostile/guardian/spawner
	invisibility = INVISIBILITY_ABSTRACT

/obj/effect/snare/Initialize(mapload)
	. = ..()
	var/static/list/loc_connections = list(
		COMSIG_ATOM_ENTERED = PROC_REF(on_entered),
	)
	AddElement(/datum/element/connect_loc, loc_connections)

/obj/effect/snare/proc/on_entered(datum/source, AM as mob|obj)
	SIGNAL_HANDLER

	if(isliving(AM) && spawner && spawner.summoner && AM != spawner && !spawner.hasmatchingsummoner(AM))
		to_chat(spawner.summoner, "<span class='danger'><B>[AM] przechodzi przez sidła obserwacyjne [name].</span></B>")
		var/list/guardians = spawner.summoner.hasparasites()
		for(var/para in guardians)
			to_chat(para, "<span class='danger'><B>[AM] przechodzi przez sidła obserwacyjne [name].</span></B>")

/obj/effect/snare/singularity_act()
	return

/obj/effect/snare/singularity_pull()
	return

/mob/living/simple_animal/hostile/guardian/ranged/Manifest(forced)
	if (toggle)
		incorporeal_move = INCORPOREAL_MOVE_BASIC
	. = ..()

/mob/living/simple_animal/hostile/guardian/ranged/Recall(forced)
	// To stop scout mode from moving when recalled
	incorporeal_move = FALSE
	. = ..()
