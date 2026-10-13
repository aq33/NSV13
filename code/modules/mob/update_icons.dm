//Most of these are defined at this level to reduce on checks elsewhere in the code.
//Having them here also makes for a nice reference list of the various overlay-updating procs available

/mob/proc/regenerate_icons()		//TODO: phase this out completely if possible
	return

/mob/proc/update_icons()
	return

/// Updates the worn overlays of every slot in slot_flags
/mob/proc/update_clothing(slot_flags)
	return

/// Updates the item slots that can be obscured by the given flags_inv
/mob/proc/update_obscured_slots(obscured_flags)
	if(obscured_flags & HIDEGLOVES)
		update_inv_gloves()
	if(obscured_flags & HIDESUITSTORAGE)
		update_inv_s_store()
	if(obscured_flags & HIDEJUMPSUIT)
		update_inv_w_uniform()
	if(obscured_flags & HIDESHOES)
		update_inv_shoes()
	if(obscured_flags & HIDEMASK)
		update_inv_wear_mask()
	if(obscured_flags & HIDEBELT)
		update_inv_belt()
	if(obscured_flags & HIDEEARS)
		update_inv_ears()
	if(obscured_flags & HIDEEYES)
		update_inv_glasses()
	if(obscured_flags & HIDENECK)
		update_inv_neck()

/mob/proc/update_transform()
	return

/mob/proc/update_inv_handcuffed()
	return

/mob/proc/update_inv_legcuffed()
	return

/mob/proc/update_inv_back()
	return

/mob/proc/update_inv_hands()
	return

/mob/proc/update_inv_wear_mask()
	return

/mob/proc/update_inv_neck()
	return

/mob/proc/update_inv_wear_suit()
	return

/mob/proc/update_inv_w_uniform()
	return

/mob/proc/update_inv_belt()
	return

/mob/proc/update_inv_head()
	return

/mob/proc/update_body()
	return

/mob/proc/update_hair()
	return

/mob/proc/update_fire()
	return

/mob/proc/update_inv_gloves()
	return

/mob/proc/update_inv_wear_id()
	return

/mob/proc/update_inv_shoes()
	return

/mob/proc/update_inv_glasses()
	return

/mob/proc/update_inv_s_store()
	return

/mob/proc/update_inv_pockets()
	return

/mob/proc/update_inv_ears()
	return
