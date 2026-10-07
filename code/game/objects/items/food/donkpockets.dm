////////////////////////////////////////////DONK POCKETS////////////////////////////////////////////

/obj/item/food/donkpocket/random //AQUILA EDIT BEGIN - polskie nazwy pierogów
	name = "\improper losowy pierożek"
	icon_state = "donkpocket"
	desc = "jedzenie wyboru dla zatwardziałego kodera(jeżeli to widzisz, skontaktuj się z DonkCo. jak najszybciej)."
	food_reagents = list(/datum/reagent/consumable/nutriment = 3)// immediately gets overwritten. This exists to not set off the edibility unit test.

/obj/item/food/donkpocket/random/Initialize()
	var/list/donkblock = list(
	/obj/item/food/donkpocket/warm,
	/obj/item/food/donkpocket/warm/spicy,
	/obj/item/food/donkpocket/warm/teriyaki,
	/obj/item/food/donkpocket/warm/pizza,
	/obj/item/food/donkpocket/warm/honk,
	/obj/item/food/donkpocket/warm/berry,
	/obj/item/food/donkpocket/gondola,
	/obj/item/food/donkpocket/warm/gondola,
	)

	var donk_type = pick(subtypesof(/obj/item/food/donkpocket) - donkblock)
	new donk_type(loc)
	return INITIALIZE_HINT_QDEL

/obj/item/food/donkpocket
	name = "\improper pieróg"
	desc = "jedzenie wyboru dla zatwardziałego dwuetatowca."
	icon_state = "donkpocket"
	icon = 'aquila/icons/obj/food/food.dmi'
	microwaved_type = /obj/item/food/donkpocket/warm
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 3,
		/datum/reagent/consumable/nutriment/protein = 2, //uhhh lorewise microwaving donkpockets makes the proteins into omnizine or somethin idk
		/datum/reagent/consumable/maltodextrin = 3
	)
	tastes = list("meat" = 2, "dough" = 2, "laziness" = 1)
	foodtypes = GRAIN
	food_flags = FOOD_FINGER_FOOD
	w_class = WEIGHT_CLASS_SMALL

	/// What type of donk pocket we're warmed into via baking or microwaving.
	//var/warm_type = /obj/item/food/donkpocket/warm
	/// The lower end for how long it takes to bake
	var/baking_time_short = 25 SECONDS
	/// The upper end for how long it takes to bake
	var/baking_time_long = 30 SECONDS

/*
/obj/item/food/donkpocket/make_microwaveable()
	AddElement(/datum/element/microwavable, warm_type)
*/

/obj/item/food/donkpocket/warm
	name = "odgrzany pieróg"
	desc = "jedzenie wyboru dla zatwardziałego dwuetatowca."
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 3,
		/datum/reagent/consumable/nutriment/protein = 2,
		/datum/reagent/medicine/omnizine = 6,
		/datum/reagent/consumable/maltodextrin = 3
	)
	tastes = list("meat" = 2, "dough" = 2, "laziness" = 1)
	foodtypes = GRAIN

	// Warmed donk pockets will burn if you leave them in the oven or microwave.
	//warm_type = /obj/item/reagent_containers/food/snacks/badrecipe
	microwaved_type = /obj/item/reagent_containers/food/snacks/badrecipe
	baking_time_short = 10 SECONDS
	baking_time_long = 15 SECONDS

/obj/item/food/dankpocket
	name = "\improper spizgany pierożek"
	desc = "bratku daj bucha, ale ta zerówka jest mocna."
	icon_state = "dankpocket"
	icon = 'aquila/icons/obj/food/food.dmi'
	food_reagents = list(
		/datum/reagent/toxin/lipolicide = 3,
		/datum/reagent/drug/space_drugs = 3,
		/datum/reagent/consumable/nutriment = 4,
		/datum/reagent/consumable/maltodextrin = 4
	)
	tastes = list("meat" = 2, "dough" = 2)
	foodtypes = GRAIN | VEGETABLES

/obj/item/food/donkpocket/spicy
	name = "\improper ostry pierożek"
	desc = "klasyczna przekąska, teraz z cieplejszym i pikantnym stylem."
	icon_state = "donkpocketspicy"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 3,
		/datum/reagent/consumable/nutriment/protein = 2,
		/datum/reagent/consumable/capsaicin = 2,
		/datum/reagent/consumable/maltodextrin = 3
	)
	tastes = list("meat" = 2, "dough" = 2, "spice" = 1)
	foodtypes = GRAIN

	//warm_type = /obj/item/food/donkpocket/warm/spicy
	microwaved_type = /obj/item/food/donkpocket/warm/spicy

/obj/item/food/donkpocket/warm/spicy
	name = "ciepły ostry pierożek"
	desc = "klasyczna przekąska, może teraz zbyt pikantna."
	icon_state = "donkpocketspicy"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 3,
		/datum/reagent/consumable/nutriment/protein = 2,
		/datum/reagent/medicine/omnizine = 2,
		/datum/reagent/consumable/capsaicin = 5,
		/datum/reagent/consumable/maltodextrin = 3
	)
	tastes = list("meat" = 2, "dough" = 2, "weird spices" = 2)
	foodtypes = GRAIN

/obj/item/food/donkpocket/teriyaki
	name = "\improper azjatycki pierożek"
	desc = "wschodnioazjatyckie podejście na klasyczną przekąskę."
	icon_state = "donkpocketteriyaki"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 3,
		/datum/reagent/consumable/nutriment/protein = 2,
		/datum/reagent/consumable/soysauce = 2,
		/datum/reagent/consumable/maltodextrin = 3
	)
	tastes = list("meat" = 2, "dough" = 2, "soy sauce" = 2)
	foodtypes = GRAIN

	//warm_type = /obj/item/food/donkpocket/warm/teriyaki
	microwaved_type = /obj/item/food/donkpocket/warm/teriyaki

