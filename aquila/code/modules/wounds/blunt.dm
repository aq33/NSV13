// AQUILA - blunt wounds: dislocation, fracture, compound fracture

/datum/wound/blunt
	wound_type = WOUND_BLUNT
	/// Per second chance to drop what the hand holds, untreated and treated
	var/drop_chance = 0
	var/treated_drop_chance = 0

/datum/wound/blunt/wound_effects(delta_time)
	var/drop = treated ? treated_drop_chance : drop_chance
	if(drop && (limb.body_zone == BODY_ZONE_L_ARM || limb.body_zone == BODY_ZONE_R_ARM) && DT_PROB(drop, delta_time))
		var/obj/item/held = victim.get_item_for_held_index(limb.held_index)
		if(held && victim.dropItemToGround(held))
			to_chat(victim, "<span class='danger'>Ból w [limb.name] sprawia, że upuszczasz [held]!</span>")
	if(treated)
		return
	switch(limb.body_zone)
		if(BODY_ZONE_CHEST)
			if(DT_PROB(severity, delta_time))
				to_chat(victim, "<span class='danger'>Połamane żebra kłują cię przy każdym oddechu!</span>")
				victim.adjustStaminaLoss(5 * severity)
		if(BODY_ZONE_HEAD)
			if(DT_PROB(severity, delta_time))
				to_chat(victim, "<span class='danger'>Kręci ci się w głowie z bólu!</span>")
				victim.Dizzy(4 * severity)

/// Gauze works as a splint on fractures
/datum/wound/blunt/can_treat_with(obj/item/item)
	return !treated && severity >= WOUND_SEVERITY_SEVERE && istype(item, /obj/item/stack/medical/gauze)

/datum/wound/blunt/treat(obj/item/stack/medical/gauze/gauze, mob/user)
	var/self = user == victim
	user.visible_message("<span class='notice'>[user] zaczyna unieruchamiać [limb.name] [victim] opatrunkiem.</span>", "<span class='notice'>Zaczynasz unieruchamiać [limb.name] [self ? "" : "[victim] "]opatrunkiem.</span>")
	if(!do_mob(user, victim, self ? 6 SECONDS : 3 SECONDS))
		return FALSE
	if(QDELETED(src) || treated || !gauze.use(1))
		return FALSE
	treated = TRUE
	victim.update_wound_slowdown()
	user.visible_message("<span class='green'>[user] unieruchamia [limb.name] [victim].</span>", "<span class='green'>Unieruchamiasz [limb.name] [self ? "" : "[victim]"].</span>")
	return TRUE

/datum/wound/blunt/dislocation
	name = "Zwichnięcie"
	desc = "Coś przeskakuje ci w stawie"
	examine_desc = "wykręconą kończynę"
	treat_text = "Nastaw ją: pomoc z pustą ręką, celując w kończynę."
	severity = WOUND_SEVERITY_MODERATE
	threshold = 35
	allowed_zones = list(BODY_ZONE_L_ARM, BODY_ZONE_R_ARM, BODY_ZONE_L_LEG, BODY_ZONE_R_LEG)
	drop_chance = 1
	limp_slowdown = 0.3

/datum/wound/blunt/dislocation/can_treat_with(obj/item/item)
	return FALSE

/// Help intent with an empty hand on the limb puts it back in place
/datum/wound/blunt/dislocation/proc/try_reset(mob/living/carbon/user)
	var/self = user == victim
	user.visible_message("<span class='notice'>[user] chwyta [limb.name] [victim] i próbuje ją nastawić.</span>", "<span class='notice'>Próbujesz nastawić [limb.name] [self ? "" : "[victim]"].</span>")
	if(!do_mob(user, victim, self ? 6 SECONDS : 3 SECONDS))
		return
	if(QDELETED(src))
		return
	if(prob(self ? 50 : 80))
		victim.visible_message("<span class='danger'>[user] z trzaskiem nastawia [limb.name] [victim]!</span>", "<span class='userdanger'>[limb.name] wskakuje z trzaskiem na miejsce!</span>")
		victim.emote("scream")
		limb.receive_damage(5)
		qdel(src)
	else
		victim.visible_message("<span class='danger'>[user] szarpie [limb.name] [victim], ale nic z tego!</span>", "<span class='userdanger'>Ból przeszywa [limb.name]!</span>")
		limb.receive_damage(5)

/datum/wound/blunt/fracture
	name = "Pęknięcie kości"
	desc = "Słyszysz chrupnięcie kości"
	examine_desc = "spuchniętą, posiniaczoną kończynę"
	treat_text = "Unieruchom gazą, zrośnie się po kilku minutach, albo operacja nastawienia kości."
	severity = WOUND_SEVERITY_SEVERE
	threshold = 60
	heal_time = 3 MINUTES
	drop_chance = 3
	limp_slowdown = 0.8
	treated_limp_slowdown = 0.3

/datum/wound/blunt/compound
	name = "Złamanie otwarte"
	desc = "Kość przebija ci skórę"
	examine_desc = "kość sterczącą z rany"
	treat_text = "Operacja nastawienia kości. Gaza tylko unieruchamia."
	severity = WOUND_SEVERITY_CRITICAL
	threshold = 115
	drop_chance = 10
	treated_drop_chance = 2
	limp_slowdown = 1.5
	treated_limp_slowdown = 0.6

/datum/wound/blunt/compound/on_apply()
	victim.add_bleeding(BLEED_SURFACE)

/mob/living/carbon/help_shake_act(mob/living/carbon/M)
	var/obj/item/bodypart/limb = get_bodypart(check_zone(M.zone_selected))
	var/datum/wound/blunt/dislocation/dislocation = locate() in limb?.wounds
	if(dislocation && !M.get_active_held_item())
		INVOKE_ASYNC(dislocation, TYPE_PROC_REF(/datum/wound/blunt/dislocation, try_reset), M)
		return
	return ..()
