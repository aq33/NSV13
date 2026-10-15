// AQUILA - darkspawn: zdolności czarnoksiężnika (port z Yogstation)

// Laska skupienia: wrodzona broń czarnoksiężnika

/datum/action/cooldown/spell/toggle/dark_staff
	name = "Laska skupienia"
	desc = "Wyciągasz ciemność z pustki i splatasz z niej laskę."
	icon_icon = 'aquila/icons/mob/darkspawn/actions_darkspawn.dmi'
	button_icon_state = "shadow_staff"
	background_icon_state = "bg_alien"
	buttontooltipstyle = "alien"
	check_flags = AB_CHECK_HANDS_BLOCKED | AB_CHECK_CONSCIOUS | AB_CHECK_LYING
	spell_requirements = SPELL_REQUIRES_HUMAN
	antimagic_flags = NONE
	/// Ulepszenia laski (STAFF_UPGRADE_*)
	var/effect_flags = NONE

/datum/action/cooldown/spell/toggle/dark_staff/link_to(Target)
	. = ..()
	if(istype(target, /datum/mind))
		RegisterSignal(target, COMSIG_DARKSPAWN_UPGRADE_ABILITY, PROC_REF(handle_upgrade))
		RegisterSignal(target, COMSIG_DARKSPAWN_DOWNGRADE_ABILITY, PROC_REF(handle_downgrade))

/datum/action/cooldown/spell/toggle/dark_staff/proc/handle_upgrade(datum/source, flag)
	SIGNAL_HANDLER
	effect_flags |= flag
	for(var/obj/item/gun/magic/darkspawn/staff in owner)
		staff.effect_flags = effect_flags

/datum/action/cooldown/spell/toggle/dark_staff/proc/handle_downgrade(datum/source, flag)
	SIGNAL_HANDLER
	effect_flags &= ~flag
	for(var/obj/item/gun/magic/darkspawn/staff in owner)
		staff.effect_flags = effect_flags

/datum/action/cooldown/spell/toggle/dark_staff/process()
	if(owner)
		active = owner.is_holding_item_of_type(/obj/item/gun/magic/darkspawn)
	return ..()

/datum/action/cooldown/spell/toggle/dark_staff/can_cast_spell(feedback = TRUE)
	if(owner && !active && !length(owner.get_empty_held_indexes()))
		if(feedback)
			to_chat(owner, "<span class='warning'>Potrzebujesz wolnej ręki!</span>")
		return FALSE
	return ..()

/datum/action/cooldown/spell/toggle/dark_staff/Enable()
	owner.balloon_alert(owner, "Shhouna")
	owner.visible_message("<span class='warning'>[owner] splata cienie w laskę!</span>", "<span class='velvet'>Przywołujesz laskę. Obejrzyj ją, żeby zobaczyć, co potrafi.</span>")
	playsound(owner, 'aquila/sound/darkspawn/pass_create.ogg', 50, TRUE)
	var/obj/item/gun/magic/darkspawn/staff = new(owner)
	staff.effect_flags = effect_flags
	if(!owner.put_in_hands(staff))
		qdel(staff)
		active = FALSE

/datum/action/cooldown/spell/toggle/dark_staff/Disable()
	owner.balloon_alert(owner, "Haoo")
	owner.visible_message("<span class='warning'>Laska [owner] rozpływa się!</span>", "<span class='velvet'>Rozpraszasz laskę.</span>")
	playsound(owner, 'aquila/sound/darkspawn/pass_dispel.ogg', 50, TRUE)
	for(var/obj/item/gun/magic/darkspawn/staff in owner)
		qdel(staff)

// Zgaszenie: pochłania światło wszystkiego w zasięgu wzroku

/datum/action/cooldown/spell/aoe/extinguish
	name = "Zgaszenie"
	desc = "Gasisz wszystkie światła wokół siebie."
	icon_icon = 'aquila/icons/mob/darkspawn/actions_darkspawn.dmi'
	button_icon_state = "extinguish"
	background_icon_state = "bg_alien"
	buttontooltipstyle = "alien"
	antimagic_flags = MAGIC_RESISTANCE_MIND
	check_flags = AB_CHECK_CONSCIOUS
	spell_requirements = SPELL_REQUIRES_HUMAN
	resource_costs = list(ANTAG_RESOURCE_DARKSPAWN = 60)
	cooldown_time = 30 SECONDS
	sound = 'aquila/sound/darkspawn/veil_mind_gasp.ogg'
	aoe_radius = 6
	/// Co widział rzucający w chwili rzucenia (nie gasi zza ścian)
	var/list/seen_things

