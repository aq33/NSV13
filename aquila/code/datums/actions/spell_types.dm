// AQUILA - podstawowe rodzaje zaklęć z tgstation (przez Yogstation): pointed, toggle, aoe, cone, touch

// Pointed: po wciśnięciu przycisku następne kliknięcie wybiera cel

/datum/action/cooldown/spell/pointed
	click_to_activate = TRUE
	/// Komunikat przy włączeniu celowania
	var/active_msg
	/// Komunikat przy wyłączeniu celowania
	var/deactive_msg
	/// Zasięg rzucania
	var/cast_range = 7
	/// Kliknięcie w pole celuje w człowieka albo moba na tym polu
	var/aim_assist = TRUE

/datum/action/cooldown/spell/pointed/New(Target)
	. = ..()
	if(!active_msg)
		active_msg = "Przygotowujesz [src]..."
	if(!deactive_msg)
		deactive_msg = "Rozpraszasz [src]."

/datum/action/cooldown/spell/pointed/set_click_ability(mob/on_who)
	. = ..()
	if(.)
		on_activation(on_who)

/datum/action/cooldown/spell/pointed/unset_click_ability(mob/on_who, refund_cooldown = TRUE)
	. = ..()
	if(.)
		on_deactivation(on_who, refund_cooldown)

/datum/action/cooldown/spell/pointed/before_cast(atom/cast_on)
	. = ..()
	if(. & SPELL_CANCEL_CAST)
		on_deactivation(owner, refund_cooldown = FALSE)
	if(owner && get_dist(get_turf(owner), get_turf(cast_on)) > cast_range)
		cast_on.balloon_alert(owner, "za daleko!")
		return . | SPELL_CANCEL_CAST

/datum/action/cooldown/spell/pointed/proc/on_activation(mob/on_who)
	SHOULD_CALL_PARENT(TRUE)
	to_chat(on_who, "<span class='notice'>[active_msg] <b>Kliknij lewym, żeby rzucić zaklęcie na cel!</b></span>")
	UpdateButtonIcon()
	return TRUE

/datum/action/cooldown/spell/pointed/proc/on_deactivation(mob/on_who, refund_cooldown = TRUE)
	SHOULD_CALL_PARENT(TRUE)
	if(refund_cooldown && on_who)
		to_chat(on_who, "<span class='notice'>[deactive_msg]</span>")
	UpdateButtonIcon()
	return TRUE

/datum/action/cooldown/spell/pointed/InterceptClickOn(mob/living/clicker, params, atom/click_target)
	var/atom/aim_assist_target
	if(aim_assist && isturf(click_target))
		aim_assist_target = locate(/mob/living/carbon/human) in click_target
		if(!aim_assist_target)
			aim_assist_target = locate(/mob/living) in click_target
	clicker.face_atom(click_target)
	return ..(clicker, params, aim_assist_target || click_target)

/datum/action/cooldown/spell/pointed/is_valid_target(atom/cast_on)
	if(cast_on == owner)
		to_chat(owner, "<span class='warning'>Nie możesz rzucić [src] na siebie!</span>")
		return FALSE
	return TRUE

// Toggle: przycisk włącza i wyłącza efekt

/datum/action/cooldown/spell/toggle
	/// Czy efekt jest włączony
	var/active = FALSE

/datum/action/cooldown/spell/toggle/New(Target)
	. = ..()
	START_PROCESSING(SSfastprocess, src)

/datum/action/cooldown/spell/toggle/Remove(mob/remove_from)
	if(active && owner)
		active = FALSE
		Disable()
	return ..()

/// Nie kończy przetwarzania razem z odnowieniem, bo przycisk ma śledzić stan
/datum/action/cooldown/spell/toggle/process()
	update_cooldown_text()
	if(owner)
		UpdateButtonIcon()

/datum/action/cooldown/spell/toggle/cast(atom/cast_on)
	active = !active
	if(active)
		Enable()
	else
		Disable()
	return ..()

/datum/action/cooldown/spell/toggle/is_action_active()
	return active

/datum/action/cooldown/spell/toggle/proc/Enable()
	return

/datum/action/cooldown/spell/toggle/proc/Disable()
	return

// AOE: działa na wszystko w promieniu

/datum/action/cooldown/spell/aoe
	/// Ile celów najwyżej, 0 = bez limitu
	var/max_targets = 0
	/// Promień działania
	var/aoe_radius = 7

