/*
//////////////////////////////////////

Voice Change

	Noticeable.
	Lowers resistance.
	Decreases stage speed.
	Increased transmission.
	Fatal Level.

Bonus
	Changes the voice of the affected mob. Causing confusion in communication.

//////////////////////////////////////
*/

/datum/symptom/voice_change

	name = "Voice Change"
	desc = "Wirus zmienia wysokość i barwę strun głosowych nosiciela, zmieniając brzmienie jego głosu."
	stealth = -1
	resistance = -2
	stage_speed = -2
	transmission = 2
	level = 3
	severity = 2
	base_message_chance = 100
	symptom_delay_min = 60
	symptom_delay_max = 120
	prefixes = list("Vocal ")
	var/scramble_language = FALSE
	var/datum/language/current_language
	threshold_desc = "<b>Transmisja 10:</b> ośrodek mowy w mózgu nosiciela zostaje uszkodzony, przez co całkowicie traci on zdolność mówienia i rozumienia jakiegokolwiek języka.<br><b>Szybkość stadiów 7:</b> częściej zmienia głos.<br><b>Ukrycie 3:</b> objaw pozostaje ukryty, dopóki nie jest aktywny."

/datum/symptom/voice_change/severityset(datum/disease/advance/A)
	. = ..()
	if(A.transmission >= 10) //random language
		severity += 1
		bodies = list("Polyglot")

/datum/symptom/voice_change/Start(datum/disease/advance/A)
	if(!..())
		return
	if(A.stealth >= 3)
		suppress_warning = TRUE
	if(A.stage_rate >= 7) //faster change of voice
		base_message_chance = 25
		symptom_delay_min = 25
		symptom_delay_max = 85
	if(A.transmission >= 10) //random language
		scramble_language = TRUE

/datum/symptom/voice_change/Activate(datum/disease/advance/A)
	if(!..())
		return
	var/mob/living/carbon/M = A.affected_mob
	switch(A.stage)
		if(1, 2, 3, 4)
			if(prob(base_message_chance) && !suppress_warning)
				to_chat(M, "<span class='warning'>[pick("Your throat hurts.", "You clear your throat.")]</span>")
		else
			if(ishuman(M))
				var/mob/living/carbon/human/H = M
				H.SetSpecialVoice(H.dna.species.random_name(H.gender))
				if(scramble_language && !current_language)	// Last part prevents rerolling language with small amounts of cure.
					current_language = pick(subtypesof(/datum/language) - /datum/language/common)
					H.add_blocked_language(subtypesof(/datum/language) - current_language, LANGUAGE_VOICECHANGE)
					H.grant_language(current_language, TRUE, TRUE, LANGUAGE_VOICECHANGE)

/datum/symptom/voice_change/End(datum/disease/advance/A)
	..()
	if(ishuman(A.affected_mob))
		var/mob/living/carbon/human/H = A.affected_mob
		H.UnsetSpecialVoice()
	if(scramble_language)
		A.affected_mob.remove_blocked_language(subtypesof(/datum/language), LANGUAGE_VOICECHANGE)
		A.affected_mob.remove_all_languages(LANGUAGE_VOICECHANGE)	// In case someone managed to get more than one anyway.
