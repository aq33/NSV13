/datum/disease/dna_retrovirus
	name = "Retrovirus"
	max_stages = 4
	spread_text = "Contact"
	spread_flags = DISEASE_SPREAD_BLOOD | DISEASE_SPREAD_CONTACT_SKIN | DISEASE_SPREAD_CONTACT_FLUIDS
	cure_text = "Odpoczynek albo zastrzyk mutadonu"
	cure_chance = 6
	agent = ""
	viable_mobtypes = list(/mob/living/carbon/human)
	desc = "Retrowirus zmieniający DNA, który nieustannie miesza strukturalne i unikalne enzymy nosiciela."
	danger = DISEASE_HARMFUL
	permeability_mod = 0.4
	stage_prob = 2
	var/restcure = 0

/datum/disease/dna_retrovirus/New()
	..()
	agent = "Wirus klasy [pick("A","B","C","D","E","F")][pick("A","B","C","D","E","F")]-[rand(50,300)]"
	if(prob(40))
		cures = list(/datum/reagent/medicine/mutadone)
	else
		restcure = 1

/datum/disease/dna_retrovirus/Copy()
	var/datum/disease/dna_retrovirus/D = ..()
	D.restcure = restcure
	return D

/datum/disease/dna_retrovirus/stage_act()
	..()
	switch(stage)
		if(1)
			if(restcure)
				if(!(affected_mob.mobility_flags & MOBILITY_STAND) && prob(30))
					to_chat(affected_mob, "<span class='notice'>Czujesz się lepiej.</span>")
					cure()
					return
			if (prob(8))
				to_chat(affected_mob, "<span class='danger'>Boli cię głowa.</span>")
			if (prob(9))
				to_chat(affected_mob, "Czujesz mrowienie w klatce piersiowej.")
			if (prob(9))
				to_chat(affected_mob, "<span class='danger'>Czujesz złość.</span>")
		if(2)
			if(restcure)
				if(!(affected_mob.mobility_flags & MOBILITY_STAND) && prob(20))
					to_chat(affected_mob, "<span class='notice'>Czujesz się lepiej.</span>")
					cure()
					return
			if (prob(8))
				to_chat(affected_mob, "<span class='danger'>Twoja skóra wydaje się luźna.</span>")
			if (prob(10))
				to_chat(affected_mob, "Czujesz się bardzo dziwnie.")
			if (prob(4))
				to_chat(affected_mob, "<span class='danger'>Czujesz kłujący ból w głowie!</span>")
				affected_mob.Unconscious(40)
			if (prob(4))
				to_chat(affected_mob, "<span class='danger'>Skręca ci się żołądek.</span>")
		if(3)
			if(restcure)
				if(!(affected_mob.mobility_flags & MOBILITY_STAND) && prob(20))
					to_chat(affected_mob, "<span class='notice'>Czujesz się lepiej.</span>")
					cure()
					return
			if (prob(10))
				to_chat(affected_mob, "<span class='danger'>Całe twoje ciało wibruje.</span>")

			if (prob(35))
				if(prob(50))
					scramble_dna(affected_mob, 1, 0, rand(15,45))
				else
					scramble_dna(affected_mob, 0, 1, rand(15,45))

		if(4)
			if(restcure)
				if(!(affected_mob.mobility_flags & MOBILITY_STAND) && prob(5))
					to_chat(affected_mob, "<span class='notice'>Czujesz się lepiej.</span>")
					cure()
					return
			if (prob(60))
				if(prob(50))
					scramble_dna(affected_mob, 1, 0, rand(50,75))
				else
					scramble_dna(affected_mob, 0, 1, rand(50,75))