/datum/action/cooldown/spell/aoe/extinguish/cast(atom/cast_on)
	seen_things = view(owner)
	. = ..()
	seen_things = null
	owner.balloon_alert(owner, "Shwooh")
	to_chat(owner, "<span class='velvet'>Gasisz wszystkie światła.</span>")

/datum/action/cooldown/spell/aoe/extinguish/cast_on_thing_in_aoe(atom/victim, atom/caster)
	if(isturf(victim) || !(victim in seen_things))
		return
	if(ishuman(victim))
		var/mob/living/carbon/human/target = victim
		if(target.can_block_magic(antimagic_flags))
			return
		target.ExtinguishMob()
	if(isobj(victim))
		var/obj/target = victim
		target.extinguish()
	if(istype(victim, /obj/machinery/light))
		var/obj/machinery/light/lamp = victim
		if(lamp.status == LIGHT_OK)
			lamp.break_light_tube()
		return
	INVOKE_ASYNC(victim, TYPE_PROC_REF(/atom, lighteater_act), null)

// Pusty ładunek: wyłącza zasilanie całej stacji przez APC

/datum/action/cooldown/spell/touch/null_charge
	name = "Pusty ładunek"
	desc = "Przez sprawne APC mieszasz w sieci energetycznej, na jakiś czas wyłączając prąd na całej stacji. APC przy tym się psuje."
	icon_icon = 'aquila/icons/mob/darkspawn/actions_darkspawn.dmi'
	button_icon_state = "null_charge"
	background_icon_state = "bg_alien"
	buttontooltipstyle = "alien"
	antimagic_flags = NONE
	check_flags = AB_CHECK_IMMOBILE | AB_CHECK_CONSCIOUS | AB_CHECK_LYING
	spell_requirements = SPELL_REQUIRES_HUMAN
	cooldown_time = 10 MINUTES
	resource_costs = list(ANTAG_RESOURCE_DARKSPAWN = 200)
	hand_path = /obj/item/melee/spell_hand/darkspawn

/datum/action/cooldown/spell/touch/null_charge/is_valid_target(atom/cast_on)
	if(!istype(cast_on, /obj/machinery/power/apc))
		return FALSE
	var/obj/machinery/power/apc/target = cast_on
	if(target.machine_stat & BROKEN)
		to_chat(owner, "<span class='danger'>[target] jest zbyt zniszczone, żeby sięgnąć przez nie do sieci.</span>")
		return FALSE
	return TRUE

/datum/action/cooldown/spell/touch/null_charge/cast_on_hand_hit(obj/item/melee/spell_hand/hand, obj/machinery/power/apc/target, mob/living/carbon/human/caster)
	if(!istype(target))
		return FALSE
	caster.balloon_alert(caster, "Xlahwa")
	target.set_light(0)
	target.visible_message("<span class='warning'>[target] migocze i zaczyna ciemnieć.</span>")
	to_chat(caster, "<span class='velvet'>Przyciemniasz ekran APC i ostrożnie zaczynasz przelewać jego moc w pustkę.</span>")
	if(!do_after(caster, 5 SECONDS, target = target))
		to_chat(caster, "<span class='velvet'>Tracisz skupienie, a APC nagle odzyskuje zasilanie!</span>")
		target.update()
		target.visible_message("<span class='warning'>[target] zaczyna jasno świecić!</span>")
		return FALSE
	if(target.machine_stat & BROKEN)
		to_chat(caster, "<span class='danger'>[target] jest zbyt zniszczone, żeby sięgnąć przez nie do sieci.</span>")
		return FALSE
	var/datum/antagonist/darkspawn/darkspawn = isdarkspawn(caster)
	darkspawn?.block_psi(60 SECONDS, type)
	caster.balloon_alert(caster, "...SHWOOH!")
	priority_announce("Wykryto nieprawidłową aktywność w sieci elektroenergetycznej [station_name()]. W ramach środka ostrożności zasilanie stacji zostanie wyłączone na nieokreślony czas.", "Krytyczna awaria zasilania", ANNOUNCER_POWEROFF)
	power_fail(30, 40)
	to_chat(caster, "<span class='velvet'>Oddajesz moc APC pustce, niszcząc je i wyłączając wszystkie pozostałe.</span>")
	target.set_broken()
	return TRUE

