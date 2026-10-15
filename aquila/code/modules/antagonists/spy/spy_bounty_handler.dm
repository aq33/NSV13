// Spy bounty handler (port of tgstation code/modules/antagonists/spy/spy_bounty_handler.dm)

/**
 * ## Spy bounty handler
 *
 * Singleton datum that handles determining active bounties for spies.
 */
/datum/spy_bounty_handler
	/// Timer between when all bounties are refreshed.
	var/refresh_time = SPY_BOUNTY_REFRESH_TIME
	/// timerID of the active refresh timer.
	var/refresh_timer
	/// Number of times we have refreshed bounties
	var/num_refreshes = 0
	/// Assoc list of items stolen in the past to how many times they have been stolen
	/// Sometimes item typepaths, sometimes REFs, in general just strings that represent stolen items
	var/list/all_claimed_bounty_types = list()
	/// List of all items stolen in the last pool of bounties.
	/// Same as above - strings that represent stolen items.
	var/list/claimed_bounties_from_last_pool = list()
	/// When rolling for bounties, the number of attempts is calculated based on the number of bounties to give out.
	/// This number will override that calculation with a set value - used for testing and debugging.
	var/num_attempts_override = 0

	/// Assoc list that dictates how much of each bounty difficulty to give out at once.
	/// Modified by the number of times we have refreshed bounties.
	var/list/base_bounties_to_give = list(
		SPY_DIFFICULTY_EASY = 4,
		SPY_DIFFICULTY_MEDIUM = 2,
		SPY_DIFFICULTY_HARD = 2,
	)

	/// Assoc list of all active bounties.
	var/list/list/bounties = list(
		SPY_DIFFICULTY_EASY = list(),
		SPY_DIFFICULTY_MEDIUM = list(),
		SPY_DIFFICULTY_HARD = list(),
	)

	/// Assoc list of all possible bounties for each difficulty, weighted.
	/// This is static, no bounty types are removed from this list.
	var/list/list/bounty_types = list(
		SPY_DIFFICULTY_EASY = list(),
		SPY_DIFFICULTY_MEDIUM = list(),
		SPY_DIFFICULTY_HARD = list(),
	)

	/// Assoc list of all uplink items possible to be given as bounties for each difficulty.
	/// This is not static, as bounties are complete uplink items will be removed from this list.
	var/list/list/possible_uplink_items = list(
		SPY_DIFFICULTY_EASY = list(),
		SPY_DIFFICULTY_MEDIUM = list(),
		SPY_DIFFICULTY_HARD = list(),
	)

	/// Uplink item datums by type, made once for the handler (our uplink keeps paths in GLOB.uplink_items)
	var/list/uplink_items_by_type = list()

	/// Uplink items (and their subtypes) that never become spy rewards: bundles, telecrystals, discounts,
	/// job and species items, services and anything that needs a traitor uplink to work
	var/static/list/blacklisted_uplink_types = typecacheof(list(
		/datum/uplink_item/discounts,
		/datum/uplink_item/bundles_TC,
		/datum/uplink_item/race_restricted,
		/datum/uplink_item/role_restricted,
		/datum/uplink_item/services,
		/datum/uplink_item/infiltration,
		/datum/uplink_item/device_tools/failsafe,
		/datum/uplink_item/implants/uplink,
	))

/datum/spy_bounty_handler/New()
	for(var/datum/spy_bounty/bounty as anything in subtypesof(/datum/spy_bounty))
		var/weight = initial(bounty.weight)
		var/difficulty = initial(bounty.difficulty)
		if(weight <= 0 || !islist(bounty_types[difficulty]))
			continue
		bounty_types[difficulty][bounty] = weight

	for(var/path in GLOB.uplink_items)
		uplink_items_by_type[path] = new path()

	var/list/limited_items = list()
	var/list/show_anyways = typesof(/datum/uplink_item/spy_unique/shotgun_ammo) // acquiring a shotgun is not difficult

	for(var/path in uplink_items_by_type)
		var/datum/uplink_item/item = uplink_items_by_type[path]
		// limited items is populated as we go
		if(item in limited_items)
			continue
		// proc handles checking if the item is valid
		if(!try_add_to_loot_pool(item))
			continue
		// any child items, such as ammo, are removed from the pool until the parent item is rewarded
		for(var/child_item_type in (item.relevant_child_items || list()) - show_anyways)
			if(prob(10)) // 10% chance to have it anyways though. teehee
				continue
			var/child_item = uplink_items_by_type[child_item_type]
			for(var/difficulty in possible_uplink_items)
				possible_uplink_items[difficulty] -= child_item
			limited_items |= child_item

	refresh_bounty_list()

