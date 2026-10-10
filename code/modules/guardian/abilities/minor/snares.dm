/datum/guardian_ability/minor/snare
	name = "Surveillance Snares"
	desc = "The guardian can lay a surveillance snare, which alerts the guardian and the user to anyone who crosses it."
	ui_icon = "exclamation-triangle"
	cost = 1

/datum/guardian_ability/minor/snare/Apply()
	guardian.add_verb(/mob/living/simple_animal/hostile/guardian/proc/Snare)
	guardian.add_verb(/mob/living/simple_animal/hostile/guardian/proc/DisarmSnare)

/datum/guardian_ability/minor/snare/Remove()
	guardian.remove_verb(/mob/living/simple_animal/hostile/guardian/proc/Snare)
	guardian.remove_verb(/mob/living/simple_animal/hostile/guardian/proc/DisarmSnare)

/mob/living/simple_animal/hostile/guardian/proc/Snare()
	set name = "Set Surveillance Snare"
	set category = "Guardian"
	set desc = "Set an invisible snare that will alert you when living creatures walk over it. Max of 5"
	if(!can_use_abilities)
		to_chat(src, "<span class='danger'><B>Nie możesz tego teraz zrobić!</span></B>")
		return
	if(snares.len <6)
		var/turf/snare_loc = get_turf(src.loc)
		var/obj/effect/snare/S = new /obj/effect/snare(snare_loc)
		S.spawner = src
		S.name = "[get_area(snare_loc)] snare ([rand(1, 1000)])"
		snares |= S
		to_chat(src, "<span class='danger'><B>Rozstawiono sidła obserwacyjne!</span></B>")
	else
		to_chat(src, "<span class='danger'><B>Masz rozstawionych za dużo sideł. Najpierw usuń część.</span></B>")

/mob/living/simple_animal/hostile/guardian/proc/DisarmSnare()
	set name = "Remove Surveillance Snare"
	set category = "Guardian"
	set desc = "Disarm unwanted surveillance snares."
	var/picked_snare = input(src, "Wybierz sidła do usunięcia", "Usuń sidła") as null|anything in src.snares
	if(picked_snare)
		snares -= picked_snare
		qdel(picked_snare)
		to_chat(src, "<span class='danger'><B>Sidła rozbrojone.</span></B>")

// the snare

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

	if(isliving(AM) && spawner && spawner?.summoner?.current && AM != spawner && !spawner.hasmatchingsummoner(AM))
		to_chat(spawner.summoner.current, "<span class='danger'><B>[AM] przekroczył sidła obserwacyjne [name].</span></B>")
		var/list/guardians = spawner.summoner.current.hasparasites()
		for(var/para in guardians)
			to_chat(para, "<span class='danger'><B>[AM] przekroczył sidła obserwacyjne [name].</span></B>")

/obj/effect/snare/singularity_act()
	return

/obj/effect/snare/singularity_pull()
	return