// Ekstrakcja: wysysa życie wroga albo oddaje je sojusznikowi

/obj/effect/ebeam/darkspawn
	name = "void beam"

/datum/action/cooldown/spell/pointed/extract
	name = "Ekstrakcja"
	desc = "Wysysasz siły życiowe celu albo oddajesz je sojusznikowi."
	icon_icon = 'aquila/icons/mob/darkspawn/actions_darkspawn.dmi'
	button_icon_state = "extract"
	background_icon_state = "bg_alien"
	buttontooltipstyle = "alien"
	antimagic_flags = MAGIC_RESISTANCE_MIND
	check_flags = AB_CHECK_CONSCIOUS | AB_CHECK_HANDS_BLOCKED | AB_CHECK_LYING
	spell_requirements = SPELL_REQUIRES_HUMAN
	ranged_mousepointer = 'aquila/icons/effects/mouse_pointers/visor_reticule.dmi'
	cast_range = 7
	resource_costs = list(ANTAG_RESOURCE_DARKSPAWN = 2)
	/// Kto jest celem
	var/mob/living/channeled
	var/datum/beam/visual
	/// Obrażenia albo leczenie na tick
	var/damage_amount = 2
	/// Odnowienie po zakończeniu
	var/actual_cooldown = 15 SECONDS
	/// Czy leczy sojusznika
	var/healing = FALSE
	var/balloon_counter = 0

/datum/action/cooldown/spell/pointed/extract/Destroy()
	cancel()
	return ..()

/datum/action/cooldown/spell/pointed/extract/is_valid_target(atom/cast_on)
	if(!isliving(cast_on))
		return FALSE
	var/mob/living/living_cast_on = cast_on
	if(living_cast_on.can_block_magic(antimagic_flags))
		return FALSE
	if(living_cast_on.stat == DEAD)
		to_chat(owner, "<span class='warning'>[cast_on] nie żyje!</span>")
		return FALSE
	if(cast_on == owner)
		to_chat(owner, "<span class='warning'>Nie możesz rzucić tego na siebie!</span>")
		return FALSE
	return TRUE

/datum/action/cooldown/spell/pointed/extract/Trigger(trigger_flags, atom/target)
	if(cancel()) // drugie kliknięcie przerywa kanał
		return FALSE
	return ..()

/datum/action/cooldown/spell/pointed/extract/cast(mob/living/cast_on)
	. = ..()
	owner.balloon_alert(owner, "Qokxlez")
	visual = owner.Beam(cast_on, "slingbeam", 'aquila/icons/mob/darkspawn/darkspawn.dmi', INFINITY, cast_range + 1, /obj/effect/ebeam/darkspawn)
	channeled = cast_on
	healing = is_team_darkspawn(channeled)
	START_PROCESSING(SSfastprocess, src)

/datum/action/cooldown/spell/pointed/extract/process()
	if(!channeled)
		return ..()
	balloon_counter++
	if(!owner?.mind || !visual || QDELETED(visual) || QDELETED(channeled))
		cancel()
		return
	if(!healing && channeled.stat == DEAD)
		cancel()
		return
	if(healing && channeled.health >= channeled.maxHealth)
		cancel()
		return
	if(get_dist(owner, channeled) > cast_range)
		cancel()
		return
	if(!SEND_SIGNAL(owner.mind, COMSIG_MIND_SPEND_ANTAG_RESOURCE, resource_costs))
		cancel()
		return
	if(balloon_counter >= 5)
		balloon_counter = 0
		owner.balloon_alert(owner, "...thum...")
	if(healing)
		channeled.adjustBruteLoss(-damage_amount)
		channeled.adjustFireLoss(-damage_amount)
		channeled.adjustToxLoss(-damage_amount)
		channeled.adjustStaminaLoss(-damage_amount)
	else
		channeled.apply_damage(damage_amount, BURN)
		if(isliving(owner))
			var/mob/living/healed = owner
			healed.adjustBruteLoss(-damage_amount)
			healed.adjustFireLoss(-damage_amount)
			healed.adjustCloneLoss(-damage_amount)
			healed.adjustStaminaLoss(-damage_amount)

