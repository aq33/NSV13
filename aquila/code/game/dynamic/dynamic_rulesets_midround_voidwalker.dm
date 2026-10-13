// AQUILA - wędrowiec pustki w midroundzie dynamica (port z tgstation)

/datum/dynamic_ruleset/midround/from_ghosts/voidwalker
	name = "Voidwalker"
	midround_ruleset_style = MIDROUND_RULESET_STYLE_LIGHT
	antag_datum = /datum/antagonist/voidwalker
	role_preference = /datum/role_preference/midround_ghost/voidwalker
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
	repeatable = FALSE
	var/turf/spawn_loc

/datum/dynamic_ruleset/midround/from_ghosts/voidwalker/execute()
	spawn_loc = find_voidwalker_spawn()
	if(!spawn_loc)
		log_game("DYNAMIC: [ruletype] ruleset [name] execute failed due to no valid spawn locations.")
		return FALSE
	return ..()

/// Antagonistę dodaje finish_setup()
/datum/dynamic_ruleset/midround/from_ghosts/voidwalker/generate_ruleset_body(mob/applicant)
	var/mob/living/simple_animal/hostile/voidwalker/walker = create_voidwalker(applicant.key, spawn_loc, give_antag = FALSE)
	message_admins("[ADMIN_LOOKUPFLW(walker)] has been made into a voidwalker by the midround ruleset.")
	log_game("DYNAMIC: [key_name(walker)] was spawned as a voidwalker by the midround ruleset.")
	return walker
