// AQUILA - zlecenia cywilne dla prac NSV: amunicja, piloci, górnicy z asteroid, mostek, woźny

// Amunicja (technik amunicji, master-at-arms) - wszystko z protolathe amunicji

/datum/bounty/item/munitions/guidance
	name = "Systemy naprowadzania"
	description = "Flota zgubiła całą partię systemów naprowadzania torped. Wyślijcie zapasowe, zanim ktoś odpali torpedę w stronę stacji."
	reward = 2000
	required_count = 3
	wanted_types = list(/obj/item/ship_weapon/parts/missile/guidance_system)

/datum/bounty/item/munitions/propulsion
	name = "Napędy pocisków"
	description = "Zakład zbrojeniowy na Marsie stanął. Potrzebujemy gotowych napędów do pocisków i torped."
	reward = 2500
	required_count = 2
	wanted_types = list(/obj/item/ship_weapon/parts/missile/propulsion_system)

/datum/bounty/item/munitions/iff_cards
	name = "Karty IFF"
	description = "Audyt wykazał, że połowa kart IFF floty uznaje sojuszników za wrogów. Przyślijcie świeże karty."
	reward = 1500
	required_count = 4
	wanted_types = list(/obj/item/ship_weapon/parts/missile/iff_card)

/datum/bounty/item/munitions/warheads
	name = "Głowice torpedowe"
	description = "Okręt flagowy wraca z pustymi magazynami. Wyślijcie głowice torpedowe dowolnego typu."
	reward = 3500
	required_count = 2
	wanted_types = list(/obj/item/ship_weapon/parts/missile/warhead)

/datum/bounty/item/munitions/railgun
	name = "Pociski do railguna"
	description = "Bateria obrony Centrali wystrzelała zapas. Potrzebne są pociski do railguna."
	reward = 2500
	required_count = 4
	wanted_types = list(/obj/item/ship_weapon/ammunition/railgun_ammo)

/datum/bounty/item/munitions/powder
	name = "Worki z prochem"
	description = "Muzeum marynarki odtwarza bitwę z czasów dział pokładowych i chce prawdziwego prochu."
	reward = 2000
	required_count = 3
	wanted_types = list(/obj/item/powder_bag)

/datum/bounty/item/munitions/broadside
	name = "Pociski burtowe"
	description = "Fregaty patrolowe mają dość ślepaków. Wyślijcie gotowe pociski burtowe."
	reward = 3000
	required_count = 4
	wanted_types = list(/obj/item/ship_weapon/ammunition/broadside_shell)

// Piloci i technicy pokładowi - części myśliwców

/datum/bounty/item/pilot/countermeasures
	name = "Ładunki przeciwdziałania"
	description = "Eskadra szkoleniowa zużyła wszystkie flary na pokazie. Przyślijcie ładunki przeciwdziałania."
	reward = 1500
	required_count = 6
	wanted_types = list(/obj/item/ship_weapon/ammunition/countermeasure_charge)

/datum/bounty/item/pilot/armour
	name = "Pancerz myśliwca"
	description = "Warsztat floty ma kolejkę rozbitych myśliwców. Potrzebne są płyty pancerza."
	reward = 2500
	required_count = 2
	wanted_types = list(/obj/item/fighter_component/armour_plating)

/datum/bounty/item/pilot/fuel_tank
	name = "Zbiorniki paliwa"
	description = "Nowy model myśliwca przecieka. Do testów potrzebne są sprawne zbiorniki paliwa."
	reward = 2000
	required_count = 2
	wanted_types = list(/obj/item/fighter_component/fuel_tank)

/datum/bounty/item/pilot/engine
	name = "Silnik myśliwca"
	description = "Akademia pilotów rozebrała ostatni silnik na części. Wyślijcie cały."
	reward = 3000
	wanted_types = list(/obj/item/fighter_component/engine)

/datum/bounty/item/pilot/battery
	name = "Baterie myśliwców"
	description = "Hangar Centrali stoi bez prądu. Potrzebne są baterie do myśliwców."
	reward = 2000
	required_count = 2
	wanted_types = list(/obj/item/fighter_component/battery)

/datum/bounty/item/pilot/cannon
	name = "Działka myśliwców"
	description = "Eskadra przechwytująca dostała myśliwce bez uzbrojenia. Wyślijcie działka."
	reward = 3000
	wanted_types = list(/obj/item/fighter_component/primary/cannon)

/datum/bounty/item/pilot/launcher
	name = "Wyrzutnia uzbrojenia"
	description = "Bombowce czekają na wyrzutnie uzbrojenia. Jedna wystarczy na prototyp."
	reward = 3000
	wanted_types = list(/obj/item/fighter_component/secondary/ordnance_launcher)

// Górnicy - asteroidy zamiast Lavalandu

/datum/bounty/item/asteroid_mining/titanium
	name = "Tytan"
	description = "Stocznia potrzebuje tytanu na kadłuby. Dostarczcie arkusze tytanu."
	reward = 2000
	required_count = 20
	wanted_types = list(/obj/item/stack/sheet/mineral/titanium)

/datum/bounty/item/asteroid_mining/silver
	name = "Srebro"
	description = "Dział elektroniki zużył całe srebro. Przyślijcie arkusze srebra."
	reward = 1500
	required_count = 20
	wanted_types = list(/obj/item/stack/sheet/mineral/silver)

