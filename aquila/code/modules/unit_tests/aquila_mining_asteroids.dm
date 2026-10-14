// The upstream assert macros are #undef'd at the end of code/modules/unit_tests/_unit_tests.dm, so this modular test carries its own copy
#define TEST_ASSERT(assertion, reason) if (!(assertion)) { return Fail("Assertion failed: [reason || "No reason"]") }
#define ASTEROID_FOLDER "_maps/map_files/Mining/nsv13/asteroids/"
#define RUIN_FOLDER "_maps/map_files/Mining/nsv13/ruins/"

/// AQUILA - KaĹĽda mapa z puli magnesu gĂłrniczego ma 40x40, Ĺ‚aduje siÄ™ bez runtime'Ăłw, a czysta asteroida dostaje rdzeĹ„ rudy
/datum/unit_test/mining_asteroids

/datum/unit_test/mining_asteroids/Run()
	var/total = 0
	for(var/folder in list(ASTEROID_FOLDER, RUIN_FOLDER))
		for(var/file in flist(folder))
			total++
			var/datum/map_template/asteroid/template = new("[folder][file]", null, FALSE, list(/turf/closed/mineral/iron))
			TEST_ASSERT(template.width == 40 && template.height == 40, "[folder][file] is [template.width]x[template.height], the magnet cage needs 40x40")
			// KaĹĽda mapa we wĹ‚asnej rezerwacji i bez sprzÄ…tania: masowe ChangeTurf po zaĹ‚adowaniu wywracaĹ‚o auxmos w CI.
			// Bez Release(): zwolnione pola od razu bierze komora testowa i dostaje w nich 0 kPa
			var/datum/turf_reservation/reservation = SSmapping.RequestBlockReservation(41, 41)
			TEST_ASSERT(reservation, "Could not reserve space for [folder][file]")
			var/turf/bottom_left = locate(reservation.bottom_left_coords[1], reservation.bottom_left_coords[2], reservation.bottom_left_coords[3])
			TEST_ASSERT(template.load(bottom_left, FALSE, TRUE), "[folder][file] failed to load")
			if(folder != ASTEROID_FOLDER)
				continue
			var/core = 0
			for(var/turf/T as anything in template.get_affected_turfs(bottom_left, FALSE))
				if(istype(T, /turf/closed/mineral/iron))
					core++
			TEST_ASSERT(core, "[folder][file] has no rock in the middle, so it never gets an ore core")
	TEST_ASSERT(total, "No asteroid maps found")

#undef TEST_ASSERT
#undef ASTEROID_FOLDER
#undef RUIN_FOLDER
