// The upstream assert macros are #undef'd at the end of code/modules/unit_tests/_unit_tests.dm, so this modular test carries its own copies
#define TEST_ASSERT(assertion, reason) if (!(assertion)) { return Fail("Assertion failed: [reason || "No reason"]") }

#define TEST_ASSERT_EQUAL(a, b, message) do { \
	var/lhs = ##a; \
	var/rhs = ##b; \
	if (lhs != rhs) { \
		return Fail("Expected [isnull(lhs) ? "null" : lhs] to be equal to [isnull(rhs) ? "null" : rhs].[message ? " [message]" : ""]"); \
	} \
} while (FALSE)

#define TEST_ASSERT_NOTEQUAL(a, b, message) do { \
	var/lhs = ##a; \
	var/rhs = ##b; \
	if (lhs == rhs) { \
		return Fail("Expected [isnull(lhs) ? "null" : lhs] to not be equal to [isnull(rhs) ? "null" : rhs].[message ? " [message]" : ""]"); \
	} \
} while (FALSE)

/// AQUILA - Bluespace locker: room loading, linking, travel both ways with several mobs, and relinking after the external locker is destroyed
/datum/unit_test/bluespace_locker

/datum/unit_test/bluespace_locker/Run()
	var/obj/structure/closet/bluespace/internal/internal = SSbluespace_locker.internal_locker
	var/obj/structure/closet/bluespace/external/external = SSbluespace_locker.external_locker
	TEST_ASSERT(SSbluespace_locker.room_reservation, "Bluespace locker room was not reserved")
	TEST_ASSERT(SSbluespace_locker.room_origin, "Bluespace locker room has no origin turf")
	TEST_ASSERT(!QDELETED(internal), "No internal bluespace locker")
	TEST_ASSERT(!QDELETED(external), "No external bluespace locker")
	TEST_ASSERT(istype(get_area(internal), /area/bluespace_locker), "Internal locker is not inside the bluespace locker area")
	TEST_ASSERT(!(locate(/obj/effect/landmark/bluespace_locker_origin) in SSbluespace_locker.room_origin), "Origin landmark was not cleaned up")

	var/externals = 0
	for(var/obj/structure/closet/bluespace/external/E in world)
		externals++
	TEST_ASSERT_EQUAL(externals, 1, "Wrong number of external bluespace lockers")
	var/internals = 0
	for(var/obj/structure/closet/bluespace/internal/I in world)
		internals++
	TEST_ASSERT_EQUAL(internals, 1, "Wrong number of internal bluespace lockers")

	TEST_ASSERT(GLOB.blacklisted_cargo_types[/obj/structure/closet/bluespace/external], "Bluespace locker is not blacklisted from cargo")
	var/datum/map_template/shelter/alpha/shelter = new
	TEST_ASSERT(shelter.banned_areas[/area/bluespace_locker], "Survival capsules can deploy in the bluespace locker room")

	var/turf/external_turf = get_turf(external)
	TEST_ASSERT_EQUAL(SSbluespace_locker.room_origin.get_virtual_z_level(), external_turf.get_virtual_z_level(), "Bluespace room virtual z does not follow the external locker")
	TEST_ASSERT_EQUAL(SSbluespace_locker.room_reservation.overmap_fallback, external.get_overmap(), "Bluespace room overmap fallback does not follow the external locker")

	var/mirages = 0
	for(var/turf/open/space/bluespace_locker_mirage/M in get_area(internal))
		if(length(M.vis_contents))
			mirages++
	TEST_ASSERT(mirages, "No mirage turf shows the external locker's surroundings")

	var/room_error = room_problem()
	TEST_ASSERT(!room_error, room_error)

	// Exactly one side is open at a time
	TEST_ASSERT_NOTEQUAL(internal.opened, external.opened, "Both sides of the bluespace locker are in the same state")
	if(!external.opened)
		internal.close()
	TEST_ASSERT(external.opened, "Could not open the external locker")
	TEST_ASSERT(!internal.opened, "Internal locker stayed open when the external one opened")

	var/datum/gas_mixture/station_air = external_turf.return_air()
	var/station_pressure = station_air?.return_pressure()

	// Two people go in
	var/mob/living/carbon/human/first = allocate(/mob/living/carbon/human)
	var/mob/living/carbon/human/second = allocate(/mob/living/carbon/human)
	var/obj/item/item = allocate(/obj/item/toy/crayon/red)
	first.forceMove(external_turf)
	second.forceMove(external_turf)
	item.forceMove(external_turf)
	TEST_ASSERT(external.close(), "Could not close the external locker")
	TEST_ASSERT(internal.opened, "Internal locker did not open when the external one closed")
	var/turf/internal_turf = get_turf(internal)
	TEST_ASSERT_EQUAL(first.loc, internal_turf, "First mob did not arrive in the bluespace room")
	TEST_ASSERT_EQUAL(second.loc, internal_turf, "Second mob did not arrive in the bluespace room")
	TEST_ASSERT_EQUAL(item.loc, internal_turf, "Item did not arrive in the bluespace room")
	TEST_ASSERT(!length(external.contents), "External locker kept contents after teleporting them")

	// And come back out
	TEST_ASSERT(internal.close(), "Could not close the internal locker")
	TEST_ASSERT(external.opened, "External locker did not open when the internal one closed")
	TEST_ASSERT_EQUAL(first.loc, external_turf, "First mob did not return from the bluespace room")
	TEST_ASSERT_EQUAL(second.loc, external_turf, "Second mob did not return from the bluespace room")
	TEST_ASSERT_EQUAL(item.loc, external_turf, "Item did not return from the bluespace room")

	// Travelling moves mobs and items only, never air
	room_error = room_problem()
	TEST_ASSERT(!room_error, "After travelling: [room_error]")
	station_air = external_turf.return_air()
	TEST_ASSERT(abs((station_air?.return_pressure() || 0) - (station_pressure || 0)) < 1, "Using the bluespace locker changed the pressure at the external locker")

	// Welded external locker traps people inside the room
	TEST_ASSERT(external.close(), "Could not close the external locker the second time")
	external.welded = TRUE
	TEST_ASSERT(!internal.close(), "Internal locker closed while the external one is welded")
	TEST_ASSERT_EQUAL(first.loc, internal_turf, "Mob left the room through a welded locker")
	external.welded = FALSE

	// Step away from the portal tile - whatever stands on it gets swallowed when the portal closes during relinking
	first.forceMove(SSbluespace_locker.room_origin)
	second.forceMove(SSbluespace_locker.room_origin)

	// Destroying the external locker relinks the room to a new random locker
	qdel(external)
	TEST_ASSERT(isnull(SSbluespace_locker.external_locker), "Destroyed external locker is still referenced")
	sleep(5)
	var/obj/structure/closet/bluespace/external/new_external = SSbluespace_locker.external_locker
	TEST_ASSERT(!QDELETED(new_external), "No new external locker was picked after the old one was destroyed")
	TEST_ASSERT(new_external != external, "The destroyed external locker was reused")
	TEST_ASSERT_EQUAL(SSbluespace_locker.internal_locker, internal, "Internal locker changed after relinking")
	TEST_ASSERT_EQUAL(first.loc, SSbluespace_locker.room_origin, "Mob in the room was moved by relinking")
	var/turf/new_external_turf = get_turf(new_external)
	TEST_ASSERT_EQUAL(SSbluespace_locker.room_origin.get_virtual_z_level(), new_external_turf.get_virtual_z_level(), "Room virtual z did not follow the new external locker")

	room_error = room_problem()
	TEST_ASSERT(!room_error, "After relinking: [room_error]")

	// Leave through the new locker
	if(new_external.opened)
		TEST_ASSERT(new_external.close(), "Could not close the new external locker")
	first.forceMove(internal_turf)
	second.forceMove(internal_turf)
	TEST_ASSERT(internal.close(), "Could not leave the room through the new external locker")
	TEST_ASSERT_EQUAL(first.loc, new_external_turf, "Mob did not leave the room through the new external locker")

