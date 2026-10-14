// AQUILA - darkspawn: zdolności wojownika (port z Yogstation)

// Macki cienia: wrodzona broń wojownika

/datum/action/cooldown/spell/toggle/shadow_tendril
	name = "Macka cienia"
	desc = "Zamieniasz rękę w masę macek o wielu zastosowaniach."
	icon_icon = 'aquila/icons/mob/darkspawn/actions_darkspawn.dmi'
	button_icon_state = "pass"
	background_icon_state = "bg_alien"
	buttontooltipstyle = "alien"
	check_flags = AB_CHECK_HANDS_BLOCKED | AB_CHECK_CONSCIOUS | AB_CHECK_LYING
	spell_requirements = SPELL_REQUIRES_HUMAN
	antimagic_flags = NONE
	/// Dodatkowe efekty z ulepszeń (TENDRIL_UPGRADE_*)
	var/ability_flags = NONE

/datum/action/cooldown/spell/toggle/shadow_tendril/link_to(Target)
	. = ..()
	if(istype(target, /datum/mind))
		RegisterSignal(target, COMSIG_DARKSPAWN_UPGRADE_ABILITY, PROC_REF(handle_upgrade))
		RegisterSignal(target, COMSIG_DARKSPAWN_DOWNGRADE_ABILITY, PROC_REF(handle_downgrade))

/datum/action/cooldown/spell/toggle/shadow_tendril/proc/handle_upgrade(datum/source, flag)
	SIGNAL_HANDLER
	ability_flags |= flag
	if(flag & TENDRIL_UPGRADE_TWIN)
		name = "Podwójne macki cienia"
		desc = "Zamieniasz jedną albo obie ręce w macki o wielu zastosowaniach."
		UpdateButtonIcon()

/datum/action/cooldown/spell/toggle/shadow_tendril/proc/handle_downgrade(datum/source, flag)
	SIGNAL_HANDLER
	ability_flags &= ~flag
	if(flag & TENDRIL_UPGRADE_TWIN)
		name = initial(name)
		desc = initial(desc)
		UpdateButtonIcon()

/datum/action/cooldown/spell/toggle/shadow_tendril/can_cast_spell(feedback = TRUE)
	if(owner && !active && !length(owner.get_empty_held_indexes()))
		if(feedback)
			to_chat(owner, "<span class='warning'>Potrzebujesz wolnej ręki!</span>")
		return FALSE
	return ..()

/datum/action/cooldown/spell/toggle/shadow_tendril/process()
	if(owner)
		active = owner.is_holding_item_of_type(/obj/item/umbral_tendrils)
	return ..()

/datum/action/cooldown/spell/toggle/shadow_tendril/Enable()
	var/list/hands_free = owner.get_empty_held_indexes()
	var/num_tendrils = min((ability_flags & TENDRIL_UPGRADE_TWIN) ? 2 : 1, LAZYLEN(hands_free))
	if(!num_tendrils)
		active = FALSE
		return
	owner.visible_message("<span class='warning'>[num_tendrils > 1 ? "Ręce" : "Ręka"] [owner] wykręca się w macki!</span>", \
		"<span class='velvet'>Zamieniasz [num_tendrils > 1 ? "ręce" : "rękę"] w macki cienia. Obejrzyj je, żeby zobaczyć, do czego służą.</span>")
	owner.balloon_alert(owner, "Ikna")
	playsound(owner, 'aquila/sound/darkspawn/pass_create.ogg', 50, TRUE)
	for(var/i in 1 to num_tendrils)
		var/obj/item/umbral_tendrils/T = new(owner)
		if(ability_flags & TENDRIL_UPGRADE_CLEAVE)
			T.cleave = TRUE
		owner.put_in_hands(T)

/datum/action/cooldown/spell/toggle/shadow_tendril/Disable()
	owner.balloon_alert(owner, "Haoo")
	owner.visible_message("<span class='warning'>Macki [owner] wracają do dawnej postaci!</span>", "<span class='notice'>Rozpraszasz macki.</span>")
	playsound(owner, 'aquila/sound/darkspawn/pass_dispel.ogg', 50, TRUE)
	for(var/obj/item/umbral_tendrils/T in owner)
		qdel(T)

// Potop: gasi ogień wokół i moczy wszystkich

