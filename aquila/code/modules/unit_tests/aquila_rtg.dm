// The upstream assert macros are #undef'd at the end of code/modules/unit_tests/_unit_tests.dm, so this modular test carries its own copies
#define TEST_ASSERT(assertion, reason) if (!(assertion)) { return Fail("Assertion failed: [reason || "No reason"]") }

#define TEST_ASSERT_EQUAL(a, b, message) do { \
	var/lhs = ##a; \
	var/rhs = ##b; \
	if (lhs != rhs) { \
		return Fail("Expected [isnull(lhs) ? "null" : lhs] to be equal to [isnull(rhs) ? "null" : rhs].[message ? " [message]" : ""]"); \
	} \
} while (FALSE)

/// Builds a lone cable node with its own powernet on the given turf
/datum/unit_test/aquila_rtg_anchoring/proc/make_powered_node(turf/location)
	var/obj/structure/cable/node = allocate(/obj/structure/cable, location)
	if(!node.powernet)
		var/datum/powernet/net = new
		net.add_cable(node)
	return node

/// AQUILA - RTGs join their powernet only while anchored (process() hook in aquila/code/modules/power/rtg.dm)
/datum/unit_test/aquila_rtg_anchoring

/datum/unit_test/aquila_rtg_anchoring/Run()
	var/obj/structure/cable/node = make_powered_node(run_loc_floor_bottom_left)
	var/datum/powernet/net = node.powernet
	var/obj/machinery/power/rtg/rtg = allocate(/obj/machinery/power/rtg)
	TEST_ASSERT(rtg.can_be_unanchored, "RTGs can not be unanchored")
	TEST_ASSERT_EQUAL(rtg.powernet, net, "Anchored RTG did not connect to the powernet under it on Initialize")

	net.newavail = 0
	rtg.process()
	TEST_ASSERT_EQUAL(rtg.powernet, net, "Anchored RTG left its powernet while processing")
	TEST_ASSERT_EQUAL(net.newavail, rtg.power_gen, "Anchored RTG did not supply its power")

	rtg.anchored = FALSE
	net.newavail = 0
	rtg.process()
	TEST_ASSERT(isnull(rtg.powernet), "Unanchored RTG stayed on its powernet")
	TEST_ASSERT_EQUAL(net.newavail, 0, "Unanchored RTG still supplied power")

	rtg.anchored = TRUE
	rtg.process()
	TEST_ASSERT_EQUAL(rtg.powernet, net, "Re-anchored RTG did not reconnect to its powernet")
	TEST_ASSERT_EQUAL(net.newavail, rtg.power_gen, "Re-anchored RTG did not supply its power")

#undef TEST_ASSERT
#undef TEST_ASSERT_EQUAL
