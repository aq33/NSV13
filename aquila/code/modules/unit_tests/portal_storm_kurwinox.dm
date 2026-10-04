// The upstream assert macros are #undef'd at the end of code/modules/unit_tests/_unit_tests.dm, so this modular test carries its own copies
#define TEST_ASSERT(assertion, reason) if (!(assertion)) { return Fail("Assertion failed: [reason || "No reason"]") }

#define TEST_ASSERT_EQUAL(a, b, message) do { \
	var/lhs = ##a; \
	var/rhs = ##b; \
	if (lhs != rhs) { \
		return Fail("Expected [isnull(lhs) ? "null" : lhs] to be equal to [isnull(rhs) ? "null" : rhs].[message ? " [message]" : ""]"); \
	} \
} while (FALSE)

/// Counts every portal flash the storm makes
/datum/round_event/portal_storm/kurwinox/unit_test
	var/portal_effects = 0

/datum/round_event/portal_storm/kurwinox/unit_test/spawn_effects(turf/T)
	portal_effects++
	return ..()

/// A station with nowhere safe to open a portal
/datum/round_event/portal_storm/kurwinox/unit_test/no_turfs/candidate_areas()
	return list()

/// AQUILA - Kurwinox portal storm control: its own settings, and the usual random event gates
/datum/unit_test/kurwinox_portal_storm_control

/datum/unit_test/kurwinox_portal_storm_control/Run()
	var/datum/round_event_control/portal_storm_kurwinox/control = locate() in SSevents.control
	TEST_ASSERT(control, "Kurwinox portal storm is not in the random event pool")
	TEST_ASSERT_EQUAL(control.typepath, /datum/round_event/portal_storm/kurwinox, "Event typepath")
	TEST_ASSERT_EQUAL(control.weight, 5, "Weight")
	TEST_ASSERT_EQUAL(control.min_players, 18, "Minimum players")
	TEST_ASSERT_EQUAL(control.earliest_start, 25 MINUTES, "Earliest start")
	TEST_ASSERT_EQUAL(control.max_occurrences, 1, "Max occurrences")
	TEST_ASSERT(control.cannot_spawn_after_shuttlecall, "Can run after the shuttle is called")

	// Only this control runs the Kurwinox storm, the normal Portal Storm controls are untouched
	for(var/datum/round_event_control/other as anything in SSevents.control)
		if(other == control)
			continue
		TEST_ASSERT(!ispath(other.typepath, /datum/round_event/portal_storm/kurwinox), "[other.type] also runs the Kurwinox storm")

	var/old_earliest = control.earliest_start
	var/old_occurrences = control.occurrences
	var/round_time = world.time - SSticker.round_start_time

	control.occurrences = 0
	control.earliest_start = 0
	var/eligible = control.canSpawnEvent(control.min_players, "")
	var/too_few = control.canSpawnEvent(control.min_players - 1, "")
	control.occurrences = control.max_occurrences
	var/after_limit = control.canSpawnEvent(control.min_players, "")
	control.occurrences = 0
	control.earliest_start = round_time + 1 MINUTES
	var/too_early = control.canSpawnEvent(control.min_players, "")

	control.earliest_start = old_earliest
	control.occurrences = old_occurrences

	TEST_ASSERT(EMERGENCY_IDLE_OR_RECALLED, "The emergency shuttle is not idle during the test, eligibility below is meaningless")
	TEST_ASSERT(eligible, "Not eligible with enough players after the earliest start")
	TEST_ASSERT(!too_few, "Eligible below the minimum player count")
	TEST_ASSERT(!after_limit, "Eligible again after reaching max occurrences")
	TEST_ASSERT(!too_early, "Eligible before the earliest start")
	TEST_ASSERT(!control.canSpawnEvent(control.min_players, ""), "Eligible at roundstart with the real earliest start")

/// AQUILA - force-runs the Kurwinox portal storm several times: only Kurwinoxy, bounded, on valid turfs, and it ends cleanly
/datum/unit_test/kurwinox_portal_storm_run

