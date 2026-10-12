/**********************Mining Equipment Vendor**************************/

/obj/machinery/vendor
	name = "equipment vendor"
	processing_flags = START_PROCESSING_MANUALLY
	subsystem_type = /datum/controller/subsystem/processing/fastprocess
	density = TRUE

	var/icon_deny
	var/obj/item/card/id/inserted_id
	var/list/prize_list = list()

/obj/machinery/vendor/Initialize(mapload)
	. = ..()
	build_inventory()

/obj/machinery/vendor/proc/build_inventory()
	for(var/p in prize_list)
		var/datum/data/vendor_equipment/M = p
		GLOB.vending_products[M.equipment_path] = 1

/obj/machinery/vendor/power_change()
	..()
	update_icon()

/obj/machinery/vendor/update_icon()
	if(powered())
		icon_state = initial(icon_state)
	else
		icon_state = "[initial(icon_state)]-off"

/obj/machinery/vendor/ui_assets(mob/user)
	return list(
		get_asset_datum(/datum/asset/spritesheet/vending),
	)


/obj/machinery/vendor/ui_state(mob/user)
	return GLOB.default_state

/obj/machinery/vendor/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "MiningVendor")
		ui.open()

/obj/machinery/vendor/ui_static_data(mob/user)
	. = list()
	.["product_records"] = list()
	for(var/datum/data/vendor_equipment/prize in prize_list)
		var/list/product_data = list(
			path = replacetext(replacetext("[prize.equipment_path]", "/obj/item/", ""), "/", "-"),
			name = prize.equipment_name,
			price = prize.cost,
			ref = REF(prize)
		)
		.["product_records"] += list(product_data)

/obj/machinery/vendor/ui_data(mob/user)
	. = list()
	var/mob/living/carbon/human/H
	var/obj/item/card/id/C
	.["user"] = null
	if(ishuman(user))
		H = user
		C = H.get_idcard(TRUE)
		if(C)
			.["user"] = list()
			.["user"]["points"] = get_points(C)
			if(C.registered_account)
				.["user"]["name"] = C.registered_account.account_holder
				if(C.registered_account.account_job)
					.["user"]["job"] = C.registered_account.account_job.title
				else
					.["user"]["job"] = "No Job"

/obj/machinery/vendor/ui_act(action, params)
	if(..())
		return

	switch(action)
		if("purchase")
			var/mob/M = usr
			var/obj/item/card/id/I = M.get_idcard(TRUE)
			if(!istype(I))
				to_chat(usr, "<span class='alert'>Błąd: wymagany identyfikator!</span>")
				flick(icon_deny, src)
				return
			var/datum/data/vendor_equipment/prize = locate(params["ref"]) in prize_list
			if(!prize || !(prize in prize_list))
				to_chat(usr, "<span class='alert'>Błąd: nieprawidłowy wybór!</span>")
				flick(icon_deny, src)
				return
			if(prize.cost > get_points(I))
				to_chat(usr, "<span class='alert'>Błąd: za mało punktów na [prize.equipment_name] na [I]!</span>")
				flick(icon_deny, src)
				return
			subtract_points(I, prize.cost)
			to_chat(usr, "<span class='notice'>[src] na chwilę ożywa ze szczękiem, po czym wydaje [prize.equipment_name]!</span>")
			new prize.equipment_path(loc)
			SSblackbox.record_feedback("nested tally", "mining_equipment_bought", 1, list("[type]", "[prize.equipment_path]"))
			. = TRUE

/obj/machinery/vendor/attackby(obj/item/I, mob/user, params)
	if(default_deconstruction_screwdriver(user, "mining-open", "mining", I))
		return
	if(default_deconstruction_crowbar(I))
		return
	return ..()

/obj/machinery/vendor/ex_act(severity, target)
	do_sparks(5, TRUE, src)
	if(prob(50 / severity) && severity < 3)
		qdel(src)

/obj/machinery/vendor/proc/subtract_points(obj/item/card/id/I, amount)
	I.mining_points -= amount

/obj/machinery/vendor/proc/get_points(obj/item/card/id/I)
	return I.mining_points

