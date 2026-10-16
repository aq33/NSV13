// AQUILA - katalog receptur chemicznych do wyszukiwarki w dispenserach i w programie PDA „Receptury”.
// Budowany raz z GLOB.chemical_reactions_list; losowane receptury (secret-chems) są celowo pominięte.

GLOBAL_LIST(recipe_catalog)

/// Zwraca listę wszystkich stałych receptur w formacie dla TGUI (RecipeLookup)
/proc/get_recipe_catalog()
	if(GLOB.recipe_catalog)
		return GLOB.recipe_catalog
	build_chemical_reactions_list()

	var/list/catalog = list()
	var/list/seen = list()
	for(var/reagent_type in GLOB.chemical_reactions_list)
		for(var/datum/chemical_reaction/reaction as anything in GLOB.chemical_reactions_list[reagent_type])
			if(seen[reaction.type])
				continue
			seen[reaction.type] = TRUE
			if(istype(reaction, /datum/chemical_reaction/randomized))
				continue
			var/list/entry = recipe_catalog_entry(reaction)
			if(entry)
				catalog += list(entry)
	GLOB.recipe_catalog = catalog
	return catalog

/proc/recipe_catalog_entry(datum/chemical_reaction/reaction)
	var/list/reagents = recipe_catalog_reagents(reaction.required_reagents)
	if(!length(reagents))
		return null
	var/list/results = recipe_catalog_reagents(reaction.results)
	var/name = length(results) ? results[1]["name"] : reaction.name
	if(!name)
		return null

	var/container
	if(reaction.required_container)
		var/atom/container_type = reaction.required_container
		container = initial(container_type.name)

	return list(
		"id" = "[reaction.type]",
		"name" = name,
		"results" = results,
		"reagents" = reagents,
		"catalysts" = recipe_catalog_reagents(reaction.required_catalysts),
		"temp" = reaction.required_temp,
		"cold" = !!reaction.is_cold_recipe,
		"container" = container,
	)

/// Zamienia listę typ odczynnika => ilość na listę dla TGUI
/proc/recipe_catalog_reagents(list/reagent_list)
	. = list()
	for(var/reagent_type in reagent_list)
		var/datum/reagent/reagent = GLOB.chemical_reagents_list[reagent_type]
		var/reagent_name = reagent ? reagent.name : "[reagent_type]"
		. += list(list(
			"name" = reagent_name,
			"id" = ckey(reagent_name),
			"amount" = reagent_list[reagent_type],
		))

/obj/machinery/chem_dispenser/ui_static_data(mob/user)
	. = ..()
	.["recipeCatalog"] = get_recipe_catalog()

GLOBAL_LIST(slime_extract_catalog)

/// Zwraca reakcje ekstraktów szlamów pogrupowane po ekstrakcie (program PDA „Ekstrakty”)
/proc/get_slime_extract_catalog()
	if(GLOB.slime_extract_catalog)
		return GLOB.slime_extract_catalog
	build_chemical_reactions_list()

	var/list/reactions_by_extract = list()
	var/list/seen = list()
	for(var/reagent_type in GLOB.chemical_reactions_list)
		for(var/datum/chemical_reaction/reaction as anything in GLOB.chemical_reactions_list[reagent_type])
			if(seen[reaction.type] || !ispath(reaction.required_container, /obj/item/slime_extract))
				continue
			seen[reaction.type] = TRUE
			LAZYADD(reactions_by_extract[reaction.required_container], list(list(
				"id" = "[reaction.type]",
				"name" = reaction.name,
				"reagents" = recipe_catalog_reagents(reaction.required_reagents),
				"results" = recipe_catalog_reagents(reaction.results),
			)))

	var/list/catalog = list()
	for(var/obj/item/slime_extract/extract_type as anything in reactions_by_extract)
		catalog += list(list(
			"id" = "[extract_type]",
			"name" = initial(extract_type.name),
			"reactions" = reactions_by_extract[extract_type],
		))
	GLOB.slime_extract_catalog = catalog
	return catalog
