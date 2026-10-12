/datum/quirk/seasick
	name = "Sea-sick"
	desc = "Your body has a natural aversion to the currents and radiation produced by bluespace. You may start to feel sick when the ship performs an FTL jump."
	value = -2
	mob_trait = TRAIT_SEASICK
	gain_text = "<span class='notice'>Myśl o podróży FTL budzi w tobie niepokój</span>"
	lose_text = "<span class='notice'>Myśl o podróży FTL nie wydaje się już taka zła.</span>"
	medical_record_text = "Pacjent jest wrażliwy na prądy bluespace i często choruje podczas podróży FTL."

/datum/quirk/junkie/coffee_addict
	name = "Coffee Addict"
	desc = "You have a strong addiction to caffeine. Probably not great in the long term."
	value = -1
	gain_text = "<span class='danger'>Masz ochotę na kubek kawy.</span>"
	lose_text = "<span class='notice'>Masz wrażenie, że nie potrzebujesz już tyle kofeiny.</span>"
	medical_record_text = "Pacjent jest uzależniony od kofeiny."
	reagent_type = /datum/reagent/consumable/coffee
	drug_container_type = /obj/item/reagent_containers/food/drinks/coffee
	process = TRUE

/datum/quirk/junkie/naval_coffee_Addict
	name = "Naval Coffee Addict"
	desc = "You have a strong addiction to the paint stripper liquid that the Navy calls coffee. Probably not great in the long term for your liver, or heart."
	value = -1
	gain_text = "<span class='danger'>Powieki ci ciążą, naprawdę potrzebujesz kubka kawy marynarki, żeby przetrwać ten patrol.</span>"
	lose_text = "<span class='notice'>Stres patrolu zelżał, nie czujesz już, że potrzebujesz tyle kofeiny.</span>"
	medical_record_text = "Pacjent jest silnie uzależniony od niebezpiecznego płynu, który marynarka nazywa kawą."
	reagent_type = /datum/reagent/consumable/navy_coffee
	drug_container_type = /obj/item/reagent_containers/food/drinks/coffee/navy_coffee
	process = TRUE
