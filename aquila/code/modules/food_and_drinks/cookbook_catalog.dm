// AQUILA - katalog przepisów kuchennych do programu PDA „Książka kucharska”.
// Zbiera przepisy ze stołu (crafting), procesora, mieszania w zbiorniku oraz to, co powstaje z jedzenia
// w mikrofali, na grillu, w piekarniku i po krojeniu. Te trzy ostatnie znamy dopiero z komponentów,
// więc każdy typ jedzenia jest raz tworzony przy budowaniu katalogu.

GLOBAL_LIST(cookbook_catalog)
/// Podkategorie przepisów ze stołu po polsku
GLOBAL_LIST_INIT(cookbook_categories, list(
	CAT_BREAD = "Pieczywo",
	CAT_BURGER = "Burgery",
	CAT_CAKE = "Ciasta",
	CAT_EGG = "Dania z jajek",
	CAT_ICE = "Desery mrożone",
	CAT_MEAT = "Mięsa",
	CAT_MEXICAN = "Kuchnia meksykańska",
	CAT_MISCFOOD = "Różne",
	CAT_PASTRY = "Wypieki",
	CAT_PIE = "Placki i tarty",
	CAT_PIZZA = "Pizze",
	CAT_SALAD = "Sałatki",
	CAT_SANDWICH = "Kanapki",
	CAT_SEAFOOD = "Owoce morza",
	CAT_SOUP = "Zupy",
	CAT_SPAGHETTI = "Makarony",
))
/// Typ => metoda => list("result", "tool", "amount"), zapisywane przez bakeable/grillable/processable
GLOBAL_LIST_EMPTY(food_transformations)

/proc/record_food_transformation(atom/target, method, result, tool, amount)
	if(!target || !result)
		return
	if(!GLOB.food_transformations[target.type])
		GLOB.food_transformations[target.type] = list()
	GLOB.food_transformations[target.type][method] = list("result" = result, "tool" = tool, "amount" = amount)

/datum/component/bakeable/Initialize(bake_result, required_bake_time, positive_result, use_large_steam_sprite)
	. = ..()
	if(. != COMPONENT_INCOMPATIBLE && positive_result)
		record_food_transformation(parent, "bake", bake_result)

/datum/component/grillable/Initialize(cook_result, required_cook_time, positive_result, use_large_steam_sprite)
	. = ..()
	if(. != COMPONENT_INCOMPATIBLE && positive_result)
		record_food_transformation(parent, "grill", cook_result)

/datum/element/processable/Attach(datum/target, tool_behaviour, result_atom_type, amount_created = 3, time_to_process = 2 SECONDS, table_required = FALSE, screentip_verb = "Przerób")
	. = ..()
	if(. != ELEMENT_INCOMPATIBLE)
		record_food_transformation(target, "process", result_atom_type, tool_behaviour, amount_created)

/// Zwraca wszystkie przepisy kuchenne w formacie dla TGUI (NtosCookbook)
/proc/get_cookbook_catalog()
	if(GLOB.cookbook_catalog)
		return GLOB.cookbook_catalog

	var/list/catalog = list()

	for(var/recipe_type in subtypesof(/datum/crafting_recipe/food))
		var/datum/crafting_recipe/food/recipe = new recipe_type
		if(recipe.name && recipe.result)
			var/list/ingredients = list()
			for(var/ingredient in recipe.reqs)
				ingredients += list(cookbook_ingredient(ingredient, recipe.reqs[ingredient]))
			var/list/tools = list()
			for(var/tool in recipe.tools)
				tools += cookbook_name(tool)
			for(var/catalyst in recipe.chem_catalysts)
				tools += "[recipe.chem_catalysts[catalyst]]u [cookbook_name(catalyst)] (nie zużywa się)"
			catalog += list(cookbook_entry(recipe.result, recipe.name, "Stół", ingredients, tools, GLOB.cookbook_categories[recipe.subcategory] || "Różne", !recipe.always_available))
		qdel(recipe)

	for(var/process_type in subtypesof(/datum/food_processor_process))
		var/datum/food_processor_process/process = new process_type
		// Tylko zwykły procesor kuchenny; procesor szlamów to ksenobiologia
		if(process.input && process.output && process.required_machine == /obj/machinery/processor)
			catalog += list(cookbook_entry(process.output, null, "Procesor", list(cookbook_ingredient(process.input, 1)), list()))
		qdel(process)

	for(var/reaction_type in subtypesof(/datum/chemical_reaction/food))
		var/datum/chemical_reaction/reaction = new reaction_type
		if(reaction.name)
			var/list/ingredients = list()
			for(var/reagent in reaction.required_reagents)
				ingredients += list(cookbook_ingredient(reagent, reaction.required_reagents[reagent]))
			var/list/tools = list()
			for(var/catalyst in reaction.required_catalysts)
				tools += "[reaction.required_catalysts[catalyst]]u [cookbook_name(catalyst)] (nie zużywa się)"
			if(reaction.required_temp)
				tools += "temperatura [reaction.is_cold_recipe ? "poniżej" : "co najmniej"] [reaction.required_temp] K"
			var/result = length(reaction.results) ? reaction.results[1] : null
			catalog += list(cookbook_entry(result, reaction.name, "Mieszanki", ingredients, tools))
		qdel(reaction)

	probe_food_transformations()
	var/static/list/method_names = list("bake" = "Piekarnik", "grill" = "Grill", "process" = "Krojenie")
	var/static/list/tool_names = list(TOOL_KNIFE = "nóż", TOOL_ROLLINGPIN = "wałek", TOOL_SAW = "piła")
	for(var/obj/item/food/food_type as anything in subtypesof(/obj/item/food))
		var/microwaved = initial(food_type.microwaved_type)
		if(microwaved)
			catalog += list(cookbook_entry(microwaved, null, "Mikrofalówka", list(cookbook_ingredient(food_type, 1)), list()))
		var/list/methods = GLOB.food_transformations[food_type]
		for(var/method in methods)
			var/list/transformation = methods[method]
			var/list/tools = list()
			if(transformation["tool"])
				tools += tool_names[transformation["tool"]] || "[transformation["tool"]]"
			var/list/entry = cookbook_entry(transformation["result"], null, method_names[method], list(cookbook_ingredient(food_type, 1)), tools)
			if(transformation["amount"] > 1)
				entry["amount"] = transformation["amount"]
			catalog += list(entry)

	GLOB.cookbook_catalog = catalog
	return catalog