/// Returns the handler's uplink item datum of the passed type
/datum/spy_bounty_handler/proc/get_uplink_item(item_type)
	return uplink_items_by_type[item_type]

/// Helper to attempt to add the passed uplink item datum to the possible bounty pool(s).
/datum/spy_bounty_handler/proc/try_add_to_loot_pool(datum/uplink_item/item)
	if(isnull(item) || !ispath(item.item) || item.cost <= 0 || !(item.purchasable_from & UPLINK_SPY))
		return FALSE
	if(is_type_in_typecache(item, blacklisted_uplink_types) || length(item.restricted_roles) || length(item.restricted_species))
		return FALSE

	// This will have some overlap, and that's intentional -
	// Adds some variety, rare moments where you can get a hard reward for an easier bounty (or visa versa)
	if(item.cost <= SPY_LOWER_COST_THRESHOLD)
		possible_uplink_items[SPY_DIFFICULTY_EASY] |= item
	if(item.cost >= SPY_LOWER_COST_THRESHOLD && item.cost <= SPY_UPPER_COST_THRESHOLD + 1)
		possible_uplink_items[SPY_DIFFICULTY_MEDIUM] |= item
	if(item.cost >= SPY_UPPER_COST_THRESHOLD + 1)
		possible_uplink_items[SPY_DIFFICULTY_HARD] |= item
	return TRUE

/// Helper that returns a list of all active bounties in a single list, regardless of difficulty.
/datum/spy_bounty_handler/proc/get_all_bounties()
	var/list/all_bounties = list()
	for(var/difficulty in bounties)
		all_bounties += bounties[difficulty]

	return all_bounties

/// Refreshes all active bounties for each difficulty, no matter if they were complete or not.
/// Then recursively calls itself via a timer.
/datum/spy_bounty_handler/proc/refresh_bounty_list()
	PRIVATE_PROC(TRUE)

	var/list/bounties_to_give = base_bounties_to_give.Copy()
	// The game doesnt start giving out hard bounties until some number of refreshes have passed
	var/hard_bounties = min(floor(num_refreshes * SPY_HARD_BOUNTIES_PER_REFRESH), base_bounties_to_give[SPY_DIFFICULTY_HARD])
	// These hard bounties are given out as medium bounties instead
	var/converted_medium_bounties = max(0, base_bounties_to_give[SPY_DIFFICULTY_HARD] - hard_bounties)

	bounties_to_give[SPY_DIFFICULTY_HARD] = hard_bounties
	bounties_to_give[SPY_DIFFICULTY_MEDIUM] += converted_medium_bounties

	for(var/difficulty in bounties)
		for(var/datum/spy_bounty/bounty as anything in bounties[difficulty])
			bounty.clear_bounty(src)
		bounties[difficulty].Cut()

		var/list/pool = bounty_types[difficulty]
		var/amount_to_give = bounties_to_give[difficulty]
		var/failed_attempts = num_attempts_override || clamp(amount_to_give * 4, 10, 25) // more potential bounties = more attempts to make one
		while(amount_to_give > 0 && failed_attempts > 0)
			var/picked_bounty = pickweight(pool)
			var/datum/spy_bounty/bounty = new picked_bounty(src)
			if(bounty.initalized)
				amount_to_give -= 1
				bounties[difficulty] += bounty

			else
				failed_attempts -= 1
				qdel(bounty)

	claimed_bounties_from_last_pool.Cut()
	num_refreshes += 1
	refresh_timer = addtimer(CALLBACK(src, PROC_REF(refresh_bounty_list)), refresh_time, TIMER_UNIQUE|TIMER_OVERRIDE|TIMER_STOPPABLE)

/// Forces a refresh of the bounty list.
/// Counts towards [num_refreshes].
/datum/spy_bounty_handler/proc/force_refresh()
	if(refresh_timer)
		deltimer(refresh_timer)

	refresh_bounty_list()

/// Spawns the passed uplink item for the spy, like buying it would (without a traitor uplink). Returns the main spawned atom.
/datum/spy_bounty_handler/proc/spawn_reward(datum/uplink_item/item, mob/living/spy)
	for(var/i in 1 to item.spawn_amount)
		var/atom/spawned = item.spawn_item(item.item, spy)
		. ||= spawned
	if(islist(item.bonus_items))
		for(var/bonus in item.bonus_items)
			item.spawn_item(bonus, spy)
