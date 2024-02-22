
///Adjust the thirst of a mob
/mob/proc/adjust_hydration(var/change)
	thirst = max(0, thirst + change)

///Force set the mob thirst
/mob/proc/set_hydration(var/change)
	thirst = max(0, change)
