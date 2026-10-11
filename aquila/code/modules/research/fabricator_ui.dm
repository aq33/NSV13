// Port BeeStation #14723: wspólne dane dla okien Fabricator i ExosuitFabricator (przeglądarka projektów z Bee).

/// Most copies of an item a lathe will print from a single order
#define MAX_LATHE_PRINT_AMOUNT 50

/**
 * Serializes designs into the shape the shared fabricator browser expects.
 *
 * * designs - `/datum/design` instances, or design ids to look up.
 * * coefficient - multiplier applied to every material cost.
 * * coefficient_override - invoked with a design to get a cost multiplier for it specifically.
 */
/proc/fabricator_ui_designs(list/designs, coefficient = 1, datum/callback/coefficient_override)
	var/list/output = list()
	var/datum/asset/spritesheet/research_designs/spritesheet = get_asset_datum(/datum/asset/spritesheet/research_designs)
	var/default_size = "[spritesheet.name]32x32"

	for(var/entry in designs)
		var/datum/design/design = istype(entry, /datum/design) ? entry : SSresearch.techweb_design_by_id(entry)
		if(!istype(design))
			continue

		var/design_coefficient = coefficient_override ? coefficient_override.Invoke(design) : coefficient
		var/list/cost = list()
		for(var/material_key in design.materials)
			// A key is either a material datum or, for designs that let the user pick, the name of a material category
			var/datum/material/material = material_key
			cost[istext(material_key) ? material_key : material.name] = design.materials[material_key] * design_coefficient

		var/list/reagent_cost = list()
		for(var/reagent_type in design.reagents_list)
			var/datum/reagent/reagent = reagent_type
			reagent_cost[ispath(reagent_type) ? initial(reagent.name) : "[reagent_type]"] = design.reagents_list[reagent_type]

		var/icon_size = spritesheet.icon_size_id(design.id)
		output[design.id] = list(
			"name" = design.name,
			"desc" = design.desc,
			"cost" = cost,
			"reagentCost" = reagent_cost,
			"id" = design.id,
			"categories" = design.category || list("Misc"),
			"icon" = "[icon_size == default_size ? "" : "[icon_size] "][design.id]",
			"constructionTime" = design.construction_time,
		)
	return output

/// Materials in a container, in the shape of the fabricator material bar
/proc/fabricator_ui_materials(datum/component/material_container/container)
	var/list/output = list()
	if(!container)
		return output
	for(var/datum/material/material as anything in container.materials)
		var/amount = container.materials[material]
		output += list(list(
			"name" = material.name,
			"ref" = REF(material),
			"amount" = amount,
			"sheets" = round(amount / MINERAL_MATERIAL_AMOUNT),
			"removable" = amount >= MINERAL_MATERIAL_AMOUNT,
			"color" = material.greyscale_colors || material.color,
		))
	return output
