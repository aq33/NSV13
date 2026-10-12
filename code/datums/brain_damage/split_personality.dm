#define OWNER 0
#define STRANGER 1

/datum/brain_trauma/severe/split_personality
	name = "Split Personality"
	desc = "Patient's brain is split into two personalities, which randomly switch control of the body."
	scan_desc = "całkowite rozdzielenie płatów"
	gain_text = "<span class='warning'>Czujesz, jakby twój umysł podzielono na dwoje.</span>"
	lose_text = "<span class='notice'>Znów czujesz się samotny.</span>"
	var/current_controller = OWNER
	var/initialized = FALSE //to prevent personalities deleting themselves while we wait for ghosts
	var/mob/living/split_personality/stranger_backseat //there's two so they can swap without overwriting
	var/mob/living/split_personality/owner_backseat

/datum/brain_trauma/severe/split_personality/on_gain()
	..()
	make_backseats()
	get_ghost()

/datum/brain_trauma/severe/split_personality/proc/make_backseats()
	stranger_backseat = new(owner, src)
	var/obj/effect/proc_holder/spell/targeted/personality_commune/stranger_spell = new(src)
	stranger_backseat.AddSpell(stranger_spell)

	owner_backseat = new(owner, src)
	var/obj/effect/proc_holder/spell/targeted/personality_commune/owner_spell = new(src)
	owner_backseat.AddSpell(owner_spell)

/datum/brain_trauma/severe/split_personality/proc/get_ghost()
	set waitfor = FALSE
	if(owner.stat == DEAD || !owner.mind)
		qdel(src)
		return
	var/list/mob/dead/observer/candidates = pollCandidatesForMob("Chcesz zagrać jako rozszczepiona osobowość [owner]?", ROLE_SPLIT_PERSONALITY, null, 7.5 SECONDS, stranger_backseat)
	if(LAZYLEN(candidates))
		var/mob/dead/observer/C = pick(candidates)
		stranger_backseat.key = C.key
		log_game("[key_name(stranger_backseat)] became [key_name(owner)]'s split personality.")
		message_admins("[ADMIN_LOOKUPFLW(stranger_backseat)] became [ADMIN_LOOKUPFLW(owner)]'s split personality.")
	else
		qdel(src)

/datum/brain_trauma/severe/split_personality/on_life()
	if(owner.stat == DEAD)
		if(current_controller != OWNER)
			switch_personalities()
		qdel(src)
	else if(prob(3))
		switch_personalities()
	..()

/datum/brain_trauma/severe/split_personality/on_lose()
	if(current_controller != OWNER) //it would be funny to cure a guy only to be left with the other personality, but it seems too cruel
		switch_personalities()
	QDEL_NULL(stranger_backseat)
	QDEL_NULL(owner_backseat)
	..()

/datum/brain_trauma/severe/split_personality/Destroy()
	if(stranger_backseat)
		QDEL_NULL(stranger_backseat)
	if(owner_backseat)
		QDEL_NULL(owner_backseat)
	return ..()

/datum/brain_trauma/severe/split_personality/proc/switch_personalities()
	if(QDELETED(owner) || owner.stat == DEAD || QDELETED(stranger_backseat) || QDELETED(owner_backseat))
		return

	var/mob/living/split_personality/current_backseat
	var/mob/living/split_personality/free_backseat
	if(current_controller == OWNER)
		current_backseat = stranger_backseat
		free_backseat = owner_backseat
	else
		current_backseat = owner_backseat
		free_backseat = stranger_backseat

	log_game("[key_name(current_backseat)] assumed control of [key_name(owner)] due to [src]. (Original owner: [current_controller == OWNER ? owner.key : current_backseat.key])")
	to_chat(owner, "<span class='userdanger'>Czujesz, jak tracisz kontrolę... teraz rządzi twoja druga osobowość!</span>")
	to_chat(current_backseat, "<span class='userdanger'>Udaje ci się przejąć kontrolę nad ciałem!</span>")

	//Body to backseat

	var/h2b_id = owner.computer_id
	var/h2b_ip= owner.lastKnownIP
	owner.computer_id = null
	owner.lastKnownIP = null

	free_backseat.ckey = owner.ckey

	free_backseat.name = owner.name

	if(owner.mind)
		free_backseat.mind = owner.mind

	if(!free_backseat.computer_id)
		free_backseat.computer_id = h2b_id

	if(!free_backseat.lastKnownIP)
		free_backseat.lastKnownIP = h2b_ip

	//Backseat to body

	var/s2h_id = current_backseat.computer_id
	var/s2h_ip= current_backseat.lastKnownIP
	current_backseat.computer_id = null
	current_backseat.lastKnownIP = null

	owner.ckey = current_backseat.ckey
	owner.mind = current_backseat.mind

	if(!owner.computer_id)
		owner.computer_id = s2h_id

	if(!owner.lastKnownIP)
		owner.lastKnownIP = s2h_ip

	current_controller = !current_controller


/mob/living/split_personality
	name = "split personality"
	real_name = "nieznane sumienie"
	var/mob/living/carbon/body
	var/datum/brain_trauma/severe/split_personality/trauma

/mob/living/split_personality/Initialize(mapload, _trauma)
	if(iscarbon(loc))
		body = loc
		name = body.real_name
		real_name = body.real_name
		trauma = _trauma
	return ..()

