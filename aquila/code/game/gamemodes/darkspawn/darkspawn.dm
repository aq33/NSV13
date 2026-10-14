// AQUILA - tryb darkspawn (port z Yogstation)

/datum/game_mode/darkspawn
	name = "darkspawn"
	config_tag = "darkspawn"
	report_type = "darkspawn"
	role_preference = /datum/role_preference/antagonist/darkspawn
	antag_datum = /datum/antagonist/darkspawn
	false_report_weight = 5
	required_players = 25
	required_enemies = 2
	recommended_enemies = 3
	restricted_jobs = list(JOB_NAME_AI, JOB_NAME_CYBORG)
	protected_jobs = list(JOB_NAME_SECURITYOFFICER, JOB_NAME_WARDEN, JOB_NAME_DETECTIVE, JOB_NAME_HEADOFSECURITY, JOB_NAME_CAPTAIN, JOB_NAME_HEADOFPERSONNEL, JOB_NAME_RESEARCHDIRECTOR, JOB_NAME_CHIEFENGINEER, JOB_NAME_CHIEFMEDICALOFFICER, JOB_NAME_BRIGPHYSICIAN, JOB_NAME_PILOT, JOB_NAME_MASTERATARMS)
	title_icon = "ss13"

	announce_span = "velvet"
	announce_text = "Na pokładzie są obcy <span class='velvet'>darkspawni</span>!\n\
	<span class='velvet'>Darkspawni</span>: Pożerajcie wolę załogi, zbierzcie lucidity i odprawcie Sakrament.\n\
	<span class='notice'>Załoga</span>: Zabijcie darkspawnów, zanim odprawią Sakrament. Trzymajcie się światła!"

	var/list/datum/mind/pre_darkspawn = list()

/datum/game_mode/darkspawn/pre_setup()
	if(CONFIG_GET(flag/protect_roles_from_antagonist))
		restricted_jobs += protected_jobs
	if(CONFIG_GET(flag/protect_assistant_from_antagonist))
		restricted_jobs += JOB_NAME_ASSISTANT

	var/num_darkspawn = weighted_cap(max(required_enemies, round(num_players() / 14)))
	for(var/i in 1 to num_darkspawn)
		if(!length(antag_candidates))
			break
		var/datum/mind/darkspawn_mind = antag_pick(antag_candidates, role_preference)
		pre_darkspawn += darkspawn_mind
		antag_candidates -= darkspawn_mind
		darkspawn_mind.special_role = ROLE_DARKSPAWN
		darkspawn_mind.restricted_roles = restricted_jobs
		log_game("[key_name(darkspawn_mind)] has been selected as a darkspawn")
	if(!length(pre_darkspawn))
		setup_error = "Not enough darkspawn candidates"
		return FALSE
	get_darkspawn_team().set_required_succs(num_players())
	return TRUE

/datum/game_mode/darkspawn/post_setup()
	for(var/datum/mind/darkspawn_mind in pre_darkspawn)
		darkspawn_mind.add_antag_datum(/datum/antagonist/darkspawn, get_darkspawn_team())
	return ..()

/datum/game_mode/darkspawn/generate_report()
	return "W waszym sektorze zaobserwowano dziwne obce istoty. Wygląda na to, że szukają konkretnych wzorców aktywności mózgu, \
	a ofiary ich poszukiwań zapadają w krótką śpiączkę. Uważajcie na ciemne miejsca i dbajcie o sprawne oświetlenie. \
	Sprawdzajcie każde zgłoszenie dziwnych obserwacji w technicznych i miejcie oko na każdego, kto mógłby sympatyzować z tymi istotami."

/datum/game_mode/darkspawn/check_finished()
	. = ..()
	if(.)
		return
	var/datum/team/darkspawn/team = GLOB.darkspawn_team
	if(team && !GLOB.sacrament_done && team.check_darkspawn_death())
		return TRUE

/datum/game_mode/darkspawn/set_round_result()
	..()
	if(GLOB.sacrament_done)
		SSticker.mode_result = "win - the darkspawn have completed the Sacrament"
	else
		SSticker.mode_result = "loss - staff stopped the darkspawn"

/datum/game_mode/darkspawn/generate_credit_text()
	var/list/round_credits = list()
	round_credits += "<center><h1>Darkspawni:</h1>"
	var/len_before_addition = round_credits.len
	for(var/datum/mind/darkspawn_mind as anything in GLOB.darkspawn_team?.members)
		round_credits += "<center><h2>[darkspawn_mind.name] jako darkspawn</h2>"
	if(len_before_addition == round_credits.len)
		round_credits += list("<center><h2>Darkspawni skryli się w cieniach!</h2>", "<center><h2>Nie udało się ich znaleźć!</h2>")
	round_credits += "<br>"
	round_credits += ..()
	return round_credits
