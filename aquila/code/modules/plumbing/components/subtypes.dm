///has one pipe input that only takes, example is manual output pipe
/datum/component/plumbing/simple_demand
	demand_connects = SOUTH

/datum/component/plumbing/simple_demand/Initialize(ducting_layer, distinct_reagent_cap = INFINITY)
	src.distinct_reagent_cap = distinct_reagent_cap
	return ..()

///For disposing reagents
/datum/component/plumbing/simple_demand/disposer

/datum/component/plumbing/simple_demand/disposer/Initialize(ducting_layer, distinct_reagent_cap)
	if(!istype(parent, /obj/machinery/plumbing/disposer))
		return COMPONENT_INCOMPATIBLE
	return ..()

/datum/component/plumbing/simple_demand/disposer/send_request(dir)
	var/obj/machinery/plumbing/disposer/target = parent
	if(target.on)
		process_request(target.disposal_rate * SSPLUMBING_DT, dir = dir)

///has one pipe output that only supplies. example is liquid pump and manual input pipe
/datum/component/plumbing/simple_supply
	supply_connects = SOUTH

///input and output, like a holding tank
/datum/component/plumbing/tank
	demand_connects = WEST
	supply_connects = EAST

/**
 * Water fixtures like sinks, toilets and showers.
 * They sit against walls in all kinds of directions, so they take from a duct on any side and draw no connectors.
 * Ducts are allowed to run under them.
 */
/datum/component/plumbing/fixture
	demand_connects = NORTH | SOUTH | EAST | WEST
	show_connectors = FALSE
	connector_overlap = FALSE
	turn_connects = FALSE

/datum/component/plumbing/fixture/on_examine(atom/movable/source, mob/user, list/examine_list)
	. = ..()
	if(length(ducts))
		examine_list += "<span class='notice'>Jest podłączony do rury z wodą.</span>"
	else
		examine_list += "<span class='notice'>Można go zasilić rurą położoną na sąsiednim polu.</span>"

///Connects different layer of ducts
/datum/component/plumbing/manifold
	demand_connects = NORTH
	supply_connects = SOUTH

/datum/component/plumbing/manifold/change_ducting_layer(obj/source, obj/changer, new_layer)
	return

///When you have a component accepting multiple connections
/datum/component/plumbing/multidirectional
	demand_connects = NORTH
	supply_connects = SOUTH | EAST | WEST //SOUTH is straight, EAST is left and WEST is right. We look from the perspective of the insert

/**
 * Returns the direction in which this component is connected to an ductnet without the rotation
 * Arguments
 *
 * * datum/ductnet/net - the net we are checking for an connection to
*/
/datum/component/plumbing/multidirectional/proc/get_connection(datum/ductnet/net)
	var/atom/movable/parent_movable = parent
	for(var/A in ducts)
		if(ducts[A] == net)
			return turn(text2num(A), dir2angle(parent_movable.dir) - 180)

///Splits reagent amounts along 3 directions
/datum/component/plumbing/multidirectional/splitter/Initialize(ducting_layer)
	if(!istype(parent, /obj/machinery/plumbing/splitter))
		return COMPONENT_INCOMPATIBLE
	return ..()

/datum/component/plumbing/multidirectional/splitter/transfer_to(datum/component/plumbing/target, amount, reagent, datum/ductnet/net, round_robin = TRUE)
	var/obj/machinery/plumbing/splitter/S = parent
	var/limit = INFINITY
	switch(get_connection(net))
		if(SOUTH)
			limit = S.transfer_straight
		if(EAST)
			limit = S.transfer_left
		if(WEST)
			limit = S.transfer_right
	amount = min(amount, limit, reagents.total_volume)
	S.use_power(S.active_power_usage)
	return ..()

///Splits reagents along 3 directions
/datum/component/plumbing/multidirectional/filter/Initialize(ducting_layer)
	if(!istype(parent, /obj/machinery/plumbing/filter))
		return COMPONENT_INCOMPATIBLE
	return ..()

