/datum/overmap_gamemode/shakedown
	name = "Shakedown"
	config_tag = "shakedown"
	desc = "Do some jumps and light combat"
	brief = "Przydzielono wam świeżo wyremontowaną jednostkę na rejs próbny. Rozgrzejcie Napęd Thirringa, przetestujcie uzbrojenie, a potem wróćcie na Posterunek 45."
	starting_system = "Argo"
	starting_faction = "nanotrasen"

	objective_reminder_setting = 0
	reminder_one = "Tu Centrala do wszystkich statków przydzielonych do patrolu Gromady Rosetta, prosimy kontynuować misję"
	reminder_two = "Tu Centrala do wszystkich statków przydzielonych do patrolu Gromady Rosetta, wasza nieaktywność została zauważona i nie będzie tolerowana."
	reminder_three = "Tu Centrala do wszystkich statków przydzielonych do patrolu Gromady Rosetta, nie płacimy wam za dryfowanie w kosmosie podczas wykonywania przydzielonej misji"
	reminder_four = "Tu Centrala do wszystkich statków obecnie przydzielonych do patrolu Gromady Rosetta, jesteście zobowiązani do wykonania przydzielonej misji"
	reminder_five = "Wasza wypłata została przeznaczona na pokrycie wydatków, dalsze ignorowanie misji doprowadzi do przymusowego terminacji."

	selection_weight = 5
	required_players = 0
	max_players = 10
	random_objective_amount = 3

/datum/overmap_gamemode/shakedown/New()
	random_objectives = list(
		/datum/overmap_objective/perform_jumps,
		/datum/overmap_objective/destroy_fleets,
		/datum/overmap_objective/apnw_efficiency,
		/datum/overmap_objective/scan
	)
