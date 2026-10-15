/datum/component/nanites/proc/reject_excess_nanites()
	var/excess = nanite_volume - max_nanites
	nanite_volume = max_nanites

	switch(excess)
		if(0 to NANITE_EXCESS_MINOR) //Minor excess amount, the extra nanites are quietly expelled without visible effects
			return
		if((NANITE_EXCESS_MINOR + 0.1) to NANITE_EXCESS_VOMIT) //Enough nanites getting rejected at once to be visible to the naked eye
			host_mob.visible_message("<span class='warning'>Z [host_mob] zaczyna sączyć się ziarnista szara breja.</span>", "<span class='warning'>Z twojej skóry zaczyna sączyć się ziarnista szara breja.</span>", null, 4);
		if((NANITE_EXCESS_VOMIT + 0.1) to INFINITY) //Nanites getting rejected in massive amounts, but still enough to make a semi-orderly exit through vomit
			if(iscarbon(host_mob))
				var/mob/living/carbon/C = host_mob
				host_mob.visible_message("<span class='warning'>[host_mob] wymiotuje ziarnistą szarą breją!</span>", "<span class='warning'>Nagle wymiotujesz ziarnistą szarą breją o metalicznym posmaku!</span>", null);
				C.vomit(0, FALSE, TRUE, FLOOR(excess / 75, 1), FALSE)
			else
				host_mob.visible_message("<span class='warning'>Ze skóry [host_mob] wytryskuje metaliczna szara breja!</span>", "<span class='userdanger'>Z twojej skóry gwałtownie wytryskuje metaliczna szara breja!</span>", null);

/datum/component/nanites/proc/set_max_volume(datum/source, amount)
	SIGNAL_HANDLER

	max_nanites = max(1, amount)
	if(nanite_volume > max_nanites)
		reject_excess_nanites()
