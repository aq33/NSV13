// Sidepaths for knowledge between Ash and Flesh.
/datum/heretic_knowledge/medallion
	name = "Ashen Eyes"
	desc = "Allows you to transmute a pair of eyes, a candle, and a glass shard into an Eldritch Medallion. \
		The Eldritch Medallion grants you thermal vision while worn, and also functions as a focus."
	gain_text = "Przenikliwe oczy prowadziły ich przez codzienność. Ani ciemność, ani groza nie mogły ich zatrzymać."
	next_knowledge = list(
		/datum/heretic_knowledge/spell/ash_passage,
		/datum/heretic_knowledge/limited_amount/flesh_ghoul,
	)
	required_atoms = list(
		/obj/item/organ/eyes = 1,
		/obj/item/shard = 1,
		/obj/item/candle = 1,
	)
	result_atoms = list(/obj/item/clothing/neck/eldritch_amulet)
	cost = 1
	route = HERETIC_PATH_SIDE

/datum/heretic_knowledge/curse/paralysis
	name = "Curse of Paralysis"
	desc = "Allows you to transmute a hatchet, a left and right leg, \
		and an item containing fingerprints to cast a curse of immobility \
		on one of the fingerprints' owners for five minutes. While cursed, \
		the victim will be unable to walk."
	gain_text = "Ludzkie ciało jest słabe. Niech krwawią. Pokaż im, jak są kruche."
	next_knowledge = list(
		/datum/heretic_knowledge/mad_mask,
		/datum/heretic_knowledge/summon/raw_prophet,
	)
	required_atoms = list(
		/obj/item/bodypart/l_leg = 1,
		/obj/item/bodypart/r_leg = 1,
		/obj/item/hatchet = 1,
	)
	duration = 5 MINUTES
	cost = 1
	route = HERETIC_PATH_SIDE

/datum/heretic_knowledge/curse/paralysis/curse(mob/living/carbon/human/chosen_mob)
	if(chosen_mob.get_num_legs() <= 0) // What're you gonna do, curse someone who already can't walk?
		to_chat(chosen_mob, "<span class='notice'>Przez chwilę czujesz lekki ból, ale szybko mija. Dziwne.</span>")
	else
		to_chat(chosen_mob, "<span class='danger'>Nagle tracisz czucie w [chosen_mob.get_num_legs() == 1 ? "nodze":"nogach"]!</span>")

	ADD_TRAIT(chosen_mob, TRAIT_PARALYSIS_L_LEG, type)
	ADD_TRAIT(chosen_mob, TRAIT_PARALYSIS_R_LEG, type)

/datum/heretic_knowledge/curse/paralysis/uncurse(mob/living/carbon/human/chosen_mob)
	REMOVE_TRAIT(chosen_mob, TRAIT_PARALYSIS_L_LEG, type)
	REMOVE_TRAIT(chosen_mob, TRAIT_PARALYSIS_R_LEG, type)

	if(chosen_mob.get_num_legs() <= 0) // What're you gonna do, curse someone who already can't walk?
		to_chat(chosen_mob, "<span class='notice'>Lekki ból wraca, ale szybko ustępuje.</span>")
	else
		to_chat(chosen_mob, "<span class='notice'>Odzyskujesz czucie w [chosen_mob.get_num_legs() == 1 ? "nodze":"nogach"]!</span>")

/datum/heretic_knowledge/summon/ashy
	name = "Ashen Ritual"
	desc = "Allows you to transmute a head, a pile of ash, and a book to create an Ash Man. \
		Ash Men have a short range jaunt and the ability to cause bleeding in foes at range. \
		They also have the ability to create a ring of fire around themselves for a length of time."
	gain_text = "Połączyłem swoją zasadę głodu z żądzą zniszczenia. Marszałek znał moje imię, a Nocny Strażnik patrzył."
	next_knowledge = list(
		/datum/heretic_knowledge/summon/stalker,
		/datum/heretic_knowledge/spell/flame_birth,
	)
	required_atoms = list(
		/obj/effect/decal/cleanable/ash = 1,
		/obj/item/bodypart/head = 1,
		/obj/item/book = 1,
		)
	mob_to_summon = /mob/living/simple_animal/hostile/heretic_summon/ash_spirit
	cost = 1
	route = HERETIC_PATH_SIDE

/datum/heretic_knowledge/summon/ashy/cleanup_atoms(list/selected_atoms)
	var/obj/item/bodypart/head/ritual_head = locate() in selected_atoms
	if(!ritual_head)
		CRASH("[type] required a head bodypart, yet did not have one in selected_atoms when it reached cleanup_atoms.")

	// Spill out any brains or stuff before we delete it.
	ritual_head.drop_organs()
	return ..()
