// The upstream assert macros are #undef'd at the end of code/modules/unit_tests/_unit_tests.dm, so this modular test carries its own copies
#define TEST_ASSERT(assertion, reason) if (!(assertion)) { return Fail("Assertion failed: [reason || "No reason"]") }

#define TEST_ASSERT_EQUAL(a, b, message) do { \
	var/lhs = ##a; \
	var/rhs = ##b; \
	if (lhs != rhs) { \
		return Fail("Expected [isnull(lhs) ? "null" : lhs] to be equal to [isnull(rhs) ? "null" : rhs].[message ? " [message]" : ""]"); \
	} \
} while (FALSE)

/// AQUILA - the mouse round-end report only shows up once mice ate something (moved from code/__HELPERS/roundend.dm)
/datum/unit_test/aquila_mouse_report

/datum/unit_test/aquila_mouse_report/Run()
	var/old_eaten = GLOB.mouse_food_eaten
	GLOB.mouse_food_eaten = 0
	var/empty_report = SSticker.mouse_report()
	GLOB.mouse_food_eaten = 3
	var/report = SSticker.mouse_report()
	GLOB.mouse_food_eaten = old_eaten
	TEST_ASSERT_EQUAL(empty_report, "", "Mouse report shown although no mouse ate anything")
	TEST_ASSERT(findtext(report, "Trash Eaten: 3"), "Mouse report is missing the eaten trash count")

#undef TEST_ASSERT
#undef TEST_ASSERT_EQUAL
