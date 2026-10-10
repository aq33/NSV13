/datum/symptom/mind_restoration //heals damage to the brain
	name = "Mind Restoration"
	desc = "Wirus wzmacnia połączenia między neuronami, skracając czas trwania wszelkich dolegliwości umysłu."
	stealth = -1
	resistance = -2
	stage_speed = 1
	transmission = -3
	level = 6
	severity = -1
	symptom_delay_min = 5
	symptom_delay_max = 10
	bodies = list("Neuron")
	var/purge_alcohol = FALSE
	var/trauma_heal_mild = FALSE
	var/trauma_heal_severe = FALSE
	threshold_desc = "<b>Odporność 6:</b> leczy drobne urazy mózgu.<br><b>Odporność 9:</b> leczy poważne urazy mózgu.<br><b>Transmisja 8:</b> usuwa alkohol z krwiobiegu."

/datum/symptom/mind_restoration/Start(datum/disease/advance/A)
	if(!..())
		return
	if(A.resistance >= 6) //heal brain damage
		trauma_heal_mild = TRUE
		if(A.resistance >= 9) //heal severe traumas
			trauma_heal_severe = TRUE
	if(A.transmission >= 8) //purge alcohol
		purge_alcohol = TRUE

/datum/symptom/mind_restoration/Activate(var/datum/disease/advance/A)
	if(!..())
		return
	var/mob/living/M = A.affected_mob


	if(A.stage >= 3)
		M.dizziness = max(0, M.dizziness - 2)
		M.drowsyness = max(0, M.drowsyness - 2)
		M.slurring = max(0, M.slurring - 2)
		M.confused = max(0, M.confused - 2)
		if(purge_alcohol)
			M.reagents.remove_all_type(/datum/reagent/consumable/ethanol, 3)
			if(ishuman(M))
				var/mob/living/carbon/human/H = M
				H.drunkenness = max(H.drunkenness - 5, 0)

	if(A.stage >= 4)
		M.drowsyness = max(0, M.drowsyness - 2)
		if(M.reagents.has_reagent(/datum/reagent/toxin/mindbreaker))
			M.reagents.remove_reagent(/datum/reagent/toxin/mindbreaker, 5)
		if(M.reagents.has_reagent(/datum/reagent/toxin/histamine))
			M.reagents.remove_reagent(/datum/reagent/toxin/histamine, 5)
		M.hallucination = max(0, M.hallucination - 10)

	if(A.stage >= 5)
		M.adjustOrganLoss(ORGAN_SLOT_BRAIN, -3)
		if(trauma_heal_mild && iscarbon(M))
			var/mob/living/carbon/C = M
			if(prob(10))
				if(trauma_heal_severe)
					C.cure_trauma_type(resilience = TRAUMA_RESILIENCE_LOBOTOMY)
				else
					C.cure_trauma_type(resilience = TRAUMA_RESILIENCE_BASIC)



/datum/symptom/sensory_restoration //heals damage to the eyes and ears
	name = "Sensory Restoration"
	desc = "Wirus stymuluje wytwarzanie i wymianę tkanek zmysłowych, przez co nosiciel odtwarza uszkodzone oczy i uszy."
	stealth = 0
	resistance = 1
	stage_speed = -2
	transmission = 2
	level = 6
	severity = -1
	base_message_chance = 7
	symptom_delay_min = 1
	symptom_delay_max = 1

