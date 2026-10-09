// AQUILA - Traitor+Horror secret game mode, built like /datum/game_mode/traitor/changeling.
// Eldritch Horrors (Yogstation#13033) are a ghost role upstream, so here the picked players skip their job
// and get swapped into a horror at an event spawn point in post_setup().

/datum/game_mode/traitor/horror
	name = "traitor+horror"
	config_tag = "traitorhorror"
	report_type = "traitorhorror"
	false_report_weight = 10
	traitors_possible = 3 //hard limit on traitors if scaling is turned off
	restricted_jobs = list(JOB_NAME_AI, JOB_NAME_CYBORG)
	required_players = 10
	required_enemies = 1	// how many of each type are required
	recommended_enemies = 3
	reroll_friendly = 1
	title_icon = "traitor"

	var/list/horrors = list()
	var/const/horror_amount = 1 //hard limit on horrors if scaling is turned off

/datum/game_mode/traitor/horror/announce()
	to_chat(world, "<B>Obecny tryb gry to Zdrajcy+Horror!</B>")
	to_chat(world, "<B>Po stacji pełzają pradawne horrory, a do tego działają tu agenci Syndykatu! Nie pozwólcie ani horrorom, ani zdrajcom osiągnąć celu!</B>")

/datum/game_mode/traitor/horror/can_start()
	if(!..())
		return FALSE
	if(!length(horror_spawn_locations()))
		return FALSE
	var/list/possible_horrors = get_players_for_role(/datum/antagonist/horror, /datum/role_preference/antagonist/horror)
	if(possible_horrors.len < required_enemies)
		return FALSE
	return TRUE

/datum/game_mode/traitor/horror/pre_setup()
	var/list/datum/mind/possible_horrors = get_players_for_role(/datum/antagonist/horror, /datum/role_preference/antagonist/horror)

	var/num_horrors = 1

	var/tsc = CONFIG_GET(number/traitor_scaling_coeff)
	if(tsc)
		num_horrors = max(1, min(round(num_players() / (tsc * 4)) + 2, round(num_players() / (tsc * 2))))
	else
		num_horrors = max(1, min(num_players(), horror_amount))

	if(!possible_horrors.len)
		return FALSE
	for(var/j = 0, j < num_horrors, j++)
		if(!possible_horrors.len)
			break
		var/datum/mind/horror = antag_pick(possible_horrors, /datum/role_preference/antagonist/horror)
		antag_candidates -= horror
		possible_horrors -= horror
		// Same assigned_role and special_role: no job gets picked and the ticker skips their equipment
		horror.assigned_role = ROLE_HORROR
		horror.special_role = ROLE_HORROR
		horrors += horror
		log_game("[key_name(horror)] has been selected as an eldritch horror")
	return ..()

/datum/game_mode/traitor/horror/post_setup()
	var/list/spawn_locs = horror_spawn_locations()
	for(var/datum/mind/horror_mind in horrors)
		var/mob/living/old_body = horror_mind.current
		var/mob/living/simple_animal/horror/H = new(pick(spawn_locs))
		horror_mind.transfer_to(H, TRUE) // force the key, a player who dropped before roundstart would come back to the deleted body
		if(old_body)
			qdel(old_body)
	// Only now, so no horror picks another one (still human above) as the antagonist it has to protect
	for(var/datum/mind/horror_mind in horrors)
		var/mob/living/simple_animal/horror/H = horror_mind.current
		horror_mind.add_antag_datum(/datum/antagonist/horror)
		to_chat(H, H.playstyle_string)
		SEND_SOUND(H, sound('sound/hallucinations/growl2.ogg'))
	return ..()

/datum/game_mode/traitor/horror/generate_report()
	return "Otrzymaliśmy niejasne raporty o pasożytniczych istotach wpełzających ludziom do głów. \
			Zaawansowany analizator zdrowia wykrywa je w czaszce, a usunąć je można chirurgicznie. Uważajcie też na agentów Syndykatu."