/mob/living/split_personality/Life()
	if(QDELETED(body))
		qdel(src) //in case trauma deletion doesn't already do it

	if((body.stat == DEAD && trauma.owner_backseat == src))
		trauma.switch_personalities()
		qdel(trauma)

	//if one of the two ghosts, the other one stays permanently
	if(!body.client && trauma.initialized)
		trauma.switch_personalities()
		qdel(trauma)

	..()

/mob/living/split_personality/Login()
	..()
	to_chat(src, "<span class='notice'>Jako rozszczepiona osobowość możesz tylko obserwować. Jednak w końcu przejmiesz kontrolę nad ciałem, zamieniając się miejscami z obecną osobowością.</span>")
	to_chat(src, "<span class='warning'><b>Nie popełniaj samobójstwa ani nie stawiaj ciała w śmiertelnym położeniu. Zachowuj się tak, jakby zależało ci na nim tak samo jak właścicielowi.</b></span>")

/mob/living/split_personality/say(message, bubble_type, var/list/spans = list(), sanitize = TRUE, datum/language/language = null, ignore_spam = FALSE, forced = null)
	to_chat(src, "<span class='warning'>Nie możesz mówić, twoje drugie ja kontroluje ciało!</span>")
	return FALSE

/mob/living/split_personality/emote(act, m_type = null, message = null, intentional = FALSE)
	return FALSE // AQ EDIT

///////////////BRAINWASHING////////////////////

/datum/brain_trauma/severe/split_personality/brainwashing
	name = "Split Personality"
	desc = "Patient's brain is split into two personalities, which randomly switch control of the body."
	scan_desc = "całkowite rozdzielenie płatów"
	gain_text = ""
	lose_text = "<span class='notice'>Jesteś wolny od prania mózgu.</span>"
	can_gain = FALSE
	var/codeword
	var/objective

/datum/brain_trauma/severe/split_personality/brainwashing/New(obj/item/organ/brain/B, _permanent, _codeword, _objective)
	..()
	if(_codeword)
		codeword = _codeword
	else
		codeword = pick(strings(ION_LAWS_FILE, "ionabstract")\
			| strings(ION_LAWS_FILE, "ionobjects")\
			| strings(ION_LAWS_FILE, "ionadjectives")\
			| strings(ION_LAWS_FILE, "ionthreats")\
			| strings(ION_LAWS_FILE, "ionfood")\
			| strings(ION_LAWS_FILE, "iondrinks"))

/datum/brain_trauma/severe/split_personality/brainwashing/on_gain()
	..()
	var/mob/living/split_personality/traitor/traitor_backseat = stranger_backseat
	traitor_backseat.codeword = codeword
	traitor_backseat.objective = objective

/datum/brain_trauma/severe/split_personality/brainwashing/make_backseats()
	stranger_backseat = new /mob/living/split_personality/traitor(owner, src, codeword, objective)
	owner_backseat = new(owner, src)

/datum/brain_trauma/severe/split_personality/brainwashing/get_ghost()
	set waitfor = FALSE
	var/list/mob/dead/observer/candidates = pollCandidatesForMob("Chcesz zagrać jako wyprany umysł [owner]?", ROLE_TRAITOR, null, 7.5 SECONDS, stranger_backseat, ignore_category = FALSE)
	if(LAZYLEN(candidates))
		var/mob/dead/observer/C = pick(candidates)
		stranger_backseat.key = C.key
	else
		qdel(src)

/datum/brain_trauma/severe/split_personality/brainwashing/on_life()
	return //no random switching

/datum/brain_trauma/severe/split_personality/brainwashing/handle_hearing(datum/source, list/hearing_args)
	if(HAS_TRAIT(owner, TRAIT_DEAF) || owner == hearing_args[HEARING_SPEAKER])
		return
	var/message = hearing_args[HEARING_RAW_MESSAGE]
	if(findtext(message, codeword))
		hearing_args[HEARING_RAW_MESSAGE] = replacetext(message, codeword, "<span class='warning'>[codeword]</span>")
		addtimer(CALLBACK(src, TYPE_PROC_REF(/datum/brain_trauma/severe/split_personality, switch_personalities)), 10)

/datum/brain_trauma/severe/split_personality/brainwashing/handle_speech(datum/source, list/speech_args)
	if(findtext(speech_args[SPEECH_MESSAGE], codeword))
		speech_args[SPEECH_MESSAGE] = "" //oh hey did you want to tell people about the secret word to bring you back?

/mob/living/split_personality/traitor
	name = "split personality"
	real_name = "nieznane sumienie"
	var/objective
	var/codeword

/mob/living/split_personality/traitor/Login()
	..()
	to_chat(src, "<span class='notice'>Jako wyprana osobowość możesz na razie tylko obserwować. Możesz jednak przejąć kontrolę nad ciałem, gdy usłyszysz specjalne słowo-klucz, zamieniając się miejscami z obecną osobowością.</span>")
	to_chat(src, "<span class='notice'>Twoje słowo aktywacyjne to: <b>[codeword]</b></span>")
	if(objective)
		to_chat(src, "<span class='notice'>Twój pan zostawił ci cel: <b>[objective]</b>. Gdy masz kontrolę, wykonuj go za wszelką cenę.</span>")

#undef OWNER
#undef STRANGER
