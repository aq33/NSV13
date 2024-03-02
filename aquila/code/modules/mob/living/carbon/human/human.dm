/mob/living/carbon/human/adjust_defecation(var/change)
	if(HAS_TRAIT(src, TRAIT_NOSHITTING)) // i ain't got shit
		return FALSE
	return ..()

/mob/living/carbon/human/set_defecation(var/change)
	if(HAS_TRAIT(src, TRAIT_NOSHITTING))

/mob/living/carbon/human/adjust_hydration(var/change)
	if(HAS_TRAIT(src, TRAIT_NOTHIRST))
		return FALSE
	return ..()

/mob/living/carbon/human/set_hydration(var/change)
	if(HAS_TRAIT(src, TRAIT_NOTHIRST))
		return FALSE
	return ..()
