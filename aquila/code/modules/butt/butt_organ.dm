// Butt organ, ported from HippieStation13 (code/modules/surgery/organs/organ_internal.dm).
// The butt holds a hidden pocket. While the butt is inside someone the pocket lives in the owner's
// contents, so the normal storage reach checks (CanReach) work without special cases.

/obj/item/organ/butt
	name = "butt"
	desc = "Extremely treasured body part."
	icon = 'aquila/icons/obj/butt.dmi'
	icon_state = "butt"
	item_state = "butt"
	worn_icon = 'aquila/icons/mob/butt_head.dmi'
	worn_icon_state = "butt"
	zone = BODY_ZONE_PRECISE_GROIN
	slot = ORGAN_SLOT_BUTT
	throwforce = 5
	throw_speed = 4
	force = 5
	hitsound = 'aquila/sound/misc/fart.ogg'
	body_parts_covered = HEAD
	slot_flags = ITEM_SLOT_HEAD
	embedding = list("embed_chance" = 5) //This is a joke
	/// Set after a superfart or a staple job; a loose butt can't superfart
	var/loose = FALSE
	var/max_combined_w_class = 3
	var/max_w_class = WEIGHT_CLASS_SMALL
	var/storage_slots = 2
	var/fart_sound = 'aquila/sound/misc/fart.ogg'
	var/blood_type = /obj/effect/decal/cleanable/blood
	var/obj/item/storage/butt_pocket/inv

/obj/item/organ/butt/xeno //XENOMORPH BUTTS ARE BEST BUTTS yes i agree
	name = "alien butt"
	desc = "Best trophy ever."
	icon_state = "xenobutt"
	item_state = "xenobutt"
	storage_slots = 3
	max_combined_w_class = 5
	fart_sound = 'aquila/sound/misc/alienfart.ogg'
	blood_type = /obj/effect/decal/cleanable/xenoblood

/obj/item/organ/butt/bluebutt // bluespace butts, science
	name = "butt of holding"
	desc = "This butt has bluespace properties, letting you store more items in it. Four tiny items, or two small ones, or one normal one can fit."
	icon_state = "bluebutt"
	item_state = "bluebutt"
	status = ORGAN_ROBOTIC
	organ_flags = ORGAN_SYNTHETIC
	max_combined_w_class = 12
	max_w_class = WEIGHT_CLASS_NORMAL
	storage_slots = 4

/obj/item/organ/butt/Initialize(mapload)
	. = ..()
	inv = new(src)
	inv.butt = src
	var/datum/component/storage/STR = inv.GetComponent(/datum/component/storage)
	STR.max_items = storage_slots
	STR.max_w_class = max_w_class
	STR.max_combined_w_class = max_combined_w_class

/obj/item/organ/butt/Destroy()
	if(inv)
		var/turf/T = get_turf(owner || src)
		for(var/obj/item/I in inv.contents)
			if(T)
				I.forceMove(T)
			else
				qdel(I)
		QDEL_NULL(inv)
	return ..()

/obj/item/organ/butt/Insert(mob/living/carbon/M, special = 0, drop_if_replaced = TRUE)
	// Already in this mob: parent Insert is a no-op here (create_internal_organs() re-inserts
	// organs that set_species() already placed), so don't re-register our signals.
	if(owner == M)
		return
	. = ..()
	if(owner != M)
		return
	if(inv)
		SEND_SIGNAL(inv, COMSIG_TRY_STORAGE_HIDE_ALL)
		inv.forceMove(M)
	RegisterSignal(M, COMSIG_MOVABLE_MOVED, PROC_REF(owner_moved))

/obj/item/organ/butt/Remove(mob/living/carbon/M, special = FALSE)
	if(M)
		UnregisterSignal(M, COMSIG_MOVABLE_MOVED)
	if(inv)
		SEND_SIGNAL(inv, COMSIG_TRY_STORAGE_HIDE_ALL)
		inv.forceMove(src)
	return ..()

/// Close the pocket for anyone who can no longer reach it
/obj/item/organ/butt/proc/owner_moved()
	SIGNAL_HANDLER
	var/datum/component/storage/STR = inv?.GetComponent(/datum/component/storage)
	if(!STR)
		return
	for(var/mob/living/L in STR.can_see_contents())
		if(!L.CanReach(inv))
			STR.hide_from(L)

