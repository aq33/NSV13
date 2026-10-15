/datum/test_chamber_kit/pr_450
	name = "Specjalne szlamy"
	pr = "aq33/AquilaStation#450"
	description = "Gotowe ekstrakty: wstrzyknij strzykawką odczynniki z butelek (dark green: earthsblood/woda, cobalt: plazma/krew, \
		dark grey: krew/plazma, crimson: czarny proch/plazma). Steroid użyj na goliacie z zestawu. \
		Mutacje: zielony szlam stoi na trawie - daj mu małpę; różowemu daj rdzeń regeneracyjny; czerwonego podpal (miotacz/laser); \
		złoty wymaga grawitacji > 1 (anomalia grawitacyjna). Potem nakarm szlam sterydem/plazmą do podziału albo VV: amount_grown. \
		Ekstrakt specjalny przyłożony do szlama powinien odmówić krzyżowania."
	items = list(
		/obj/item/slime_extract/darkgreen = 2,
		/obj/item/slime_extract/cobalt = 2,
		/obj/item/slime_extract/darkgrey = 2,
		/obj/item/slime_extract/crimson = 2,
		/obj/item/reagent_containers/syringe = 4,
		/obj/item/reagent_containers/glass/bottle/plasma = 2,
		/obj/item/reagent_containers/glass/bottle/water = 1,
		/obj/item/organ/regenerative_core = 1,
		/obj/item/food/monkeycube = 3,
		/obj/item/stack/tile/grass = 1,
		/mob/living/simple_animal/hostile/asteroid/goliath/beast = 1
	)

/datum/test_chamber_kit/pr_450/setup(list/spawned, list/turfs, turf/center, mob/user)
	for(var/obj/item/stack/tile/grass/G in spawned)
		G.add(4) // stos 5 płytek; osobne sztuki na jednym turfie same by się połączyły
	var/index = length(items) + 1
	for(var/colour in list("green", "pink", "red", "gold"))
		var/turf/T = turfs[min(index++, length(turfs))]
		spawned += new /mob/living/simple_animal/slime(T, colour, TRUE)
	var/turf/T = turfs[min(index++, length(turfs))]
	for(var/reagent in list(/datum/reagent/medicine/earthsblood, /datum/reagent/blood, /datum/reagent/blackpowder))
		var/obj/item/reagent_containers/glass/bottle/B = new(T)
		B.reagents.add_reagent(reagent, 30)
		B.name = "[initial(B.name)] ([B.reagents.get_master_reagent_name()])"
		spawned += B