/obj/machinery/vendor/mining
	name = "mining equipment vendor"
	desc = "An equipment vendor for miners, points collected at an ore redemption machine can be spent here."
	icon = 'icons/obj/machines/mining_machines.dmi'
	icon_state = "mining"
	density = TRUE
	circuit = /obj/item/circuitboard/machine/mining_equipment_vendor

	icon_deny = "mining-deny"

	// NSV13 - removed various combat and lavaland things, re-added the jetpack, added cryofuel
	prize_list = list( //if you add something to this, please, for the love of god, sort it by price/type. use tabs and not spaces.
		new /datum/data/vendor_equipment("1 znacznik",				/obj/item/stack/marker_beacon,										5),
		new /datum/data/vendor_equipment("10 znaczników",			/obj/item/stack/marker_beacon/ten,									75),
		new /datum/data/vendor_equipment("30 znaczników",			/obj/item/stack/marker_beacon/thirty,								150),
		new /datum/data/vendor_equipment("Kapsuła schronienia",				/obj/item/survivalcapsule,											400),
		//new /datum/data/vendor_equipment("Regen. Core Stabilizer",		/obj/item/hivelordstabilizer,										400),
		//new /datum/data/vendor_equipment("Skeleton Key",				/obj/item/skeleton_key,												750),
		new /datum/data/vendor_equipment("Medipen przetrwania",			/obj/item/reagent_containers/hypospray/medipen/survival,			500),
		new /datum/data/vendor_equipment("Zestaw leczenia obrażeń fizycznych",			/obj/item/storage/firstaid/brute,									600),
		new /datum/data/vendor_equipment("Zestaw leczenia oparzeń",			/obj/item/storage/firstaid/fire,									600),
		new /datum/data/vendor_equipment("Zaawansowany zestaw leczniczy",		/obj/item/storage/firstaid/advanced,								1200),
		new /datum/data/vendor_equipment("Nadajnik Fultona",				/obj/item/fulton_core,												500),
		new /datum/data/vendor_equipment("Pakiet ewakuacyjny Fultona",		/obj/item/extraction_pack,											1000),
		new /datum/data/vendor_equipment("Jaunter",						/obj/item/wormhole_jaunter,											750),
		new /datum/data/vendor_equipment("Zaawansowany skaner rudy",		/obj/item/t_scanner/adv_mining_scanner,								800),
		new /datum/data/vendor_equipment("Explorer's Webbing",			/obj/item/storage/belt/mining,										500),
		//new /datum/data/vendor_equipment("Jump Boots",					/obj/item/clothing/shoes/bhop,										2000),
		new /datum/data/vendor_equipment("Proto-kinetyczna kruszarka",		/obj/item/kinetic_crusher,											800),
		new /datum/data/vendor_equipment("Proto-kinetyczny akcelerator",	/obj/item/gun/energy/kinetic_accelerator,							500),
		new /datum/data/vendor_equipment("Resonator",					/obj/item/resonator,												750),
		new /datum/data/vendor_equipment("Ulepszony rezonator",			/obj/item/resonator/upgraded,										1500),
		new /datum/data/vendor_equipment("Srebrny kilof",				/obj/item/pickaxe/silver,											500),
		new /datum/data/vendor_equipment("Diamentowy kilof",				/obj/item/pickaxe/diamond,											1000),
		new /datum/data/vendor_equipment("Towarzysz – robot górniczy",		/mob/living/simple_animal/hostile/mining_drone,						800),
		//new /datum/data/vendor_equipment("Minebot Upgrade: Armor",		/obj/item/minebot_upgrade/health,									400),
		new /datum/data/vendor_equipment("Ulepszenie minebota: szufla do rudy",	/obj/item/minebot_upgrade/ore_pickup,								400),
		new /datum/data/vendor_equipment("Ulepszenie minebota: odnowienie",	/obj/item/borg/upgrade/modkit/cooldown/minebot,						600),
		new /datum/data/vendor_equipment("Ulepszenie minebota: medyczne",	/obj/item/minebot_upgrade/medical,									800),
		new /datum/data/vendor_equipment("Ulepszenie minebota: SI",		/obj/item/slimepotion/slime/sentience/mining,						1000),
		//new /datum/data/vendor_equipment("Minebot Weatherproof Chassis",/obj/item/minebot_upgrade/antiweather,								1200),
		new /datum/data/vendor_equipment("Ulepszenie P-KA: przyjazny botom",	/obj/item/borg/upgrade/modkit/minebot_passthrough,					100),
		new /datum/data/vendor_equipment("Ulepszenie P-KA: pociski smugowe",	/obj/item/borg/upgrade/modkit/tracer,								200),
		new /datum/data/vendor_equipment("Ulepszenie P-KA: regul. pociski smugowe",	/obj/item/borg/upgrade/modkit/tracer/adjustable,					300),
		new /datum/data/vendor_equipment("Ulepszenie P-KA: zasięg",			/obj/item/borg/upgrade/modkit/range,								1000),
		//new /datum/data/vendor_equipment("P-KA Upgrade: Damage",		/obj/item/borg/upgrade/modkit/damage,								1000),
		new /datum/data/vendor_equipment("Ulepszenie P-KA: odnowienie",		/obj/item/borg/upgrade/modkit/cooldown,								1000),
		//new /datum/data/vendor_equipment("P-KA Upgrade: Damage Radius",	/obj/item/borg/upgrade/modkit/aoe/mobs,								2000),
		new /datum/data/vendor_equipment("Kosmetyczny super kadłub P-KA",	/obj/item/borg/upgrade/modkit/chassis_mod,							200),
		new /datum/data/vendor_equipment("Kosmetyczny hiper kadłub P-KA",	/obj/item/borg/upgrade/modkit/chassis_mod/orange,					200),
		new /datum/data/vendor_equipment("Górniczy hardsuit",				/obj/item/clothing/suit/space/hardsuit/mining,						2000),
		new /datum/data/vendor_equipment("Powiększona awaryjna butla tlenowa",		/obj/item/tank/internals/emergency_oxygen/engi,						1000),
		new /datum/data/vendor_equipment("Ulepszenie plecaka odrzutowego",				/obj/item/tank/jetpack/suit,										2000),
		new /datum/data/vendor_equipment("Mining Conscription Kit",		/obj/item/storage/backpack/duffelbag/mining_conscript,				1000),
		new /datum/data/vendor_equipment("Nóż survivalowy",				/obj/item/kitchen/knife/combat/survival,							1000),
		new /datum/data/vendor_equipment("Zestaw implantów śledzących", 		/obj/item/storage/box/minertracker,									1000),
		new /datum/data/vendor_equipment("Karta transferu punktów",			/obj/item/card/mining_point_card,									500),
		new /datum/data/vendor_equipment("Mezony GAR",					/obj/item/clothing/glasses/meson/gar,								500),
		//new /datum/data/vendor_equipment("Luxury Shelter Capsule",		/obj/item/survivalcapsule/luxury,									3000),
		//new /datum/data/vendor_equipment("Mining Outpost Capsule",		/obj/item/survivalcapsule/encampment,								5000),
		new /datum/data/vendor_equipment("Luksusowa kapsuła z barem",			/obj/item/survivalcapsule/luxuryelite,								10000),
		new /datum/data/vendor_equipment("Iniektor Łazarza",			/obj/item/lazarus_injector,											1000),
		new /datum/data/vendor_equipment("1000 kosmicznych kredytów",				/obj/item/stack/spacecash/c1000,									2000),
		new /datum/data/vendor_equipment("Pizza",						/obj/item/pizzabox/margherita,										200),
		new /datum/data/vendor_equipment("Whiskey",						/obj/item/reagent_containers/food/drinks/bottle/whiskey,			100),
		new /datum/data/vendor_equipment("Absinthe",					/obj/item/reagent_containers/food/drinks/bottle/absinthe/premium,	100),
		new /datum/data/vendor_equipment("Cigar",						/obj/item/clothing/mask/cigarette/cigar/havana,						150),
		new /datum/data/vendor_equipment("Soap",						/obj/item/soap/nanotrasen,											200),
		new /datum/data/vendor_equipment("Wskaźnik laserowy",				/obj/item/laser_pointer,											300),
		new /datum/data/vendor_equipment("Zabawkowy obcy",					/obj/item/clothing/mask/facehugger/toy,								300),
		new /datum/data/vendor_equipment("Kriogeniczny zbiornik paliwa",			/obj/structure/reagent_dispensers/fueltank/cryogenic_fuel,			10000),
		)

