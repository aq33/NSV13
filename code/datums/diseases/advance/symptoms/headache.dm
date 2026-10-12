/*
//////////////////////////////////////

Headache

	Noticable.
	Highly resistant.
	Increases stage speed.
	Not transmittable.
	Low Level.

BONUS
	Displays an annoying message!
	Should be used for buffing your disease.

//////////////////////////////////////
*/

/datum/symptom/headache

	name = "Headache"
	desc = "Wirus wywołuje stan zapalny w mózgu, powodując ciągłe bóle głowy."
	stealth = -1
	resistance = 4
	stage_speed = 2
	transmission = 0
	level = 1
	severity = 0
	base_message_chance = 100
	symptom_delay_min = 15
	symptom_delay_max = 30
	bodies = list("Skull", "Migraine")
	threshold_desc = "<b>Szybkość stadiów 6:</b> bóle głowy są silne i osłabiają nosiciela.<br><b>Szybkość stadiów 9:</b> bóle głowy są rzadsze, ale o wiele silniejsze, uniemożliwiając nosicielowi jakiekolwiek działanie.<br><b>Ukrycie 4:</b> zmniejsza częstotliwość bólów głowy do późniejszych stadiów."

/datum/symptom/headache/severityset(datum/disease/advance/A)
	. = ..()
	if(A.stage_rate >= 6)
		severity += 1
		if(A.stage_rate >= 9)
			severity += 1

/datum/symptom/headache/Start(datum/disease/advance/A)
	if(!..())
		return
	if(A.stealth >= 4)
		base_message_chance = 50
		if(A.stage_rate >= 6) //severe pain
			power = 2
	if(A.stage_rate >= 9) //cluster headaches
		symptom_delay_min = 30
		symptom_delay_max = 60
		power = 3

/datum/symptom/headache/Activate(datum/disease/advance/A)
	if(!..())
		return
	var/mob/living/M = A.affected_mob
	if(power < 2)
		if(prob(base_message_chance) || A.stage >=4)
			to_chat(M, "<span class='warning'>[pick("Your head hurts.", "Your head pounds.")]</span>")
	if(power >= 2 && A.stage >= 4)
		to_chat(M, "<span class='warning'>[pick("Your head hurts a lot.", "Your head pounds incessantly.")]</span>")
		M.adjustStaminaLoss(25)
	if(power >= 3 && A.stage >= 5)
		to_chat(M, "<span class='userdanger'>[pick("Your head hurts!", "You feel a burning knife inside your brain!", "A wave of pain fills your head!")]</span>")
		M.Stun(35)
