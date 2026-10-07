// Gas mask breathing sound is only audible while the wearer is actually breathing from internals
/datum/looping_sound/gasmask/play(soundfile)
	var/mob/living/carbon/C = parent?.loc
	if(!istype(C) || !C.internal || C.stat == DEAD)
		return
	return ..()
