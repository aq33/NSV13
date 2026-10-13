// AQUILA - demon cieni w midroundzie dynamica (port z ParadiseSS13), zastępuje ruleset koszmara

/datum/dynamic_ruleset/midround/from_ghosts/shadow_demon
	name = "Shadow Demon"
	midround_ruleset_style = MIDROUND_RULESET_STYLE_LIGHT
	antag_datum = /datum/antagonist/shadow_demon
	role_preference = /datum/role_preference/midround_ghost/shadow_demon
	enemy_roles = list(
		JOB_NAME_CAPTAIN,
		JOB_NAME_DETECTIVE,
		JOB_NAME_HEADOFSECURITY,
		JOB_NAME_SECURITYOFFICER,
		JOB_NAME_WARDEN,
	)
	required_enemies = list(2,2,1,1,1,1,1,0,0,0)
	required_candidates = 1
	weight = 3
	cost = 5
	minimum_players = 15
	repeatable = TRUE
	var/list/spawn_locs = list()

/datum/dynamic_ruleset/midround/from_ghosts/shadow_demon/execute()
	spawn_locs = shadow_demon_spawn_locations()
	if(!length(spawn_locs))
		log_game("DYNAMIC: [ruletype] ruleset [name] execute failed due to no valid spawn locations.")
		return FALSE
	return ..()

/// Antagonistę dodaje finish_setup()
/datum/dynamic_ruleset/midround/from_ghosts/shadow_demon/generate_ruleset_body(mob/applicant)
	var/mob/living/simple_animal/shadow_demon/demon = create_shadow_demon(applicant.key, pick(spawn_locs), give_antag = FALSE)
	message_admins("[ADMIN_LOOKUPFLW(demon)] has been made into a shadow demon by the midround ruleset.")
	log_game("DYNAMIC: [key_name(demon)] was spawned as a shadow demon by the midround ruleset.")
	return demon
