// The upstream assert macros are #undef'd at the end of code/modules/unit_tests/_unit_tests.dm, so this modular test carries its own copies
#define TEST_ASSERT(assertion, reason) if (!(assertion)) { return Fail("Assertion failed: [reason || "No reason"]") }

#define TEST_ASSERT_EQUAL(a, b, message) do { \
	var/lhs = ##a; \
	var/rhs = ##b; \
	if (lhs != rhs) { \
		return Fail("Expected [isnull(lhs) ? "null" : lhs] to be equal to [isnull(rhs) ? "null" : rhs].[message ? " [message]" : ""]"); \
	} \
} while (FALSE)

/// AQUILA - ethanol hydration scales down with booze power (moved from code/modules/reagents/chemistry/reagents/alcohol_reagents.dm)
/datum/unit_test/aquila_ethanol_hydration

/datum/unit_test/aquila_ethanol_hydration/Run()
	var/datum/reagent/consumable/ethanol/booze = new /datum/reagent/consumable/ethanol/beer
	TEST_ASSERT_EQUAL(booze.get_hydration_factor(), LERP(15, 0, booze.boozepwr / 100), "Beer hydration does not follow its booze power")
	qdel(booze)
	booze = new /datum/reagent/consumable/ethanol
	TEST_ASSERT_EQUAL(booze.get_hydration_factor(), LERP(15, 0, 0.65), "Ethanol hydration does not follow its booze power")
	qdel(booze)

#undef TEST_ASSERT
#undef TEST_ASSERT_EQUAL
