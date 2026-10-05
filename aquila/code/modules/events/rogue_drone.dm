// AQUILA - Rogue Drone: a drone shell dispenser on the ship glitches and prints a single Syndicate drone shell.
// Ghosts get pinged to take it over, no announcement - the crew finds out the hard way.

/datum/round_event_control/aquila_rogue_drone
	name = "Rogue Drone"
	typepath = /datum/round_event/aquila_rogue_drone
	weight = 8
	max_occurrences = 1
	min_players = 10
	earliest_start = 20 MINUTES
	cannot_spawn_after_shuttlecall = TRUE

/datum/round_event_control/aquila_rogue_drone/canSpawnEvent(players_amt, gamemode)
	if(!(GLOB.ghost_role_flags & GHOSTROLE_SPAWNER)) // nobody could take the shell
		return FALSE
	if(!length(aquila_rogue_drone_dispensers()))
		return FALSE
	return ..()

/datum/round_event/aquila_rogue_drone
	fakeable = FALSE

/datum/round_event/aquila_rogue_drone/start()
	var/list/dispensers = aquila_rogue_drone_dispensers()
	if(!length(dispensers))
		message_admins("Rogue Drone event found no working drone shell dispenser, nothing was spawned.")
		log_game("Rogue Drone event found no working drone shell dispenser, nothing was spawned.")
		return
	var/obj/machinery/droneDispenser/dispenser = pick(dispensers)
	var/turf/spot = get_turf(dispenser)

	dispenser.visible_message("<span class='warning'>[dispenser] zgrzyta i wypluwa podejrzaną skorupę drona w czerwonych barwach!</span>")
	playsound(dispenser, 'sound/machines/warning-buzzer.ogg', 50, TRUE)
	do_sparks(3, TRUE, dispenser)

	var/obj/effect/mob_spawn/drone/syndrone/shell = new(spot)
	notify_ghosts("[dispenser] w [get_area_name(spot, TRUE)] wyprodukował skorupę syndrona!", source = shell, action = NOTIFY_ATTACK, header = "Zbuntowany dron", flashwindow = TRUE)

	message_admins("Rogue Drone event spawned [shell] at [ADMIN_VERBOSEJMP(spot)].")
	log_game("Rogue Drone event spawned [shell] at [AREACOORD(spot)].")

/// Ordinary drone shell dispensers on the ship that are powered and in one piece
/proc/aquila_rogue_drone_dispensers()
	. = list()
	for(var/obj/machinery/droneDispenser/dispenser in GLOB.machines)
		if(dispenser.dispense_type != /obj/effect/mob_spawn/drone) // skip the syndrone, swarmer and other special variants
			continue
		if(!is_station_level(dispenser.z) || !dispenser.anchored || (dispenser.machine_stat & (BROKEN|NOPOWER)))
			continue
		. += dispenser
