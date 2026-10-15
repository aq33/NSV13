/datum/bounty/item/assistant/strange_object
	name = "Strange Object"
	description = "Nanotrasen zainteresował się dziwnymi obiektami. Znajdźcie jeden w tunelach technicznych i od razu wyślijcie go do Centrali."
	reward = 1200
	wanted_types = list(/obj/item/relic)

/datum/bounty/item/assistant/scooter
	name = "Scooter"
	description = "Nanotrasen uznał chodzenie za marnotrawstwo. Wyślijcie hulajnogę do Centrali, by przyspieszyć działania."
	reward = 1080 // the mat hoffman
	wanted_types = list(/obj/vehicle/ridden/scooter)
	include_subtypes = FALSE

/datum/bounty/item/assistant/skateboard
	name = "Skateboard"
	description = "Nanotrasen uznał chodzenie za marnotrawstwo. Wyślijcie deskorolkę do Centrali, by przyspieszyć działania."
	reward = 900 // the tony hawk
	wanted_types = list(/obj/vehicle/ridden/scooter/skateboard, /obj/item/melee/skateboard)

/datum/bounty/item/assistant/stunprod
	name = "Stunprod"
	description = "Centrala żąda pałki paralizującej do użycia przeciwko dysydentom. Zróbcie ją, a potem wyślijcie."
	reward = 1300
	wanted_types = list(/obj/item/melee/baton/cattleprod)

/datum/bounty/item/assistant/soap
	name = "Soap"
	description = "Z łazienek Centrali zniknęło mydło i nikt nie wie, kto je zabrał. Zastąpcie je i bądźcie bohaterami, jakich Centrala potrzebuje."
	reward = 2000
	required_count = 3
	wanted_types = list(/obj/item/soap)

/datum/bounty/item/assistant/spear
	name = "Spears"
	description = "Siły ochrony Centrali przechodzą cięcia budżetowe. Dostaniecie zapłatę, jeśli wyślecie zestaw włóczni."
	reward = 2000
	required_count = 5
	wanted_types = list(/obj/item/spear)

/datum/bounty/item/assistant/toolbox
	name = "Toolboxes"
	description = "W Centrali brakuje krzepy. Pospieszcie się i wyślijcie trochę skrzynek z narzędziami jako rozwiązanie."
	reward = 2000
	required_count = 6
	wanted_types = list(/obj/item/storage/toolbox)

/datum/bounty/item/assistant/statue
	name = "Statue"
	description = "Centrala chciałaby zamówić artystyczny posąg do holu. Wyślijcie go, kiedy tylko będzie można."
	reward = 2000
	wanted_types = list(/obj/structure/statue)

/datum/bounty/item/assistant/clown_box
	name = "Clown Box"
	description = "Wszechświat potrzebuje śmiechu. Podstemplujcie karton pieczątką klauna i wyślijcie go."
	reward = 1500
	wanted_types = list(/obj/item/storage/box/clown)

/datum/bounty/item/assistant/cheesiehonkers
	name = "Cheesie Honkers"
	description = "Podobno firma produkująca Cheesie Honkers wkrótce zbankrutuje. Centrala chce zrobić zapasy, zanim to nastąpi!"
	reward = 1200
	required_count = 3
	wanted_types = list(/obj/item/food/cheesiehonkers)

/datum/bounty/item/assistant/baseball_bat
	name = "Baseball Bat"
	description = "W Centrali panuje gorączka baseballu! Bądźcie tak mili i wyślijcie im kilka kijów baseballowych, by kierownictwo mogło spełnić marzenie z dzieciństwa."
	reward = 2000
	required_count = 5
	wanted_types = list(/obj/item/melee/baseball_bat)

/datum/bounty/item/assistant/extendohand
	name = "Extendo-Hand"
	description = "Komandor Betsy się starzeje i nie może się już schylić po pilota do teleekranu. Kierownictwo prosi o wydłużoną rękę, by jej pomóc."
	reward = 2500
	wanted_types = list(/obj/item/extendohand)

/datum/bounty/item/assistant/donut
	name = "Donuts"
	description = "Siły ochrony Centrali ponoszą ciężkie straty w walce z Syndykatem. Wyślijcie pączki, by podnieść morale."
	reward = 3000
	required_count = 10
	wanted_types = list(/obj/item/food/donut)

/datum/bounty/item/assistant/donkpocket
	name = "Donk-Pockets"
	description = "Wycofanie produktu dla bezpieczeństwa konsumentów: Ostrzeżenie. Donk-Pockety wyprodukowane w ubiegłym roku zawierają niebezpieczną biomasę jaszczurów. Natychmiast zwróćcie je do Centrali."
	reward = 3000
	required_count = 10
	wanted_types = list(/obj/item/food/donkpocket)

/datum/bounty/item/assistant/briefcase
	name = "Briefcase"
	description = "Centrala organizuje w tym roku konwencję biznesową. Wyślijcie kilka teczek na wsparcie."
	reward = 2500
	required_count = 5
	wanted_types = list(/obj/item/storage/briefcase, /obj/item/storage/secure/briefcase)

/datum/bounty/item/assistant/sunglasses
	name = "Sunglasses"
	description = "Przez sektor przejeżdża słynny duet bluesowy, ale zgubili okulary przeciwsłoneczne i nie mogą występować. Wyślijcie nowe okulary przeciwsłoneczne do Centrali, by temu zaradzić."
	reward = 3000
	required_count = 2
	wanted_types = list(/obj/item/clothing/glasses/sunglasses)

/datum/bounty/item/assistant/monkey_hide
	name = "Monkey Hide"
	description = "Jeden z naukowców w Centrali chce testować produkty na małpiej skórze. Waszym zadaniem jest zdobyć małpią skórę i ją wysłać."
	reward = 1500
	wanted_types = list(/obj/item/stack/sheet/animalhide/monkey)

