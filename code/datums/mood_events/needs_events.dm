//nutrition
/datum/mood_event/fat
	description = "<span class='warning'><B>Jestem taki gruby.</B></span>\n" //muh fatshaming
	mood_change = -6

/datum/mood_event/wellfed
	description = "<span class='nicegreen'>I'm stuffed!</span>\n"
	mood_change = 8

/datum/mood_event/fed
	description = "<span class='nicegreen'>Niedawno coś zjadłem.</span>\n"
	mood_change = 5

/datum/mood_event/hungry
	description = "<span class='warning'>Robię się trochę głodny.</span>\n"
	mood_change = -10

/datum/mood_event/starving
	description = "<span class='boldwarning'>I'm starving!</span>\n"
	mood_change = -16

//charge
/datum/mood_event/charged
	description = "<span class='nicegreen'>Czuję moc w żyłach!</span>\n"
	mood_change = 6

/datum/mood_event/lowpower
	description = "<span class='warning'>Kończy mi się energia, powinienem gdzieś się naładować.</span>\n"
	mood_change = -10

/datum/mood_event/decharged
	description = "<span class='boldwarning'>Rozpaczliwie potrzebuję prądu!</span>\n"
	mood_change = -15

//Disgust
/datum/mood_event/gross
	description = "<span class='warning'>Widziałem coś obrzydliwego.</span>\n"
	mood_change = -4

/datum/mood_event/verygross
	description = "<span class='warning'>Chyba zaraz zwymiotuję.</span>\n"
	mood_change = -6

/datum/mood_event/disgusted
	description = "<span class='boldwarning'>O Boże, to obrzydliwe.</span>\n"
	mood_change = -8

/datum/mood_event/disgust/bad_smell
	description = "<span class='warning'>Czuję w tym pomieszczeniu coś okropnie rozłożonego.</span>\n"
	mood_change = -6

/datum/mood_event/disgust/nauseating_stench
	description = "<span class='warning'>Smród gnijących zwłok jest nie do zniesienia!</span>\n"
	mood_change = -12

//NSV13 - Hygiene Events
/datum/mood_event/neat
	description = "<span class='nicegreen'>Jestem taki czysty, uwielbiam to.</span>\n"
	mood_change = 3

/datum/mood_event/dirty
	description = "<span class='warning'>Okropnie śmierdzę.</span>\n"
	mood_change = -3

/datum/mood_event/disgusting
	description = "<span class='warning'>Śmierdzę <i>OBRZYDLIWIE!</i></span>\n"
	mood_change = -5

/datum/mood_event/happy_neet
	description = "<span class='nicegreen'>Okropnie śmierdzę.</span>\n"
	mood_change = 2

//Generic needs events
/datum/mood_event/nice_shower
	description = "<span class='nicegreen'>Niedawno wziąłem przyjemny prysznic.</span>\n"
	mood_change = 4
	timeout = 5 MINUTES

/datum/mood_event/fresh_laundry
	description = "<span class='nicegreen'>Nie ma to jak świeżo wyprany kombinezon.</span>\n"
	mood_change = 2
	timeout = 10 MINUTES
