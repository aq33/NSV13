
/mob/living/carbon/human/adjust_defecation(var/change)
	if(HAS_TRAIT(src, TRAIT_NOSHITTING)) // i ain't got shit
		return FALSE
	return ..()

/mob/living/carbon/human/set_defecation(var/change)
	if(HAS_TRAIT(src, TRAIT_NOSHITTING))
		return FALSE
	return ..()
