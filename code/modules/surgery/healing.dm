/datum/surgery/healing
	steps = list(/datum/surgery_step/incise,
				/datum/surgery_step/retract_skin,
				/datum/surgery_step/incise,
				/datum/surgery_step/clamp_bleeders,
				/datum/surgery_step/heal,
				/datum/surgery_step/close)

	target_mobtypes = list(/mob/living/carbon/human, /mob/living/carbon/monkey)
	possible_locs = list(BODY_ZONE_CHEST)
	requires_bodypart_type = FALSE
	replaced_by = /datum/surgery
	ignore_clothes = TRUE
	var/healing_step_type
	var/antispam = FALSE

/datum/surgery/healing/New(surgery_target, surgery_location, surgery_bodypart)
	..()
	if(healing_step_type)
		steps = list(/datum/surgery_step/incise/nobleed,
					healing_step_type, //hehe cheeky
					/datum/surgery_step/close)

/datum/surgery_step/heal
	name = "repair body"
	implements = list(TOOL_HEMOSTAT = 100, TOOL_SCREWDRIVER = 35, /obj/item/pen = 15)
	repeatable = TRUE
	time = 25
	var/brutehealing = 0
	var/burnhealing = 0
	var/missinghpbonus = 0 //heals an extra point of damager per X missing damage of type (burn damage for burn healing, brute for brute). Smaller Number = More Healing!

/datum/surgery_step/heal/proc/get_progress(mob/user, mob/living/carbon/target, brute_healed, burn_healed)
	return

