/datum/disease/anxiety
	name = "Severe Anxiety"
	form = "Infection"
	max_stages = 4
	spread_text = "Przez kontakt"
	spread_flags = DISEASE_SPREAD_BLOOD | DISEASE_SPREAD_CONTACT_SKIN | DISEASE_SPREAD_CONTACT_FLUIDS
	cure_text = "Ethanol"
	cures = list(/datum/reagent/consumable/ethanol)
	agent = "Nadmiar lepidoptycydów"
	viable_mobtypes = list(/mob/living/carbon/human, /mob/living/carbon/monkey)
	desc = "Nieleczony chory zacznie zwracać motyle."
	danger = DISEASE_MINOR

/datum/disease/anxiety/stage_act()
	..()
	switch(stage)
		if(2) //also changes say, see say.dm
			if(prob(5))
				to_chat(affected_mob, "<span class='notice'>Czujesz niepokój.</span>")
		if(3)
			if(prob(10))
				to_chat(affected_mob, "<span class='notice'>Coś trzepocze ci w żołądku.</span>")
			if(prob(5))
				to_chat(affected_mob, "<span class='notice'>Ogarnia cię panika.</span>")
			if(prob(2))
				to_chat(affected_mob, "<span class='danger'>Ogarnia cię przerażenie!</span>")
				affected_mob.confused += (rand(2,3))
		if(4)
			if(prob(10))
				to_chat(affected_mob, "<span class='danger'>Czujesz motyle w brzuchu.</span>")
			if(prob(5))
				affected_mob.visible_message("<span class='danger'>[affected_mob] w panice się zatacza.</span>", \
												"<span class='userdanger'>Dostajesz ataku paniki!</span>")
				affected_mob.confused += (rand(6,8))
				affected_mob.jitteriness += (rand(6,8))
			if(prob(2))
				affected_mob.visible_message("<span class='danger'>[affected_mob] wykasłuje motyle!</span>", \
													"<span class='userdanger'>Wykasłujesz motyle!</span>")
				new /mob/living/simple_animal/butterfly(affected_mob.loc)
				new /mob/living/simple_animal/butterfly(affected_mob.loc)
	return
