/datum/keybinding/human
	category = CATEGORY_HUMAN
	weight = WEIGHT_MOB

/datum/keybinding/human/can_use(client/user)
	return ishuman(user.mob) && !user.mob.incapacitated()


/datum/keybinding/human/quick_equip
	key = "E"
	name = "quick_equip"
	full_name = "Szybkie założenie"
	description = ""
	keybind_signal = COMSIG_KB_HUMAN_QUICKEQUIP_DOWN

/datum/keybinding/human/quick_equip/down(client/user)
	. = ..()
	if(.)
		return
	var/mob/living/carbon/human/H = user.mob
	H.quick_equip()
	return TRUE


/datum/keybinding/human/quick_equip_belt
	key = "Shift-E"
	name = "quick_equip_belt"
	full_name = "Włóż przedmiot do pasa"
	description = ""
	keybind_signal = COMSIG_KB_HUMAN_QUICKEQUIPBELT_DOWN

/datum/keybinding/human/quick_equip_belt/down(client/user)
	. = ..()
	if(.)
		return
	var/mob/living/carbon/human/H = user.mob
	var/obj/item/thing = H.get_active_held_item()
	var/obj/item/equipped_belt = H.get_item_by_slot(ITEM_SLOT_BELT)
	if(!equipped_belt) // We also let you equip a belt like this
		if(!thing)
			to_chat(user, "<span class='notice'>Nie masz pasa, z którego można coś wyjąć.</span>")
			return TRUE
		if(H.equip_to_slot_if_possible(thing, ITEM_SLOT_BELT))
			H.update_inv_hands()
		return TRUE
	if(!SEND_SIGNAL(equipped_belt, COMSIG_CONTAINS_STORAGE)) // not a storage item
		if(!thing)
			equipped_belt.attack_hand(H)
		else
			to_chat(user, "<span class='notice'>Nic się nie zmieści.</span>")
		return TRUE
	if(thing) // put thing in belt
		if(!SEND_SIGNAL(equipped_belt, COMSIG_TRY_STORAGE_INSERT, thing, user.mob))
			to_chat(user, "<span class='notice'>Nic się nie zmieści.</span>")
		return TRUE
	if(!equipped_belt.contents.len) // nothing to take out
		to_chat(user, "<span class='notice'>W twoim pasie nie ma nic do wyjęcia.</span>")
		return TRUE
	var/obj/item/stored = equipped_belt.contents[equipped_belt.contents.len]
	if(!stored || stored.on_found(H))
		return TRUE
	stored.attack_hand(H) // take out thing from belt
	return TRUE


/datum/keybinding/human/quick_equip_backpack
	key = "Shift-B"
	name = "quick_equip_backpack"
	full_name = "Włóż przedmiot do plecaka"
	description = ""
	keybind_signal = COMSIG_KB_HUMAN_BAGEQUIP_DOWN

/datum/keybinding/human/quick_equip_backpack/down(client/user)
	. = ..()
	if(.)
		return TRUE
	var/mob/living/carbon/human/H = user.mob
	var/obj/item/thing = H.get_active_held_item()
	var/obj/item/equipped_back = H.get_item_by_slot(ITEM_SLOT_BACK)
	if(!equipped_back) // We also let you equip a backpack like this
		if(!thing)
			to_chat(user, "<span class='notice'>Nie masz plecaka, z którego można coś wyjąć.</span>")
			return TRUE
		if(H.equip_to_slot_if_possible(thing, ITEM_SLOT_BACK))
			H.update_inv_hands()
		return TRUE
	if(!SEND_SIGNAL(equipped_back, COMSIG_CONTAINS_STORAGE)) // not a storage item
		if(!thing)
			equipped_back.attack_hand(H)
		else
			to_chat(user, "<span class='notice'>Nic się nie zmieści.</span>")
		return TRUE
	if(thing) // put thing in backpack
		if(!SEND_SIGNAL(equipped_back, COMSIG_TRY_STORAGE_INSERT, thing, user.mob))
			to_chat(user, "<span class='notice'>Nic się nie zmieści.</span>")
		return TRUE
	if(!equipped_back.contents.len) // nothing to take out
		to_chat(user, "<span class='notice'>W twoim plecaku nie ma nic do wyjęcia.</span>")
		return TRUE
	var/obj/item/stored = equipped_back.contents[equipped_back.contents.len]
	if(!stored || stored.on_found(H))
		return TRUE
	stored.attack_hand(H) // take out thing from backpack
	return TRUE


/datum/keybinding/human/quick_equip_suit_storage
	key = "Shift-Q"
	name = "quick_equip_suit_storage"
	full_name = "Włóż przedmiot do schowka skafandra"
	description = ""
	keybind_signal = COMSIG_KB_HUMAN_SUITEQUIP_DOWN

/datum/keybinding/human/quick_equip_suit_storage/down(client/user)
	. = ..()
	if(.)
		return
	var/mob/living/carbon/human/H = user.mob
	var/obj/item/thing = H.get_active_held_item()
	var/obj/item/stored = H.get_item_by_slot(ITEM_SLOT_SUITSTORE)
	if(!stored)
		if(!thing)
			to_chat(user, "<span class='notice'>W schowku skafandra nie ma nic do wyjęcia.")
			return TRUE
		if(H.equip_to_slot_if_possible(thing, ITEM_SLOT_SUITSTORE))
			H.update_inv_hands()
			return TRUE
	if(thing && stored)
		to_chat(user, "<span class='notice'>W schowku skafandra już coś jest!")
		return TRUE
	if(!stored || stored.on_found(H))
		return TRUE
	stored.attack_hand(H)
	return TRUE
