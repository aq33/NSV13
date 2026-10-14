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
	TEST_ASSERT(!fail, fail)

	for(var/name in test_chamber_kits())
		var/datum/test_chamber_kit/kit = test_chamber_kits()[name]
		chamber.spawn_kit(kit, null)
		for(var/path in kit.items)
			var/found = FALSE
			for(var/turf/T as anything in chamber.reservation.reserved_turfs)
				if(locate(path) in T)
					found = TRUE
					break
			TEST_ASSERT(found, "Kit [name] did not spawn [path]")

	var/turf/open/floor/F = chamber.kit_center
	F.ScrapeAway(flags = CHANGETURF_INHERIT_AIR)
	TEST_ASSERT(chamber.reset(), "Test chamber failed to reset")
	for(var/turf/T as anything in chamber.reservation.reserved_turfs)
		TEST_ASSERT(!(locate(/mob/living) in T), "Reset left a mob at [T.x],[T.y]")
	TEST_ASSERT(istype(chamber.kit_center, /turf/open/floor/plasteel/dark), "Reset did not restore the arena floor")
	fail = check_room(chamber)
	TEST_ASSERT(!fail, fail)

/datum/unit_test/test_chamber/proc/check_room(datum/test_chamber/chamber)
	var/consoles = 0
	for(var/turf/T as anything in chamber.reservation.reserved_turfs)
		consoles += length(typecache_filter_list(T.contents, typecacheof(/obj/machinery/computer/test_chamber)))
	if(consoles != 1)
		return "Expected one console in the chamber, found [consoles]"
	var/datum/gas_mixture/air = chamber.arrival.return_air()
	var/pressure = air.return_pressure()
	if(pressure < 90 || pressure > 110)
		return "Chamber has unsafe pressure [pressure] kPa"

#undef TEST_ASSERT