/datum/bounty/item/asteroid_mining/gold
	name = "Złoto"
	description = "Zarząd Nanotrasen chce nowe złote tabliczki na drzwiach. Wyślijcie złoto."
	reward = 2000
	required_count = 15
	wanted_types = list(/obj/item/stack/sheet/mineral/gold)

/datum/bounty/item/asteroid_mining/uranium
	name = "Uran"
	description = "Reaktor badawczy Centrali kończy paliwo. Potrzebny jest uran."
	reward = 2500
	required_count = 10
	wanted_types = list(/obj/item/stack/sheet/mineral/uranium)

/datum/bounty/item/asteroid_mining/diamond
	name = "Diamenty"
	description = "Laboratorium optyki potrzebuje diamentów na soczewki."
	reward = 3500
	required_count = 5
	wanted_types = list(/obj/item/stack/sheet/mineral/diamond)

/datum/bounty/item/asteroid_mining/bluespace
	name = "Kryształy bluespace"
	description = "Badania nad skokami FTL wymagają kryształów bluespace prosto z asteroid."
	reward = 4000
	required_count = 5
	wanted_types = list(/obj/item/stack/ore/bluespace_crystal)

/datum/bounty/item/asteroid_mining/duranium
	name = "Duran"
	description = "Pancerz nowego krążownika wymaga duranu. Przetopcie rudę i wyślijcie arkusze."
	reward = 3000
	required_count = 20
	wanted_types = list(/obj/item/stack/sheet/duranium)

/datum/bounty/item/asteroid_mining/nanocarbon
	name = "Szkło nanowęglowe"
	description = "Kopuły obserwacyjne Centrali popękały. Potrzebne jest szkło nanowęglowe."
	reward = 2000
	required_count = 20
	wanted_types = list(/obj/item/stack/sheet/nanocarbon_glass)

// Mostek i kontrola lotów - płytki konsol okrętowych do wydrukowania w R&D

/datum/bounty/item/bridge/navigation
	name = "Płytka nawigacji"
	description = "Nowy okręt zwiadowczy wyleciał bez konsoli nawigacyjnej. Zdobądźcie płytkę i wyślijcie ją."
	reward = 2000
	wanted_types = list(/obj/item/circuitboard/computer/ship/navigation)

/datum/bounty/item/bridge/dradis
	name = "Płytka DRADIS"
	description = "Sieć wczesnego ostrzegania ma dziury. Wyślijcie zapasowe płytki DRADIS."
	reward = 2000
	required_count = 2
	wanted_types = list(/obj/item/circuitboard/computer/ship/dradis)

/datum/bounty/item/bridge/tactical
	name = "Płytka konsoli taktycznej"
	description = "Symulator dowodzenia w Akademii potrzebuje prawdziwej konsoli taktycznej."
	reward = 2500
	wanted_types = list(/obj/item/circuitboard/computer/ship/tactical_computer)

/datum/bounty/item/bridge/helm
	name = "Płytka steru"
	description = "Holownik Centrali stracił ster w awarii. Wyślijcie płytkę konsoli steru."
	reward = 2500
	wanted_types = list(/obj/item/circuitboard/computer/ship/helm)

/datum/bounty/item/bridge/fighter_control
	name = "Płytka kontroli myśliwców"
	description = "Nowa wieża kontroli lotów nie ma czym sterować. Wyślijcie płytkę konsoli kontroli myśliwców."
	reward = 2000
	wanted_types = list(/obj/item/circuitboard/computer/ship/fighter_controller)

// Woźny

/datum/bounty/item/janitor/trash_bags
	name = "Worki na śmieci"
	description = "Na stacji przesiadkowej skończyły się worki na śmieci. Wyślijcie kilka."
	reward = 1000
	required_count = 3
	wanted_types = list(/obj/item/storage/bag/trash)

/datum/bounty/item/janitor/trash
	name = "Śmieci do analizy"
	description = "Dział ekologii Centrali bada, co wyrzuca załoga. Zbierzcie i wyślijcie śmieci."
	reward = 1000
	required_count = 15
	wanted_types = list(/obj/item/trash)

/datum/bounty/item/janitor/light_tubes
	name = "Świetlówki"
	description = "Korytarze Centrali toną w mroku. Przyślijcie świetlówki."
	reward = 1000
	required_count = 10
	wanted_types = list(/obj/item/light/tube)

/datum/bounty/item/janitor/cleaner
	name = "Środek czyszczący"
	description = "Ktoś rozlał coś nieopisanego w sali konferencyjnej. Wyślijcie spryskiwacze ze środkiem czyszczącym."
	reward = 1500
	required_count = 3
	wanted_types = list(/obj/item/reagent_containers/spray/cleaner)

/datum/bounty/item/janitor/caution
	name = "Znaki „mokra podłoga”"
	description = "Po trzech poślizgnięciach dyrektora Centrala zamawia znaki ostrzegawcze."
	reward = 1000
	required_count = 4
	wanted_types = list(/obj/item/clothing/suit/caution)

/datum/bounty/item/janitor/light_replacer
	name = "Wymieniacz świetlówek"
	description = "Nowy woźny w Centrali chce pracować jak profesjonalista. Wyślijcie wymieniacz świetlówek."
	reward = 1500
	wanted_types = list(/obj/item/lightreplacer)
