/datum/test_chamber_kit/pr_435
	name = "Restauracja z robotami"
	pr = "aq33/AquilaStation#435"
	description = "Weź kartę kuchni i baru. Na terminalu restauracji kliknij Otwórz lokal: pierwszy robot przychodzi po kilku sekundach, kolejne co 80-100 s (bar co 40-60 s). \
		Miejsca przy stolikach i stołkach są już rozstawione; sprawdź też Zdejmij wolne, Rozstaw miejsca i Wydaj projektor. \
		Robot siada, obraca się do stołu i zamawia (dymek nad głową, terminal mówi zamówienie). Podaj danie do ręki albo połóż na stole przed nim: ma zostawić holochip i zniknąć w portalu. \
		Złe danie ma odrzucić. W skrzyniach są gotowe dania i napoje (napój w szklance, min. 10u). Uderz robota w trybie walki (pięścią, bronią, strzałem albo rzutem; karta nie chroni): dwa ostrzeżenia, za trzecim miażdży napastnika uściskiem. Z kartą możesz go ciągnąć bez ostrzeżeń, bez karty ciągnięcie też jest ostrzeżeniem. \
		Ćma przychodzi tylko, gdy otwierający ma czapkę, rękawice albo buty (w skrzyni jest czapka kucharza)."
	items = list(
		/obj/machinery/restaurant_portal/restaurant = 1,
		/obj/machinery/restaurant_portal/bar = 1,
		/obj/machinery/restaurant_terminal/restaurant = 1,
		/obj/machinery/restaurant_terminal/bar = 1,
	)

/datum/test_chamber_kit/pr_435/spawn_kit(list/turfs, turf/center, mob/user)
	// Portale i terminale stawiamy sami, z daleka od sali, żeby nie zajęły pól pod stoliki
	var/list/spawned = list()
	spawned += new /obj/machinery/restaurant_portal/restaurant(free_turf(center, -6, 4, turfs))
	spawned += new /obj/machinery/restaurant_portal/bar(free_turf(center, -6, -4, turfs))
	spawned += new /obj/machinery/restaurant_terminal/restaurant(free_turf(center, -7, 2, turfs))
	spawned += new /obj/machinery/restaurant_terminal/bar(free_turf(center, -7, -2, turfs))
	setup(spawned, turfs, center, user)

/datum/test_chamber_kit/pr_435/setup(list/spawned, list/turfs, turf/center, mob/user)
	// Restauracja: dwa rzędy po trzy stoliki, krzesła zwrócone do stołów
	for(var/dx in 0 to 2)
		new /obj/structure/table(free_turf(center, dx, 3, turfs))
		dining_seat(/obj/structure/chair, NORTH, /obj/structure/holosign/robot_seat/restaurant, free_turf(center, dx, 2, turfs))
		new /obj/structure/table(free_turf(center, dx, -1, turfs))
		dining_seat(/obj/structure/chair, SOUTH, /obj/structure/holosign/robot_seat/restaurant, free_turf(center, dx, 0, turfs))

	// Bar: lada ze stołkami
	for(var/dx in 0 to 2)
		new /obj/structure/table/wood(free_turf(center, dx, -5, turfs))
		dining_seat(/obj/structure/chair/stool/bar, SOUTH, /obj/structure/holosign/robot_seat/bar, free_turf(center, dx, -4, turfs))

	var/turf/supply = free_turf(center, -3, 0, turfs)
	var/obj/item/card/id/card = new(supply)
	card.name = "karta kuchni i baru"
	card.access = list(ACCESS_KITCHEN, ACCESS_BAR)
	new /obj/item/clothing/head/chefhat(supply)

	var/obj/structure/closet/crate/food_crate = new(free_turf(center, -3, 1, turfs))
	food_crate.name = "gotowe dania"
	for(var/food_type in list(
		/obj/item/food/burger/plain, /obj/item/food/burger/plain, /obj/item/food/burger/cheese, /obj/item/food/fries,
		/obj/item/food/hotdog, /obj/item/food/taco/plain, /obj/item/food/taco/plain, /obj/item/food/burrito,
		/obj/item/food/spaghetti/pastatomato, /obj/item/food/baguette, /obj/item/food/omelette, /obj/item/food/soup/miso,
		/obj/item/food/tofu, /obj/item/food/fishandchips, /obj/item/food/soup/stew, /obj/item/food/golabki,
		/obj/item/food/soup/zurek, /obj/item/food/icecream, /obj/item/food/sausage,
	))
		new food_type(food_crate)

	var/obj/structure/closet/crate/drink_crate = new(free_turf(center, -3, -1, turfs))
	drink_crate.name = "gotowe napoje"
	for(var/reagent_type in list(
		/datum/reagent/consumable/ethanol/beer, /datum/reagent/consumable/ethanol/beer, /datum/reagent/consumable/ethanol/beer,
		/datum/reagent/consumable/ethanol/vodka, /datum/reagent/consumable/ethanol/tequila, /datum/reagent/consumable/ethanol/sake,
		/datum/reagent/consumable/ethanol/wine, /datum/reagent/consumable/ethanol/champagne, /datum/reagent/consumable/ethanol/ale,
		/datum/reagent/consumable/tea, /datum/reagent/consumable/lemonade,
	))
		var/obj/item/reagent_containers/food/drinks/drinkingglass/glass = new(drink_crate)
		glass.reagents.add_reagent(reagent_type, 20)
	// Rozwodnione piwo, którego bar nie powinien przyjąć
	var/obj/item/reagent_containers/food/drinks/drinkingglass/watered = new(drink_crate)
	watered.reagents.add_reagent(/datum/reagent/consumable/ethanol/beer, 10)
	watered.reagents.add_reagent(/datum/reagent/water, 30)

///Pole przesunięte względem środka areny; jeśli jest zajęte albo poza areną, pierwsze wolne pole
/datum/test_chamber_kit/pr_435/proc/free_turf(turf/center, dx, dy, list/turfs)
	var/turf/T = locate(center.x + dx, center.y + dy, center.z)
	if(kit_turf_free(T))
		turfs -= T
		return T
	for(var/turf/fallback as anything in turfs)
		if(kit_turf_free(fallback))
			turfs -= fallback
			return fallback
	return center

///Pole areny bez gęstych rzeczy, struktur i maszyn
/datum/test_chamber_kit/pr_435/proc/kit_turf_free(turf/T)
	if(!isopenturf(T) || !istype(T.loc, /area/test_chamber/arena) || is_blocked_turf(T, TRUE))
		return FALSE
	return !(locate(/obj/structure) in T) && !(locate(/obj/machinery) in T)

/datum/test_chamber_kit/pr_435/proc/dining_seat(chair_type, chair_dir, seat_type, turf/T)
	var/obj/structure/chair/chair = new chair_type(T)
	chair.setDir(chair_dir)
	new seat_type(T)
