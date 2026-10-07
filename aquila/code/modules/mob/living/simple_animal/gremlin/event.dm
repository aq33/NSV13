// AQUILA - event z gremlinami (port z HippieStation)

/datum/round_event_control/gremlin
	name = "Spawn Gremlins"
	typepath = /datum/round_event/gremlin
	weight = 15
	max_occurrences = 2
	earliest_start = 20 MINUTES //Meant to mix things up early-game
	min_players = 5

/datum/round_event/gremlin

/datum/round_event/gremlin/announce(fake)
	priority_announce("Bioskany wskazują, że przez wentylację na pokład [station_name()] dostały się gremliny. Zajmijcie się nimi!", "Alarm: gremliny")

/datum/round_event/gremlin/start()
	var/list/spawn_locs = list()
	for(var/atom/spawn_point as anything in GLOB.xeno_spawn + GLOB.generic_event_spawns + GLOB.blobstart)
		var/turf/T = get_turf(spawn_point)
		if(T && is_station_level(T.z) && !isspaceturf(T))
			spawn_locs |= T
	if(!length(spawn_locs)) //No landmarks, crawl out of the station's vents instead
		for(var/obj/machinery/atmospherics/components/unary/vent_pump/vent in GLOB.machines)
			if(!QDELETED(vent) && !vent.welded && is_station_level(vent.z))
				spawn_locs |= get_turf(vent)
	if(!length(spawn_locs))
		message_admins("Gremlin event found no spawn locations, nothing was spawned.")
		return MAP_ERROR

	var/gremlins_to_spawn = rand(3, 6)
	var/list/gremlin_areas = list()
	while(gremlins_to_spawn-- > 0 && length(spawn_locs))
		var/turf/spawnat = pick_n_take(spawn_locs)
		gremlin_areas |= get_area_name(spawnat, TRUE)
		var/mob/living/simple_animal/hostile/gremlin/G = new(spawnat)
		announce_to_ghosts(G)
	var/grems = gremlin_areas.Join(", ")
	message_admins("Gremlins have been spawned at the areas: [grems]")
	log_game("Gremlins have been spawned at the areas: [grems]")
	return SUCCESSFUL_SPAWN
