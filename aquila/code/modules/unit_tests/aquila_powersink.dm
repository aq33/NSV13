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

/// AQUILA - on_drain(): when the powernet runs short, the sink pulls a flat 50 from every operating APC cell on the net and skips APCs without a cell (hardened)
/datum/unit_test/aquila_powersink_apc_drain

/datum/unit_test/aquila_powersink_apc_drain/Run()
	var/obj/structure/cable/node = allocate(/obj/structure/cable, run_loc_floor_bottom_left)
	// Always a fresh powernet, so only the terminals added below are on it
	var/datum/powernet/net = new
	net.add_cable(node)

	// APC built outside mapload: no area, terminal or cell of its own, so it only exists for the drain loop
	var/obj/machinery/power/apc/apc = make_bare_apc()
	var/obj/item/stock_parts/cell/cell = allocate(/obj/item/stock_parts/cell, apc)
	cell.maxcharge = 1000
	cell.charge = 1000
	apc.cell = cell
	apc.operating = TRUE
	apc.charging = 2 // APC_FULLY_CHARGED
	var/obj/machinery/power/terminal/apc_terminal = allocate(/obj/machinery/power/terminal)
	apc_terminal.master = apc
	net.add_machine(apc_terminal)

	var/obj/machinery/power/apc/empty_apc = make_bare_apc()
	empty_apc.operating = TRUE
	var/obj/machinery/power/terminal/empty_terminal = allocate(/obj/machinery/power/terminal)
	empty_terminal.master = empty_apc
	net.add_machine(empty_terminal)

	var/obj/item/powersink/sink = allocate(/obj/item/powersink)
	sink.attached = node
	var/list/net_contents = list()
	for(var/obj/machinery/power/machine as anything in net.nodes)
		var/obj/machinery/power/terminal/terminal = machine
		var/obj/machinery/power/apc/master = istype(terminal) ? terminal.master : null
		net_contents += "[machine.type][istype(master) ? " -> [REF(master)] cell=[master.cell ? master.cell.charge : "none"]" : ""]"
	var/net_description = jointext(net_contents, ", ")
	var/runtimes_before = GLOB.total_runtimes

	// Enough power on the net: APC cells are left alone
	net.newavail = sink.drain_rate * 2
	sink.process()
	var/full_net_charge = cell.charge
	var/full_net_charging = apc.charging
	var/full_net_drained = sink.power_drained

	// Shortfall: 50 from the APC with a cell, the cell-less APC is skipped
	net.newavail = 0
	sink.process()
	var/short_charge = cell.charge
	var/short_charging = apc.charging
	var/short_drained = sink.power_drained
	var/runtimes = GLOB.total_runtimes - runtimes_before

	apc_terminal.master = null
	empty_terminal.master = null

	TEST_ASSERT_EQUAL(full_net_charge, 1000, "APC cell drained although the powernet covered the full drain rate")
	TEST_ASSERT_EQUAL(full_net_charging, 2, "APC charging state changed although the powernet covered the full drain rate")
	TEST_ASSERT_EQUAL(full_net_drained, sink.drain_rate, "Unexpected drain from a fully powered net")
	TEST_ASSERT_EQUAL(short_charge, 950, "APC cell was not drained by 50 on a powernet shortfall")
	TEST_ASSERT_EQUAL(short_charging, 1, "Drained full APC was not switched back to charging")
	TEST_ASSERT_EQUAL(short_drained, sink.drain_rate + 50, "APC drain was not counted towards the sink (powernet nodes: [net_description])")
	TEST_ASSERT_EQUAL(runtimes, 0, "Runtimes while draining APCs (cell-less APC must be skipped)")

/// An APC with no cell or terminal of its own. Atoms made while a map is loading in the background (ship interiors, templates)
/// initialize as mapload, and a mapload APC builds its own 2250 charge cell and a terminal, which made this test flaky.
/// Built away from the test cable so a terminal it makes can't join the test powernet.
/datum/unit_test/aquila_powersink_apc_drain/proc/make_bare_apc()
	var/obj/machinery/power/apc/apc = allocate(/obj/machinery/power/apc, run_loc_floor_top_right)
	apc.end_processing()
	QDEL_NULL(apc.cell)
	if(apc.terminal)
		apc.terminal.master = null
		QDEL_NULL(apc.terminal)
	return apc

#undef TEST_ASSERT
#undef TEST_ASSERT_EQUAL
