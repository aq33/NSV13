// The upstream assert macros are #undef'd at the end of code/modules/unit_tests/_unit_tests.dm, so this modular test carries its own copies
#define TEST_ASSERT(assertion, reason) if (!(assertion)) { return Fail("Assertion failed: [reason || "No reason"]") }

#define TEST_ASSERT_EQUAL(a, b, message) do { \
	var/lhs = ##a; \
	var/rhs = ##b; \
	if (lhs != rhs) { \
		return Fail("Expected [isnull(lhs) ? "null" : lhs] to be equal to [isnull(rhs) ? "null" : rhs].[message ? " [message]" : ""]"); \
	} \
} while (FALSE)

/// AQUILA - Smartwires (port BeeStation/BeeStation-Hornet#14275): cables link up with neighbours of their colour, nodes sit on cable ends, cuts split the powernet
/datum/unit_test/smartwires

/datum/unit_test/smartwires/Run()
	var/turf/start = run_loc_floor_bottom_left
	var/turf/east_1 = locate(start.x + 1, start.y, start.z)
	var/turf/east_2 = locate(start.x + 2, start.y, start.z)
	var/turf/north = locate(start.x, start.y + 1, start.z)
	var/turf/north_east = locate(start.x + 1, start.y + 1, start.z)

	// A straight red line: one powernet, nodes only on the ends
	var/obj/structure/cable/left = allocate(/obj/structure/cable, start)
	var/obj/structure/cable/middle = allocate(/obj/structure/cable, east_1)
	var/obj/structure/cable/right = allocate(/obj/structure/cable, east_2)
	TEST_ASSERT(left.powernet, "A cable laid at runtime did not get a powernet")
	TEST_ASSERT_EQUAL(left.powernet, middle.powernet, "Adjacent red cables are not in one powernet")
	TEST_ASSERT_EQUAL(middle.powernet, right.powernet, "Adjacent red cables are not in one powernet")
	TEST_ASSERT_EQUAL(middle.linked_dirs, EAST|WEST, "The middle cable did not link both ways")
	TEST_ASSERT(left.has_power_node, "The west end of the line has no power node")
	TEST_ASSERT(right.has_power_node, "The east end of the line has no power node")
	TEST_ASSERT(!middle.has_power_node, "A cable running through a tile got a power node")

	// Another colour next to it stays separate
	var/obj/structure/cable/yellow/other = allocate(/obj/structure/cable/yellow, north)
	TEST_ASSERT(other.powernet != left.powernet, "A yellow cable joined the red powernet")
	TEST_ASSERT_EQUAL(other.linked_dirs, NONE, "A yellow cable linked to a red one")

	// An omni cable joins both colours
	var/obj/structure/cable/omni/bridge = allocate(/obj/structure/cable/omni, north_east)
	TEST_ASSERT_EQUAL(bridge.powernet, middle.powernet, "The omni cable did not join the red cable under it")
	TEST_ASSERT_EQUAL(bridge.powernet, other.powernet, "The omni cable did not join the yellow cable next to it")
	qdel(bridge)

	// Forcing a node keeps it on a cable that runs through
	middle.add_power_node()
	TEST_ASSERT(middle.has_power_node, "add_power_node() did not give the cable a node")
	TEST_ASSERT(start.get_cable_node() == left, "get_cable_node() did not return the node cable")

	// Cutting the middle splits the line once the powernet is recalculated
	qdel(middle)
	var/datum/powernet/net = left.powernet
	TEST_ASSERT(net.dirty, "Cutting a cable did not queue the powernet for recalculation")
	SSmachines.dirty_powernets -= net
	net.dirty = FALSE
	net.repropogate_cables()
	TEST_ASSERT(left.powernet != right.powernet, "Cutting the middle cable did not split the powernet")
	TEST_ASSERT(right.has_power_node, "The east cable lost its node")

#undef TEST_ASSERT
#undef TEST_ASSERT_EQUAL
