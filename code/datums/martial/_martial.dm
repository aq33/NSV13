/datum/martial_art
	var/name = "Martial Art"
	var/id = "" //ID, used by mind/has_martialart
	var/streak = ""
	var/max_streak_length = 6
	var/current_target
	var/datum/martial_art/base // The permanent style. This will be null unless the martial art is temporary
	var/deflection_chance = 0 //Chance to deflect projectiles
	var/reroute_deflection = FALSE //Delete the bullet, or actually deflect it in some direction?
	var/block_chance = 0 //Chance to block melee attacks using items while on throw mode.
	var/restraining = 0 //used in cqc's disarm_act to check if the disarmed is being restrained and so whether they should be put in a chokehold or not
	var/armlockstate = 0 //used in jujitsu grab after hand armlock move
	var/help_verb
	var/no_guns = FALSE
	var/allow_temp_override = TRUE //if this martial art can be overridden by temporary martial arts
	var/smashes_tables = FALSE //If the martial art smashes tables when performing table slams and head smashes
	var/datum/weakref/holder //owner of the martial art
	var/display_combos = FALSE //shows combo meter if true
	var/combo_timer = 6 SECONDS // period of time after which the combo streak is reset.
	var/timerid
	/// If set to true this style allows you to punch people despite being a pacifist (for instance Boxing, which does no damage)
	var/pacifist_style = FALSE

	/// Weakref to button to access martial guide
	var/datum/weakref/info_button_ref

	//Moves that are specific to each martial art, and passed into the martial art action button
	var/Move1 = null
	var/Move2 = null
	var/Move3 = null
	var/Move4 = null
	var/Move5 = null
	var/AdditionText = null

/datum/martial_art/proc/help_act(mob/living/carbon/human/A, mob/living/carbon/human/D)
	return MARTIAL_ATTACK_INVALID

/datum/martial_art/proc/disarm_act(mob/living/carbon/human/A, mob/living/carbon/human/D)
	return MARTIAL_ATTACK_INVALID

/datum/martial_art/proc/harm_act(mob/living/carbon/human/A, mob/living/carbon/human/D)
	return MARTIAL_ATTACK_INVALID

/datum/martial_art/proc/grab_act(mob/living/carbon/human/A, mob/living/carbon/human/D)
	return MARTIAL_ATTACK_INVALID

/datum/martial_art/proc/can_use(mob/living/carbon/human/H)
	return TRUE

/datum/martial_art/proc/add_to_streak(element,mob/living/carbon/human/D)
	if(D != current_target)
		reset_streak(D)
	streak = streak+element
	if(length(streak) > max_streak_length)
		streak = copytext(streak, 1 + length(streak[1]))
	if(display_combos)
		var/mob/living/holder_living = holder?.resolve()
		timerid = addtimer(CALLBACK(src, PROC_REF(reset_streak), null, FALSE), combo_timer, TIMER_UNIQUE | TIMER_STOPPABLE)
		holder_living?.hud_used?.combo_display?.update_icon_state(streak, combo_timer - 2 SECONDS)

/datum/martial_art/proc/reset_streak(mob/living/new_target, update_icon = TRUE)
	if(timerid)
		deltimer(timerid)
	current_target = new_target
	streak = ""
	restraining = 0
	if(update_icon)
		var/mob/living/holder_living = holder?.resolve()
		holder_living?.hud_used?.combo_display?.update_icon_state(streak)

/datum/martial_art/proc/basic_hit(mob/living/carbon/human/A,mob/living/carbon/human/D)

	var/damage = A.dna.species.punchdamage

	var/atk_verb = A.dna.species.attack_verb
	if(!(D.mobility_flags & MOBILITY_STAND))
		atk_verb = "kick"

	switch(atk_verb)
		if("kick")
			A.do_attack_animation(D, ATTACK_EFFECT_KICK)
		if("slash")
			A.do_attack_animation(D, ATTACK_EFFECT_CLAW)
		if("smash")
			A.do_attack_animation(D, ATTACK_EFFECT_SMASH)
		else
			A.do_attack_animation(D, ATTACK_EFFECT_PUNCH)

	if(!damage)
		playsound(D.loc, A.dna.species.miss_sound, 25, 1, -1)
		D.visible_message("<span class='warning'>[A] chybia, próbując zaatakować [D]!</span>", \
			"<span class='userdanger'>[A] chybia, próbując cię zaatakować!</span>", null, COMBAT_MESSAGE_RANGE)
		log_combat(A, D, "attempted to [atk_verb]")
		return 0

	var/obj/item/bodypart/affecting = D.get_bodypart(ran_zone(A.zone_selected))
	var/armor_block = D.run_armor_check(affecting, "melee")

	playsound(D.loc, A.dna.species.attack_sound, 25, 1, -1)
	D.visible_message("<span class='danger'>[A] [attack_verb_pl(atk_verb)] [D]!</span>", \
			"<span class='userdanger'>[A] [attack_verb_pl(atk_verb)] cię!</span>", null, COMBAT_MESSAGE_RANGE)

	D.apply_damage(damage, A.dna.species.attack_type, affecting, armor_block)

	log_combat(A, D, "punched")

	if(!(D.mobility_flags & MOBILITY_STAND))
		D.force_say(A)
	return 1