/datum/action/cooldown/spell/aoe/deluge
	name = "Potop"
	desc = "Przyzywa nieskończone głębiny, by oblały wszystkich zaświatami."
	icon_icon = 'aquila/icons/mob/darkspawn/actions_darkspawn.dmi'
	button_icon_state = "deluge"
	background_icon_state = "bg_alien"
	buttontooltipstyle = "alien"
	antimagic_flags = NONE
	check_flags = AB_CHECK_CONSCIOUS
	spell_requirements = SPELL_REQUIRES_HUMAN
	resource_costs = list(ANTAG_RESOURCE_DARKSPAWN = 25)
	cooldown_time = 45 SECONDS

/datum/action/cooldown/spell/aoe/deluge/cast(atom/cast_on)
	. = ..()
	owner.balloon_alert(owner, "Wyrmul")
	if(isliving(owner))
		var/mob/living/target = owner
		target.ExtinguishMob()
		target.adjust_fire_stacks(-20)

/datum/action/cooldown/spell/aoe/deluge/cast_on_thing_in_aoe(atom/victim, atom/caster)
	if(!can_see(caster, victim))
		return
	if(isliving(victim))
		var/mob/living/target = victim
		target.ExtinguishMob()
		target.adjust_fire_stacks(-20)
	else if(isobj(victim))
		var/obj/target = victim
		target.extinguish()

// Szarża cienia: rozpęd w wybraną stronę, przewraca tych, w których uderzy

/datum/action/cooldown/spell/pointed/shadow_crash
	name = "Szarża cienia"
	desc = "Szarżujesz w wybranym kierunku, odrzucając i na chwilę paraliżując każdego, w kogo uderzysz."
	icon_icon = 'aquila/icons/mob/darkspawn/actions_darkspawn.dmi'
	button_icon_state = "shadow_crash"
	background_icon_state = "bg_alien"
	buttontooltipstyle = "alien"
	check_flags = AB_CHECK_CONSCIOUS | AB_CHECK_HANDS_BLOCKED | AB_CHECK_LYING
	spell_requirements = NONE
	antimagic_flags = NONE
	cooldown_time = 5 SECONDS
	ranged_mousepointer = 'aquila/icons/effects/mouse_pointers/visor_reticule.dmi'
	resource_costs = list(ANTAG_RESOURCE_DARKSPAWN = 20)
	cast_range = 7
	aim_assist = FALSE
	/// Czy właśnie szarżuje
	var/charging = FALSE

/datum/action/cooldown/spell/pointed/shadow_crash/is_valid_target(atom/cast_on)
	return TRUE

/datum/action/cooldown/spell/pointed/shadow_crash/Grant(mob/grant_to)
	. = ..()
	if(owner)
		RegisterSignal(owner, COMSIG_MOVABLE_IMPACT, PROC_REF(impact), override = TRUE)

/datum/action/cooldown/spell/pointed/shadow_crash/Remove(mob/remove_from)
	if(remove_from)
		UnregisterSignal(remove_from, COMSIG_MOVABLE_IMPACT)
	return ..()

/datum/action/cooldown/spell/pointed/shadow_crash/cast(atom/cast_on)
	. = ..()
	if(!isliving(owner))
		return
	var/mob/living/thing = owner
	owner.balloon_alert(owner, "Vorl'ax")
	charging = TRUE
	thing.SetImmobilized(1 SECONDS, TRUE) // żeby nie wyjść z szarży
	thing.throw_at(cast_on, 4, 1, thing, FALSE, callback = CALLBACK(src, PROC_REF(end_dash), thing))

/datum/action/cooldown/spell/pointed/shadow_crash/proc/end_dash(mob/living/H)
	charging = FALSE
	H.SetImmobilized(0, TRUE)

/datum/action/cooldown/spell/pointed/shadow_crash/proc/impact(atom/source, atom/hit_atom, datum/thrownthing/throwingdatum)
	SIGNAL_HANDLER
	if(!charging || isturf(hit_atom))
		return
	if(!isobj(hit_atom) && !isliving(hit_atom))
		return
	// Niszczenie i tarcze mogą spać, a handler sygnału nie może
	INVOKE_ASYNC(src, PROC_REF(crash_into), source, hit_atom, throwingdatum?.init_dir)
	return COMPONENT_MOVABLE_IMPACT_NEVERMIND

/datum/action/cooldown/spell/pointed/shadow_crash/proc/crash_into(atom/source, atom/hit_atom, init_dir)
	if(QDELETED(hit_atom))
		return
	if(isobj(hit_atom))
		var/obj/thing = hit_atom
		// dwa razy po 29, żeby łamać słabe rzeczy, a nie ruszać wzmocnionych
		thing.take_damage(29)
		if(!QDELETED(thing))
			thing.take_damage(29)
		return
	var/mob/living/target = hit_atom
	var/blocked = FALSE
	if(ishuman(target))
		var/mob/living/carbon/human/H = target
		if(H.check_shields(source, 0, "[source]", LEAP_ATTACK))
			blocked = TRUE
	var/destination = get_ranged_target_turf(get_turf(target), init_dir || get_dir(source, target), 5)
	if(blocked)
		target.throw_at(destination, 3, 2)
	else
		target.throw_at(destination, 3, 2, callback = CALLBACK(target, TYPE_PROC_REF(/mob/living, Paralyze), 2 SECONDS))

