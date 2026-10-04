// AQUILA - Paradox Clone random event (tgstation#71141 ships it as a dynamic midround ruleset only,
// our rounds roll midround ghost antags through random events, so it gets both).
// Tuned through the PARADOX_CLONE_* entries in config/game_options.txt.

/datum/round_event_control/paradox_clone
	name = "Spawn Paradox Clone"
	typepath = /datum/round_event/ghost_role/paradox_clone
	weight = 8
	max_occurrences = 1
	min_players = 10
	earliest_start = 20 MINUTES
	dynamic_should_hijack = TRUE
	cannot_spawn_after_shuttlecall = TRUE

/datum/round_event_control/paradox_clone/New()
	// Read before the parent applies the EVENTS_MIN_*_MUL multipliers
	if(config)
		weight = CONFIG_GET(number/paradox_clone_weight)
		max_occurrences = CONFIG_GET(number/paradox_clone_max_occurrences)
		min_players = CONFIG_GET(number/paradox_clone_min_players)
		earliest_start = CONFIG_GET(number/paradox_clone_earliest_start) MINUTES
	return ..()

/datum/round_event_control/paradox_clone/canSpawnEvent(players_amt, gamemode)
	if(!CONFIG_GET(flag/paradox_clone_enabled))
		return FALSE
	if(!paradox_clone_find_original())
		return FALSE
	return ..()

/datum/round_event/ghost_role/paradox_clone
	minimum_required = 1
	role_name = "Paradox Clone"
	fakeable = FALSE

/datum/round_event/ghost_role/paradox_clone/spawn_role()
	var/list/possible_spawns = paradox_clone_spawn_locations()
	if(!length(possible_spawns))
		message_admins("No valid spawn locations found for Paradox Clone event, aborting...")
		return MAP_ERROR

	if(!paradox_clone_find_original())
		return NOT_ENOUGH_PLAYERS

	var/list/candidates = get_candidates(ROLE_PARADOX_CLONE, /datum/role_preference/midround_ghost/paradox_clone)
	if(!length(candidates))
		return NOT_ENOUGH_PLAYERS

	// The poll takes a while, pick the original afterwards so they are still around
	var/mob/living/carbon/human/original = paradox_clone_find_original()
	if(!original)
		return NOT_ENOUGH_PLAYERS

	var/mob/dead/selected = pick(candidates)
	var/mob/living/carbon/human/clone = create_paradox_clone(selected.key, original, pick(possible_spawns), "an event")
	spawned_mobs += clone
	return SUCCESSFUL_SPAWN
