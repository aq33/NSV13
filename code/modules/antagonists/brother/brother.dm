/datum/antagonist/brother
	name = "Brat krwi"
	antagpanel_category = "Brother"
	banning_key = ROLE_BROTHER
	required_living_playtime = 4
	hijack_speed = 0.5
	var/datum/team/brother_team/team
	antag_moodlet = /datum/mood_event/focused

/datum/antagonist/brother/create_team(datum/team/brother_team/new_team)
	if(!new_team)
		return
	if(!istype(new_team))
		stack_trace("Wrong team type passed to [type] initialization.")
	team = new_team

/datum/antagonist/brother/get_team()
	return team

/datum/antagonist/brother/on_gain()
	SSticker.mode.brothers += owner
	objectives += team.objectives
	for(var/datum/objective/O in team.objectives)
		log_objective(owner, O.explanation_text)
	owner.special_role = ROLE_BROTHER
	finalize_brother()
	return ..()

/datum/antagonist/brother/on_removal()
	SSticker.mode.brothers -= owner
	if(owner.current)
		to_chat(owner.current,"<span class='userdanger'>Nie jesteś już bratem krwi!</span>")
	owner.special_role = null
	return ..()

/datum/antagonist/brother/antag_panel_data()
	return "Conspirators : [get_brother_names()]"

/datum/antagonist/brother/proc/get_brother_names()
	var/list/brothers = team.members - owner
	var/brother_text = ""
	for(var/i = 1 to brothers.len)
		var/datum/mind/M = brothers[i]
		brother_text += M.name
		if(i == brothers.len - 1)
			brother_text += " and "
		else if(i != brothers.len)
			brother_text += ", "
	return brother_text

/datum/antagonist/brother/proc/give_meeting_area()
	if(!owner.current || !team || !team.meeting_area)
		return
	to_chat(owner.current, "<B>Wyznaczone miejsce spotkania:</B> [team.meeting_area]")
	antag_memory += "<b>Miejsce spotkania</b>: [team.meeting_area]<br>"

/datum/antagonist/brother/greet()
	var/brother_text = get_brother_names()
	to_chat(owner.current, "<span class='alertsyndie'>Jesteś bratem krwi: [brother_text].</span>")
	to_chat(owner.current, "Syndykat przyjmuje tylko tych, którzy się wykazali. Wykaż się ty i twoi bracia, wykonując wspólnie cele! Ty i twoja drużyna macie implanty komunikacyjne do bezpośredniej, szyfrowanej łączności.")
	owner.announce_objectives()
	give_meeting_area()
	owner.current.client?.tgui_panel?.give_antagonist_popup("Brat krwi",
		"Syndykat przyjmuje tylko tych, którzy się wykazali. Wykaż się ty i twoi bracia, wykonując wspólnie cele!")

/datum/antagonist/brother/proc/finalize_brother()
	var/obj/item/implant/bloodbrother/I = new /obj/item/implant/bloodbrother()
	I.implant(owner.current, null, TRUE, TRUE)
	I.implant_colour = team.team_id <= 9 ? COLOR_LIST_BLOOD_BROTHERS[team.team_id] : "#ff0000"
	for(var/datum/mind/M in team.members) // Link the implants of all team members
		var/obj/item/implant/bloodbrother/T = locate() in M.current.implants
		I.link_implant(T)
	SSticker.mode.update_brother_icons_added(owner)
	owner.current.playsound_local(get_turf(owner.current), 'sound/ambience/antag/tatoralert.ogg', 100, FALSE, pressure_affected = FALSE, use_reverb = FALSE)

