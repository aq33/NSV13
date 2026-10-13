// The upstream assert macros are #undef'd at the end of code/modules/unit_tests/_unit_tests.dm, so this modular test carries its own copies
#define TEST_ASSERT(assertion, reason) if (!(assertion)) { return Fail("Assertion failed: [reason || "No reason"]") }

#define TEST_ASSERT_EQUAL(a, b, message) do { \
	var/lhs = ##a; \
	var/rhs = ##b; \
	if (lhs != rhs) { \
		return Fail("Expected [isnull(lhs) ? "null" : lhs] to be equal to [isnull(rhs) ? "null" : rhs].[message ? " [message]" : ""]"); \
	} \
} while (FALSE)

/// AQUILA - weighted rotation: pool chances follow the survey tilt, and empty pools get nothing
/datum/unit_test/aquila_weighted_pool_odds

/datum/unit_test/aquila_weighted_pool_odds/Run()
	var/datum/weighted_rotation/rotation = new
	var/list/all_pools = list(WEIGHTED_POOL_LOW, WEIGHTED_POOL_MEDIUM, WEIGHTED_POOL_HIGH)

	rotation.bias = 0
	var/list/odds = rotation.pool_odds(all_pools)
	TEST_ASSERT_EQUAL(odds[WEIGHTED_POOL_LOW], 33, "Neutral low pool")
	TEST_ASSERT_EQUAL(odds[WEIGHTED_POOL_MEDIUM], 33, "Neutral medium pool")
	TEST_ASSERT_EQUAL(odds[WEIGHTED_POOL_HIGH], 33, "Neutral high pool")

	rotation.bias = 1
	odds = rotation.pool_odds(all_pools)
	TEST_ASSERT_EQUAL(odds[WEIGHTED_POOL_LOW], 17, "Chaos-hungry low pool")
	TEST_ASSERT_EQUAL(odds[WEIGHTED_POOL_HIGH], 50, "Chaos-hungry high pool")

	rotation.bias = -1
	odds = rotation.pool_odds(all_pools)
	TEST_ASSERT_EQUAL(odds[WEIGHTED_POOL_LOW], 50, "Calm-seeking low pool")
	TEST_ASSERT_EQUAL(odds[WEIGHTED_POOL_HIGH], 17, "Calm-seeking high pool")

	rotation.bias = 0
	odds = rotation.pool_odds(list(WEIGHTED_POOL_LOW, WEIGHTED_POOL_HIGH))
	TEST_ASSERT_EQUAL(odds[WEIGHTED_POOL_MEDIUM], 0, "An empty pool")
	TEST_ASSERT_EQUAL(odds[WEIGHTED_POOL_LOW], 50, "Low pool next to an empty one")

	qdel(rotation)

/// AQUILA - weighted rotation: the antagonist limit only lowers amounts, and only when it is set
/datum/unit_test/aquila_weighted_antag_cap

/datum/unit_test/aquila_weighted_antag_cap/Run()
	var/datum/game_mode/traitor/mode = new
	TEST_ASSERT_EQUAL(mode.weighted_cap(5), 5, "No limit")
	mode.weighted_antag_cap = 2
	TEST_ASSERT_EQUAL(mode.weighted_cap(5), 2, "Limit of 2")
	TEST_ASSERT_EQUAL(mode.weighted_cap(1), 1, "Under the limit")
	mode.weighted_antag_cap = 0
	TEST_ASSERT_EQUAL(mode.weighted_cap(3), 0, "Used up limit")
	qdel(mode)

/// AQUILA - maps without xeno_spawn/blobstart get safe station turfs instead
/datum/unit_test/aquila_fallback_spawn_turfs

/datum/unit_test/aquila_fallback_spawn_turfs/Run()
	var/list/turfs = aquila_fallback_spawn_turfs(5)
	TEST_ASSERT(length(turfs), "No fallback spawn turf found on the station")
	TEST_ASSERT(length(turfs) <= 5, "More fallback turfs than asked for")
	for(var/turf/T as anything in turfs)
		TEST_ASSERT(is_station_level(T.z), "Fallback turf [AREACOORD(T)] is not on the station")
		TEST_ASSERT(is_turf_safe(T), "Fallback turf [AREACOORD(T)] is not safe")

#undef TEST_ASSERT
#undef TEST_ASSERT_EQUAL
