
/*
//////////////////////////////////////

Asphyxiation

	Very very noticable.
	Decreases stage speed.
	Decreases transmittablity.

Bonus
	Inflicts large spikes of oxyloss
	Introduces Asphyxiating drugs to the system
	Causes cardiac arrest on dying victims.

//////////////////////////////////////
*/

/datum/symptom/asphyxiation

	name = "Acute respiratory distress syndrome"
	desc = "The virus causes shrinking of the host's lungs, causing severe asphyxiation. May also lead to heart attacks."
	stealth = -2
	resistance = -0
	stage_speed = -1
	transmission = -2
	level = 9
	severity = 5
	base_message_chance = 15
	symptom_delay_min = 14
	symptom_delay_max = 30
	bodies = list("Lung")
	suffixes = list(" Tuberculosis")
	var/paralysis = FALSE
	threshold_desc = "<b>Szybkość stadiów 8:</b> dodatkowo syntetyzuje w nosicielu pankuronium i tiopental sodu.<br><b>Transmisja 8:</b> podwaja obrażenia zadawane przez objaw."

/datum/symptom/asphyxiation/severityset(datum/disease/advance/A)
	. = ..()
	if(A.transmission >= 8)
		severity += 1

/datum/symptom/asphyxiation/Start(datum/disease/advance/A)
	if(!..())
		return
	if(A.stage_rate >= 8)
		paralysis = TRUE
	if(A.transmission >= 8)
		power = 2

/datum/symptom/asphyxiation/Activate(datum/disease/advance/A)
	if(!..())
		return
	var/mob/living/M = A.affected_mob
	if(HAS_TRAIT(M, TRAIT_NOBREATH)) //if they don't breath, why would being unable to breath kill them?
		return
	switch(A.stage)
		if(3, 4)
			to_chat(M, "<span class='warning'><b>[pick("Your windpipe feels thin.", "Your lungs feel small.")]</span>")
			Asphyxiate_stage_3_4(M, A)
			M.emote("gasp")
		if(5)
			to_chat(M, "<span class='userdanger'>[pick("Your lungs hurt!", "It hurts to breathe!")]</span>")
			Asphyxiate(M, A)
			M.emote("gasp")
			if(M.getOxyLoss() >= 120)
				M.visible_message("<span class='warning'>[M] przestaje oddychać, jakby jego płuca całkowicie się zapadły!</span>")
				Asphyxiate_death(M, A)
	return

/datum/symptom/asphyxiation/proc/Asphyxiate_stage_3_4(mob/living/M, datum/disease/advance/A)
	var/get_damage = rand(10,15) * power
	M.adjustOxyLoss(get_damage)
	return 1

/datum/symptom/asphyxiation/proc/Asphyxiate(mob/living/M, datum/disease/advance/A)
	var/get_damage = rand(15,21) * power
	M.adjustOxyLoss(get_damage)
	if(paralysis)
		M.reagents.add_reagent_list(list(/datum/reagent/toxin/pancuronium = 3, /datum/reagent/toxin/sodium_thiopental = 3))
	return 1

/datum/symptom/asphyxiation/proc/Asphyxiate_death(mob/living/M, datum/disease/advance/A)
	var/get_damage = rand(25,35) * power
	M.adjustOxyLoss(get_damage)
	M.adjustOrganLoss(ORGAN_SLOT_BRAIN, get_damage/2)
	return 1
