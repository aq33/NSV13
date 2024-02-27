/obj/item/Initialize(mapload)
	for(var/path in actions_types)
		add_item_action(path)
	.=..()

/obj/item/Destroy(force)
// Handle cleaning up our actions list
	for(var/datum/action/action as anything in actions)
		remove_item_action(action)

	return ..()


/// Called when an action associated with our item is deleted
/obj/item/proc/on_action_deleted(datum/source)
	SIGNAL_HANDLER

	if(!(source in actions))
		CRASH("An action ([source.type]) was deleted that was associated with an item ([src]), but was not found in the item's actions list.")

	LAZYREMOVE(actions, source)

/// Adds an item action to our list of item actions.
/// Item actions are actions linked to our item, that are granted to mobs who equip us.
/// This also ensures that the actions are properly tracked in the actions list and removed if they're deleted.
/// Can be be passed a typepath of an action or an instance of an action.
/obj/item/proc/add_item_action(action_or_action_type)

	var/datum/action/action
	if(ispath(action_or_action_type, /datum/action))
		action = new action_or_action_type(src)
	else if(istype(action_or_action_type, /datum/action))
		action = action_or_action_type
	else
		CRASH("item add_item_action got a type or instance of something that wasn't an action.")

	LAZYADD(actions, action)
	RegisterSignal(action, COMSIG_PARENT_QDELETING, .proc/on_action_deleted)
	if(ismob(loc))
		// We're being held or are equipped by someone while adding an action?
		// Then they should also probably be granted the action, given it's in a correct slot
		var/mob/holder = loc
		give_item_action(action, holder, holder.get_slot_by_item(src))

	return action

/// Removes an instance of an action from our list of item actions.
/obj/item/proc/remove_item_action(datum/action/action)
	if(!action)
		return

	UnregisterSignal(action, COMSIG_PARENT_QDELETING)
	LAZYREMOVE(actions, action)
	qdel(action)


/obj/item/proc/dropped(mob/user, silent = FALSE)
// Remove any item actions we temporary gave out.
	for(var/datum/action/action_item_has as anything in actions)
		action_item_has.Remove(user)
	. = ..()

/obj/item/proc/equipped(mob/user, slot, initial = FALSE)
// Give out actions our item has to people who equip it.
	for(var/datum/action/action as anything in actions)
		give_item_action(action, user, slot)
	. = ..()

/// Gives one of our item actions to a mob, when equipped to a certain slot
/obj/item/proc/give_item_action(datum/action/action, mob/to_who, slot)
	// Some items only give their actions buttons when in a specific slot.
	if(!item_action_slot_check(slot, to_who))
		// There is a chance we still have our item action currently,
		// and are moving it from a "valid slot" to an "invalid slot".
		// So call Remove() here regardless, even if excessive.
		action.Remove(to_who)
		return

	action.Grant(to_who)
