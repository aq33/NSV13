/datum/disease/beesease
	name = "Beesease"
	form = "Infection"
	max_stages = 4
	spread_text = "Przez kontakt"
	spread_flags = DISEASE_SPREAD_BLOOD | DISEASE_SPREAD_CONTACT_SKIN | DISEASE_SPREAD_CONTACT_FLUIDS
	cure_text = "Sugar"
	cures = list(/datum/reagent/consumable/sugar)
	agent = "Apidae Infection"
	viable_mobtypes = list(/mob/living/carbon/human, /mob/living/carbon/monkey)
	desc = "Nieleczony chory zacznie zwracać pszczoły."
	danger = DISEASE_MEDIUM
	infectable_biotypes = list(MOB_ORGANIC, MOB_UNDEAD) //bees nesting in corpses

/datum/disease/beesease/stage_act()
	..()
	switch(stage)
		if(2) //also changes say, see say.dm
			if(prob(2))
				to_chat(affected_mob, "<span class='notice'>Czujesz w ustach smak miodu.</span>")
		if(3)
			if(prob(10))
				to_chat(affected_mob, "<span class='notice'>Burczy ci w brzuchu.</span>")
			if(prob(2))
				to_chat(affected_mob, "<span class='danger'>Boleśnie kłuje cię w żołądku.</span>")
				if(prob(20))
					affected_mob.adjustToxLoss(2)
					affected_mob.updatehealth()
		if(4)
			if(prob(10))
				affected_mob.visible_message("<span class='danger'>[affected_mob] buzzes.</span>", \
												"<span class='userdanger'>Twój żołądek gwałtownie brzęczy!</span>")
			if(prob(5))
				to_chat(affected_mob, "<span class='danger'>Czujesz, jak coś porusza się w twoim gardle.</span>")
			if(prob(1))
				affected_mob.visible_message("<span class='danger'>[affected_mob] wykasłuje rój pszczół!</span>", \
													"<span class='userdanger'>Wykasłujesz rój pszczół!</span>")
				new /mob/living/simple_animal/hostile/poison/bees(affected_mob.loc)
	return
