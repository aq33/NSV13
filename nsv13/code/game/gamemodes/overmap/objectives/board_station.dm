/datum/overmap_objective/board_station
	name = "Board Station"
	desc = "Find and board a station, then defend the station."
	brief = "Przejmijcie placówkę Syndykatu CALLANADMIN: wejdźcie na pokład, pokonajcie wrogów, zmieńcie jej kody IFF, a potem odeprzyjcie kontratak."
	var/defense_complete = FALSE
	var/datum/star_system/target_system = null
	var/obj/structure/overmap/target_station = null
	/// The boarding fleet sent to retake the station once it's captured
	var/datum/fleet/reinforcements = null

/datum/overmap_objective/board_station/New(datum/star_system/passed_input)
	.=..()
	if(passed_input) //Let us select a system in the gamemode controller
		target_system = passed_input
	if(!target_system)
		var/list/candidates = list()
		for(var/datum/star_system/S in SSstar_system.neutral_zone_systems)
			// Is this even in a reasonable location?
			if(S.hidden || (S.sector != 2) || S.name == "Rubicon" || S.has_anomaly_type(/obj/effect/overmap_anomaly/singularity))
				continue
			// Don't put it where it will immediately get shot
			if((S.alignment != "syndicate") && (S.alignment != "unaligned") && (S.alignment != "uncharted"))
				continue
			// This shouldn't be needed with the faction check, but don't put it in the spawn location
			if(S == SSstar_system.system_by_id(SSovermap_mode.mode.starting_system))
				continue
			candidates += S
		if(length(candidates))
			target_system = pick(candidates)

/datum/overmap_objective/board_station/instance()
	. = ..()
	if(!target_system)
		message_admins("[name] objective couldn't find a target system, marking it as completed.")
		status = 1
		return
	// make a station
	target_station = instance_overmap(/obj/structure/overmap/trader/syndicate/outpost)
	target_station.block_deletion = TRUE
	target_station.essential = TRUE
	RegisterSignal(target_station, COMSIG_SHIP_IFF_CHANGE, PROC_REF(iff_change))
	RegisterSignal(target_station, COMSIG_SHIP_RELEASE_BOARDING, PROC_REF(release_boarding))
	target_station.ai_load_interior(SSstar_system.find_main_overmap())
	target_station.name = generate_ship_name()
	brief = "Przejmijcie placówkę Syndykatu [target_station] w systemie [target_system]: wejdźcie na pokład, pokonajcie wrogów, zmieńcie jej kody IFF, a potem odeprzyjcie kontratak."
	target_system.add_ship(target_station)
	target_system.enemies_in_system += target_station
	target_system.objective_sector = TRUE
	// give it some friends :)
	var/datum/faction/S = SSstar_system.faction_by_id(FACTION_ID_SYNDICATE)
	S.send_fleet(target_system, null, TRUE)
	var/datum/fleet/F = pick(target_system.fleets)
	F.fleet_trait = FLEET_TRAIT_DEFENSE
	F.add_ship(target_station, "supply")

	// How long should this take?
	var/list/fastest_route = find_route(SSstar_system.find_system(SSovermap_mode.mode.starting_system), target_system, wormholes_allowed = FALSE)
	var/distance = 0
	for(var/i = 2; i <= length(fastest_route); i++)
		var/datum/star_system/start = fastest_route[i-1]
		var/datum/star_system/finish = fastest_route[i]
		distance += start.dist(finish)
	var/obj/structure/overmap/OM = SSstar_system.find_main_overmap()
	var/travel_time = (distance / (OM.ftl_drive.get_jump_speed() * 10)) SECONDS // Time spent flying
	travel_time += 2 MINUTES * length(fastest_route) // Time spent spooling FTL drive
	travel_time += 15 MINUTES //Time spent defending the objective after capture
	travel_time *= 1.2 // Time spent lolligagging
	SSovermap_mode.mode.objective_reminder_interval = max((travel_time / 5), SSovermap_mode.mode.objective_reminder_interval)
	message_admins("Reminder interval set to [(SSovermap_mode.mode.objective_reminder_interval) / 600] minutes")

/datum/overmap_objective/board_station/check_completion()
	if(defense_complete && status == 0)
		status = 1
		UnregisterSignal(target_station, COMSIG_SHIP_RELEASE_BOARDING) //Now that you've defended it you can do whatever
	return ..()

/datum/overmap_objective/board_station/proc/release_boarding()
	SIGNAL_HANDLER
	// Don't let them kill the ship if they haven't won yet
	if(status != 1 && status != 3) // complete or admin override
		return COMSIG_SHIP_BLOCKS_RELEASE_BOARDING
	return 0

/datum/overmap_objective/board_station/proc/iff_change()
	SIGNAL_HANDLER
	if(target_station.faction != SSovermap_mode.mode.starting_faction)
		return
	target_station.block_deletion = FALSE //You captured it, it's now your responsibility
	target_station.essential = FALSE
	UnregisterSignal(target_station, COMSIG_SHIP_IFF_CHANGE)
	INVOKE_ASYNC(src, PROC_REF(send_counterattack))

/// The Syndicate wants its outpost back
/datum/overmap_objective/board_station/proc/send_counterattack()
	var/datum/star_system/adjacent = SSstar_system.system_by_id(pick(target_system.adjacency_list))
	reinforcements = adjacent.spawn_fleet(/datum/fleet/boarding, 5) //Harder fight
	RegisterSignal(reinforcements, COMSIG_PARENT_QDELETING, PROC_REF(fleet_destroyed)) //Kill the fleet and you're done
	reinforcements.move(target_system, TRUE)

/datum/overmap_objective/board_station/proc/fleet_destroyed()
	SIGNAL_HANDLER
	reinforcements = null
	defense_complete = TRUE
	check_completion()