/datum/surgery_step/heal/preop(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	var/woundtype
	if(brutehealing && burnhealing)
		woundtype = "wounds"
	else if(brutehealing)
		woundtype = "bruises"
	else //why are you trying to 0,0...?
		woundtype = "burns"
	if(istype(surgery,/datum/surgery/healing))
		var/datum/surgery/healing/the_surgery = surgery
		if(!the_surgery.antispam)
			display_results(user, target, "<span class='notice'>Próbujesz opatrzyć część obrażeń [target] ([woundtype]).</span>",
		"[user] próbuje opatrzyć część obrażeń [target] ([woundtype]).",
		"[user] próbuje opatrzyć część obrażeń [target] ([woundtype]).")


/datum/surgery_step/heal/initiate(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery, try_to_fail = FALSE)
	if(..())
		while((brutehealing && target.getBruteLoss()) || (burnhealing && target.getFireLoss()))
			if(!..())
				break

/datum/surgery_step/heal/success(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	var/umsg = "Udaje ci się opatrzyć część ran [target]" //no period, add initial space to "addons"
	var/tmsg = "[user] opatruje część ran [target]" //see above
	var/urhealedamt_brute = brutehealing
	var/urhealedamt_burn = burnhealing
	if(missinghpbonus)
		if(target.stat != DEAD)
			urhealedamt_brute += round((target.getBruteLoss()/ missinghpbonus),0.1)
			urhealedamt_burn += round((target.getFireLoss()/ missinghpbonus),0.1)
		else //less healing bonus for the dead since they're expected to have lots of damage to begin with (to make TW into defib not TOO simple)
			urhealedamt_brute += round((target.getBruteLoss()/ (missinghpbonus*5)),0.1)
			urhealedamt_burn += round((target.getFireLoss()/ (missinghpbonus*5)),0.1)
	if(!get_location_accessible(target, target_zone))
		urhealedamt_brute *= 0.55
		urhealedamt_burn *= 0.55
		umsg += " najlepiej, jak potrafisz, gdy pacjent ma na sobie ubranie"
		tmsg += " najlepiej, jak potrafi, gdy pacjent ma na sobie ubranie"
	target.heal_bodypart_damage(urhealedamt_brute,urhealedamt_burn)
	umsg += get_progress(user, target, urhealedamt_brute, urhealedamt_burn)

	display_results(user, target, "<span class='notice'>[umsg].</span>",
		"[tmsg].",
		"[tmsg].")
	if(istype(surgery, /datum/surgery/healing))
		var/datum/surgery/healing/the_surgery = surgery
		the_surgery.antispam = TRUE
	return TRUE

/datum/surgery_step/heal/failure(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	display_results(user, target, "<span class='warning'>Partaczysz!</span>",
		"<span class='warning'>[user] partaczy!</span>",
		"<span class='notice'>[user] opatruje część ran [target].</span>", TRUE)
	var/urdamageamt_burn = brutehealing * 0.8
	var/urdamageamt_brute = burnhealing * 0.8
	if(missinghpbonus)
		urdamageamt_brute += round((target.getBruteLoss()/ (missinghpbonus*2)),0.1)
		urdamageamt_burn += round((target.getFireLoss()/ (missinghpbonus*2)),0.1)

	target.take_bodypart_damage(urdamageamt_brute, urdamageamt_burn)
	return FALSE

/***************************BRUTE***************************/
/datum/surgery/healing/brute
	name = "Tend Wounds (Bruises)"

/datum/surgery/healing/brute/basic
	name = "Tend Wounds (Bruises, Basic)"
	replaced_by = /datum/surgery/healing/brute/upgraded
	healing_step_type = /datum/surgery_step/heal/brute/basic
	desc = "A surgical procedure that provides basic treatment for a patient's brute traumas. Heals slightly more when the patient is severely injured."

/datum/surgery/healing/brute/upgraded
	name = "Tend Wounds (Bruises, Adv.)"
	replaced_by = /datum/surgery/healing/brute/upgraded/femto
	requires_tech = TRUE
	healing_step_type = /datum/surgery_step/heal/brute/upgraded
	desc = "A surgical procedure that provides advanced treatment for a patient's brute traumas. Heals more when the patient is severely injured."

/datum/surgery/healing/brute/upgraded/femto
	name = "Tend Wounds (Bruises, Exp.)"
	replaced_by = /datum/surgery/healing/combo/upgraded/femto
	requires_tech = TRUE
	healing_step_type = /datum/surgery_step/heal/brute/upgraded/femto
	desc = "A surgical procedure that provides experimental treatment for a patient's brute traumas. Heals considerably more when the patient is severely injured."

/********************BRUTE STEPS********************/
/datum/surgery_step/heal/brute/get_progress(mob/user, mob/living/carbon/target, brute_healed, burn_healed)
	if(!brute_healed)
		return

	var/estimated_remaining_steps = target.getBruteLoss() / brute_healed
	var/progress_text
	if(locate(/obj/item/healthanalyzer) in user.held_items)
		progress_text = ". Pozostałe urazy: <font color='#ff3333'>[target.getBruteLoss()]</font>"
	else
		switch(estimated_remaining_steps)
			if(-INFINITY to 1)
				return
			if(1 to 3)
				progress_text = ", zszywając ostatnie zadrapania"
			if(3 to 6)
				progress_text = ", odliczając ostatnie siniaki do opatrzenia"
			if(6 to 9)
				progress_text = ", dalej zmagając się z rozległymi rozerwaniami"
			if(9 to 12)
				progress_text = ", szykując się na długą operację"
			if(12 to 15)
				progress_text = ", choć pacjent wciąż bardziej przypomina mielone niż człowieka"
			if(15 to INFINITY)
				progress_text = ", choć masz wrażenie, że ledwo zaczynasz leczyć to zmasakrowane ciało"

	return progress_text

/datum/surgery_step/heal/brute/basic
	name = "tend bruises"
	brutehealing = 5
	missinghpbonus = 15
	preop_sound = 'sound/surgery/scalpel1.ogg'
	success_sound = 'sound/surgery/retractor2.ogg'
	failure_sound = 'sound/surgery/organ1.ogg'

/datum/surgery_step/heal/brute/upgraded
	brutehealing = 5
	missinghpbonus = 10
	preop_sound = 'sound/surgery/scalpel1.ogg'
	success_sound = 'sound/surgery/retractor2.ogg'
	failure_sound = 'sound/surgery/organ1.ogg'

/datum/surgery_step/heal/brute/upgraded/femto
	brutehealing = 5
	missinghpbonus = 5
	preop_sound = 'sound/surgery/scalpel1.ogg'
	success_sound = 'sound/surgery/retractor2.ogg'
	failure_sound = 'sound/surgery/organ1.ogg'

/***************************BURN***************************/
/datum/surgery/healing/burn
	name = "Tend Wounds (Burn)"

/datum/surgery/healing/burn/basic
	name = "Tend Wounds (Burn, Basic)"
	replaced_by = /datum/surgery/healing/burn/upgraded
	healing_step_type = /datum/surgery_step/heal/burn/basic
	desc = "A surgical procedure that provides basic treatment for a patient's burns. Heals slightly more when the patient is severely injured."

/datum/surgery/healing/burn/upgraded
	name = "Tend Wounds (Burn, Adv.)"
	replaced_by = /datum/surgery/healing/burn/upgraded/femto
	requires_tech = TRUE
	healing_step_type = /datum/surgery_step/heal/burn/upgraded
	desc = "A surgical procedure that provides advanced treatment for a patient's burns. Heals more when the patient is severely injured."

/datum/surgery/healing/burn/upgraded/femto
	name = "Tend Wounds (Burn, Exp.)"
	replaced_by = /datum/surgery/healing/combo/upgraded/femto
	requires_tech = TRUE
	healing_step_type = /datum/surgery_step/heal/burn/upgraded/femto
	desc = "A surgical procedure that provides experimental treatment for a patient's burns. Heals considerably more when the patient is severely injured."

/********************BURN STEPS********************/
/datum/surgery_step/heal/burn/get_progress(mob/user, mob/living/carbon/target, brute_healed, burn_healed)
	if(!burn_healed)
		return

	var/estimated_remaining_steps = target.getFireLoss() / burn_healed
	var/progress_text
	if(locate(/obj/item/healthanalyzer) in user.held_items)
		progress_text = ". Pozostałe oparzenia: <font color='#ff9933'>[target.getFireLoss()]</font>"
	else
		switch(estimated_remaining_steps)
			if(-INFINITY to 1)
				return
			if(1 to 3)
				progress_text = ", kończąc ostatnie ślady przypaleń"
			if(3 to 6)
				progress_text = ", odliczając ostatnie pęcherze do opatrzenia"
			if(6 to 9)
				progress_text = ", dalej zmagając się z dokładnym przypieczeniem"
			if(9 to 12)
				progress_text = ", szykując się na długą operację"
			if(12 to 15)
				progress_text = ", choć pacjent wciąż bardziej przypomina przypalony stek niż człowieka"
			if(15 to INFINITY)
				progress_text = ", choć masz wrażenie, że ledwo zaczynasz leczyć to zwęglone ciało"

	return progress_text

/datum/surgery_step/heal/burn/basic
	name = "tend burn wounds"
	burnhealing = 5
	missinghpbonus = 15
	preop_sound = 'sound/surgery/scalpel1.ogg'
	success_sound = 'sound/surgery/retractor2.ogg'
	failure_sound = 'sound/surgery/organ1.ogg'

/datum/surgery_step/heal/burn/upgraded
	burnhealing = 5
	missinghpbonus = 10
	preop_sound = 'sound/surgery/scalpel1.ogg'
	success_sound = 'sound/surgery/retractor2.ogg'
	failure_sound = 'sound/surgery/organ1.ogg'

/datum/surgery_step/heal/burn/upgraded/femto
	burnhealing = 5
	missinghpbonus = 5
	preop_sound = 'sound/surgery/scalpel1.ogg'
	success_sound = 'sound/surgery/retractor2.ogg'
	failure_sound = 'sound/surgery/organ1.ogg'

/***************************COMBO***************************/
/datum/surgery/healing/combo
	name = "Tend Wounds (Mixture, Basic)"
	replaced_by = /datum/surgery/healing/combo/upgraded
	requires_tech = TRUE
	healing_step_type = /datum/surgery_step/heal/combo
	desc = "A surgical procedure that provides basic treatment for a patient's burns and brute traumas. Heals slightly more when the patient is severely injured."

/datum/surgery/healing/combo/upgraded
	name = "Tend Wounds (Mixture, Adv.)"
	replaced_by = /datum/surgery/healing/combo/upgraded/femto
	healing_step_type = /datum/surgery_step/heal/combo/upgraded
	desc = "A surgical procedure that provides advanced treatment for a patient's burns and brute traumas. Heals more when the patient is severely injured."


/datum/surgery/healing/combo/upgraded/femto //no real reason to type it like this except consistency, don't worry you're not missing anything
	name = "Tend Wounds (Mixture, Exp.)"
	replaced_by = null
	healing_step_type = /datum/surgery_step/heal/combo/upgraded/femto
	desc = "A surgical procedure that provides experimental treatment for a patient's burns and brute traumas. Heals considerably more when the patient is severely injured."

/********************COMBO STEPS********************/
/datum/surgery_step/heal/combo/get_progress(mob/user, mob/living/carbon/target, brute_healed, burn_healed)
	var/estimated_remaining_steps = 0
	if(brute_healed > 0)
		estimated_remaining_steps = max(0, (target.getBruteLoss() / brute_healed))
	if(burn_healed > 0)
		estimated_remaining_steps = max(estimated_remaining_steps, (target.getFireLoss() / burn_healed)) // whichever is higher between brute or burn steps

	var/progress_text

	if(locate(/obj/item/healthanalyzer) in user.held_items)
		if(target.getBruteLoss())
			progress_text = ". Pozostałe urazy: <font color='#ff3333'>[target.getBruteLoss()]</font>"
		if(target.getFireLoss())
			progress_text += ". Pozostałe oparzenia: <font color='#ff9933'>[target.getFireLoss()]</font>"
	else
		switch(estimated_remaining_steps)
			if(-INFINITY to 1)
				return
			if(1 to 3)
				progress_text = ", kończąc ostatnie ślady obrażeń"
			if(3 to 6)
				progress_text = ", odliczając ostatnie miejsca urazów"
			if(6 to 9)
				progress_text = ", dalej zmagając się z rozległymi obrażeniami"
			if(9 to 12)
				progress_text = ", szykując się na długą operację"
			if(12 to 15)
				progress_text = ", choć pacjent wciąż bardziej przypomina rozgniecioną papkę dla niemowląt niż człowieka"
			if(15 to INFINITY)
				progress_text = ", choć masz wrażenie, że ledwo zaczynasz leczyć to połamane ciało"

	return progress_text

/datum/surgery_step/heal/combo
	name = "tend physical wounds"
	brutehealing = 3
	burnhealing = 3
	missinghpbonus = 15
	time = 10
	preop_sound = 'sound/surgery/scalpel1.ogg'
	success_sound = 'sound/surgery/retractor2.ogg'
	failure_sound = 'sound/surgery/organ1.ogg'

/datum/surgery_step/heal/combo/upgraded
	brutehealing = 3
	burnhealing = 3
	missinghpbonus = 10
	preop_sound = 'sound/surgery/scalpel1.ogg'
	success_sound = 'sound/surgery/retractor2.ogg'
	failure_sound = 'sound/surgery/organ1.ogg'

/datum/surgery_step/heal/combo/upgraded/femto
	brutehealing = 1
	burnhealing = 1
	missinghpbonus = 2.5
	preop_sound = 'sound/surgery/scalpel1.ogg'
	success_sound = 'sound/surgery/retractor2.ogg'
	failure_sound = 'sound/surgery/organ1.ogg'

/datum/surgery_step/heal/combo/upgraded/femto/failure(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	display_results(user, target, "<span class='warning'>Partaczysz!</span>",
		"<span class='warning'>[user] partaczy!</span>",
		"<span class='notice'>[user] opatruje część ran [target].</span>", TRUE)
	target.take_bodypart_damage(5,5)
