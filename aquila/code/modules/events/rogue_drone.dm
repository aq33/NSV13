// AQUILA - Rogue Drone: a drone shell dispenser on the ship glitches and builds a single Syndicate drone.
// Ghosts are polled for it like any other ghost role; if nobody signs up the dispenser leaves the shell behind for later.
// No announcement - the crew finds out the hard way.

/datum/round_event_control/aquila_rogue_drone
	name = "Rogue Drone"
	typepath = /datum/round_event/ghost_role/aquila_rogue_drone
	weight = 10
	max_occurrences = 1
	earliest_start = 20 MINUTES
	cannot_spawn_after_shuttlecall = TRUE

/datum/round_event_control/aquila_rogue_drone/canSpawnEvent(players_amt, gamemode)
	if(!length(aquila_rogue_drone_dispensers()))
		return FALSE
	return ..()

/datum/round_event/ghost_role/aquila_rogue_drone
	minimum_required = 1
	role_name = "Rogue Drone"
	fakeable = FALSE

/datum/round_event/ghost_role/aquila_rogue_drone/spawn_role()
	if(!length(aquila_rogue_drone_dispensers()))
		return MAP_ERROR

	var/list/candidates = get_candidates(ROLE_DRONE, null)

	// The poll takes a while, pick the dispenser afterwards so it is still working
	var/list/dispensers = aquila_rogue_drone_dispensers()
	if(!length(dispensers))
		return MAP_ERROR
	var/obj/machinery/droneDispenser/dispenser = pick(dispensers)
	var/turf/spot = get_turf(dispenser)

	dispenser.visible_message("<span class='warning'>[dispenser] zgrzyta i wypluwa podejrzanego drona w czerwonych barwach!</span>")
	playsound(dispenser, 'sound/machines/warning-buzzer.ogg', 50, TRUE)
	do_sparks(3, TRUE, dispenser)

	if(!length(candidates))
		// Nobody wanted it now, a ghost can still click the shell later
		var/obj/effect/mob_spawn/drone/syndrone/shell = new(spot)
		message_admins("Rogue Drone event found no candidates, left [shell] at [ADMIN_VERBOSEJMP(spot)].")
		log_game("Rogue Drone event found no candidates, left [shell] at [AREACOORD(spot)].")
		spawned_mobs += shell
		return SUCCESSFUL_SPAWN

	var/mob/dead/selected = pick(candidates)
	var/mob/living/simple_animal/drone/syndrone/drone = new(spot)
	drone.key = selected.key
	message_admins("[ADMIN_LOOKUPFLW(drone)] has been made into a rogue syndrone by an event at [ADMIN_VERBOSEJMP(spot)].")
	log_game("[key_name(drone)] was spawned as a rogue syndrone by an event at [AREACOORD(spot)].")
	spawned_mobs += drone
	return SUCCESSFUL_SPAWN

/// Ordinary drone shell dispensers on the ship that are powered and in one piece
/proc/aquila_rogue_drone_dispensers()
	. = list()
	for(var/obj/machinery/droneDispenser/dispenser in GLOB.machines)
		if(dispenser.dispense_type != /obj/effect/mob_spawn/drone) // skip the syndrone, swarmer and other special variants
			continue
		if(!is_station_level(dispenser.z) || !dispenser.anchored || (dispenser.machine_stat & (BROKEN|NOPOWER)))
			continue
		. += dispenser
