//this category is very little but I think that it has great potential to grow
////////////////////////////////////////////SALAD////////////////////////////////////////////
/obj/item/food/salad
	icon = 'icons/obj/food/soupsalad.dmi'
	trash_type = /obj/item/reagent_containers/glass/bowl
	bite_consumption = 3
	w_class = WEIGHT_CLASS_NORMAL
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 7,
		/datum/reagent/consumable/nutriment/vitamin = 2
	)
	tastes = list("liście" = 1)
	foodtypes = VEGETABLES
	eatverbs = list("pożera","skubie","obgryza","pochłania","chrupie") //who the fuck gnaws and devours on a salad
	crafting_complexity = FOOD_COMPLEXITY_2

/obj/item/food/salad/aesirsalad
	name = "\improper Aesir salad"
	desc = "Probably too incredible for mortal men to fully enjoy."
	icon_state = "aesirsalad"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 8,
		/datum/reagent/consumable/nutriment/vitamin = 12
	)
	tastes = list("liście" = 1)
	foodtypes = VEGETABLES | FRUIT
	crafting_complexity = FOOD_COMPLEXITY_3

/obj/item/food/salad/herbsalad
	name = "herb salad"
	desc = "A tasty salad with apples on top."
	icon_state = "herbsalad"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 8,
		/datum/reagent/consumable/nutriment/vitamin = 6
	)
	tastes = list("liście" = 1, "jabłko" = 1)
	foodtypes = VEGETABLES | FRUIT
	crafting_complexity = FOOD_COMPLEXITY_2

/obj/item/food/salad/validsalad
	name = "valid salad"
	desc = "It's just an herb salad with meatballs and fried potato slices. Nothing suspicious about it."
	icon_state = "validsalad"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 5,
		/datum/reagent/consumable/nutriment/protein = 5,
		/datum/reagent/consumable/doctor_delight = 8,
		/datum/reagent/consumable/nutriment/vitamin = 6
	)
	tastes = list("liście" = 1, "ziemniak" = 1, "mięso" = 1, "validy" = 1)
	foodtypes = VEGETABLES | MEAT | FRIED | FRUIT

/obj/item/food/salad/fruit
	name = "fruit salad"
	desc = "Your standard fruit salad."
	icon_state = "fruitsalad"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 9,
		/datum/reagent/consumable/nutriment/vitamin = 5
	)
	tastes = list("owoce" = 1)
	foodtypes = FRUIT
	crafting_complexity = FOOD_COMPLEXITY_3

/obj/item/food/salad/jungle
	name = "jungle salad"
	desc = "Exotic fruits in a bowl."
	icon_state = "junglesalad"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 11,
		/datum/reagent/consumable/banana = 5,
		/datum/reagent/consumable/nutriment/vitamin = 7
	)
	tastes = list("owoce" = 1, "dżungla" = 1)
	foodtypes = FRUIT
	crafting_complexity = FOOD_COMPLEXITY_3

/obj/item/food/salad/citrusdelight
	name = "citrus delight"
	desc = "Citrus overload!"
	icon_state = "citrusdelight"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 11,
		/datum/reagent/consumable/nutriment/vitamin = 7
	)
	tastes = list("kwaśność" = 1, "liście" = 1)
	foodtypes = FRUIT
	crafting_complexity = FOOD_COMPLEXITY_3

/obj/item/food/uncooked_rice
	name = "uncooked rice"
	desc = "A clump of raw rice."
	icon_state = "uncooked_rice"
	food_reagents = list(/datum/reagent/consumable/nutriment = 4)
	tastes = list("ryż" = 1)
	foodtypes = GRAIN | RAW
	microwaved_type = /obj/item/food/boiledrice

/*
/obj/item/food/salad/ricebowl/make_microwaveable()
	AddElement(/datum/element/microwavable, /obj/item/food/boiledrice)
*/

/obj/item/food/boiledrice
	name = "boiled rice"
	desc = "A steaming cup of boiled rice. A bit bland by itself, but the basis for something delicious..."
	icon_state = "cooked_rice"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 6,
		/datum/reagent/consumable/nutriment/vitamin = 2
	)
	tastes = list("ryż" = 1)
	foodtypes = GRAIN | BREAKFAST
	crafting_complexity = FOOD_COMPLEXITY_1

/obj/item/food/salad/ricepudding
	name = "rice pudding"
	desc = "Everybody loves rice pudding!"
	icon_state = "ricepudding"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 8,
		/datum/reagent/consumable/sugar = 3,
		/datum/reagent/consumable/nutriment/vitamin = 3
	)
	tastes = list("ryż" = 1, "słodycz" = 1)
	foodtypes = GRAIN | DAIRY | SUGAR

/obj/item/food/salad/ricepork
	name = "rice and pork"
	desc = "Well, it looks like pork..."
	icon_state = "riceporkbowl"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 6,
		/datum/reagent/consumable/nutriment/protein = 6,
		/datum/reagent/consumable/nutriment/vitamin = 3
	)
	tastes = list("ryż" = 1, "mięso" = 1)
	foodtypes = GRAIN | MEAT
	crafting_complexity = FOOD_COMPLEXITY_2

/obj/item/food/salad/eggbowl
	name = "egg bowl"
	desc = "A bowl of rice with a fried egg."
	icon_state = "eggbowl"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 8,
		/datum/reagent/consumable/nutriment/protein = 2,
		/datum/reagent/consumable/nutriment/vitamin = 4
	)
	tastes = list("ryż" = 1, "jajko" = 1)
	foodtypes = GRAIN | MEAT //EGG = MEAT -NinjaNomNom 2017
	crafting_complexity = FOOD_COMPLEXITY_4


/obj/item/reagent_containers/glass/bowl
	name = "bowl"
	desc = "A simple bowl, used for soups and salads."
	icon = 'icons/obj/food/soupsalad.dmi'
	icon_state = "bowl"
	reagent_flags = OPENCONTAINER
	custom_materials = list(/datum/material/glass = 500)
	w_class = WEIGHT_CLASS_NORMAL
	custom_price = PAYCHECK_EASY * 0.6

/obj/item/reagent_containers/glass/bowl/Initialize()
	. = ..()
	AddComponent(/datum/component/customizable_reagent_holder, /obj/item/food/salad/empty, CUSTOM_INGREDIENT_ICON_FILL, max_ingredients = 6)

// empty salad for custom salads
/obj/item/food/salad/empty
	name = "salad"
	foodtypes = NONE
	tastes = list()
	icon_state = "bowl"
	desc = "A delicious customized salad."
