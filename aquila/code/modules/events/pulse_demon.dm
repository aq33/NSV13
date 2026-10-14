// AQUILA - event demona impulsu (port z ParadiseSS13)

/datum/round_event_control/pulse_demon
	name = "Spawn Pulse Demon"
	typepath = /datum/round_event/ghost_role/pulse_demon
	max_occurrences = 1
	weight = 8
	min_players = 10
	earliest_start = 20 MINUTES
	dynamic_should_hijack = TRUE
	cannot_spawn_after_shuttlecall = TRUE

/datum/round_event/ghost_role/pulse_demon
	minimum_required = 1
	role_name = "pulse demon"
	fakeable = FALSE

/datum/round_event/ghost_role/pulse_demon/spawn_role()
	var/list/candidates = get_candidates(ROLE_PULSE_DEMON, /datum/role_preference/midround_ghost/pulse_demon)
	if(!length(candidates))
		return NOT_ENOUGH_PLAYERS

	var/list/spawn_locs = pulse_demon_spawn_locations()
	if(!length(spawn_locs))
		message_admins("No powered cables found for a pulse demon, aborting...")
		return MAP_ERROR

	var/mob/dead/selected = pick(candidates)
	var/mob/living/simple_animal/pulse_demon/demon = create_pulse_demon(selected.key, pick(spawn_locs))
	message_admins("[ADMIN_LOOKUPFLW(demon)] has been made into a pulse demon by an event.")
	log_game("[key_name(demon)] was spawned as a pulse demon by an event.")
	spawned_mobs += demon
	return SUCCESSFUL_SPAWN
