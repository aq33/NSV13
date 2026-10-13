/datum/game_mode
	var/list/datum/mind/brothers = list()
	var/list/datum/team/brother_team/brother_teams = list()

/datum/game_mode/traitor/bros
	name = "traitor+brothers"
	config_tag = "traitorbro"
	restricted_jobs = list(JOB_NAME_AI, JOB_NAME_CYBORG)

	announce_span = "danger"
	announce_text = "Na stacji są agenci Syndykatu i Bracia Krwi!\n<span class='danger'>Zdrajcy</span>: wykonajcie swoje cele.\n<span class='danger'>Bracia Krwi</span>: wykonajcie swoje cele.\n<span class='notice'>Załoga</span>: nie pozwólcie zdrajcom ani braciom odnieść sukcesu!"

	var/list/datum/team/brother_team/pre_brother_teams = list()
	var/const/team_amount = 2 //hard limit on brother teams if scaling is turned off
	var/const/min_team_size = 2
	num_modifier = -4 //Takes out the average number of default traitors to prevent an excessive number of antags at low pops
	traitors_required = FALSE //Only teams are possible

/datum/game_mode/traitor/bros/pre_setup()
	if(CONFIG_GET(flag/protect_roles_from_antagonist))
		restricted_jobs += protected_jobs
	if(CONFIG_GET(flag/protect_assistant_from_antagonist))
		restricted_jobs += JOB_NAME_ASSISTANT
	if(CONFIG_GET(flag/protect_heads_from_antagonist))
		restricted_jobs += GLOB.command_positions

	var/list/datum/mind/possible_brothers = get_players_for_role(/datum/antagonist/brother, /datum/role_preference/antagonist/blood_brother)

	var/num_teams = team_amount
	var/bsc = CONFIG_GET(number/brother_scaling_coeff)
	if(bsc)
		num_teams = max(1, round(num_players() / bsc))
	// AQUILA EDIT START - weighted rotation antagonist limit, brothers and traitors together
	var/brothers_picked = 0
	if(!isnull(weighted_antag_cap))
		num_teams = min(num_teams, max(1, round(weighted_antag_cap / min_team_size)))
	// AQUILA EDIT END

	for(var/j = 1 to num_teams)
		if(possible_brothers.len < min_team_size || antag_candidates.len <= required_enemies)
			break
		// AQUILA EDIT START - no team that would go over the weighted rotation limit
		if(!isnull(weighted_antag_cap) && weighted_antag_cap - brothers_picked < min_team_size)
			break
		// AQUILA EDIT END
		var/datum/team/brother_team/team = new
		var/team_size = prob(10) ? min(3, possible_brothers.len) : 2
		// AQUILA EDIT START
		if(!isnull(weighted_antag_cap))
			team_size = min(team_size, weighted_antag_cap - brothers_picked)
		brothers_picked += team_size
		// AQUILA EDIT END
		for(var/k = 1 to team_size)
			var/datum/mind/bro = antag_pick(possible_brothers, /datum/role_preference/antagonist/blood_brother)
			possible_brothers -= bro
			antag_candidates -= bro
			team.add_member(bro)
			bro.special_role = "brother"
			bro.restricted_roles = restricted_jobs
			log_game("[key_name(bro)] has been selected as a Brother")
		pre_brother_teams += team
	if(!isnull(weighted_antag_cap)) // AQUILA EDIT - traitors only get what the brothers left of the limit
		weighted_antag_cap = max(0, weighted_antag_cap - brothers_picked)
	return ..()

/datum/game_mode/traitor/bros/post_setup()
	for(var/datum/team/brother_team/team in pre_brother_teams)
		team.pick_meeting_area()
		team.forge_brother_objectives()
		for(var/datum/mind/M in team.members)
			M.add_antag_datum(/datum/antagonist/brother, team)
		team.update_name()
	brother_teams += pre_brother_teams
	return ..()

/datum/game_mode/traitor/bros/generate_report()
	return "W tym miesiącu wypada sezon rekrutacyjny Syndykatu. Bądźcie czujni na potencjalnych infiltratorów Syndykatu oraz niezadowolonych pracowników, którzy starają się uciec. W przeciwieństwie do Nanotrasenu, Syndykat szczyci się pracą zespołową i będzie rekrutował tylko te pary, które mają wspólne, braterskie zaufanie."

/datum/game_mode/proc/update_brother_icons_added(datum/mind/brother_mind)
	var/datum/atom_hud/antag/brotherhud = GLOB.huds[ANTAG_HUD_BROTHER]
	brotherhud.join_hud(brother_mind.current)
	set_antag_hud(brother_mind.current, "brother")

/datum/game_mode/proc/update_brother_icons_removed(datum/mind/brother_mind)
	var/datum/atom_hud/antag/brotherhud = GLOB.huds[ANTAG_HUD_BROTHER]
	brotherhud.leave_hud(brother_mind.current)
	set_antag_hud(brother_mind.current, null)
