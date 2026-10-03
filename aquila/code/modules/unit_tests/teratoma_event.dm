// The upstream assert macros are #undef'd at the end of code/modules/unit_tests/_unit_tests.dm, so this modular test carries its own copies
#define TEST_ASSERT(assertion, reason) if (!(assertion)) { return Fail("Assertion failed: [reason || "No reason"]") }

#define TEST_ASSERT_EQUAL(a, b, message) do { \
	var/lhs = ##a; \
	var/rhs = ##b; \
	if (lhs != rhs) { \
		return Fail("Expected [isnull(lhs) ? "null" : lhs] to be equal to [isnull(rhs) ? "null" : rhs].[message ? " [message]" : ""]"); \
	} \
} while (FALSE)

/// AQUILA - Living Tumor event: only safe station maintenance turfs, on the real map, and exactly one spawner
/datum/unit_test/teratoma_event_turfs

/datum/unit_test/teratoma_event_turfs/Run()
	var/runtimes_before = GLOB.total_runtimes
	var/datum/round_event/aquila_teratoma/event = new(FALSE) // not processing, we call the procs ourselves
	var/list/candidates = event.candidate_turfs()
	TEST_ASSERT(length(candidates), "No candidate turf in the station's maintenance")
	var/static/list/excluded_areas = typecacheof(list(/area/maintenance/solars, /area/maintenance/disposal, /area/maintenance/department/science/xenobiology))
	for(var/turf/T as anything in candidates)
		var/area/A = get_area(T)
		TEST_ASSERT(istype(A, /area/maintenance), "Candidate [AREACOORD(T)] is not maintenance")
		TEST_ASSERT(!is_type_in_typecache(A, excluded_areas), "Candidate [AREACOORD(T)] is in an excluded maintenance area")
		TEST_ASSERT(is_station_level(T.z), "Candidate [AREACOORD(T)] is not on the station")
		TEST_ASSERT(isfloorturf(T) && !T.density, "Candidate [AREACOORD(T)] is not an open floor")
		TEST_ASSERT(!is_blocked_turf(T), "Candidate [AREACOORD(T)] is blocked")
		TEST_ASSERT(is_turf_safe(T), "Candidate [AREACOORD(T)] has no breathable air")

	// Outside maintenance is never valid: the test room, and a floor of some other station area
	TEST_ASSERT(!event.valid_turf(run_loc_floor_bottom_left), "The unit test room counted as maintenance")
	var/turf/other_floor
	for(var/area/A as anything in GLOB.sortedAreas)
		if(istype(A, /area/maintenance))
			continue
		for(var/turf/open/floor/F in A)
			if(is_station_level(F.z) && is_turf_safe(F) && !is_blocked_turf(F))
				other_floor = F
				break
		if(other_floor)
			break
	if(other_floor)
		TEST_ASSERT(!event.valid_turf(other_floor), "A floor in [get_area(other_floor)] counted as maintenance")

	// Walls inside maintenance are never valid
	var/turf/maint_wall
	for(var/area/maintenance/A in GLOB.sortedAreas)
		for(var/turf/closed/W in A)
			if(is_station_level(W.z))
				maint_wall = W
				break
		if(maint_wall)
			break
	if(maint_wall)
		TEST_ASSERT(!event.valid_turf(maint_wall), "A maintenance wall at [AREACOORD(maint_wall)] counted as valid")

	// A dense object or another spawner on the turf makes it invalid, removing them makes it valid again
	var/turf/spot = candidates[1]
	TEST_ASSERT(event.valid_turf(spot), "First candidate is not valid")
	var/obj/structure/table/table = allocate(/obj/structure/table, spot)
	TEST_ASSERT(!event.valid_turf(spot), "A turf with a table counted as valid")
	qdel(table)
	TEST_ASSERT(event.valid_turf(spot), "Turf stayed invalid after the table was removed")
	var/obj/effect/mob_spawn/teratomamonkey/existing = allocate(/obj/effect/mob_spawn/teratomamonkey, spot)
	TEST_ASSERT(!event.valid_turf(spot), "A turf with a spawner on it counted as valid")
	qdel(existing)

	// The event puts exactly one fleshy mass on one of the candidates
	var/spawners_before = length(GLOB.mob_spawners["fleshy mass"])
	var/obj/effect/mob_spawn/teratomamonkey/mass = event.spawn_mass()
	TEST_ASSERT(mass, "The event spawned nothing")
	allocated += mass
	TEST_ASSERT(get_turf(mass) in candidates, "The event spawned outside the candidate turfs, at [AREACOORD(mass)]")
	TEST_ASSERT_EQUAL(length(GLOB.mob_spawners["fleshy mass"]), spawners_before + 1, "The event did not spawn exactly one spawner")
	var/masses_on_turf = 0
	for(var/obj/effect/mob_spawn/teratomamonkey/M in get_turf(mass))
		masses_on_turf++
	TEST_ASSERT_EQUAL(masses_on_turf, 1, "More than one fleshy mass on the picked turf")
	qdel(mass)
	event.kill()
	TEST_ASSERT_EQUAL(GLOB.total_runtimes, runtimes_before, "Runtimes during the event")

