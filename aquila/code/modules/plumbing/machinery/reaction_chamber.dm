/// how fast the chamber pulls its contents towards the target temperature, per second
#define CHAMBER_HEATER_COEFFICIENT 0.05

///a reaction chamber for plumbing. pretty much everything can react, but this one keeps the reagents separated and only reacts under your given terms
/obj/machinery/plumbing/reaction_chamber
	name = "mixing chamber"
	desc = "Keeps chemicals separated until given conditions are met."
	icon_state = "reaction_chamber"
	buffer = 200

	/**
	* list of set reagents that the reaction_chamber allows in, and must all be present before mixing is enabled.
	* example: list(/datum/reagent/water = 20, /datum/reagent/fuel/oil = 50)
	*/
	var/list/datum/reagent/required_reagents = list()
	///list of catalyst reagents to take
	var/list/datum/reagent/catalysts = list()
	///our reagent goal has been reached, so now we lock our inputs and start emptying
	var/emptying = FALSE
	///towards which temperature do we build (except during draining)?
	var/target_temperature = 300

/obj/machinery/plumbing/reaction_chamber/Initialize(mapload, layer)
	. = ..()
	AddComponent(/datum/component/plumbing/reaction_chamber, layer)

/// Everything we wanted is inside, react and start draining
/obj/machinery/plumbing/reaction_chamber/proc/start_reacting()
	//our reactions are instant, so wait until the mix reaches the target temperature
	if(abs(target_temperature - reagents.chem_temp) > 1 && !(machine_stat & NOPOWER))
		return
	reagents.flags &= ~NO_REACT
	reagents.handle_reactions()
	emptying = TRUE
	check_emptied() //some reactions leave nothing left.

/// Stops draining once only the catalysts are left
/obj/machinery/plumbing/reaction_chamber/proc/check_emptied()
	if(!emptying)
		return
	for(var/datum/reagent/chemical as anything in reagents.reagent_list)
		if(chemical.volume > (catalysts[chemical.type] || 0) + 0.1)
			return
	emptying = FALSE
	reagents.flags |= NO_REACT

/obj/machinery/plumbing/reaction_chamber/process(delta_time)
	if(machine_stat & NOPOWER || !reagents.total_volume || emptying)
		return

	//adjust temperature of final solution
	if(abs(target_temperature - reagents.chem_temp) > 0.5)
		reagents.chem_temp = clamp(reagents.chem_temp + (target_temperature - reagents.chem_temp) * min(CHAMBER_HEATER_COEFFICIENT * delta_time, 1), 2.7, 1000)
		use_power(active_power_usage)

/obj/machinery/plumbing/reaction_chamber/power_change()
	. = ..()
	icon_state = initial(icon_state) + "[machine_stat & NOPOWER ? "" : "_on"]"

/obj/machinery/plumbing/reaction_chamber/ui_state(mob/user)
	return GLOB.default_state

/obj/machinery/plumbing/reaction_chamber/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "ChemMixingChamber", name)
		ui.open()
		ui.set_autoupdate(TRUE)

/obj/machinery/plumbing/reaction_chamber/ui_data(mob/user)
	. = list()

	var/list/reagents_data = list()
	for(var/datum/reagent/required_reagent as anything in required_reagents) //make a list where the key is text, because that looks alot better in the ui than a typepath
		var/list/reagent_data = list()
		reagent_data["name"] = initial(required_reagent.name)
		reagent_data["volume"] = required_reagents[required_reagent]
		reagents_data += list(reagent_data)
	.["reagents"] = reagents_data

	var/list/catalyst_data = list()
	for(var/datum/reagent/required_catalyst as anything in catalysts)
		var/list/reagent_data = list()
		reagent_data["name"] = initial(required_catalyst.name)
		reagent_data["volume"] = catalysts[required_catalyst]
		catalyst_data += list(reagent_data)
	.["catalysts"] = catalyst_data

	.["emptying"] = emptying
	.["temperature"] = round(reagents.chem_temp, 0.1)
	.["targetTemp"] = target_temperature
	.["isReacting"] = FALSE

/obj/machinery/plumbing/reaction_chamber/ui_act(action, params)
	. = ..()
	if(.)
		return

	switch(action)
		if("add")
			var/selected_reagent = tgui_input_list(usr, "Wybierz odczynnik", "Odczynnik", GLOB.name2reagent)
			if(!selected_reagent)
				return FALSE

			var/datum/reagent/input_reagent = GLOB.name2reagent[selected_reagent]
			if(!input_reagent || catalysts[input_reagent])
				return FALSE

			var/input_amount = text2num(params["amount"])
			if(!input_amount)
				return FALSE
			input_amount = clamp(round(input_amount, 0.01), 1, buffer)

			if(!required_reagents[input_reagent])
				required_reagents[input_reagent] = input_amount
				return TRUE

		if("remove")
			var/reagent = get_chem_id(params["chem"])
			if(reagent)
				required_reagents.Remove(reagent)
				return TRUE

		if("temperature")
			var/target = text2num(params["target"])
			if(!isnull(target))
				target_temperature = clamp(target, 0, 1000)
				return TRUE

		if("catalyst")
			var/reagent = get_chem_id(params["chem"])
			if(!reagent)
				return FALSE

			if(!catalysts[reagent])
				catalysts[reagent] = required_reagents[reagent]
				required_reagents -= reagent
				return TRUE

		if("catremove")
			var/reagent = get_chem_id(params["chem"])
			if(!reagent)
				return FALSE

			if(catalysts[reagent])
				required_reagents[reagent] = catalysts[reagent]
				catalysts -= reagent
				return TRUE

#undef CHAMBER_HEATER_COEFFICIENT