// Dylatacja czasu

/datum/action/cooldown/spell/time_dilation
	name = "Dylatacja czasu"
	desc = "Na minutę znacznie przyspiesza reakcje i działania oraz daje odporność na spowolnienie. Kosztuje 75 Psi."
	icon_icon = 'aquila/icons/mob/darkspawn/actions_darkspawn.dmi'
	button_icon_state = "time_dilation"
	background_icon_state = "bg_alien"
	buttontooltipstyle = "alien"
	check_flags = AB_CHECK_CONSCIOUS
	antimagic_flags = NONE
	spell_requirements = SPELL_REQUIRES_HUMAN
	sound = 'aquila/sound/darkspawn/darkspawn_howl.ogg'
	resource_costs = list(ANTAG_RESOURCE_DARKSPAWN = 75)

/datum/action/cooldown/spell/time_dilation/can_cast_spell(feedback = TRUE)
	if(isliving(owner))
		var/mob/living/L = owner
		if(L.has_status_effect(/datum/status_effect/darkspawn_time_dilation))
			if(feedback)
				to_chat(owner, "<span class='notice'>Dylatacja czasu wciąż działa.</span>")
			return FALSE
	return ..()

/datum/action/cooldown/spell/time_dilation/cast(atom/cast_on)
	. = ..()
	var/mob/living/L = owner
	L.apply_status_effect(/datum/status_effect/darkspawn_time_dilation)
	L.balloon_alert(L, "Quix'thra ZYXAR!")
	L.visible_message("<span class='warning'>[L] wyje, a sigile na ciele zaczynają strzelać światłem na wszystkie strony!</span>", "<span class='velvet'>Twoje sigile wyją światłem, a ciało porusza się z niewiarygodną prędkością!</span>")

// Obłąkany wybuch: opóźniony krzyk, który rozrzuca wszystkich wokół

/datum/action/cooldown/spell/aoe/demented_outburst
	name = "Obłąkany wybuch"
	desc = "Po pięciu sekundach ładowania ogłusza i dezorientuje słuchaczy, odrzucając wszystkich w pobliżu. Kosztuje 50 Psi."
	icon_icon = 'aquila/icons/mob/darkspawn/actions_darkspawn.dmi'
	button_icon_state = "demented_outburst"
	background_icon_state = "bg_alien"
	buttontooltipstyle = "alien"
	antimagic_flags = NONE
	spell_requirements = NONE
	check_flags = AB_CHECK_CONSCIOUS
	resource_costs = list(ANTAG_RESOURCE_DARKSPAWN = 50)
	cooldown_time = 20 SECONDS
	aoe_radius = 7
	var/casting = FALSE
	/// Czas ładowania
	var/cast_time = 5 SECONDS

/datum/action/cooldown/spell/aoe/demented_outburst/can_cast_spell(feedback = TRUE)
	if(casting)
		return FALSE
	return ..()

/datum/action/cooldown/spell/aoe/demented_outburst/before_cast(atom/cast_on)
	. = ..()
	if(casting)
		return . | SPELL_CANCEL_CAST
	if(. & SPELL_CANCEL_CAST)
		return .
	casting = TRUE
	owner.balloon_alert(owner, "Kap...")
	owner.visible_message("<span class='boldwarning'>[owner] zaczyna warczeć, a chityna twardnieje...</span>", "<span class='velvet'>Zaczynasz skupiać moc...</span>")
	playsound(owner, 'aquila/sound/darkspawn/demented_outburst_charge.ogg', 50, FALSE)
	if(!do_after(owner, cast_time, target = owner))
		casting = FALSE
		return . | SPELL_CANCEL_CAST
	casting = FALSE

/datum/action/cooldown/spell/aoe/demented_outburst/cast(atom/cast_on)
	. = ..()
	owner.balloon_alert(owner, "...WXSU!")
	owner.visible_message("<span class='userdanger'>[owner] wydaje ogłuszający krzyk!</span>", "<span class='velvet'>Wypuszczasz ogłuszający wybuch!</span>")
	playsound(owner, 'aquila/sound/darkspawn/demented_outburst_scream.ogg', 75, FALSE)

