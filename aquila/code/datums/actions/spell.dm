// AQUILA - system zaklęć /datum/action/cooldown/spell z tgstation (przez Yogstation), przepisany na nasze stare akcje.
// U nas /datum/action ma jeden przycisk (UpdateButtonIcon), a nie listę przycisków jak w tg.
// Plik ikony zdolności to icon_icon, a button_icon to plik TŁA (odwrotnie niż w tg).
//
// Łańcuch rzucania (jak w tg):
// Trigger() -> (click_to_activate: set_click_ability() i kliknięcie -> InterceptClickOn()) -> PreActivate() ->
// is_valid_target() -> Activate(): before_cast() -> spell_feedback() -> cast() -> StartCooldown() -> after_cast()

/datum/action/cooldown/spell
	name = "Spell"
	desc = "A spell."
	icon_icon = 'icons/mob/actions/actions_spells.dmi'
	button_icon_state = "spell_default"
	background_icon_state = "bg_spell"
	check_flags = AB_CHECK_CONSCIOUS
	/// Dźwięk przy rzuceniu
	var/sound
	/// Co rzucający mówi przy rzuceniu
	var/invocation
	/// Co rzucający widzi przy INVOCATION_EMOTE
	var/invocation_self_message
	/// none, whisper, shout albo emote
	var/invocation_type = INVOCATION_NONE
	/// Flagi SPELL_REQUIRES_* i SPELL_CASTABLE_*
	var/spell_requirements = NONE
	/// Jaka ochrona blokuje to zaklęcie na celu (MAGIC_RESISTANCE_*)
	var/antimagic_flags = MAGIC_RESISTANCE
	/// Iskry po rzuceniu
	var/sparks_amt = 0
	/// Koszt w zasobach antagonisty, np. list(ANTAG_RESOURCE_DARKSPAWN = 30)
	var/list/resource_costs
	/// Pomija koszt (np. darmowy powrót z przemiany)
	var/bypass_cost = FALSE

	/// Zaklęcie rzuca się kliknięciem w cel po wciśnięciu przycisku
	var/click_to_activate = FALSE
	/// Odnowienie kliknięcia po rzuceniu na cel
	var/click_cd_override = CLICK_CD_CLICK_ABILITY
	/// Po rzuceniu na cel zdejmuje przechwytywanie kliknięć
	var/unset_after_click = TRUE
	/// Kursor na czas wybierania celu
	var/ranged_mousepointer

/datum/action/cooldown/spell/link_to(Target)
	. = ..()
	// Zaklęcia przypięte do umysłu idą za nim do nowego ciała (nasze transfer_actions tego nie robi)
	if(istype(target, /datum/mind))
		RegisterSignal(target, COMSIG_MIND_TRANSFER_TO, PROC_REF(on_mind_transfer))

/datum/action/cooldown/spell/Destroy()
	STOP_PROCESSING(SSfastprocess, src)
	return ..()

/datum/action/cooldown/spell/proc/on_mind_transfer(datum/mind/source, mob/old_current, mob/new_current)
	SIGNAL_HANDLER
	if(owner == old_current && new_current)
		Grant(new_current)

/datum/action/cooldown/spell/Grant(mob/grant_to)
	// Zaklęcie umysłu daje się tylko jego obecnemu ciału
	if(istype(target, /datum/mind))
		var/datum/mind/mind_target = target
		if(mind_target.current != grant_to)
			return
	return ..()

/datum/action/cooldown/spell/Remove(mob/remove_from)
	if(click_to_activate && remove_from?.click_intercept == src)
		unset_click_ability(remove_from, refund_cooldown = FALSE)
	return ..()

/datum/action/cooldown/spell/IsAvailable(feedback = FALSE)
	if(!owner)
		return FALSE
	if(!check_action_flags(feedback))
		return FALSE
	if(next_use_time > world.time)
		return FALSE
	return can_cast_spell(feedback)

