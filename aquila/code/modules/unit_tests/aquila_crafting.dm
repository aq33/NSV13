// The upstream assert macros are #undef'd at the end of code/modules/unit_tests/_unit_tests.dm, so this modular test carries its own copies
#define TEST_ASSERT(assertion, reason) if (!(assertion)) { return Fail("Assertion failed: [reason || "No reason"]") }

/// AQUILA - BeeStation#12485: our recipes in the new crafting menu
/datum/unit_test/aquila_crafting

/datum/unit_test/aquila_crafting/Run()
	TEST_ASSERT(length(GLOB.crafting_recipes) > 50, "Only [length(GLOB.crafting_recipes)] crafting recipes")
	TEST_ASSERT(length(GLOB.cooking_recipes) > 50, "Only [length(GLOB.cooking_recipes)] cooking recipes")

	var/list/old_categories = list(CAT_WEAPONRY, CAT_WEAPON, CAT_AMMO, CAT_EYEWEAR, CAT_FOOD, CAT_NONE)
	var/found_stack_chair = FALSE
	for(var/datum/crafting_recipe/recipe as anything in GLOB.crafting_recipes)
		TEST_ASSERT(!(recipe.category in old_categories), "[recipe.type] ([recipe.name]) still has the old category [recipe.category]")
		TEST_ASSERT(!(recipe.category in GLOB.crafting_category_food), "Food recipe [recipe.type] is in the crafting mode")
		if(istype(recipe, /datum/crafting_recipe/stack) && ispath(recipe.result, /obj/structure/chair))
			found_stack_chair = TRUE
	TEST_ASSERT(found_stack_chair, "Stack recipes (a metal chair) are not in the crafting menu")
	for(var/datum/crafting_recipe/recipe as anything in GLOB.cooking_recipes)
		TEST_ASSERT(recipe.category in GLOB.crafting_category_food, "[recipe.type] in the cooking mode has category [recipe.category]")

	// Our "tools" list is split into behaviours and paths
	for(var/datum/crafting_recipe/recipe as anything in GLOB.crafting_recipes + GLOB.cooking_recipes)
		for(var/tool in recipe.tools)
			if(ispath(tool))
				TEST_ASSERT(tool in recipe.tool_paths, "[recipe.type]: tool [tool] is not in tool_paths")
			else
				TEST_ASSERT(tool in recipe.tool_behaviors, "[recipe.type]: tool [tool] is not in tool_behaviors")

	// Every result has an atom id for the menu
	for(var/datum/crafting_recipe/recipe as anything in GLOB.crafting_recipes)
		TEST_ASSERT(recipe.result in GLOB.crafting_recipes_atoms, "[recipe.type] result has no atom id")

	// The window data
	var/mob/living/carbon/human/crafter = allocate(/mob/living/carbon/human)
	var/datum/component/personal_crafting/crafting = crafter.GetComponent(/datum/component/personal_crafting)
	TEST_ASSERT(crafting, "Humans have no crafting component")
	var/list/static_data = crafting.ui_static_data(crafter)
	TEST_ASSERT(length(static_data["recipes"]) && length(static_data["categories"]), "The crafting menu has no recipes or categories")
	TEST_ASSERT(length(static_data["atom_data"]) == length(GLOB.crafting_recipes_atoms), "Atom data does not match the atom ids")
	var/list/dynamic_data = crafting.ui_data(crafter)
	TEST_ASSERT(islist(dynamic_data["craftability"]), "No craftability data")

	// Building a stack recipe from the menu: two metal sheets next to the crafter make a chair
	var/datum/crafting_recipe/stack/chair_recipe
	for(var/datum/crafting_recipe/stack/recipe in GLOB.crafting_recipes)
		if(recipe.result == /obj/structure/chair && (/obj/item/stack/sheet/iron in recipe.reqs))
			chair_recipe = recipe
			break
	TEST_ASSERT(chair_recipe, "No metal chair stack recipe")
	chair_recipe.time = 0
	var/obj/item/stack/sheet/iron/sheets = allocate(/obj/item/stack/sheet/iron, run_loc_floor_bottom_left, 5)
	crafter.forceMove(run_loc_floor_bottom_left)
	var/result = crafting.construct_item(crafter, chair_recipe)
	TEST_ASSERT(istype(result, /obj/structure/chair), "Crafting a chair from the menu failed: [result]")
	TEST_ASSERT(QDELETED(sheets) || sheets.amount == 5 - chair_recipe.reqs[/obj/item/stack/sheet/iron], "The chair did not use the sheets")
	qdel(result)

#undef TEST_ASSERT
