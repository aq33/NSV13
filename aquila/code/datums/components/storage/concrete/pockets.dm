// Holstering and drawing a gun

/datum/component/storage/concrete/pockets/holster/handle_item_insertion(obj/item/I, prevent_warning = FALSE, mob/M, datum/component/storage/remote)
	. = ..()
	if(. && M && isgun(I))
		playsound(parent, 'aquila/sound/items/gun_holster.ogg', 40, TRUE, -3)

/datum/component/storage/concrete/pockets/holster/remove_from_storage(atom/movable/AM, atom/new_location)
	. = ..()
	if(new_location && isgun(AM))
		playsound(parent, 'aquila/sound/items/gun_unholster.ogg', 40, TRUE, -3)
