//Severe traumas, when your brain gets abused way too much.
//These range from very annoying to completely debilitating.
//They cannot be cured with chemicals, and require brain recalibration to solve.

/datum/brain_trauma/severe
	resilience = TRAUMA_RESILIENCE_SURGERY

/datum/brain_trauma/severe/mute
	name = "Mutism"
	desc = "Patient is completely unable to speak."
	scan_desc = "rozległe uszkodzenie ośrodka mowy w mózgu"
	gain_text = "<span class='warning'>Zapominasz, jak się mówi!</span>"
	lose_text = "<span class='notice'>Nagle przypominasz sobie, jak się mówi.</span>"

/datum/brain_trauma/severe/mute/on_gain()
	ADD_TRAIT(owner, TRAIT_MUTE, TRAUMA_TRAIT)
	..()

/datum/brain_trauma/severe/mute/on_lose()
	REMOVE_TRAIT(owner, TRAIT_MUTE, TRAUMA_TRAIT)
	..()

/datum/brain_trauma/severe/aphasia
	name = "Aphasia"
	desc = "Patient is unable to speak or understand any language."
	scan_desc = "rozległe uszkodzenie ośrodka językowego w mózgu"
	gain_text = "<span class='warning'>Masz problem z układaniem słów w głowie...</span>"
	lose_text = "<span class='notice'>Nagle przypominasz sobie, jak działają języki.</span>"

/datum/brain_trauma/severe/aphasia/on_gain()
	owner.add_blocked_language(subtypesof(/datum/language/) - /datum/language/aphasia, LANGUAGE_APHASIA)
	owner.grant_language(/datum/language/aphasia, TRUE, TRUE, LANGUAGE_APHASIA)
	..()

/datum/brain_trauma/severe/aphasia/on_lose()
	owner.remove_blocked_language(subtypesof(/datum/language/), LANGUAGE_APHASIA)
	owner.remove_language(/datum/language/aphasia, TRUE, TRUE, LANGUAGE_APHASIA)
	..()

/datum/brain_trauma/severe/blindness
	name = "Cerebral Blindness"
	desc = "Patient's brain is no longer connected to its eyes."
	scan_desc = "rozległe uszkodzenie płata potylicznego"
	gain_text = "<span class='warning'>Nic nie widzisz!</span>"
	lose_text = "<span class='notice'>Wzrok ci wraca.</span>"

/datum/brain_trauma/severe/blindness/on_gain()
	owner.become_blind(TRAUMA_TRAIT)
	..()

/datum/brain_trauma/severe/blindness/on_lose()
	owner.cure_blind(TRAUMA_TRAIT)
	..()

/datum/brain_trauma/severe/paralysis
	name = "Paralysis"
	desc = "Patient's brain can no longer control part of its motor functions."
	scan_desc = "paraliż mózgowy"
	gain_text = ""
	lose_text = ""
	var/paralysis_type
	var/list/paralysis_traits = list()
	 //for descriptions

/datum/brain_trauma/severe/paralysis/New(specific_type)
	if(specific_type)
		paralysis_type = specific_type
	if(!paralysis_type)
		paralysis_type = pick("full","left","right","arms","legs","r_arm","l_arm","r_leg","l_leg")
	var/subject
	switch(paralysis_type)
		if("full")
			subject = "całe ciało"
			paralysis_traits = list(TRAIT_PARALYSIS_L_ARM, TRAIT_PARALYSIS_R_ARM, TRAIT_PARALYSIS_L_LEG, TRAIT_PARALYSIS_R_LEG)
		if("left")
			subject = "lewa strona ciała"
			paralysis_traits = list(TRAIT_PARALYSIS_L_ARM, TRAIT_PARALYSIS_L_LEG)
		if("right")
			subject = "prawa strona ciała"
			paralysis_traits = list(TRAIT_PARALYSIS_R_ARM, TRAIT_PARALYSIS_R_LEG)
		if("arms")
			subject = "ręce"
			paralysis_traits = list(TRAIT_PARALYSIS_L_ARM, TRAIT_PARALYSIS_R_ARM)
		if("legs")
			subject = "nogi"
			paralysis_traits = list(TRAIT_PARALYSIS_L_LEG, TRAIT_PARALYSIS_R_LEG)
		if("r_arm")
			subject = "prawa ręka"
			paralysis_traits = list(TRAIT_PARALYSIS_R_ARM)
		if("l_arm")
			subject = "lewa ręka"
			paralysis_traits = list(TRAIT_PARALYSIS_L_ARM)
		if("r_leg")
			subject = "prawa noga"
			paralysis_traits = list(TRAIT_PARALYSIS_R_LEG)
		if("l_leg")
			subject = "lewa noga"
			paralysis_traits = list(TRAIT_PARALYSIS_L_LEG)

	gain_text = "<span class='warning'>Tracisz czucie: [subject]!</span>"
	lose_text = "<span class='notice'>Odzyskujesz czucie: [subject]!</span>"

