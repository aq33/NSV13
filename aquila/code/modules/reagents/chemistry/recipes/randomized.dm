// AQUILA - losowane receptury z tg (recipes/special.dm) + tgstation/tgstation#95952
// Nasza chemia nie ma pH ani czystości, więc losujemy tylko składniki, katalizatory, temperaturę i pojemnik.

#define RNGCHEM_INPUT "input"
#define RNGCHEM_CATALYSTS "catalysts"
#define RANDOMIZED_RECIPES_FILE "data/RandomizedChemRecipes.json"

/// Czy odczynnik może trafić do losowej receptury (tylko to, co da się normalnie zsyntetyzować)
/proc/valid_random_recipe_reagent(datum/reagent/reagent_type)
	return !(initial(reagent_type.chem_flags) & CHEMICAL_NOT_SYNTH)

/// Receptury zapisane w poprzednich rundach, wczytywane raz
/proc/get_saved_randomized_recipes()
	var/static/list/saved_recipes
	if(isnull(saved_recipes))
		saved_recipes = list()
		if(fexists(RANDOMIZED_RECIPES_FILE))
			saved_recipes = decode_randomized_recipes(file2text(RANDOMIZED_RECIPES_FILE))
	return saved_recipes

/// Dekoduje zapis receptur; uszkodzony zapis (np. przerwany po fdel) daje pustą listę zamiast błędu
/proc/decode_randomized_recipes(json_text)
	. = list()
	try
		var/list/decoded = json_decode(json_text)
		if(islist(decoded))
			. = decoded
	catch(var/exception/decode_error)
		log_game("Nie udało się wczytać zapisanych losowych receptur: [decode_error]")

/datum/chemical_reaction/randomized
	/// Co ile dni receptura się zmienia
	var/persistence_period = 7
	/// Kiedy receptura została wylosowana (world.realtime)
	var/created
	var/min_temp = 1
	var/max_temp = 600
	var/min_input_reagent_amount = 1
	var/max_input_reagent_amount = 10
	var/min_input_reagents = 2
	var/max_input_reagents = 5
	var/min_catalysts = 0
	var/max_catalysts = 2
	/// Pojemniki, z których losujemy wymagany
	var/list/possible_containers

/datum/chemical_reaction/randomized/New()
	. = ..()
	if(type == /datum/chemical_reaction/randomized)
		return

	var/list/recipe_data = get_saved_randomized_recipes()["[type]"]
	created = recipe_data ? text2num("[recipe_data["timestamp"]]") : world.realtime
	if(!created || (world.realtime - created) / (24 HOURS) > persistence_period)
		created = world.realtime
		recipe_data = null

	if(recipe_data && load_recipe(recipe_data))
		return
	created = world.realtime
	randomize_recipe()

/// Wczytuje recepturę z zapisu, FALSE jeśli zapis jest nieaktualny (np. odczynnik zniknął z kodu)
/datum/chemical_reaction/randomized/proc/load_recipe(list/recipe_data)
	var/list/loaded_reagents = unwrap_reagent_list(recipe_data["required_reagents"])
	var/list/loaded_catalysts = unwrap_reagent_list(recipe_data["required_catalysts"])
	if(!length(loaded_reagents) || isnull(loaded_catalysts))
		return FALSE
	var/container
	if(recipe_data["required_container"])
		container = text2path(recipe_data["required_container"])
		if(!container)
			return FALSE
	required_reagents = loaded_reagents
	required_catalysts = loaded_catalysts
	required_container = container
	is_cold_recipe = recipe_data["is_cold_recipe"]
	required_temp = recipe_data["required_temp"]
	return TRUE

/datum/chemical_reaction/randomized/proc/randomize_recipe()
	var/list/remaining_possible_reagents = GetPossibleReagents(RNGCHEM_INPUT)
	var/list/remaining_possible_catalysts = GetPossibleReagents(RNGCHEM_CATALYSTS)
	for(var/reagent_type in results)
		remaining_possible_catalysts -= reagent_type
		remaining_possible_reagents -= reagent_type

	required_reagents = list()
	required_catalysts = list()
	var/in_reagent_count = min(rand(min_input_reagents, max_input_reagents), length(remaining_possible_reagents))
	if(in_reagent_count <= 0)
		return // Bez składników reakcja nie trafi do listy reakcji
	for(var/i in 1 to in_reagent_count)
		var/reagent_type = pick_n_take(remaining_possible_reagents)
		required_reagents[reagent_type] = rand(min_input_reagent_amount, max_input_reagent_amount)
		remaining_possible_catalysts -= reagent_type

	var/in_catalyst_count = min(rand(min_catalysts, max_catalysts), length(remaining_possible_catalysts))
	for(var/i in 1 to in_catalyst_count)
		required_catalysts[pick_n_take(remaining_possible_catalysts)] = rand(min_input_reagent_amount, max_input_reagent_amount)

	is_cold_recipe = pick(TRUE, FALSE)
	if(is_cold_recipe)
		required_temp = rand(min_temp + 50, max_temp)
	else
		required_temp = rand(min_temp, max_temp - 50)

	if(length(possible_containers))
		required_container = pick(possible_containers)

