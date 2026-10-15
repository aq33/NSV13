/mob/living/Initialize(mapload)
	. = ..()
	set_hydration(rand(HYDRATION_LEVEL_START_MIN, HYDRATION_LEVEL_START_MAX))
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
		"<span class='warning'>[src] popuścił[gender == FEMALE ? "a" : ""] w spodnie!</span>",
		"<span class='warning'>Popuścił[gender == FEMALE ? "aś" : "eś"] w spodnie!</span>")

	// update disgust for viewers
	for(var/mob/living/L in viewers(7, get_turf(src)))
		L.adjust_disgust(DISGUST_LEVEL_VERYGROSS)

	playsound(get_turf(src), 'aquila/sound/creatures/fart.ogg', 100, TRUE)
	new /obj/effect/decal/cleanable/feces(get_turf(src))
	var/datum/reagent/consumable/castor_oil/oil = reagents?.get_reagent(/datum/reagent/consumable/castor_oil)
	oil?.purge(src)
	return TRUE

/mob/living/carbon/human/actually_shit_myself()
	. = ..()
	if(.)
		set_hygiene(HYGIENE_LEVEL_DISGUSTING)

///Adjust the thirst of a mob
/mob/living/proc/adjust_hydration(var/change)
	hydration = max(0, hydration + change)

///Force set the mob thirst
/mob/living/proc/set_hydration(var/change)
	hydration = max(0, change)

// Szarpnięcie przy ogłuszeniu pałką: port z BeeStation-Hornet (code/modules/mob/living/living.dm)
/mob/living/proc/do_stun_animation()
	var/matrix/rotation_matrix = matrix()
	rotation_matrix.Turn(5)
	var/matrix/reset_matrix = matrix()
	reset_matrix.Turn(-5)
	// Offset animation
	var/start_x = rand(-2, 2)
	var/start_y = rand(-1, 1)
	animate(src, time = 1, pixel_x = start_x, pixel_y = start_y, easing = ELASTIC_EASING, flags = ANIMATION_RELATIVE|ANIMATION_PARALLEL)
	for (var/i in 1 to 4)
		var/dx = rand(-4, 2)
		var/dy = rand(-4, 2)
		animate(time = 1, pixel_x = dx, pixel_y = dy, easing = ELASTIC_EASING, flags = ANIMATION_RELATIVE)
		animate(time = 0, pixel_x = -dx, pixel_y = -dy, easing = ELASTIC_EASING, flags = ANIMATION_RELATIVE)
	// Cofnięcie tylko własnego przesunięcia, żeby nie zgubić offsetu leżenia
	animate(time = 1, pixel_x = -start_x, pixel_y = -start_y, flags = ANIMATION_RELATIVE)
	// Rotational Animation
	animate(src, time = 3, transform = rotation_matrix, flags = ANIMATION_PARALLEL | ANIMATION_RELATIVE)
	animate(time = 2, flags = ANIMATION_RELATIVE)
	animate(time = 1, transform = reset_matrix, flags = ANIMATION_RELATIVE)
