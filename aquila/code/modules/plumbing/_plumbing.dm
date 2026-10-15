// Plumbing port from tg (tgstation/tgstation@1568dbe1da), adapted to our reagent holder.

PROCESSING_SUBSYSTEM_DEF(plumbing)
	name = "Plumbing"
	wait = 1 SECONDS
	stat_tag = "FD" //its actually Fluid Ducts
	flags = SS_NO_INIT

/// List of plumbing layers as name => bitflag
GLOBAL_LIST_INIT(plumbing_layers, list(
	"First Layer" = FIRST_DUCT_LAYER,
	"Second Layer" = SECOND_DUCT_LAYER,
	"Default Layer" = THIRD_DUCT_LAYER,
	"Fourth Layer" = FOURTH_DUCT_LAYER,
	"Fifth Layer" = FIFTH_DUCT_LAYER,
))

/// Reverse of plumbing_layers, as "[bitflag]" => name
GLOBAL_LIST_INIT(plumbing_layer_names, list(
	"[FIRST_DUCT_LAYER]" = "First Layer",
	"[SECOND_DUCT_LAYER]" = "Second Layer",
	"[THIRD_DUCT_LAYER]" = "Default Layer",
	"[FOURTH_DUCT_LAYER]" = "Fourth Layer",
	"[FIFTH_DUCT_LAYER]" = "Fifth Layer",
))

/// Duct color names a player can pick. "omni" connects to every color.
/proc/get_duct_colors()
	var/static/list/duct_colors
	if(!duct_colors)
		duct_colors = list(DUCT_COLOR_OMNI)
		for(var/color_name in GLOB.pipe_paint_colors)
			duct_colors += color_name
	return duct_colors

/// Pixel offset of ducts and connectors on the given layer
/proc/duct_layer_offset(ducting_layer)
	switch(ducting_layer)
		if(FIRST_DUCT_LAYER)
			return -10
		if(SECOND_DUCT_LAYER)
			return -5
		if(FOURTH_DUCT_LAYER)
			return 5
		if(FIFTH_DUCT_LAYER)
			return 10
	return 0

/// Hex color of the given duct color name, null for omni
/proc/duct_color_value(color_name)
	if(color_name == DUCT_COLOR_OMNI)
		return null
	return GLOB.pipe_paint_colors[color_name]

/**
 * Finds a duct or plumbing machinery located at the destination
 *
 * Arguments
 * * atom/destination - the target loc we are checking for
 * * ducting_layer - the ducting layer to check for. pass -ve value when you are checking for overlapping machines
*/
/proc/ducting_layer_check(atom/destination, ducting_layer)
	. = null

	var/is_machine = FALSE
	if(ducting_layer < 0)
		is_machine = TRUE
		ducting_layer = abs(ducting_layer)

	for(var/atom/movable/other in get_turf(destination))
		if(other == destination)
			continue

		//check for overlapping ducts
		var/obj/machinery/duct/pipe = other
		if(istype(pipe) && (pipe.duct_layer & ducting_layer))
			return pipe

		//check for overlapping machines. -ve duct layer means we are checking machines on machines overlap which regardless of layer is not allowed
		for(var/datum/component/plumbing/plumber in other.GetComponents(/datum/component/plumbing))
			if(plumber.connector_overlap && (is_machine || (plumber.ducting_layer & ducting_layer)))
				return plumber

/**
 * Moves reagents between two holders for plumbing.
 *
 * Round robin (default) moves whole reagents in order, so 5u from 15 water, 15 sugar and 15 plasma becomes 10, 15, 15
 * instead of 13.33 each. Without it the transfer is proportional.
 *
 * Arguments
 * * datum/reagents/target - receiving holder
 * * amount - how much to move at most
 * * reagent_type - only move this reagent, null for anything
 * * round_robin - see above
 * * list/excluded - reagent types that never leave
 * * list/kept - reagent type => amount that has to stay behind (catalysts)
 *
 * Returns the moved amount
 */
/datum/reagents/proc/plumbing_transfer(datum/reagents/target, amount, reagent_type, round_robin = TRUE, list/excluded, list/kept)
	if(!target || QDELETED(target.my_atom) || !total_volume || !isnum_safe(amount))
		return 0

	var/list/available = list()
	var/available_volume = 0
	for(var/datum/reagent/reagent as anything in reagent_list)
		if(reagent_type && reagent.type != reagent_type)
			continue
		if(excluded && (reagent.type in excluded))
			continue
		var/spare = reagent.volume - (kept ? (kept[reagent.type] || 0) : 0)
		if(spare <= 0)
			continue
		available[reagent] = spare
		available_volume += spare

	amount = round(min(amount, available_volume, target.maximum_volume - target.total_volume), CHEMICAL_QUANTISATION_LEVEL)
	if(amount <= 0)
		return 0

	var/moved = 0
	var/to_move = amount
	for(var/datum/reagent/reagent as anything in available)
		var/transfer_amount
		if(round_robin)
			if(to_move <= 0)
				break
			transfer_amount = min(to_move, available[reagent])
		else
			transfer_amount = available[reagent] * (amount / available_volume)
		if(transfer_amount <= 0)
			continue
		if(!target.add_reagent(reagent.type, transfer_amount, copy_data(reagent), chem_temp, no_react = TRUE))
			continue
		remove_reagent(reagent.type, transfer_amount)
		moved += transfer_amount
		to_move -= transfer_amount

	update_total()
	target.update_total()
	target.handle_reactions()
	return moved
