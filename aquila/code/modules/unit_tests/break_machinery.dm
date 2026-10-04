// The upstream assert macros are #undef'd at the end of code/modules/unit_tests/_unit_tests.dm, so this modular test carries its own copies
#define TEST_ASSERT(assertion, reason) if (!(assertion)) { return Fail("Assertion failed: [reason || "No reason"]") }

/// A machine type that is never mapped
/obj/machinery/aquila_test_unmapped_machine

/// AQUILA - break_machinery objective (#248): target selection on the real map, partial and full destruction, rebuilding
/datum/unit_test/break_machinery_objective

/datum/unit_test/break_machinery_objective/Run()
	// Free choice picks a type that really is on the station
	var/datum/objective/break_machinery/free = new
	TEST_ASSERT(free.finalize(), "No machine type to break on the station")
	TEST_ASSERT(free.target_obj_type in free.potential_target_types(), "Picked a type outside the original list")
	TEST_ASSERT(length(free.target_areas) && length(free.target_areas) <= free.max_target_areas, "Wrong number of target areas: [length(free.target_areas)]")
	for(var/area/A as anything in free.target_areas)
		TEST_ASSERT(locate(free.target_obj_type) in A, "[A] holds no [free.target_obj_type]")
	TEST_ASSERT(findtext(free.explanation_text, initial(free.target_obj_type.name)), "Explanation text does not name the machine: [free.explanation_text]")
	TEST_ASSERT(!free.check_completion(), "Objective complete before anything was broken")
	qdel(free)

	// Nothing to break: finalize fails, and an unfinished objective never blocks greentext
	var/datum/objective/break_machinery/impossible = new
	impossible.target_obj_type = /obj/machinery/aquila_test_unmapped_machine
	TEST_ASSERT(!impossible.finalize(), "Objective accepted a machine type that is not on the station")
	TEST_ASSERT(impossible.check_completion(), "Empty objective counts as failed")
	qdel(impossible)

	// Destruction, with a harmless type so the station keeps power for the other tests
	var/target_type = /obj/machinery/modular_fabricator/autolathe
	var/area/mapped_area
	for(var/obj/machinery/M as anything in GLOB.machines)
		if(istype(M, target_type) && is_station_level(M.z))
			mapped_area = get_area(M)
			break
	if(!mapped_area)
		return // this map has no autolathe on the station, the free choice above already covered selection
	// Make sure there are at least two target areas, so partial destruction can be checked
	for(var/turf/T as anything in get_safe_random_station_turfs(amount = 20))
		if(get_area(T) != mapped_area)
			allocate(target_type, T)
			break
	var/datum/objective/break_machinery/objective = new
	objective.target_obj_type = target_type
	TEST_ASSERT(objective.finalize(), "Could not target the autolathes")
	TEST_ASSERT(!objective.check_completion(), "Complete with every autolathe still standing")

	var/list/area/areas = objective.target_areas.Copy()
	TEST_ASSERT(length(areas) > 1, "Expected at least two target areas, got [length(areas)]")
	for(var/obj/machinery/M in areas[1])
		if(istype(M, target_type))
			qdel(M)
	TEST_ASSERT(!objective.check_completion(), "Complete after breaking only some of the target areas")
	for(var/area/A as anything in areas)
		for(var/obj/machinery/M in A)
			if(istype(M, target_type))
				qdel(M)
	TEST_ASSERT(objective.check_completion(), "Not complete after breaking every autolathe in the target areas")

	// A new one somewhere else does not matter, one rebuilt in a target area undoes the sabotage
	var/obj/machinery/elsewhere = allocate(target_type)
	TEST_ASSERT(objective.check_completion(), "An autolathe outside the target areas undid the sabotage")
	qdel(elsewhere)
	var/turf/rebuild_spot
	for(var/turf/open/T in areas[1])
		rebuild_spot = T
		break
	if(rebuild_spot)
		var/obj/machinery/rebuilt = allocate(target_type, rebuild_spot)
		TEST_ASSERT(!objective.check_completion(), "Rebuilding in a target area did not undo the sabotage")
		qdel(rebuilt)
	qdel(objective)

/// The traitor objective generator never ends up with a broken or empty break_machinery objective
/datum/unit_test/break_machinery_traitor_forge

/datum/unit_test/break_machinery_traitor_forge/Run()
	var/mob/living/carbon/human/H = allocate(/mob/living/carbon/human)
	H.mind_initialize()
	var/datum/antagonist/traitor/T = new // not added to the mind: only the objective generator is under test
	T.owner = H.mind
	for(var/i in 1 to 40)
		T.forge_single_human_objective()
	var/breaks = 0
	for(var/datum/objective/O as anything in T.objectives)
		TEST_ASSERT(O.explanation_text && O.explanation_text != "Nothing", "Objective [O.type] has no text")
		var/datum/objective/break_machinery/B = O
		if(istype(B))
			breaks++
			TEST_ASSERT(B.target_obj_type && length(B.target_areas), "A break_machinery objective with no target was handed out")
	TEST_ASSERT(breaks, "40 forged objectives and not one break_machinery")
	QDEL_LIST(T.objectives)
	T.owner = null
	qdel(T)

#undef TEST_ASSERT
