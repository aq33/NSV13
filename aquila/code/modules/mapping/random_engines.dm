/datum/map_template/random_engine
	var/engine_id //The SSmapping random_room_template list is ordered by this var
	var/spawned //Whether this template (on the random_room template list) has been spawned
	var/centerspawner = TRUE
	var/template_height = 0
	var/template_width = 0
	var/weight = 10 //weight a room has to appear
	var/stock = 10 //how many times this room can appear in a round

/datum/map_template/random_engine/atlas_engine_stormdrive
	name = "Atlas Stormdrive Engine"
	engine_id = "atlas_engine_stormdrive"
	mappath = "_maps/RandomEngines/atlas_engine_stormdrive.dmm"
	centerspawner = TRUE
	template_height = 18
	template_width = 22
	weight = 1

/datum/map_template/random_engine/atlas_engine_supermatter
	name = "Atlas Supermatter Engine"
	engine_id = "atlas_engine_supermatter"
	mappath = "_maps/RandomEngines/atlas_engine_supermatter.dmm"
	centerspawner = TRUE
	centerspawner = TRUE
	template_height = 18
	template_width = 22
	weight = 1

/datum/map_template/random_engine/atlas_engine_tesla
	name = "Atlas Singularity and Tesla Engine"
	engine_id = "atlas_engine_tesla"
	mappath = "_maps/RandomEngines/atlas_engine_tesla.dmm"
	centerspawner = TRUE
	centerspawner = TRUE
	template_height = 18
	template_width = 22
	weight = 1
