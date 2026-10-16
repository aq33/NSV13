// AQUILA - katalog symptomów wirusów do listy w PANDEMIC

GLOBAL_LIST(symptom_catalog)

/// Zwraca wszystkie symptomy wirusów z poziomem i chemikaliami, które mogą je wylosować (PANDEMIC)
/proc/get_symptom_catalog()
	if(GLOB.symptom_catalog)
		return GLOB.symptom_catalog

	// Poziom symptomu => nazwy odczynników z reakcji mix_virus, które go losują
	var/list/sources_by_level = list()
	for(var/reaction_type in subtypesof(/datum/chemical_reaction/mix_virus))
		if(ispath(reaction_type, /datum/chemical_reaction/mix_virus/rem_virus) || ispath(reaction_type, /datum/chemical_reaction/mix_virus/neuter_virus) \
			|| ispath(reaction_type, /datum/chemical_reaction/mix_virus/preserve_virus) || ispath(reaction_type, /datum/chemical_reaction/mix_virus/falter_virus))
			continue
		var/datum/chemical_reaction/mix_virus/reaction = new reaction_type
		for(var/level in reaction.level_min to reaction.level_max)
			for(var/list/reagent as anything in recipe_catalog_reagents(reaction.required_reagents))
				LAZYOR(sources_by_level["[level]"], reagent["name"])
		qdel(reaction)

	var/list/catalog = list()
	for(var/datum/symptom/symptom_type as anything in subtypesof(/datum/symptom))
		var/level = initial(symptom_type.level)
		if(level < 0 || !initial(symptom_type.name))
			continue
		catalog += list(list(
			"id" = "[symptom_type]",
			"name" = initial(symptom_type.name),
			"desc" = initial(symptom_type.desc),
			"threshold_desc" = initial(symptom_type.threshold_desc),
			"level" = level,
			"severity" = initial(symptom_type.severity),
			"stealth" = initial(symptom_type.stealth),
			"resistance" = initial(symptom_type.resistance),
			"stage_speed" = initial(symptom_type.stage_speed),
			"transmission" = initial(symptom_type.transmission),
			"natural" = !!initial(symptom_type.naturally_occuring),
			"sources" = sources_by_level["[level]"] || list(),
		))
	GLOB.symptom_catalog = catalog
	return catalog

/obj/machinery/computer/pandemic/ui_static_data(mob/user)
	. = ..()
	.["symptom_catalog"] = get_symptom_catalog()
