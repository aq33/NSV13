// Black market goods (port of tgstation code/modules/cargo/markets/market_items/*), only the items we have

// Clothing

/datum/market_item/clothing
	category = BLACKMARKET_CATEGORY_CLOTHING
	abstract_path = /datum/market_item/clothing

/datum/market_item/clothing/ninja_mask
	name = "Maska kosmicznego ninja"
	desc = "Udawaj kosmicznego ninja i bij się z kim popadnie w tej masce."
	item = /obj/item/clothing/mask/gas/ninja
	price_min = MARKET_CRATE_VALUE
	price_max = MARKET_CRATE_VALUE * 2.5
	stock_max = 3
	availability_prob = 40

/datum/market_item/clothing/durathread_vest
	name = "Kamizelka z duranitki"
	desc = "Nie rozdawajcie tego taniej, niż to warte. Kamizelka z duranitki, mocna jak nowa."
	item = /obj/item/clothing/suit/armor/vest/durathread
	price_min = MARKET_CRATE_VALUE
	price_max = MARKET_CRATE_VALUE * 2
	stock_max = 4
	availability_prob = 50

/datum/market_item/clothing/durathread_helmet
	name = "Hełm z duranitki"
	desc = "Wyglądaj na zdrowo opancerzonego, wydając na to grosze."
	item = /obj/item/clothing/head/helmet/durathread
	price_min = MARKET_CRATE_VALUE * 0.5
	price_max = MARKET_CRATE_VALUE
	stock_max = 4
	availability_prob = 50

/datum/market_item/clothing/full_spacesuit_set
	name = "Pełny skafander"
	desc = "Nikt nie zauważy, że zniknęło kilka skafandrów z jednego z ich statków. Pudełko z logo NT."
	item = /obj/item/storage/box
	price_min = MARKET_CRATE_VALUE * 1.875
	price_max = MARKET_CRATE_VALUE * 4
	stock_max = 3
	availability_prob = 30

/datum/market_item/clothing/full_spacesuit_set/spawn_item(loc, datum/market_purchase/purchase)
	var/obj/item/storage/box/B = ..()
	B.name = "pudełko ze skafandrem"
	B.desc = "Ma na sobie logo NT."
	new /obj/item/clothing/suit/space(B)
	new /obj/item/clothing/head/helmet/space(B)
	return B

/datum/market_item/clothing/bhop_shoes
	name = "Buty odrzutowe"
	desc = "Buty z silniczkami do szybkich skoków. Ostatni właściciel nie potrzebuje ich już do niczego."
	item = /obj/item/clothing/shoes/bhop
	price_min = MARKET_CRATE_VALUE * 3
	price_max = MARKET_CRATE_VALUE * 6
	stock_max = 1
	availability_prob = 40

// Consumables

/datum/market_item/consumable
	category = BLACKMARKET_CATEGORY_CONSUMABLES
	abstract_path = /datum/market_item/consumable

/datum/market_item/consumable/clown_tears
	name = "Butelka łez klauna"
	desc = "Wyciśnięte świeżo z prawdziwego klauna."
	item = /obj/item/reagent_containers/glass/bottle/clownstears
	stock = 1
	price_min = MARKET_CRATE_VALUE * 2.6
	price_max = MARKET_CRATE_VALUE * 3
	availability_prob = 10

/datum/market_item/consumable/donk_pocket_box
	name = "Pudełko donk pocketów"
	desc = "Pudełko pysznych donk pocketów, od bazy przez pizzę aż po owocowe."
	item = /obj/item/storage/box/donkpockets
	stock_min = 2
	stock_max = 5
	price_min = MARKET_CRATE_VALUE * 1.375
	price_max = MARKET_CRATE_VALUE * 1.825
	availability_prob = 80

/datum/market_item/consumable/donk_pocket_box/spawn_item(loc, datum/market_purchase/purchase)
	item = pick(typesof(/obj/item/storage/box/donkpockets))
	return ..()

/datum/market_item/consumable/suspicious_pills
	name = "Butelka podejrzanych pigułek"
	desc = "Losowy koktajl luksusowych dragów, które na pewno wywołają uśmiech na twarzy!"
	item = /obj/item/storage/pill_bottle
	stock_min = 2
	stock_max = 3
	price_min = MARKET_CRATE_VALUE * 0.625
	price_max = MARKET_CRATE_VALUE * 1.25
	availability_prob = 50

/datum/market_item/consumable/suspicious_pills/spawn_item(loc, datum/market_purchase/purchase)
	item = pick(list(/obj/item/storage/pill_bottle/zoom,
		/obj/item/storage/pill_bottle/happy,
		/obj/item/storage/pill_bottle/lsd,
		/obj/item/storage/pill_bottle/aranesp,
		/obj/item/storage/pill_bottle/stimulant,
	))
	return ..()

