/mob/proc/adjust_hydration(var/change)
	if(HAS_TRAIT(src, TRAIT_NOTHIRST))
		return FALSE
	return ..()

/mob/proc/set_hydration(var/change)
	if(HAS_TRAIT(src, TRAIT_NOTHIRST))
		return FALSE
	return ..()
