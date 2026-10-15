// The upstream assert macros are #undef'd at the end of code/modules/unit_tests/_unit_tests.dm, so this modular test carries its own copies
#define TEST_ASSERT(assertion, reason) if (!(assertion)) { return Fail("Assertion failed: [reason || "No reason"]") }

/// AQUILA - Plumbing: a stationary water tank refills a sink through a duct line, and ducts split their network when cut
/datum/unit_test/aquila_plumbing

/datum/unit_test/aquila_plumbing/Run()
	var/turf/start = run_loc_floor_bottom_left
	var/turf/middle = get_step(start, EAST)
	var/turf/finish = get_step(middle, EAST)

	// tank -> duct -> duct, sink sits next to the last duct
	var/obj/structure/reagent_dispensers/plumbed/tank = allocate(/obj/structure/reagent_dispensers/plumbed, start)
	tank.setDir(EAST)
	var/obj/machinery/duct/first = allocate(/obj/machinery/duct, middle)
	var/obj/machinery/duct/second = allocate(/obj/machinery/duct, finish)
	var/obj/structure/sink/sink = allocate(/obj/structure/sink, get_step(finish, NORTH))

	TEST_ASSERT(first.net && first.net == second.net, "Neighbouring ducts did not share a network")
	var/datum/component/plumbing/supply = tank.GetComponents(/datum/component/plumbing)[1]
	var/datum/component/plumbing/demand = sink.GetComponents(/datum/component/plumbing)[1]
	TEST_ASSERT(supply in first.net.suppliers, "The water tank did not join the duct network (tank dir [tank.dir], supply connects [supply.supply_connects])")
	TEST_ASSERT(demand in first.net.demanders, "The sink did not join the duct network")

	// A dry sink pulls water out of the tank
	sink.has_water_reclaimer = FALSE
	sink.reagents.clear_reagents()
	var/tank_water = tank.reagents.total_volume
	demand.process()
	TEST_ASSERT(sink.reagents.get_reagent_amount(/datum/reagent/water) >= MACHINE_REAGENT_TRANSFER, "The sink did not draw water from the tank")
	TEST_ASSERT(tank.reagents.total_volume < tank_water, "The tank did not lose the water the sink drew")

	// The tank can be topped up by hand
	var/obj/item/reagent_containers/glass/beaker/refill = allocate(/obj/item/reagent_containers/glass/beaker)
	refill.reagents.add_reagent(/datum/reagent/water, 5)
	var/mob/living/carbon/human/refiller = allocate(/mob/living/carbon/human, middle)
	var/before_refill = tank.reagents.total_volume
	tank.attackby_secondary(refill, refiller)
	TEST_ASSERT(tank.reagents.total_volume > before_refill, "Pouring a beaker into the water tank did not refill it")
	TEST_ASSERT(!refill.reagents.total_volume, "Pouring a beaker into the water tank left it full")

	// Cutting the line leaves the sink without a source
	qdel(first)
	TEST_ASSERT(!(supply in second.net.suppliers), "The tank stayed in the network after its duct was removed")
	sink.reagents.clear_reagents()
	demand.process()
	TEST_ASSERT(!sink.reagents.total_volume, "The sink drew water through a cut duct line")

	// Washing hands uses up the sink's water
	sink.reagents.add_reagent(/datum/reagent/water, SINK_CAPACITY)
	var/obj/item/reagent_containers/glass/beaker/beaker = allocate(/obj/item/reagent_containers/glass/beaker)
	var/mob/living/carbon/human/washer = allocate(/mob/living/carbon/human, get_step(sink, SOUTH))
	sink.attackby(beaker, washer)
	TEST_ASSERT(beaker.reagents.get_reagent_amount(/datum/reagent/water), "Filling a beaker at a sink gave no water")
	TEST_ASSERT(sink.reagents.total_volume < SINK_CAPACITY, "Filling a beaker did not use the sink's water")

#undef TEST_ASSERT