/// Kończy kanał. TRUE, jeśli coś faktycznie przerwał.
/datum/action/cooldown/spell/pointed/extract/proc/cancel()
	balloon_counter = 0
	if(visual)
		QDEL_NULL(visual)
	if(channeled)
		channeled = null
		StartCooldown(actual_cooldown)
		owner?.balloon_alert(owner, "...qokshe")
		return TRUE
	return FALSE

// Zew otchłani: macki z zaświatów

/datum/action/cooldown/spell/pointed/darkspawn_build/abyssal_call
	name = "Zew otchłani"
	desc = "Przyzywasz zza zasłony macki, które chwytają wroga."
	button_icon_state = "abyssal_call"
	cast_range = 10
	cast_time = 0
	object_type = /obj/effect/temp_visual/goliath_tentacle/darkspawn/original
	cooldown_time = 10 SECONDS
	can_density = TRUE
	aim_assist = TRUE
	language_final = "Xylt'he kkxla'thamara"

// Masowa halucynacja

/datum/action/cooldown/spell/aoe/mass_hallucination
	name = "Masowa halucynacja"
	desc = "Wywołuje u wszystkich wrogów w pobliżu krótkie majaczenie."
	icon_icon = 'aquila/icons/mob/darkspawn/actions_darkspawn.dmi'
	button_icon_state = "mass_hallucination"
	background_icon_state = "bg_alien"
	buttontooltipstyle = "alien"
	antimagic_flags = MAGIC_RESISTANCE_MIND
	check_flags = AB_CHECK_CONSCIOUS
	spell_requirements = SPELL_REQUIRES_HUMAN
	resource_costs = list(ANTAG_RESOURCE_DARKSPAWN = 30)
	cooldown_time = 30 SECONDS
	sound = 'aquila/sound/darkspawn/veil_mind_scream.ogg'
	aoe_radius = 7
	/// Ile halucynacji (jedna na sekundę)
	var/hallucination_triggers = 3

/datum/action/cooldown/spell/aoe/mass_hallucination/cast(atom/cast_on)
	. = ..()
	owner.balloon_alert(owner, "H'ellekth'ele")

/datum/action/cooldown/spell/aoe/mass_hallucination/cast_on_thing_in_aoe(atom/victim, atom/caster)
	if(!iscarbon(victim))
		return
	var/mob/living/carbon/target = victim
	if(is_team_darkspawn(target) || target.can_block_magic(antimagic_flags))
		return
	hallucinate(target, hallucination_triggers)

/datum/action/cooldown/spell/aoe/mass_hallucination/proc/hallucinate(mob/living/carbon/target, times)
	if(times <= 0 || QDELETED(target))
		return
	var/picked_hallucination = pickweight(GLOB.hallucination_list)
	new picked_hallucination(target, TRUE)
	addtimer(CALLBACK(src, PROC_REF(hallucinate), target, times - 1), 1 SECONDS)

// Pochwycenie: paraliż z bliska, wyczerpanie z daleka

/datum/action/cooldown/spell/pointed/seize
	name = "Pochwycenie"
	desc = "Pętasz umysł celu. Z bliska nie może się ruszać ani mówić, z daleka opada z sił."
	icon_icon = 'aquila/icons/mob/darkspawn/actions_darkspawn.dmi'
	button_icon_state = "seize"
	background_icon_state = "bg_alien"
	buttontooltipstyle = "alien"
	antimagic_flags = MAGIC_RESISTANCE_MIND
	check_flags = AB_CHECK_CONSCIOUS | AB_CHECK_HANDS_BLOCKED | AB_CHECK_LYING
	spell_requirements = SPELL_CASTABLE_AS_BRAIN
	resource_costs = list(ANTAG_RESOURCE_DARKSPAWN = 35)
	cooldown_time = 30 SECONDS
	cast_range = 10
	ranged_mousepointer = 'aquila/icons/effects/mouse_pointers/cult_target.dmi'
	/// Paraliż z bliska
	var/stun_duration = 10 SECONDS

