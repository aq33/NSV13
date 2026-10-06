// AQUILA - Thief secret game mode, built like /datum/game_mode/traitor (thieves from tgstation#64144)

/datum/game_mode/thief
	name = "thief"
	config_tag = "thief"
	report_type = "thief"
	role_preference = /datum/role_preference/antagonist/thief
	antag_datum = /datum/antagonist/thief
	false_report_weight = 10
	restricted_jobs = list(JOB_NAME_AI, JOB_NAME_CYBORG)
	protected_jobs = list(JOB_NAME_SECURITYOFFICER, JOB_NAME_WARDEN, JOB_NAME_HEADOFSECURITY, JOB_NAME_CAPTAIN, JOB_NAME_DETECTIVE, JOB_NAME_PRISONER, JOB_NAME_PILOT, JOB_NAME_MASTERATARMS)
	required_players = 0
	required_enemies = 1
	recommended_enemies = 4
	reroll_friendly = 1

	announce_span = "danger"
	announce_text = "Na stacji grasują złodzieje!\n\
	<span class='danger'>Złodzieje</span>: Ukradnijcie swoje łupy i uciekajcie, bez zabijania!\n\
	<span class='notice'>Załoga</span>: Pilnujcie swojego dobytku!"

	title_icon = "traitor"

	var/list/datum/mind/pre_thieves = list()
	var/thieves_possible = 4 //hard limit on thieves if scaling is turned off

/datum/game_mode/thief/pre_setup()
	if(CONFIG_GET(flag/protect_roles_from_antagonist))
		restricted_jobs += protected_jobs

	if(CONFIG_GET(flag/protect_assistant_from_antagonist))
		restricted_jobs += JOB_NAME_ASSISTANT

	if(CONFIG_GET(flag/protect_heads_from_antagonist))
		restricted_jobs += GLOB.command_positions

	var/num_thieves = 1

	var/tsc = CONFIG_GET(number/traitor_scaling_coeff)
	if(tsc)
		num_thieves = max(1, min(round(num_players() / (tsc * 2)) + 2, round(num_players() / tsc)))
	else
		num_thieves = max(1, min(num_players(), thieves_possible))

	for(var/j = 0, j < num_thieves, j++)
		if(!antag_candidates.len)
			break
		var/datum/mind/thief = antag_pick(antag_candidates, role_preference)
		pre_thieves += thief
		thief.special_role = ROLE_THIEF
		thief.restricted_roles = restricted_jobs
		log_game("[key_name(thief)] has been selected as a thief")
		antag_candidates.Remove(thief)

	if(!pre_thieves.len)
		setup_error = "Not enough thief candidates"
		return FALSE
	return TRUE

/datum/game_mode/thief/post_setup()
	for(var/datum/mind/thief in pre_thieves)
		addtimer(CALLBACK(thief, TYPE_PROC_REF(/datum/mind, add_antag_datum), antag_datum), rand(10,100))
	..()

	//We're not actually ready until all thieves are assigned.
	gamemode_ready = FALSE
	addtimer(VARSET_CALLBACK(src, gamemode_ready, TRUE), 101)
	return TRUE

/// Number of minds that currently are thieves
/datum/game_mode/thief/proc/count_thieves()
	. = 0
	for(var/datum/antagonist/thief/thief in GLOB.antagonists)
		if(thief.owner)
			.++

/datum/game_mode/thief/make_antag_chance(mob/living/carbon/human/character) //Assigns thief to latejoiners
	var/tsc = CONFIG_GET(number/traitor_scaling_coeff)
	if(!tsc)
		return
	var/thiefcap = min(round(GLOB.joined_player_list.len / (tsc * 2)) + 2, round(GLOB.joined_player_list.len / tsc))
	var/thief_count = count_thieves()
	if(thief_count >= thiefcap) //Upper cap for number of latejoin antagonists
		return
	if(thief_count <= (thiefcap - 2) || prob(100 / (tsc * 2)))
		if(!QDELETED(character) && character.client?.should_include_for_role(
			banning_key = initial(antag_datum.banning_key),
			role_preference_key = role_preference,
			req_hours = initial(antag_datum.required_living_playtime),
		))
			if(!(character.job in restricted_jobs))
				character.mind.add_antag_datum(antag_datum)

/datum/game_mode/thief/generate_report()
	return "Z naszych danych wynika, że ostatnio na stacjach Nanotrasenu nasiliły się kradzieże cennego sprzętu, organów i pamiątek. Sprawcami mogą być członkowie waszej własnej załogi. Pilnujcie swojego dobytku."
