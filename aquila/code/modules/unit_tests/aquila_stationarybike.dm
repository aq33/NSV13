// The upstream assert macros are #undef'd at the end of code/modules/unit_tests/_unit_tests.dm, so this modular test carries its own copies
#define TEST_ASSERT(assertion, reason) if (!(assertion)) { return Fail("Assertion failed: [reason || "No reason"]") }

#define TEST_ASSERT_EQUAL(a, b, message) do { \
	var/lhs = ##a; \
	var/rhs = ##b; \
	if (lhs != rhs) { \
		return Fail("Expected [isnull(lhs) ? "null" : lhs] to be equal to [isnull(rhs) ? "null" : rhs].[message ? " [message]" : ""]"); \
	} \
} while (FALSE)

/// AQUILA - Stationary bike (port Yogstation #9163) powers its net only while a living mob is buckled to it
/datum/unit_test/aquila_stationarybike

/datum/unit_test/aquila_stationarybike/Run()
	var/obj/structure/cable/node = allocate(/obj/structure/cable, run_loc_floor_bottom_left)
	if(!node.powernet)
		var/datum/powernet/new_net = new
		new_net.add_cable(node)
	var/datum/powernet/net = node.powernet
	var/obj/machinery/power/stationarybike/bike = allocate(/obj/machinery/power/stationarybike, run_loc_floor_bottom_left)
	TEST_ASSERT_EQUAL(bike.powernet, net, "Anchored bike did not connect to the powernet under it on Initialize")

	var/mob/living/carbon/monkey/runner = allocate(/mob/living/carbon/monkey, run_loc_floor_bottom_left)
	TEST_ASSERT(bike.buckle_mob(runner, TRUE), "Could not buckle a monkey to the bike")
	bike.check_buckled()
	TEST_ASSERT_EQUAL(bike.operating, bike.simple_power, "Bike did not start for a buckled monkey")

	net.newavail = 0
	bike.process()
	TEST_ASSERT_EQUAL(net.newavail, bike.simple_power * bike.power_exponent, "Bike did not supply power")

	bike.unbuckle_mob(runner, TRUE)
	TEST_ASSERT_EQUAL(bike.operating, 0, "Bike kept running after its runner was unbuckled")
	net.newavail = 0
	bike.process()
	TEST_ASSERT_EQUAL(net.newavail, 0, "Empty bike still supplied power")

#undef TEST_ASSERT
#undef TEST_ASSERT_EQUAL
