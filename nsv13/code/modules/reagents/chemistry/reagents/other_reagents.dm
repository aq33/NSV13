/datum/reagent/methane
	name = "Methane"
	description = "Lekki, łatwopalny węglowodór. Powszechnie używany do produkcji paliwa kriogenicznego."
	reagent_state = GAS
	color = "#ccf6ff"
	taste_description = "nic"

/datum/reagent/consumable/creamer
	name = "Coffee Creamer"
	description = "Mleko w proszku do taniej kawy. Jak uroczo."
	taste_description = "mleko"
	color = "#efeff0"
	nutriment_factor = 1.5 * REAGENTS_METABOLISM

/datum/reagent/consumable/navy_coffee
	name = "Naval Coffee"
	description = "Krew życia marynarki i wojska wszędzie; ta kawa jest tak mocna, że nie da ci spać przez wiele dni, zniszczy kubki smakowe i obudzi pieprzonych umarłych."
	color = "#241000"
	nutriment_factor = 0
	addiction_threshold = 40 //Downing two cups in one go will make you addicted to it.
	taste_description = "skrajna gorycz z nutą paliwa"
	glass_icon_state = "glass_brown"
	glass_name = "glass of navy coffee"
	glass_desc = "Nie upuść jej, bo zdegradują cię z powrotem do kadeta!"

/datum/reagent/consumable/navy_coffee/on_mob_life(mob/living/carbon/M)
	M.dizziness = max(0,M.dizziness-5)
	M.drowsyness = max(0,M.drowsyness-3)
	M.AdjustSleeping(-40, FALSE)
	SEND_SIGNAL(M, COMSIG_ADD_MOOD_EVENT, "navy_coffee", /datum/mood_event/drink_navy_coffee, M.faction)
	..()
	. = 1

/obj/item/reagent_containers/food/drinks/coffee/navy_coffee
	name = "naval coffee"
	list_reagents = list(/datum/reagent/consumable/navy_coffee = 30)
