/datum/symptom/braindamage
	name = "Neural Decay"
	desc = "Causes the host's brain cells to naturally die off, causing severe brain damage."
	stealth = 1
	resistance = -2
	stage_speed = -3
	transmission = -1
	level = 7
	severity = 3
	symptom_delay_min = 15
	symptom_delay_max = 60
	prefixes = list("Idiot's ")
	bodies = list("Idiot")
	suffixes = list(" Utrata pamięci")
	var/lethal = FALSE
	var/moretrauma = FALSE
	threshold_desc = "<b>Transmisja 12:</b> obrażenia od choroby osiągają śmiertelny poziom.<br><b>Szybkość 9:</b> w mózgu nosiciela rozwija się jeszcze więcej urazów niż zwykle."

/datum/symptom/braindamage/severityset(datum/disease/advance/A)
	. = ..()
	if(A.transmission >= 12)
		severity += 1

/datum/symptom/braindamage/Start(datum/disease/advance/A)
	if(!..())
		return
	if(A.transmission >= 12)
		lethal = TRUE
	if(A.stage_rate >= 9)
		moretrauma = TRUE

/datum/symptom/braindamage/Activate(datum/disease/advance/A)
	if(!..())
		return
	var/mob/living/M = A.affected_mob
	switch(A.stage)
		if(1)
			if(prob(10))
				to_chat(M, "<span class='notice'>Twoja głowa wydaje się dziwna...</span>")
		if(2, 3)
			if(prob(10))
				to_chat(M, "<span class='danger'>Mózg zaczyna cię boleć...</span>")
		if(4, 5)
			if(lethal)
				if(prob(35))
					M.adjustOrganLoss(ORGAN_SLOT_BRAIN, (rand(5,90)), 200)
					to_chat(M, "<span class='danger'>Mózg okropnie cię boli!</span>")
			else
				if(prob(35))
					M.adjustOrganLoss(ORGAN_SLOT_BRAIN, (rand(5,90)), 120)
					to_chat(M, "<span class='danger'>Głowa okropnie cię boli!</span>")
			if(moretrauma && A.stage == 5)
				givetrauma(A, 10)

/datum/symptom/braindamage/proc/givetrauma(datum/disease/advance/A, chance)
	if(prob(chance))
		if(ishuman(A.affected_mob))
			var/mob/living/carbon/human/M = A.affected_mob
			M?.gain_trauma(BRAIN_TRAUMA_MILD)
