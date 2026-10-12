// AQUILA - demon impulsu w midroundzie dynamica (port z ParadiseSS13)

/datum/dynamic_ruleset/midround/from_ghosts/pulse_demon
	name = "Pulse Demon"
	midround_ruleset_style = MIDROUND_RULESET_STYLE_LIGHT
	antag_datum = /datum/antagonist/pulse_demon
	role_preference = /datum/role_preference/midround_ghost/pulse_demon
	enemy_roles = list(
		JOB_NAME_CAPTAIN,
		JOB_NAME_CHIEFENGINEER,
		JOB_NAME_HEADOFSECURITY,
		JOB_NAME_SECURITYOFFICER,
		JOB_NAME_STATIONENGINEER,
	)
	required_enemies = list(2,2,1,1,1,1,1,0,0,0)
	required_candidates = 1
	weight = 3
	cost = 5
	minimum_players = 10
	repeatable = TRUE
	var/list/spawn_locs = list()

/datum/dynamic_ruleset/midround/from_ghosts/pulse_demon/execute()
	spawn_locs = pulse_demon_spawn_locations()
	if(!length(spawn_locs))
		log_game("DYNAMIC: [ruletype] ruleset [name] execute failed due to no powered cables.")
		return FALSE
	return ..()

/// Antagonistę dodaje finish_setup()
/datum/dynamic_ruleset/midround/from_ghosts/pulse_demon/generate_ruleset_body(mob/applicant)
	var/mob/living/simple_animal/pulse_demon/demon = create_pulse_demon(applicant.key, pick(spawn_locs), give_antag = FALSE)
	message_admins("[ADMIN_LOOKUPFLW(demon)] has been made into a pulse demon by the midround ruleset.")
	log_game("DYNAMIC: [key_name(demon)] was spawned as a pulse demon by the midround ruleset.")
	return demon
