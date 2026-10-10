// Port BeeStation/BeeStation-Hornet#13707: sloty ekwipunku, w których nie da się teraz nic założyć, są przyciemnione.
// Reguły odpowiadają naszemu /datum/species/proc/can_equip(). Bez zamiany `nojumpsuit` na trait z oryginału.

/// Pełne nadpisanie: oryginał sprawdzał tylko listę `no_equip` gatunku.
/datum/hud/human/update_locked_slots()
	if(!mymob)
		return
	var/mob/living/carbon/human/H = mymob
	if(!istype(H) || !H.dna?.species)
		return
	var/datum/species/S = H.dna.species
	var/blocked_slots = NONE
	for(var/slot_id in S.no_equip)
		blocked_slots |= slot_id

	if(!H.w_uniform && !S.nojumpsuit)
		var/obj/item/bodypart/chest = H.get_bodypart(BODY_ZONE_CHEST)
		if(!chest || IS_ORGANIC_LIMB(chest))
			blocked_slots |= ITEM_SLOT_ID|ITEM_SLOT_BELT
		var/obj/item/bodypart/left_leg = H.get_bodypart(BODY_ZONE_L_LEG)
		if(!left_leg || IS_ORGANIC_LIMB(left_leg))
			blocked_slots |= ITEM_SLOT_LPOCKET
		var/obj/item/bodypart/right_leg = H.get_bodypart(BODY_ZONE_R_LEG)
		if(!right_leg || IS_ORGANIC_LIMB(right_leg))
			blocked_slots |= ITEM_SLOT_RPOCKET
	if(!H.wear_suit)
		blocked_slots |= ITEM_SLOT_SUITSTORE
	if(H.get_num_arms(FALSE) < 2)
		blocked_slots |= ITEM_SLOT_GLOVES
	if(H.get_num_legs(FALSE) < 2)
		blocked_slots |= ITEM_SLOT_FEET
	if(!H.get_bodypart(BODY_ZONE_HEAD))
		blocked_slots |= ITEM_SLOT_HEAD|ITEM_SLOT_EARS|ITEM_SLOT_EYES|ITEM_SLOT_MASK
	var/obj/item/organ/eyes/eyes = H.getorganslot(ORGAN_SLOT_EYES)
	if(eyes?.no_glasses)
		blocked_slots |= ITEM_SLOT_EYES

	for(var/atom/movable/screen/inventory/inv in (static_inventory + toggleable_inventory))
		if(!inv.slot_id)
			continue
		inv.alpha = (blocked_slots & inv.slot_id) ? 128 : initial(inv.alpha)

/mob/living/carbon/equip_to_slot(obj/item/I, slot)
	. = ..()
	hud_used?.update_locked_slots()

/mob/living/carbon/human/equip_to_slot(obj/item/I, slot)
	. = ..()
	hud_used?.update_locked_slots()

/mob/living/carbon/doUnEquip(obj/item/I, force, newloc, no_move, invdrop = TRUE, was_thrown = FALSE, silent = FALSE)
	. = ..()
	hud_used?.update_locked_slots()

/mob/living/carbon/human/doUnEquip(obj/item/I, force, newloc, no_move, invdrop = TRUE, was_thrown = FALSE, silent = FALSE)
	. = ..()
	hud_used?.update_locked_slots()

/datum/species/on_species_gain(mob/living/carbon/C, datum/species/old_species, pref_load)
	. = ..()
	C.hud_used?.update_locked_slots()

/obj/item/bodypart/drop_limb(special)
	var/mob/living/carbon/old_owner = owner
	. = ..()
	if(!special)
		old_owner?.hud_used?.update_locked_slots()

/obj/item/bodypart/attach_limb(mob/living/carbon/C, special, is_creating = FALSE)
	. = ..()
	if(!special)
		C?.hud_used?.update_locked_slots()

/obj/item/organ/Insert(mob/living/carbon/M, special = 0, drop_if_replaced = TRUE)
	. = ..()
	if(!special)
		M?.hud_used?.update_locked_slots()

/obj/item/organ/Remove(mob/living/carbon/M, special = FALSE)
	. = ..()
	if(!special)
		M?.hud_used?.update_locked_slots()