/obj/item/food/donkpocket/warm/teriyaki
	name = "ciepły azjatycki pierożek"
	desc = "wschodnioazjatyckie podejście na klasyczną przekąskę, teraz ciepłe i parujące."
	icon_state = "donkpocketteriyaki"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 3,
		/datum/reagent/consumable/nutriment/protein = 3,
		/datum/reagent/medicine/omnizine = 2,
		/datum/reagent/consumable/soysauce = 2,
		/datum/reagent/consumable/maltodextrin = 3
	)
	tastes = list("meat" = 2, "dough" = 2, "soy sauce" = 2)
	foodtypes = GRAIN

/obj/item/food/donkpocket/pizza
	name = "\improper pizza-pieróg"
	desc = "pyszny, serowy i zdumiewająco sycące."
	icon_state = "donkpocketpizza"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 3,
		/datum/reagent/consumable/nutriment/protein = 2,
		/datum/reagent/consumable/tomatojuice = 2,
		/datum/reagent/consumable/maltodextrin = 3
	)
	tastes = list("meat" = 2, "dough" = 2, "cheese"= 2)
	foodtypes = GRAIN

	//warm_type = /obj/item/food/donkpocket/warm/pizza
	microwaved_type = /obj/item/food/donkpocket/warm/pizza

/obj/item/food/donkpocket/warm/pizza
	name = "ciepły pizza-pieróg"
	desc = "pyszny, serowy i jeszcze lepszy bo ciepły."
	icon_state = "donkpocketpizza"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 3,
		/datum/reagent/consumable/nutriment/protein = 2,
		/datum/reagent/medicine/omnizine = 2,
		/datum/reagent/consumable/tomatojuice = 2,
		/datum/reagent/consumable/maltodextrin = 3
	)
	tastes = list("meat" = 2, "dough" = 2, "melty cheese"= 2)
	foodtypes = GRAIN

/obj/item/food/donkpocket/honk
	name = "\improper bananowy pierożek"
	desc = "wielokrotnie nagradzane pierogi które podbiły serca klaunów oraz ludzi."
	icon_state = "donkpocketbanana"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 4,
		/datum/reagent/consumable/banana = 4,
		/datum/reagent/consumable/maltodextrin = 4
	)
	tastes = list("banana" = 2, "dough" = 2, "children's antibiotics" = 1)
	foodtypes = GRAIN

	//warm_type = /obj/item/food/donkpocket/warm/honk
	microwaved_type = /obj/item/food/donkpocket/warm/honk

/obj/item/food/donkpocket/warm/honk
	name = "ciepły bananowy pierożek"
	desc = "wielokrotnie nagradzane pierogi które podbiły serca klaunów oraz ludzi, teraz ciepły."
	icon_state = "donkpocketbanana"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 4,
		/datum/reagent/medicine/omnizine = 2,
		/datum/reagent/consumable/banana = 4,
		/datum/reagent/consumable/laughter = 6,
		/datum/reagent/consumable/maltodextrin = 4
	)
	tastes = list("banana" = 2, "dough" = 2, "children's antibiotics" = 1)
	foodtypes = GRAIN

/obj/item/food/donkpocket/berry
	name = "\improper jagodowy pierożek"
	desc = "nieubłaganie słodkie pierogi."
	icon_state = "donkpocketberry"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 4,
		/datum/reagent/consumable/berryjuice = 3,
		/datum/reagent/consumable/maltodextrin = 4
	)
	tastes = list("dough" = 2, "jam" = 2)
	foodtypes = GRAIN

	//warm_type = /obj/item/food/donkpocket/warm/berry
	microwaved_type = /obj/item/food/donkpocket/warm/berry

/obj/item/food/donkpocket/warm/berry
	name = "ciepły jagodowy pierożek"
	desc = "nieubłaganie słodkie pierogi, teraz ciepłe i smaczne."
	icon_state = "donkpocketberry"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 4,
		/datum/reagent/medicine/omnizine = 2,
		/datum/reagent/consumable/berryjuice = 3,
		/datum/reagent/consumable/maltodextrin = 4
	)
	tastes = list("dough" = 2, "warm jam" = 2)
	foodtypes = GRAIN

/obj/item/food/donkpocket/gondola
	name = "\improper pierożek finlandzki"
	desc = "decyzja o wykorzystaniu w przepisie prawdziwego mięsa gondol, jest co najmniej kontrowersyjna" //Only a monster would craft this.
	icon_state = "donkpocketgondola"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 3,
		/datum/reagent/consumable/nutriment/protein = 2,
		/datum/reagent/tranquility = 5,
		/datum/reagent/consumable/maltodextrin = 3
	)
	tastes = list("meat" = 2, "dough" = 2, "inner peace" = 1)
	foodtypes = GRAIN

	//warm_type = /obj/item/food/donkpocket/warm/gondola
	microwaved_type = /obj/item/food/donkpocket/warm/gondola

/obj/item/food/donkpocket/warm/gondola //AQUILA EDIT END
	name = "ciepły pierożek finlandzki"
	desc = "decyzja o wykorzystaniu w przepisie prawdziwego mięsa gondol, jest co najmniej kontrowersyjna."
	icon_state = "donkpocketgondola"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 3,
		/datum/reagent/consumable/nutriment/protein = 2,
		/datum/reagent/medicine/omnizine = 2,
		/datum/reagent/tranquility = 10,
		/datum/reagent/consumable/maltodextrin = 3
	)
	tastes = list("meat" = 2, "dough" = 2, "inner peace" = 1)
	foodtypes = GRAIN