/obj/item/organ/butt/on_life()
	. = ..()
	if(!owner || !inv)
		return
	for(var/obj/item/I in inv.contents)
		if(I.is_sharp())
			owner.bleed(4)
		// Pills and food slowly get absorbed
		if(istype(I, /obj/item/reagent_containers/pill) || istype(I, /obj/item/reagent_containers/food))
			if(I.reagents?.total_volume)
				I.reagents.trans_to(owner, 1, transfered_by = owner, method = INGEST)
			else
				qdel(I)

/obj/item/organ/butt/attackby(obj/item/W, mob/user, params)
	if(istype(W, /obj/item/bodypart/l_arm/robot) || istype(W, /obj/item/bodypart/r_arm/robot))
		if(!user.temporarilyRemoveItemFromInventory(W))
			return
		qdel(W)
		var/mob/living/simple_animal/bot/buttbot/B = new(get_turf(src))
		if(istype(src, /obj/item/organ/butt/xeno))
			B.make_xeno()
		to_chat(user, "<span class='notice'>You add the robot arm to the butt and... What?</span>")
		qdel(src)
		return
	return ..()

/obj/item/organ/butt/throw_impact(atom/hit_atom, datum/thrownthing/throwingdatum)
	. = ..()
	playsound(src, fart_sound, 50, TRUE, 5)
	if(ishuman(hit_atom))
		var/mob/living/carbon/human/M = hit_atom
		M.apply_damage(5, STAMINA)
		if(prob(5))
			M.Paralyze(6 SECONDS)
			visible_message("<span class='danger'>[src] smacks [M] right in the face!</span>")

/// Tear the butt off its owner, dumping the pocket contents on the floor
/obj/item/organ/butt/proc/blow_off(mob/living/carbon/user)
	var/turf/T = get_turf(user)
	if(inv)
		for(var/obj/item/I in inv.contents)
			I.forceMove(T)
	Remove(user)
	forceMove(T)
	new blood_type(T)

// The hidden pocket

/obj/item/storage/butt_pocket
	name = "butt"
	desc = "You probably shouldn't be seeing this."
	icon = 'aquila/icons/obj/butt.dmi'
	icon_state = "butt"
	item_flags = ABSTRACT
	w_class = WEIGHT_CLASS_BULKY
	component_type = /datum/component/storage/concrete/pockets/butt
	var/obj/item/organ/butt/butt

/obj/item/storage/butt_pocket/Destroy()
	butt = null
	return ..()

/datum/component/storage/concrete/pockets/butt
	silent = FALSE
	rustle_sound = FALSE
	attack_hand_interact = FALSE
	quickdraw = FALSE

/datum/component/storage/concrete/pockets/butt/can_be_inserted(obj/item/I, stop_messages = FALSE, mob/M)
	var/obj/item/storage/butt_pocket/pocket = parent
	var/mob/living/carbon/human/H = pocket.butt?.owner
	if(istype(H) && H.w_uniform)
		if(M && !stop_messages)
			to_chat(M, "<span class='danger'>Remove the jumpsuit first!</span>")
		return FALSE
	return ..()

// Who gets a butt

/datum/species
	/// Butt organ type this species spawns with, null for none
	var/obj/item/organ/butt/mutantbutt = /obj/item/organ/butt

/datum/species/regenerate_organs(mob/living/carbon/C, datum/species/old_species, replace_current = TRUE)
	. = ..()
	var/obj/item/organ/butt/butt = C.getorganslot(ORGAN_SLOT_BUTT)
	if(butt && !mutantbutt)
		butt.Remove(C, TRUE)
		qdel(butt)
	else if(!butt && mutantbutt)
		butt = new mutantbutt()
		butt.Insert(C)

/mob/living/carbon/monkey/create_internal_organs()
	internal_organs += new /obj/item/organ/butt
	return ..()

/mob/living/carbon/alien/humanoid/create_internal_organs()
	internal_organs += new /obj/item/organ/butt/xeno
	return ..()