/// Returns why the room is not a sealed, breathable space, or null if it is
/datum/unit_test/bluespace_locker/proc/room_problem()
	var/area/A = get_area(SSbluespace_locker.internal_locker)
	for(var/turf/T as anything in SSbluespace_locker.room_reservation.reserved_turfs)
		if(T.loc != A)
			return "Room tile [T.x],[T.y],[T.z] ([T.type]) is not part of the bluespace locker area - the template has a hole"
	var/floors = 0
	for(var/turf/open/T in A)
		if(isspaceturf(T))
			continue
		floors++
		for(var/turf/adjacent as anything in T.atmos_adjacent_turfs)
			if(adjacent.loc != A || isspaceturf(adjacent))
				return "Room tile [T.x],[T.y] shares air with [adjacent.type] at [adjacent.x],[adjacent.y]"
		var/datum/gas_mixture/air = T.return_air()
		var/pressure = air.return_pressure()
		var/total = air.total_moles()
		var/oxygen_pressure = total ? pressure * air.get_moles(GAS_O2) / total : 0
		var/temperature = air.return_temperature()
		if(pressure < 95 || pressure > 110)
			return "Room tile [T.x],[T.y] has unsafe pressure [pressure] kPa"
		if(oxygen_pressure < 16)
			return "Room tile [T.x],[T.y] has too little oxygen ([oxygen_pressure] kPa partial pressure)"
		if(temperature < 283 || temperature > 303)
			return "Room tile [T.x],[T.y] has unsafe temperature [temperature] K"
	if(!floors)
		return "Room has no floor"

#undef TEST_ASSERT
#undef TEST_ASSERT_EQUAL
#undef TEST_ASSERT_NOTEQUAL