/datum/action/cooldown/spell/pointed/seize/before_cast(atom/cast_on)
	. = ..()
	if(!isliving(cast_on))
		return . | SPELL_CANCEL_CAST
	var/mob/living/target = cast_on
	if(target.stat)
		to_chat(owner, "<span class='warning'>[target] musi być przytomny!</span>")
		return . | SPELL_CANCEL_CAST
	if(is_team_darkspawn(target))
		to_chat(owner, "<span class='warning'>Nie możesz pochwycić sojusznika!</span>")
		return . | SPELL_CANCEL_CAST

/datum/action/cooldown/spell/pointed/seize/cast(atom/cast_on)
	. = ..()
	if(!isliving(cast_on))
		return
	if(iscarbon(owner))
		var/mob/living/carbon/user = owner
		if(!(user.check_obscured_slots() & ITEM_SLOT_EYES))
			user.visible_message("<span class='warning'><b>Oczy [user] rozbłyskują głębokim fioletem</b></span>")
	owner.balloon_alert(owner, "Sskr'aya")
	var/mob/living/target = cast_on
	if(target.can_block_magic(antimagic_flags))
		return
	var/distance = get_dist(target, owner)
	if(distance <= 2)
		target.visible_message("<span class='danger'>[target] nagle osuwa się na ziemię...</span>")
		to_chat(target, "<span class='userdanger'>Przez twój umysł przelatuje fioletowe światło i tracisz władzę nad ciałem!</span>")
		target.Paralyze(stun_duration)
		if(iscarbon(target))
			var/mob/living/carbon/M = target
			M.silent += 10
	else
		var/loss = max(120 - (distance * 10), 0)
		target.adjustStaminaLoss(loss)
		target.stuttering += loss / 10
		to_chat(target, "<span class='userdanger'>Przez twój umysł przelatuje fioletowe światło, a ciało zalewa wyczerpanie...</span>")

// Kwantowe zakłócenie: znikasz na chwilę, zostawiając iluzję

/datum/action/cooldown/spell/quantum_disruption
	name = "Kwantowe zakłócenie"
	desc = "Zaburzasz bieg możliwości: przez chwilę jesteś wszędzie, gdzie mógłbyś być, a w twoim miejscu zostaje iluzja."
	icon_icon = 'aquila/icons/mob/darkspawn/actions_darkspawn.dmi'
	button_icon_state = "quantum_disruption"
	background_icon_state = "bg_alien"
	buttontooltipstyle = "alien"
	antimagic_flags = NONE
	check_flags = AB_CHECK_CONSCIOUS
	spell_requirements = SPELL_REQUIRES_HUMAN
	resource_costs = list(ANTAG_RESOURCE_DARKSPAWN = 80)
	cooldown_time = 60 SECONDS
	/// Jak długo trwa
	var/length = 5 SECONDS

/datum/action/cooldown/spell/quantum_disruption/can_cast_spell(feedback = TRUE)
	if(owner && !isturf(owner.loc))
		return FALSE
	return ..()

/datum/action/cooldown/spell/quantum_disruption/cast(atom/cast_on)
	. = ..()
	var/mob/living/user = owner
	owner.balloon_alert(owner, "KSH SHOL'NAXHAR!")
	var/datum/antagonist/darkspawn/darkspawn = isdarkspawn(owner)
	darkspawn?.block_psi(20 SECONDS, type)
	var/mob/living/simple_animal/hostile/illusion/fake = new(get_turf(user))
	fake.setDir(user.dir)
	fake.Copy_Parent(user, length, 100)
	fake.target = null
	user.SetAllImmobility(0)
	user.setStaminaLoss(0)
	INVOKE_ASYNC(src, PROC_REF(disappear), user, fake)

