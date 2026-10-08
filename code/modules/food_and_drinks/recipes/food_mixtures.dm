/datum/crafting_recipe/food
	var/real_parts
	category = CAT_FOOD

/datum/crafting_recipe/food/New()
	real_parts = parts.Copy()
	parts |= reqs

/datum/crafting_recipe/food/on_craft_completion(mob/user, atom/result)
	SHOULD_CALL_PARENT(TRUE)
	. = ..()
	if(istype(result) && !isnull(user.mind))
		ADD_TRAIT(result, TRAIT_FOOD_CHEF_MADE, REF(user.mind))

//////////////////////////////////////////FOOD MIXTURES////////////////////////////////////

/datum/chemical_reaction/food
	//reaction_tags = REACTION_TAG_FOOD | REACTION_TAG_EASY

/datum/chemical_reaction/food/tofu
	name = "Tofu"
	id = "tofu"
	required_reagents = list(/datum/reagent/consumable/soymilk = 10)
	required_catalysts = list(/datum/reagent/consumable/enzyme = 5)
	mob_react = FALSE

/datum/chemical_reaction/food/tofu/on_reaction(datum/reagents/holder, created_volume)
	var/location = get_turf(holder.my_atom)
	for(var/i = 1, i <= created_volume, i++)
		new /obj/item/food/tofu(location)

/datum/chemical_reaction/food/chocolate_bar
	name = "Chocolate Bar"
	id = "chocolate_bar"
	required_reagents = list(/datum/reagent/consumable/soymilk = 2, /datum/reagent/consumable/cocoa = 2, /datum/reagent/consumable/sugar = 2)

/datum/chemical_reaction/food/chocolate_bar/on_reaction(datum/reagents/holder, created_volume)
	var/location = get_turf(holder.my_atom)
	for(var/i in 1 to created_volume)
		new /obj/item/food/chocolatebar(location)

/datum/chemical_reaction/food/chocolate_bar2
	name = "Chocolate Bar"
	id = "chocolate_bar"
	required_reagents = list(/datum/reagent/consumable/milk/chocolate_milk = 4, /datum/reagent/consumable/sugar = 2)
	mob_react = FALSE

/datum/chemical_reaction/food/chocolate_bar2/on_reaction(datum/reagents/holder, created_volume)
	var/location = get_turf(holder.my_atom)
	for(var/i in 1 to created_volume)
		new /obj/item/food/chocolatebar(location)

/datum/chemical_reaction/food/hot_cocoa
	name = "Hot Cocoa"
	id = /datum/reagent/consumable/cocoa/hot_cocoa
	results = list(/datum/reagent/consumable/cocoa/hot_cocoa = 5)
	required_reagents = list(/datum/reagent/water = 5, /datum/reagent/consumable/cocoa = 1)

/datum/chemical_reaction/food/coffee
	name = "Coffee"
	id = /datum/reagent/consumable/coffee
	results = list(/datum/reagent/consumable/coffee = 5)
	required_reagents = list(/datum/reagent/toxin/coffeepowder = 1, /datum/reagent/water = 5)

/datum/chemical_reaction/food/tea
	name = "Tea"
	id = /datum/reagent/consumable/tea
	results = list(/datum/reagent/consumable/tea = 5)
	required_reagents = list(/datum/reagent/toxin/teapowder = 1, /datum/reagent/water = 5)

/datum/chemical_reaction/food/soysauce
	name = "Soy Sauce"
	id = /datum/reagent/consumable/soysauce
	results = list(/datum/reagent/consumable/soysauce = 5)
	required_reagents = list(/datum/reagent/consumable/soymilk = 4, /datum/reagent/toxin/acid = 1)

/datum/chemical_reaction/food/corn_syrup
	name = /datum/reagent/consumable/corn_syrup
	id = /datum/reagent/consumable/corn_syrup
	results = list(/datum/reagent/consumable/corn_syrup = 5)
	required_reagents = list(/datum/reagent/consumable/corn_starch = 1, /datum/reagent/toxin/acid = 1)
	required_temp = 374

/datum/chemical_reaction/food/caramel
	name = "Caramel"
	id = /datum/reagent/consumable/caramel
	results = list(/datum/reagent/consumable/caramel = 1)
	required_reagents = list(/datum/reagent/consumable/sugar = 1)
	required_temp = 413.15
	mob_react = FALSE

