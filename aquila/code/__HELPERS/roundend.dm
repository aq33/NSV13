/// Mouse statistics for the round-end report (szczury)
/datum/controller/subsystem/ticker/proc/mouse_report()
	if(GLOB.mouse_food_eaten)
		var/list/parts = list()
		parts += "<span class='header'>Mouse stats:</span>"
		parts += "Mouse Born: [GLOB.mouse_spawned]"
		parts += "Mouse Killed: [GLOB.mouse_killed]"
		parts += "Trash Eaten: [GLOB.mouse_food_eaten]"
		return "<div class='panel stationborder'>[parts.Join("<br>")]</div>"
	return ""
