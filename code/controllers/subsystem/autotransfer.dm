SUBSYSTEM_DEF(autotransfer)
	name = "Autotransfer Vote"
	flags = SS_KEEP_TIMING | SS_BACKGROUND
	wait = 1 MINUTES

	var/starttime
	var/targettime

/datum/controller/subsystem/autotransfer/Initialize(timeofday)
	starttime = REALTIMEOFDAY
	targettime = starttime + CONFIG_GET(number/vote_autotransfer_initial)

	if(!CONFIG_GET(flag/vote_autotransfer_enabled))
		can_fire = FALSE

	. = ..()

/datum/controller/subsystem/autotransfer/fire()
	if(REALTIMEOFDAY > targettime)
		if(!SSvote.current_vote) // AQ EDIT - port BeeStation #13247: vote datums
			SSvote.initiate_vote(/datum/vote/transfer, "the server", forced = TRUE)
		targettime = targettime + CONFIG_GET(number/vote_autotransfer_interval)