/datum/chemical_reaction/food/caramel_burned
	name = "Caramel burned"
	id = "caramel_burned"
	results = list(/datum/reagent/carbon = 1)
	required_reagents = list(/datum/reagent/consumable/caramel = 1)
	required_temp = 483.15
	mob_react = FALSE

/datum/chemical_reaction/food/synthmeat
	name = "synthmeat"
	id = "synthmeat"
	required_reagents = list(/datum/reagent/blood = 5, /datum/reagent/medicine/cryoxadone = 1)
	mob_react = FALSE

/datum/chemical_reaction/food/synthmeat/on_reaction(datum/reagents/holder, created_volume)
	var/location = get_turf(holder.my_atom)
	for(var/i = 1, i <= created_volume, i++)
		new /obj/item/food/meat/slab/synthmeat(location)

/datum/chemical_reaction/food/hot_ramen
	name = "Hot Ramen"
	id = /datum/reagent/consumable/hot_ramen
	results = list(/datum/reagent/consumable/hot_ramen = 3)
	required_reagents = list(/datum/reagent/water = 1, /datum/reagent/consumable/dry_ramen = 3)

/datum/chemical_reaction/food/hell_ramen
	name = "Hell Ramen"
	id = /datum/reagent/consumable/hell_ramen
	results = list(/datum/reagent/consumable/hell_ramen = 6)
	required_reagents = list(/datum/reagent/consumable/capsaicin = 1, /datum/reagent/consumable/hot_ramen = 6)

/datum/chemical_reaction/food/imitationcarpmeat
	name = "Imitation Carpmeat"
	id = "imitationcarpmeat"
	required_reagents = list(/datum/reagent/toxin/carpotoxin = 5)
	required_container = /obj/item/food/tofu
	mix_message = "The mixture becomes similar to carp meat."

/datum/chemical_reaction/food/imitationcarpmeat/on_reaction(datum/reagents/holder)
	var/location = get_turf(holder.my_atom)
	new /obj/item/food/fishmeat/carp/imitation(location)
	if(holder?.my_atom)
		qdel(holder.my_atom)

/datum/chemical_reaction/food/dough
	name = "Dough"
	id = "dough"
	required_reagents = list(/datum/reagent/water = 10, /datum/reagent/consumable/flour = 15)
	mix_message = "The ingredients form a dough."

/datum/chemical_reaction/food/dough/on_reaction(datum/reagents/holder, created_volume)
	var/location = get_turf(holder.my_atom)
	for(var/i in 1 to created_volume)
		new /obj/item/food/dough(location)

/datum/chemical_reaction/food/cakebatter
	name = "Cake Batter"
	id = "cakebatter"
	required_reagents = list(/datum/reagent/consumable/eggyolk = 15, /datum/reagent/consumable/flour = 15, /datum/reagent/consumable/sugar = 5)
	mix_message = "The ingredients form a cake batter."

/datum/chemical_reaction/food/cakebatter/on_reaction(datum/reagents/holder, created_volume)
	var/location = get_turf(holder.my_atom)
	for(var/i in 1 to created_volume)
		new /obj/item/food/cakebatter(location)

/datum/chemical_reaction/food/cakebatter/vegan
	id = "vegancakebatter"
	required_reagents = list(/datum/reagent/consumable/soymilk = 15, /datum/reagent/consumable/flour = 15, /datum/reagent/consumable/sugar = 5)

//pancake batter goes here
/*
/datum/chemical_reaction/food/pancakebatter
*/

/datum/chemical_reaction/food/uncooked_rice
	name = "Uncooked Rice"
	id = "uncookedrice"
	required_reagents = list(/datum/reagent/consumable/rice = 10, /datum/reagent/water = 10)
	mix_message = "The rice absorbs the water."

/datum/chemical_reaction/food/uncooked_rice/on_reaction(datum/reagents/holder, created_volume)
	var/location = get_turf(holder.my_atom)
	for(var/i in 1 to created_volume)
		new /obj/item/food/uncooked_rice(location)

/datum/chemical_reaction/food/bbqsauce
	name = "BBQ Sauce"
	id = /datum/reagent/consumable/bbqsauce
	results = list(/datum/reagent/consumable/bbqsauce = 5)
	required_reagents = list(/datum/reagent/ash = 1, /datum/reagent/consumable/tomatojuice = 1, /datum/reagent/medicine/salglu_solution = 3, /datum/reagent/consumable/blackpepper = 1)