/datum/data/vendor_equipment
	var/equipment_name = "generic"
	var/equipment_path = null
	var/cost = 0

/datum/data/vendor_equipment/New(name, path, cost)
	src.equipment_name = name
	src.equipment_path = path
	src.cost = cost

/obj/machinery/vendor/mining/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/mining_voucher))
		RedeemVoucher(I, user)
		return
	return ..()

/obj/machinery/vendor/mining/proc/RedeemVoucher(obj/item/mining_voucher/voucher, mob/redeemer)
	var/items = list("Survival Capsule and Explorer's Webbing", "Resonator Kit", "Minebot Kit", "Extraction and Rescue Kit", "Crusher Kit", "Mining Conscription Kit")

	var/selection = input(redeemer, "Wybierz swój sprzęt", "Wymiana bonu górniczego") as null|anything in sortList(items)
	if(!selection || !Adjacent(redeemer) || QDELETED(voucher) || voucher.loc != redeemer)
		return
	var/drop_location = drop_location()
	switch(selection)
		if("Survival Capsule and Explorer's Webbing")
			new /obj/item/storage/belt/mining/vendor(drop_location)
		if("Resonator Kit")
			new /obj/item/storage/firstaid/brute(drop_location)
			new /obj/item/resonator(drop_location)
		if("Minebot Kit")
			new /mob/living/simple_animal/hostile/mining_drone(drop_location)
			new /obj/item/weldingtool/hugetank(drop_location)
			new /obj/item/clothing/head/welding(drop_location)
			new /obj/item/borg/upgrade/modkit/minebot_passthrough(drop_location)
		if("Extraction and Rescue Kit")
			new /obj/item/extraction_pack(drop_location)
			new /obj/item/fulton_core(drop_location)
			new /obj/item/stack/marker_beacon/thirty(drop_location)
		if("Crusher Kit")
			new /obj/item/extinguisher/mini(drop_location)
			new /obj/item/kinetic_crusher(drop_location)
		if("Mining Conscription Kit")
			new /obj/item/storage/backpack/duffelbag/mining_conscript(drop_location)

	SSblackbox.record_feedback("tally", "mining_voucher_redeemed", 1, selection)
	qdel(voucher)