/**
 * Returns if an reagent can be supplied in an specific direction
 * Arguments
 *
 * * dir - the direction to check
 * * datum/reagent/reagent - the reagent we are checking for
*/
/datum/component/plumbing/multidirectional/filter/proc/can_give_in_direction(dir, datum/reagent/reagent)
	var/obj/machinery/plumbing/filter/F = parent
	switch(dir)
		if(SOUTH) //straight
			return !F.left.Find(reagent) && !F.right.Find(reagent)
		if(EAST) //left
			return F.left.Find(reagent)
		if(WEST) //right
			return F.right.Find(reagent)

/datum/component/plumbing/multidirectional/filter/can_give(amount, reagent, datum/ductnet/net)
	if(reagent)
		return can_give_in_direction(get_connection(net), reagent) && ..()
	if(amount <= 0)
		return FALSE
	var/direction = get_connection(net)
	for(var/datum/reagent/R as anything in reagents.reagent_list)
		if(can_give_in_direction(direction, R.type))
			return TRUE
	return FALSE

/datum/component/plumbing/multidirectional/filter/transfer_to(datum/component/plumbing/target, amount, reagent, datum/ductnet/net, round_robin = TRUE)
	var/obj/machinery/plumbing/filter/F = parent
	var/direction = get_connection(net)
	var/list/rejected_reagents = list()
	for(var/datum/reagent/R as anything in reagents.reagent_list)
		if(!can_give_in_direction(direction, R.type))
			rejected_reagents += R.type
	F.use_power(F.active_power_usage)
	return reagents.plumbing_transfer(target.recipient_reagents_holder(), amount, reagent, round_robin, rejected_reagents)

/datum/component/plumbing/reaction_chamber
	demand_connects = NORTH
	supply_connects = SOUTH

/datum/component/plumbing/reaction_chamber/Initialize(ducting_layer)
	if(!istype(parent, /obj/machinery/plumbing/reaction_chamber))
		return COMPONENT_INCOMPATIBLE
	return ..()

/datum/component/plumbing/reaction_chamber/can_give(amount, reagent, datum/ductnet/net)
	. = FALSE

	var/obj/machinery/plumbing/reaction_chamber/reaction_chamber = parent

	//cannot give when we outselves are requesting the reagents
	if(amount <= 0 || !reagents.total_volume || !reaction_chamber.emptying)
		return

	//check to see if we can give catalysts only if they are in excess
	var/list/datum/reagent/catalysts = reaction_chamber.catalysts
	for(var/datum/reagent/chemical as anything in reagents.reagent_list)
		if(reagent && chemical.type != reagent)
			continue

		//we have the exact amounts so no excess to spare
		if(chemical.volume <= (catalysts[chemical.type] || 0))
			if(reagent)
				break
			else
				continue

		//atleast 1 reagent to give so take whatever
		return TRUE

/datum/component/plumbing/reaction_chamber/transfer_to(datum/component/plumbing/target, amount, reagent, datum/ductnet/net, round_robin = TRUE)
	var/obj/machinery/plumbing/reaction_chamber/chamber = parent
	. = reagents.plumbing_transfer(target.recipient_reagents_holder(), amount, reagent, round_robin, kept = chamber.catalysts)
	chamber.check_emptied()

/datum/component/plumbing/reaction_chamber/send_request(dir)
	var/obj/machinery/plumbing/reaction_chamber/chamber = parent

	if(chamber.emptying || !length(chamber.required_reagents))
		return

	//take in reagents
	var/present_amount
	var/diff
	var/list/datum/reagent/required_reagents = chamber.catalysts | chamber.required_reagents
	for(var/datum/reagent/required_reagent as anything in required_reagents)
		//find how much amount is already present if at all and get the reagent reference
		present_amount = reagents.get_reagent_amount(required_reagent)

		//compute how much more is needed
		diff = min(required_reagents[required_reagent] - present_amount, MACHINE_REAGENT_TRANSFER)
		if(diff >= 0.1) // the closest we can ask for so values like 0.9999 become 1
			process_request(diff, required_reagent, dir)
			if(!chamber.catalysts[required_reagent]) //only block if not a catalyst as they can come in whenever they are available
				return

	chamber.start_reacting()