/datum/action/cooldown/spell/aoe/cast(atom/cast_on)
	. = ..()
	var/list/atom/things_to_cast_on = get_things_to_cast_on(cast_on)
	if(max_targets > 0)
		things_to_cast_on = shuffle(things_to_cast_on)
	var/num_targets = 0
	for(var/thing_to_target in things_to_cast_on)
		if(max_targets > 0 && num_targets >= max_targets)
			break
		cast_on_thing_in_aoe(thing_to_target, cast_on)
		num_targets++

/datum/action/cooldown/spell/aoe/proc/get_things_to_cast_on(atom/center)
	var/list/things = list()
	for(var/atom/nearby_thing in range(aoe_radius, center))
		if(nearby_thing == owner || nearby_thing == center)
			continue
		things += nearby_thing
	return things

/// Efekt na jednej rzeczy w zasięgu. Tu, a nie w cast(), idą efekty zaklęcia.
/datum/action/cooldown/spell/aoe/proc/cast_on_thing_in_aoe(atom/victim, atom/caster)
	SHOULD_CALL_PARENT(FALSE)
	CRASH("[type] did not implement cast_on_thing_in_aoe")

// Cone: stożek przed rzucającym

/datum/action/cooldown/spell/cone
	/// Długość stożka
	var/cone_levels = 3
	/// Czy stożek zatrzymuje się na ścianach
	var/respect_density = FALSE

/datum/action/cooldown/spell/cone/cast(atom/cast_on)
	. = ..()
	make_cone(get_cone_turfs(get_turf(cast_on), cast_on.dir, cone_levels), cast_on)

/datum/action/cooldown/spell/cone/proc/make_cone(list/cone_turfs, atom/caster)
	var/level = 0
	for(var/list/turf_list in cone_turfs)
		level++
		do_cone_effects(turf_list, caster, level)

/datum/action/cooldown/spell/cone/proc/do_cone_effects(list/target_turf_list, atom/caster, level = 1)
	for(var/turf/target_turf as anything in target_turf_list)
		if(QDELETED(target_turf))
			continue
		do_turf_cone_effect(target_turf, caster, level)
		if(!isopenturf(target_turf))
			continue
		for(var/atom/movable/movable_content as anything in target_turf)
			if(isobj(movable_content))
				do_obj_cone_effect(movable_content, caster, level)
			else if(isliving(movable_content))
				do_mob_cone_effect(movable_content, caster, level)

/datum/action/cooldown/spell/cone/proc/do_turf_cone_effect(turf/target_turf, atom/caster, level)
	return

/datum/action/cooldown/spell/cone/proc/do_obj_cone_effect(obj/target_obj, atom/caster, level)
	return

/datum/action/cooldown/spell/cone/proc/do_mob_cone_effect(mob/living/target_mob, atom/caster, level)
	return

/datum/action/cooldown/spell/cone/proc/get_cone_turfs(turf/starter_turf, dir_to_use, cone_levels = 3)
	var/list/turfs_to_return = list()
	var/turf/turf_to_use = starter_turf
	var/turf/left_turf
	var/turf/right_turf
	var/right_dir
	var/left_dir
	switch(dir_to_use)
		if(NORTH)
			left_dir = WEST
			right_dir = EAST
		if(SOUTH)
			left_dir = EAST
			right_dir = WEST
		if(EAST)
			left_dir = NORTH
			right_dir = SOUTH
		if(WEST)
			left_dir = SOUTH
			right_dir = NORTH

	for(var/i in 1 to cone_levels)
		var/list/level_turfs = list()
		turf_to_use = get_step(turf_to_use, dir_to_use)
		if(!turf_to_use)
			break
		level_turfs += turf_to_use
		if(i != 1)
			left_turf = get_step(turf_to_use, left_dir)
			right_turf = get_step(turf_to_use, right_dir)
			if(left_turf)
				level_turfs += left_turf
			if(right_turf)
				level_turfs += right_turf
			for(var/left_i in 1 to i - calculate_cone_shape(i))
				if(!left_turf || (left_turf.density && respect_density))
					break
				left_turf = get_step(left_turf, left_dir)
				if(left_turf)
					level_turfs += left_turf
			for(var/right_i in 1 to i - calculate_cone_shape(i))
				if(!right_turf || (right_turf.density && respect_density))
					break
				right_turf = get_step(right_turf, right_dir)
				if(right_turf)
					level_turfs += right_turf
		turfs_to_return += list(level_turfs)
		if(i == cone_levels)
			continue
		if(turf_to_use.density && respect_density)
			break
	return turfs_to_return

