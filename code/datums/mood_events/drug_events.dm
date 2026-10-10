/datum/mood_event/high
	mood_change = 6
	description = "<span class='nicegreen'>Łooooł, stary... ale mam odlot...</span>\n"

/datum/mood_event/smoked
	description = "<span class='nicegreen'>Niedawno zapaliłem.</span>\n"
	mood_change = 2
	timeout = 6 MINUTES

/datum/mood_event/wrong_brand
	description = "<span class='warning'>Nienawidzę tej marki papierosów.</span>\n"
	mood_change = -2
	timeout = 6 MINUTES

/datum/mood_event/overdose
	mood_change = -8
	timeout = 5 MINUTES

/datum/mood_event/overdose/add_effects(drug_name)
	description = "<span class='warning'>Chyba wziąłem trochę za dużo: [drug_name]</span>\n"

/datum/mood_event/withdrawal_light
	mood_change = -2

/datum/mood_event/withdrawal_light/add_effects(drug_name)
	description = "<span class='warning'>Przydałoby mi się trochę [drug_name]</span>\n"

/datum/mood_event/withdrawal_medium
	mood_change = -5

/datum/mood_event/withdrawal_medium/add_effects(drug_name)
	description = "<span class='warning'>Naprawdę potrzebuję [drug_name]</span>\n"

/datum/mood_event/withdrawal_severe
	mood_change = -8

/datum/mood_event/withdrawal_severe/add_effects(drug_name)
	description = "<span class='boldwarning'>O Boże, potrzebuję trochę [drug_name]</span>\n"

/datum/mood_event/withdrawal_critical
	mood_change = -10

/datum/mood_event/withdrawal_critical/add_effects(drug_name)
	description = "<span class='boldwarning'>[drug_name]! [drug_name]! [drug_name]!</span>\n"

/datum/mood_event/happiness_drug
	description = "<span class='nicegreen'>Nic nie czuję i chcę, żeby to się nigdy nie skończyło.</span>\n"
	mood_change = 50

/datum/mood_event/happiness_drug_good_od
	description = "<span class='nicegreen'>TAK! TAK!! TAK!!!</span>\n"
	mood_change = 100
	timeout = 30 SECONDS
	special_screen_obj = "mood_happiness_good"

/datum/mood_event/happiness_drug_bad_od
	description = "<span class='boldwarning'>NIE! NIE!! NIE!!!</span>\n"
	mood_change = -100
	timeout = 30 SECONDS
	special_screen_obj = "mood_happiness_bad"
