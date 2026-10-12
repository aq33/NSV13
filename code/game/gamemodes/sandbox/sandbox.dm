/datum/game_mode/sandbox
	name = "sandbox"
	config_tag = "sandbox"
	report_type = "sandbox"
	required_players = 0

	announce_span = "info"
	announce_text = "Zbuduj własną stację... albo po prostu się powystrzelajcie!"

	allow_persistence_save = FALSE

/datum/game_mode/sandbox/pre_setup()

	CONFIG_SET(flag/allow_random_events, FALSE) //stops harmful events

	for(var/mob/M in GLOB.player_list)
		M.CanBuild()
	return 1

/datum/game_mode/sandbox/post_setup()
	..()
	SSshuttle.registerHostileEnvironment(src)

/datum/game_mode/sandbox/generate_report()
	return "Czujniki wskazują, że wszyscy członkowie załogi otrzymali moce psychiczne, dzięki którym mogą materializować przedmioty.<br><br>To się może skończyć tylko źle."
