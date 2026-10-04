// AQUILA - aq33/NSV13#248, port of yogstation13/Yogstation#19887

/**
 * Break shit - the objective
 *
 * Areas are stored, not references to the machines and not checking the machines globally.
 * This solves the following issues:
 * * Engineers rebuild and the sabotage is immediately undone, the traitor having no reason to stop them
 * * Engineers build a random machine in maint where no one would look to fuck over the traitor
 * The idea is that the traitor must commit to breaking the machines.
 */
/datum/objective/break_machinery
	name = "destroy some machines"
	explanation_text = "Zniszcz wszystkie maszyny danego typu w miejscach, w których stoją."
	/// The machine type to get rid of
	var/obj/machinery/target_obj_type
	/// Areas that must end up without a single target_obj_type
	var/list/area/target_areas = list()
	/// Up to this many areas are picked
	var/max_target_areas = 4

/// Every type this objective can pick, as in the original PR
/datum/objective/break_machinery/proc/potential_target_types()
	return list(
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
		/obj/machinery/modular_fabricator/autolathe,
		/obj/machinery/ore_silo,
		/obj/machinery/teleport/hub,
		/obj/machinery/rnd/production/protolathe, // hard-mode 2.0
	)

/// Picks a machine type that exists on the station and up to max_target_areas areas holding it. FALSE if there is none.
/datum/objective/break_machinery/proc/finalize()
	target_areas = list()
	if(!target_obj_type)
		for(var/candidate in shuffle(potential_target_types()))
			for(var/obj/machinery/machine as anything in GLOB.machines)
				if(istype(machine, candidate) && is_station_level(machine.z)) // every deck, not only the first station z-level
					target_obj_type = candidate
					break
			if(target_obj_type)
				break
	if(!target_obj_type)
		return FALSE

	var/list/eligible_machines = list()
	for(var/obj/machinery/machine as anything in GLOB.machines)
		if(istype(machine, target_obj_type) && is_station_level(machine.z) && get_area(machine))
			eligible_machines += machine
	for(var/obj/machinery/machine as anything in shuffle(eligible_machines))
		target_areas |= get_area(machine)
		if(length(target_areas) >= max_target_areas)
			break
	if(!length(target_areas))
		return FALSE

	var/machine_name = initial(target_obj_type.name)
	name = "destroy [machine_name]"
	var/list/area_names = list()
	for(var/area/A as anything in target_areas)
		area_names += A.name
	explanation_text = "Zniszcz wszystkie maszyny typu [machine_name] w tych miejscach: [english_list(area_names, and_text = " i ")]."
	return TRUE

/datum/objective/break_machinery/check_completion()
	if(!target_obj_type || !length(target_areas))
		return TRUE
	for(var/area/target_area as anything in target_areas)
		if(locate(target_obj_type) in target_area)
			return FALSE
	return TRUE

// The base telecomms type had no name, so the objective would read "machinery"
/obj/machinery/telecomms
	name = "telecommunications machine"
