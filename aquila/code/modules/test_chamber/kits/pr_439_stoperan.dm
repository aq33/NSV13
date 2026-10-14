/datum/test_chamber_kit/pr_439
	name = "Stoperan"
	pr = "aq33/AquilaStation#439"
	description = "Sprawdź pozycję „Pigułka stoperanu” w automacie górników. Połknij pigułkę: przez 5 minut potrzeba wypróżnienia nie ma rosnąć (np. jedząc dużo), \
		po czasie ma wrócić do normy z komunikatem. Druga pigułka odświeża czas. Toaleta nadal ma zmniejszać potrzebę."
	items = list(
		/obj/item/reagent_containers/pill/stoperan = 3,
		/obj/item/pizzabox/margherita = 2,
		/obj/machinery/vendor/mining = 1,
		/obj/item/card/id/mining = 1
	)

/datum/test_chamber_kit/pr_439/setup(list/spawned, list/turfs, turf/center, mob/user)
	// Punkty na zakup pigułki w automacie
	for(var/obj/item/card/id/mining/card in spawned)
		card.mining_points = 500
