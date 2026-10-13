// AQUILA - treating wounds with medical stacks, and the two wound surgeries

/// Medical stacks treat a wound on the targeted limb before doing their usual healing
/obj/item/stack/medical/attack(mob/living/M, mob/user)
	if(iscarbon(M) && try_treat_wound(M, user))
		return
	return ..()

/// Returns TRUE if the stack went to a wound (even if the treatment was interrupted)
/obj/item/stack/medical/proc/try_treat_wound(mob/living/carbon/patient, mob/user)
	if(patient in user.do_afters)
		return FALSE
	var/obj/item/bodypart/limb = patient.get_bodypart(check_zone(user.zone_selected))
	var/datum/wound/wound = patient.get_treatable_wound(limb, src)
	if(!wound)
		return FALSE
	INVOKE_ASYNC(wound, TYPE_PROC_REF(/datum/wound, treat), src, user)
	return TRUE

/obj/item/stack/medical/suture/attack(mob/living/M, mob/user)
	if(iscarbon(M) && try_treat_wound(M, user))
		return
	return ..()

/obj/item/stack/medical/mesh/attack(mob/living/M, mob/user)
	if(iscarbon(M) && try_treat_wound(M, user))
		return
	return ..()

// --- Bone setting ---

/datum/surgery/aq_repair_bone
	name = "nastawienie kości"
	steps = list(/datum/surgery_step/incise,
				/datum/surgery_step/retract_skin,
				/datum/surgery_step/aq_set_bone,
				/datum/surgery_step/close)
	target_mobtypes = list(/mob/living/carbon/human, /mob/living/carbon/monkey)
	possible_locs = list(BODY_ZONE_R_ARM, BODY_ZONE_L_ARM, BODY_ZONE_R_LEG, BODY_ZONE_L_LEG, BODY_ZONE_CHEST, BODY_ZONE_HEAD)
	requires_real_bodypart = TRUE

/datum/surgery/aq_repair_bone/can_start(mob/user, mob/living/carbon/target, target_zone)
	var/obj/item/bodypart/limb = target.get_bodypart(check_zone(target_zone))
	var/datum/wound/blunt/fracture = limb?.get_wound(WOUND_BLUNT)
	return fracture?.severity >= WOUND_SEVERITY_SEVERE

/datum/surgery_step/aq_set_bone
	name = "nastaw kość"
	implements = list(TOOL_RETRACTOR = 100, TOOL_HEMOSTAT = 80, TOOL_CROWBAR = 50, TOOL_WRENCH = 35)
	time = 40
	preop_sound = 'sound/surgery/retractor1.ogg'
	success_sound = 'sound/surgery/retractor2.ogg'

/datum/surgery_step/aq_set_bone/preop(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	display_results(user, target, "<span class='notice'>Zaczynasz nastawiać kość ([strefa_pl(target_zone)]) [target]...</span>",
		"[user] zaczyna nastawiać kość ([strefa_pl(target_zone)]) [target].",
		"[user] zaczyna nastawiać kość ([strefa_pl(target_zone)]) [target].")

/datum/surgery_step/aq_set_bone/success(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	var/obj/item/bodypart/limb = target.get_bodypart(check_zone(target_zone))
	var/datum/wound/fracture = limb?.get_wound(WOUND_BLUNT)
	if(fracture)
		qdel(fracture)
	display_results(user, target, "<span class='notice'>Nastawiasz kość ([strefa_pl(target_zone)]) [target].</span>",
		"[user] nastawia kość ([strefa_pl(target_zone)]) [target].",
		"[user] kończy operację ([strefa_pl(target_zone)]) [target].")
	return TRUE

// --- Debridement ---

/datum/surgery/aq_debride
	name = "usunięcie martwej tkanki"
	steps = list(/datum/surgery_step/incise,
				/datum/surgery_step/aq_debride,
				/datum/surgery_step/close)
	target_mobtypes = list(/mob/living/carbon/human, /mob/living/carbon/monkey)
	possible_locs = list(BODY_ZONE_R_ARM, BODY_ZONE_L_ARM, BODY_ZONE_R_LEG, BODY_ZONE_L_LEG, BODY_ZONE_CHEST, BODY_ZONE_HEAD)
	requires_real_bodypart = TRUE

/datum/surgery/aq_debride/can_start(mob/user, mob/living/carbon/target, target_zone)
	var/obj/item/bodypart/limb = target.get_bodypart(check_zone(target_zone))
	return !!limb?.get_wound(WOUND_BURN)

/datum/surgery_step/aq_debride
	name = "wytnij martwą tkankę"
	implements = list(TOOL_SCALPEL = 100, TOOL_HEMOSTAT = 60, TOOL_SAW = 40)
	time = 40
	preop_sound = 'sound/surgery/scalpel1.ogg'
	success_sound = 'sound/surgery/scalpel2.ogg'

/datum/surgery_step/aq_debride/preop(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	display_results(user, target, "<span class='notice'>Zaczynasz wycinać martwą tkankę ([strefa_pl(target_zone)]) [target]...</span>",
		"[user] zaczyna wycinać martwą tkankę ([strefa_pl(target_zone)]) [target].",
		"[user] zaczyna wycinać martwą tkankę ([strefa_pl(target_zone)]) [target].")

/datum/surgery_step/aq_debride/success(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	var/obj/item/bodypart/limb = target.get_bodypart(check_zone(target_zone))
	var/datum/wound/burn = limb?.get_wound(WOUND_BURN)
	if(burn)
		qdel(burn)
	target.apply_damage(5, BRUTE, limb)
	display_results(user, target, "<span class='notice'>Wycinasz martwą tkankę ([strefa_pl(target_zone)]) [target].</span>",
		"[user] wycina martwą tkankę ([strefa_pl(target_zone)]) [target].",
		"[user] kończy operację ([strefa_pl(target_zone)]) [target].")
	return TRUE
