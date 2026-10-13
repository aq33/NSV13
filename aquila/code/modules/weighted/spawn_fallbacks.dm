// AQUILA - Not every one of our maps has xeno_spawn and blobstart landmarks (Snake has neither, Atlas has no blobstart).
// Without them morphs, nightmares, paradox clones, fugitives and blobs can't spawn, and the blob core autoplace runtimes.
// Before antagonists are picked, an empty list gets safe maintenance turfs instead.

/// How many turfs an empty spawn list gets
#define FALLBACK_SPAWN_TURFS 10

/// Up to amount random safe, open floor turfs in station maintenance, or anywhere on the station if there is no maintenance
/proc/aquila_fallback_spawn_turfs(amount)
	var/list/maintenance = list()
	for(var/area_type in GLOB.the_station_areas)
		if(ispath(area_type, /area/maintenance))
			maintenance += area_type
	var/list/valid = list()
	for(var/area_type in (length(maintenance) ? maintenance : GLOB.the_station_areas))
		for(var/turf/candidate as anything in get_area_turfs(area_type))
			if(!is_station_level(candidate.z) || isgroundlessturf(candidate) || is_blocked_turf(candidate, TRUE) || !is_turf_safe(candidate))
				continue
			valid += candidate
		CHECK_TICK
	. = list()
	while(length(valid) && length(.) < amount)
		. += pick_n_take(valid)

/proc/aquila_fill_missing_spawns()
	if(!length(GLOB.xeno_spawn))
		GLOB.xeno_spawn += aquila_fallback_spawn_turfs(FALLBACK_SPAWN_TURFS)
		log_mapping("The map has no xeno_spawn landmarks, using [length(GLOB.xeno_spawn)] maintenance turfs instead.")
	if(!length(GLOB.blobstart))
		GLOB.blobstart += aquila_fallback_spawn_turfs(FALLBACK_SPAWN_TURFS)
		log_mapping("The map has no blobstart landmarks, using [length(GLOB.blobstart)] maintenance turfs instead.")

/datum/controller/subsystem/ticker/setup()
	aquila_fill_missing_spawns()
	return ..()

// AQUILA - our maps have no empty space level, so the pirate ship had nowhere to load and the event never ran.
// The level is made when the pirates first come, the same way SSmapping makes it at startup.
/datum/round_event_control/pirates/preRunEvent()
	if(!SSmapping.empty_space)
		SSmapping.space_levels_so_far++
		SSmapping.empty_space = SSmapping.add_new_zlevel("Empty Area [SSmapping.space_levels_so_far]", list(ZTRAIT_LINKAGE = SELFLOOPING), orbital_body_type = /datum/orbital_object/z_linked/beacon/weak)
	return ..()

#undef FALLBACK_SPAWN_TURFS
