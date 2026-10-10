/datum/disease/cold
	name = "The Cold"
	max_stages = 3
	cure_text = "Odpoczynek i spacyklina"
	cures = list(/datum/reagent/medicine/spaceacillin)
	agent = "XY-rhinovirus"
	viable_mobtypes = list(/mob/living/carbon/human, /mob/living/carbon/monkey)
	permeability_mod = 0.5
	desc = "Nieleczony chory zachoruje na grypę."
	danger = DISEASE_NONTHREAT

/datum/disease/cold/stage_act()
	..()
	switch(stage)
		if(2)
			if(!(affected_mob.mobility_flags & MOBILITY_STAND) && prob(40))  //changed FROM prob(10) until sleeping is fixed
				to_chat(affected_mob, "<span class='notice'>Czujesz się lepiej.</span>")
				cure()
				return
			if(prob(1) && prob(5))
				to_chat(affected_mob, "<span class='notice'>Czujesz się lepiej.</span>")
				cure()
				return
			if(prob(1))
				affected_mob.emote("sneeze")
			if(prob(1))
				affected_mob.emote("cough")
			if(prob(1))
				to_chat(affected_mob, "<span class='danger'>Boli cię gardło.</span>")
			if(prob(1))
				to_chat(affected_mob, "<span class='danger'>Wydzielina spływa ci po tylnej ścianie gardła.</span>")
		if(3)
			if(!(affected_mob.mobility_flags & MOBILITY_STAND) && prob(25))  //changed FROM prob(5) until sleeping is fixed
				to_chat(affected_mob, "<span class='notice'>Czujesz się lepiej.</span>")
				cure()
				return
			if(prob(1) && prob(1))
				to_chat(affected_mob, "<span class='notice'>Czujesz się lepiej.</span>")
				cure()
				return
			if(prob(1))
				affected_mob.emote("sneeze")
			if(prob(1))
				affected_mob.emote("cough")
			if(prob(1))
				to_chat(affected_mob, "<span class='danger'>Boli cię gardło.</span>")
			if(prob(1))
				to_chat(affected_mob, "<span class='danger'>Wydzielina spływa ci po tylnej ścianie gardła.</span>")
			if(prob(1) && prob(50))
				if(!affected_mob.disease_resistances.Find(/datum/disease/flu))
					var/datum/disease/Flu = new /datum/disease/flu()
					affected_mob.ForceContractDisease(Flu, FALSE, TRUE)
					cure()
