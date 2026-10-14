// AQUILA - darkspawn w dynamicu (port z Yogstation)

/datum/dynamic_ruleset/roundstart/darkspawn
	name = "Darkspawn"
	role_preference = /datum/role_preference/antagonist/darkspawn
	antag_datum = /datum/antagonist/darkspawn
	restricted_roles = list(JOB_NAME_AI, JOB_NAME_CYBORG)
	protected_roles = list(JOB_NAME_SECURITYOFFICER, JOB_NAME_WARDEN, JOB_NAME_DETECTIVE, JOB_NAME_HEADOFSECURITY, JOB_NAME_CAPTAIN, JOB_NAME_HEADOFPERSONNEL, JOB_NAME_RESEARCHDIRECTOR, JOB_NAME_CHIEFENGINEER, JOB_NAME_CHIEFMEDICALOFFICER, JOB_NAME_BRIGPHYSICIAN)
	required_candidates = 2
	weight = 3
	cost = 20
	requirements = list(101,101,101,80,60,50,30,20,10,10)
	flags = HIGH_IMPACT_RULESET
	antag_cap = list("denominator" = 14, "offset" = 1)

/datum/dynamic_ruleset/roundstart/darkspawn/ready(population, forced = FALSE)
	required_candidates = max(2, get_antag_cap(population))
	return ..()

/datum/dynamic_ruleset/roundstart/darkspawn/pre_execute(population)
	. = ..()
	var/num_darkspawn = max(2, get_antag_cap(population))
	for(var/i in 1 to num_darkspawn)
		if(!length(candidates))
			break
		var/mob/M = pick_n_take(candidates)
		assigned += M.mind
		M.mind.special_role = ROLE_DARKSPAWN
		M.mind.restricted_roles = restricted_roles
	get_darkspawn_team().set_required_succs(population)
	return TRUE

/datum/dynamic_ruleset/roundstart/darkspawn/execute()
	for(var/datum/mind/M in assigned)
		M.add_antag_datum(/datum/antagonist/darkspawn, get_darkspawn_team())
	return TRUE

/datum/dynamic_ruleset/roundstart/darkspawn/round_result()
	..()
	if(GLOB.sacrament_done)
		SSticker.mode_result = "win - the darkspawn have completed the Sacrament"
	else
		SSticker.mode_result = "loss - staff stopped the darkspawn"