/// Sprawdza check_flags akcji, łącznie z flagami z tg (AB_CHECK_HANDS_BLOCKED, AB_CHECK_IMMOBILE)
/datum/action/cooldown/spell/proc/check_action_flags(feedback = FALSE)
	var/mob/living/living_owner = isliving(owner) ? owner : null
	if((check_flags & AB_CHECK_RESTRAINED) && owner.restrained())
		return FALSE
	if((check_flags & AB_CHECK_STUN) && living_owner && (living_owner.IsParalyzed() || living_owner.IsStun()))
		return FALSE
	if((check_flags & AB_CHECK_LYING) && living_owner && !(living_owner.mobility_flags & MOBILITY_STAND))
		return FALSE
	if((check_flags & AB_CHECK_CONSCIOUS) && owner.stat != CONSCIOUS)
		return FALSE
	if((check_flags & AB_CHECK_HANDS_BLOCKED) && (owner.restrained() || (living_owner && !(living_owner.mobility_flags & MOBILITY_USE))))
		return FALSE
	if((check_flags & AB_CHECK_IMMOBILE) && living_owner && !(living_owner.mobility_flags & MOBILITY_MOVE))
		return FALSE
	return TRUE

/datum/action/cooldown/spell/Trigger(trigger_flags, atom/target)
	if(!owner)
		return FALSE
	// Najpierw can_cast_spell z komunikatem, żeby gracz wiedział, czemu nie działa
	if(!can_cast_spell(TRUE))
		return FALSE
	if(!check_action_flags(TRUE))
		return FALSE
	if(next_use_time > world.time)
		to_chat(owner, "<span class='warning'>[name] jeszcze się odnawia.</span>")
		return FALSE
	if(SEND_SIGNAL(src, COMSIG_ACTION_TRIGGER, src) & COMPONENT_ACTION_BLOCK_TRIGGER)
		return FALSE

	if(click_to_activate)
		if(target) // automatyczne użycie z kodu
			return InterceptClickOn(owner, null, target)
		var/datum/action/cooldown/spell/already_set = owner.click_intercept
		if(already_set == src)
			return unset_click_ability(owner, refund_cooldown = TRUE)
		if(istype(already_set))
			already_set.unset_click_ability(owner, refund_cooldown = TRUE)
		return set_click_ability(owner)

	return PreActivate(owner)

/// Kliknięcie w cel, gdy zaklęcie przechwytuje kliknięcia. TRUE = kliknięcie zużyte.
/datum/action/cooldown/spell/proc/InterceptClickOn(mob/living/clicker, params, atom/click_target)
	if(!IsAvailable(TRUE))
		return FALSE
	if(!click_target)
		return FALSE
	if(!PreActivate(click_target))
		return FALSE
	if(unset_after_click)
		unset_click_ability(clicker, refund_cooldown = FALSE)
	clicker.next_click = world.time + click_cd_override
	return TRUE

/datum/action/cooldown/spell/proc/set_click_ability(mob/on_who)
	SHOULD_CALL_PARENT(TRUE)
	on_who.click_intercept = src
	if(ranged_mousepointer && on_who.client)
		on_who.client.mouse_pointer_icon = ranged_mousepointer
	UpdateButtonIcon()
	return TRUE

/// refund_cooldown = TRUE, gdy gracz sam wyłącza celowanie, FALSE po użyciu zaklęcia
/datum/action/cooldown/spell/proc/unset_click_ability(mob/on_who, refund_cooldown = TRUE)
	SHOULD_CALL_PARENT(TRUE)
	if(on_who.click_intercept == src)
		on_who.click_intercept = null
	if(ranged_mousepointer)
		on_who.update_mouse_pointer()
	UpdateButtonIcon()
	return TRUE

/datum/action/cooldown/spell/proc/PreActivate(atom/target)
	if(SEND_SIGNAL(owner, COMSIG_MOB_ABILITY_STARTED, src) & COMPONENT_BLOCK_ABILITY_START)
		return FALSE
	if(!is_valid_target(target))
		return FALSE
	return Activate(target)