/datum/action/cooldown/spell/quantum_disruption/proc/disappear(mob/living/user, mob/living/fake)
	user.status_flags |= GODMODE
	ADD_TRAIT(user, TRAIT_PACIFISM, type)
	darkspawn_jaunt(user, length)
	if(QDELETED(user))
		return
	user.status_flags &= ~GODMODE
	REMOVE_TRAIT(user, TRAIT_PACIFISM, type)
	if(!QDELETED(fake))
		fake.death()

// Promień pustki: po chwili strzela przez całą stację pasem pustki

/datum/action/cooldown/spell/pointed/shadow_beam
	name = "Promień pustki"
	desc = "Po krótkiej chwili wystrzeliwuje ogromny promień pustki przez całą stację."
	icon_icon = 'aquila/icons/mob/darkspawn/actions_darkspawn.dmi'
	button_icon_state = "shadow_beam"
	background_icon_state = "bg_alien"
	buttontooltipstyle = "alien"
	antimagic_flags = MAGIC_RESISTANCE_MIND
	check_flags = AB_CHECK_CONSCIOUS
	spell_requirements = SPELL_REQUIRES_HUMAN
	cooldown_time = 90 SECONDS
	resource_costs = list(ANTAG_RESOURCE_DARKSPAWN = 100)
	ranged_mousepointer = 'aquila/icons/effects/mouse_pointers/visor_reticule.dmi'
	cast_range = INFINITY
	aim_assist = FALSE
	var/charging = FALSE
	/// Ile sekund ładowania
	var/charge_ticks = 2
	var/turf/targets_from
	var/turf/targets_to

/datum/action/cooldown/spell/pointed/shadow_beam/can_cast_spell(feedback = TRUE)
	if(charging)
		return FALSE
	return ..()

/datum/action/cooldown/spell/pointed/shadow_beam/is_valid_target(atom/cast_on)
	return TRUE

/datum/action/cooldown/spell/pointed/shadow_beam/cast(atom/cast_on)
	. = ..()
	if(charging)
		return
	targets_from = get_turf(owner)
	targets_to = get_turf(cast_on)
	owner.balloon_alert(owner, "Qwo...")
	to_chat(owner, "<span class='velvet'>Zaczynasz zbierać psioniczną energię.</span>")
	charging = TRUE
	INVOKE_ASYNC(src, PROC_REF(start_beam), owner)

/datum/action/cooldown/spell/pointed/shadow_beam/proc/start_beam(mob/user)
	INVOKE_ASYNC(GLOBAL_PROC, GLOBAL_PROC_REF(darkspawn_charge_effect), src, user, charge_ticks, TRUE)
	if(do_after(user, charge_ticks SECONDS, target = user))
		fire_beam(user)
	charging = FALSE

/datum/action/cooldown/spell/pointed/shadow_beam/proc/fire_beam(mob/user)
	if(!targets_from || !targets_to)
		return
	user.balloon_alert(user, "...GX'KSHA!")
	var/datum/antagonist/darkspawn/darkspawn = isdarkspawn(user)
	darkspawn?.block_psi(30 SECONDS, type)
	playsound(user, 'aquila/sound/darkspawn/devour_will_end.ogg', 100, FALSE, 30)
	for(var/turf/step_target in getline(targets_from, targets_to))
		spawn_ground(step_target)
	// sto pól dalej mniej więcej wzdłuż tej samej linii
	var/turf/distant_target = get_turf_in_angle(get_angle(targets_from, targets_to), targets_to, 100)
	for(var/turf/step_target in getline(targets_to, distant_target))
		spawn_ground(step_target)

/datum/action/cooldown/spell/pointed/shadow_beam/proc/spawn_ground(turf/target)
	for(var/turf/realtile in RANGE_TURFS(1, target))
		if(!(locate(/obj/effect/temp_visual/darkspawn/chasm) in realtile))
			new /obj/effect/temp_visual/darkspawn/chasm(realtile)

