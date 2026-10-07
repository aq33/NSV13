/mob/living/carbon/human/adjust_defecation(var/change)
	if(HAS_TRAIT(src, TRAIT_NOSHITTING)) // i ain't got shit
		return FALSE
	return ..()

/mob/living/carbon/human/set_defecation(var/change)
	if(HAS_TRAIT(src, TRAIT_NOSHITTING))
		return FALSE
	return ..()

/mob/living/carbon/human/adjust_hydration(var/change)
	if(HAS_TRAIT(src, TRAIT_NOTHIRST))
		return FALSE
	return ..()

/mob/living/carbon/human/set_hydration(var/change)
	if(HAS_TRAIT(src, TRAIT_NOTHIRST))
		return FALSE
	return ..()

/mob/living/carbon/human/Initialize(mapload)
	. = ..()
	if(!istype(src, /mob/living/carbon/human/dummy)) // podgląd postaci kopiuje appearance manekina, a z nim ukryty render_target
		AddComponent(/datum/component/walk_animation)
