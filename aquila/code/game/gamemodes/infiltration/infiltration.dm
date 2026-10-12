/datum/game_mode/infiltration
	name = "infiltration"
	config_tag = "infiltration"
	false_report_weight = 10
	required_players = 25
	required_enemies = 3
	recommended_enemies = 5
	role_preference = /datum/role_preference/antagonist/infiltrator
	antag_datum = /datum/antagonist/infiltrator
	//antag_flag = ROLE_INFILTRATOR

	announce_span = "danger"
	announce_text = "Infiltratorzy Syndykatu próbują dostać się na statek!\n\
	<span class='danger'>Infiltratorzy</span>: dostańcie się po cichu na statek i wykonajcie cele!\n\
	<span class='notice'>Załoga</span>: nie pozwólcie infiltratorom wykonać celów!"

	var/agents_possible = 5
	var/agents_left = 1
	var/list/pre_sit = list()

	var/datum/team/infiltrator/sit_team

	var/static/list/areas_that_can_finish = typecacheof(list(/area/shuttle/stealthcruiser, /area/syndicate_mothership/infiltrator_base))

/datum/game_mode/infiltration/pre_setup()
	var/n_agents = min(max(CEILING(num_players() / 7, 1), 1), antag_candidates.len, agents_possible)
	if(GLOB.Debug2 || n_agents >= required_enemies)
		for(var/i = 0, i < n_agents, ++i)
			var/datum/mind/new_sit = pick_n_take(antag_candidates)
			pre_sit += new_sit
			new_sit.assigned_role = "Syndicate Infiltrator"
			new_sit.special_role = "Syndicate Infiltrator"
			log_game("[key_name(new_sit)] has been selected as a syndicate infiltrator")
		return TRUE
	setup_error = "Not enough infiltrator candidates"
	message_admins("Not enough infiltrator candidates! Was making [n_agents], but we need [required_enemies]!")
	return FALSE

/datum/game_mode/infiltration/post_setup()
	sit_team = new /datum/team/infiltrator
	for(var/datum/mind/sit_mind in pre_sit)
		sit_mind.add_antag_datum(ANTAG_DATUM_INFILTRATOR, sit_team)
	sit_team.update_objectives()
	return ..()

/datum/game_mode/infiltration/generate_report() //make this less shit
	return "Raporty wskazują, że Syndykat zbiera elitarnych agentów, być może do napadu na stację kontrolowaną przez Nanotrasen. Miejcie oko na nietypowe osoby."

/datum/game_mode/infiltration/set_round_result()
	..()
	var/result = sit_team.get_result()
	switch(result)
		if(INFILTRATION_ALLCOMPLETE)
			SSticker.mode_result = "major win - objectives complete"
		if(INFILTRATION_MOSTCOMPLETE)
			SSticker.mode_result = "minor win - most objectives complete"
		if(INFILTRATION_SOMECOMPLETE)
			SSticker.mode_result = "neutral - some objectives complete"
		else
			SSticker.mode_result = "loss - no objectives complete"
