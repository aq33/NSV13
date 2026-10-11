// Port BeeStation #12485: nasze przepisy w kształcie, którego używa nowe menu craftingu.
// Pliki przepisów zostają bez zmian: stare kategorie (CAT_WEAPONRY + podkategoria), "tools" i "always_available"
// są tłumaczone przy tworzeniu przepisu. Przepisy ze stosów (płyty, pręty, drewno...) też trafiają do menu.

/// Categories of the cooking mode, everything else is in the crafting mode
GLOBAL_LIST_INIT(crafting_category_food, list(
	CAT_FOOD,
	CAT_BREAD,
	CAT_BURGER,
	CAT_CAKE,
	CAT_EGG,
	CAT_MEAT,
	CAT_SEAFOOD,
	CAT_MISCFOOD,
	CAT_MEXICAN,
	CAT_PASTRY,
	CAT_PIE,
	CAT_PIZZA,
	CAT_SALAD,
	CAT_SANDWICH,
	CAT_SOUP,
	CAT_SPAGHETTI,
	CAT_ICE,
	CAT_DRINK,
))

/// Cooking recipes, the crafting ones stay in GLOB.crafting_recipes
GLOBAL_LIST_EMPTY(cooking_recipes)
/// Every atom used by a crafting recipe, its index is the id the crafting menu uses
GLOBAL_LIST_EMPTY(crafting_recipes_atoms)
/// Every atom used by a cooking recipe, its index is the id the crafting menu uses
GLOBAL_LIST_EMPTY(cooking_recipes_atoms)

/datum/crafting_recipe
	/// Description displayed in game, optional, if not set uses the result's desc
	var/desc
	/// String defines of tool behaviours needed but not consumed (from our "tools")
	var/list/tool_behaviors
	/// Type paths of items needed but not consumed (from our "tools")
	var/list/tool_paths
	/// Required machines for the craft: type path -> CRAFTING_MACHINERY_CONSUME or CRAFTING_MACHINERY_USE
	var/list/machinery
	/// Required structures for the craft: type path -> CRAFTING_STRUCTURE_CONSUME or CRAFTING_STRUCTURE_USE
	var/list/structures
	/// Bitflag of additional placement checks (STACK_CHECK_CARDINALS | STACK_CHECK_ADJACENT)
	var/placement_checks = NONE
	/// Steps needed to achieve the result
	var/list/steps
	/// Whether the result can be crafted with a crafting menu button
	var/non_craftable
	/// Chemical reaction described in the recipe
	var/datum/chemical_reaction/reaction
	/// Resulting amount (for stacks only)
	var/result_amount
	/// Whether we should delete the contents of the crafted storage item
	var/delete_contents = TRUE
	/// Allows you to craft so that you don't have to click the craft button many times
	var/mass_craftable = FALSE
	/// Should admins be notified about this getting created by a non-antagonist?
	var/dangerous_craft = FALSE
	/// Crafting flags (CRAFT_*). Our recipes never checked density, so neither does the default.
	var/crafting_flags = NONE

/// Translates our recipe to the new menu, called when the recipe lists are built
/// (not from New(), the food recipes override New() without calling the parent)
/datum/crafting_recipe/proc/aquila_setup()
	// Our recipes mix tool behaviours and item paths in one list
	for(var/tool in tools)
		if(ispath(tool))
			LAZYADD(tool_paths, tool)
		else
			LAZYADD(tool_behaviors, tool)
	if(!always_available)
		crafting_flags |= CRAFT_MUST_BE_LEARNED
	category = aquila_crafting_category()

/// The category of the new crafting menu for our two level categories
/datum/crafting_recipe/proc/aquila_crafting_category()
	var/old_category = (subcategory && subcategory != CAT_NONE) ? subcategory : category
	switch(old_category)
		if(CAT_WEAPON, CAT_WEAPONRY)
			return ispath(result, /obj/item/gun) ? CAT_WEAPON_RANGED : CAT_WEAPON_MELEE
		if(CAT_AMMO)
			return CAT_WEAPON_AMMO
		if(CAT_EYEWEAR)
			return CAT_CLOTHING
		if(CAT_FOOD)
			return CAT_MISCFOOD
		if(CAT_NONE, null)
			return CAT_MISC
	return old_category

