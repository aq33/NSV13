// AQUILA - job specific traitor objectives, like tgstation's /datum/job/proc/generate_traitor_objective()

/// Returns the objective of the traitor's job, or null if the job has none (or it can't be set up).
/datum/antagonist/traitor/proc/forge_job_objective()
	var/datum/job/job = SSjob.GetJob(owner.assigned_role)
	var/datum/objective/job_objective = job?.generate_traitor_objective(owner)
	if(job_objective)
		job_objective.owner = owner
	return job_objective

/// Override to give traitors with this job a special objective.
/datum/job/proc/generate_traitor_objective(datum/mind/traitor)
	return null

/datum/job/head_of_personnel/generate_traitor_objective(datum/mind/traitor)
	var/datum/objective/assassinate/captain_replacement/promotion = new
	promotion.owner = traitor
	if(!promotion.find_target())
		qdel(promotion)
		return null
	return promotion

/// The XO kills the captain and takes their ID to become the new one
/datum/objective/assassinate/captain_replacement
	name = "zastąp kapitana"

/datum/objective/assassinate/captain_replacement/find_target(list/dupe_search_range, list/blacklist)
	for(var/datum/mind/possible_target as anything in get_crewmember_minds())
		if(possible_target.assigned_role != JOB_NAME_CAPTAIN || !is_valid_target(possible_target))
			continue
		set_target(possible_target)
		update_explanation_text()
		return target
	set_target(null)
	update_explanation_text()
	return null

/datum/objective/assassinate/captain_replacement/update_explanation_text()
	..()
	if(target?.current)
		explanation_text = "Zabij kapitana, [target.name], zabierz jego kartę identyfikacyjną i przejmij dowodzenie statkiem."
	else
		explanation_text = "Cel dowolny"

/datum/objective/assassinate/captain_replacement/check_completion()
	if(completed)
		return TRUE
	if(!..())
		return FALSE
	for(var/datum/mind/owner_mind as anything in get_owners())
		if(!isliving(owner_mind.current))
			continue
		for(var/obj/item/card/id/card in owner_mind.current.GetAllContents())
			if(istype(card, /obj/item/card/id/captains_spare) || (card.registered_name == target.name && card.assignment == JOB_NAME_CAPTAIN))
				return TRUE
	return FALSE