/datum/market_item/consumable/pumpup
	name = "Pump-Up uliczny"
	desc = "Wstrzyknij sobie adrenalinę i nie przejmuj się krwawieniem i ranami!"
	item = /obj/item/reagent_containers/hypospray/medipen/pumpup
	stock_max = 3
	price_min = MARKET_CRATE_VALUE * 0.25
	price_max = MARKET_CRATE_VALUE * 0.75
	availability_prob = 90

// Miscellaneous

/datum/market_item/misc
	category = BLACKMARKET_CATEGORY_MISC
	abstract_path = /datum/market_item/misc

/datum/market_item/misc/clear_pda
	name = "Przezroczyste PDA"
	desc = "Pochwal się stylem z tym limitowanym, przezroczystym PDA!"
	item = /obj/item/modular_computer/tablet/pda/clear
	price_min = MARKET_CRATE_VALUE * 1.25
	price_max = MARKET_CRATE_VALUE * 3
	stock_max = 2
	availability_prob = 50

/datum/market_item/misc/cap_gun
	name = "Pistolet na kapiszony"
	desc = "Zrób kolegom kawał tym nieszkodliwym pistoletem! Nieszkodliwość gwarantowana."
	item = /obj/item/toy/gun
	price_min = MARKET_CRATE_VALUE * 0.25
	price_max = MARKET_CRATE_VALUE
	stock_max = 6
	availability_prob = 80

/datum/market_item/misc/shoulder_holster
	name = "Kabura"
	desc = "Pierwszy krok do marzeń o byciu detektywem, któremu wolno strzelać prawdziwą bronią!"
	item = /obj/item/clothing/accessory/holster
	price_min = MARKET_CRATE_VALUE * 2
	price_max = MARKET_CRATE_VALUE * 4
	stock_max = 8
	availability_prob = 60

/datum/market_item/misc/holywater
	name = "Butelka wody święconej"
	desc = "Woda święcona z niepewnego źródła. Nikt nie pytał, kto ją święcił."
	item = /obj/item/reagent_containers/food/drinks/bottle/holywater
	price_min = MARKET_CRATE_VALUE * 2
	price_max = MARKET_CRATE_VALUE * 3
	stock_max = 3
	availability_prob = 40

/datum/market_item/misc/strange_seed
	name = "Dziwne nasiona"
	desc = "Egzotyczne nasiona nieznanego pochodzenia."
	item = /obj/item/seeds/random
	price_min = MARKET_CRATE_VALUE * 1.6
	price_max = MARKET_CRATE_VALUE * 1.8
	stock_min = 2
	stock_max = 5
	availability_prob = 50

/datum/market_item/misc/smugglers_satchel
	name = "Torba przemytnika"
	desc = "Płaska torba, którą da się schować pod podłogą. Pytania o zawartość nie są mile widziane."
	item = /obj/item/storage/backpack/satchel/flat
	price_min = MARKET_CRATE_VALUE * 3.75
	price_max = MARKET_CRATE_VALUE * 5
	stock_max = 2
	availability_prob = 30

/datum/market_item/misc/tanner
	name = "Moduł opalania do MOD"
	desc = "Zawsze chciałeś być jednocześnie na plaży i w pracy? Teraz możesz, z tym modułem opalania!"
	item = /obj/item/mod/module/tanner
	price_min = MARKET_CRATE_VALUE * 2
	price_max = MARKET_CRATE_VALUE * 3
	stock_max = 2
	availability_prob = 30

/datum/market_item/misc/hat_stabilizer
	name = "Stabilizator kapelusza do MOD"
	desc = "Nie poświęcaj stylu dla wygody. Kapelusz nie jest w zestawie."
	item = /obj/item/mod/module/hat_stabilizer
	price_min = MARKET_CRATE_VALUE * 2
	price_max = MARKET_CRATE_VALUE * 3
	stock_max = 2
	availability_prob = 35

// Tools

/datum/market_item/tool
	category = BLACKMARKET_CATEGORY_TOOLS
	abstract_path = /datum/market_item/tool

/datum/market_item/tool/blackmarket_telepad
	name = "Płytka LTSRBT"
	desc = "Potrzebujesz szybszego i lepszego sposobu dostarczania nielegalnego towaru na statek? \
		Long-To-Short-Range-Bluespace-Transceiver przyjdzie z pomocą. \
		W zestawie płytka LTSRBT. Kryształy bluespace i ansible nie są w zestawie."
	item = /obj/item/circuitboard/machine/ltsrbt
	stock_min = 2
	stock_max = 4
	price_min = MARKET_CRATE_VALUE * 2.5
	price_max = MARKET_CRATE_VALUE * 3.25
	availability_prob = 100