/// Additional UI data to be passed to the crafting UI for this recipe
/datum/crafting_recipe/proc/crafting_ui_data()
	return list()

/datum/crafting_recipe/food
	mass_craftable = TRUE

/datum/crafting_recipe/food/crafting_ui_data()
	var/list/data = list()
	if(ispath(result, /obj/item/food))
		var/obj/item/food/item = result
		data["foodtypes"] = bitfield2list(initial(item.foodtypes), FOOD_FLAGS)
	data["nutriments"] = 0
	return data

/// A stack recipe (sheets, rods, wood...) shown in the crafting menu
/datum/crafting_recipe/stack
	always_available = TRUE

/datum/crafting_recipe/stack/New(obj/item/stack/material, datum/stack_recipe/stack_recipe)
	if(!material || !stack_recipe || !stack_recipe.result_type)
		return
	name = stack_recipe.title
	time = stack_recipe.time
	result = stack_recipe.result_type
	result_amount = stack_recipe.res_amount
	reqs = list()
	reqs[material] = stack_recipe.req_amount
	..()
	aquila_setup()
	category = aquila_stack_category(result)
	if(stack_recipe.one_per_turf)
		crafting_flags |= CRAFT_ONE_PER_TURF
	if(stack_recipe.on_floor)
		crafting_flags |= CRAFT_ON_SOLID_GROUND
	if(stack_recipe.window_checks)
		crafting_flags |= CRAFT_CHECK_DIRECTION
	if(stack_recipe.placement_checks)
		placement_checks |= STACK_CHECK_CARDINALS

/// Our stack recipes have no categories, pick one from what they make
/datum/crafting_recipe/stack/proc/aquila_stack_category(result_path)
	if(ispath(result_path, /obj/structure/window) || ispath(result_path, /obj/structure/windoor_assembly))
		return CAT_WINDOWS
	if(ispath(result_path, /obj/structure/door_assembly) || ispath(result_path, /obj/structure/mineral_door) || ispath(result_path, /obj/machinery/door))
		return CAT_DOORS
	if(ispath(result_path, /obj/item/stack/tile) || ispath(result_path, /turf))
		return CAT_TILES
	if(ispath(result_path, /obj/structure/chair) || ispath(result_path, /obj/structure/bed) || ispath(result_path, /obj/structure/table) || ispath(result_path, /obj/structure/rack) || ispath(result_path, /obj/item/chair))
		return CAT_FURNITURE
	if(ispath(result_path, /obj/item/storage) || ispath(result_path, /obj/structure/closet) || ispath(result_path, /obj/item/reagent_containers))
		return CAT_CONTAINERS
	if(ispath(result_path, /obj/item/gun))
		return CAT_WEAPON_RANGED
	if(ispath(result_path, /obj/item/spear) || ispath(result_path, /obj/item/kitchen/knife) || ispath(result_path, /obj/item/melee))
		return CAT_WEAPON_MELEE
	if(ispath(result_path, /obj/item/clothing))
		return CAT_CLOTHING
	if(ispath(result_path, /obj/structure) || ispath(result_path, /obj/machinery))
		return CAT_STRUCTURE
	return CAT_MISC

