/datum/action/changeling/organic_mindshield
	name = "Organic Mindshield"
	desc = "We emit a constant frequency matching that of a mindshield, fooling security HUDs into thinking we are mindshielded."
	button_icon_state = "mindshield"
	helptext = "Sprawia, że na HUD-ach ochrony widać u ciebie implant ochrony umysłu. Utrzymanie zużywa 1 jedn. chemikaliów co 3 sekundy. Nie działa, gdy płoniesz."
	chemical_cost = 0
	dna_cost = 1
	req_human = 1

/datum/action/changeling/organic_mindshield/sting_action(mob/living/user)
	..()

	if(!user.has_status_effect(STATUS_EFFECT_CHANGELING_MINDSHIELD))
		user.apply_status_effect(STATUS_EFFECT_CHANGELING_MINDSHIELD)
	else
		user.remove_status_effect(STATUS_EFFECT_CHANGELING_MINDSHIELD)
	return TRUE

/datum/action/changeling/organic_mindshield/Remove(mob/living/user)
	user.remove_status_effect(STATUS_EFFECT_CHANGELING_MINDSHIELD)
	..()
