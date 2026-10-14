//Go to a place, board a ship, change the IFF

/datum/overmap_gamemode/boarding
	name = "Boarding"
	config_tag = "boarding"
	desc = "Boarding gamemode - board a specific ship and hack the IFF"
	brief = "Waszym zadaniem jest przejęcie jednostki Syndykatu. Zlokalizujcie cel, bezwzględnie wyeliminujcie siły Syndykatu, a następnie zmieńcie kody transpondera i sprowadźcie ją do domu."
	starting_system = "Argo"
	starting_faction = "nanotrasen"
	objective_reminder_setting = 2 // Combat can postpone, but it's not the goal
	combat_delay = 10 MINUTES
	selection_weight = 5
	required_players = 10
	fixed_objectives = list(/datum/overmap_objective/board_ship)
