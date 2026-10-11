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
