/datum/symptom/beesease
	name = "Bee Infestation"
	desc = "Sprawia, że nosiciel kaszle toksycznymi pszczołami i czasem syntetyzuje toksynę."
	stealth = -2
	resistance = 2
	stage_speed = 1
	transmission = 1
	level = 0
	severity = 2
	symptom_delay_min = 5
	symptom_delay_max = 20
	var/honey = FALSE
	var/toxic_bees= FALSE
	prefixes = list("Hive ")
	bodies = list("Bees", "Hive")
	threshold_desc = "<b>Odporność 12:</b> pszczoły stają się symbiotyczne z nosicielem, wytwarzają miód, przestają żądlić śluzówkę żołądka i atakować nosiciela. Pszczoły będą też zawierać miód, chyba że transmisja przekroczy 10.<br><b>Transmisja 10:</b> pszczoły zawierają teraz zupełnie losową toksynę."

/datum/symptom/beesease/severityset(datum/disease/advance/A)
	. = ..()
	if(A.transmission >= 10)
		severity += 2
		if(A.resistance >= 12)
			severity -= 4

/datum/symptom/beesease/Start(datum/disease/advance/A)
	if(!..())
		return
	if(A.resistance >= 12)
		honey = TRUE
	if(A.transmission >= 10)
		toxic_bees = TRUE

/datum/symptom/beesease/Activate(datum/disease/advance/A)
	if(!..())
		return
	var/mob/living/M = A.affected_mob
	switch(A.stage)
		if(2)
			if(prob(2))
				to_chat(M, "<span class='notice'>Czujesz w ustach smak miodu.</span>")
		if(3)
			if(prob(15))
				to_chat(M, "<span class='notice'>Mrowi cię w żołądku.</span>")
			if(prob(15))
				if(honey)
					to_chat(M, "<span class='notice'>Nie możesz pozbyć się z ust smaku miodu!</span>")
					M.reagents.add_reagent(/datum/reagent/consumable/honey, 2)
				else
					to_chat(M, "<span class='danger'>Boleśnie kłuje cię w żołądku.</span>")
					M.adjustToxLoss(5)
					M.updatehealth()
		if(4, 5)
			if(honey)
				ADD_TRAIT(M, TRAIT_BEEFRIEND, DISEASE_TRAIT)
			if(prob(15))
				to_chat(M, "<span class='notice'>Coś wierci ci się w żołądku.</span>")
			if(prob(25))
				if(honey)
					to_chat(M, "<span class='notice'>Nie możesz pozbyć się z ust smaku miodu!</span>")
					M.reagents.add_reagent_list(list(/datum/reagent/consumable/honey = 10, /datum/reagent/consumable/honey/special = 5, /datum/reagent/medicine/insulin = 5)) //insulin prevents hyperglycemic shock
				else
					to_chat(M, "<span class='danger'>Boleśnie kłuje cię w żołądku.</span>")
					M.adjustToxLoss(5)
					M.updatehealth()
			if(prob(10))
				M.visible_message("<span class='danger'>[M] buzzes.</span>", \
								  "<span class='userdanger'>Twój żołądek gwałtownie brzęczy!</span>")
			if(prob(15))
				to_chat(M, "<span class='danger'>Czujesz, jak coś porusza się w twoim gardle.</span>")
			if(prob(10))
				M.visible_message("<span class='danger'>[M] wykasłuje pszczołę!</span>", \
								  "<span class='userdanger'>Wykasłujesz pszczołę!</span>")
				if(toxic_bees)
					new /mob/living/simple_animal/hostile/poison/bees/toxin(M.loc)
				else if(honey)
					var/mob/living/simple_animal/hostile/poison/bees/newbee = new /mob/living/simple_animal/hostile/poison/bees(M.loc) //Heh, newbee
					newbee.assign_reagent(GLOB.chemical_reagents_list[/datum/reagent/consumable/honey])
					var/mob/living/simple_animal/hostile/poison/bees/newbee2 = new /mob/living/simple_animal/hostile/poison/bees(M.loc)
					newbee2.assign_reagent(GLOB.chemical_reagents_list[/datum/reagent/medicine/insulin])
				else
					new /mob/living/simple_animal/hostile/poison/bees(M.loc)

/datum/symptom/beesease/End(datum/disease/advance/A)
	if(!..())
		return
	REMOVE_TRAIT(A.affected_mob, TRAIT_BEEFRIEND, DISEASE_TRAIT)