/// AQUILA - Living Tumor event: the natural spawn limits
/datum/unit_test/teratoma_event_limits

/datum/unit_test/teratoma_event_limits/Run()
	var/datum/round_event_control/aquila_teratoma/registered = locate() in SSevents.control
	TEST_ASSERT(registered, "The event is not in the random event pool")
	TEST_ASSERT_EQUAL(initial(registered.max_occurrences), 1, "The event can happen more than once per round")
	TEST_ASSERT(initial(registered.min_players) >= 15 && initial(registered.min_players) <= 20, "Minimum population out of the 15-20 range")
	TEST_ASSERT(initial(registered.earliest_start) >= 20 MINUTES && initial(registered.earliest_start) <= 30 MINUTES, "Earliest start out of the 20-30 minute range")

	var/datum/round_event_control/aquila_teratoma/control = new
	control.earliest_start = 0 // the test round is young, only the other limits are checked here
	var/players = control.min_players + 5
	var/gamemode = SSticker.mode?.config_tag
	TEST_ASSERT(control.canSpawnEvent(players, gamemode), "The event cannot spawn even with every requirement met")
	TEST_ASSERT(!control.canSpawnEvent(control.min_players - 1, gamemode), "The event can spawn below the minimum population")
	control.occurrences = control.max_occurrences
	TEST_ASSERT(!control.canSpawnEvent(players, gamemode), "The event can spawn again after reaching max_occurrences")
	control.occurrences = 0
	var/old_flags = GLOB.ghost_role_flags
	GLOB.ghost_role_flags &= ~GHOSTROLE_SPAWNER
	var/spawns_without_ghost_roles = control.canSpawnEvent(players, gamemode)
	GLOB.ghost_role_flags = old_flags
	TEST_ASSERT(!spawns_without_ghost_roles, "The event can spawn while admins have disabled ghost spawners")
	control.earliest_start = initial(control.earliest_start)
	if(world.time - SSticker.round_start_time <= control.earliest_start)
		TEST_ASSERT(!control.canSpawnEvent(players, gamemode), "The event can spawn before its earliest start")
	qdel(control)

/// AQUILA - teratoma ghost role: role bans apply, and a living maintenance tumor does not hold the round open
/datum/unit_test/teratoma_ghost_role_safety

