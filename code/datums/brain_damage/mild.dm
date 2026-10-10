//Mild traumas are the most common; they are generally minor annoyances.
//They can be cured with mannitol and patience, although brain recalibration still works.
//Most of the old brain damage effects have been transferred to the dumbness trauma.

/datum/brain_trauma/mild

/datum/brain_trauma/mild/hallucinations
	name = "Hallucinations"
	desc = "Patient suffers constant hallucinations."
	scan_desc = "schizophrenia"
	gain_text = "<span class='warning'>Czujesz, że tracisz kontakt z rzeczywistością...</span>"
	lose_text = "<span class='notice'>Czujesz się bardziej ugruntowany.</span>"

/datum/brain_trauma/mild/hallucinations/on_life()
	owner.hallucination = min(owner.hallucination + 10, 50)
	..()

/datum/brain_trauma/mild/hallucinations/on_lose()
	owner.hallucination = 0
	..()

/datum/brain_trauma/mild/stuttering
	name = "Stuttering"
	desc = "Patient can't speak properly."
	scan_desc = "osłabiona koordynacja ust"
	gain_text = "<span class='warning'>Coraz trudniej ci wyraźnie mówić.</span>"
	lose_text = "<span class='notice'>Panujesz nad swoją mową.</span>"

/datum/brain_trauma/mild/stuttering/on_life()
	owner.stuttering = min(owner.stuttering + 5, 25)
	..()

/datum/brain_trauma/mild/stuttering/on_lose()
	owner.stuttering = 0
	..()

/datum/brain_trauma/mild/dumbness
	name = "Dumbness"
	desc = "Patient has reduced brain activity, making them less intelligent."
	scan_desc = "obniżona aktywność mózgu"
	gain_text = "<span class='warning'>Czujesz się głupszy.</span>"
	lose_text = "<span class='notice'>Znów czujesz się mądry.</span>"

/datum/brain_trauma/mild/dumbness/on_gain()
	ADD_TRAIT(owner, TRAIT_DUMB, TRAUMA_TRAIT)
	SEND_SIGNAL(owner, COMSIG_ADD_MOOD_EVENT, "dumb", /datum/mood_event/oblivious)
	..()

/datum/brain_trauma/mild/dumbness/on_life()
	owner.derpspeech = min(owner.derpspeech + 5, 25)
	if(prob(3))
		owner.emote("drool")
	else if(owner.stat == CONSCIOUS && prob(3))
		owner.say(pick_list_replacements(BRAIN_DAMAGE_FILE, "brain_damage"), forced = "uszkodzenie mózgu")
	..()

/datum/brain_trauma/mild/dumbness/on_lose()
	REMOVE_TRAIT(owner, TRAIT_DUMB, TRAUMA_TRAIT)
	owner.derpspeech = 0
	SEND_SIGNAL(owner, COMSIG_CLEAR_MOOD_EVENT, "dumb")
	..()

/datum/brain_trauma/mild/speech_impediment
	name = "Speech Impediment"
	desc = "Patient is unable to form coherent sentences."
	scan_desc = "zaburzenie komunikacji"
	gain_text = "<span class='danger'>Nie potrafisz ułożyć żadnej spójnej myśli!</span>"
	lose_text = "<span class='danger'>Twój umysł wydaje się jaśniejszy.</span>"

/datum/brain_trauma/mild/speech_impediment/on_gain()
	ADD_TRAIT(owner, TRAIT_UNINTELLIGIBLE_SPEECH, TRAUMA_TRAIT)
	..()

/datum/brain_trauma/mild/speech_impediment/on_lose()
	REMOVE_TRAIT(owner, TRAIT_UNINTELLIGIBLE_SPEECH, TRAUMA_TRAIT)
	..()

/datum/brain_trauma/mild/concussion
	name = "Concussion"
	desc = "Patient's brain is concussed."
	scan_desc = "concussion"
	gain_text = "<span class='warning'>Boli cię głowa!</span>"
	lose_text = "<span class='notice'>Ucisk w twojej głowie zaczyna słabnąć.</span>"

/datum/brain_trauma/mild/concussion/on_life()
	if(prob(5))
		switch(rand(1,11))
			if(1)
				owner.vomit()
			if(2,3)
				owner.dizziness += 10
			if(4,5)
				owner.confused += 10
				owner.blur_eyes(10)
			if(6 to 9)
				owner.slurring += 30
			if(10)
				to_chat(owner, "<span class='notice'>Przez chwilę zapominasz, co robiłeś.</span>")
				owner.Stun(20)
			if(11)
				to_chat(owner, "<span class='warning'>Mdlejesz.</span>")
				owner.Unconscious(80)

	..()

/datum/brain_trauma/mild/healthy
	name = "Anosognosia"
	desc = "Patient always feels healthy, regardless of their condition."
	scan_desc = "deficyt samoświadomości"
	gain_text = "<span class='notice'>Czujesz się świetnie!</span>"
	lose_text = "<span class='warning'>Nie czujesz się już w pełni zdrowy.</span>"

/datum/brain_trauma/mild/healthy/on_gain()
	owner.set_screwyhud(SCREWYHUD_HEALTHY)
	..()