/// Odczynniki, z których losujemy dany rodzaj składnika
/datum/chemical_reaction/randomized/proc/GetPossibleReagents(kind)
	return list()

/// Zamienia tekstowe ścieżki z JSON-a na typy, null jeśli któraś nie istnieje
/datum/chemical_reaction/randomized/proc/unwrap_reagent_list(list/textreagents)
	if(!islist(textreagents))
		return null
	. = list()
	for(var/text_path in textreagents)
		var/reagent_path = text2path(text_path)
		if(!reagent_path)
			return null
		.[reagent_path] = textreagents[text_path]

/datum/chemical_reaction/randomized/proc/get_save_data()
	return list(
		"timestamp" = num2text(created, 20),
		"required_reagents" = required_reagents,
		"required_catalysts" = required_catalysts,
		"is_cold_recipe" = is_cold_recipe,
		"required_temp" = required_temp,
		"required_container" = required_container ? "[required_container]" : null,
	)

/datum/controller/subsystem/persistence/CollectData()
	. = ..()
	save_randomized_recipes()

/datum/controller/subsystem/persistence/proc/save_randomized_recipes()
	var/list/file_data = list()
	for(var/randomized_type in subtypesof(/datum/chemical_reaction/randomized))
		var/datum/chemical_reaction/randomized/recipe = get_chemical_reaction(randomized_type)
		if(!recipe)
			continue
		file_data["[randomized_type]"] = recipe.get_save_data()
	fdel(RANDOMIZED_RECIPES_FILE)
	text2file(json_encode(file_data), RANDOMIZED_RECIPES_FILE)

/datum/chemical_reaction/randomized/secret_sauce
	name = "Secret Sauce"
	persistence_period = 7
	possible_containers = list(/obj/item/reagent_containers/glass/bucket) // w wiadrze, żeby nie gryzło się ze zwykłymi reakcjami
	results = list(/datum/reagent/consumable/secretsauce = 1)

/datum/chemical_reaction/randomized/secret_sauce/GetPossibleReagents(kind)
	switch(kind)
		if(RNGCHEM_INPUT, RNGCHEM_CATALYSTS)
			. = list()
			for(var/reagent_type in subtypesof(/datum/reagent/consumable))
				if(valid_random_recipe_reagent(reagent_type))
					. += reagent_type
			return
	return ..()

/// Metalgen, zawsze z wittelem jako katalizatorem, zmienia się co 3 dni
/datum/chemical_reaction/randomized/metalgen
	name = "Metalgen"
	persistence_period = 3
	min_catalysts = 1
	max_catalysts = 1
	results = list(/datum/reagent/metalgen = 20)

/datum/chemical_reaction/randomized/metalgen/GetPossibleReagents(kind)
	switch(kind)
		if(RNGCHEM_INPUT)
			. = list()
			for(var/reagent_type in subtypesof(/datum/reagent/medicine))
				if(valid_random_recipe_reagent(reagent_type))
					. += reagent_type
			return
		if(RNGCHEM_CATALYSTS)
			return list(/datum/reagent/wittel)
	return ..()

/// Gorgium, ze wszystkiego, co da się zsyntetyzować
/datum/chemical_reaction/randomized/gorgium
	name = "Gorgium"
	persistence_period = 7
	results = list(/datum/reagent/metalgen/gorgium = 20)

/datum/chemical_reaction/randomized/gorgium/GetPossibleReagents(kind)
	. = list()
	for(var/reagent_type in subtypesof(/datum/reagent))
		if(valid_random_recipe_reagent(reagent_type))
			. += reagent_type