/// Dźwięki i runy podczas ładowania potężnych zaklęć czarnoksiężnika
/proc/darkspawn_charge_effect(datum/action/cooldown/spell/source, mob/user, times, first)
	if(QDELETED(source) || QDELETED(user) || times <= 0)
		return
	var/charging = source.vars["charging"]
	if(!charging)
		return
	var/max_ticks = source.vars["charge_ticks"]
	var/power = max_ticks - times
	var/volume = min(10 + (power * 20), 60)
	playsound(user, 'sound/effects/magic.ogg', volume, TRUE, power)
	playsound(user, 'aquila/sound/darkspawn/devour_will_form.ogg', volume, TRUE, power)
	new /obj/effect/temp_visual/cult/rune_spawn/rune1(user.loc, 2 SECONDS, COLOR_VELVET)
	addtimer(CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(darkspawn_charge_effect), source, user, times - 1, !first), 1 SECONDS)

// Zerowy wybuch: eksplozja pustki we wskazanym miejscu

/datum/action/cooldown/spell/pointed/null_burst
	name = "Zerowy wybuch"
	desc = "Po krótkiej chwili we wskazanym miejscu wybucha pustka."
	icon_icon = 'aquila/icons/mob/darkspawn/actions_darkspawn.dmi'
	button_icon_state = "null_burst"
	background_icon_state = "bg_alien"
	buttontooltipstyle = "alien"
	antimagic_flags = MAGIC_RESISTANCE_MIND
	check_flags = AB_CHECK_CONSCIOUS
	spell_requirements = SPELL_REQUIRES_HUMAN
	cooldown_time = 90 SECONDS
	resource_costs = list(ANTAG_RESOURCE_DARKSPAWN = 100)
	ranged_mousepointer = 'aquila/icons/effects/mouse_pointers/visor_reticule.dmi'
	cast_range = INFINITY
	aim_assist = FALSE
	var/charging = FALSE
	var/charge_ticks = 2
	var/turf/targets_to
	/// Promień wybuchu
	var/burst_range = 4
	/// Mnożnik opóźnienia między kolejnymi falami
	var/spread_speed = 1

/datum/action/cooldown/spell/pointed/null_burst/can_cast_spell(feedback = TRUE)
	if(charging)
		return FALSE
	return ..()

/datum/action/cooldown/spell/pointed/null_burst/is_valid_target(atom/cast_on)
	return TRUE

/datum/action/cooldown/spell/pointed/null_burst/cast(atom/cast_on)
	. = ..()
	if(charging)
		return
	targets_to = get_turf(cast_on)
	owner.balloon_alert(owner, "Qwo...")
	to_chat(owner, "<span class='velvet'>Zaczynasz zbierać psioniczną energię.</span>")
	charging = TRUE
	INVOKE_ASYNC(src, PROC_REF(start_burst), owner)

/datum/action/cooldown/spell/pointed/null_burst/proc/start_burst(mob/user)
	INVOKE_ASYNC(GLOBAL_PROC, GLOBAL_PROC_REF(darkspawn_charge_effect), src, user, charge_ticks, TRUE)
	if(do_after(user, charge_ticks SECONDS, target = user))
		burst(user)
	charging = FALSE

/datum/action/cooldown/spell/pointed/null_burst/proc/burst(mob/user)
	if(!targets_to)
		return
	user.balloon_alert(user, "...GWO'KSHA!")
	var/datum/antagonist/darkspawn/darkspawn = isdarkspawn(user)
	darkspawn?.block_psi(30 SECONDS, type)
	playsound(user, 'aquila/sound/darkspawn/devour_will_end.ogg', 100, FALSE, 30)
	playsound(targets_to, 'aquila/sound/darkspawn/divulge_end.ogg', 70, TRUE, burst_range)
	var/last_dist = 0
	var/real_delay = 0
	for(var/turf/T as anything in spiral_range_turfs(burst_range, targets_to))
		var/dist = get_dist(targets_to, T)
		if(dist > last_dist)
			last_dist = dist
			real_delay += 0.1 SECONDS + (min(burst_range - last_dist, 1.2 SECONDS) * spread_speed) // przyspiesza im dalej
		addtimer(CALLBACK(src, PROC_REF(spawn_ground), T), real_delay)

/datum/action/cooldown/spell/pointed/null_burst/proc/spawn_ground(turf/target)
	new /obj/effect/temp_visual/darkspawn/chasm(target)

