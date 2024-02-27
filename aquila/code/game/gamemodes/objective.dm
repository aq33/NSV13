
/**
  * Break shit - the objective
  *
  * Areas are stored, not references to the machines and not checking the machines globally
  * This solves the following issues:
  * * Problem 1 - Engineers rebuild and then the sabotage is immediately undone, the traitor having no reason to stop them
  * * Problem 2 - Engineers build a random machine in maint where no one would look to fuck over the traitor
  * The idea is that the traitor must commit to breaking the machines
  */
/datum/objective/break_machinery
	name = "Destroy some machines"
	explanation_text = "Destroy all of something in the areas it spawns in."
	var/obj/machinery/target_obj_type
	var/list/potential_target_types
	var/list/area/target_areas

/datum/objective/break_machinery/finalize()
	target_areas = list()
	var/station_z = SSmapping.levels_by_trait(ZTRAIT_STATION)[1]
	if(!target_obj_type) // Select our target machine if there is none pre-set
		potential_target_types = list(
			// SCIENCE
			/obj/machinery/rnd/server,
			// ENGINEERING
			/obj/machinery/power/smes,
			/obj/machinery/power/supermatter_crystal,
			/obj/machinery/telecomms, // hard-mode
			// MEDICAL
			/obj/machinery/stasis,
			/obj/machinery/sleeper,
			/obj/machinery/clonepod,
			// OTHER
			/obj/machinery/autolathe,
			/obj/machinery/ore_silo,
			/obj/machinery/teleport/hub,
			/obj/machinery/rnd/production/protolathe, // hard-mode 2.0
		)
		potential_target_types = shuffle(potential_target_types)
		var/targets_len = potential_target_types.len
		var/iteration = 1
		while(!target_obj_type && targets_len >= iteration)
			for(var/obj/machinery/machine as anything in GLOB.machines)
				if(machine.z == station_z && istype(machine, potential_target_types[iteration]))
					target_obj_type = potential_target_types[iteration]
					break
			iteration++

	if(!target_obj_type)
		return FALSE

	var/machine_name = initial(target_obj_type.name)
	name = "Destroy [machine_name][machine_name[length(machine_name)] == "s" ? "es" : "s"]"
	// Find and shuffle machines for random area selection
	var/list/eligible_machines = list()
	for(var/obj/machinery/machine as anything in GLOB.machines)
		if(!istype(machine, target_obj_type))
			continue
		if(machine.z != station_z)
			continue
		if(!istype(get_area(machine), /area))
			continue
		eligible_machines |= machine

	eligible_machines = shuffle(eligible_machines)
	// Store areas
	for(var/obj/machinery/machine as anything in eligible_machines)
		target_areas |= get_area(machine)
		if(target_areas.len >= 4)
			break

	// Format explanation text
	explanation_text = "Ensure no functioning [machine_name][machine_name[length(machine_name)] == "s" ? "es" : "s"] exist in "
	switch(target_areas.len)
		if(0)
			return FALSE
		if(1)
			explanation_text += "[target_areas[1].name]."
		if(2)
			explanation_text += "[target_areas[1].name] and [target_areas[2].name]."
		else
			var/iteration = 1
			for(var/area/target_area in target_areas)
				if(iteration == target_areas.len)
					explanation_text += "and [target_area.name]."
					break
				explanation_text += "[target_area.name], "
				iteration++
	return TRUE

/datum/objective/break_machinery/check_completion()
	if(!target_obj_type)
		return TRUE
	if(target_areas.len == 0)
		return TRUE
	for(var/area/target_area in target_areas)
		if(locate(target_obj_type) in target_area)
			return FALSE
	return TRUE