/datum/bounty/item/assistant/shard
	name = "Shards"
	description = "Centralę nęka klaun-zabójca, a personel nie może jej złapać, bo nie nosi butów. Wyślijcie trochę odłamków szkła, by zbudować pułapkę."
	reward = 1500
	required_count = 15
	wanted_types = list(/obj/item/shard)

/datum/bounty/item/assistant/comfy_chair
	name = "Comfy Chairs"
	description = "Komandor Pat jest niezadowolony ze swojego krzesła. Twierdzi, że boli go od niego plecy. Wyślijcie jakieś alternatywy, by go udobruchać."
	reward = 1500
	required_count = 5
	wanted_types = list(/obj/structure/chair/fancy/comfy)

/datum/bounty/item/assistant/poppy
	name = "Poppies"
	description = "Komandor Zot bardzo chce zawrócić w głowie oficer ochrony Olivii. Wyślijcie maki – jej ulubione kwiaty – a chętnie was wynagrodzi."
	reward = 1000
	required_count = 3
	wanted_types = list(/obj/item/food/grown/poppy)
	include_subtypes = FALSE

/datum/bounty/item/assistant/shadyjims
	name = "Shady Jim's"
	description = "W Centrali jest wściekły oficer, który żąda paczki papierosów Shady Jim's. Wyślijcie jedną. Zaczyna grozić."
	reward = 500
	wanted_types = list(/obj/item/storage/fancy/cigarettes/cigpack_shadyjims)

/datum/bounty/item/assistant/potted_plants
	name = "Potted Plants"
	description = "Centrala zamierza zamówić nową stację klasy BirdBoat. Macie dostarczyć rośliny doniczkowe."
	reward = 2000
	required_count = 8
	wanted_types = list(/obj/item/kirbyplants)

/datum/bounty/item/assistant/earmuffs
	name = "Earmuffs"
	description = "Centrala ma dość wiadomości z waszej stacji. Kazała wysłać nauszniki, by zmniejszyć irytację."
	reward = 1000
	wanted_types = list(/obj/item/clothing/ears/earmuffs)

/datum/bounty/item/assistant/handcuffs
	name = "Handcuffs"
	description = "Do Centrali trafiło mnóstwo zbiegłych skazańców. To idealny moment, by wysłać zapasowe kajdanki (albo inne więzy)."
	reward = 1000
	required_count = 5
	wanted_types = list(/obj/item/restraints/handcuffs)

/datum/bounty/item/assistant/monkey_cubes
	name = "Monkey Cubes"
	description = "Po niedawnym wypadku genetycznym Centrala pilnie potrzebuje małp. Waszym zadaniem jest wysłać kostki małpie."
	reward = 2000
	required_count = 3
	wanted_types = list(/obj/item/food/monkeycube)

/datum/bounty/item/assistant/chainsaw
	name = "Chainsaw"
	description = "Kucharka w Centrali ma problem z ubojem zwierząt. Prosi o jedną piłę łańcuchową."
	reward = 2500
	wanted_types = list(/obj/item/chainsaw)

/datum/bounty/item/assistant/ied
	name = "IED"
	description = "Więzienie o zaostrzonym rygorze Nanotrasen w Centrali przechodzi szkolenie personelu. Wyślijcie kilka IED jako pomoce szkoleniowe."
	reward = 2000
	required_count = 3
	wanted_types = list(/obj/item/grenade/iedcasing)

/datum/bounty/item/assistant/bonfire
	name = "Lit Bonfire"
	description = "Grzejniki się psują, a załoga zaopatrzenia Centrali zaczyna marznąć. Wyślijcie płonące ognisko, by ich ogrzać."
	reward = 5000
	wanted_types = list(/obj/structure/bonfire)

/datum/bounty/item/assistant/bonfire/applies_to(obj/O)
	if(!..())
		return FALSE
	var/obj/structure/bonfire/B = O
	return !!B.burning

/datum/bounty/item/assistant/corgimeat
	name = "Raw Corgi Meat"
	description = "Syndykat ukradł niedawno całe mięso corgi z Centrali. Natychmiast wyślijcie zamiennik."
	reward = 3000
	wanted_types = list(/obj/item/food/meat/slab/corgi)

/datum/bounty/item/assistant/corgifarming
	name = "Corgi Hides"
	description = "Kosmiczny jacht admirała Weinsteina potrzebuje nowej tapicerki. Tuzin skór corgi w zupełności wystarczy."
	reward = 30000 //that's a lot of dead dogs
	required_count = 12
	wanted_types = list(/obj/item/stack/sheet/animalhide/corgi)

/datum/bounty/item/assistant/action_figures
	name = "Action Figures"
	description = "Syn wiceprezesa zobaczył na teleekranie reklamę figurek akcji i teraz nie przestaje o nich gadać. Wyślijcie kilka, by ukrócić jego narzekania."
	reward = 4000
	required_count = 5
	wanted_types = list(/obj/item/toy/figure)

/datum/bounty/item/assistant/tail_whip
	name = "Nine Tails whip"
	description = "Komandor Jackson szuka wspaniałego uzupełnienia swojej kolekcji egzotycznej broni. Sowicie wynagrodzi was za Kocią albo Jaszczurzą Dziewięciorzemienną."
	reward = 4000
	wanted_types = list(/obj/item/melee/chainofcommand/tailwhip)

/datum/bounty/item/assistant/dead_mice
	name = "Dead Mice"
	description = "Na Stacji 14 skończyły się liofilizowane myszy. Wyślijcie trochę świeżych, by ich woźny nie zastrajkował."
	reward = 5000
	required_count = 5
	wanted_types = list(/obj/item/food/deadmouse)
