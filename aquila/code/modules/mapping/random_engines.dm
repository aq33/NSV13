/datum/map_template/random_engine
	var/engine_id //The SSmapping random_room_template list is ordered by this var
	var/spawned //Whether this template (on the random_room template list) has been spawned
	var/centerspawner = FALSE
	var/template_height = 0
	var/template_width = 0
	var/weight = 10 //weight a room has to appear
	var/stock = 10 //how many times this room can appear in a round
	var/atlas_engines = list("_maps/random_engines/atlas_engine_supermatter.dmm", "_maps/random_engines/atlas_engine_tesla.dmm", "_maps/random_engines/atlas_engine_stormdrive.dmm")

/datum/map_template/random_engine/engine/New()
	switch(SSmapping.config?.map_name)
		if("Atlas")
			mappath = pick(atlas_engines)

/datum/map_template/random_engine/atlas_engine_stormdrive
	name = "Atlas Stormdrive Engine"
	engine_id = "atlas_engine_stormdrive"
	mappath = "_maps/RandomEngines/atlas_engine_stormdrive.dmm"
	centerspawner = FALSE
	template_height = 18
	template_width = 22
	weight = 1

/datum/map_template/random_engine/atlas_engine_supermatter
	name = "Atlas Supermatter Engine"
	engine_id = "atlas_engine_supermatter"
	mappath = "_maps/RandomEngines/atlas_engine_supermatter.dmm"
	centerspawner = FALSE
	template_height = 18
	template_width = 22
	weight = 1

/datum/map_template/random_engine/atlas_engine_tesla
	name = "Atlas Singularity and Tesla Engine"
	engine_id = "atlas_engine_tesla"
	mappath = "_maps/RandomEngines/atlas_engine_tesla.dmm"
	centerspawner = FALSE
	template_height = 18
	template_width = 22
	weight = 1
