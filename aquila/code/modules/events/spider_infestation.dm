// AQUILA - plaga pająków jak w tg: gniazda jaj matek w technicznych, z których wykluwają się duchy

/datum/round_event_control/spider_infestation
	name = "Spider Infestation"
	typepath = /datum/round_event/spider_infestation
	weight = 10
	max_occurrences = 1
	min_players = 15
	dynamic_should_hijack = TRUE
	can_malf_fake_alert = TRUE

/datum/round_event/spider_infestation
	announceWhen = 400
	/// Ile gniazd matek podrzucić
	var/egg_count = 1

/datum/round_event/spider_infestation/setup()
	announceWhen = rand(announceWhen, announceWhen + 50)
	egg_count = clamp(1 + round(length(GLOB.player_list) / 20), 1, 3)

/datum/round_event/spider_infestation/announce(fake)
	priority_announce("Wykryto niezidentyfikowane formy życia wkraczające na pokład [station_name()]. Zabezpieczyć wszelkie drogi zewnętrznego dostępu, jak również system wentylacji.", "Alarm biologiczny", ANNOUNCER_ALIENS)

/datum/round_event/spider_infestation/start()
	var/list/spawn_turfs = find_spider_spawns()
	if(!length(spawn_turfs))
		message_admins("Plaga pająków: nie znaleziono miejsca na gniazdo.")
		return
	for(var/i in 1 to egg_count)
		if(!length(spawn_turfs))
			break
		var/turf/spawn_loc = pick_n_take(spawn_turfs)
		var/obj/structure/spider/eggcluster/midwife/new_eggs = new(spawn_loc)
		new_eggs.amount_grown = 98
		announce_to_ghosts(new_eggs)
		message_admins("Plaga pająków: gniazdo matki w [ADMIN_VERBOSEJMP(spawn_loc)].")
		log_game("Spider infestation: midwife egg cluster spawned at [AREACOORD(spawn_loc)].")

/// Pola przy wentylacjach w technicznych; jeśli takich nie ma, przy dowolnej wentylacji na statku
/datum/round_event/spider_infestation/proc/find_spider_spawns()
	var/list/maint_turfs = list()
	var/list/other_turfs = list()
	for(var/obj/machinery/atmospherics/components/unary/vent_pump/vent in GLOB.machines)
		if(QDELETED(vent) || vent.welded)
			continue
		var/turf/vent_turf = get_turf(vent)
		if(!vent_turf || !is_station_level(vent_turf.z) || isspaceturf(vent_turf))
			continue
		if(istype(get_area(vent_turf), /area/maintenance))
			maint_turfs += vent_turf
		else
			other_turfs += vent_turf
	return length(maint_turfs) ? maint_turfs : other_turfs
