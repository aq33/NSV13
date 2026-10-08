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

// The "Polak" belly hides under clothes covering the chest, so redraw the body when they change
/mob/living/carbon/human/update_inv_w_uniform()
	. = ..()
	if(dna?.features["body_size"] == "Polak")
		update_body()

/mob/living/carbon/human/update_inv_wear_suit()
	. = ..()
	if(dna?.features["body_size"] == "Polak")
		update_body()