////////////////////////////////////////////CHEESEMILK////////////////////////////////////////////
/datum/chemical_reaction/food/bluemilk
	name = "Blue Cheese Milk"
	id = "bluemilk"
	required_reagents = list(/datum/reagent/consumable/milk = 30, /datum/reagent/consumable/penicilliumroqueforti = 1)
	results = list(/datum/reagent/consumable/milk/blue = 30)

/datum/chemical_reaction/food/briemilk
	name = "Brie Cheese Milk"
	id = "briemilk"
	required_reagents = list(/datum/reagent/consumable/milk = 30, /datum/reagent/consumable/penicilliumcandidum = 1)
	results = list(/datum/reagent/consumable/milk/brie = 30)

/datum/chemical_reaction/food/cheddarmilk
	name = "Cheddar Cheese Milk"
	id = "cheddarmilk"
	required_reagents = list(/datum/reagent/consumable/milk = 30, /datum/reagent/consumable/mesophilicculture = 1)
	results = list(/datum/reagent/consumable/milk/cheddar = 30)

/datum/chemical_reaction/food/fetamilk
	name = "Feta Cheese Milk"
	id = "fetamilk"
	required_reagents = list(/datum/reagent/consumable/milk/sheep = 30, /datum/reagent/consumable/mesophilicculture = 1)
	results = list(/datum/reagent/consumable/milk/feta = 30)

/datum/chemical_reaction/food/goatmilk
	name = "Goat Cheese Milk"
	id = "goatmilk"
	required_reagents = list(/datum/reagent/consumable/milk/goat = 30, /datum/reagent/consumable/mesophilicculture = 1)
	results = list(/datum/reagent/consumable/milk/goatcheese = 30)

/datum/chemical_reaction/food/shoatmilk
	name = "Shoat Milk"
	id = "shoatmilk"
	required_reagents = list(/datum/reagent/consumable/milk/goat = 15, /datum/reagent/consumable/milk/sheep = 15)
	results = list(/datum/reagent/consumable/milk/shoat = 30)

/datum/chemical_reaction/food/halloumimilk
	name = "Halloumi Cheese Milk"
	id = "halloumimilk"
	required_reagents = list(/datum/reagent/consumable/milk/shoat = 30, /datum/reagent/consumable/mesophilicculture = 1)
	results = list(/datum/reagent/consumable/milk/halloumi = 30)

/datum/chemical_reaction/food/mozzarellamilk
	name = "Mozzarella Cheese Milk"
	id = "mozzarellamilk"
	required_reagents = list(/datum/reagent/consumable/milk = 30, /datum/reagent/consumable/lemonjuice = 5)
	results = list(/datum/reagent/consumable/milk/mozzarella = 30)

/datum/chemical_reaction/food/parmesanmilk
	name = "Parmesan Cheese Milk"
	id = "parmesanmilk"
	required_reagents = list(/datum/reagent/consumable/milk = 30, /datum/reagent/consumable/sodiumchloride = 10)
	results = list(/datum/reagent/consumable/milk/parmesan = 30)

/datum/chemical_reaction/food/swissmilk
	name = "Swiss Cheese Milk"
	id = "swissmix"
	required_reagents = list(/datum/reagent/consumable/milk = 30, /datum/reagent/consumable/thermophilicculture = 1)
	results = list(/datum/reagent/consumable/milk/swiss = 30)

////////////////////////////////////////////CHEESE////////////////////////////////////////////
/datum/chemical_reaction/food/american
	name = "American Cheese Block"
	id = "americancheeseblock"
	required_reagents = list(/datum/reagent/consumable/milk = 40)
	required_catalysts = list(/datum/reagent/consumable/enzyme = 5)

/datum/chemical_reaction/food/american/on_reaction(datum/reagents/holder, created_volume)
	var/location = get_turf(holder.my_atom)
	for(var/i = 1, i <= created_volume, i++)
		new /obj/item/food/cheese/wheel/american(location)

/datum/chemical_reaction/food/bluemix
	name = "Blue Cheese Mix"
	id = "bluemix"
	required_reagents = list(/datum/reagent/consumable/milk/blue = 30)
	required_catalysts = list(/datum/reagent/consumable/enzyme = 5)

/datum/chemical_reaction/food/bluemix/on_reaction(datum/reagents/holder, created_volume)
	var/location = get_turf(holder.my_atom)
	for(var/i = 1, i <= created_volume, i++)
		new /obj/item/food/cheesemix/blue(location)

