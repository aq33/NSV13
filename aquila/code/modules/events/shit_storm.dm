/datum/round_event_control/shit_storm
	name = "Shit Storm"
	typepath = /datum/round_event/shit_storm
	max_occurrences = 1
	weight = 6
	can_malf_fake_alert = TRUE

/datum/round_event/shit_storm

/datum/round_event/shit_storm/setup()
	startWhen = 3
	endWhen = startWhen + 1
	announceWhen	= 1

/datum/round_event/shit_storm/announce(fake)
	if(!CONFIG_GET(flag/shitting_enabled))
		return
	priority_announce("Wysokie poziomy gówna wykryte w pobliżu stacji. Prosimy udać się do tuneli serwisowych.", "Alarm: Anomalia", ANNOUNCER_RADIATION)
	//sound not longer matches the text, but an audible warning is probably good

/datum/round_event/shit_storm/start()
	if(!CONFIG_GET(flag/shitting_enabled))
		return
	SSweather.run_weather(/datum/weather/shit_storm)