/datum/action/cooldown/spell/aoe/demented_outburst/cast_on_thing_in_aoe(atom/movable/victim, atom/caster)
	if(!ismovable(victim) || victim.anchored)
		return
	if(!can_see(victim, caster, aoe_radius))
		return
	if(isitem(victim) && isliving(victim.loc)) // nie wyrywa rzeczy z rąk
		return
	if(isliving(victim) && is_team_darkspawn(victim))
		return
	var/distance = get_dist(owner, victim)
	var/turf/target = get_edge_target_turf(owner, get_dir(owner, get_step_away(victim, owner)))
	victim.throw_at(target, clamp(5 - clamp(distance - 2, 0, distance), 3, 5), 1, owner)
	if(iscarbon(victim))
		var/mob/living/carbon/C = victim
		if(distance <= 2)
			C.visible_message("<span class='warning'>Podmuch wyrzuca [C] w powietrze!</span>", "<span class='userdanger'>Siła wyrzuca cię w powietrze!</span>")
			C.Stun(5 SECONDS)
			C.adjustBruteLoss(10)
			C.soundbang_act(1, 5, 15, 5)
		else if(distance <= 5)
			C.visible_message("<span class='warning'>Podmuch zwala [C] z nóg!</span>", "<span class='userdanger'>Siła zwala cię z nóg!</span>")
			C.Stun(3 SECONDS)
			C.soundbang_act(1, 3, 5, 0)
	else if(iscyborg(victim))
		var/mob/living/silicon/robot/R = victim
		R.visible_message("<span class='warning'>Podmuch wyrzuca [R] w powietrze!</span>", "<span class='userdanger'>Siła wyrzuca cię w powietrze!</span>")
		R.Paralyze(10 SECONDS)
		R.soundbang_act(1, 5, 15, 5)

// Całun: ochrona przed światłem za Psi

/datum/action/cooldown/spell/toggle/creep
	name = "Całun"
	desc = "Póki działa, światło cię nie pali. Można włączać i wyłączać. Zużywa 5 Psi na sekundę."
	icon_icon = 'aquila/icons/mob/darkspawn/actions_darkspawn.dmi'
	button_icon_state = "encroach"
	background_icon_state = "bg_alien"
	buttontooltipstyle = "alien"
	antimagic_flags = NONE
	check_flags = AB_CHECK_CONSCIOUS
	spell_requirements = SPELL_REQUIRES_HUMAN
	resource_costs = list(ANTAG_RESOURCE_DARKSPAWN = 1)

/datum/action/cooldown/spell/toggle/creep/process()
	// SSfastprocess ma 5 ticków na sekundę, więc 1 Psi na tick to 5 Psi na sekundę
	if(active && owner?.mind && !SEND_SIGNAL(owner.mind, COMSIG_MIND_SPEND_ANTAG_RESOURCE, resource_costs))
		to_chat(owner, "<span class='warning'>Bez Psi ochronne cienie znikają!</span>")
		active = FALSE
		Disable()
	return ..()

/datum/action/cooldown/spell/toggle/creep/Enable()
	owner.balloon_alert(owner, "Odeahz")
	owner.visible_message("<span class='warning'>Wokół [owner] zbierają się aksamitne cienie!</span>", "<span class='velvet'>Zaczynasz używać Psi, żeby chronić się przed światłem.</span>")
	playsound(owner, 'aquila/sound/darkspawn/devour_will_victim.ogg', 50, TRUE)
	var/datum/antagonist/darkspawn/dude = isdarkspawn(owner)
	if(dude)
		ADD_TRAIT(dude, TRAIT_DARKSPAWN_CREEP, type)

/datum/action/cooldown/spell/toggle/creep/Disable()
	owner.balloon_alert(owner, "Phwo")
	to_chat(owner, "<span class='velvet'>Puszczasz cienie.</span>")
	playsound(owner, 'aquila/sound/darkspawn/devour_will_end.ogg', 50, TRUE)
	var/datum/antagonist/darkspawn/dude = isdarkspawn(owner)
	if(dude)
		REMOVE_TRAIT(dude, TRAIT_DARKSPAWN_CREEP, type)

// Niezłomność: odporność na powalenia za Psi, ale tylko chód