/datum/martial_art/proc/teach(mob/living/carbon/human/H,make_temporary=0)
	if(!istype(H) || !H.mind)
		return FALSE
	if(H.mind.martial_art)
		if(make_temporary)
			if(!H.mind.martial_art.allow_temp_override)
				return FALSE
			store(H.mind.martial_art,H)
		else
			H.mind.martial_art.on_remove(H)
	else if(make_temporary)
		base = H.mind.default_martial_art
	if(help_verb)
		H.add_verb(help_verb)
	H.mind.martial_art = src
	holder = WEAKREF(H)
	//Skip info button stuff if we dont have moves
	if(!display_combos)
		return TRUE
	var/datum/action/martial_info/info_button = make_info_button()
	if(info_button)
		to_chat(H, span_boldnotice("Więcej informacji znajdziesz w poradniku sztuki walki. \
			Zawsze możesz do niego wrócić przyciskiem w lewym górnym rogu."))
		INVOKE_ASYNC(info_button, TYPE_PROC_REF(/datum/action, Trigger))
	return TRUE

/datum/martial_art/proc/make_info_button()
	var/mob/living/holder_living = holder?.resolve()
	if(!holder_living)
		return
	var/datum/action/martial_info/info_button = new(src)
	info_button.name = "Open [name] Guide"
	info_button.Grant(holder_living)
	info_button_ref = WEAKREF(info_button)
	return info_button

/datum/martial_art/proc/store(datum/martial_art/M,mob/living/carbon/human/H)
	M.on_remove(H)
	if(M.base) //Checks if M is temporary, if so it will not be stored.
		base = M.base
	else //Otherwise, M is stored.
		base = M

/datum/martial_art/proc/remove(mob/living/carbon/human/H)
	if(!istype(H) || !H.mind || H.mind.martial_art != src)
		return
	on_remove(H)
	if(base)
		base.teach(H)
	else
		var/datum/martial_art/X = H.mind.default_martial_art
		X.teach(H)
	holder = null

/datum/martial_art/proc/on_remove(mob/living/carbon/human/H)
	if(help_verb)
		H.remove_verb(help_verb)
	if(info_button_ref)
		var/datum/action/martial_info/info_button = info_button_ref.resolve()
		if(info_button)
			info_button.Remove(H)
			qdel(info_button)
		info_button_ref = null
	reset_streak(null, FALSE)
	H.hud_used?.combo_display?.update_icon_state("")
	return

//button to review martial arts
/datum/action/martial_info
	name = "Poradnik sztuki walki"
	button_icon_state = "round_end"

/datum/action/martial_info/Trigger()
	if(!..())
		return FALSE
	ui_interact(owner)
	return TRUE

/datum/action/martial_info/IsAvailable()
	. = ..()
	if(!.)
		return
	if(!owner.mind || !owner.mind.martial_art)
		return FALSE
	return TRUE

/datum/action/martial_info/ui_state(mob/user)
	return GLOB.always_state

/datum/action/martial_info/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "MartialInfo", name)
		ui.set_autoupdate(FALSE)
		ui.open()

/datum/action/martial_info/ui_data(mob/user)
	var/list/data = list()
	var/datum/martial_art/martial_art = owner?.mind?.martial_art
	if(!martial_art)
		return data
	data["name"] = martial_art.name
	data["Move1"] = martial_art.Move1
	data["Move2"] = martial_art.Move2
	data["Move3"] = martial_art.Move3
	data["Move4"] = martial_art.Move4
	data["Move5"] = martial_art.Move5
	data["AdditionText"] = martial_art.AdditionText
	return data
