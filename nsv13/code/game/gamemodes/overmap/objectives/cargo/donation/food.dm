/datum/overmap_objective/cargo/donation/food
	name = "Donate food"
	desc = "Donate food"
	crate_name = "Buffet crate"

/datum/overmap_objective/cargo/donation/food/New()
	// Must create a specific list of foods. Using parent types may turn up "snack" on communications console which is misleading, and using subtypes loops may turn up uncraftable foods
	// var/picked = get_random_food()
	var/picked = pick( list(
		/obj/item/food/bread/plain,
		/obj/item/food/bread/meat,
		/obj/item/food/bread/banana,
		/obj/item/food/bread/tofu,
		/obj/item/food/bread/creamcheese,
		/obj/item/food/cake/plain,
		/obj/item/food/cake/carrot,
		/obj/item/food/cake/cheese,
		/obj/item/food/cake/orange,
		/obj/item/food/cake/lemon,
		/obj/item/food/cake/lime,
		/obj/item/food/cake/chocolate,
		/obj/item/food/cake/holy_cake,
		/obj/item/food/cake/pound_cake,
		/obj/item/food/burger/plain,
		/obj/item/food/burger/bigbite,
		/obj/item/food/burger/superbite,
		/obj/item/reagent_containers/food/snacks/omelette,
		/obj/item/reagent_containers/food/snacks/benedict,
		/obj/item/reagent_containers/food/snacks/icecreamsandwich,
		/obj/item/reagent_containers/food/snacks/sundae,
		/obj/item/reagent_containers/food/snacks/carpmeat,
		/obj/item/food/enchiladas,
		/obj/item/reagent_containers/food/snacks/popcorn,
		/obj/item/food/burrito,
		/obj/item/food/cheesyburrito,
		/obj/item/food/carneburrito,
		/obj/item/food/nachos,
		/obj/item/food/cheesynachos,
		/obj/item/food/cubannachos,
		/obj/item/reagent_containers/food/snacks/waffles,
		/obj/item/reagent_containers/food/snacks/pie/cream,
		/obj/item/reagent_containers/food/snacks/pie/pumpkinpie,
		/obj/item/reagent_containers/food/snacks/pie/plain,
		/obj/item/reagent_containers/food/snacks/pie/applepie,
		/obj/item/food/pizza/meat,
		/obj/item/food/pizza/margherita,
		/obj/item/reagent_containers/food/snacks/salad/fruit,
		/obj/item/reagent_containers/food/snacks/salad/oatmeal,
		/obj/item/reagent_containers/food/snacks/deadmouse
	) )
	var/datum/freight_type/single/object/C = new( picked )
	C.target = rand( 3, 5 )
	freight_type_group = new( list( C ) )
