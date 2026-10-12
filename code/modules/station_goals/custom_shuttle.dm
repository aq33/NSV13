//Custom Shuttle
//Crew has to build a custom shuttle
/datum/station_goal/custom_shuttle
	name = "Custom Shuttle"

/datum/station_goal/custom_shuttle/get_report()
	return list(
		"<blockquote>Nanotrasen potrzebuje nowego prototypu lekkiego krążownika.",
		"Pozostawiamy wam decyzję, czego potrzebuje prom, by był skuteczną platformą.",
		"",
		"Wyznacznik możecie stworzyć w dziale inżynieryjnym albo kupić w zaopatrzeniu.</blockquote>",
	).Join("\n")

/datum/station_goal/custom_shuttle/check_completion()
	if(..())
		return TRUE
	if(GLOB.custom_shuttle_count)
		return TRUE
	return FALSE
