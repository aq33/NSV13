// AQUILA - Miasma: the gas itself, its sterilization reaction, canister and export value

/datum/gas/miasma
	id = GAS_MIASMA
	specific_heat = 20
	fusion_power = 50
	name = "Miazma"
	gas_overlay = "miasma"
	moles_visible = MOLES_GAS_VISIBLE * 60

/// Dry heat sterilization: hot, dry air burns miasma off into oxygen
/datum/gas_reaction/miaster
	priority = -10 // after all the heating from fires etc. is done
	name = "Dry Heat Sterilization"
	id = "sterilization"

/datum/gas_reaction/miaster/init_reqs()
	min_requirements = list(
		"TEMP" = FIRE_MINIMUM_TEMPERATURE_TO_EXIST + 70,
		GAS_MIASMA = MINIMUM_MOLE_COUNT
	)

/datum/gas_reaction/miaster/react(datum/gas_mixture/air, datum/holder)
	// As the name says it, it needs to be dry
	if(air.get_moles(GAS_H2O) / air.total_moles() > 0.1)
		return NO_REACTION

	var/cleaned_air = min(air.get_moles(GAS_MIASMA), 20 + (air.return_temperature() - FIRE_MINIMUM_TEMPERATURE_TO_EXIST - 70) / 20)
	air.adjust_moles(GAS_MIASMA, -cleaned_air)
	air.adjust_moles(GAS_O2, cleaned_air)
	// Burning a bit of organic matter (maillard reaction) gives off a tiny bit of heat
	air.set_temperature(air.return_temperature() + cleaned_air * 0.002)
	SSresearch.science_tech.add_point_type(TECHWEB_POINT_TYPE_DEFAULT, cleaned_air * MIASMA_RESEARCH_AMOUNT)
	return REACTING

/obj/machinery/portable_atmospherics/canister/miasma
	name = "kanister z miazmą"
	desc = "Miazma. Po jednym wdechu żałujesz, że nie masz zatkanego nosa."
	gas_type = GAS_MIASMA
	filled = 1
	greyscale_config = /datum/greyscale_config/canister/double_stripe
	greyscale_colors = "#009823#f7d5d3"

/datum/export/large/gas_canister/get_cost(obj/O)
	. = ..()
	var/obj/machinery/portable_atmospherics/canister/C = O
	. += C.air_contents.get_moles(GAS_MIASMA) * MIASMA_EXPORT_PRICE