/// Czy właściciel może teraz rzucić zaklęcie (bez sprawdzania celu)
/datum/action/cooldown/spell/proc/can_cast_spell(feedback = TRUE)
	if(!owner)
		return FALSE

	var/turf/caster_turf = get_turf(owner)
	if((spell_requirements & SPELL_REQUIRES_STATION) && !is_station_level(caster_turf?.z))
		if(feedback)
			to_chat(owner, "<span class='warning'>Tu nie rzucisz [src]!</span>")
		return FALSE

	if((spell_requirements & SPELL_REQUIRES_MIND) && !owner.mind)
		return FALSE

	if(owner.mind && !bypass_cost && LAZYLEN(resource_costs))
		for(var/resource in resource_costs)
			if(!SEND_SIGNAL(owner.mind, COMSIG_MIND_CHECK_ANTAG_RESOURCE, resource, resource_costs[resource]))
				if(feedback)
					to_chat(owner, "<span class='warning'>Masz za mało [resource]!</span>")
				return FALSE

	if((spell_requirements & SPELL_REQUIRES_NO_ANTIMAGIC) && owner.anti_magic_check(TRUE, FALSE, FALSE, TRUE))
		if(feedback)
			to_chat(owner, "<span class='warning'>Coś antymagicznego nie pozwala ci rzucić [src]!</span>")
		return FALSE

	if(!(spell_requirements & SPELL_CASTABLE_WHILE_PHASED) && istype(owner.loc, /obj/effect/dummy))
		if(feedback)
			to_chat(owner, "<span class='warning'>[src] rzucisz dopiero po pełnym zmaterializowaniu się!</span>")
		return FALSE

	if(!try_invoke(feedback))
		return FALSE

	if(!ishuman(owner))
		if(spell_requirements & SPELL_REQUIRES_HUMAN)
			if(feedback)
				to_chat(owner, "<span class='warning'>[src] mogą rzucać tylko ludzie!</span>")
			return FALSE
		if(!(spell_requirements & SPELL_CASTABLE_AS_BRAIN) && isbrain(owner))
			if(feedback)
				to_chat(owner, "<span class='warning'>W tym stanie nie rzucisz [src]!</span>")
			return FALSE
		if(ispAI(owner) || (isAI(owner) && istype(owner.loc, /obj/item/aicard)))
			return FALSE

	return TRUE

/// Czy cel jest dobry. Dla zaklęć bez celowania cast_on to rzucający.
/datum/action/cooldown/spell/proc/is_valid_target(atom/cast_on)
	return TRUE

/datum/action/cooldown/spell/proc/Activate(atom/cast_on)
	SHOULD_NOT_OVERRIDE(TRUE)

	var/precast_result = before_cast(cast_on)
	if(precast_result & SPELL_CANCEL_CAST)
		return FALSE

	if(!(precast_result & SPELL_NO_FEEDBACK))
		spell_feedback()

	cast(cast_on)

	if(!(precast_result & SPELL_NO_IMMEDIATE_COOLDOWN))
		StartCooldown()
		consume_resource()

	after_cast(cast_on)
	if(!QDELETED(src))
		UpdateButtonIcon()
	return TRUE

/// Ostatnia szansa na przerwanie. Zwraca flagi SPELL_*.
/datum/action/cooldown/spell/proc/before_cast(atom/cast_on)
	SHOULD_CALL_PARENT(TRUE)
	return SEND_SIGNAL(src, COMSIG_SPELL_BEFORE_CAST, cast_on)

/// Główny efekt zaklęcia
/datum/action/cooldown/spell/proc/cast(atom/cast_on)
	SHOULD_CALL_PARENT(TRUE)
	if(owner?.ckey)
		owner.log_message("cast the spell [name][cast_on != owner ? " on / at [cast_on]" : ""].", LOG_ATTACK)

/// Efekty po rzuceniu, odnowienie już trwa
/datum/action/cooldown/spell/proc/after_cast(atom/cast_on)
	SHOULD_CALL_PARENT(TRUE)
	if(owner && sparks_amt)
		do_sparks(sparks_amt, FALSE, get_turf(owner))
	SEND_SIGNAL(src, COMSIG_SPELL_AFTER_CAST, cast_on)