/mob/living/carbon/regenerate_organs()
	. = ..()
	if(dna?.species || getorganslot(ORGAN_SLOT_BUTT))
		return
	var/obj/item/organ/butt/B
	if(isalienadult(src))
		B = new /obj/item/organ/butt/xeno()
	else if(ismonkey(src))
		B = new /obj/item/organ/butt()
	B?.Insert(src)

// Using the pocket: grab intent on the groin

/mob/living/carbon/human/grabbedby(mob/living/carbon/user, supress_message = FALSE)
	if(user.zone_selected != BODY_ZONE_PRECISE_GROIN)
		return ..()
	var/obj/item/organ/butt/B = getorganslot(ORGAN_SLOT_BUTT)
	if(w_uniform)
		if(user == src)
			user.visible_message("<span class='warning'>[user] grabs [user.p_their()] own butt!</span>", "<span class='warning'>You grab your own butt!</span>")
			to_chat(user, "<span class='warning'>You'll need to remove your jumpsuit first!</span>")
		else
			user.visible_message("<span class='warning'>[user] grabs [src]'s butt!</span>", "<span class='warning'>You grab [src]'s butt!</span>")
			to_chat(user, "<span class='warning'>You'll need to remove [src]'s jumpsuit first!</span>")
			to_chat(src, "<span class='warning'>You feel your butt being grabbed!</span>")
		return FALSE
	if(!B?.inv)
		to_chat(user, "<span class='warning'>There's nothing to inspect!</span>")
		return FALSE
	user.visible_message("<span class='warning'>[user] starts inspecting [user == src ? "[user.p_their()] own" : "[src]'s"] ass!</span>", "<span class='warning'>You start inspecting [user == src ? "your" : "[src]'s"] ass!</span>")
	if(!do_mob(user, src, 4 SECONDS))
		user.visible_message("<span class='warning'>[user] fails to inspect [user == src ? "[user.p_their()] own" : "[src]'s"] ass!</span>", "<span class='warning'>You fail to inspect [user == src ? "your" : "[src]'s"] ass!</span>")
		return FALSE
	user.visible_message("<span class='warning'>[user] inspects [user == src ? "[user.p_their()] own" : "[src]'s"] ass!</span>", "<span class='warning'>You inspect [user == src ? "your" : "[src]'s"] ass!</span>")
	SEND_SIGNAL(B.inv, COMSIG_TRY_STORAGE_SHOW, user)
	return FALSE

/datum/species/spec_attacked_by(obj/item/I, mob/living/user, obj/item/bodypart/affecting, intent, mob/living/carbon/human/H)
	if(user.zone_selected != BODY_ZONE_PRECISE_GROIN || user.a_intent != INTENT_GRAB)
		return ..()
	if(H.w_uniform)
		H.visible_message("<span class='danger'>[user] pokes [H == user ? "[user.p_their()] own" : "[H]'s"] butt with [I].</span>", "<span class='danger'>[user] pokes your butt with [I].</span>")
		return FALSE
	var/obj/item/organ/butt/B = H.getorganslot(ORGAN_SLOT_BUTT)
	if(!B?.inv)
		return ..()
	user.visible_message("<span class='warning'>[user] starts hiding [I] inside [H == user ? "[user.p_their()] own" : "[H]'s"] butt.</span>", "<span class='warning'>You start hiding [I] inside [H == user ? "your" : "[H]'s"] butt.</span>")
	if(do_mob(user, H, 4 SECONDS) && SEND_SIGNAL(B.inv, COMSIG_TRY_STORAGE_INSERT, I, user, TRUE))
		user.visible_message("<span class='warning'>[user] hides [I] inside [H == user ? "[user.p_their()] own" : "[H]'s"] butt.</span>", "<span class='warning'>You hide [I] inside [H == user ? "your" : "[H]'s"] butt.</span>")
	return FALSE

/obj/item/clothing/equipped(mob/user, slot)
	. = ..()
	if(!(slot_flags & slot) || !iscarbon(user))
		return
	var/mob/living/carbon/C = user
	var/obj/item/organ/butt/B = C.getorganslot(ORGAN_SLOT_BUTT)
	if(B?.inv)
		SEND_SIGNAL(B.inv, COMSIG_TRY_STORAGE_HIDE_ALL)
