// The upstream assert macros are #undef'd at the end of code/modules/unit_tests/_unit_tests.dm, so this modular test carries its own copies
#define TEST_ASSERT(assertion, reason) if (!(assertion)) { return Fail("Assertion failed: [reason || "No reason"]") }

/// AQUILA - sekretne chemikalia z tg: losowane receptury, kartki, metalgen i chemikalia z maint pilli
/datum/unit_test/aquila_secret_chems

/datum/unit_test/aquila_secret_chems/Run()
	var/turf/start = run_loc_floor_bottom_left

	// Każda losowa receptura ma składniki z puli syntezowalnych i jest na liście reakcji
	for(var/randomized_type in subtypesof(/datum/chemical_reaction/randomized))
		var/datum/chemical_reaction/randomized/recipe = get_chemical_reaction(randomized_type)
		TEST_ASSERT(recipe, "[randomized_type] nie trafiła na listę reakcji")
		TEST_ASSERT(length(recipe.required_reagents), "[randomized_type] nie ma składników")
		for(var/reagent_type in recipe.required_reagents)
			TEST_ASSERT(valid_random_recipe_reagent(reagent_type), "[randomized_type] wymaga niesyntezowalnego [reagent_type]")
		var/first_reagent = recipe.required_reagents[1]
		TEST_ASSERT(recipe in GLOB.chemical_reactions_list[first_reagent], "[randomized_type] nie jest podpięta pod [first_reagent]")
	var/datum/chemical_reaction/randomized/metalgen_recipe = get_chemical_reaction(/datum/chemical_reaction/randomized/metalgen)
	TEST_ASSERT(metalgen_recipe.required_catalysts[/datum/reagent/wittel], "Metalgen nie wymaga wittelu")
	var/datum/chemical_reaction/randomized/sauce_recipe = get_chemical_reaction(/datum/chemical_reaction/randomized/secret_sauce)
	TEST_ASSERT(sauce_recipe.required_container == /obj/item/reagent_containers/glass/bucket, "Sekretny sos nie wymaga wiadra")

	// Zapis receptury da się wczytać z powrotem
	var/list/saved = json_decode(json_encode(metalgen_recipe.get_save_data()))
	var/datum/chemical_reaction/randomized/metalgen/reloaded = new
	TEST_ASSERT(reloaded.load_recipe(saved), "Zapisana receptura metalgenu się nie wczytuje")
	TEST_ASSERT(reloaded.required_reagents ~= metalgen_recipe.required_reagents, "Wczytane składniki różnią się od zapisanych")
	TEST_ASSERT(reloaded.required_temp == metalgen_recipe.required_temp, "Wczytana temperatura różni się od zapisanej")
	qdel(reloaded)

	// Uszkodzony zapis nie wywala dekodowania, a receptura i tak dostaje składniki
	var/list/broken_save = decode_randomized_recipes("{\"/datum/chemical_reaction/randomized/metalgen\": {\"timestamp\": ")
	TEST_ASSERT(islist(broken_save) && !length(broken_save), "Uszkodzony zapis nie dał pustej listy")
	var/datum/chemical_reaction/randomized/metalgen/fresh = new
	TEST_ASSERT(!fresh.load_recipe(list("required_reagents" = "zepsute")), "Wczytano recepturę z uszkodzonych danych")
	var/list/bad_temp = saved.Copy()
	bad_temp["required_temp"] = "gorąco"
	TEST_ASSERT(!fresh.load_recipe(bad_temp), "Wczytano recepturę z nieliczbową temperaturą")
	TEST_ASSERT(length(fresh.required_reagents), "Receptura bez zapisu nie ma składników")
	qdel(fresh)

	// Kartki: skamieniała z gorgium, uranowa z metalgenem
	var/obj/item/paper/secretrecipe/gorgium/rock_paper = allocate(/obj/item/paper/secretrecipe/gorgium, start)
	TEST_ASSERT(LAZYLEN(rock_paper.raw_text_inputs), "Kartka gorgium jest pusta")
	var/datum/paper_input/rock_text = rock_paper.raw_text_inputs[1]
	TEST_ASSERT(findtext(rock_text.raw_text, "Gorgium"), "Na kartce gorgium nie ma gorgium")
	TEST_ASSERT(rock_paper.custom_materials?[getmaterialref(/datum/material/rock)], "Kartka gorgium nie jest z kamienia")
	TEST_ASSERT(rock_paper.name == "rock paper", "Kartka gorgium nazywa się [rock_paper.name]")
	var/obj/item/paper/secretrecipe/metalgen/uranium_paper = allocate(/obj/item/paper/secretrecipe/metalgen, start)
	TEST_ASSERT(uranium_paper.custom_materials?[getmaterialref(/datum/material/uranium)], "Kartka metalgenu nie jest z uranu")

	// Ponowna przemiana zdejmuje poprzedni materiał zamiast go kumulować
	metal_transmute(rock_paper, /datum/material/gold)
	TEST_ASSERT(length(rock_paper.custom_materials) == 1 && rock_paper.custom_materials[getmaterialref(/datum/material/gold)], "Przemiana nie zdjęła starego materiału")
	TEST_ASSERT(rock_paper.name == "gold paper", "Druga przemiana dała nazwę [rock_paper.name]")

	// Odcisk metalgenu: metalgen + ciemna materia + 40u złota
	var/obj/item/reagent_containers/glass/beaker/large/beaker = allocate(/obj/item/reagent_containers/glass/beaker/large, start)
	beaker.reagents.add_reagent(/datum/reagent/gold, 40)
	beaker.reagents.add_reagent(/datum/reagent/metalgen, 10)
	beaker.reagents.add_reagent(/datum/reagent/liquid_dark_matter, 1)
	var/datum/reagent/metalgen/imprinted = beaker.reagents.has_reagent(/datum/reagent/metalgen)
	TEST_ASSERT(imprinted?.data?["material"] == /datum/material/gold, "Metalgen nie dostał odcisku złota")
	var/obj/item/toy/eightball/ball = allocate(/obj/item/toy/eightball, start)
	imprinted.reaction_obj(ball, 10)
	TEST_ASSERT(ball.custom_materials?[getmaterialref(/datum/material/gold)], "Metalgen nie pozłocił przedmiotu")

	// Gorgium zamienia w posąg
	var/mob/living/carbon/human/statue_victim = allocate(/mob/living/carbon/human, start)
	var/datum/reagent/metalgen/gorgium/gorgium = GLOB.chemical_reagents_list[/datum/reagent/metalgen/gorgium]
	gorgium.reaction_mob(statue_victim, TOUCH, 2)
	TEST_ASSERT(!istype(statue_victim.loc, /obj/structure/statue/petrified), "Gorgium skamieniło poniżej progu")
	gorgium.reaction_mob(statue_victim, TOUCH, 5)
	var/obj/structure/statue/petrified/statue = statue_victim.loc
	TEST_ASSERT(istype(statue), "Gorgium nie skamieniło")
	TEST_ASSERT(statue.timer == 25, "Posąg trwa [statue.timer] s zamiast 25")
	qdel(statue)

	// Gibbium daje nieroznoszący się GBS
	var/mob/living/carbon/human/gib_victim = allocate(/mob/living/carbon/human, start)
	gib_victim.reagents.add_reagent(/datum/reagent/toxin/gibbium, 10)
	var/datum/reagent/toxin/gibbium/gibbium = gib_victim.reagents.has_reagent(/datum/reagent/toxin/gibbium)
	gibbium.current_cycle = gibbium.gib_cycle
	gibbium.on_mob_life(gib_victim)
	var/datum/disease/gbs/no_transmission/gbs = locate() in gib_victim.diseases
	TEST_ASSERT(gbs, "Gibbium nie dało GBS")
	TEST_ASSERT(gbs.spread_flags == DISEASE_SPREAD_NON_CONTAGIOUS, "GBS z gibbium się roznosi")

	// Surowica pająka zamienia w pająka olbrzymiego
	var/mob/living/carbon/human/spider_victim = allocate(/mob/living/carbon/human, start)
	spider_victim.reagents.add_reagent(/datum/reagent/toxin/spider_serum, 10)
	var/datum/reagent/toxin/spider_serum/serum = spider_victim.reagents.has_reagent(/datum/reagent/toxin/spider_serum)
	serum.current_cycle = serum.transformation_cycle
	serum.on_mob_life(spider_victim)
	var/mob/living/simple_animal/hostile/spider/giant/new_spider = locate() in start
	TEST_ASSERT(new_spider, "Surowica nie zrobiła pająka")
	TEST_ASSERT(!spider_victim.reagents.has_reagent(/datum/reagent/toxin/spider_serum), "Surowica została w ciele po przemianie")
	qdel(new_spider)

	// Wszystkie trzy chemikalia z pilli i gorgium mogą wypaść z maint pilla
	var/list/fun_reagents = get_random_reagent_id(CHEMICAL_RNG_FUN, return_as_list = TRUE)
	for(var/reagent_type in list(/datum/reagent/polyjuice, /datum/reagent/toxin/gibbium, /datum/reagent/toxin/spider_serum, /datum/reagent/metalgen/gorgium))
		TEST_ASSERT(reagent_type in fun_reagents, "[reagent_type] nie wypada z maint pilli")

#undef TEST_ASSERT
