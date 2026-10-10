/datum/team/nation
	name = "Nation"

/datum/antagonist/separatist
	name = "Separatyści"
	show_in_antagpanel = FALSE
	show_name_in_check_antagonists = TRUE
	var/datum/team/nation/nation
	banning_key = BAN_ROLE_ALL_ANTAGONISTS

/datum/antagonist/separatist/create_team(datum/team/nation/new_team)
	if(!new_team)
		return
	nation = new_team

/datum/antagonist/separatist/get_team()
	return nation

/datum/antagonist/separatist/greet()
	to_chat(owner, "<B>Jesteś separatystą! [nation.name] na zawsze! Razem z towarzyszami broni chroń suwerenność swojej nowej ziemi!</B>")