/datum/symptom/sensory_restoration/Activate(datum/disease/advance/A)
	if(!..())
		return
	var/mob/living/M = A.affected_mob
	var/obj/item/organ/eyes/eyes = M.getorganslot(ORGAN_SLOT_EYES)
	if (!eyes)
		return
	switch(A.stage)
		if(4, 5)
			M.restoreEars()

			if(HAS_TRAIT_FROM(M, TRAIT_BLIND, EYE_DAMAGE))
				if(prob(20))
					to_chat(M, "<span class='notice'>Wzrok powoli ci wraca...</span>")
					M.cure_blind(EYE_DAMAGE)
					M.cure_nearsighted(EYE_DAMAGE)
					M.blur_eyes(35)
			else if(HAS_TRAIT_FROM(M, TRAIT_NEARSIGHT, EYE_DAMAGE))
				to_chat(M, "<span class='notice'>W końcu możesz skupić wzrok na odległych przedmiotach.</span>")
				M.cure_nearsighted(EYE_DAMAGE)
				M.blur_eyes(10)
			else if(M.eye_blind || M.eye_blurry)
				M.set_blindness(0)
				M.set_blurriness(0)
			else if(eyes.damage > 0)
				eyes.applyOrganDamage(-1)
		else
			if(prob(base_message_chance))
				to_chat(M, "<span class='notice'>[pick("Your eyes feel great.","You feel like your eyes can focus more clearly.", "You don't feel the need to blink.","Your ears feel great.","Your healing feels more acute.")]</span>")


/datum/symptom/organ_restoration //heals damage to other internal organs that get damaged far less often
	name = "Organ Restoration"
	desc = "Wirus pobudza szybki wzrost komórek w tkankach narządów, z czasem powoli je naprawiając."
	stealth = 2
	resistance = 3
	stage_speed = -2
	transmission = -1
	level = 6
	severity = -1
	symptom_delay_min = 1
	symptom_delay_max = 1
	prefixes = list("Organ ")
	var/curing = FALSE
	var/regenorgans = FALSE 
	threshold_desc = "<b>Ukrycie 4:</b> nosiciel przez długi czas regeneruje brakujące narządy.<br><b>Szybkość stadiów 10:</b> wirus nadaje narządom wewnętrznym nosiciela zdolność samonaprawy, zapobiegając zawałom serca i zapaleniu wyrostka.<br>"

/datum/symptom/organ_restoration/severityset(datum/disease/advance/A)
	. = ..()
	if(A.stealth >= 4)
		severity -= 1

/datum/symptom/organ_restoration/Start(datum/disease/advance/A)
	if(!..())
		return
	if(A.stage_rate >= 10)
		curing = TRUE
	if(A.stealth >= 4)
		regenorgans = TRUE

/datum/symptom/organ_restoration/Activate(datum/disease/advance/A)
	if(!..())
		return
	var/mob/living/carbon/M = A.affected_mob
	var/status = ORGAN_ORGANIC
	if(MOB_ROBOTIC in A.infectable_biotypes)
		status = null //if the disease is capable of interfacing with robotics, it is allowed to heal mechanical organs
	if(A.stage >= 4)
		M.adjustOrganLoss(ORGAN_SLOT_APPENDIX, -1, required_status = status)
		M.adjustOrganLoss(ORGAN_SLOT_STOMACH, -1, required_status = status)
		M.adjustOrganLoss(ORGAN_SLOT_LUNGS, -1, required_status = status)
		M.adjustOrganLoss(ORGAN_SLOT_HEART, -1, required_status = status)
		M.adjustOrganLoss(ORGAN_SLOT_LIVER, -1, required_status = status)
		M.adjustOrganLoss(ORGAN_SLOT_TAIL, -1, required_status = status)
		M.adjustOrganLoss(ORGAN_SLOT_WINGS, -1, required_status = status)
		if(curing)
			for(var/datum/disease/D in M.diseases)
				if(istype(D, /datum/disease/appendicitis) || istype(D, /datum/disease/heart_failure))
					D.cure()
			if(M.undergoing_cardiac_arrest())
				M.set_heartattack(FALSE)
		if(regenorgans) //regenerate missing organs that this disease cures, other than the brain
			if(ishuman(M))
				var/mob/living/carbon/human/H = M
				var/datum/species/S = H.dna.species
				if(!M.getorgan(/obj/item/organ/appendix) && !((TRAIT_NOHUNGER in S.inherent_traits) || (TRAIT_POWERHUNGRY in S.inherent_traits)))
					var/obj/item/organ/appendix/O = new()
					O.Insert(M)
					M.adjustOrganLoss(ORGAN_SLOT_APPENDIX, 99, 99) //don't make it fail, or the host will start taking massive damage
					return
				if(!M.getorgan(/obj/item/organ/stomach) && !(NOSTOMACH in S.species_traits))
					var/obj/item/organ/stomach/O
					if(S.mutantstomach)
						O = new S.mutantstomach()
					else
						O = new()
					O.Insert(M, drop_if_replaced = FALSE)
					M.adjustOrganLoss(ORGAN_SLOT_STOMACH, 200)
					return
				if(!M.getorgan(/obj/item/organ/lungs) && !(TRAIT_NOBREATH in S.inherent_traits))
					var/obj/item/organ/lungs/O
					if(S.mutantlungs)
						O = new S.mutantlungs()
					else
						O = new()
					O.Insert(M, drop_if_replaced = FALSE)
					M.adjustOrganLoss(ORGAN_SLOT_LUNGS, 200)
					return
				if(!M.getorgan(/obj/item/organ/heart) && !(NOBLOOD in S.species_traits))
					var/obj/item/organ/heart/O = new()
					O.Insert(M, drop_if_replaced = FALSE)
					M.adjustOrganLoss(ORGAN_SLOT_HEART, 200)
					return
				if(!M.getorgan(/obj/item/organ/liver) && !(TRAIT_NOMETABOLISM in S.inherent_traits))
					var/obj/item/organ/liver/O
					if(S.mutantliver)
						O = new S.mutantliver()
					else
						O = new()
					O.Insert(M, drop_if_replaced = FALSE)
					M.adjustOrganLoss(ORGAN_SLOT_LIVER, 200)
					return
				if(!M.getorgan(/obj/item/organ/tail))
					if(S.mutanttail)
						var/obj/item/organ/tail/O = new S.mutanttail()
						O.Insert(M, drop_if_replaced = FALSE)
						M.adjustOrganLoss(ORGAN_SLOT_TAIL, 200)
						M.visible_message("<span class='notice'>[M] wypuszcza nowy ogon!", "<span_class='userdanger'>Wyrasta ci nowy ogon!</span>")
						playsound(M, 'sound/magic/demon_consume.ogg', 50, 1)
						M.add_splatter_floor(get_turf(M))
						return
				if(!M.getorgan(/obj/item/organ/wings))
					if(S.mutantwings)
						var/obj/item/organ/wings/O = new S.mutantwings()
						O.Insert(M, drop_if_replaced = FALSE)
						M.adjustOrganLoss(ORGAN_SLOT_WINGS, 200)
						M.visible_message("<span class='notice'>[M] wypuszcza nową parę skrzydeł!", "<span_class='userdanger'>Wyrasta ci nowa para skrzydeł!</span>")
						playsound(M, 'sound/magic/demon_consume.ogg', 50, 1)
						M.add_splatter_floor(get_turf(M))
						return
	if(prob(2))
		to_chat(M, "<span class='notice'>[pick("You feel healthy!.","You feel energetic!", "You feel rejuvenated!")]</span>")
