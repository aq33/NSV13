/datum/test_chamber_kit/pr_456
	name = "Wyszukiwarki przepisów i operacji"
	pr = "aq33/AquilaStation#456"
	description = "Chem dispenser i booze dispenser: przycisk „Szukaj” w sekcji „Wyszukiwarka przepisów”. Wpisz „bicaridine”, przełącz na „Składnik”, zaznacz „Tylko stąd”, wydaj składnik kroplą (zlewka w maszynie). \
		PDA lekarza: program „Operacje” (filtr miejsca, rozwinięcie operacji, kroki z narzędziami). PDA chemika i barmana: program „Receptury”."
	items = list(
		/obj/machinery/chem_dispenser = 1,
		/obj/machinery/chem_dispenser/drinks/beer = 1,
		/obj/item/reagent_containers/glass/beaker/large = 2,
		/obj/item/modular_computer/tablet/pda/medical = 1,
		/obj/item/modular_computer/tablet/pda/chemist = 1,
		/obj/item/modular_computer/tablet/pda/bartender = 1
	)
