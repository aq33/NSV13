///Adjust the need to defecate of a mob
/mob/living/proc/adjust_defecation(var/change)
	defecation = max(0, nutrition + change)

///Force set the mob need to defecate
/mob/living/proc/set_defecation(var/change)
	defecation = max(0, change)
