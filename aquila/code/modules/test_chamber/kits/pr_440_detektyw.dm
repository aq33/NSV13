// aq33/AquilaStation#440 - detektyw (luminol, ślady prochu, balistyka, logi drzwi, miejsce zbrodni) i genpop po polsku

/datum/test_chamber_kit/pr_440_forensics
	name = "PR 440: luminol, ślady prochu, balistyka"
	pr = "aq33/AquilaStation#440"
	description = "Weź zestaw obiektów testowych. Zrań człowieka nożem, umyj krew mopem lub cleanerem, popsikaj luminolem i zeskanuj świecący ślad. \
	Strzel z Makarowa (ostra amunicja) i zeskanuj swoje dłonie, broń, łuskę i ciało (fragmenty pocisków; wyjmij je chirurgią ciał obcych). \
	Spiłuj numer seryjny PPM śrubokrętem, obetnij lufę dwururki piłą i porównaj sygnatury. Umyj ręce mydłem - ślady prochu znikają."
	items = list(
		/obj/item/detective_scanner = 1,
		/obj/item/reagent_containers/spray/luminol = 2,
		/obj/item/kitchen/knife = 1,
		/obj/item/mop = 1,
		/obj/item/reagent_containers/spray/cleaner = 1,
		/obj/item/soap/nanotrasen = 1,
		/obj/item/gun/ballistic/automatic/pistol/glock/makarov/lethal = 1,
		/obj/item/gun/ballistic/shotgun/doublebarrel = 1,
		/obj/item/circular_saw = 1,
		/obj/item/screwdriver = 1,
		/obj/item/clothing/gloves/color/black = 1,
		/obj/item/storage/box/evidence = 1,
		/obj/structure/table/optable = 1,
		/obj/item/scalpel = 1,
		/obj/item/hemostat = 1,
		/obj/item/retractor = 1,
	)

/datum/test_chamber_kit/pr_440_scene
	name = "PR 440: logi drzwi i miejsce zbrodni"
	pr = "aq33/AquilaStation#440"
	description = "Drzwi i szafka wymagają dostępu ochrony - otwórz je kartą, potem w tablecie detektywa włącz „Czytnik logów dostępu” i kliknij tabletem w drzwi (drukuj, emag czyści log). \
	Rozciągnij taśmę (użyj rolki dwa razy) i przejdź przez nią bez karty ochrony - na taśmie zostaje odcisk. Postaw znaczniki, obrysuj kredą leżące ciało, \
	postaw rażącą holobarierę detektywa, a na projektorze ochrony włącz strefę zamkniętą (przycisk akcji)."
	items = list(
		/obj/item/modular_computer/tablet/pda/detective = 1,
		/obj/item/card/id/captains_spare = 1,
		/obj/machinery/door/airlock/security = 1,
		/obj/structure/closet/secure_closet/security = 1,
		/obj/item/barrier_tape_roll = 1,
		/obj/item/storage/box/csi_markers = 1,
		/obj/item/toy/crayon/white/chalk = 1,
		/obj/item/holosign_creator/detective = 1,
		/obj/item/holosign_creator/security = 1,
		/obj/item/detective_scanner = 1,
	)

/datum/test_chamber_kit/pr_440_scene/setup(list/spawned, list/turfs, turf/center, mob/user)
	for(var/obj/machinery/door/airlock/security/door in spawned)
		door.req_access = list(ACCESS_SECURITY)

/datum/test_chamber_kit/pr_440_genpop
	name = "PR 440: genpop po polsku"
	pr = "aq33/AquilaStation#440"
	description = "Otwórz interfejs więźniów (karta kapitana daje dostęp). Zaznacz kilka zarzutów z różnych kategorii i sprawdź, czy czas się sumuje, \
	potem modyfikatory (usiłowanie, recydywa, opór). Wydrukuj kartę, przyłóż „Zwolnij” i „Uciekł” do zwolnionej już karty - powinna wrócić do odliczania."
	items = list(
		/obj/machinery/genpop_interface = 1,
		/obj/item/card/id/captains_spare = 1,
	)
