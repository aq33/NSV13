///How fast the acclimator moves its contents towards the target temperature, per second
#define HEATER_COFFICIENT 0.3
///Minimal allowed difference temperature range
#define TEMP_DIFF 0.5

/obj/machinery/plumbing/acclimator
	name = "chemical acclimator"
	desc = "An efficient cooler and heater for the perfect showering temperature or illicit chemical factory."
	icon_state = "acclimator"
	buffer = 200
	active_power_usage = 100

	///towards wich temperature do we build?
	var/target_temperature = 300
	///See code/__DEFINES/plumbing.dm
	var/acclimate_state = AC_FILLING
	///Maximum volume intake before processing
	var/max_volume = 200

/obj/machinery/plumbing/acclimator/Initialize(mapload, layer)
	. = ..()
	AddComponent(/datum/component/plumbing/acclimator, layer)
	update_appearance(UPDATE_ICON_STATE)

/obj/machinery/plumbing/acclimator/update_icon_state()
	. = ..()

	icon_state = initial(icon_state)
	if(machine_stat & NOPOWER || !anchored)
		return

	switch(acclimate_state)
		if(AC_FILLING)
			icon_state += "_fill"
		if(AC_HEATING)
			icon_state += "_hot"
		if(AC_COOLING)
			icon_state += "_cold"
		if(AC_EMPTYING)
			icon_state += "_empty"

/obj/machinery/plumbing/acclimator/wrench_act(mob/living/user, obj/item/tool)
	. = ..()
	acclimate_state = AC_FILLING
	update_appearance(UPDATE_ICON_STATE)

/obj/machinery/plumbing/acclimator/plunger_act(obj/item/plunger/attacking_plunger, mob/living/user, reinforced)
	. = ..()
	acclimate_state = AC_FILLING
	reagents.flags |= NO_REACT
	update_appearance(UPDATE_ICON_STATE)

/// Full, start heating or cooling
/obj/machinery/plumbing/acclimator/proc/start_acclimating()
	reagents.flags &= ~NO_REACT
	acclimate_state = reagents.chem_temp > target_temperature ? AC_COOLING : AC_HEATING
	update_appearance(UPDATE_ICON_STATE)

/// Back to filling once drained
/obj/machinery/plumbing/acclimator/proc/check_emptied()
	if(acclimate_state == AC_EMPTYING && !reagents.total_volume)
		acclimate_state = AC_FILLING
		reagents.flags |= NO_REACT
		update_appearance(UPDATE_ICON_STATE)

/obj/machinery/plumbing/acclimator/process(delta_time)
	if(machine_stat & NOPOWER || !reagents.total_volume || acclimate_state == AC_FILLING || acclimate_state == AC_EMPTYING)
		return

	var/new_state = reagents.chem_temp > target_temperature ? AC_COOLING : AC_HEATING
	if(acclimate_state != new_state)
		acclimate_state = new_state
		update_appearance(UPDATE_ICON_STATE)

	reagents.chem_temp = clamp(reagents.chem_temp + (target_temperature - reagents.chem_temp) * min(HEATER_COFFICIENT * delta_time, 1), 2.7, 1000)
	reagents.handle_reactions()
	use_power(active_power_usage)

	if(abs(reagents.chem_temp - target_temperature) <= TEMP_DIFF)
		reagents.chem_temp = target_temperature
		acclimate_state = AC_EMPTYING
		update_appearance(UPDATE_ICON_STATE)

/obj/machinery/plumbing/acclimator/ui_state(mob/user)
	return GLOB.default_state

/obj/machinery/plumbing/acclimator/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "ChemAcclimator", name)
		ui.open()
		ui.set_autoupdate(TRUE)

/obj/machinery/plumbing/acclimator/ui_data(mob/user)
	return list(
		chem_temp = round(reagents.chem_temp, 0.01),
		target_temperature = target_temperature,
		max_volume = max_volume,
		acclimate_state = acclimate_state
	)

/obj/machinery/plumbing/acclimator/ui_act(action, list/params)
	. = ..()
	if(.)
		return

	switch(action)
		if("set_target_temperature")
			var/value = text2num(params["temperature"])
			if(!value)
				return FALSE

			target_temperature = round(clamp(value, 1, 1000), 0.01)
			return TRUE

		if("change_volume")
			var/value = text2num(params["volume"])
			if(!value)
				return FALSE

			max_volume = round(clamp(value, 1, buffer), 0.01)
			return TRUE

#undef HEATER_COFFICIENT
#undef TEMP_DIFF
