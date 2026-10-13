// AQUILA - event wędrowca pustki (port z tgstation)

/datum/round_event_control/voidwalker
	name = "Spawn Voidwalker"
	typepath = /datum/round_event/ghost_role/voidwalker
	max_occurrences = 1
	weight = 8
	min_players = 15
	dynamic_should_hijack = TRUE
	cannot_spawn_after_shuttlecall = TRUE

/datum/round_event/ghost_role/voidwalker
	minimum_required = 1
	role_name = "voidwalker"
	fakeable = FALSE

/datum/round_event/ghost_role/voidwalker/spawn_role()
	var/list/candidates = get_candidates(ROLE_VOIDWALKER, /datum/role_preference/midround_ghost/voidwalker)
	if(!length(candidates))
		return NOT_ENOUGH_PLAYERS

	var/turf/spawn_loc = find_voidwalker_spawn()
	if(!spawn_loc)
		message_admins("No valid spawn locations found for a voidwalker, aborting...")
		return MAP_ERROR

	var/mob/dead/selected = pick(candidates)
	var/mob/living/simple_animal/hostile/voidwalker/walker = create_voidwalker(selected.key, spawn_loc)
	message_admins("[ADMIN_LOOKUPFLW(walker)] has been made into a voidwalker by an event.")
	log_game("[key_name(walker)] was spawned as a voidwalker by an event.")
	spawned_mobs += walker
	return SUCCESSFUL_SPAWN