/datum/brain_trauma/mild/healthy/on_life()
	owner.set_screwyhud(SCREWYHUD_HEALTHY) //just in case of hallucinations
	owner.adjustStaminaLoss(-5) //no pain, no fatigue
	..()

/datum/brain_trauma/mild/healthy/on_lose()
	owner.set_screwyhud(SCREWYHUD_NONE)
	..()

/datum/brain_trauma/mild/muscle_weakness
	name = "Muscle Weakness"
	desc = "Patient experiences occasional bouts of muscle weakness."
	scan_desc = "słaby sygnał nerwów ruchowych"
	gain_text = "<span class='warning'>Twoje mięśnie wydają się dziwnie słabe.</span>"
	lose_text = "<span class='notice'>Znów panujesz nad mięśniami.</span>"

/datum/brain_trauma/mild/muscle_weakness/on_life()
	var/fall_chance = 1
	if(owner.m_intent == MOVE_INTENT_RUN)
		fall_chance += 2
	if(prob(fall_chance) && (owner.mobility_flags & MOBILITY_STAND))
		to_chat(owner, "<span class='warning'>Noga się pod tobą ugina!</span>")
		owner.Paralyze(35)

	else if(owner.get_active_held_item())
		var/drop_chance = 1
		var/obj/item/I = owner.get_active_held_item()
		drop_chance += I.w_class
		if(prob(drop_chance) && owner.dropItemToGround(I))
			to_chat(owner, "<span class='warning'>Upuszczasz [I]!</span>")

	else if(prob(3))
		to_chat(owner, "<span class='warning'>Czujesz nagłą słabość w mięśniach!</span>")
		owner.adjustStaminaLoss(50)
	..()

/datum/brain_trauma/mild/muscle_spasms
	name = "Muscle Spasms"
	desc = "Patient has occasional muscle spasms, causing them to move unintentionally."
	scan_desc = "ataki nerwowe"
	gain_text = "<span class='warning'>Twoje mięśnie wydają się dziwnie słabe.</span>"
	lose_text = "<span class='notice'>Znów panujesz nad mięśniami.</span>"

/datum/brain_trauma/mild/muscle_spasms/on_gain()
	owner.apply_status_effect(STATUS_EFFECT_SPASMS)
	..()

/datum/brain_trauma/mild/muscle_spasms/on_lose()
	owner.remove_status_effect(STATUS_EFFECT_SPASMS)
	..()

/datum/brain_trauma/mild/nervous_cough
	name = "Nervous Cough"
	desc = "Patient feels a constant need to cough."
	scan_desc = "kaszel nerwowy"
	gain_text = "<span class='warning'>Gardło nieustannie cię swędzi.</span>"
	lose_text = "<span class='notice'>Gardło przestaje cię swędzieć.</span>"

/datum/brain_trauma/mild/nervous_cough/on_life()
	if(prob(12) && !HAS_TRAIT(owner, TRAIT_SOOTHED_THROAT))
		if(prob(5))
			to_chat(owner, "<span notice='warning'>[pick("You have a coughing fit!", "You can't stop coughing!")]</span>")
			owner.Immobilize(20)
			owner.emote("cough")
			addtimer(CALLBACK(owner, TYPE_PROC_REF(/mob, emote), "cough"), 6)
			addtimer(CALLBACK(owner, TYPE_PROC_REF(/mob, emote), "cough"), 12)
		owner.emote("cough")
	..()

/datum/brain_trauma/mild/expressive_aphasia
	name = "Expressive Aphasia"
	desc = "Patient is affected by partial loss of speech leading to a reduced vocabulary."
	scan_desc = "niezdolność do tworzenia złożonych zdań"
	gain_text = "<span class='warning'>Tracisz zdolność posługiwania się złożonymi słowami.</span>"
	lose_text = "<span class='notice'>Czujesz, że twoje słownictwo wraca do normy.</span>"

	var/static/list/common_words = world.file2list("strings/1000_most_common.txt")

/datum/brain_trauma/mild/expressive_aphasia/handle_speech(datum/source, list/speech_args)
	var/message = speech_args[SPEECH_MESSAGE]
	if(message)
		var/list/message_split = splittext(message, " ")
		var/list/new_message = list()

		for(var/word in message_split)
			var/suffix = ""
			var/suffix_foundon = 0
			for(var/potential_suffix in list("." , "," , ";" , "!" , ":" , "?"))
				suffix_foundon = findtext(word, potential_suffix, -length(potential_suffix))
				if(suffix_foundon)
					suffix = potential_suffix
					break

			if(suffix_foundon)
				word = copytext(word, 1, suffix_foundon)
			word = html_decode(word)

			if(lowertext(word) in common_words)
				new_message += word + suffix
			else
				if(prob(30) && message_split.len > 2)
					new_message += pick("uh","erm")
					break
				else
					var/list/charlist = text2charlist(word)
					charlist.len = round(charlist.len * 0.5, 1)
					shuffle_inplace(charlist)
					new_message += jointext(charlist, "") + suffix

		message = jointext(new_message, " ")

	speech_args[SPEECH_MESSAGE] = trim(message)
