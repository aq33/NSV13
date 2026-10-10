/// Mouse statistics for the round-end report (szczury)
/datum/controller/subsystem/ticker/proc/mouse_report()
	if(GLOB.mouse_food_eaten)
		var/list/parts = list()
		parts += "<span class='header'>Statystyki myszy:</span>"
		parts += "Narodzone myszy: [GLOB.mouse_spawned]"
		parts += "Zabite myszy: [GLOB.mouse_killed]"
		parts += "Zjedzone śmieci: [GLOB.mouse_food_eaten]"
		return "<div class='panel stationborder'>[parts.Join("<br>")]</div>"
	return ""
