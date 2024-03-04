/mob/living/Initialize(mapload)
	. = ..()
	set_hydration(rand(HYDRATION_LEVEL_START_MIN, HYDRATION_LEVEL_START_MAX))

///Adjust the thirst of a mob
/mob/living/proc/adjust_hydration(var/change)
	hydration = max(0, hydration + change)

///Force set the mob thirst
/mob/living/proc/set_hydration(var/change)
	hydration = max(0, change)
