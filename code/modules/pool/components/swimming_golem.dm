/datum/component/swimming/golem/enter_pool()
	var/mob/living/M = parent
	M.Paralyze(60)
	M.visible_message("<span class='warning'>[M] gwałtownie uderza o ziemię!</span>",
		"<span class='warning'>Toniesz jak kamień!</span>")
	playsound(get_turf(M), 'sound/effects/picaxe1.ogg')

/datum/component/swimming/golem/is_drowning()
	return FALSE
