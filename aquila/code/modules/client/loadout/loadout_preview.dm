// AQUILA - podgląd przedmiotów z loadoutu przed zakupem: ikonka na liście i postać w przedmiocie

/datum/preferences
	/// Id przedmiotu z loadoutu pokazywanego na podglądzie postaci
	var/preview_gear

/// Zakłada podglądany przedmiot na manekina, tylko w zakładce loadoutu
/datum/preferences/proc/apply_gear_preview(mob/living/carbon/human/dummy/mannequin)
	if(current_tab != 2 || !preview_gear)
		return
	var/datum/gear/G = GLOB.gear_datums[preview_gear]
	G?.preview_on(mannequin)

/// Czy przedmiot da się pokazać na postaci
/datum/gear/proc/can_preview()
	return !!path

/// Ikonka na listę w loadoucie
/datum/gear/proc/preview_icon(client/C)
	if(!path)
		return
	var/obj/O = path
	return icon2html(initial(O.icon), C, initial(O.icon_state))

/datum/gear/proc/preview_on(mob/living/carbon/human/H)
	if(!path)
		return
	var/obj/item/I = new path(H)
	if(slot && slot != ITEM_SLOT_BACKPACK)
		var/list/worn_before = H.get_equipped_items(TRUE)
		qdel(H.get_item_by_slot(slot))
		// Rzeczy zależne od zdjętego slotu (np. kieszenie munduru) wypadają w nicość, więc je sprzątamy
		for(var/obj/item/dropped as anything in worn_before)
			if(!QDELETED(dropped) && dropped.loc != H)
				qdel(dropped)
		if(H.equip_to_slot_if_possible(I, slot, disable_warning = TRUE, bypass_equip_delay_self = TRUE))
			return
	if(!H.put_in_hands(I))
		qdel(I)

/datum/gear/aquila_accessory/can_preview()
	return TRUE

/datum/gear/aquila_accessory/preview_icon(client/C)
	return icon2html(initial(accessory.icon), C, initial(accessory.icon_state))

/// Bielizna na postaci bez ubrania, żeby było ją widać
/datum/gear/aquila_accessory/preview_on(mob/living/carbon/human/H)
	H.delete_equipment()
	var/accessory_name = initial(accessory.name)
	if(ispath(accessory, /datum/sprite_accessory/underwear))
		H.underwear = accessory_name
	else if(ispath(accessory, /datum/sprite_accessory/undershirt))
		H.undershirt = accessory_name
	else if(ispath(accessory, /datum/sprite_accessory/socks))
		H.socks = accessory_name
	H.update_body()
