/datum/objective/clockcult
	name = "serve Rat'var"
	explanation_text = "Chroń Niebiańską Bramę, by Rat'var mógł oświecić ten świat!"

/datum/objective/clockcult/check_completion()
	return GLOB.ratvar_risen || ..()
