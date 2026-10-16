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

	var/list/extracts = get_slime_extract_catalog()
	TEST_ASSERT(length(extracts) > 10, "Katalog ekstraktów ma tylko [length(extracts)] pozycji")
	for(var/list/extract as anything in extracts)
		TEST_ASSERT(length(extract["reactions"]), "Ekstrakt [extract["id"]] nie ma reakcji")

	var/list/symptoms = get_symptom_catalog()
	TEST_ASSERT(length(symptoms) > 20, "Katalog symptomów ma tylko [length(symptoms)] pozycji")
	var/sourced = 0
	for(var/list/symptom as anything in symptoms)
		if(length(symptom["sources"]))
			sourced++
	TEST_ASSERT(sourced > 10, "Tylko [sourced] symptomów ma odczynnik, który je losuje")

	var/list/law = get_space_law_catalog()
	TEST_ASSERT(length(law) >= 4, "Prawo kosmiczne ma tylko [length(law)] kategorii")
	for(var/list/category as anything in law)
		TEST_ASSERT(length(category["crimes"]), "Kategoria prawa [category["name"]] jest pusta")

	var/list/cookbook = get_cookbook_catalog()
	TEST_ASSERT(length(cookbook) > 200, "Książka kucharska ma tylko [length(cookbook)] przepisów")
	var/list/methods = list()
	for(var/list/recipe as anything in cookbook)
		TEST_ASSERT(recipe["name"], "Przepis [recipe["id"]] nie ma nazwy")
		methods[recipe["method"]] = TRUE
	for(var/method in list("stół", "mikrofalówka", "grill", "piekarnik", "krojenie"))
		TEST_ASSERT(methods[method], "W książce kucharskiej nie ma przepisów typu „[method]”")

	// Dyski zawodowe mają programy; dysk ma też drugą definicję Initialize() w logprobe.dm
	TEST_ASSERT(disk_has_program(/obj/item/computer_hardware/hard_drive/role/medical, /datum/computer_file/program/surgery_lookup), "Dysk medyczny nie ma programu „Operacje”")
	TEST_ASSERT(disk_has_program(/obj/item/computer_hardware/hard_drive/role/chemistry, /datum/computer_file/program/recipe_lookup), "Dysk chemiczny nie ma programu „Receptury”")
	TEST_ASSERT(disk_has_program(/obj/item/computer_hardware/hard_drive/role/signal/toxins, /datum/computer_file/program/slime_extracts), "Dysk naukowy nie ma programu „Ekstrakty”")
	TEST_ASSERT(disk_has_program(/obj/item/computer_hardware/hard_drive/role/security, /datum/computer_file/program/space_law), "Dysk ochrony nie ma programu „Prawo kosmiczne”")

/datum/unit_test/recipe_surgery_lookup/proc/disk_has_program(disk_type, program_type)
	var/obj/item/computer_hardware/hard_drive/disk = allocate(disk_type)
	return !!(locate(program_type) in disk.stored_files)

#undef TEST_ASSERT
