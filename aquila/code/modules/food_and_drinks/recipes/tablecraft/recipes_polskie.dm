// AQUILA - przepisy na polskie jedzenie (tgstation/tgstation#65848)

/datum/crafting_recipe/food/golabki
	name = "Gołąbki"
	reqs = list(
		/obj/item/food/meat/cutlet = 2,
		/obj/item/food/boiledrice = 1,
		/obj/item/food/grown/cabbage = 1,
		/obj/item/food/grown/tomato = 1,
	)
	result = /obj/item/food/golabki
	subcategory = CAT_MISCFOOD

/datum/crafting_recipe/food/zurek
	name = "Żurek"
	reqs = list(
		/datum/reagent/water = 10,
		/datum/reagent/consumable/flour = 5,
		/obj/item/food/boiledegg = 1,
		/obj/item/food/meat/cutlet = 1,
		/obj/item/food/grown/carrot = 1,
		/obj/item/food/grown/onion = 1,
		/obj/item/reagent_containers/glass/bowl = 1,
	)
	result = /obj/item/food/soup/zurek
	subcategory = CAT_SOUP

/datum/crafting_recipe/food/ptasie_mleczko
	name = "Ptasie mleczko"
	reqs = list(
		/obj/item/food/chocolatebar = 1,
		/datum/reagent/consumable/cream = 5,
		/datum/reagent/consumable/sugar = 5,
	)
	result = /obj/item/food/ptasie_mleczko
	subcategory = CAT_MISCFOOD
