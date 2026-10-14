/datum/test_chamber_kit/pr_433
	name = "Secret chems"
	pr = "aq33/AquilaStation#433"
	description = "Kartki: przeczytaj skamieniałą (gorgium), uranową (metalgen) i zwykłą starą recepturę. \
	Gotowe składniki aktualnych receptur są w zlewce gorgium, zlewce metalgenu i wiadrze sosu, schłodzone/podgrzane tuż obok progu: włóż je do podgrzewacza i ustaw temperaturę z kartki. \
	Metalgen: wlej do zlewki z 40u złota i ciemną materią, potem polej nim przedmiot lub podłogę (zmiana koloru i nazwy). \
	Gorgium ze spryskiwacza na królika (3u+ = posąg 5 s/u). Pigułki gibbium (GBS, leczy synaptizine + siarka), polyjuice (przemiana po 10 cyklach), spider serum (pajączki, pająk po 30 cyklach) daj królikom lub zjedz. \
	Butelka maint pilli losuje z nowej puli."
	items = list(
		/obj/item/paper/secretrecipe/gorgium = 1,
		/obj/item/paper/secretrecipe/metalgen = 1,
		/obj/machinery/chem_heater = 1,
		/obj/item/storage/pill_bottle/floorpill/full = 1,
		/obj/item/toy/eightball = 2,
		/obj/item/reagent_containers/syringe = 3,
	)

/datum/test_chamber_kit/pr_433/setup(list/spawned, list/turfs, turf/center, mob/user)
	. = ..()
	var/turf/drop = turfs[min(length(items) + 1, length(turfs))]
	new /obj/item/paper/secretrecipe(drop) // tu, bo test komory liczy podtypy z items

	// Składniki aktualnych receptur, z temperaturą tuż poza progiem, żeby nie zareagowały od razu
	ingredients_for(/datum/chemical_reaction/randomized/gorgium, new /obj/item/reagent_containers/glass/beaker/bluespace(drop), "składniki gorgium")
	ingredients_for(/datum/chemical_reaction/randomized/metalgen, new /obj/item/reagent_containers/glass/beaker/bluespace(drop), "składniki metalgenu")
	ingredients_for(/datum/chemical_reaction/randomized/secret_sauce, new /obj/item/reagent_containers/glass/bucket(drop), "składniki sekretnego sosu")

	// Odcisk metalgenu: gotowy metalgen + złoto + ciemna materia osobno
	var/obj/item/reagent_containers/glass/beaker/large/gold = new(drop)
	gold.name = "zlewka ze złotem (odcisk metalgenu)"
	gold.reagents.add_reagent(/datum/reagent/gold, 40)
	reagent_bottle(drop, /datum/reagent/metalgen, 30, "metalgen bez materiału")
	reagent_bottle(drop, /datum/reagent/liquid_dark_matter, 5, "ciekła ciemna materia")
	reagent_bottle(drop, /datum/reagent/wittel, 30, "wittel")

	var/obj/item/reagent_containers/spray/gorgium_spray = new(drop)
	gorgium_spray.name = "spryskiwacz z gorgium"
	gorgium_spray.reagents.add_reagent(/datum/reagent/metalgen/gorgium, 100)

	for(var/reagent_type in list(/datum/reagent/toxin/gibbium, /datum/reagent/polyjuice, /datum/reagent/toxin/spider_serum))
		var/datum/reagent/reagent = reagent_type
		for(var/i in 1 to 2)
			var/obj/item/reagent_containers/pill/pill = new(drop)
			pill.name = "pigułka: [initial(reagent.name)]"
			pill.reagents.add_reagent(reagent_type, 20)
	reagent_bottle(drop, /datum/reagent/medicine/synaptizine, 30, "synaptizine (lek na GBS)")
	reagent_bottle(drop, /datum/reagent/sulfur, 30, "siarka (lek na GBS)")

/datum/test_chamber_kit/pr_433/proc/reagent_bottle(turf/drop, reagent_type, amount, label)
	var/obj/item/reagent_containers/glass/bottle/bottle = new(drop)
	bottle.name = "butelka: [label]"
	bottle.reagents.add_reagent(reagent_type, amount)

/datum/test_chamber_kit/pr_433/proc/ingredients_for(recipe_type, obj/item/reagent_containers/container, label)
	container.name = label
	var/datum/chemical_reaction/recipe = get_chemical_reaction(recipe_type)
	if(!recipe)
		return
	// Hot: tuż poniżej progu, cold: tuż powyżej
	var/start_temp = recipe.is_cold_recipe ? recipe.required_temp + 20 : max(recipe.required_temp - 20, 1)
	for(var/reagent_type in recipe.required_reagents)
		container.reagents.add_reagent(reagent_type, recipe.required_reagents[reagent_type], null, start_temp, TRUE)
	for(var/reagent_type in recipe.required_catalysts)
		container.reagents.add_reagent(reagent_type, recipe.required_catalysts[reagent_type], null, start_temp, TRUE)
