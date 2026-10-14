// The upstream assert macros are #undef'd at the end of code/modules/unit_tests/_unit_tests.dm, so this modular test carries its own copy
#define TEST_ASSERT(assertion, reason) if (!(assertion)) { return Fail("Assertion failed: [reason || "No reason"]") }
#define ASTEROID_FOLDER "_maps/map_files/Mining/nsv13/asteroids/"
#define RUIN_FOLDER "_maps/map_files/Mining/nsv13/ruins/"

/// AQUILA - Każda mapa z puli magnesu górniczego ma 40x40, ładuje się bez runtime'ów, a czysta asteroida dostaje rdzeń rudy
/datum/unit_test/mining_asteroids

/datum/unit_test/mining_asteroids/Run()
	var/datum/turf_reservation/reservation = SSmapping.RequestBlockReservation(41, 41)
	TEST_ASSERT(reservation, "Could not reserve space for the asteroid maps")
	var/turf/bottom_left = locate(reservation.bottom_left_coords[1], reservation.bottom_left_coords[2], reservation.bottom_left_coords[3])
	var/total = 0
	for(var/folder in list(ASTEROID_FOLDER, RUIN_FOLDER))
		for(var/file in flist(folder))
			total++
			var/datum/map_template/asteroid/template = new("[folder][file]", null, FALSE, list(/turf/closed/mineral/iron))
			TEST_ASSERT(template.width == 40 && template.height == 40, "[folder][file] is [template.width]x[template.height], the magnet cage needs 40x40")
			template.load(bottom_left, FALSE, TRUE)
			var/core = 0
			for(var/turf/T as anything in template.get_affected_turfs(bottom_left, FALSE))
				if(istype(T, /turf/closed/mineral/iron))
					core++
				for(var/atom/movable/AM as anything in T.contents)
					qdel(AM)
				T.ChangeTurf(reservation.turf_type)
			if(folder == ASTEROID_FOLDER)
				TEST_ASSERT(core, "[folder][file] has no rock in the middle, so it never gets an ore core")
	TEST_ASSERT(total, "No asteroid maps found")
	// Bez Release(): zwolnione pola od razu bierze komora testowa i dostaje w nich 0 kPa

#undef TEST_ASSERT
#undef ASTEROID_FOLDER
#undef RUIN_FOLDER
