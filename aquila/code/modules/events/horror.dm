// AQUILA - Eldritch Horror ghost role event (Yogstation#13033)
/datum/round_event_control/horror
	name = "Spawn Eldritch Horror"
	typepath = /datum/round_event/ghost_role/horror
	weight = 10 // AQUILA - Yogs uses the default weight
	max_occurrences = 2
	min_players = 15
	earliest_start = 20 MINUTES

/datum/round_event/ghost_role/horror
	minimum_required = 1
	role_name = "horror"
	fakeable = FALSE

/datum/round_event/ghost_role/horror/spawn_role()
	var/list/candidates = get_candidates(ROLE_HORROR, /datum/role_preference/midround_ghost/horror)
	if(!candidates.len)
		return NOT_ENOUGH_PLAYERS

	var/mob/dead/selected = pick_n_take(candidates)

	var/list/spawn_locs = horror_spawn_locations()
	if(!length(spawn_locs))
		return MAP_ERROR
	var/datum/mind/player_mind = new /datum/mind(selected.key)
	player_mind.active = 1
	var/mob/living/simple_animal/horror/S = new /mob/living/simple_animal/horror(pick(spawn_locs))
	player_mind.transfer_to(S)
	player_mind.assigned_role = ROLE_HORROR
	player_mind.special_role = ROLE_HORROR
	player_mind.add_antag_datum(/datum/antagonist/horror)
	to_chat(S, S.playstyle_string)
	SEND_SOUND(S, sound('sound/hallucinations/growl2.ogg'))
	message_admins("[ADMIN_LOOKUPFLW(S)] has been made into an eldritch horror by an event.")
	log_game("[key_name(S)] was spawned as an eldritch horror by an event.")
	spawned_mobs += S
	return SUCCESSFUL_SPAWN

/// AQUILA - event spawn points on the ship only. The gulag map has its own event spawns on a space z-level.
/proc/horror_spawn_locations()
	. = list()
	for(var/obj/effect/landmark/event_spawn/spawn_point as anything in GLOB.generic_event_spawns)
		var/turf/T = get_turf(spawn_point)
		if(T && is_station_level(T.z))
			. += T
