// The upstream assert macros are #undef'd at the end of code/modules/unit_tests/_unit_tests.dm, so this modular test carries its own copy
#define TEST_ASSERT(assertion, reason) if (!(assertion)) { return Fail("Assertion failed: [reason || "No reason"]") }

/// AQUILA - Komora testowa: ładuje się, każdy zestaw daje się zrzucić, reset przywraca pokój
/datum/unit_test/test_chamber

/datum/unit_test/test_chamber/Run()
	var/datum/test_chamber/chamber = get_test_chamber()
	TEST_ASSERT(chamber, "Test chamber failed to load")
	TEST_ASSERT(istype(chamber.arrival?.loc, /area/test_chamber), "Arrival turf is outside the chamber")
	TEST_ASSERT(istype(chamber.kit_center?.loc, /area/test_chamber/arena), "Kit center is outside the arena")
	TEST_ASSERT(!(locate(/obj/effect/landmark/test_chamber) in chamber.arrival), "Landmarks were not cleaned up")
	var/fail = check_room(chamber)
	TEST_ASSERT(!fail, "Fresh chamber: [fail]")

	for(var/name in test_chamber_kits())
		var/datum/test_chamber_kit/kit = test_chamber_kits()[name]
		// Liczymy różnicę, bo komora i wcześniejsze zestawy mogą już mieć obiekty tego typu
		var/list/before = list()
		for(var/path in kit.items)
			before[path] = count_in_chamber(chamber, path)
		chamber.spawn_kit(kit, null)
		for(var/path in kit.items)
			var/spawned = count_in_chamber(chamber, path) - before[path]
			var/expected = kit.items[path] || 1
			TEST_ASSERT(spawned == expected, "Kit [name] spawned [spawned] of [expected] [path]")

	var/turf/open/floor/F = chamber.kit_center
	F.ScrapeAway(flags = CHANGETURF_INHERIT_AIR)
	TEST_ASSERT(chamber.reset(), "Test chamber failed to reset")
	for(var/turf/T as anything in chamber.reservation.reserved_turfs)
		var/mob/living/leftover = locate() in T
		TEST_ASSERT(!leftover, "Reset left [leftover?.type] at [T.x],[T.y]")
	TEST_ASSERT(istype(chamber.kit_center, /turf/open/floor/plasteel/dark), "Reset did not restore the arena floor")
	fail = check_room(chamber)
	TEST_ASSERT(!fail, "After reset: [fail]")

/datum/unit_test/test_chamber/proc/count_in_chamber(datum/test_chamber/chamber, path)
	. = 0
	for(var/turf/T as anything in chamber.reservation.reserved_turfs)
		for(var/atom/movable/AM in T)
			if(istype(AM, path))
				.++

/datum/unit_test/test_chamber/proc/check_room(datum/test_chamber/chamber)
	var/consoles = 0
	for(var/turf/T as anything in chamber.reservation.reserved_turfs)
		consoles += length(typecache_filter_list(T.contents, typecacheof(/obj/machinery/computer/test_chamber)))
	if(consoles != 1)
		return "Expected one console in the chamber, found [consoles]"
	var/datum/gas_mixture/air = chamber.arrival.return_air()
	var/pressure = air.return_pressure()
	if(pressure < 90 || pressure > 110)
		var/list/space = list()
		for(var/turf/T as anything in chamber.reservation.reserved_turfs)
			if(!isclosedturf(T) && !T.blocks_air && T.return_air()?.return_pressure() < 1)
				space += "[T.type]@[T.x],[T.y]"
		return "Chamber has unsafe pressure [pressure] kPa (arrival [chamber.arrival.type], [length(space)] empty turfs: [english_list(space.Copy(1, min(length(space), 6) + 1))])"

#undef TEST_ASSERT