/datum/antagonist/brother/admin_add(datum/mind/new_owner,mob/admin)
	//show list of possible brothers
	var/list/candidates = list()
	for(var/mob/living/L in GLOB.player_list)
		if(!L.mind || L.mind == new_owner || !can_be_owned(L.mind))
			continue
		candidates += L.mind

	var/choice = input(admin,"Wybierz brata krwi.", "Brother") as null|anything in sortNames(candidates)
	if(!choice)
		return
	var/datum/mind/bro = choice
	var/datum/team/brother_team/T = new
	T.add_member(new_owner)
	T.add_member(bro)
	T.pick_meeting_area()
	T.forge_brother_objectives()
	new_owner.add_antag_datum(/datum/antagonist/brother,T)
	bro.add_antag_datum(/datum/antagonist/brother, T)
	T.update_name()
	message_admins("[key_name_admin(admin)] made [key_name_admin(new_owner)] and [key_name_admin(bro)] into blood brothers.")
	log_admin("[key_name(admin)] made [key_name(new_owner)] and [key_name(bro)] into blood brothers.")

/datum/team/brother_team
	name = "brotherhood"
	member_name = "brat krwi"
	var/team_id
	var/meeting_area
	var/static/meeting_areas = list("Bar", "Kwatery", "Dok ewakuacyjny", "Hala przylotów", "Holodek", "Główny magazyn narzędzi", "Strefa rekreacji", "Kaplica", "Biblioteka")

/datum/team/brother_team/New(starting_members)
	. = ..()
	var/static/blood_teams
	team_id = ++blood_teams

/datum/team/brother_team/is_solo()
	return FALSE

/datum/team/brother_team/proc/pick_meeting_area()
	meeting_area = pick(meeting_areas)
	meeting_areas -= meeting_area

/datum/team/brother_team/proc/update_name()
	var/list/last_names = list()
	for(var/datum/mind/M in members)
		var/list/split_name = splittext(M.name," ")
		last_names += split_name[split_name.len]

	name = last_names.Join(" & ")

/datum/team/brother_team/roundend_report()
	var/list/parts = list()

	parts += "<span class='header'>Bracia krwi z drużyny [name]:</span>"
	for(var/datum/mind/M in members)
		parts += printplayer(M)
	var/win = TRUE
	var/objective_count = 1
	for(var/datum/objective/objective in objectives)
		if(objective.check_completion())
			parts += "<B>Cel nr [objective_count]</B>: [objective.explanation_text] <span class='greentext'>Sukces!</span>"
		else
			parts += "<B>Cel nr [objective_count]</B>: [objective.explanation_text] <span class='redtext'>Porażka.</span>"
			win = FALSE
		objective_count++
	if(win)
		parts += "<span class='greentext'>Bracia krwi odnieśli sukces!</span>"
	else
		parts += "<span class='redtext'>Bracia krwi ponieśli porażkę!</span>"

	return "<div class='panel redborder'>[parts.Join("<br>")]</div>"

/datum/team/brother_team/proc/add_objective(datum/objective/O, needs_target = FALSE)
	O.team = src
	if(needs_target)
		O.find_target(dupe_search_range = list(src))
	O.update_explanation_text()
	objectives += O
	for(var/datum/mind/member in members)
		log_objective(member, O.explanation_text)

/datum/team/brother_team/proc/forge_brother_objectives()
	objectives = list()
	var/is_hijacker = prob(10)
	for(var/i = 1 to max(1, CONFIG_GET(number/brother_objectives_amount) + (members.len > 2) - is_hijacker))
		forge_single_objective()
	if(is_hijacker)
		if(!locate(/datum/objective/hijack) in objectives)
			add_objective(new/datum/objective/hijack)
	else if(!locate(/datum/objective/escape) in objectives)
		add_objective(new/datum/objective/escape)

/datum/team/brother_team/proc/forge_single_objective()
	if(prob(50))
		if(LAZYLEN(active_ais()) && prob(100/GLOB.joined_player_list.len))
			add_objective(new/datum/objective/destroy, TRUE)
		else if(prob(30))
			add_objective(new/datum/objective/maroon, TRUE)
		else
			add_objective(new/datum/objective/assassinate, TRUE)
	else
		add_objective(new/datum/objective/steal, TRUE)

/datum/team/brother_team/antag_listing_name()
	return "bracia krwi [name]"
