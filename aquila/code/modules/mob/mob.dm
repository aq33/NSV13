/// Gets what slot the item on the mob is held in.
/// Returns null if the item isn't in any slots on our mob.
/// Does not check if the passed item is null, which may result in unexpected outcoms.
/mob/proc/get_slot_by_item(obj/item/looking_for)
	if(looking_for in held_items)
		return ITEM_SLOT_HANDS

	return null

/mob/proc/get_actions_for_statpanel()
	var/list/data = list()
	for(var/datum/action/cooldown/action in actions)
		var/list/action_data = action.set_statpanel_format()
		if(!length(action_data))
			return

		data += list(list(
			// the panel the action gets displayed to
			// in the future, this could probably be replaced with subtabs (a la admin tabs)
			action_data[PANEL_DISPLAY_PANEL],
			// the status of the action, - cooldown, charges, whatever
			action_data[PANEL_DISPLAY_STATUS],
			// the name of the action
			action_data[PANEL_DISPLAY_NAME],
			// a ref to the action button of this action for this mob
			// it's a ref to the button specifically, instead of the action itself,
			// because statpanel href calls click(), which the action button (not the action itself) handles
			REF(action.viewers[hud_used]),
		))

	return data
