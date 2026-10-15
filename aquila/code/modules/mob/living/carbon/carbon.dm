/mob/living/carbon/update_sight()
	. = ..()
	if(mind)
		var/datum/antagonist/vampire/V = mind.has_antag_datum(/datum/antagonist/vampire)
		if(V)
			if(V.get_ability(/datum/vampire_passive/full))
				sight |= (SEE_TURFS|SEE_MOBS|SEE_OBJS)
				see_in_dark = max(see_in_dark, 8)
			else if(V.get_ability(/datum/vampire_passive/vision))
				sight |= (SEE_MOBS)

/// Przy upadku update_transform() obraca moba na północ lub południe przez animate(dir = ...), z pominięciem setDir(),
/// więc nikt nie dostawał sygnału zmiany kierunku. Animacja chodu zostawiała wtedy ukrytą nogę z widoku z boku
/// i postać leżąca przodem miała jedną nogę. animate() ustawia dir od razu, więc wystarczy porównać przed i po.
/mob/living/carbon/update_transform()
	var/old_dir = dir
	. = ..()
	if(dir != old_dir)
		SEND_SIGNAL(src, COMSIG_ATOM_DIR_CHANGE, old_dir, dir)

// Potrząśnięcie przy próbie podniesienia leżącego: port z tgstation (code/modules/mob/living/carbon/carbon_defense.dm)
#define SHAKE_ANIMATION_OFFSET 4
/mob/proc/shake_up_animation()
	var/direction = prob(50) ? -1 : 1
	animate(src, pixel_x = SHAKE_ANIMATION_OFFSET * direction, time = 0.1 SECONDS, easing = QUAD_EASING | EASE_OUT, flags = ANIMATION_PARALLEL|ANIMATION_RELATIVE)
	animate(pixel_x = SHAKE_ANIMATION_OFFSET * -2 * direction, time = 0.1 SECONDS, flags = ANIMATION_RELATIVE)
	animate(pixel_x = SHAKE_ANIMATION_OFFSET * direction, time = 0.1 SECONDS, easing = QUAD_EASING | EASE_IN, flags = ANIMATION_RELATIVE)
#undef SHAKE_ANIMATION_OFFSET
