// AQUILA - light version of tgstation wounds.
// A wound sits on one limb. It is rolled from the damage the limb really took from a weapon or a projectile,
// does something unpleasant while it lasts and is fixed with the right item or surgery.
// Kinds: blunt (dislocation, fracture, compound fracture), slash (deep cut, torn artery, on top of Bee bleeding),
// burn (second and third degree burns with infection). No scars, no per-weapon wound bonus, no wound armor.

/obj/item/bodypart/var/list/datum/wound/wounds

/obj/item/bodypart/proc/get_wound(wound_type)
	for(var/datum/wound/wound as anything in wounds)
		if(wound.wound_type == wound_type)
			return wound

/// Wound types of a kind, from the mildest
/proc/aq_wound_types(wound_type)
	switch(wound_type)
		if(WOUND_BLUNT)
			return list(/datum/wound/blunt/dislocation, /datum/wound/blunt/fracture, /datum/wound/blunt/compound)
		if(WOUND_SLASH)
			return list(/datum/wound/slash/deep, /datum/wound/slash/artery)
		if(WOUND_BURN)
			return list(/datum/wound/burn/second_degree, /datum/wound/burn/third_degree)

/datum/wound
	var/name = "rana"
	/// What the victim and the scanner read
	var/desc = ""
	/// "ma [examine_desc]" on examine
	var/examine_desc = "ranę"
	/// How to fix it, shown on the scanner
	var/treat_text = ""
	var/wound_type
	var/severity = WOUND_SEVERITY_MODERATE
	/// Roll needed for this wound, multiplied by WOUND_THRESHOLD_MULTIPLIER
	var/threshold = 35
	/// Limbs it can appear on, null for all
	var/list/allowed_zones
	var/obj/item/bodypart/limb
	var/mob/living/carbon/victim
	/// Splinted, sutured or disinfected: the wound is under control
	var/treated = FALSE
	/// How long a treated wound takes to heal by itself, 0 means it needs surgery
	var/heal_time = 0
	var/heal_progress = 0
	/// Movement slowdown when on a leg, untreated and treated
	var/limp_slowdown = 0
	var/treated_limp_slowdown = 0

/datum/wound/Destroy()
	if(limb)
		LAZYREMOVE(limb.wounds, src)
	if(victim)
		UnregisterSignal(victim, COMSIG_PARENT_EXAMINE)
		var/mob/living/carbon/old_victim = victim
		victim = null
		old_victim.update_wound_slowdown()
	limb = null
	STOP_PROCESSING(SSprocessing, src)
	return ..()

/datum/wound/proc/apply_wound(obj/item/bodypart/new_limb, silent = FALSE)
	limb = new_limb
	victim = new_limb.owner
	LAZYADD(limb.wounds, src)
	RegisterSignal(victim, COMSIG_PARENT_EXAMINE, PROC_REF(on_examine))
	START_PROCESSING(SSprocessing, src)
	victim.update_wound_slowdown()
	if(!silent)
		to_chat(victim, "<span class='userdanger'>[desc] ([limb.name])!</span>")
		victim.visible_message("<span class='danger'>[victim] ma [examine_desc] ([limb.name])!</span>", ignored_mobs = victim)
	on_apply()

/// Effects that happen once, when the wound appears
/datum/wound/proc/on_apply()
	return

/datum/wound/process(delta_time)
	if(QDELETED(limb) || QDELETED(victim) || limb.owner != victim)
		qdel(src)
		return
	if(victim.stat == DEAD)
		return
	if(treated && heal_time)
		heal_progress += delta_time SECONDS
		if(heal_progress >= heal_time)
			to_chat(victim, "<span class='green'>[name] ([limb.name]) się zagoiła.</span>")
			qdel(src)
			return
	wound_effects(delta_time)

/// Effects every process, while the victim is alive
/datum/wound/proc/wound_effects(delta_time)
	return

/// Replaces this wound with a milder or a worse one of the same kind
/datum/wound/proc/replace_with(new_type)
	var/obj/item/bodypart/old_limb = limb
	qdel(src)
	if(new_type)
		var/datum/wound/replacement = new new_type()
		replacement.apply_wound(old_limb, silent = TRUE)
		return replacement

/datum/wound/proc/on_examine(mob/living/source, mob/user, list/examine_list)
	SIGNAL_HANDLER
	examine_list += "<span class='warning'>Ma [examine_desc] ([limb.name])[treated ? ", opatrzoną" : ""]!</span>"

/// Can this item treat the wound? Called before the item does its usual healing.
/datum/wound/proc/can_treat_with(obj/item/item)
	return FALSE

/// Does the treatment. Returns TRUE if something was used up.
/datum/wound/proc/treat(obj/item/item, mob/user)
	return FALSE

/// Line for the health analyzer
/datum/wound/proc/get_scan_text()
	var/status = treated ? (heal_time ? " (opatrzone, goi się)" : " (opatrzone, wymaga operacji)") : ""
	return "[capitalize(limb.name)]: <b>[name]</b>[status]. [treat_text]"

