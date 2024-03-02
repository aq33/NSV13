/mob/living/simple_animal/hostile/macrophage/proc/InitializeSkin()
	for(var/datum/disease/advance/A in infections)
		for(var/datum/symptom/S in A.symptoms)
			if(istype(S, /datum/symptom/flesh))//yes, we do a check for if we have exolocomotive xenomitosis just to turn the phage pink
				if(istype(src, /mob/living/simple_animal/hostile/macrophage/aggro))
					icon_state = "pinkvirus_large"
				else
					icon_state = "pinkvirus_small"
				break

