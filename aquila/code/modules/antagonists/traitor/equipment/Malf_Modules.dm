/datum/AI_Module/proc/can_use(mob/living/silicon/ai/AI)
	return TRUE

/datum/AI_Module/destructive/nuke_station/can_use(mob/living/silicon/ai/AI)
	return !AI.mind.has_antag_datum(/datum/antagonist/hijacked_ai)

/datum/AI_Module/utility/place_cyborg_transformer/can_use(mob/living/silicon/ai/AI)
	return !AI.mind.has_antag_datum(/datum/antagonist/hijacked_ai)
