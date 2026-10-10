/mob/living/carbon/human
	var/datum/squad/squad = null

//Show relevent squad info on status panel.
/mob/living/carbon/human/proc/get_stat_tab_squad()
	var/list/tab_data = list()

	if(!squad)
		tab_data["Przydzielony oddział"] = list(
			text = "None",
			type = STAT_TEXT
		)
		return tab_data

	tab_data["Przydzielony oddział"] = list(
			text = "[squad.name || "Unassigned"]",
			type = STAT_TEXT
		)
	tab_data["Dowódca oddziału"] = list(
			text = "[squad.leader || "None"]",
			type = STAT_TEXT
		)
	tab_data["Cel główny"] = list(
			text = "[squad.primary_objective || "None"]",
			type = STAT_TEXT
		)
	tab_data["Cel poboczny"] = list(
			text = "[squad.secondary_objective || "None"]",
			type = STAT_TEXT
		)
	return tab_data
