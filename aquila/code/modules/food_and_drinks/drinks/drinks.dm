
/obj/item/reagent_containers/food/drinks/dry_ramen
	name = "zupa romana"
	desc = "Wystarczy, że dodasz 5ml wody."

// ikony do amareny dodałem do drinks.dmi w icons/... bo
// była to droga najmniejszego oponu
/obj/item/reagent_containers/food/drinks/bottle/amarena
	name = "Amarena"
	desc = "Szery szery lejcie, amarenę wlejcie."
	icon_state = "amarenabottle"
	volume = 70
	list_reagents = list(/datum/reagent/consumable/ethanol/amarena = 70)

/obj/item/reagent_containers/food/drinks/soda_cans/mocnyfull
	name = "mocny full"
	desc = "Najlepsze w całym kosmosie."
	icon = 'aquila/icons/obj/drinks.dmi'
	icon_state = "mocnyfull"
	lefthand_file = 'icons/mob/inhands/equipment/kitchen_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/kitchen_righthand.dmi'
	list_reagents = list(/datum/reagent/consumable/ethanol/beer = 30)
	foodtype = GRAIN | ALCOHOL

/obj/item/reagent_containers/food/drinks/bottle/tymbark
	name = "Tymbark jabłko - mięta"
	desc = "Smak wakacji."
	custom_price = 10
	icon = 'aquila/icons/obj/drinks.dmi'
	icon_state = "tymkapsel"
	lefthand_file = 'icons/mob/inhands/equipment/kitchen_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/kitchen_righthand.dmi'
	isGlass = TRUE
	list_reagents = list(/datum/reagent/consumable/applejuice = 50)
	foodtype = FRUIT | SUGAR

/obj/item/reagent_containers/food/drinks/soda_cans/helenka
	name = "Helena jabłko - truskawka"
	desc = "Smak działki."
	custom_price = 20
	icon = 'aquila/icons/obj/drinks.dmi'
	icon_state = "helenka"
	lefthand_file = 'icons/mob/inhands/equipment/kitchen_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/kitchen_righthand.dmi'
	list_reagents = list(/datum/reagent/consumable/applejuice = 100)
	foodtype = FRUIT | SUGAR