/// One piece of the treating stack per wound: is there one this item can help?
/mob/living/carbon/proc/get_treatable_wound(obj/item/bodypart/limb, obj/item/item)
	for(var/datum/wound/wound as anything in limb?.wounds)
		if(wound.can_treat_with(item))
			return wound

// --- Rolling ---

/mob/living/carbon/proc/aq_limb_damage_snapshot()
	var/list/snapshot = list()
	for(var/obj/item/bodypart/limb as anything in bodyparts)
		snapshot[limb] = list(limb.brute_dam, limb.burn_dam)
	return snapshot

/// Rolls wounds on every limb that took damage since the snapshot
/mob/living/carbon/proc/aq_wound_from_snapshot(list/snapshot, damage_type, sharp)
	var/wound_type
	switch(damage_type)
		if(BRUTE)
			wound_type = sharp ? WOUND_SLASH : WOUND_BLUNT
		if(BURN)
			wound_type = WOUND_BURN
	if(!wound_type)
		return
	for(var/obj/item/bodypart/limb as anything in bodyparts)
		var/list/before = snapshot[limb]
		if(!before)
			continue
		var/damage_taken = damage_type == BURN ? limb.burn_dam - before[2] : limb.brute_dam - before[1]
		if(damage_taken > 0)
			check_wounding(limb, damage_taken, wound_type)

/mob/living/carbon/proc/check_wounding(obj/item/bodypart/limb, damage, wound_type)
	if(damage < WOUND_MINIMUM_DAMAGE || QDELETED(limb) || limb.owner != src || !IS_ORGANIC_LIMB(limb))
		return
	if(status_flags & GODMODE)
		return
	if(wound_type == WOUND_SLASH && HAS_TRAIT(src, TRAIT_NO_BLOOD))
		return
	var/roll = rand(max(damage / 1.5, 25), max(25, round(damage ** 1.4)))
	roll += WOUND_DAMAGED_LIMB_BONUS * limb.get_damage() / limb.max_damage
	var/datum/wound/existing = limb.get_wound(wound_type)
	if(existing)
		roll += existing.severity * 10
	var/chosen
	for(var/datum/wound/path as anything in aq_wound_types(wound_type))
		var/list/zones = initial(path.allowed_zones)
		if(zones && !(limb.body_zone in zones))
			continue
		if(roll >= initial(path.threshold) * WOUND_THRESHOLD_MULTIPLIER)
			chosen = path
	if(!chosen)
		return
	var/datum/wound/chosen_wound = chosen
	if(existing)
		if(initial(chosen_wound.severity) <= existing.severity)
			return
		qdel(existing)
	var/datum/wound/new_wound = new chosen()
	new_wound.apply_wound(limb)
	return new_wound

// --- Hooks ---

/mob/living/carbon/human/attacked_by(obj/item/I, mob/living/user)
	var/list/snapshot = aq_limb_damage_snapshot()
	. = ..()
	if(I)
		aq_wound_from_snapshot(snapshot, I.damtype, I.is_sharp())

/mob/living/carbon/human/bullet_act(obj/item/projectile/P, def_zone, piercing_hit = FALSE)
	var/list/snapshot = aq_limb_damage_snapshot()
	. = ..()
	if(P && !P.nodamage)
		aq_wound_from_snapshot(snapshot, P.damage_type, TRUE)

/mob/living/carbon/fully_heal(admin_revive = FALSE)
	for(var/obj/item/bodypart/limb as anything in bodyparts)
		for(var/datum/wound/wound as anything in limb.wounds?.Copy())
			qdel(wound)
	return ..()

/mob/living/carbon/proc/update_wound_slowdown()
	var/slowdown = 0
	for(var/obj/item/bodypart/limb as anything in bodyparts)
		if(limb.body_zone != BODY_ZONE_L_LEG && limb.body_zone != BODY_ZONE_R_LEG)
			continue
		for(var/datum/wound/wound as anything in limb.wounds)
			slowdown += wound.treated ? wound.treated_limp_slowdown : wound.limp_slowdown
	if(slowdown)
		add_movespeed_modifier("aq_wounds", override = TRUE, multiplicative_slowdown = slowdown)
	else
		remove_movespeed_modifier("aq_wounds")

/// Wound lines for the health analyzer
/mob/living/carbon/proc/get_wound_scan_lines()
	var/list/lines = list()
	for(var/obj/item/bodypart/limb as anything in bodyparts)
		for(var/datum/wound/wound as anything in limb.wounds)
			lines += "<span class='alert'>[wound.get_scan_text()]</span>"
	return lines

/mob/living/carbon/human/check_self_for_injuries()
	. = ..()
	if(stat == DEAD || stat == UNCONSCIOUS)
		return
	for(var/obj/item/bodypart/limb as anything in bodyparts)
		for(var/datum/wound/wound as anything in limb.wounds)
			to_chat(src, "<span class='danger'>[capitalize(limb.name)]: [wound.name][wound.treated ? " (opatrzone)" : ""].</span>")