/datum/brain_trauma/severe/paralysis/on_gain()
	..()
	for(var/X in paralysis_traits)
		ADD_TRAIT(owner, X, "trauma_paralysis")
	owner.update_disabled_bodyparts()

/datum/brain_trauma/severe/paralysis/on_lose()
	..()
	for(var/X in paralysis_traits)
		REMOVE_TRAIT(owner, X, "trauma_paralysis")
	owner.update_disabled_bodyparts()

/datum/brain_trauma/severe/paralysis/paraplegic
	random_gain = FALSE
	paralysis_type = "legs"
	resilience = TRAUMA_RESILIENCE_ABSOLUTE

/datum/brain_trauma/severe/narcolepsy
	name = "Narcolepsy"
	desc = "Patient may involuntarily fall asleep during normal activities."
	scan_desc = "urazowa narkolepsja"
	gain_text = "<span class='warning'>Ciągle czujesz senność...</span>"
	lose_text = "<span class='notice'>Znów czujesz się rozbudzony i przytomny.</span>"

/datum/brain_trauma/severe/narcolepsy/on_life()
	..()
	if(owner.IsSleeping())
		return
	var/sleep_chance = 1
	if(owner.m_intent == MOVE_INTENT_RUN)
		sleep_chance += 2
	if(owner.drowsyness)
		sleep_chance += 3
	if(prob(sleep_chance))
		to_chat(owner, "<span class='warning'>Zasypiasz.</span>")
		owner.Sleeping(60)
	else if(!owner.drowsyness && prob(sleep_chance * 2))
		to_chat(owner, "<span class='warning'>Czujesz się zmęczony...</span>")
		owner.drowsyness += 10

/datum/brain_trauma/severe/monophobia
	name = "Monophobia"
	desc = "Patient feels sick and distressed when not around other people, leading to potentially lethal levels of stress."
	scan_desc = "monophobia"
	gain_text = ""
	lose_text = "<span class='notice'>Czujesz, że sam też byłbyś bezpieczny.</span>"
	var/stress = 0

/datum/brain_trauma/severe/monophobia/on_gain()
	..()
	if(check_alone())
		to_chat(owner, "<span class='warning'>Czujesz się bardzo samotny...</span>")
	else
		to_chat(owner, "<span class='notice'>Czujesz się bezpiecznie, dopóki masz wokół siebie ludzi.</span>")

/datum/brain_trauma/severe/monophobia/on_life()
	..()
	if(check_alone())
		stress = min(stress + 0.5, 100)
		if(stress > 10 && (prob(5)))
			stress_reaction()
	else
		stress = max(stress - 4, 0)

/datum/brain_trauma/severe/monophobia/proc/check_alone()
	if(HAS_TRAIT(owner, TRAIT_BLIND))
		return TRUE
	for(var/mob/living/M in oview(7, owner))
		if((istype(M, /mob/living/simple_animal/pet)) || M.ckey)
			return FALSE
	return TRUE

