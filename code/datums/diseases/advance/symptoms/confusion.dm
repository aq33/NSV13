/*
//////////////////////////////////////

Confusion

	Little bit hidden.
	Lowers resistance.
	Decreases stage speed.
	Not very transmissibile.
	Intense Level.

Bonus
	Makes the affected mob be confused for short periods of time.

//////////////////////////////////////
*/

/datum/symptom/confusion

	name = "Confusion"
	desc = "Wirus zakłóca prawidłową pracę układu nerwowego, prowadząc do napadów dezorientacji i chaotycznych ruchów."
	stealth = 1
	resistance = -1
	stage_speed = -3
	transmission = 0
	level = 3
	severity = 2
	base_message_chance = 25
	symptom_delay_min = 10
	symptom_delay_max = 30
	prefixes = list("Dizzy ")
	bodies = list("Ditz")
	var/brain_damage = FALSE
	threshold_desc = "<b>Odporność 6:</b> z czasem uszkadza mózg.<br><b>Transmisja 6:</b> wydłuża czas dezorientacji.<br><b>Ukrycie 4:</b> objaw pozostaje ukryty, dopóki nie jest aktywny."

/datum/symptom/confusion/severityset(datum/disease/advance/A)
	. = ..()
	if(A.resistance >= 6)
		severity += 1

/datum/symptom/confusion/Start(datum/disease/advance/A)
	if(!..())
		return
	if(A.resistance >= 6)
		brain_damage = TRUE
	if(A.transmission >= 6)
		power = 1.5
	if(A.stealth >= 4)
		suppress_warning = TRUE

/datum/symptom/confusion/Activate(datum/disease/advance/A)
	if(!..())
		return
	var/mob/living/carbon/M = A.affected_mob
	switch(A.stage)
		if(1, 2, 3, 4)
			if(prob(base_message_chance) && !suppress_warning)
				to_chat(M, "<span class='warning'>[pick("Your head hurts.", "Your mind blanks for a moment.")]</span>")
		else
			to_chat(M, "<span class='userdanger'>Nie możesz jasno myśleć!</span>")
			M.confused = min(100 * power, M.confused + 8)
			if(brain_damage)
				M.adjustOrganLoss(ORGAN_SLOT_BRAIN,3 * power, 80)
				M.updatehealth()

	return
