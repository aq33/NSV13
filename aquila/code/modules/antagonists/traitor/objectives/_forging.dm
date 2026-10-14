// AQUILA - traitor objective pool.
// Every generic slot first rolls a category (kill / steal / sabotage), then a weighted objective inside it.
// An objective that can't be set up this round (no target, missing machine...) is skipped and the next one in the category is tried.

/// Every category has the same chance. The kill category is zero below MIN_POP_KILL_OBJECTIVES.
#define TRAITOR_CATEGORY_WEIGHT 1
/// Every objective inside a category has the same weight
#define TRAITOR_OBJECTIVE_WEIGHT 10
/// The flavor objective that took the maroon's place keeps the maroon's old share (30% of kill objectives) instead (Skyrat-SS13/Skyrat13#1115)
#define TRAITOR_FLAVOR_WEIGHT 20

/// Marker in the kill pool: the slot goes to a flavor objective instead of a maroon (Skyrat-SS13/Skyrat13#1115).
#define TRAITOR_FLAVOR_INSTEAD_OF_MAROON "flavor"
/// Marker in the steal pool: document exchange with another traitor
#define TRAITOR_DOCUMENT_EXCHANGE "exchange"

/datum/antagonist/traitor/proc/forge_aquila_human_objective()
	var/kill_allowed = length(GLOB.joined_player_list) >= CONFIG_GET(number/min_pop_kill_objectives)
	var/list/categories = list(
		"kill" = kill_allowed ? TRAITOR_CATEGORY_WEIGHT : 0,
		"steal" = TRAITOR_CATEGORY_WEIGHT,
		"sabotage" = TRAITOR_CATEGORY_WEIGHT,
	)
	while(length(categories))
		var/category = pick_nonzero_weight(categories)
		if(!category)
			break
		categories -= category
		var/added
		switch(category)
			if("kill")
				added = forge_kill_objective()
			if("steal")
				added = add_rolled_objective(list(
					/datum/objective/steal = TRAITOR_OBJECTIVE_WEIGHT,
					/datum/objective/steal/hdd = TRAITOR_OBJECTIVE_WEIGHT, // replaces the old research download
					/datum/objective/steal/heirloom = TRAITOR_OBJECTIVE_WEIGHT,
					/datum/objective/tcomms_data = TRAITOR_OBJECTIVE_WEIGHT,
					/datum/objective/forged_manifest = TRAITOR_OBJECTIVE_WEIGHT,
					/datum/objective/steal_five_of_type/organs = TRAITOR_OBJECTIVE_WEIGHT,
					/datum/objective/steal_five_of_type/summon_guns/thief = TRAITOR_OBJECTIVE_WEIGHT,
					/datum/objective/hoarder = TRAITOR_OBJECTIVE_WEIGHT,
					/datum/objective/hoarder/bodies = kill_allowed ? TRAITOR_OBJECTIVE_WEIGHT : 0,
					TRAITOR_DOCUMENT_EXCHANGE = TRAITOR_OBJECTIVE_WEIGHT,
				))
			if("sabotage")
				added = add_rolled_objective(list(
					/datum/objective/break_machinery = TRAITOR_OBJECTIVE_WEIGHT,
					/datum/objective/plant_device/bomb = kill_allowed ? TRAITOR_OBJECTIVE_WEIGHT : 0,
					/datum/objective/plant_device/bug = TRAITOR_OBJECTIVE_WEIGHT,
					/datum/objective/plant_device/tide = TRAITOR_OBJECTIVE_WEIGHT,
					/datum/objective/poison_items = TRAITOR_OBJECTIVE_WEIGHT,
					/datum/objective/sabotage/power_sink = TRAITOR_OBJECTIVE_WEIGHT,
					/datum/objective/sabotage/integrity = TRAITOR_OBJECTIVE_WEIGHT,
					/datum/objective/air_sabotage = TRAITOR_OBJECTIVE_WEIGHT,
					/datum/objective/sabotage/ai_law = TRAITOR_OBJECTIVE_WEIGHT,
					/datum/objective/hack_comms = TRAITOR_OBJECTIVE_WEIGHT,
					/datum/objective/breakout = TRAITOR_OBJECTIVE_WEIGHT,
					/datum/objective/sabotage/supermatter = TRAITOR_OBJECTIVE_WEIGHT,
					/datum/objective/iff_subvert = TRAITOR_OBJECTIVE_WEIGHT,
				))
		if(added)
			return 1
	// Nothing in any category could be set up, the classic steal always works
	var/datum/objective/steal/steal_objective = new
	steal_objective.owner = owner
	steal_objective.find_target()
	add_objective(steal_objective)
	return 1

/datum/antagonist/traitor/proc/forge_kill_objective()
	var/list/active_ais = active_ais()
	if(length(active_ais) && prob(100 / max(1, length(GLOB.joined_player_list))))
		if(add_rolled_objective(list(/datum/objective/destroy = 1)))
			return TRUE
	return add_rolled_objective(list(
		/datum/objective/assassinate = TRAITOR_OBJECTIVE_WEIGHT,
		/datum/objective/assassinate/once = TRAITOR_OBJECTIVE_WEIGHT,
		/datum/objective/assassinate/behead = TRAITOR_OBJECTIVE_WEIGHT,
		/datum/objective/assassinate/calling_card = TRAITOR_OBJECTIVE_WEIGHT,
		/datum/objective/assassinate/photo = TRAITOR_OBJECTIVE_WEIGHT,
		/datum/objective/assassinate/traitor = TRAITOR_OBJECTIVE_WEIGHT,
		TRAITOR_FLAVOR_INSTEAD_OF_MAROON = TRAITOR_FLAVOR_WEIGHT,
	))

