/mob/living/Initialize(mapload)
	. = ..()
	if(CONFIG_GET(flag/shitting_enabled))
		set_defecation(rand(DEFECATION_NONE, DEFECATION_SOMEWHAT))

///Adjust the need to defecate of a mob
/mob/living/proc/adjust_defecation(var/change)
	defecation = max(0, defecation + change)

///Force set the mob need to defecate
/mob/living/proc/set_defecation(var/change)
	defecation = max(0, change)

/mob/living/proc/actually_shit_myself()
	if(!CONFIG_GET(flag/shitting_enabled))
		return FALSE
	visible_message(
		"<span class='warning'>[src] się zesrał[gender == FEMALE ? "a" : ""]!</span>",
		"<span class='warning'>Zesrał[gender == FEMALE ? "aś" : "eś"] się!</span>")

	// update disgust for viewers
	for(var/mob/living/L in viewers(7, get_turf(src)))
		L.adjust_disgust(DISGUST_LEVEL_VERYGROSS)

	playsound(get_turf(src), 'aquila/sound/creatures/fart.ogg', 100, TRUE)
	new /obj/effect/decal/cleanable/feces(get_turf(src))
	return TRUE

/mob/living/carbon/human/actually_shit_myself()
	. = ..()
	if(.)
		set_hygiene(HYGIENE_LEVEL_DISGUSTING)
	set_hydration(rand(HYDRATION_LEVEL_START_MIN, HYDRATION_LEVEL_START_MAX))

///Adjust the thirst of a mob
/mob/living/proc/adjust_hydration(var/change)
	hydration = max(0, hydration + change)

///Force set the mob thirst
/mob/living/proc/set_hydration(var/change)
	hydration = max(0, change)
