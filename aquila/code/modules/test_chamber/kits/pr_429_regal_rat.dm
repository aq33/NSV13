/datum/test_chamber_kit/pr_429
	name = "Szczurzy król"
	pr = "aq33/AquilaStation#429"
	description = "Jako duch kliknij szczurzego króla, żeby go przejąć. Zbierz armię przy myszach (zmienia je w szczury) i bez myszy w pobliżu (przywołuje nową). \
		Domena: miazma i brud. Poza trybem walki poliż zlewkę i człowieka (szczurza ślina, 20u to przedawkowanie i frakcja szczurów), podważ zwykłą śluzę (ta zaryglowana ma się nie dać), \
		w trybie walki drap. Ser leczy, pułapki ranią szczury, a króla nie. W pierwszej skrzyni jest królewski ser: połóż go obok myszy, zanim zmienisz ją w szczura, ma wyewoluować w króla. \
		W drugiej skrzyni składniki do wytworzenia królewskiego sera."
	items = list(
		/mob/living/simple_animal/hostile/regalrat/controlled = 1,
		/mob/living/simple_animal/mouse = 4,
		/obj/item/food/cheese/wedge = 3,
		/obj/item/food/cheese/wheel = 1,
		/obj/item/assembly/mousetrap/armed = 2,
		/obj/item/reagent_containers/glass/beaker = 1,
		/mob/living/carbon/human = 1
	)

/datum/test_chamber_kit/pr_429/setup(list/spawned, list/turfs, turf/center, mob/user)
	// Skrzynie i śluzy na dalszych turfach; ser zamknięty, żeby myszy nie zjadły go od razu
	var/list/far = turfs.Copy(min(length(items) + 1, length(turfs)))
	if(length(far) < 4)
		far = turfs
	var/obj/structure/closet/crate/cheese_crate = new(far[1])
	cheese_crate.name = "królewski ser"
	new /obj/item/food/royalcheese(cheese_crate)

	var/obj/structure/closet/crate/recipe_crate = new(far[2])
	recipe_crate.name = "składniki królewskiego sera"
	new /obj/item/food/cheese/wheel/cheddar(recipe_crate)
	new /obj/item/clothing/head/crown(recipe_crate)
	new /obj/item/reagent_containers/glass/bottle/mutagen(recipe_crate)
	var/obj/item/reagent_containers/glass/bottle/strange = new(recipe_crate)
	strange.name = "strange reagent bottle"
	strange.reagents.add_reagent(/datum/reagent/medicine/strange_reagent, 30)

	new /obj/machinery/door/airlock(far[3])
	var/obj/machinery/door/airlock/bolted = new(far[4])
	bolted.name = "zaryglowana śluza"
	bolted.bolt()