/datum/chemical_reaction/food/briemix
	name = "Brie Cheese Mix"
	id = "briemix"
	required_reagents = list(/datum/reagent/consumable/milk/brie = 30)
	required_catalysts = list(/datum/reagent/consumable/enzyme = 5)

/datum/chemical_reaction/food/briemix/on_reaction(datum/reagents/holder, created_volume)
	var/location = get_turf(holder.my_atom)
	for(var/i = 1, i <= created_volume, i++)
		new /obj/item/food/cheesemix/brie(location)

/datum/chemical_reaction/food/cheddarmix
	name = "Cheddar Cheese Mix"
	id = "cheddarmix"
	required_reagents = list(/datum/reagent/consumable/milk/cheddar = 30)
	required_catalysts = list(/datum/reagent/consumable/enzyme = 5)

/datum/chemical_reaction/food/cheddarmix/on_reaction(datum/reagents/holder, created_volume)
	var/location = get_turf(holder.my_atom)
	for(var/i = 1, i <= created_volume, i++)
		new /obj/item/food/cheesemix/cheddar(location)

/datum/chemical_reaction/food/fetamix
	name = "Feta Cheese Mix"
	id = "fetamix"
	required_reagents = list(/datum/reagent/consumable/milk/feta = 30)
	required_catalysts = list(/datum/reagent/consumable/enzyme = 5)

/datum/chemical_reaction/food/fetamix/on_reaction(datum/reagents/holder, created_volume)
	var/location = get_turf(holder.my_atom)
	for(var/i = 1, i <= created_volume, i++)
		new /obj/item/food/cheesemix/feta(location)

/datum/chemical_reaction/food/goatmix
	name = "Goat Cheese Mix"
	id = "goatmix"
	required_reagents = list(/datum/reagent/consumable/milk/goatcheese = 30)
	required_catalysts = list(/datum/reagent/consumable/enzyme = 5)

/datum/chemical_reaction/food/goatmix/on_reaction(datum/reagents/holder, created_volume)
	var/location = get_turf(holder.my_atom)
	for(var/i = 1, i <= created_volume, i++)
		new /obj/item/food/cheesemix/goat(location)

/datum/chemical_reaction/food/halloumimix
	name = "Halloumi Cheese Mix"
	id = "halloumimix"
	required_reagents = list(/datum/reagent/consumable/milk/halloumi = 30)
	required_catalysts = list(/datum/reagent/consumable/enzyme = 5)

/datum/chemical_reaction/food/halloumimix/on_reaction(datum/reagents/holder, created_volume)
	var/location = get_turf(holder.my_atom)
	for(var/i = 1, i <= created_volume, i++)
		new /obj/item/food/cheesemix/halloumi(location)

/datum/chemical_reaction/food/mozzarellamix
	name = "Mozzarella Cheese Mix"
	id = "mozzarellamix"
	required_reagents = list(/datum/reagent/consumable/milk/mozzarella = 30)
	required_catalysts = list(/datum/reagent/consumable/enzyme = 5)

/datum/chemical_reaction/food/mozzarellamix/on_reaction(datum/reagents/holder, created_volume)
	var/location = get_turf(holder.my_atom)
	for(var/i = 1, i <= created_volume, i++)
		new /obj/item/food/cheesemix/mozzarella(location)

/datum/chemical_reaction/food/parmesanmix
	name = "Parmesan Cheese Mix"
	id = "parmesanmix"
	required_reagents = list(/datum/reagent/consumable/milk/parmesan = 30)
	required_catalysts = list(/datum/reagent/consumable/enzyme = 5)

/datum/chemical_reaction/food/parmesanmix/on_reaction(datum/reagents/holder, created_volume)
	var/location = get_turf(holder.my_atom)
	for(var/i = 1, i <= created_volume, i++)
		new /obj/item/food/cheesemix/parmesan(location)

/datum/chemical_reaction/food/swissmix
	name = "Swiss Cheese Mix"
	id = "swissmix"
	required_reagents = list(/datum/reagent/consumable/milk/swiss = 30)
	required_catalysts = list(/datum/reagent/consumable/enzyme = 5)

/datum/chemical_reaction/food/swissmix/on_reaction(datum/reagents/holder, created_volume)
	var/location = get_turf(holder.my_atom)
	for(var/i = 1, i <= created_volume, i++)
		new /obj/item/food/cheesemix/swiss(location)
