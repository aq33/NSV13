GLOBAL_LIST_EMPTY(antagonist_teams)

//A barebones antagonist team.
/datum/team
	var/list/datum/mind/members = list()
	var/name = "team"
	var/member_name = "member"
	var/list/objectives = list() //common objectives, these won't be added or removed automatically, subtypes handle this, this is here for bookkeeping purposes.
	var/show_roundend_report = TRUE

/datum/team/New(starting_members)
	. = ..()
	GLOB.antagonist_teams += src
	if(starting_members)
		if(islist(starting_members))
			for(var/datum/mind/M in starting_members)
				add_member(M)
		else
			add_member(starting_members)

/datum/team/Destroy(force, ...)
	GLOB.antagonist_teams -= src
	. = ..()

/datum/team/proc/is_solo()
	return members.len == 1

/datum/team/proc/add_member(datum/mind/new_member)
	members |= new_member

/datum/team/proc/remove_member(datum/mind/member)
	members -= member

//Display members/victory/failure/objectives for the team
/datum/team/proc/roundend_report()
	if(!show_roundend_report)
		return

	var/list/report = list()

	report += "<span class='header'>[name]:</span>"
	report += "Członkowie ([member_name]):"
	report += printplayerlist(members)

	if(objectives.len)
		report += "<span class='header'>Cele drużyny:</span>"
		var/win = TRUE
		var/objective_count = 1
		for(var/datum/objective/objective in objectives)
			if(objective.check_completion())
				report += "<B>Cel nr [objective_count]</B>: [objective.explanation_text] <span class='greentext'>Sukces!</span>"
			else
				report += "<B>Cel nr [objective_count]</B>: [objective.explanation_text] <span class='redtext'>Porażka.</span>"
				win = FALSE
			objective_count++
		if(win)
			report += "<span class='greentext'>[name]: sukces!</span>"
		else
			report += "<span class='redtext'>[name]: porażka!</span>"


	return "<div class='panel redborder'>[report.Join("<br>")]</div>"