/// Tworzy raz każde jedzenie, którego jeszcze nie było w tej rundzie, żeby jego komponenty zapisały przemiany
/proc/probe_food_transformations()
	var/static/probed = FALSE
	if(probed)
		return
	probed = TRUE
	var/static/list/skip = typecacheof(list(/obj/item/food/grown)) // potrzebują nasion, tak jak w create_and_destroy
	for(var/food_type in subtypesof(/obj/item/food))
		if(skip[food_type] || GLOB.food_transformations[food_type])
			continue
		var/obj/item/food/probe = new food_type(null)
		qdel(probe)

/proc/cookbook_entry(result, name, method, list/ingredients, list/tools, category, learned = FALSE)
	var/result_name = result ? cookbook_name(result) : null
	var/desc
	if(ispath(result, /atom))
		var/atom/result_type = result
		desc = initial(result_type.desc)
	else if(ispath(result, /datum/reagent))
		var/datum/reagent/reagent = GLOB.chemical_reagents_list[result]
		desc = reagent?.description
	return list(
		"id" = "[method]:[result]:[name]:[length(ingredients) ? ingredients[1]["name"] : ""]",
		"name" = capitalize(result_name || name),
		"desc" = desc,
		"method" = method,
		"ingredients" = ingredients,
		"tools" = tools,
		"category" = category,
		"learned" = learned,
	)

/proc/cookbook_ingredient(path, amount)
	return list("name" = cookbook_name(path), "amount" = amount, "reagent" = ispath(path, /datum/reagent))

/proc/cookbook_name(path)
	if(ispath(path, /datum/reagent))
		var/datum/reagent/reagent = GLOB.chemical_reagents_list[path]
		return reagent ? reagent.name : "[path]"
	if(ispath(path, /atom))
		var/atom/atom_type = path
		return initial(atom_type.name)
	return "[path]"

/datum/computer_file/program/cookbook
	filename = "kucharz"
	filedesc = "Książka kucharska"
	category = PROGRAM_CATEGORY_CREW
	program_icon_state = "generic"
	extended_desc = "Przepisy na jedzenie: stół, procesor, mikrofalówka, grill, piekarnik i krojenie, z wyszukiwarką po daniu albo składniku."
	size = 2
	tgui_id = "NtosCookbook"
	program_icon = "utensils"
	usage_flags = PROGRAM_ALL

/datum/computer_file/program/cookbook/ui_static_data(mob/user)
	. = ..()
	.["recipes"] = get_cookbook_catalog()

/obj/item/modular_computer/tablet/pda/cook/Initialize(mapload)
	. = ..()
	var/obj/item/computer_hardware/hard_drive/hdd = all_components[MC_HDD]
	hdd?.store_file(new /datum/computer_file/program/cookbook(hdd))
	// Katalog tworzy każde jedzenie (~0,4 s), więc lepiej przy starcie niż przy pierwszym otwarciu programu
	if(!GLOB.cookbook_catalog)
		addtimer(CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(get_cookbook_catalog)), 5 SECONDS)