/// Szerokość stożka na danym poziomie
/datum/action/cooldown/spell/cone/proc/calculate_cone_shape(current_level)
	var/end_taper_start = round(cone_levels * 0.8)
	if(current_level > end_taper_start)
		return (current_level % end_taper_start) * 2
	return 2

/// Stożek, który rośnie poziom po poziomie zamiast od razu
/datum/action/cooldown/spell/cone/staggered
	/// Opóźnienie między poziomami
	var/delay_between_level = 0.2 SECONDS

/datum/action/cooldown/spell/cone/staggered/make_cone(list/cone_turfs, atom/caster)
	var/level_counter = 0
	for(var/list/turf_list in cone_turfs)
		level_counter++
		addtimer(CALLBACK(src, PROC_REF(do_cone_effects), turf_list, caster, level_counter), delay_between_level * level_counter)

// Touch: przycisk daje dłoń, efekt jest przy dotknięciu nią celu

/datum/action/cooldown/spell/touch
	check_flags = AB_CHECK_CONSCIOUS|AB_CHECK_HANDS_BLOCKED
	invocation_type = INVOCATION_NONE
	/// Typ dłoni
	var/obj/item/melee/spell_hand/hand_path = /obj/item/melee/spell_hand
	/// Dłoń, którą rzucający teraz trzyma
	var/obj/item/melee/spell_hand/attached_hand
	/// Komunikat przy przywołaniu dłoni
	var/draw_message = "<span class='notice'>Skupiasz moc zaklęcia w dłoni.</span>"
	/// Komunikat przy odwołaniu dłoni bez użycia
	var/drop_message = "<span class='notice'>Wycofujesz moc z dłoni.</span>"
	/// Czy można dotknąć samego siebie
	var/can_cast_on_self = FALSE

/datum/action/cooldown/spell/touch/Destroy()
	if(!owner)
		QDEL_NULL(attached_hand)
	return ..()

/datum/action/cooldown/spell/touch/Remove(mob/remove_from)
	remove_hand(remove_from, reset_cooldown_after = TRUE)
	return ..()

/// Bez is_valid_target na samym rzucającym
/datum/action/cooldown/spell/touch/PreActivate(atom/target)
	return Activate(target)

/datum/action/cooldown/spell/touch/is_action_active()
	return !!attached_hand

/datum/action/cooldown/spell/touch/can_cast_spell(feedback = TRUE)
	. = ..()
	if(!.)
		return FALSE
	if(!iscarbon(owner))
		return FALSE
	var/mob/living/carbon/carbon_owner = owner
	return !!(carbon_owner.mobility_flags & MOBILITY_USE)

/datum/action/cooldown/spell/touch/is_valid_target(atom/cast_on)
	return isliving(cast_on)

/datum/action/cooldown/spell/touch/proc/create_hand(mob/living/carbon/cast_on)
	SHOULD_CALL_PARENT(TRUE)
	var/obj/item/melee/spell_hand/new_hand = new hand_path(cast_on, src)
	if(!cast_on.put_in_hands(new_hand, del_on_fail = TRUE))
		reset_spell_cooldown()
		if(!cast_on.get_num_arms())
			to_chat(cast_on, "<span class='warning'>Nie masz sprawnych rąk!</span>")
		else
			to_chat(cast_on, "<span class='warning'>Masz zajęte ręce!</span>")
		return FALSE
	attached_hand = new_hand
	RegisterSignal(attached_hand, COMSIG_ITEM_AFTERATTACK, PROC_REF(on_hand_hit))
	RegisterSignal(attached_hand, COMSIG_ITEM_DROPPED, PROC_REF(on_hand_dropped))
	RegisterSignal(attached_hand, COMSIG_PARENT_QDELETING, PROC_REF(on_hand_deleted))
	to_chat(cast_on, draw_message)
	return TRUE

/// reset_cooldown_after = TRUE cofa odnowienie (dłoń odwołana), FALSE zaczyna odnowienie i płaci koszt (dłoń użyta)
/datum/action/cooldown/spell/touch/proc/remove_hand(mob/living/hand_owner, reset_cooldown_after = FALSE)
	SHOULD_CALL_PARENT(TRUE)
	if(!QDELETED(attached_hand))
		UnregisterSignal(attached_hand, list(COMSIG_ITEM_AFTERATTACK, COMSIG_ITEM_DROPPED, COMSIG_PARENT_QDELETING))
		hand_owner?.temporarilyRemoveItemFromInventory(attached_hand, TRUE)
		QDEL_NULL(attached_hand)
	attached_hand = null
	if(reset_cooldown_after)
		if(hand_owner)
			to_chat(hand_owner, drop_message)
		reset_spell_cooldown()
	else
		StartCooldown()
		consume_resource()
		UpdateButtonIcon()

