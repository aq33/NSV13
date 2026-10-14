// aq33/AquilaStation#420 - nowe cele traitora, główny serwer B+R, historia zdrajcy

/datum/test_chamber_kit/pr_420
	name = "PR 420: cele traitora - przedmioty"
	pr = "aq33/AquilaStation#420"
	description = "Luźne przedmioty z nowych celów: papier z trucizną (zatruj laser i podnieś go bez rękawic, potem w rękawicach), wizytówka, implant szantażu, \
	dysk z serwera B+R, narzędzia do serwera, aparat do zdjęcia zwłok, moduł prawa SI. Urządzenia do podkładania działają z celami - weź zestaw \"zrób mnie zdrajcą\"."
	items = list(
		/obj/item/poison_paper = 2,
		/obj/item/gun/energy/laser/captain = 1,
		/obj/item/hand_tele = 1,
		/obj/item/clothing/gloves/color/black = 1,
		/obj/item/paper/calling_card = 1,
		/obj/item/implanter/blackmail = 1,
		/obj/item/computer_hardware/hard_drive/cluster/hdd_theft = 1,
		/obj/item/screwdriver = 1,
		/obj/item/crowbar = 1,
		/obj/item/wirecutters = 1,
		/obj/item/multitool = 1,
		/obj/item/camera = 1,
		/obj/item/aiModule/syndicate = 1,
	)

/datum/test_chamber_kit/pr_420_machines
	name = "PR 420: cele traitora - maszyny"
	pr = "aq33/AquilaStation#420"
	description = "Główny serwer B+R (śrubokręt -> łom -> przecinak, tylko antagonista; zwykły gracz nie znajdzie klapy), hub telekomunikacji (dysk z danymi), \
	konsola łączności (UWAGA: przechwytywacz naprawdę ściąga zagrożenie na statek), kloner i SMES do celu zniszczenia maszyn, drzwi do wirusa T1de."
	items = list(
		/obj/machinery/rnd/server/master = 1,
		/obj/machinery/telecomms/hub = 1,
		/obj/machinery/computer/communications = 1,
		/obj/machinery/clonepod = 1,
		/obj/machinery/power/smes = 1,
		/obj/machinery/door/airlock = 2,
	)

/// Makes the user a traitor with test versions of the objectives, all targeting the chamber
/datum/test_chamber_kit/pr_420_traitor
	name = "PR 420: zrób mnie zdrajcą z celami testowymi"
	pr = "aq33/AquilaStation#420"
	description = "Robi z ciebie zdrajcę (trzeba być człowiekiem w komorze). Otworzy się okno historii - wybierz frakcję i sprawdź, czy dopiero wtedy pojawia się uplink. \
	Cele celują w komorę: podsłuch, wirus T1de, bomba (wybuchnie w komorze!), zatrucie lasera i teleportera, dane z tcomms, włamanie do łączności, dysk B+R, beacon braci. \
	Do łączności, huba i serwera weź zestaw z maszynami. Stan celów sprawdzisz w oknie zdrajcy albo przez Traitor Panel."
	items = list(
		/obj/item/gun/energy/laser/captain = 1,
		/obj/item/hand_tele = 1,
		/obj/item/clothing/gloves/color/black = 1,
	)

/datum/test_chamber_kit/pr_420_traitor/setup(list/spawned, list/turfs, turf/center, mob/user)
	var/mob/living/carbon/human/H = user
	if(!istype(H) || !H.mind)
		to_chat(user, "<span class='warning'>Musisz być człowiekiem w komorze, żeby zostać zdrajcą. Przedmioty i tak leżą na arenie.</span>")
		return
	var/area/chamber_area = get_area(center)
	var/datum/antagonist/traitor/traitor = H.mind.has_antag_datum(/datum/antagonist/traitor)
	if(!traitor)
		traitor = new
		traitor.give_objectives = FALSE
		H.mind.add_antag_datum(traitor)
	var/list/new_objectives = list()

	for(var/device_type in list(/datum/objective/plant_device/bug, /datum/objective/plant_device/tide, /datum/objective/plant_device/bomb))
		var/datum/objective/plant_device/plant = new device_type
		plant.owner = H.mind
		plant.target_areas = list(chamber_area)
		if(istype(plant, /datum/objective/plant_device/tide))
			var/datum/objective/plant_device/tide/tide = plant
			tide.department_name = "komora testowa"
		plant.update_explanation_text()
		plant.give_device()
		new_objectives += plant

	var/datum/objective/poison_items/poison = new
	poison.owner = H.mind
	poison.target_paths = list(/obj/item/gun/energy/laser/captain = "zabytkowy laser kapitana", /obj/item/hand_tele = "teleporter ręczny")
	poison.update_explanation_text()
	poison.give_papers()
	new_objectives += poison

	var/datum/objective/tcomms_data/tcomms = new
	tcomms.owner = H.mind
	tcomms.give_special_equipment(list(/obj/item/disk/tcomms_data))
	new_objectives += tcomms

	var/datum/objective/hack_comms/hack = new
	hack.owner = H.mind
	hack.give_special_equipment(list(/obj/item/comms_hacker))
	new_objectives += hack

	var/datum/objective/steal/hdd/hdd = new
	hdd.owner = H.mind
	var/datum/objective_item/steal/hdd_extraction/hdd_item = locate() in GLOB.possible_items
	if(hdd_item)
		hdd.set_steal_target(hdd_item)
		new_objectives += hdd
	else
		qdel(hdd)

	if(!GLOB.brother_beacon_site)
		GLOB.brother_beacon_site = center
	var/datum/objective/brother_beacon/beacon = new
	beacon.owner = H.mind
	if(beacon.setup_beacon())
		new_objectives += beacon
	else
		qdel(beacon)

	for(var/datum/objective/objective as anything in new_objectives)
		traitor.add_objective(objective)
	if(traitor.uses_backstory() && !traitor.faction)
		traitor.setup_backstories(FALSE, FALSE)
		traitor.update_static_data(H)
	H.mind.announce_objectives()
	traitor.ui_interact(H)
