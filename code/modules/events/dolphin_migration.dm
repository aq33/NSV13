/datum/round_event_control/dolphin_migration
	name = "Dolphin Migration"
	typepath = /datum/round_event/dolphin_migration
	weight = 10
	earliest_start = 10 MINUTES
	max_occurrences = 1

/datum/round_event/dolphin_migration
	announceWhen = 3
	startWhen = 50

/datum/round_event/dolphin_migration/setup()
	startWhen = rand(40, 60)

/datum/round_event/dolphin_migration/announce()
	priority_announce("W pobliżu [station_name()] wykryto nieznane formy biologiczne, prosimy czekać na dalsze informacje.", "Alarm - formy życia", SSstation.announcer.get_rand_alert_sound())


/datum/round_event/dolphin_migration/start()
	for(var/obj/effect/landmark/carpspawn/C in GLOB.landmarks_list)
		new /mob/living/simple_animal/hostile/retaliate/dolphin(C.loc)
