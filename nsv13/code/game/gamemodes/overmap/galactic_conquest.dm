//Special gamemode used only in PVP. This gamemode should not be used outside of PVP.
//This is used to prevent other overmap gamemodes (delivery, boarding, shakedown) from getting in the way.
/datum/overmap_gamemode/galactic_conquest
	name = "Galactic Conquest"
	config_tag = "conquest"
	desc = "PVP Gamemode - Acquire 700 victory tickets for Nanotrasen or destroy the Syndicate Flagship"
	brief = "Wywiad sugeruje, że Syndykat szykuje zmasowany atak na sektor Sol. Patrolujcie ten obszar i bezwzględnie eliminujcie siły Syndykatu."
	starting_system = "Argo"
	starting_faction = "nanotrasen"
	objective_reminder_setting = 3 //No external pressure in this round...
	fixed_objectives = list(/datum/overmap_objective/tickets/nt) //Placeholder for now


/datum/overmap_gamemode/galactic_conquest/New()
	fixed_objectives = list(/datum/overmap_objective/tickets/nt)
