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
/datum/unit_test/aquila_powersink_drain/proc/make_powered_node(turf/location)
	var/obj/structure/cable/node = allocate(/obj/structure/cable, location)
	if(!node.powernet)
		var/datum/powernet/net = new
		net.add_cable(node)
	return node

/// AQUILA - power sinks drain through core process() and the modular on_drain() hook; infiltrator sinks count the drained power towards their objective
/datum/unit_test/aquila_powersink_drain

/datum/unit_test/aquila_powersink_drain/Run()
	var/obj/structure/cable/node = make_powered_node(run_loc_floor_bottom_left)
	var/datum/powernet/net = node.powernet
	TEST_ASSERT(net, "Test cable has no powernet")

	var/obj/item/powersink/sink = allocate(/obj/item/powersink)
	sink.attached = node

	// Enough power on the net: drain the full rate, all of it as delayed load
	net.newavail = sink.drain_rate * 2
	sink.process()
	TEST_ASSERT_EQUAL(sink.power_drained, sink.drain_rate, "Power sink did not drain its full rate from a powered net")
	TEST_ASSERT_EQUAL(net.delayedload, sink.drain_rate, "Power sink drain was not applied as delayed load")

	// Shortfall with no APCs on the net: only what is available gets drained
	net.newavail = 1000
	sink.process()
	TEST_ASSERT_EQUAL(sink.power_drained, sink.drain_rate + 1000, "Power sink drained more than was available")

	// Infiltrator sinks report every drain tick, shortfall or not
	var/obj/item/powersink/infiltrator/transmitter = allocate(/obj/item/powersink/infiltrator)
	transmitter.attached = node
	transmitter.target = INFINITY
	var/transmitted_before = GLOB.powersink_transmitted
	net.newavail = transmitter.drain_rate * 2
	transmitter.process()
	net.newavail = 500
	transmitter.process()
	var/transmitted = GLOB.powersink_transmitted - transmitted_before
	GLOB.powersink_transmitted = transmitted_before
	TEST_ASSERT_EQUAL(transmitted, transmitter.drain_rate + 500, "Infiltrator power sink did not count drained power towards its objective")
	TEST_ASSERT_EQUAL(transmitter.power_drained, transmitter.drain_rate + 500, "Infiltrator power sink drained a different amount than it counted")

#undef TEST_ASSERT
#undef TEST_ASSERT_EQUAL