/datum/brain_trauma/severe/monophobia/proc/stress_reaction()
	if(owner.stat != CONSCIOUS)
		return

	var/high_stress = (stress > 60) //things get psychosomatic from here on
	switch(rand(1, 6))
		if(1)
			if(!high_stress)
				to_chat(owner, "<span class='warning'>Czujesz się chory...</span>")
			else
				to_chat(owner, "<span class='warning'>Na samą myśl o samotności robi ci się niedobrze!</span>")
			addtimer(CALLBACK(owner, TYPE_PROC_REF(/mob/living/carbon, vomit), high_stress), 50) //blood vomit if high stress
		if(2)
			if(!high_stress)
				to_chat(owner, "<span class='warning'>Nie możesz przestać się trząść...</span>")
				owner.dizziness += 20
				owner.confused += 20
				owner.Jitter(20)
			else
				to_chat(owner, "<span class='warning'>Czujesz się słaby i przestraszony! Gdybyś tylko nie był sam...</span>")
				owner.dizziness += 20
				owner.confused += 20
				owner.Jitter(20)
				owner.adjustStaminaLoss(50)

		if(3, 4)
			if(!high_stress)
				to_chat(owner, "<span class='warning'>Czujesz się bardzo samotny...</span>")
			else
				to_chat(owner, "<span class='warning'>Wariujesz z samotności!</span>")
				owner.hallucination += 30

		if(5)
			if(!high_stress)
				to_chat(owner, "<span class='warning'>Twoje serce gubi rytm.</span>")
				owner.adjustOxyLoss(8)
			else
				if(prob(15) && ishuman(owner))
					var/mob/living/carbon/human/H = owner
					H.set_heartattack(TRUE)
					to_chat(H, "<span class='userdanger'>Czujesz kłujący ból w sercu!</span>")
				else
					to_chat(owner, "<span class='userdanger'>Czujesz, jak serce podskakuje ci w piersi...</span>")
					owner.adjustOxyLoss(8)
		else
			SWITCH_EMPTY_STATEMENT

/datum/brain_trauma/severe/discoordination
	name = "Discoordination"
	desc = "Patient is unable to use complex tools or machinery."
	scan_desc = "skrajne zaburzenie koordynacji"
	gain_text = "<span class='warning'>Ledwo panujesz nad rękami!</span>"
	lose_text = "<span class='notice'>Znów panujesz nad rękami.</span>"

/datum/brain_trauma/severe/discoordination/on_gain()
	ADD_TRAIT(owner, TRAIT_DISCOORDINATED, TRAUMA_TRAIT) // AQ EDIT (TRAIT_MONKEYLIKE -> TRAIT_DISCOORDINATED)
	..()

/datum/brain_trauma/severe/discoordination/on_lose()
	REMOVE_TRAIT(owner, TRAIT_DISCOORDINATED, TRAUMA_TRAIT) // AQ EDIT (TRAIT_MONKEYLIKE -> TRAIT_DISCOORDINATED)
	..()

/datum/brain_trauma/severe/pacifism
	name = "Traumatic Non-Violence"
	desc = "Patient is extremely unwilling to harm others in violent ways."
	scan_desc = "syndrom pacyfistyczny"
	gain_text = "<span class='userdanger'>Nie chcesz już krzywdzić innych!</span>"
	lose_text = "<span class='notice'>Nie czujesz już przymusu, by nie krzywdzić.</span>"

/datum/brain_trauma/severe/pacifism/on_gain()
	ADD_TRAIT(owner, TRAIT_PACIFISM, TRAUMA_TRAIT)
	..()

/datum/brain_trauma/severe/pacifism/on_lose()
	REMOVE_TRAIT(owner, TRAIT_PACIFISM, TRAUMA_TRAIT)
	..()

/datum/brain_trauma/severe/hypnotic_stupor
	name = "Hypnotic Stupor"
	desc = "Patient is prone to episodes of extreme stupor that leaves them extremely suggestible."
	scan_desc = "oniryczna pętla sprzężenia zwrotnego"
	gain_text = "<span class='warning'>Czujesz się nieco oszołomiony.</span>"
	lose_text = "<span class='notice'>Czujesz, jakby mgła opadła z twojego umysłu.</span>"

/datum/brain_trauma/severe/hypnotic_stupor/on_lose() //hypnosis must be cleared separately, but brain recalibration should get rid of both anyway
	..()
	owner.remove_status_effect(/datum/status_effect/trance)

/datum/brain_trauma/severe/hypnotic_stupor/on_life()
	..()
	if(prob(1) && !owner.has_status_effect(/datum/status_effect/trance))
		owner.apply_status_effect(/datum/status_effect/trance, rand(100,300), FALSE)
