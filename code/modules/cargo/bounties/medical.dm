/datum/bounty/item/medical/heart
	name = "Heart"
	description = "Komandor Johnson jest w stanie krytycznym po kolejnym zawale. Lekarze mówią, że szybko potrzebuje nowego serca. Wyślijcie jedno, migiem!"
	reward = 3000
	wanted_types = list(/obj/item/organ/heart)

/datum/bounty/item/medical/lung
	name = "Lungs"
	description = "Niedawny wybuch w Centrali zostawił wielu pracowników z przebitymi płucami. Wyślijcie zapasowe płuca, by otrzymać nagrodę."
	reward = 10000
	required_count = 3
	wanted_types = list(/obj/item/organ/lungs)

/datum/bounty/item/medical/appendix
	name = "Appendix"
	description = "Szef kuchni Gibb z Centrali chce przygotować posiłek z bardzo wyjątkowego przysmaku: wyrostka robaczkowego. Jeśli go wyślecie, zapłaci."
	reward = 5000 //there are no synthetic appendixes
	wanted_types = list(/obj/item/organ/appendix)

/datum/bounty/item/medical/ears
	name = "Ears"
	description = "Wielu pracowników Stacji 12 ogłuchło przez nieautoryzowane klaunowanie. Wyślijcie im nowe uszy."
	reward = 10000
	required_count = 3
	wanted_types = list(/obj/item/organ/ears)

/datum/bounty/item/medical/liver
	name = "Livers"
	description = "Wielu wysoko postawionych dyplomatów Centrali trafiło do szpitala z niewydolnością wątroby po niedawnym spotkaniu z ambasadorami Trzeciego Związku Radzieckiego. Pomożecie?"
	reward = 10000
	required_count = 3
	wanted_types = list(/obj/item/organ/liver)

/datum/bounty/item/medical/eye
	name = "Organic Eyes"
	description = "Dyrektor badań Stacji 5, Willem, prosi o kilka par nierobotycznych oczu. Nie zadawajcie pytań, po prostu je wyślijcie."
	reward = 10000
	required_count = 3
	wanted_types = list(/obj/item/organ/eyes)
	exclude_types = list(/obj/item/organ/eyes/robotic)

/datum/bounty/item/medical/tongue
	name = "Tongues"
	description = "Niedawny atak ekstremistów-mimów odebrał mowę personelowi Stacji 23. Wyślijcie zapasowe języki."
	reward = 10000
	required_count = 3
	wanted_types = list(/obj/item/organ/tongue)

/datum/bounty/item/medical/lizard_tail
	name = "Lizard Tail"
	description = "Federacja Czarodziejów zwinęła zapas jaszczurzych ogonów Nanotrasen. Czy, gdy Centrala rozprawia się z czarodziejami, stacja mogłaby odstąpić własny ogon?"
	reward = 3000
	wanted_types = list(/obj/item/organ/tail/lizard)

/datum/bounty/item/medical/cat_tail
	name = "Cat Tail"
	description = "W Centrali skończyły się wytrzymałe wyciory do rur. Możecie wysłać koci ogon, by nam pomóc?"
	reward = 3000
	wanted_types = list(/obj/item/organ/tail/cat)

/datum/bounty/item/medical/moth_wings
	name = "Pair of Moth Wings"
	description = "Woźnemu-ćmie z Centrali spłonęły skrzydła. Wyślecie zastępczą parę?"
	reward = 3000
	wanted_types = list(/obj/item/organ/wings/moth)
