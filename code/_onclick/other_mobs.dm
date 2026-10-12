/// Checks for RIGHT_CLICK in modifiers and runs resolve_right_click_attack if so. Returns TRUE if normal chain blocked.
/mob/living/proc/right_click_attack_chain(atom/target, list/modifiers)
	if (!LAZYACCESS(modifiers, RIGHT_CLICK))
		return
	var/secondary_result = resolve_right_click_attack(target, modifiers)

	if (secondary_result == SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN || secondary_result == SECONDARY_ATTACK_CONTINUE_CHAIN)
		return TRUE
	else if (secondary_result != SECONDARY_ATTACK_CALL_NORMAL)
		CRASH("resolve_right_click_attack (probably attack_hand_secondary) did not return a SECONDARY_ATTACK_* define.")

/*
	Humans:
	Adds an exception for gloves, to allow special glove types like the ninja ones.

	Otherwise pretty standard.
*/
/mob/living/carbon/human/UnarmedAttack(atom/A, proximity, modifiers)

	if(!has_active_hand()) //can't attack without a hand.
		to_chat(src, "<span class='notice'>Patrzysz na swoją rękę i wzdychasz.</span>")
		return

	// Special glove functions:
	// If the gloves do anything, have them return 1 to stop
	// normal attack_hand() here.
	var/obj/item/clothing/gloves/G = gloves // not typecast specifically enough in defines
	if(proximity && istype(G) && G.Touch(A,1))
		return

	var/override = 0

	for(var/datum/mutation/HM as() in dna.mutations)
		override += HM.on_attack_hand(A, proximity)

	if(override)
		return

	if(SEND_SIGNAL(src, COMSIG_HUMAN_EARLY_UNARMED_ATTACK, A, proximity, modifiers) & COMPONENT_CANCEL_ATTACK_CHAIN)
		return

	SEND_SIGNAL(src, COMSIG_HUMAN_MELEE_UNARMED_ATTACK, A, proximity, modifiers)

	if(!right_click_attack_chain(A, modifiers))
		A.attack_hand(src, modifiers)

/mob/living/carbon/human/resolve_right_click_attack(atom/target, list/modifiers)
	return target.attack_hand_secondary(src, modifiers)

/// Return TRUE to cancel other attack hand effects that respect it. Modifiers is the assoc list for click info such as if it was a right click.
/atom/proc/attack_hand(mob/user, list/modifiers)
	. = FALSE
	if(!(interaction_flags_atom & INTERACT_ATOM_NO_FINGERPRINT_ATTACK_HAND))
		add_fingerprint(user)
	if(SEND_SIGNAL(src, COMSIG_ATOM_ATTACK_HAND, user, modifiers) & COMPONENT_NO_ATTACK_HAND)
		. = TRUE
	if(interaction_flags_atom & INTERACT_ATOM_ATTACK_HAND)
		. = _try_interact(user)

/// When the user uses their hand on an item while holding right-click
/// Returns a SECONDARY_ATTACK_* value.
/atom/proc/attack_hand_secondary(mob/user, list/modifiers)
	if(SEND_SIGNAL(src, COMSIG_ATOM_ATTACK_HAND_SECONDARY, user, modifiers) & COMPONENT_CANCEL_ATTACK_CHAIN)
		return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN
	return SECONDARY_ATTACK_CALL_NORMAL

//Return a non FALSE value to cancel whatever called this from propagating, if it respects it.
/atom/proc/_try_interact(mob/user)
	if(IsAdminGhost(user))		//admin abuse
		return interact(user)
	if(can_interact(user))
		return interact(user)
	return FALSE

/atom/proc/can_interact(mob/user)
	if(!user.can_interact_with(src, interaction_flags_atom & INTERACT_ATOM_ALLOW_USER_LOCATION))
		return FALSE
	if((interaction_flags_atom & INTERACT_ATOM_REQUIRES_DEXTERITY) && !user.IsAdvancedToolUser())
		to_chat(user, "<span class='warning'>Brakuje ci zręczności, by to zrobić!</span>")
		return FALSE
	if(!(interaction_flags_atom & INTERACT_ATOM_IGNORE_INCAPACITATED) && user.incapacitated((interaction_flags_atom & INTERACT_ATOM_IGNORE_RESTRAINED), !(interaction_flags_atom & INTERACT_ATOM_CHECK_GRAB)))
		return FALSE
	return TRUE

/atom/ui_status(mob/user)
	. = ..()
	//Check if both user and atom are at the same location
	if(!can_interact(user))
		. = min(., UI_UPDATE)

/atom/movable/can_interact(mob/user)
	. = ..()
	if(!.)
		return
	if(!anchored && (interaction_flags_atom & INTERACT_ATOM_REQUIRES_ANCHORED))
		return FALSE

/atom/proc/interact(mob/user)
	if(interaction_flags_atom & INTERACT_ATOM_NO_FINGERPRINT_INTERACT)
		add_hiddenprint(user)
	else
		add_fingerprint(user)
	if(interaction_flags_atom & INTERACT_ATOM_UI_INTERACT)
		return ui_interact(user)
	return FALSE

