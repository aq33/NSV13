// AQUILA - Partition: the ship is cut in half by an impassable energy barrier for a few minutes.
// The barrier runs through the middle of the ship, across its longer side, on every deck and out into space
// so nobody can walk or float around it. Air still flows through, only movement and projectiles are stopped.

/datum/round_event_control/aquila_ship_partition
	name = "Ship Partition"
	typepath = /datum/round_event/aquila_ship_partition
	weight = 8
	max_occurrences = 1
	min_players = 8
	earliest_start = 15 MINUTES

/datum/round_event/aquila_ship_partition
	announceWhen = 1
	startWhen = 1
	/// How long the barrier stands
	var/duration

/datum/round_event/aquila_ship_partition/setup()
	duration = rand(3, 5) MINUTES

/datum/round_event/aquila_ship_partition/announce(fake)
	priority_announce("Usterka emiterów pola siłowego: statek został tymczasowo przedzielony nieprzekraczalną barierą energetyczną. \
		Bariera powinna zniknąć w ciągu kilku minut.", "Alarm: Bariera energetyczna", ANNOUNCER_SPANOMALIES)

/datum/round_event/aquila_ship_partition/start()
	var/list/line = aquila_partition_line()
	if(!length(line))
		message_admins("Ship Partition event found no station turfs, nothing was spawned.")
		log_game("Ship Partition event found no station turfs, nothing was spawned.")
		return
	var/vertical = line["vertical"]
	var/position = line["position"]
	var/barriers = 0
	for(var/z in SSmapping.levels_by_trait(ZTRAIT_STATION))
		for(var/i in 1 to (vertical ? world.maxy : world.maxx))
			var/turf/T = vertical ? locate(position, i, z) : locate(i, position, z)
			if(!T)
				continue
			// Nobody gets to stand inside the barrier and walk out on the other side
			for(var/mob/living/stuck in T)
				var/turf/aside = get_step(T, pick(vertical ? list(EAST, WEST) : list(NORTH, SOUTH)))
				if(aside && !aside.density)
					stuck.forceMove(aside)
			new /obj/effect/forcefield/aquila_partition(T, duration)
			barriers++
		CHECK_TICK
	addtimer(CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(priority_announce), "Bariera energetyczna przedzielająca statek wygasła.", "Bariera energetyczna"), duration)
	message_admins("Ship Partition event split the ship along [vertical ? "x" : "y"] = [position] with [barriers] barrier tiles for [DisplayTimeText(duration)].")
	log_game("Ship Partition event split the ship along [vertical ? "x" : "y"] = [position] with [barriers] barrier tiles for [DisplayTimeText(duration)].")

/// Where to cut the ship: the middle of its longer side. Returns list("vertical" = TRUE if the line runs north-south, "position" = x or y), or null
/proc/aquila_partition_line()
	var/min_x = INFINITY
	var/max_x = 0
	var/min_y = INFINITY
	var/max_y = 0
	for(var/area/A as anything in GLOB.sortedAreas)
		if(!(A.type in GLOB.the_station_areas))
			continue
		for(var/turf/T in A)
			if(!is_station_level(T.z))
				continue
			min_x = min(min_x, T.x)
			max_x = max(max_x, T.x)
			min_y = min(min_y, T.y)
			max_y = max(max_y, T.y)
		CHECK_TICK
	if(!max_x)
		return null
	if(max_x - min_x >= max_y - min_y)
		return list("vertical" = TRUE, "position" = round((min_x + max_x) / 2))
	return list("vertical" = FALSE, "position" = round((min_y + max_y) / 2))

/obj/effect/forcefield/aquila_partition
	name = "bariera energetyczna"
	desc = "Migocząca ściana energii przecinająca statek na pół. Nie przejdziesz przez nią, możesz najwyżej poczekać, aż zgaśnie."
	icon_state = "m_shield"
	layer = ABOVE_MOB_LAYER
	CanAtmosPass = ATMOS_PASS_YES
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF | FREEZE_PROOF
	move_resist = INFINITY
	timeleft = 3 MINUTES

/obj/effect/forcefield/aquila_partition/CanAllowThrough(atom/movable/mover, turf/target)
	. = ..()
	return FALSE

/obj/effect/forcefield/aquila_partition/ex_act(severity, target)
	return

/obj/effect/forcefield/aquila_partition/emp_act(severity)
	return