/// Tries the weighted objective types one by one until one can be set up for this traitor. Returns the added objective.
/datum/antagonist/traitor/proc/add_rolled_objective(list/weighted_types)
	weighted_types = weighted_types.Copy()
	while(length(weighted_types))
		var/path = pick_nonzero_weight(weighted_types)
		if(!path)
			return null
		weighted_types -= path
		if(path == TRAITOR_DOCUMENT_EXCHANGE)
			if(try_document_exchange())
				return TRUE
			continue
		if(path == TRAITOR_FLAVOR_INSTEAD_OF_MAROON)
			var/datum/objective/gimmick/flavor = new
			flavor.owner = owner
			flavor.find_target()
			flavor.update_explanation_text()
			add_objective(flavor)
			return flavor
		var/datum/objective/rolled = new path
		rolled.owner = owner
		if(!rolled.traitor_roll_setup(src))
			qdel(rolled)
			continue
		add_objective(rolled)
		return rolled
	return null

/// Pairs this traitor with another one for the secret documents exchange. FALSE if there is no partner or an exchange already exists.
/datum/antagonist/traitor/proc/try_document_exchange()
	var/datum/game_mode/mode = SSticker.mode
	if(!mode || mode.exchange_red || mode.exchange_blue || !ishuman(owner.current))
		return FALSE
	var/list/partners = list()
	for(var/datum/antagonist/traitor/other in GLOB.antagonists)
		if(other == src || other.type != /datum/antagonist/traitor || other.traitor_kind != TRAITOR_HUMAN)
			continue
		if(!ishuman(other.owner?.current) || other.owner.current.stat == DEAD)
			continue
		partners += other
	if(!length(partners))
		return FALSE
	var/datum/antagonist/traitor/partner = pick(partners)
	mode.exchange_red = partner.owner
	mode.exchange_blue = owner
	partner.assign_exchange_role()
	partner.owner.announce_objectives()
	assign_exchange_role()
	return TRUE

/// pickweight that never returns an entry with zero weight. Null if every weight is zero.
/proc/pick_nonzero_weight(list/weighted)
	var/list/filtered = list()
	for(var/key in weighted)
		if(weighted[key] > 0)
			filtered[key] = weighted[key]
	if(!length(filtered))
		return null
	return pickweight(filtered)

/**
 * Sets the objective up for a freshly rolled traitor.
 * Return FALSE if it can't work this round, it gets deleted and another objective is rolled instead.
 */
/datum/objective/proc/traitor_roll_setup(datum/antagonist/traitor/rolling)
	find_target()
	return TRUE

/datum/objective/assassinate/traitor_roll_setup(datum/antagonist/traitor/rolling)
	find_target()
	return !!target

/datum/objective/destroy/traitor_roll_setup(datum/antagonist/traitor/rolling)
	find_target()
	return !!target

/datum/objective/break_machinery/traitor_roll_setup(datum/antagonist/traitor/rolling)
	return finalize()

/// TRUE if any traitor already got an objective of this exact type. For objectives that only make sense once per round.
/datum/objective/proc/taken_by_other_traitor()
	for(var/datum/antagonist/traitor/traitor in GLOB.antagonists)
		for(var/datum/objective/objective in traitor.objectives)
			if(objective != src && objective.type == type)
				return TRUE
	return FALSE

/// All areas on the station z-levels whose type is any of `area_types` (subtypes included).
/proc/get_station_areas_of_types(list/area_types)
	. = list()
	var/list/typecache = typecacheof(area_types)
	for(var/area/A as anything in GLOB.sortedAreas)
		if(!is_type_in_typecache(A, typecache))
			continue
		if(!(A.type in GLOB.the_station_areas))
			continue
		. += A

// Objectives added through the antag panel run the same setup as rolled ones
/datum/objective/hoarder/admin_edit(mob/admin)
	traitor_roll_setup()

/datum/objective/tcomms_data/admin_edit(mob/admin)
	traitor_roll_setup()

/datum/objective/sabotage/integrity/admin_edit(mob/admin)
	traitor_roll_setup()

/datum/objective/sabotage/ai_law/admin_edit(mob/admin)
	update_explanation_text()
	give_special_equipment(list(/obj/item/aiModule/syndicate))

/datum/objective/air_sabotage/admin_edit(mob/admin)
	traitor_roll_setup()

/datum/objective/iff_subvert/admin_edit(mob/admin)
	update_explanation_text()

#undef TRAITOR_CATEGORY_WEIGHT
#undef TRAITOR_OBJECTIVE_WEIGHT
#undef TRAITOR_FLAVOR_WEIGHT
#undef TRAITOR_FLAVOR_INSTEAD_OF_MAROON
#undef TRAITOR_DOCUMENT_EXCHANGE