/*
/mob/living/carbon/human/RestrainedClickOn(var/atom/A) ---carbons will handle this
	return
*/

/mob/living/carbon/RestrainedClickOn(atom/A)
	return 0

/mob/living/carbon/RangedAttack(atom/A, mouseparams)
	. = ..()
	if(!dna)
		return
	for(var/datum/mutation/HM as() in dna.mutations)
		HM.on_ranged_attack(A, mouseparams)

/mob/living/carbon/human/RangedAttack(atom/A, mouseparams)
	. = ..()
	if(.)
		return
	if(gloves)
		var/obj/item/clothing/gloves/G = gloves
		if(istype(G) && G.Touch(A,0)) // for magic gloves
			return TRUE

	if(isturf(A) && get_dist(src,A) <= 1)
		src.Move_Pulled(A)
		return TRUE

/*
	Animals & All Unspecified
*/
/mob/living/UnarmedAttack(atom/attack_target, proximity_flag, list/modifiers)
	if(SEND_SIGNAL(src, COMSIG_LIVING_UNARMED_ATTACK, attack_target, proximity_flag, modifiers) & COMPONENT_CANCEL_ATTACK_CHAIN)
		return FALSE
	if(!right_click_attack_chain(attack_target, modifiers))
		resolve_unarmed_attack(attack_target, modifiers)
	return TRUE

/**
 * Called when the unarmed attack hasn't been stopped by the COMSIG_LIVING_UNARMED_ATTACK signal or the right_click_attack_chain proc.
 * This will call an attack proc that can vary from mob type to mob type on the target.
 */
/mob/living/proc/resolve_unarmed_attack(atom/attack_target, list/modifiers)
	attack_target.attack_animal(src, modifiers)

/**
 * Called when an unarmed attack performed with right click hasn't been stopped by the COMSIG_LIVING_UNARMED_ATTACK signal.
 * This will call a secondary attack proc that can vary from mob type to mob type on the target.
 * Sometimes, a target is interacted differently when right_clicked, in that case the secondary attack proc should return
 * a SECONDARY_ATTACK_* value that's not SECONDARY_ATTACK_CALL_NORMAL.
 * Otherwise, it should just return SECONDARY_ATTACK_CALL_NORMAL. Failure to do so will result in an exception (runtime error).
 */
/mob/living/proc/resolve_right_click_attack(atom/target, list/modifiers)
	return target.attack_animal_secondary(src, modifiers)

/atom/proc/attack_animal(mob/user, list/modifiers)
	SEND_SIGNAL(src, COMSIG_ATOM_ATTACK_ANIMAL, user)
	return

/**
 * Called when a simple animal right clicks an atom.
 * Returns a SECONDARY_ATTACK_* value.
 */
/atom/proc/attack_animal_secondary(mob/user, list/modifiers)
	return SECONDARY_ATTACK_CALL_NORMAL

/mob/living/RestrainedClickOn(atom/A)
	return

/*
	Monkeys
*/
/mob/living/carbon/monkey/UnarmedAttack(atom/A, proximity, modifiers)
	var/override = 0
	for(var/datum/mutation/HM as() in dna.mutations)
		override += HM.on_attack_hand(A, proximity)
	if(override)
		return

	A.attack_paw(src, modifiers)

///Attacked by monkey. It doesn't need its own *_secondary proc as it just uses attack_hand_secondary instead.
/atom/proc/attack_paw(mob/user, list/modifiers)
	if(SEND_SIGNAL(src, COMSIG_ATOM_ATTACK_PAW, user, modifiers) & COMPONENT_NO_ATTACK_HAND)
		return TRUE
	return FALSE

/*
	Monkey RestrainedClickOn() was apparently the
	one and only use of all of the restrained click code
	(except to stop you from doing things while handcuffed);
	moving it here instead of various hand_p's has simplified
	things considerably
*/
/mob/living/carbon/monkey/RestrainedClickOn(atom/A)
	if(..())
		return
	if(!combat_mode || !ismob(A))
		return
	if(is_muzzled())
		return
	var/mob/living/carbon/ML = A
	if(istype(ML))
		var/dam_zone = pick(BODY_ZONE_CHEST, BODY_ZONE_PRECISE_L_HAND, BODY_ZONE_PRECISE_R_HAND, BODY_ZONE_L_LEG, BODY_ZONE_R_LEG)
		var/obj/item/bodypart/affecting = null
		if(ishuman(ML))
			var/mob/living/carbon/human/H = ML
			affecting = H.get_bodypart(ran_zone(dam_zone))
		var/armor = ML.run_armor_check(affecting, "melee")
		if(prob(75))
			ML.apply_damage(rand(1,3), BRUTE, affecting, armor)
			ML.visible_message("<span class='danger'>[name] bites [ML]!</span>", \
							"<span class='userdanger'>[name] gryzie cię!</span>", null, COMBAT_MESSAGE_RANGE)
			if(armor >= 2)
				return
			for(var/thing in diseases)
				var/datum/disease/D = thing
				ML.ForceContractDisease(D)
		else
			ML.visible_message("<span class='danger'>[src] chybia, próbując ugryźć [ML]!</span>", \
							"<span class='danger'>[src] chybia, próbując cię ugryźć!</span>", null, COMBAT_MESSAGE_RANGE)

