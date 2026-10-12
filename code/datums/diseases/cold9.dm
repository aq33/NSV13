/datum/disease/cold9
	name = "The Cold"
	max_stages = 3
	spread_text = "Przez kontakt"
	spread_flags = DISEASE_SPREAD_BLOOD | DISEASE_SPREAD_CONTACT_SKIN | DISEASE_SPREAD_CONTACT_FLUIDS
	cure_text = "Przeciwciała przeciw przeziębieniu i spacyklina"
	cures = list(/datum/reagent/medicine/spaceacillin)
	agent = "ICE9-rhinovirus"
	viable_mobtypes = list(/mob/living/carbon/human)
	desc = "Nieleczony chory zwolni, jakby był częściowo zamrożony."
	danger = DISEASE_HARMFUL

/datum/disease/cold9/stage_act()
	..()
	switch(stage)
		if(2)
			affected_mob.adjust_bodytemperature(-10)
			if(prob(1) && prob(10))
				to_chat(affected_mob, "<span class='notice'>Czujesz się lepiej.</span>")
				cure()
				return
			if(prob(1))
				affected_mob.emote("sneeze")
			if(prob(1))
				affected_mob.emote("cough")
			if(prob(1))
				to_chat(affected_mob, "<span class='danger'>Boli cię gardło.</span>")
			if(prob(5))
				to_chat(affected_mob, "<span class='danger'>Czujesz sztywność.</span>")
		if(3)
			affected_mob.adjust_bodytemperature(-20)
			if(prob(1))
				affected_mob.emote("sneeze")
			if(prob(1))
				affected_mob.emote("cough")
			if(prob(1))
				to_chat(affected_mob, "<span class='danger'>Boli cię gardło.</span>")
			if(prob(10))
				to_chat(affected_mob, "<span class='danger'>Czujesz sztywność.</span>")
