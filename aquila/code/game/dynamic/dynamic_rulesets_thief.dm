// AQUILA - Thief dynamic rulesets (tgstation#64144)

/// Ruleset for thieves
/datum/dynamic_ruleset/roundstart/thieves
	name = "Thieves"
	role_preference = /datum/role_preference/antagonist/thief
	antag_datum = /datum/antagonist/thief
	protected_roles = list(
		JOB_NAME_CAPTAIN,
		JOB_NAME_DETECTIVE,
		JOB_NAME_HEADOFSECURITY,
		JOB_NAME_PRISONER,
		JOB_NAME_SECURITYOFFICER,
		JOB_NAME_WARDEN,
	)
	restricted_roles = list(
		JOB_NAME_AI,
		JOB_NAME_CYBORG,
	)
	required_candidates = 1
	weight = 3
	cost = 6 //very cheap cost for the round
	scaling_cost = 9
	requirements = list(8,8,8,8,8,8,8,8,8,8)
	antag_cap = list("denominator" = 24)

/datum/dynamic_ruleset/roundstart/thieves/pre_execute(population)
	. = ..()
	var/num_thieves = get_antag_cap(population) * (scaled_times + 1)
	for (var/i = 1 to num_thieves)
		if(candidates.len <= 0)
			break
		var/mob/chosen = pick_n_take(candidates)
		assigned += chosen.mind
		chosen.mind.special_role = ROLE_THIEF
		chosen.mind.restricted_roles = restricted_roles
	return TRUE

/// Thief midround ruleset
/datum/dynamic_ruleset/midround/opportunist
	name = "Opportunist"
	midround_ruleset_style = MIDROUND_RULESET_STYLE_LIGHT
	antag_datum = /datum/antagonist/thief
	role_preference = /datum/role_preference/midround_living/opportunist
	restricted_roles = list(
		JOB_NAME_AI,
		JOB_NAME_CYBORG,
		"Positronic Brain",
		JOB_NAME_CAPTAIN,
		JOB_NAME_DETECTIVE,
		JOB_NAME_HEADOFPERSONNEL,
		JOB_NAME_HEADOFSECURITY,
		JOB_NAME_PRISONER,
		JOB_NAME_SECURITYOFFICER,
		JOB_NAME_WARDEN,
	)
	enemy_roles = list(
		JOB_NAME_CAPTAIN,
		JOB_NAME_DETECTIVE,
		JOB_NAME_HEADOFSECURITY,
		JOB_NAME_SECURITYOFFICER,
		JOB_NAME_WARDEN,
	)
	required_enemies = list(1,1,0,0,0,0,0,0,0,0)
	required_candidates = 1
	weight = 5
	cost = 3 //Worth less than obsessed, but there's more of them.
	requirements = list(10,10,10,10,10,10,10,10,10,10)
	repeatable = TRUE

/datum/dynamic_ruleset/midround/opportunist/trim_candidates()
	..()
	candidates = living_players
	for(var/mob/living/carbon/human/candidate in candidates)
		if( \
			candidate.mind.has_antag_datum(antag_datum) \
			|| candidate.stat == DEAD \
			|| !SSjob.GetJob(candidate.mind.assigned_role) \
			|| (candidate.mind.assigned_role in GLOB.nonhuman_positions) \
		)
			candidates -= candidate

/datum/dynamic_ruleset/midround/opportunist/ready(forced = FALSE)
	if(!check_candidates())
		return FALSE
	if(mode.check_lowpop_lowimpact_injection())
		return FALSE
	return ..()

/datum/dynamic_ruleset/midround/opportunist/execute()
	if(!length(candidates))
		return FALSE
	var/mob/living/carbon/human/thief = pick_n_take(candidates)
	thief.mind.add_antag_datum(antag_datum)
	message_admins("[ADMIN_LOOKUPFLW(thief)] has been made a Thief by the midround ruleset.")
	log_game("[key_name(thief)] was made a Thief by the midround ruleset.")
	return ..()
