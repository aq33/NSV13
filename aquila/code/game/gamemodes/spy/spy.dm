// AQUILA - Spy secret game mode, built like /datum/game_mode/traitor (spies from tgstation, a roundstart dynamic ruleset there)

/datum/game_mode/spy
	name = "spy"
	config_tag = "spy"
	report_type = "spy"
	role_preference = /datum/role_preference/antagonist/spy
	antag_datum = /datum/antagonist/spy
	false_report_weight = 10
	restricted_jobs = list(JOB_NAME_AI, JOB_NAME_CYBORG)
	protected_jobs = list(JOB_NAME_SECURITYOFFICER, JOB_NAME_WARDEN, JOB_NAME_HEADOFSECURITY, JOB_NAME_CAPTAIN, JOB_NAME_DETECTIVE, JOB_NAME_PRISONER, JOB_NAME_PILOT, JOB_NAME_MASTERATARMS)
	required_players = 0
	required_enemies = 1
	recommended_enemies = 3
	reroll_friendly = 1

	announce_span = "danger"
	announce_text = "Na statku działają szpiedzy!\n\
	<span class='danger'>Szpiedzy</span>: Kradnijcie cele zleceń i odbierajcie nagrody!\n\
	<span class='notice'>Załoga</span>: Pilnujcie sprzętu, maszyn i siebie nawzajem!"

	title_icon = "traitor"

	var/list/datum/mind/pre_spies = list()
	var/spies_possible = 3 //hard limit on spies if scaling is turned off

/datum/game_mode/spy/pre_setup()
	if(CONFIG_GET(flag/protect_roles_from_antagonist))
		restricted_jobs += protected_jobs

	if(CONFIG_GET(flag/protect_assistant_from_antagonist))
		restricted_jobs += JOB_NAME_ASSISTANT

	if(CONFIG_GET(flag/protect_heads_from_antagonist))
		restricted_jobs += GLOB.command_positions

	var/num_spies = 1

	var/tsc = CONFIG_GET(number/traitor_scaling_coeff)
	if(tsc)
		num_spies = max(1, min(round(num_players() / (tsc * 2)) + 1, round(num_players() / tsc)))
	else
		num_spies = max(1, min(num_players(), spies_possible))

	for(var/j = 0, j < num_spies, j++)
		if(!antag_candidates.len)
			break
		var/datum/mind/spy = antag_pick(antag_candidates, role_preference)
		pre_spies += spy
		spy.special_role = ROLE_SPY
		spy.restricted_roles = restricted_jobs
		log_game("[key_name(spy)] has been selected as a spy")
		antag_candidates.Remove(spy)

	if(!pre_spies.len)
		setup_error = "Not enough spy candidates"
		return FALSE
	return TRUE

/datum/game_mode/spy/post_setup()
	for(var/datum/mind/spy in pre_spies)
		addtimer(CALLBACK(spy, TYPE_PROC_REF(/datum/mind, add_antag_datum), antag_datum), rand(10,100))
	..()

	//We're not actually ready until all spies are assigned.
	gamemode_ready = FALSE
	addtimer(VARSET_CALLBACK(src, gamemode_ready, TRUE), 101)
	return TRUE

/datum/game_mode/spy/generate_report()
	return "Z naszych danych wynika, że na statkach Nanotrasenu działają szpiedzy na zlecenie nieznanego zleceniodawcy. \
	Kradną sprzęt, maszyny, roboty, a nawet organy członków załogi. Łupy trafiają na czarny rynek. Pilnujcie swojego dobytku."
