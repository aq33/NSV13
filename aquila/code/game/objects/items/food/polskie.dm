// AQUILA - polskie jedzenie: gołąbki i żurek z tg (tgstation/tgstation#65848), ptasie mleczko z CM-SS13

/obj/item/food/golabki
	name = "gołąbki"
	desc = "Mielone mięso z ryżem zawinięte w liście kapusty i polane sosem pomidorowym. Palce lizać."
	icon = 'aquila/icons/obj/food/polskie.dmi'
	icon_state = "stuffed_cabbage"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 10,
		/datum/reagent/consumable/nutriment/vitamin = 5,
	)
	tastes = list("soczyste mięso" = 1, "ryż" = 1, "kapusta" = 1)
	foodtypes = MEAT | VEGETABLES | GRAIN
	w_class = WEIGHT_CLASS_SMALL

/obj/item/food/soup/zurek
	name = "żurek"
	desc = "Tradycyjna polska zupa na zakwasie, z warzywami, kiełbasą i jajkiem. Najlepiej smakuje z chlebem."
	icon = 'aquila/icons/obj/food/polskie.dmi'
	icon_state = "zurek"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 8,
		/datum/reagent/consumable/nutriment/vitamin = 2,
		/datum/reagent/consumable/nutriment/protein = 2,
	)
	tastes = list("kremowe warzywa" = 2, "kiełbasa" = 1)
	foodtypes = VEGETABLES | MEAT | GRAIN | BREAKFAST

/obj/item/food/ptasie_mleczko
	name = "ptasie mleczko"
	desc = "Mięciutka pianka w czekoladzie. Popularny słodycz z Polski, idealny do herbaty."
	icon = 'aquila/icons/obj/food/polskie.dmi'
	icon_state = "ptasie_mleczko"
	food_reagents = list(
		/datum/reagent/consumable/sugar = 4,
		/datum/reagent/consumable/cream = 3,
		/datum/reagent/consumable/cocoa = 3,
	)
	tastes = list("czekolada" = 1, "słodka pianka" = 1)
	foodtypes = SUGAR | DAIRY | JUNKFOOD
	junkiness = 10
	w_class = WEIGHT_CLASS_SMALL
