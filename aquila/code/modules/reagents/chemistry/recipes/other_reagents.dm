/datum/chemical_reaction/concentrated_bz
	name = "Concentrated BZ"
	id = "Concentrated BZ"
	results = list(/datum/reagent/concentrated_bz = 10)
	required_reagents = list(/datum/reagent/toxin/plasma = 40, /datum/reagent/nitrous_oxide = 10)

/datum/chemical_reaction/fake_cbz
	name = "Fake CBZ"
	id = "Fake CBZ"
	results = list(/datum/reagent/fake_cbz = 1)
	required_reagents = list(/datum/reagent/concentrated_bz = 1, /datum/reagent/medicine/neurine = 3)