/datum/market_item/tool/caravan_wrench
	name = "Eksperymentalny klucz"
	desc = "Klucz zrobiony przez kupców z karawan. Kręci szybciej niż zwykły."
	item = /obj/item/wrench/caravan
	stock = 1
	price_min = MARKET_CRATE_VALUE * 2
	price_max = MARKET_CRATE_VALUE * 4
	availability_prob = 20

/datum/market_item/tool/caravan_wirecutters
	name = "Eksperymentalne przecinaki"
	desc = "Przecinaki zrobione przez kupców z karawan. Tną szybciej niż zwykłe."
	item = /obj/item/wirecutters/caravan
	stock = 1
	price_min = MARKET_CRATE_VALUE * 2
	price_max = MARKET_CRATE_VALUE * 4
	availability_prob = 20

/datum/market_item/tool/caravan_screwdriver
	name = "Eksperymentalny śrubokręt"
	desc = "Śrubokręt zrobiony przez kupców z karawan. Kręci szybciej niż zwykły."
	item = /obj/item/screwdriver/caravan
	stock = 1
	price_min = MARKET_CRATE_VALUE * 2
	price_max = MARKET_CRATE_VALUE * 4
	availability_prob = 20

/datum/market_item/tool/caravan_crowbar
	name = "Eksperymentalny łom"
	desc = "Łom zrobiony przez kupców z karawan. Podważa szybciej niż zwykły."
	item = /obj/item/crowbar/red/caravan
	stock = 1
	price_min = MARKET_CRATE_VALUE * 2
	price_max = MARKET_CRATE_VALUE * 4
	availability_prob = 20

/datum/market_item/tool/binoculars
	name = "Lornetka"
	desc = "Patrz dalej i szybciej niż inni, z tą lornetką!"
	item = /obj/item/binoculars
	stock = 1
	price_min = MARKET_CRATE_VALUE * 1.75
	price_max = MARKET_CRATE_VALUE * 4
	availability_prob = 30

/datum/market_item/tool/riot_shield
	name = "Tarcza prewencyjna"
	desc = "Chroń się przed zamieszkami, które sam wywołasz."
	item = /obj/item/shield/riot
	price_min = MARKET_CRATE_VALUE * 2.25
	price_max = MARKET_CRATE_VALUE * 3.25
	stock_max = 2
	availability_prob = 50

/datum/market_item/tool/sechud
	name = "Okulary z HUD-em ochrony"
	desc = "Okulary przeciwsłoneczne z HUD-em ochrony, prosto z magazynu zbrojowni. Nikt nie liczył."
	item = /obj/item/clothing/glasses/hud/security/sunglasses
	price_min = MARKET_CRATE_VALUE * 2
	price_max = MARKET_CRATE_VALUE * 3.5
	stock_max = 3
	availability_prob = 50

// Weapons

/datum/market_item/weapon
	category = BLACKMARKET_CATEGORY_WEAPONS
	abstract_path = /datum/market_item/weapon

/datum/market_item/weapon/bear_trap
	name = "Sidła na niedźwiedzie"
	desc = "Zaskocz każdego tymi sidłami na niedźwiedzie. Niedźwiedź niewliczony."
	item = /obj/item/restraints/legcuffs/beartrap
	price_min = MARKET_CRATE_VALUE * 1.5
	price_max = MARKET_CRATE_VALUE * 2.75
	stock_max = 3
	availability_prob = 40

/datum/market_item/weapon/chainsaw
	name = "Piła łańcuchowa"
	desc = "Drewno w kosmosie to rzadkość, ale ta piła tnie też inne rzeczy."
	item = /obj/item/chainsaw
	price_min = MARKET_CRATE_VALUE * 1.75
	price_max = MARKET_CRATE_VALUE * 3
	stock_max = 1
	availability_prob = 35

/datum/market_item/weapon/switchblade
	name = "Nóż sprężynowy"
	desc = "Klasyczny nóż sprężynowy. Wygląda niewinnie, dopóki nie wyskoczy ostrze."
	item = /obj/item/switchblade
	price_min = MARKET_CRATE_VALUE * 1.25
	price_max = MARKET_CRATE_VALUE * 1.75
	stock_max = 3
	availability_prob = 45

/datum/market_item/weapon/emp_grenade
	name = "Granat EMP"
	desc = "Użyj tego granatu, żeby UPORAĆ SIĘ z elektroniką w okolicy."
	item = /obj/item/grenade/empgrenade
	price_min = MARKET_CRATE_VALUE * 0.5
	price_max = MARKET_CRATE_VALUE * 2
	stock_max = 2
	availability_prob = 50