/****************Golem Point Vendor**************************/

/obj/machinery/vendor/mining/golem
	name = "golem ship equipment vendor"
	circuit = /obj/item/circuitboard/machine/mining_equipment_vendor/golem

/obj/machinery/vendor/mining/golem/Initialize(mapload)
	. = ..()
	desc += "\nWygląda na to, że dodano kilka nowych opcji."
	prize_list += list(
		new /datum/data/vendor_equipment("Dodatkowy identyfikator",       				/obj/item/card/id/mining, 				                   		250),
		new /datum/data/vendor_equipment("Gogle naukowe",       		/obj/item/clothing/glasses/science,								250),
		new /datum/data/vendor_equipment("Kostka małpia",					/obj/item/food/monkeycube,        	300),
		new /datum/data/vendor_equipment("Toolbelt",					/obj/item/storage/belt/utility,	    							350),
		new /datum/data/vendor_equipment("Królewska peleryna Wyzwoliciela", /obj/item/bedsheet/rd/royal_cape, 								500),
		new /datum/data/vendor_equipment("Szary ekstrakt szlamu",			/obj/item/slime_extract/grey,									1000),
		new /datum/data/vendor_equipment("Ulepszenie P-KA: modyfikacja spustu",	/obj/item/borg/upgrade/modkit/trigger_guard,					1000),
		new /datum/data/vendor_equipment("Spuścizna Wyzwoliciela",  	/obj/item/storage/box/rndboards,								2000)
		)

/**********************Mining Equipment Vendor Items**************************/

/**********************Mining Equipment Voucher**********************/

/obj/item/mining_voucher
	name = "mining voucher"
	desc = "A token to redeem a piece of equipment. Use it on a mining equipment vendor."
	icon = 'icons/obj/mining.dmi'
	icon_state = "mining_voucher"
	w_class = WEIGHT_CLASS_TINY

/**********************Mining Point Card**********************/

/obj/item/card/mining_point_card
	name = "mining points card"
	desc = "A small card preloaded with mining points. Swipe your ID card over it to transfer the points, then discard."
	icon_state = "data_1"
	var/points = 500

/obj/item/card/mining_point_card/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/card/id))
		if(points)
			var/obj/item/card/id/C = I
			C.mining_points += points
			to_chat(user, "<span class='info'>Przekazujesz [C] punkty: [points].</span>")
			points = 0
		else
			to_chat(user, "<span class='info'>Na [src] nie zostały żadne punkty.</span>")
	..()

/obj/item/card/mining_point_card/examine(mob/user)
	. = ..()
	. += "<span class='info'>Na karcie są punkty: [points].</span>"

///Conscript kit
/obj/item/card/id/pass/mining_access_card
	name = "mining access card"
	desc = "A small card, that when used on any ID, will add mining access."
	access = list(ACCESS_MINING, ACCESS_MINING_STATION, ACCESS_MECH_MINING, ACCESS_MINERAL_STOREROOM, ACCESS_CARGO)

/obj/item/storage/backpack/duffelbag/mining_conscript
	name = "mining conscription kit"
	desc = "A kit containing everything a crewmember needs to support a shaft miner in the field."

/obj/item/storage/backpack/duffelbag/mining_conscript/PopulateContents()
	new /obj/item/pickaxe/mini(src)
	new /obj/item/clothing/glasses/meson(src)
	new /obj/item/t_scanner/adv_mining_scanner/lesser(src)
	new /obj/item/storage/bag/ore(src)
	new /obj/item/clothing/suit/space/hardsuit/mining(src)
	new /obj/item/encryptionkey/headset_cargo(src)
	new /obj/item/clothing/mask/gas/explorer(src)
	new /obj/item/card/id/pass/mining_access_card(src)
