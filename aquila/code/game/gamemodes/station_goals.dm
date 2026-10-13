// Cele statku przy wyłączonym raporcie wywiadu: jedno zbiorcze ogłoszenie i jeden wydruk zamiast osobnego komunikatu dla każdego celu.

/datum/game_mode/proc/send_station_goals_report()
	if(!length(station_goals))
		return
	var/list/reports = list()
	for(var/datum/station_goal/goal as anything in station_goals)
		goal.on_report()
		reports += goal.get_report()
	priority_announce("Otrzymano priorytetowe dyrektywy Nanotrasen ([length(reports)]). Szczegóły projektów wydrukowano na konsolach komunikacyjnych.", "Przychodząca wiadomość priorytetowa", SSstation.announcer.get_rand_report_sound())
	print_command_report(reports.Join("<hr>"), "Dyrektywy Nanotrasen [pick(GLOB.phonetic_alphabet)] \Roman[rand(1,50)]", announce = FALSE)