/*
	Aliens
	Defaults to same as monkey in most places
*/
/mob/living/carbon/alien/resolve_unarmed_attack(atom/attack_target, list/modifiers)
	attack_target.attack_alien(src, modifiers)

/mob/living/carbon/alien/resolve_right_click_attack(atom/target, list/modifiers)
	return target.attack_alien_secondary(src, modifiers)

/atom/proc/attack_alien(mob/living/carbon/alien/user, list/modifiers)
	attack_paw(user, modifiers)
	return

/**
 * Called when an alien right clicks an atom.
 * Returns a SECONDARY_ATTACK_* value.
 */
/atom/proc/attack_alien_secondary(mob/living/carbon/alien/user, list/modifiers)
	return SECONDARY_ATTACK_CALL_NORMAL

/mob/living/carbon/alien/RestrainedClickOn(atom/A)
	return

// Babby aliens
/mob/living/carbon/alien/larva/resolve_unarmed_attack(atom/attack_target, list/modifiers)
	attack_target.attack_larva(src, modifiers)

/mob/living/carbon/alien/larva/resolve_right_click_attack(atom/target, list/modifiers)
	return target.attack_larva_secondary(src, modifiers)

/atom/proc/attack_larva(mob/user, list/modifiers)
	return

/**
 * Called when an alien larva right clicks an atom.
 * Returns a SECONDARY_ATTACK_* value.
 */
/atom/proc/attack_larva_secondary(mob/user, list/modifiers)
	return SECONDARY_ATTACK_CALL_NORMAL


/*
	Slimes
	Nothing happening here
*/
/mob/living/simple_animal/slime/resolve_unarmed_attack(atom/attack_target, list/modifiers)
	attack_target.attack_slime(src, modifiers)

/mob/living/simple_animal/slime/resolve_right_click_attack(atom/target, list/modifiers)
	return target.attack_slime_secondary(src, modifiers)

/atom/proc/attack_slime(mob/user, list/modifiers)
	return

/**
 * Called when a slime mob right clicks an atom.
 * Returns a SECONDARY_ATTACK_* value.
 */
/atom/proc/attack_slime_secondary(mob/user, list/modifiers)
	return SECONDARY_ATTACK_CALL_NORMAL

/mob/living/simple_animal/slime/RestrainedClickOn(atom/A)
	return


/*
	Drones
*/
/mob/living/simple_animal/drone/resolve_unarmed_attack(atom/attack_target, list/modifiers)
	attack_target.attack_drone(src, modifiers)

/mob/living/simple_animal/drone/resolve_right_click_attack(atom/target, list/modifiers)
	return target.attack_drone_secondary(src, modifiers)

/// Defaults to attack_hand. Override it when you don't want drones to do same stuff as humans.
/atom/proc/attack_drone(mob/living/simple_animal/drone/user, list/modifiers)
	attack_hand(user, modifiers)

/**
 * Called when a maintenance drone right clicks an atom.
 * Defaults to attack_hand_secondary.
 * When overriding it, remember that it ought to return a SECONDARY_ATTACK_* value.
 */
/atom/proc/attack_drone_secondary(mob/living/simple_animal/drone/user, list/modifiers)
	return attack_hand_secondary(user, modifiers)


/*
	True Devil
*/

/mob/living/carbon/true_devil/UnarmedAttack(atom/A, proximity, modifiers)
	if(!right_click_attack_chain(A, modifiers))
		A.attack_hand(src, modifiers)

/mob/living/carbon/true_devil/resolve_right_click_attack(atom/target, list/modifiers)
	return target.attack_hand_secondary(src, modifiers)

/*
	Brain
*/

/mob/living/brain/UnarmedAttack(atom/attack_target, proximity_flag, list/modifiers)//Stops runtimes due to attack_animal being the default
	return


/*
	pAI
*/

/mob/living/silicon/pai/UnarmedAttack(atom/attack_target, proximity_flag, list/modifiers)//Stops runtimes due to attack_animal being the default
	return


/*
	Simple animals
*/

/mob/living/simple_animal/resolve_unarmed_attack(atom/attack_target, list/modifiers)
	if(dextrous && (isitem(attack_target) || !combat_mode))
		attack_target.attack_hand(src, modifiers)
		update_inv_hands()
	else
		return ..()

/mob/living/simple_animal/resolve_right_click_attack(atom/target, list/modifiers)
	if(dextrous && (isitem(target) || !combat_mode))
		. = target.attack_hand_secondary(src, modifiers)
		update_inv_hands()
	else
		return ..()


/*
	Hostile animals
*/

/mob/living/simple_animal/hostile/resolve_unarmed_attack(atom/attack_target, list/modifiers)
	GiveTarget(attack_target)
	if(dextrous && (isitem(attack_target) || !combat_mode))
		return ..()
	else
		AttackingTarget()



/*
	New Players:
	Have no reason to click on anything at all.
*/
/mob/dead/new_player/ClickOn()
	return
