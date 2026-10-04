// AQUILA - Paradox Clone dynamic midround ruleset (tgstation#71141, with the tgstation#74989 cloning fix)

/datum/dynamic_ruleset/midround/from_ghosts/paradox_clone
	name = "Paradox Clone"
	midround_ruleset_style = MIDROUND_RULESET_STYLE_LIGHT
	antag_datum = /datum/antagonist/paradox_clone
	role_preference = /datum/role_preference/midround_ghost/paradox_clone
	enemy_roles = list(
		JOB_NAME_CAPTAIN,
		JOB_NAME_DETECTIVE,
		JOB_NAME_HEADOFSECURITY,
		JOB_NAME_SECURITYOFFICER,
		JOB_NAME_WARDEN,
	)
	required_enemies = list(2,2,1,1,1,1,1,0,0,0)
	required_candidates = 1
	weight = 4
	cost = 3
	repeatable = TRUE
	///places the antag can spawn
	var/list/possible_spawns = list()

/datum/dynamic_ruleset/midround/from_ghosts/paradox_clone/ready(forced = FALSE)
	if(!forced && !CONFIG_GET(flag/paradox_clone_enabled))
		return FALSE
	if(!paradox_clone_find_original())
		log_game("DYNAMIC: FAIL: [src] is not ready, because there is no crew member to clone.")
		return FALSE
	return ..()

/datum/dynamic_ruleset/midround/from_ghosts/paradox_clone/execute()
	possible_spawns = paradox_clone_spawn_locations()
	if(!length(possible_spawns))
		message_admins("No valid spawn locations found for Paradox Clone ruleset, aborting...")
		log_game("DYNAMIC: [ruletype] ruleset [name] execute failed due to no valid spawn locations.")
		return FALSE
	return ..()

/datum/dynamic_ruleset/midround/from_ghosts/paradox_clone/generate_ruleset_body(mob/applicant)
	var/mob/living/carbon/human/original = paradox_clone_find_original()
	if(!original)
		message_admins("The [name] ruleset found no crew member to clone after polling, [key_name_admin(applicant)] was not spawned.")
		log_game("DYNAMIC: [name] found no crew member to clone after polling.")
		return applicant
	return create_paradox_clone(applicant.key, original, pick(possible_spawns), "the midround ruleset")

/// The antag datum is already given (and set up with its original) in generate_ruleset_body()
/datum/dynamic_ruleset/midround/from_ghosts/paradox_clone/finish_setup(mob/new_character, index)
	return
