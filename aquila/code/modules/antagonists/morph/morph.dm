/mob/living/simple_animal/hostile/morph
	playable = TRUE

/mob/living/simple_animal/hostile/morph/Initialize(mapload)
	. = ..()
	find_candidates()

/mob/living/simple_animal/hostile/morph/attack_ghost(mob/dead/observer/user)
	. = ..()
	give_to_ghost(user)