/// Płaci koszt w zasobach antagonisty
/datum/action/cooldown/spell/proc/consume_resource()
	if(!bypass_cost && owner?.mind && LAZYLEN(resource_costs))
		SEND_SIGNAL(owner.mind, COMSIG_MIND_SPEND_ANTAG_RESOURCE, resource_costs)

/datum/action/cooldown/spell/proc/spell_feedback()
	if(!owner)
		return
	if(invocation_type != INVOCATION_NONE)
		invocation()
	if(sound)
		playsound(get_turf(owner), sound, 50, TRUE)

/datum/action/cooldown/spell/proc/invocation()
	switch(invocation_type)
		if(INVOCATION_SHOUT)
			owner.say(invocation, forced = "spell ([src])")
		if(INVOCATION_WHISPER)
			owner.whisper(invocation)
		if(INVOCATION_EMOTE)
			owner.visible_message(invocation, invocation_self_message)

/datum/action/cooldown/spell/proc/try_invoke(feedback = TRUE)
	if(spell_requirements & SPELL_CASTABLE_WITHOUT_INVOCATION)
		return TRUE
	if(invocation_type == INVOCATION_NONE || invocation_type == INVOCATION_EMOTE)
		return TRUE
	if(!isliving(owner))
		if(feedback)
			to_chat(owner, "<span class='warning'>Musisz żyć, żeby wypowiedzieć [src]!</span>")
		return FALSE
	var/mob/living/living_owner = owner
	if(!living_owner.can_speak_vocal())
		if(feedback)
			to_chat(owner, "<span class='warning'>Nie możesz wydusić z siebie słów [src]!</span>")
		return FALSE
	return TRUE

/// Cofa odnowienie (np. gdy zaklęcie nie wyszło)
/datum/action/cooldown/spell/proc/reset_spell_cooldown()
	next_use_time = world.time
	update_cooldown_text()
	UpdateButtonIcon()

/datum/action/cooldown/spell/StartCooldown(override_cooldown_time)
	var/cooldown_amount = isnum(override_cooldown_time) ? override_cooldown_time : cooldown_time
	if(owner && HAS_TRAIT(owner, TRAIT_FAST_COOLDOWNS))
		cooldown_amount *= 0.66
	next_use_time = world.time + cooldown_amount
	update_cooldown_text()
	UpdateButtonIcon()
	if(cooldown_amount > 0)
		START_PROCESSING(SSfastprocess, src)

/datum/action/cooldown/spell/proc/update_cooldown_text()
	if(!button)
		return
	var/time_left = max(next_use_time - world.time, 0)
	button.maptext = (owner && time_left) ? MAPTEXT("<b>[round(time_left / 10, 0.1)]</b>") : ""

/datum/action/cooldown/spell/process()
	update_cooldown_text()
	if(!owner || next_use_time <= world.time)
		UpdateButtonIcon()
		return PROCESS_KILL

/// Czy zaklęcie jest teraz włączone (celowanie, przełącznik, dłoń)
/datum/action/cooldown/spell/proc/is_action_active()
	return click_to_activate && owner?.click_intercept == src

/datum/action/cooldown/spell/UpdateButtonIcon(status_only = FALSE, force = FALSE)
	. = ..()
	if(. && is_action_active())
		button.color = COLOR_GREEN

// Ochrona przed magią celu

/// Czy mob ma ochronę przed zaklęciem z danymi flagami MAGIC_RESISTANCE_*
/mob/proc/can_block_magic(antimagic_flags = MAGIC_RESISTANCE)
	if(!antimagic_flags)
		return FALSE
	if((antimagic_flags & MAGIC_RESISTANCE) && anti_magic_check(TRUE, FALSE))
		return TRUE
	if((antimagic_flags & MAGIC_RESISTANCE_HOLY) && anti_magic_check(FALSE, TRUE))
		return TRUE
	if(antimagic_flags & MAGIC_RESISTANCE_MIND)
		if(anti_magic_check(TRUE, FALSE, FALSE))
			return TRUE
		var/obj/item/hat = get_item_by_slot(ITEM_SLOT_HEAD)
		if(istype(hat, /obj/item/clothing/head/foilhat))
			return TRUE
	return FALSE