// Pustka: efekt promienia i wybuchu

/obj/effect/temp_visual/darkspawn
	name = "echoing void"
	icon = 'aquila/icons/mob/darkspawn/darkspawn_effects.dmi'
	icon_state = "blank_dspawn"
	anchored = TRUE
	move_resist = INFINITY

/// Pole spowolnienia, które po chwili wybucha
/obj/effect/temp_visual/darkspawn/chasm
	icon_state = "consuming"
	duration = 4 SECONDS // opóźnienie do wybuchu, nie krótsze niż 1,1 s, bo psuje się animacja
	layer = ABOVE_OPEN_TURF_LAYER
	alpha = 0

/obj/effect/temp_visual/darkspawn/chasm/Initialize(mapload)
	. = ..()
	var/static/list/loc_connections = list(
		COMSIG_ATOM_ENTERED = PROC_REF(on_entered),
	)
	AddElement(/datum/element/connect_loc, loc_connections)
	animate(src, alpha = 255, time = 1.1 SECONDS)

/obj/effect/temp_visual/darkspawn/chasm/proc/on_entered(datum/source, atom/movable/AM)
	SIGNAL_HANDLER
	if(isliving(AM) && !is_team_darkspawn(AM))
		var/mob/living/target = AM
		target.apply_status_effect(/datum/status_effect/darkspawn_slow, 1 SECONDS)

/obj/effect/temp_visual/darkspawn/chasm/Destroy()
	var/turf/T = get_turf(src)
	if(T)
		new /obj/effect/temp_visual/darkspawn/detonate(T)
	return ..()

/// Wybuch: rani wrogów i leczy sojuszników na polu
/obj/effect/temp_visual/darkspawn/detonate
	icon_state = "detonate"
	layer = ABOVE_OPEN_TURF_LAYER
	duration = 2

/obj/effect/temp_visual/darkspawn/detonate/Destroy()
	var/turf/tile_location = get_turf(src)
	for(var/mob/living/victim in tile_location?.contents)
		if(is_team_darkspawn(victim))
			victim.adjustBruteLoss(-90)
			victim.adjustFireLoss(-90)
			victim.adjustToxLoss(-90)
			victim.adjustStaminaLoss(-90)
		else if(!victim.can_block_magic(MAGIC_RESISTANCE_MIND))
			victim.take_overall_damage(10, 50, 200) // kto nie uskoczy, ten sam sobie winny
			victim.emote("scream")
	return ..()

// Wylew cienistego płomienia: zimny ogień w stożku

/datum/action/cooldown/spell/cone/staggered/shadowflame
	name = "Wylew cienistego płomienia"
	desc = "Wypuszczasz falę cienistego płomienia, który błyskawicznie wysysa ciepło z każdego."
	icon_icon = 'aquila/icons/mob/darkspawn/actions_darkspawn.dmi'
	button_icon_state = "veiling_touch"
	background_icon_state = "bg_alien"
	buttontooltipstyle = "alien"
	sound = 'sound/magic/demon_dies.ogg'
	spell_requirements = NONE
	antimagic_flags = MAGIC_RESISTANCE_MIND
	check_flags = AB_CHECK_CONSCIOUS
	cooldown_time = 60 SECONDS
	resource_costs = list(ANTAG_RESOURCE_DARKSPAWN = 100)
	delay_between_level = 0.3 SECONDS
	cone_levels = 5
	respect_density = TRUE

/datum/action/cooldown/spell/cone/staggered/shadowflame/do_turf_cone_effect(turf/target_turf, atom/caster, level)
	new /obj/effect/temp_visual/darkspawn/shadowflame(target_turf)

/datum/action/cooldown/spell/cone/staggered/shadowflame/do_mob_cone_effect(mob/living/target_mob, atom/caster, level)
	if(is_team_darkspawn(target_mob))
		return
	target_mob.apply_status_effect(/datum/status_effect/shadowflame)

/// Stożek w kolumnie szerokiej na trzy pola
/datum/action/cooldown/spell/cone/staggered/shadowflame/calculate_cone_shape(current_level)
	return (2 * current_level) - 1