/// Odnowienie i inkantacja dopiero przy użyciu dłoni
/datum/action/cooldown/spell/touch/before_cast(atom/cast_on)
	return ..() | SPELL_NO_FEEDBACK | SPELL_NO_IMMEDIATE_COOLDOWN

/datum/action/cooldown/spell/touch/cast(mob/living/carbon/cast_on)
	if(!QDELETED(attached_hand) && (attached_hand in cast_on.held_items))
		remove_hand(cast_on, reset_cooldown_after = TRUE)
		return ..()
	create_hand(cast_on)
	return ..()

/datum/action/cooldown/spell/touch/proc/on_hand_hit(datum/source, atom/victim, mob/caster, proximity_flag, click_parameters)
	SIGNAL_HANDLER
	SHOULD_NOT_OVERRIDE(TRUE)
	if(!proximity_flag)
		return
	if(!can_hit_with_hand(victim, caster))
		return
	INVOKE_ASYNC(src, PROC_REF(do_hand_hit), source, victim, caster)

/datum/action/cooldown/spell/touch/proc/can_hit_with_hand(atom/victim, mob/caster)
	if(!can_cast_on_self && victim == caster)
		return FALSE
	if(!is_valid_target(victim))
		return FALSE
	if(!can_cast_spell(TRUE))
		return FALSE
	return TRUE

/datum/action/cooldown/spell/touch/proc/do_hand_hit(obj/item/melee/spell_hand/hand, atom/victim, mob/living/carbon/caster)
	SHOULD_NOT_OVERRIDE(TRUE)
	var/mob/mob_victim = victim
	if(istype(mob_victim) && mob_victim.can_block_magic(antimagic_flags))
		on_antimagic_triggered(hand, victim, caster)
	else if(!cast_on_hand_hit(hand, victim, caster))
		return
	if(QDELETED(src))
		return
	log_combat(caster, victim, "cast the touch spell [name] on", hand)
	spell_feedback()
	remove_hand(caster)

/// Efekt dotknięcia. TRUE zużywa dłoń, FALSE zostawia ją w ręce.
/datum/action/cooldown/spell/touch/proc/cast_on_hand_hit(obj/item/melee/spell_hand/hand, atom/victim, mob/living/carbon/caster)
	return FALSE

/datum/action/cooldown/spell/touch/proc/on_antimagic_triggered(obj/item/melee/spell_hand/hand, atom/victim, mob/living/carbon/caster)
	to_chat(caster, "<span class='warning'>[victim] opiera się twojemu zaklęciu!</span>")

/datum/action/cooldown/spell/touch/proc/on_hand_deleted(datum/source)
	SIGNAL_HANDLER
	attached_hand = null
	INVOKE_ASYNC(src, PROC_REF(reset_spell_cooldown))

/datum/action/cooldown/spell/touch/proc/on_hand_dropped(datum/source, mob/living/dropper)
	SIGNAL_HANDLER
	INVOKE_ASYNC(src, PROC_REF(remove_hand), dropper, TRUE)

/// Dłoń zaklęcia dotyku. Osobny typ, bo nasze /obj/item/melee/touch_attack jest zrośnięte ze starymi zaklęciami.
/obj/item/melee/spell_hand
	name = "\improper outstretched hand"
	desc = "High Five?"
	icon = 'icons/obj/items_and_weapons.dmi'
	icon_state = "syndballoon"
	lefthand_file = 'icons/mob/inhands/misc/touchspell_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/misc/touchspell_righthand.dmi'
	item_state = null
	item_flags = NEEDS_PERMIT | ABSTRACT | DROPDEL
	w_class = WEIGHT_CLASS_HUGE
	force = 0
	throwforce = 0
	throw_range = 0
	throw_speed = 0
	/// Zaklęcie, które stworzyło dłoń
	var/datum/weakref/spell_which_made_us

/obj/item/melee/spell_hand/Initialize(mapload, datum/action/cooldown/spell/spell)
	. = ..()
	if(spell)
		spell_which_made_us = WEAKREF(spell)

/obj/item/melee/spell_hand/attack(mob/target, mob/living/carbon/user)
	if(!iscarbon(user))
		return TRUE
	if(!(user.mobility_flags & MOBILITY_USE))
		to_chat(user, "<span class='warning'>Nie możesz sięgnąć!</span>")
		return TRUE
	return ..()
