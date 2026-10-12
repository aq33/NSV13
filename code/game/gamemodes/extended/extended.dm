/datum/game_mode/extended
	name = "extended"
	config_tag = "extended"
	report_type = "extended"
	false_report_weight = 0
	required_players = 0

	announce_span = "notice"
	announce_text = "Po prostu baw się dobrze i ciesz grą!"

	title_icon = "extended_white"

	var/secret = FALSE

/datum/game_mode/extended/secret
	name = "secret extended"
	config_tag ="secret_extended"
	report_type = "traitor"	//So this won't appear with traitor report
	secret = TRUE

/datum/game_mode/extended/pre_setup()
	return 1

/datum/game_mode/extended/generate_report()
	return "Transmisja w zasadzie nie wspominała o waszym sektorze. Możliwe, że podczas tej zmiany Syndykat nie ma niczego, co mogłoby zagrozić waszemu statkowi."

/datum/game_mode/extended/generate_station_goals()
	if(secret)
		return ..()
	for(var/T in subtypesof(/datum/station_goal))
		var/datum/station_goal/G = new T
		station_goals += G
		G.on_report()

/datum/game_mode/extended/announced/send_intercept()
	var/greenshift_message = "Dzięki niestrudzonej pracy naszych działów ochrony i wywiadu nie ma obecnie żadnych wiarygodnych zagrożeń dla [station_name()]. Wszystkie projekty budowlane na statku zostały zatwierdzone. Bezpiecznej zmiany!"
	. += "<b><i>Podsumowanie sytuacji od Centrali</i></b><hr>"
	. += greenshift_message

	print_command_report(., "Podsumowanie sytuacji od Centrali", announce = FALSE)
	priority_announce(greenshift_message, "Raport ochrony", SSstation.announcer.get_rand_report_sound())
