// The upstream assert macros are #undef'd at the end of code/modules/unit_tests/_unit_tests.dm, so this modular test carries its own copies
#define TEST_ASSERT(assertion, reason) if (!(assertion)) { return Fail("Assertion failed: [reason || "No reason"]") }

/// AQUILA - Wallrot: a rotting wall carries fungus, sheds it when cleaned or changed, and crumbles when pushed
/datum/unit_test/aquila_wallrot

/datum/unit_test/aquila_wallrot/Run()
	var/turf/test_turf = run_loc_floor_bottom_left
	var/original_type = test_turf.type
	var/turf/closed/wall/wall = test_turf.ChangeTurf(/turf/closed/wall)
	wall.aquila_rot()
	TEST_ASSERT(wall.aquila_rotting, "the wall did not start rotting")
	TEST_ASSERT(length(wall.aquila_rot_effects) >= 2, "the rotting wall has no fungus on it")

	var/datum/reagents/holder = new(10)
	holder.add_reagent(/datum/reagent/toxin/plantbgone, 10)
	holder.reaction(wall, TOUCH)
	qdel(holder)
	TEST_ASSERT(!wall.aquila_rotting, "Plant-B-Gone did not clear the fungus")
	TEST_ASSERT(!(locate(/obj/effect/overlay/aquila_wallrot) in wall), "fungus effects were left behind after Plant-B-Gone")

	wall.aquila_rot()
	var/mob/living/carbon/human/pusher = allocate(/mob/living/carbon/human, locate(wall.x + 1, wall.y, wall.z))
	wall.attack_hand(pusher)
	var/turf/after_push = locate(wall.x, wall.y, wall.z)
	TEST_ASSERT(!iswallturf(after_push), "a rotting wall did not crumble when pushed")
	TEST_ASSERT(!(locate(/obj/effect/overlay/aquila_wallrot) in after_push), "fungus effects were left floating after the wall crumbled")

	for(var/obj/O in after_push)
		if(istype(O, /obj/structure/girder) || istype(O, /obj/item/stack))
			qdel(O)
	after_push.ChangeTurf(original_type)

/// AQUILA - Stray Cargo Pod: both variants build a crate to drop
/datum/unit_test/aquila_stray_cargo

/datum/unit_test/aquila_stray_cargo/Run()
	var/datum/round_event/aquila_stray_cargo/cargo = new(FALSE)
	cargo.kill()
	TEST_ASSERT(length(cargo.stray_spawnable_supply_packs), "no cargo packs are allowed in stray pods")
	var/obj/crate = cargo.get_contents()
	TEST_ASSERT(crate, "a stray cargo pod built no crate")
	allocated += crate

	var/datum/round_event/aquila_stray_cargo/syndicate/syndicate_cargo = new(FALSE)
	syndicate_cargo.kill()
	var/obj/syndicate_crate = syndicate_cargo.get_contents()
	TEST_ASSERT(syndicate_crate, "a stray syndicate pod built no crate")
	allocated += syndicate_crate
	TEST_ASSERT(length(syndicate_crate.contents), "a stray syndicate crate is empty")

/// AQUILA - Department Independence: every department lists real jobs and every grievance has a demand
/datum/unit_test/aquila_department_independence

/datum/unit_test/aquila_department_independence/Run()
	// Tytuły wszystkich prac, także wyłączonych konfiguracją mapy (np. Kontroler Lotów na Serendipity)
	var/list/all_job_titles = list()
	for(var/datum/job/job_type as anything in subtypesof(/datum/job))
		all_job_titles[initial(job_type.title)] = TRUE
	for(var/list/department in GLOB.aquila_independence_departments)
		for(var/job in department["jobs"])
			TEST_ASSERT(all_job_titles[job], "the [department["name"]] department lists an unknown job: [job]")
		TEST_ASSERT(length(department["prefixes"]), "the [department["name"]] department has no nation name prefixes")
		for(var/list/grievance in department["reasons"])
			TEST_ASSERT(length(grievance) == 2, "a grievance of the [department["name"]] department is not a reason and demand pair")
	for(var/list/grievance in GLOB.aquila_independence_common_reasons)
		TEST_ASSERT(length(grievance) == 2, "a common grievance is not a reason and demand pair")

/// AQUILA - Crystal Invasion: portals, monsters, the crystal and the stabilizer all work outside of the event
/datum/unit_test/aquila_crystal_invasion

/datum/unit_test/aquila_crystal_invasion/Run()
	var/obj/machinery/destabilized_crystal/crystal = allocate(/obj/machinery/destabilized_crystal)
	crystal.process()

	for(var/portal_type in subtypesof(/obj/structure/crystal_portal))
		var/obj/structure/crystal_portal/portal = allocate(portal_type, run_loc_floor_top_right)
		portal.closed = TRUE // so cleaning up does not blow up the test room
		TEST_ASSERT(portal.GetComponent(/datum/component/spawner), "[portal_type] has no spawner")
		TEST_ASSERT(portal.a_signal, "[portal_type] has no signaler")
	TEST_ASSERT(length(GLOB.huge_crystal_portals), "the huge portal did not register itself")

	for(var/monster_type in subtypesof(/mob/living/simple_animal/hostile/crystal_monster))
		allocate(monster_type, run_loc_floor_top_right)

	var/obj/item/crystal_stabilizer/stabilizer = allocate(/obj/item/crystal_stabilizer)
	var/obj/item/stack/sheet/otherworld_crystal/crystals = allocate(/obj/item/stack/sheet/otherworld_crystal)
	var/mob/living/carbon/human/engineer = allocate(/mob/living/carbon/human)
	stabilizer.attackby(crystals, engineer)
	TEST_ASSERT(stabilizer.filled, "the stabilizer did not take the otherworld crystal")

	var/datum/techweb_node/anomaly = SSresearch.techweb_node_by_id("anomaly_research")
	TEST_ASSERT("crystal_stabilizer" in anomaly.design_ids, "the stabilizer is not researchable")

#undef TEST_ASSERT