/datum/unit_test/kurwinox_portal_storm_run/Run()
	for(var/run in 1 to 5)
		var/fail = force_run(run)
		if(fail)
			return Fail("Run [run]: [fail]")

	// Nowhere to open a portal: nothing spawns, nothing is announced, the event ends at once without runtimes
	var/runtimes_before = GLOB.total_runtimes
	var/list/mobs_before = GLOB.mob_living_list.Copy()
	var/datum/round_event/portal_storm/kurwinox/unit_test/no_turfs/empty = new(FALSE)
	TEST_ASSERT(empty.aborted, "Storm without safe turfs was not aborted")
	TEST_ASSERT_EQUAL(empty.announceChance, 0, "Aborted storm would still announce")
	empty.processing = TRUE
	var/steps = 0
	while((empty in SSevents.running) && steps < 10)
		empty.process()
		steps++
	TEST_ASSERT(!(empty in SSevents.running), "Aborted storm kept running")
	TEST_ASSERT_EQUAL(empty.portal_effects, 0, "Aborted storm opened portals")
	TEST_ASSERT_EQUAL(length(GLOB.mob_living_list - mobs_before), 0, "Aborted storm spawned mobs")
	TEST_ASSERT_EQUAL(GLOB.total_runtimes, runtimes_before, "Runtimes in the aborted storm")
	log_test("Kurwinox storm without safe turfs: aborted, ended after [steps] process call(s), 0 portals, 0 mobs, 0 runtimes")

/// Runs one storm start to finish by calling process() ourselves, returns a failure message or null
/datum/unit_test/kurwinox_portal_storm_run/proc/force_run(run)
	var/runtimes_before = GLOB.total_runtimes
	var/list/mobs_before = GLOB.mob_living_list.Copy()

	var/datum/round_event/portal_storm/kurwinox/unit_test/storm = new(FALSE) // not processed by SSevents, we drive it
	if(storm.aborted)
		return "the storm found no safe turf on the test map"
	var/list/spawn_turfs = storm.hostiles_spawn + storm.boss_spawn
	if(length(spawn_turfs) != 10)
		return "expected 10 spawn turfs, got [length(spawn_turfs)]"
	for(var/turf/T as anything in spawn_turfs)
		if(!storm.valid_turf(T))
			return "invalid spawn turf [AREACOORD(T)]"

	storm.processing = TRUE
	var/steps = 0
	var/cost_before = TICK_USAGE
	while((storm in SSevents.running) && steps < 200)
		storm.process()
		steps++
	var/cost = TICK_USAGE - cost_before

	if(storm in SSevents.running)
		return "the storm did not end after [steps] process calls"

	var/list/new_mobs = GLOB.mob_living_list - mobs_before
	var/kurwinoxy = 0
	var/czerwone = 0
	var/list/where = list()
	for(var/mob/living/M as anything in new_mobs)
		if(M.type == /mob/living/simple_animal/hostile/kurwinoxy)
			kurwinoxy++
		else if(M.type == /mob/living/simple_animal/hostile/kurwinoxy/czerwony)
			czerwone++
		else
			return "the storm spawned [M.type]"
		if(!(get_turf(M) in spawn_turfs))
			return "[M] appeared at [AREACOORD(M)], not on a picked spawn turf"
		where += "[get_area_name(M, TRUE)] ([M.x],[M.y],[M.z])"

	// Cleanup: nothing left to spawn, the portals were bounded by the event's lifetime
	var/remaining = length(storm.hostile_types) + length(storm.boss_types) + length(storm.hostiles_spawn) + length(storm.boss_spawn)
	var/effects = storm.portal_effects
	for(var/mob/living/M as anything in new_mobs)
		qdel(M)
	if(kurwinoxy != 8 || czerwone != 2)
		return "expected 8 Kurwinoxy and 2 red ones, got [kurwinoxy] and [czerwone]"
	if(remaining)
		return "[remaining] spawns left over after the storm ended"
	if(effects > steps + 10)
		return "[effects] portal effects in [steps] process calls"
	for(var/mob/living/M as anything in new_mobs)
		if(!QDELETED(M))
			return "[M] was not deleted"
	if(GLOB.total_runtimes != runtimes_before)
		return "[GLOB.total_runtimes - runtimes_before] runtimes during the storm"

	log_test("Kurwinox storm run [run]: [length(spawn_turfs)] spawn turfs, [effects] portal effects, [kurwinoxy] Kurwinoxy + [czerwone] czerwone, ended after [steps] ticks, processing cost [round(cost * world.tick_lag, 0.01)] ms, spawned at: [jointext(where, "; ")]")

#undef TEST_ASSERT
#undef TEST_ASSERT_EQUAL
