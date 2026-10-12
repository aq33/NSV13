// The upstream assert macros are #undef'd at the end of code/modules/unit_tests/_unit_tests.dm, so this modular test carries its own copies
#define TEST_ASSERT(assertion, reason) if (!(assertion)) { return Fail("Assertion failed: [reason || "No reason"]") }

#define TEST_ASSERT_EQUAL(a, b, message) do { \
	var/lhs = ##a; \
	var/rhs = ##b; \
	if (lhs != rhs) { \
		return Fail("Expected [isnull(lhs) ? "null" : lhs] to be equal to [isnull(rhs) ? "null" : rhs].[message ? " [message]" : ""]"); \
	} \
} while (FALSE)

/// AQUILA - BeeStation#12738/#13722: ghost role polls run through SSpolling and the old poll procs still work
/datum/unit_test/aquila_ghost_polls

/datum/unit_test/aquila_ghost_polls/Run()
	// The role shown on the alert comes from the role preference, then from the ban key
	TEST_ASSERT_EQUAL(poll_role_name(ROLE_ALIEN, null), ROLE_ALIEN, "Wrong role name from the ban key")
	TEST_ASSERT_EQUAL(poll_role_name(BAN_ROLE_ALL_ANTAGONISTS, null), null, "The generic antagonist ban key should not be shown as a role")
	var/datum/role_preference/pirate_preference = /datum/role_preference/midround_ghost/space_pirate
	TEST_ASSERT_EQUAL(poll_role_name(ROLE_SPACE_PIRATE, pirate_preference), initial(pirate_preference.name), "Wrong role name from the role preference")

	// Nobody to ask: the old proc returns an empty list right away instead of sleeping
	var/started = world.time
	var/list/result = pollCandidates("Test?", group = list())
	TEST_ASSERT(islist(result) && !length(result), "An empty poll did not return an empty list")
	TEST_ASSERT_EQUAL(world.time, started, "An empty poll slept")

	// Clientless mobs never get the alert and are never picked; the poll ends after its time
	var/mob/living/carbon/human/dummy = allocate(/mob/living/carbon/human)
	var/polls_before = SSpolling.total_polls
	result = pollCandidates("Test?", poll_time = 2 SECONDS, group = list(dummy))
	TEST_ASSERT(islist(result) && !length(result), "A clientless mob was picked by a poll")
	TEST_ASSERT_EQUAL(SSpolling.total_polls, polls_before + 1, "The poll did not go through SSpolling")
	TEST_ASSERT(!length(SSpolling.currently_polling), "The finished poll is still running")
	for(var/category in dummy.alerts)
		TEST_ASSERT(!findtext(category, "_poll_alert"), "A clientless mob got a poll alert")

	// Poll alerts use their own timeout
	var/atom/movable/screen/alert/poll_alert/alert = dummy.throw_alert("test_poll_alert", /atom/movable/screen/alert/poll_alert, timeout_override = 5 SECONDS, no_anim = TRUE)
	TEST_ASSERT(alert, "throw_alert() did not create the poll alert")
	TEST_ASSERT(alert.timeout > world.time + 4 SECONDS && alert.timeout <= world.time + 5 SECONDS, "timeout_override was ignored: [alert.timeout - world.time]")
	dummy.clear_alert("test_poll_alert")

#undef TEST_ASSERT
#undef TEST_ASSERT_EQUAL