/// Fills GLOB.crafting_recipes and GLOB.cooking_recipes, called from make_datum_references_lists()
/proc/aquila_init_crafting_recipes()
	for(var/path in subtypesof(/datum/crafting_recipe))
		if(ispath(path, /datum/crafting_recipe/stack))
			continue
		var/datum/crafting_recipe/recipe = new path()
		if(!recipe.result)
			continue
		if(!recipe.name)
			var/atom/result_atom = recipe.result
			recipe.name = initial(result_atom.name)
		recipe.aquila_setup()
		if(recipe.category in GLOB.crafting_category_food)
			GLOB.cooking_recipes += recipe
		else
			GLOB.crafting_recipes += recipe

	var/list/global_stack_recipes = list(
		/obj/item/stack/sheet/glass = GLOB.glass_recipes,
		/obj/item/stack/sheet/plasmaglass = GLOB.pglass_recipes,
		/obj/item/stack/sheet/rglass = GLOB.reinforced_glass_recipes,
		/obj/item/stack/sheet/plasmarglass = GLOB.prglass_recipes,
		/obj/item/stack/sheet/animalhide/gondola = GLOB.gondola_recipes,
		/obj/item/stack/sheet/animalhide/corgi = GLOB.corgi_recipes,
		/obj/item/stack/sheet/animalhide/monkey = GLOB.monkey_recipes,
		/obj/item/stack/sheet/animalhide/xeno = GLOB.xeno_recipes,
		/obj/item/stack/sheet/leather = GLOB.leather_recipes,
		/obj/item/stack/sheet/sinew = GLOB.sinew_recipes,
		/obj/item/stack/sheet/mineral/sandstone = GLOB.sandstone_recipes,
		/obj/item/stack/sheet/mineral/sandbags = GLOB.sandbag_recipes,
		/obj/item/stack/sheet/mineral/diamond = GLOB.diamond_recipes,
		/obj/item/stack/sheet/mineral/uranium = GLOB.uranium_recipes,
		/obj/item/stack/sheet/mineral/plasma = GLOB.plasma_recipes,
		/obj/item/stack/sheet/mineral/gold = GLOB.gold_recipes,
		/obj/item/stack/sheet/mineral/silver = GLOB.silver_recipes,
		/obj/item/stack/sheet/mineral/copper = GLOB.copper_recipes,
		/obj/item/stack/sheet/mineral/bananium = GLOB.bananium_recipes,
		/obj/item/stack/sheet/mineral/titanium = GLOB.titanium_recipes,
		/obj/item/stack/sheet/mineral/plastitanium = GLOB.plastitanium_recipes,
		/obj/item/stack/sheet/mineral/snow = GLOB.snow_recipes,
		/obj/item/stack/sheet/mineral/adamantine = GLOB.adamantine_recipes,
		/obj/item/stack/sheet/mineral/abductor = GLOB.abductor_recipes,
		/obj/item/stack/sheet/iron = GLOB.metal_recipes,
		/obj/item/stack/sheet/plasteel = GLOB.plasteel_recipes,
		/obj/item/stack/sheet/mineral/wood = GLOB.wood_recipes,
		/obj/item/stack/sheet/mineral/bamboo = GLOB.bamboo_recipes,
		/obj/item/stack/sheet/cotton/cloth = GLOB.cloth_recipes,
		/obj/item/stack/sheet/durathread = GLOB.durathread_recipes,
		/obj/item/stack/sheet/cardboard = GLOB.cardboard_recipes,
		/obj/item/stack/tile/bronze = GLOB.bronze_recipes,
		/obj/item/stack/sheet/plastic = GLOB.plastic_recipes,
		/obj/item/stack/ore/glass = GLOB.sand_recipes,
		/obj/item/stack/rods = GLOB.rod_recipes,
		/obj/item/stack/sheet/runed_metal = GLOB.runed_metal_recipes,
	)
	for(var/stack in global_stack_recipes)
		for(var/stack_recipe in global_stack_recipes[stack])
			if(istype(stack_recipe, /datum/stack_recipe_list))
				var/datum/stack_recipe_list/stack_recipe_list = stack_recipe
				for(var/nested_recipe in stack_recipe_list.recipes)
					aquila_add_stack_crafting_recipe(stack, nested_recipe)
			else
				aquila_add_stack_crafting_recipe(stack, stack_recipe)

	aquila_init_crafting_recipes_atoms()

/proc/aquila_add_stack_crafting_recipe(stack, datum/stack_recipe/stack_recipe)
	if(!istype(stack_recipe))
		return
	var/datum/crafting_recipe/stack/recipe = new /datum/crafting_recipe/stack(stack, stack_recipe)
	if(recipe.name && recipe.result)
		GLOB.crafting_recipes += recipe

