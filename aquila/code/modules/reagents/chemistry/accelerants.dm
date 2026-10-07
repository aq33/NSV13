// Turf fires (port of Yogstation #19738): how big a fire a molotov starts depends on its reagents

/datum/reagent
	/// How flammable is this material? Used by molotovs to determine how big of a fire they start
	var/accelerant_quality = 0

/// Returns how much fire power the contained reagents provide, used by molotovs
/datum/reagents/proc/get_total_accelerant_quality()
	var/quality = 0
	for(var/datum/reagent/reagent as anything in reagent_list)
		quality += reagent.volume * reagent.accelerant_quality
	return quality

/datum/reagent/consumable/ethanol
	accelerant_quality = 5

/datum/reagent/hellwater
	accelerant_quality = 20

/datum/reagent/fuel
	accelerant_quality = 10

/datum/reagent/clf3
	accelerant_quality = 20

/datum/reagent/phlogiston
	accelerant_quality = 20

/datum/reagent/napalm
	accelerant_quality = 20

/datum/reagent/toxin/plasma
	accelerant_quality = 10

/datum/reagent/toxin/spore_burning
	accelerant_quality = 10