/// Nadaje metalgenowi materiał: metalgen + ciekła ciemna materia + 40u metalu
/datum/chemical_reaction/metalgen_imprint
	name = "Metalgen Imprint"
	required_reagents = list(/datum/reagent/metalgen = 1, /datum/reagent/liquid_dark_matter = 1)
	results = list(/datum/reagent/metalgen = 1)
	/// Odczynnik => materiał, jaki odciska
	var/static/list/reagent_materials = list(
		/datum/reagent/iron = /datum/material/iron,
		/datum/reagent/gold = /datum/material/gold,
		/datum/reagent/silver = /datum/material/silver,
		/datum/reagent/uranium = /datum/material/uranium,
		/datum/reagent/toxin/plasma = /datum/material/plasma,
		/datum/reagent/bluespace = /datum/material/bluespace,
		/datum/reagent/copper = /datum/material/copper,
		/datum/reagent/silicon = /datum/material/glass,
	)

/datum/chemical_reaction/metalgen_imprint/on_reaction(datum/reagents/holder, created_volume)
	var/datum/reagent/metalgen/metalgen = holder.has_reagent(/datum/reagent/metalgen)
	if(!metalgen || metalgen.type != /datum/reagent/metalgen)
		return
	for(var/datum/reagent/metal as anything in holder.reagent_list)
		var/material = reagent_materials[metal.type]
		if(!material || metal.volume < 40)
			continue
		metalgen.data = list("material" = material)
		holder.remove_reagent(metal.type, 40)
		var/atom/container = holder.my_atom
		var/datum/material/material_ref = getmaterialref(material)
		message_admins("[metalgen.volume]u metalgenu dostało odcisk materiału [material_ref.name] w [container] [ADMIN_VERBOSEJMP(container)], ostatni odcisk palca: [container?.fingerprintslast || "brak"]")
		log_game("[metalgen.volume]u of Metalgen imprinted with [material_ref.name] in [container] at [AREACOORD(container)], last fingerprint [container?.fingerprintslast || "none"]")
		break

/obj/item/paper/secretrecipe
	name = "stara receptura"
	/// Receptury, z których kartka losuje
	var/list/possible_recipes = list(/datum/chemical_reaction/randomized/metalgen, /datum/chemical_reaction/randomized/secret_sauce)

/obj/item/paper/secretrecipe/Initialize(mapload)
	. = ..()
	write_recipe()

/// Spisuje recepturę na kartkę
/obj/item/paper/secretrecipe/proc/write_recipe()
	var/datum/chemical_reaction/recipe = get_chemical_reaction(pick(possible_recipes))
	if(!recipe || !length(recipe.required_reagents))
		add_raw_text("Tej receptury nie da się odczytać.")
		update_appearance()
		return
	var/datum/reagent/result_type = recipe.results[1]
	var/list/dat = list("<b>[initial(result_type.name)]</b><ul>")
	for(var/datum/reagent/reagent_type as anything in recipe.required_reagents)
		dat += "<li>[recipe.required_reagents[reagent_type]]u [initial(reagent_type.name)]</li>"
	dat += "</ul>"
	if(length(recipe.required_catalysts))
		dat += "W obecności:<ul>"
		for(var/datum/reagent/reagent_type as anything in recipe.required_catalysts)
			dat += "<li>[recipe.required_catalysts[reagent_type]]u [initial(reagent_type.name)]</li>"
		dat += "</ul>"
	dat += "Mieszać powoli<ul>"
	if(recipe.required_container)
		var/obj/item/container = recipe.required_container
		dat += "<li>w pojemniku: [initial(container.name)]</li>"
	if(recipe.required_temp)
		if(recipe.is_cold_recipe)
			dat += "<li>schładzając poniżej [recipe.required_temp] K</li>"
		else
			dat += "<li>podgrzewając powyżej [recipe.required_temp] K</li>"
	dat += "</ul>"
	add_raw_text(dat.Join(""))
	update_appearance()

/// Skamieniała kartka z recepturą gorgium, tylko w technicznych
/obj/item/paper/secretrecipe/gorgium
	name = "paper"
	possible_recipes = list(/datum/chemical_reaction/randomized/gorgium)

/obj/item/paper/secretrecipe/gorgium/Initialize(mapload)
	. = ..()
	metal_transmute(src, /datum/material/rock)

/// Kartka zawsze z metalgenem
/obj/item/paper/secretrecipe/metalgen
	name = "paper"
	possible_recipes = list(/datum/chemical_reaction/randomized/metalgen)

/obj/item/paper/secretrecipe/metalgen/Initialize(mapload)
	. = ..()
	metal_transmute(src, /datum/material/uranium)

#undef RNGCHEM_INPUT
#undef RNGCHEM_CATALYSTS
#undef RANDOMIZED_RECIPES_FILE
