/datum/objective/blood/proc/gen_amount_goal(lowbound = 450, highbound = 700)
	target_amount = rand (lowbound,highbound)
	explanation_text = "Wyssij [target_amount] jednostek krwi."
	return target_amount

/datum/objective/blood/check_completion()
	if(..())
		return TRUE
	if(!owner)
		return FALSE
	var/datum/antagonist/vampire/vamp = owner.has_antag_datum(/datum/antagonist/vampire)
	if(vamp && target_amount <= vamp.total_blood)
		return TRUE
	else
		return FALSE

/datum/objective/convert/proc/gen_amount_goal(lowbound = 1, highbound = 3)
	target_amount = rand (lowbound,highbound)
	if(target_amount == 1)
		explanation_text = "Zmień członka załogi w wampira za pomocą Paktu Lilith."
	else
		explanation_text = "Zmień [target_amount] członków załogi w wampiry za pomocą Paktu Lilith."
	return target_amount

/datum/objective/convert/check_completion()
	if(..())
		return TRUE
	if(!owner)
		return FALSE
	var/datum/antagonist/vampire/vamp = owner.has_antag_datum(/datum/antagonist/vampire)
	if(vamp && target_amount <= vamp.converted)
		return TRUE
	else
		return FALSE
