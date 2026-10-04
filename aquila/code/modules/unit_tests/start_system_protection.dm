// The upstream assert macros are #undef'd at the end of code/modules/unit_tests/_unit_tests.dm, so this modular test carries its own copies
#define TEST_ASSERT(assertion, reason) if (!(assertion)) { return Fail("Assertion failed: [reason || "No reason"]") }

#define TEST_ASSERT_EQUAL(a, b, message) do { \
	var/lhs = ##a; \
	var/rhs = ##b; \
	if (lhs != rhs) { \
		return Fail("Expected [isnull(lhs) ? "null" : lhs] to be equal to [isnull(rhs) ? "null" : rhs].[message ? " [message]" : ""]"); \
	} \
} while (FALSE)

#define TEST_STARMAP "config/starmap/unit_test_start_protection.json"

/// AQUILA - The starting system doesn't come back occupied after a restart, so no enemies spawn there at load
/datum/unit_test/start_system_protection
	var/list/made = list()

/datum/unit_test/start_system_protection/Run()
	var/start_name = SSstar_system.player_start_system_name()
	TEST_ASSERT(start_name, "No starting system name")

	// Loaded occupied with no fleet (the saved state that kept respawning enemies): put back under its owner, and nothing spawns
	var/datum/star_system/start = make_system(start_name, "syndicate", "nanotrasen")
	TEST_ASSERT(SSstar_system.clear_start_system_occupation(start), "The occupied starting system wasn't cleared")
	TEST_ASSERT_EQUAL(start.alignment, "nanotrasen", "The starting system's alignment wasn't restored to its owner")
	start.apply_system_effects() // what generate_anomaly() runs 15 seconds after load
	TEST_ASSERT_EQUAL(length(start.fleets), 0, "Enemies spawned in the starting system at load")

	// The same saved state anywhere else still spawns its enemies, so the starting system is the only change
	var/datum/star_system/other = make_system("Unit Test Occupied System", "syndicate", "nanotrasen")
	TEST_ASSERT(!SSstar_system.clear_start_system_occupation(other), "A system other than the start was cleared")
	other.apply_system_effects()
	TEST_ASSERT(length(other.fleets), "An occupied system that isn't the start no longer spawns enemies")

	// A fleet really in the starting system keeps it occupied
	var/datum/star_system/held = make_system(start_name, "syndicate", "nanotrasen")
	held.fleets += make_fleet(held)
	TEST_ASSERT(!SSstar_system.clear_start_system_occupation(held), "The starting system was cleared with a fleet in it")
	TEST_ASSERT_EQUAL(held.alignment, "syndicate", "A real occupation was undone")

	// The save writes the owner for systems with fleets in them, and leaves the rest alone
	var/datum/star_system/occupied = make_system("Unit Test Saved Occupation", "syndicate", "nanotrasen")
	occupied.fleets += make_fleet(occupied)
	var/datum/star_system/designed = make_system("Unit Test Saved Design", "unaligned", "syndicate") // like Deimos: differs by design, no fleet
	SSstar_system.systems += occupied
	SSstar_system.systems += designed
	var/save_result = SSstar_system.save(TEST_STARMAP)
	SSstar_system.systems -= occupied
	SSstar_system.systems -= designed
	TEST_ASSERT_EQUAL(save_result, 0, "The starmap save failed")
	var/list/saved = list()
	for(var/list/entry in json_decode(rustg_file_read(TEST_STARMAP)))
		saved[entry["name"]] = entry
	fdel(TEST_STARMAP)
	TEST_ASSERT_EQUAL(saved["Unit Test Saved Occupation"]?["alignment"], "nanotrasen", "An occupation was saved")
	TEST_ASSERT_EQUAL(saved["Unit Test Saved Occupation"]?["owner"], "nanotrasen", "The owner wasn't saved")
	TEST_ASSERT_EQUAL(saved["Unit Test Saved Design"]?["alignment"], "unaligned", "A system without fleets lost its alignment")
	TEST_ASSERT_EQUAL(saved["Unit Test Saved Design"]?["owner"], "syndicate", "A system without fleets lost its owner")

	// Fallback starmap systems get the owner their alignment implies; explicit owners, unaligned and "random" are left alone
	var/datum/star_system/fallback = make_system("Unit Test Fallback", "nanotrasen", null)
	var/datum/star_system/fallback_owned = make_system("Unit Test Fallback Owned", "unaligned", "syndicate")
	var/datum/star_system/fallback_random = make_system("Unit Test Fallback Random", "random", null)
	SSstar_system.assign_owners_from_alignment(list(fallback, fallback_owned, fallback_random))
	TEST_ASSERT_EQUAL(fallback.owner, "nanotrasen", "A fallback system didn't get its alignment as owner")
	TEST_ASSERT_EQUAL(fallback_owned.owner, "syndicate", "An explicit owner was overwritten")
	TEST_ASSERT_EQUAL(fallback_random.owner, "unaligned", "A random system's owner was picked early")

	// Neutral zone fleets move again, but only into unaligned/uncharted systems
	var/datum/star_system/hub = make_system("Unit Test Hub", "unaligned", "unaligned")
	var/datum/star_system/open = make_system("Unit Test Open", "unaligned", "unaligned")
	var/datum/star_system/held_nt = make_system("Unit Test NT", "nanotrasen", "nanotrasen")
	hub.adjacency_list = list(open.name, held_nt.name)
	SSstar_system.systems += list(hub, open, held_nt)
	var/datum/fleet/roamer = make_fleet(hub)
	roamer.can_reinforce = FALSE
	hub.fleets += roamer
	TEST_ASSERT_EQUAL(roamer.fleet_trait, FLEET_TRAIT_NEUTRAL_ZONE, "The test fleet isn't a neutral zone fleet")
	TEST_ASSERT(roamer.move(null, TRUE), "A neutral zone fleet couldn't move to an unaligned neighbour")
	TEST_ASSERT_EQUAL(roamer.current_system, open, "A neutral zone fleet went somewhere other than the unaligned neighbour")
	open.adjacency_list = list(held_nt.name)
	TEST_ASSERT(!roamer.move(null, TRUE), "A neutral zone fleet moved into a Nanotrasen system")
	TEST_ASSERT_EQUAL(roamer.current_system, open, "A neutral zone fleet left with nowhere valid to go")
	SSstar_system.systems -= list(hub, open, held_nt)

	// Random fleet spawns skip the starting system, even when it counts as one of the faction's systems
	var/datum/faction/syndicate = SSstar_system.faction_by_id(FACTION_ID_SYNDICATE)
	var/list/real_pool = SSstar_system.neutral_zone_systems
	var/real_next_spawn = syndicate.next_fleet_spawn
	var/datum/star_system/start_pool = make_system(start_name, "syndicate", "nanotrasen")
	SSstar_system.neutral_zone_systems = list(start_pool)
	syndicate.send_fleet(force = TRUE)
	var/start_fleets = length(start_pool.fleets)
	var/datum/star_system/other_pool = make_system("Unit Test Spawn Pool", "syndicate", "unaligned")
	SSstar_system.neutral_zone_systems = list(other_pool)
	syndicate.send_fleet(force = TRUE)
	SSstar_system.neutral_zone_systems = real_pool
	syndicate.next_fleet_spawn = real_next_spawn
	TEST_ASSERT_EQUAL(start_fleets, 0, "A random fleet spawned in the starting system")
	TEST_ASSERT_EQUAL(length(other_pool.fleets), 1, "Random fleet spawns stopped working elsewhere")

/datum/unit_test/start_system_protection/Destroy()
	fdel(TEST_STARMAP)
	for(var/datum/star_system/S as anything in made)
		SSstar_system.systems -= S
		for(var/datum/fleet/F as anything in S.fleets.Copy())
			F.current_system = S
			qdel(F)
		qdel(S) // also drops its pending generate_anomaly() timer
	made = null
	return ..()

/datum/unit_test/start_system_protection/proc/make_system(name, alignment, owner)
	var/datum/star_system/S = new /datum/star_system(name = name, x = 1, y = 1, alignment = alignment, owner = owner, sector = 2, adjacency_list = list(), system_type = list()) // a loaded starmap always passes a system_type, "[]" when untyped
	made += S
	return S

/datum/unit_test/start_system_protection/proc/make_fleet(datum/star_system/S)
	var/datum/fleet/F = new /datum/fleet/neutral
	F.current_system = S
	return F

#undef TEST_STARMAP
#undef TEST_ASSERT
#undef TEST_ASSERT_EQUAL