/datum/component/plumbing/buffer
	demand_connects = WEST
	supply_connects = EAST

/datum/component/plumbing/buffer/Initialize(ducting_layer)
	if(!istype(parent, /obj/machinery/plumbing/buffer))
		return COMPONENT_INCOMPATIBLE
	return ..()

/datum/component/plumbing/buffer/send_request(dir)
	var/obj/machinery/plumbing/buffer/buffer = parent
	if(buffer.mode == AB_UNREADY)
		return ..()

/datum/component/plumbing/buffer/can_give(amount, reagent, datum/ductnet/net)
	var/obj/machinery/plumbing/buffer/buffer = parent
	return (buffer.mode == AB_READY) ? ..() : FALSE

/datum/component/plumbing/buffer/transfer_to(datum/component/plumbing/target, amount, reagent, datum/ductnet/net, round_robin = TRUE)
	. = ..()
	var/obj/machinery/plumbing/buffer/buffer = parent
	buffer.on_reagent_change()

/datum/component/plumbing/acclimator
	demand_connects = WEST
	supply_connects = EAST

/datum/component/plumbing/acclimator/Initialize(ducting_layer)
	if(!istype(parent, /obj/machinery/plumbing/acclimator))
		return COMPONENT_INCOMPATIBLE
	return ..()

/datum/component/plumbing/acclimator/send_request(dir)
	var/obj/machinery/plumbing/acclimator/myacclimator = parent
	if(myacclimator.acclimate_state != AC_FILLING)
		return
	if(reagents.total_volume < myacclimator.max_volume)
		process_request(min(MACHINE_REAGENT_TRANSFER, myacclimator.max_volume - reagents.total_volume), null, dir)
		if(reagents.total_volume < myacclimator.max_volume)
			return
	myacclimator.start_acclimating()

/datum/component/plumbing/acclimator/can_give(amount, reagent)
	var/obj/machinery/plumbing/acclimator/myacclimator = parent
	return myacclimator.acclimate_state == AC_EMPTYING && ..()

/datum/component/plumbing/acclimator/transfer_to(datum/component/plumbing/target, amount, reagent, datum/ductnet/net, round_robin = TRUE)
	. = ..()
	var/obj/machinery/plumbing/acclimator/myacclimator = parent
	myacclimator.check_emptied()

/// Hydroponics trays only take water from the pipes, straight into their water level.
/datum/component/plumbing/fixture/hydroponics

/datum/component/plumbing/fixture/hydroponics/Initialize(ducting_layer)
	if(!istype(parent, /obj/machinery/hydroponics))
		return COMPONENT_INCOMPATIBLE
	return ..()

/datum/component/plumbing/fixture/hydroponics/on_examine(atom/movable/source, mob/user, list/examine_list)
	if(length(ducts))
		examine_list += "<span class='notice'>Jest podłączona do rury i sama uzupełnia wodę.</span>"
	else
		examine_list += "<span class='notice'>Można ją podłączyć do rury z wodą na sąsiednim polu.</span>"

/datum/component/plumbing/fixture/hydroponics/send_request(dir)
	var/obj/machinery/hydroponics/tray = parent
	var/wanted = min(tray.maxwater - tray.waterlevel, MACHINE_REAGENT_TRANSFER)
	if(wanted < 1)
		return
	process_request(wanted, /datum/reagent/water, dir)
	var/received = reagents.get_reagent_amount(/datum/reagent/water)
	if(received)
		tray.adjustWater(round(received))
	reagents.clear_reagents()
