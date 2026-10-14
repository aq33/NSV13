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
	required_players = 14
	fixed_objectives = list(/datum/overmap_objective/board_ship)

//Go to a place, capture a station, hold it against the counterattack

/datum/overmap_gamemode/station_boarding
	name = "Station Boarding"
	config_tag = "station_boarding"
	desc = "Station boarding gamemode - capture a Syndicate outpost, then defend it from a boarding fleet"
	brief = "Waszym zadaniem jest przejęcie placówki Syndykatu. Zlokalizujcie ją, rozbijcie flotę obronną, wejdźcie na pokład i zmieńcie kody IFF, a potem utrzymajcie placówkę do odparcia kontrataku."
	starting_system = "Argo"
	starting_faction = "nanotrasen"
	objective_reminder_setting = 2 // Combat can postpone, but it's not the goal
	combat_delay = 10 MINUTES
	selection_weight = 5
	required_players = 10
	fixed_objectives = list(/datum/overmap_objective/board_station)