/// Every atom used in the crafting and cooking recipes, the crafting menu sends atom ids instead of paths
/proc/aquila_init_crafting_recipes_atoms()
	var/list/recipe_lists = list(GLOB.crafting_recipes, GLOB.cooking_recipes)
	var/list/atom_lists = list(GLOB.crafting_recipes_atoms, GLOB.cooking_recipes_atoms)
	for(var/list_index in 1 to length(recipe_lists))
		var/list/recipe_list = recipe_lists[list_index]
		var/list/atom_list = atom_lists[list_index]
		for(var/datum/crafting_recipe/recipe as anything in recipe_list)
			atom_list |= recipe.result
			for(var/req_atom in recipe.reqs)
				atom_list |= req_atom
			for(var/req_atom in recipe.chem_catalysts)
				atom_list |= req_atom
			if(recipe.reaction)
				var/required_container = initial(recipe.reaction.required_container)
				if(required_container)
					atom_list |= required_container
			for(var/req_atom in recipe.tool_paths)
				atom_list |= req_atom
			for(var/req_atom in recipe.machinery)
				atom_list |= req_atom
			for(var/req_atom in recipe.structures)
				atom_list |= req_atom

/// Representative icons for the contents of each crafting recipe
/datum/asset/spritesheet/crafting
	name = "crafting"

/datum/asset/spritesheet/crafting/register()
	fill_icons()
	..()

/// Adds the icons of this sheet, the cooking sheet only has its own atoms
/datum/asset/spritesheet/crafting/proc/fill_icons()
	var/id = 1
	for(var/atom in GLOB.crafting_recipes_atoms)
		add_atom_icon(atom, id++)
	add_tool_icons()

/datum/asset/spritesheet/crafting/cooking
	name = "cooking"

/datum/asset/spritesheet/crafting/cooking/fill_icons()
	var/id = 1
	for(var/atom in GLOB.cooking_recipes_atoms)
		add_atom_icon(atom, id++)

/// Adds the icon of an ingredient or result, reagents are shown as a beaker
/datum/asset/spritesheet/crafting/proc/add_atom_icon(ingredient_typepath, id)
	var/obj/preview_item = ingredient_typepath
	if(ispath(ingredient_typepath, /datum/reagent))
		preview_item = /obj/item/reagent_containers/glass/beaker
	if(!ispath(preview_item, /atom))
		return
	var/icon_file = initial(preview_item.icon)
	var/icon_state = initial(preview_item.icon_state)
	if(!icon_file || !(icon_state in icon_states(icon_file)))
		return
	Insert("a[id]", icon(icon_file, icon_state, SOUTH))

/// Tool icons shown next to the recipes
/datum/asset/spritesheet/crafting/proc/add_tool_icons()
	var/list/tool_icons = list(
		TOOL_CROWBAR = list('icons/obj/tools.dmi', "crowbar"),
		TOOL_MULTITOOL = list('icons/obj/device.dmi', "multitool"),
		TOOL_SCREWDRIVER = list('icons/obj/tools.dmi', "screwdriver_map"),
		TOOL_WIRECUTTER = list('icons/obj/tools.dmi', "cutters_map"),
		TOOL_WRENCH = list('icons/obj/tools.dmi', "wrench"),
		TOOL_WELDER = list('icons/obj/tools.dmi', "welder"),
		TOOL_ANALYZER = list('icons/obj/device.dmi', "analyzer"),
		TOOL_MINING = list('icons/obj/mining.dmi', "minipick"),
		TOOL_SHOVEL = list('icons/obj/mining.dmi', "spade"),
		TOOL_RETRACTOR = list('icons/obj/surgery.dmi', "retractor"),
		TOOL_HEMOSTAT = list('icons/obj/surgery.dmi', "hemostat"),
		TOOL_CAUTERY = list('icons/obj/surgery.dmi', "cautery"),
		TOOL_DRILL = list('icons/obj/surgery.dmi', "drill"),
		TOOL_SCALPEL = list('icons/obj/surgery.dmi', "scalpel"),
		TOOL_SAW = list('icons/obj/surgery.dmi', "saw"),
		TOOL_KNIFE = list('icons/obj/kitchen.dmi', "knife"),
		TOOL_ROLLINGPIN = list('icons/obj/kitchen.dmi', "rolling_pin"),
	)
	for(var/tool in tool_icons)
		var/list/icon_data = tool_icons[tool]
		if(!(icon_data[2] in icon_states(icon_data[1])))
			continue
		Insert(replacetext(tool, " ", ""), icon(icon_data[1], icon_data[2], SOUTH))
