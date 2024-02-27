/datum/species
	var/gendered_speech = FALSE	// If true, will play different speech sounds based on gender.
	var/speech_sound = ""

/datum/species/proc/handle_digestion(mob/living/carbon/human/H)
	if(HAS_TRAIT(H, TRAIT_EAT_MORE))
			hunger_rate *= 3 //hunger rate tripled
	if(HAS_TRAIT(H, TRAIT_BOTTOMLESS_STOMACH))
		H.nutrition = min(H.nutrition, NUTRITION_LEVEL_MOSTLY_FULL)
	.=..()


/datum/species/proc/eat_text(fullness, eatverb, obj/O, mob/living/carbon/C, mob/user)
	if(C == user)
		if(fullness<=50)
			user.visible_message(span_notice("[user] frantically [eatverb]s \the [O], scarfing it down!"), span_notice("You frantically [eatverb] \the [O], scarfing it down!"))
		else if((fullness > 50 && fullness < 150) || HAS_TRAIT(C, TRAIT_BOTTOMLESS_STOMACH))
			user.visible_message(span_notice("[user] hungrily [eatverb]s \the [O]."), span_notice("You hungrily [eatverb] \the [O]."))
		else if(fullness > 500 && fullness < 600)
			user.visible_message(span_notice("[user] unwillingly [eatverb]s a bit of \the [O]."), span_notice("You unwillingly [eatverb] a bit of \the [O]."))
		else if(fullness > (600 * (1 + C.overeatduration / 2000)))	// The more you eat - the more you can eat
			user.visible_message(span_warning("[user] cannot force any more of \the [O] to go down [user.p_their()] throat!"), span_warning("You cannot force any more of \the [O] to go down your throat!"))
			return FALSE
	.=..()
