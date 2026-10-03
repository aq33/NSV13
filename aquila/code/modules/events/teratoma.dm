// AQUILA - a living tumor (teratoma monkey ghost spawner, aq33/NSV13#240) grows somewhere in maintenance
// Rare and capped: at most once per round, only with enough crew and ghosts around to make it interesting

/datum/round_event_control/aquila_teratoma
	name = "Living Tumor"
	typepath = /datum/round_event/aquila_teratoma
	// Looks big, but it is picked at most once and only in the few event rolls after earliest_start, and half of all rolls
	// go to the star system's own list instead. Against the ~570 total weight of the pool this is ~1/3 rounds that reach 18 players
	weight = 55
	max_occurrences = 1
	min_players = 18
	earliest_start = 25 MINUTES
	cannot_spawn_after_shuttlecall = TRUE

/datum/round_event_control/aquila_teratoma/canSpawnEvent(players_amt, gamemode)
	if(!(GLOB.ghost_role_flags & GHOSTROLE_SPAWNER)) // nobody could take the spawner
		return FALSE
	return ..()

/datum/round_event/aquila_teratoma
	fakeable = FALSE

/datum/round_event/aquila_teratoma/start()
	spawn_mass()

/// Puts one fleshy mass on a random safe maintenance turf, returns it or null if there was no such turf
/datum/round_event/aquila_teratoma/proc/spawn_mass()
	var/list/turfs = candidate_turfs()
	if(!length(turfs))
		message_admins("Living Tumor event found no safe maintenance turf, nothing was spawned.")
		log_game("Living Tumor event found no safe maintenance turf, nothing was spawned.")
		return
	var/turf/spot = pick(turfs)
	var/obj/effect/mob_spawn/teratomamonkey/mass = new(spot)
	message_admins("Living Tumor event spawned [mass] at [ADMIN_VERBOSEJMP(spot)].")
	log_game("Living Tumor event spawned [mass] at [AREACOORD(spot)].")
	return mass

/// Every turf the event may pick
/datum/round_event/aquila_teratoma/proc/candidate_turfs()
	. = list()
	for(var/area/A as anything in GLOB.sortedAreas)
		if(!valid_area(A))
			continue
		for(var/turf/T in A)
			if(valid_turf(T))
				. += T

/// Station maintenance, minus the parts that are outside, deadly or a lab
/datum/round_event/aquila_teratoma/proc/valid_area(area/A)
	var/static/list/excluded_areas = typecacheof(list(
		/area/maintenance/solars, // solar arrays, half of it is space
		/area/maintenance/disposal, // conveyors, the crusher and the incinerator
		/area/maintenance/department/science/xenobiology, // slime pens on some maps
	))
	return istype(A, /area/maintenance) && !is_type_in_typecache(A, excluded_areas)

/datum/round_event/aquila_teratoma/proc/valid_turf(turf/T)
	if(!T || !is_station_level(T.z) || !valid_area(get_area(T)))
		return FALSE
	if(isgroundlessturf(T) || !is_turf_safe(T)) // floors only, no walls or space, and breathable air
		return FALSE
	if(is_blocked_turf(T)) // dense turf, dense objects or someone standing there
		return FALSE
	if(locate(/obj/effect/mob_spawn) in T)
		return FALSE
	return TRUE
