// The upstream assert macros are #undef'd at the end of code/modules/unit_tests/_unit_tests.dm, so this modular test carries its own copy
#define TEST_ASSERT(assertion, reason) if (!(assertion)) { return Fail("Assertion failed: [reason || "No reason"]") }
#define ASTEROID_FOLDER "_maps/map_files/Mining/nsv13/asteroids/"
#define RUIN_FOLDER "_maps/map_files/Mining/nsv13/ruins/"

/// AQUILA - KaĹĽda mapa z puli magnesu gĂłrniczego ma 40x40, Ĺ‚aduje siÄ™ bez runtime'Ăłw, a czysta asteroida dostaje rdzeĹ„ rudy
/datum/unit_test/mining_asteroids

/datum/unit_test/mining_asteroids/Run()
	// Wątek auxmos wywołuje set_visuals na turfach, które ładowanie mapy właśnie podmieniło - przy tylu mapach
	// pod rząd wywracało to DreamDaemona w CI. Atmosfera stoi, dopóki wszystkie mapy się nie załadują.
	SSair.can_fire = FALSE
	UNTIL(!SSair.thread_running())
	sleep(1 SECONDS) // SScallbacks zdąży oddać zaległe wywołania z poprzednich testów
	SScallbacks.can_fire = FALSE
	var/error = load_all_maps()
	SScallbacks.can_fire = TRUE
	SSair.can_fire = TRUE
	TEST_ASSERT(!error, error)

/// Zwraca opis pierwszego błędu albo null
/datum/unit_test/mining_asteroids/proc/load_all_maps()
	var/total = 0
	for(var/folder in list(ASTEROID_FOLDER, RUIN_FOLDER))
		for(var/file in flist(folder))
			total++
			var/datum/map_template/asteroid/template = new("[folder][file]", null, FALSE, list(/turf/closed/mineral/iron))
			if(template.width != 40 || template.height != 40)
				return "[folder][file] is [template.width]x[template.height], the magnet cage needs 40x40"
			// Każda mapa we własnej rezerwacji i bez sprzątania. Bez Release(): zwolnione pola od razu bierze komora testowa i dostaje w nich 0 kPa
			var/datum/turf_reservation/reservation = SSmapping.RequestBlockReservation(41, 41)
			if(!reservation)
				return "Could not reserve space for [folder][file]"
			var/turf/bottom_left = locate(reservation.bottom_left_coords[1], reservation.bottom_left_coords[2], reservation.bottom_left_coords[3])
			if(!template.load(bottom_left, FALSE, TRUE))
				return "[folder][file] failed to load"
			if(folder != ASTEROID_FOLDER)
				continue
			var/core = 0
			for(var/turf/T as anything in template.get_affected_turfs(bottom_left, FALSE))
				if(istype(T, /turf/closed/mineral/iron))
					core++
			if(!core)
				return "[folder][file] has no rock in the middle, so it never gets an ore core"
	if(!total)
		return "No asteroid maps found"

#undef TEST_ASSERT
#undef ASTEROID_FOLDER
#undef RUIN_FOLDER