/datum/action/cooldown/spell/toggle/indomitable
	name = "Niezłomność"
	desc = "Daje odporność na ogłuszenia i powalenia, ale zmusza do chodzenia. Zużywa 5 Psi na sekundę."
	icon_icon = 'aquila/icons/mob/darkspawn/actions_darkspawn.dmi'
	button_icon_state = "indomitable"
	background_icon_state = "bg_alien"
	buttontooltipstyle = "alien"
	antimagic_flags = NONE
	check_flags = AB_CHECK_CONSCIOUS
	spell_requirements = NONE
	cooldown_time = 1 SECONDS
	resource_costs = list(ANTAG_RESOURCE_DARKSPAWN = 1)
	/// Czy przed włączeniem biegł
	var/was_running
	/// Cechy na czas działania
	var/list/traits = list(TRAIT_STUNIMMUNE, TRAIT_PUSHIMMUNE, TRAIT_NOSOFTCRIT, TRAIT_NOHARDCRIT, TRAIT_NODEATH, TRAIT_IGNOREDAMAGESLOWDOWN)

/datum/action/cooldown/spell/toggle/indomitable/process()
	if(active && owner?.mind && !SEND_SIGNAL(owner.mind, COMSIG_MIND_SPEND_ANTAG_RESOURCE, resource_costs))
		active = FALSE
		Disable()
	if(active && owner.m_intent != MOVE_INTENT_WALK)
		owner.toggle_move_intent()
	return ..()

/datum/action/cooldown/spell/toggle/indomitable/Enable()
	owner.balloon_alert(owner, "Zhaedo")
	owner.visible_message("<span class='warning'>Cienie przyszywają nogi [owner] do ziemi!</span>", "<span class='velvet'>Zaczynasz używać Psi, żeby nic cię nie zachwiało.</span>")
	playsound(owner, 'aquila/sound/darkspawn/devour_will_form.ogg', 50, TRUE)
	for(var/trait in traits)
		ADD_TRAIT(owner, trait, type)
	owner.move_resist = INFINITY
	was_running = (owner.m_intent == MOVE_INTENT_RUN)
	if(was_running)
		owner.toggle_move_intent()

/datum/action/cooldown/spell/toggle/indomitable/Disable()
	owner.balloon_alert(owner, "Phwo")
	to_chat(owner, "<span class='velvet'>Puszczasz cienie.</span>")
	playsound(owner, 'aquila/sound/darkspawn/devour_will_end.ogg', 50, TRUE)
	for(var/trait in traits)
		REMOVE_TRAIT(owner, trait, type)
	owner.move_resist = initial(owner.move_resist)
	if(was_running && owner.m_intent == MOVE_INTENT_WALK)
		owner.toggle_move_intent()

// Podburzenie: wszyscy wokół idą do ciebie, ale sam nie możesz atakować

/datum/action/cooldown/spell/aoe/taunt
	name = "Podburzenie"
	desc = "Zmusza wszystkich w pobliżu, żeby szli w twoją stronę, ale na chwilę nie możesz atakować."
	icon_icon = 'aquila/icons/mob/darkspawn/actions_darkspawn.dmi'
	button_icon_state = "incite"
	background_icon_state = "bg_alien"
	buttontooltipstyle = "alien"
	sound = 'aquila/sound/darkspawn/veil_mind_scream.ogg'
	antimagic_flags = NONE
	check_flags = AB_CHECK_CONSCIOUS
	spell_requirements = SPELL_REQUIRES_HUMAN
	resource_costs = list(ANTAG_RESOURCE_DARKSPAWN = 15)
	cooldown_time = 20 SECONDS
	invocation_type = INVOCATION_SHOUT
	invocation = "Kmmo'axhe!"

/datum/action/cooldown/spell/aoe/taunt/cast(atom/cast_on)
	. = ..()
	if(!isliving(owner))
		return
	var/mob/living/target = owner
	ADD_TRAIT(target, TRAIT_PACIFISM, type)
	ADD_TRAIT(target, TRAIT_PUSHIMMUNE, type)
	target.move_resist = INFINITY
	addtimer(CALLBACK(src, PROC_REF(unlock), target), 5 SECONDS, TIMER_UNIQUE | TIMER_OVERRIDE)

/datum/action/cooldown/spell/aoe/taunt/proc/unlock(mob/living/target)
	REMOVE_TRAIT(target, TRAIT_PACIFISM, type)
	REMOVE_TRAIT(target, TRAIT_PUSHIMMUNE, type)
	target.move_resist = initial(target.move_resist)

/datum/action/cooldown/spell/aoe/taunt/cast_on_thing_in_aoe(atom/victim, atom/caster)
	if(!isliving(victim) || !can_see(caster, victim))
		return
	var/mob/living/target = victim
	if(is_team_darkspawn(target))
		return
	target.apply_status_effect(/datum/status_effect/darkspawn_taunt, owner)
