/datum/round_event_control/supermatter_surge
	name = "Supermatter Surge"
	typepath = /datum/round_event/supermatter_surge
	weight = 10
	max_occurrences = 4
	earliest_start = 10 MINUTES

/datum/round_event_control/supermatter_surge/canSpawnEvent()
	if(GLOB.main_supermatter_engine?.has_been_powered)
		return ..()

/datum/round_event/supermatter_surge
	announceWhen = 1
	var/power = 2000

/datum/round_event/supermatter_surge/setup()
	power = rand(200,4000)

/datum/round_event/supermatter_surge/announce()
	if(power > 800 || prob(round(power/8)))
		priority_announce("Wykryto skok mocy supermaterii klasy [round(power/500) + 1]. Może być wymagana interwencja.", "Alarm - anomalia", SSstation.announcer.get_rand_alert_sound())

/datum/round_event/supermatter_surge/start()
	if(!GLOB.main_supermatter_engine) // AQ EDIT - admins can force it without a supermatter
		return
	GLOB.main_supermatter_engine.matter_power += power
