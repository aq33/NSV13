// The upstream assert macros are #undef'd at the end of code/modules/unit_tests/_unit_tests.dm, so this modular test carries its own copies
#define TEST_ASSERT(assertion, reason) if (!(assertion)) { return Fail("Assertion failed: [reason || "No reason"]") }

/// AQUILA - katalogi wyszukiwarek receptur i operacji: niepuste, bez losowanych receptur, każda operacja ma kroki z narzędziami
/datum/unit_test/recipe_surgery_lookup

/datum/unit_test/recipe_surgery_lookup/Run()
	var/list/recipes = get_recipe_catalog()
	TEST_ASSERT(length(recipes) > 100, "Katalog receptur ma tylko [length(recipes)] pozycji")
	for(var/list/recipe as anything in recipes)
		TEST_ASSERT(recipe["name"], "Receptura [recipe["id"]] nie ma nazwy")
		TEST_ASSERT(length(recipe["reagents"]), "Receptura [recipe["id"]] nie ma składników")
		TEST_ASSERT(!ispath(text2path(recipe["id"]), /datum/chemical_reaction/randomized), "Losowana receptura [recipe["id"]] trafiła do katalogu")

	var/list/surgeries = get_surgery_catalog()
	TEST_ASSERT(length(surgeries) > 20, "Katalog operacji ma tylko [length(surgeries)] pozycji")
	for(var/list/surgery as anything in surgeries)
		TEST_ASSERT(length(surgery["steps"]), "Operacja [surgery["id"]] nie ma kroków")
		for(var/list/step as anything in surgery["steps"])
			TEST_ASSERT(length(step["tools"]), "Krok [step["name"]] operacji [surgery["id"]] nie ma narzędzi")

#undef TEST_ASSERT
