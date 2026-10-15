/datum/test_chamber_kit/pr_444
	name = "Rewolucja, zegary, marskość"
	pr = "aq33/AquilaStation#444"
	description = "Rewolucja: zrób kogoś przywódcą rewolucji w panelu antagów - ma dostać zdolność „Nawrócenie rewolucyjne” zamiast flesza. \
		Konwersja to 3 zdania po 3 s, cel jest ogłuszony; odejście albo przerwanie ma ją zepsuć, a cel zaatakowany przed chwilą nie da się przekonać. \
		Wezwij prom przy trwającej rewolucji: po 2:30 lub później ma przyjść ogłoszenie, ETA 10 min i brak odwołania. \
		Zegary: zegar ma pokazywać czas pokładowy, emag losuje cyfry, multitool resetuje, ramę montuje się na ścianie. \
		Wyświetlacze: ustaw w konsoli komunikacyjnej krótki i długi komunikat (z polskimi literami) - długi ma płynnie przewijać się. \
		Marskość: zjedz wątrobę z zestawu przez autochirurga albo pij whisky/absynt i skanuj analizatorem - ma pokazać marskość. \
		Menu kołowe (np. skrzynka z narzędziami) ma być zawsze nad przedmiotami w rękach i HUD-em."
	items = list(
		/obj/machinery/digital_clock = 1,
		/obj/item/wallframe/digital_clock = 1,
		/obj/item/multitool = 1,
		/obj/item/card/emag = 1,
		/obj/machinery/status_display/evac = 1,
		/obj/machinery/computer/communications = 1,
		/obj/item/reagent_containers/food/drinks/bottle/whiskey = 2,
		/obj/item/reagent_containers/food/drinks/bottle/absinthe = 1,
		/obj/item/reagent_containers/food/drinks/beer = 4,
		/obj/item/healthanalyzer = 1,
		/obj/item/autosurgeon/cirrhosis_test = 1,
		/obj/item/storage/toolbox/mechanical = 1
	)

/obj/item/organ/liver/cirrhosis_test
	cirrhosis = 70

/obj/item/autosurgeon/cirrhosis_test
	uses = 1
	starting_organ = list(/obj/item/organ/liver/cirrhosis_test)