/datum/unit_test/teratoma_ghost_role_safety/Run()
	var/obj/effect/mob_spawn/teratomamonkey/spawner = allocate(/obj/effect/mob_spawn/teratomamonkey)
	TEST_ASSERT_EQUAL(spawner.banType, ROLE_TERATOMA, "The spawner does not check the Teratoma role ban")
	TEST_ASSERT(check_role_ban(list(ROLE_TERATOMA), spawner.banType), "A Teratoma ban does not stop the spawner")
	TEST_ASSERT(check_role_ban(list(BAN_ROLE_ALL_ANTAGONISTS), spawner.banType), "An all-antagonists ban does not stop the spawner")
	TEST_ASSERT(!check_role_ban(list(), spawner.banType), "An unbanned player is stopped by the spawner")

	var/mob/living/carbon/monkey/tumor/tumor = allocate(/mob/living/carbon/monkey/tumor)
	var/datum/mind/mind = new("aquila_teratoma_test")
	mind.current = tumor
	tumor.mind = mind
	var/datum/antagonist/antag = mind.add_antag_datum(spawner.antagonist_type)
	TEST_ASSERT(antag, "The tumor did not get its antagonist datum")
	// Same checks as /datum/game_mode/proc/check_finished
	TEST_ASSERT(!antag.delay_roundend, "A maintenance teratoma delays the round end")
	TEST_ASSERT(!antag.prevent_roundtype_conversion, "A maintenance teratoma prevents round type conversion")
	var/datum/antagonist/teratoma/ling_teratoma = /datum/antagonist/teratoma
	TEST_ASSERT(initial(ling_teratoma.delay_roundend), "The changeling teratoma lost its round end delay")
	mind.remove_antag_datum(antag.type)
	tumor.mind = null
	mind.current = null

/// AQUILA - teratoma spawners share one ghost alert cooldown, quiet spawners still work
/datum/unit_test/teratoma_notification_cooldown

/datum/unit_test/teratoma_notification_cooldown/Run()
	var/turf/spot = run_loc_floor_bottom_left
	var/list/already_there = spot.contents.Copy() // the test harness keeps its landmark here, never delete it
	var/obj/effect/mob_spawn/teratomamonkey/first = allocate(/obj/effect/mob_spawn/teratomamonkey)
	COOLDOWN_RESET(first, ghost_notify_cooldown) // whatever earlier tests spawned
	qdel(first)

	var/obj/effect/mob_spawn/teratomamonkey/loud = allocate(/obj/effect/mob_spawn/teratomamonkey)
	TEST_ASSERT(loud.ghosts_notified, "The first spawner did not alert the ghosts")
	var/cooldown_end = loud.ghost_notify_cooldown
	TEST_ASSERT(cooldown_end > world.time, "No cooldown after an alert")
	TEST_ASSERT(cooldown_end - world.time >= 2 MINUTES && cooldown_end - world.time <= 3 MINUTES, "Cooldown out of the 2-3 minute range")

	var/obj/effect/mob_spawn/teratomamonkey/quiet = allocate(/obj/effect/mob_spawn/teratomamonkey)
	TEST_ASSERT(!quiet.ghosts_notified, "A second spawner alerted the ghosts during the cooldown")
	TEST_ASSERT_EQUAL(quiet.ghost_notify_cooldown, cooldown_end, "A quiet spawner moved the cooldown")
	// It still works like any other spawner
	TEST_ASSERT(quiet in GLOB.mob_spawners[quiet.name], "A quiet spawner is missing from the spawner menu")
	TEST_ASSERT(quiet in GLOB.poi_list, "A quiet spawner is missing from the ghost orbit list")
	TEST_ASSERT_EQUAL(quiet.uses, 1, "A quiet spawner has no use left")
	TEST_ASSERT(quiet.ghost_usable, "A quiet spawner is not usable by ghosts")
	quiet.create()
	var/tumors = 0
	for(var/mob/living/carbon/monkey/tumor/T in spot)
		tumors++
		qdel(T)
	TEST_ASSERT_EQUAL(tumors, 1, "A quiet spawner did not make a living tumor")
	TEST_ASSERT(QDELETED(quiet), "A quiet spawner was not used up")

	// Once the cooldown is over the next spawner alerts again
	loud.ghost_notify_cooldown = world.time - 1
	var/obj/effect/mob_spawn/teratomamonkey/later = allocate(/obj/effect/mob_spawn/teratomamonkey)
	TEST_ASSERT(later.ghosts_notified, "No alert after the cooldown ended")
	for(var/atom/movable/spawned in spot)
		if(!(spawned in already_there) && !(spawned in allocated))
			qdel(spawned)

#undef TEST_ASSERT
#undef TEST_ASSERT_EQUAL
