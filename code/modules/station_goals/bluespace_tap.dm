//Station goal stuff goes here
/datum/station_goal/bluespace_tap
	name = "Bluespace Harvester"
	var/goal = 45000

/datum/station_goal/bluespace_tap/get_report()
	return list(
	"<blockquote><b>Bluespace Harvester Experiment</b>",
	"Inna stacja badawcza opracowała urządzenie zwane Kombajnem Bluespace.",
	"Sięga ono przez bluespace do innych wymiarów, by przeczesywać je w poszukiwaniu ciekawych obiektów.",
	"Z powodu nieprzewidzianych okoliczności test prototypu na dużą skalę nie mógł zostać przeprowadzony na pierwotnej stacji badawczej. Zamiast tego zostanie przeprowadzony na waszej stacji.",
	"Zdobądźcie płytkę, zbudujcie urządzenie na węźle przewodów i dostarczcie mu dość energii, by do końca zmiany wygenerowało [goal] pkt górniczych.",
	"",
	"Uwaga: urządzenie jest eksperymentalne i przy wystarczającym zasilaniu może zachowywać się w nieco nieprzewidziany sposób.",
	"Dyrektoriat Naukowy Nanotrasen</blockquote>",
	).Join("\n")

/datum/station_goal/bluespace_tap/on_report()
	var/datum/supply_pack/engineering/bluespace_tap/P = SSshuttle.supply_packs[/datum/supply_pack/engineering/bluespace_tap]
	P.special_enabled = TRUE

/datum/station_goal/bluespace_tap/check_completion()
	if(..())
		return TRUE
	var/highscore = 0
	for(var/obj/machinery/power/bluespace_tap/T in GLOB.machines)
		highscore = max(highscore, T.total_points)
	to_chat(world, "<b>Rekord Kombajnu Bluespace</b>: [highscore >= goal ? "<span class='greenannounce'>": "<span class='boldannounce'>"][highscore]</span>")
	if(highscore >= goal)
		return TRUE
	return FALSE

//needed for the vending part of it
/datum/data/bluespace_tap_product
	var/product_name = "generic"
	var/product_path = null
	var/product_cost = 100	//cost in mining points to generate


/datum/data/bluespace_tap_product/New(name, path, cost)
	product_name = name
	product_path = path
	product_cost = cost

/obj/item/circuitboard/machine/bluespace_tap
	name = "Bluespace Harvester"
	icon_state = "command"
	build_path = /obj/machinery/power/bluespace_tap
	req_components = list(
							/obj/item/stock_parts/capacitor/quadratic = 5,//Probably okay, right?
							/obj/item/stack/ore/bluespace_crystal = 5)

/obj/effect/spawner/lootdrop/bluespace_tap
	name = "bluespace harvester reward spawner"
	lootcount = 1

/obj/effect/spawner/lootdrop/bluespace_tap/hat
	name = "exotic hat"
	loot = list(
			/obj/item/clothing/head/collectable/chef,	//same weighing on all of them
			/obj/item/clothing/head/collectable/paper,
			/obj/item/clothing/head/collectable/tophat,
			/obj/item/clothing/head/collectable/captain,
			/obj/item/clothing/head/collectable/beret,
			/obj/item/clothing/head/collectable/welding,
			/obj/item/clothing/head/collectable/flatcap,
			/obj/item/clothing/head/collectable/pirate,
			/obj/item/clothing/head/collectable/kitty,
			/obj/item/clothing/head/crown/fancy,
			/obj/item/clothing/head/collectable/rabbitears,
			/obj/item/clothing/head/collectable/wizard,
			/obj/item/clothing/head/collectable/hardhat,
			/obj/item/clothing/head/collectable/HoS,
			/obj/item/clothing/head/collectable/thunderdome,
			/obj/item/clothing/head/collectable/swat,
			/obj/item/clothing/head/collectable/slime,
			/obj/item/clothing/head/collectable/police,
			/obj/item/clothing/head/collectable/slime,
			/obj/item/clothing/head/collectable/xenom,
			/obj/item/clothing/head/collectable/petehat
	)


/obj/effect/spawner/lootdrop/bluespace_tap/cultural
	name = "cultural artifacts"
	loot = list(
		/obj/item/grenade/clusterbuster/cleaner = 10,
		/obj/item/grenade/clusterbuster/soap = 10,
		/obj/item/toy/katana = 10,
		/obj/item/stack/sheet/iron/twenty = 15,
		/obj/item/stack/sheet/glass/fifty = 10,
		/obj/item/stack/sheet/mineral/copper/twenty = 20,
		/obj/item/sord = 20,
		/obj/item/toy/syndicateballoon = 15,
		/obj/item/lighter/greyscale = 5,
		/obj/item/lighter = 5,
		/obj/item/gun/ballistic/automatic/toy/pistol = 1,
		/obj/item/gun/ballistic/automatic/c20r/toy = 1,
		/obj/item/gun/ballistic/automatic/l6_saw/toy = 1,
		/obj/item/gun/ballistic/shotgun/toy = 1,
		/obj/item/gun/ballistic/shotgun/toy/crossbow = 1,
		/obj/item/dualsaber/toy = 5,
		/obj/machinery/smoke_machine = 10,
		/obj/item/clothing/head/kitty = 5,
		/obj/item/coin/antagtoken = 5,
		/obj/item/clothing/suit/cardborg = 10,
		/obj/item/toy/prize/honk = 10,
		/obj/item/bedsheet/patriot = 2,
		/obj/item/bedsheet/rainbow = 2,
		/obj/item/bedsheet/captain = 2,
		/obj/item/bedsheet/centcom = 1, //mythic rare rarity
		/obj/item/bedsheet/syndie = 2,
		/obj/item/bedsheet/cult = 2,
		/obj/item/bedsheet/wiz = 2,
		/obj/item/clothing/gloves/combat = 5
	)

/obj/effect/spawner/lootdrop/bluespace_tap/organic
	name = "organic objects"
	loot = list(
		/obj/item/seeds/random = 10,
		/obj/item/storage/pill_bottle/charcoal = 25,
		/obj/item/storage/pill_bottle/mannitol = 25,
		/obj/item/storage/pill_bottle/mutadone = 25,
		/obj/item/dnainjector/telemut = 5,
		/obj/item/dnainjector/chameleonmut = 5,
		/obj/item/dnainjector/dwarf = 5,
		/mob/living/simple_animal/pet/dog/corgi/ = 5,
		/mob/living/simple_animal/pet/cat = 5,
		/mob/living/simple_animal/pet/dog/bullterrier = 5,
		/mob/living/simple_animal/pet/penguin = 5,
		/mob/living/simple_animal/parrot = 5,
		/obj/item/slimepotion/slime/sentience = 5,
		/obj/item/clothing/mask/cigarette/cigar/havana = 3,
		/obj/item/stack/sheet/mineral/bananium/five = 10,	//bananas are organic, clearly.
		/obj/item/storage/box/monkeycubes = 5,
		/obj/item/stack/tile/carpet/black/fifty = 10,
		/obj/item/stack/tile/carpet/blue/thirtytwo = 10,
		/obj/item/stack/tile/carpet/cyan/thirtytwo = 10,
		/obj/item/soap/deluxe = 5
	)

/obj/effect/spawner/lootdrop/bluespace_tap/food
	name = "fancy food"
	lootcount = 3
	loot = list(
		/obj/item/food/burger/crab,
		/obj/item/food/crab_rangoon,
		/obj/item/food/scotchegg,
		/obj/item/food/pancakes/chocolatechip,
		/obj/item/food/carrotfries,
		/obj/item/food/chocolatebunny,
		/obj/item/food/benedict,
		/obj/item/food/cornedbeef,
		/obj/item/food/soup/meatball,
		/obj/item/food/soup/monkeysdelight,
		/obj/item/food/soup/stew,
		/obj/item/food/soup/hotchili,
		/obj/item/food/burrito,
		/obj/item/food/burger/fish,
		/obj/item/food/cubancarp,
		/obj/item/food/fishandchips,
		/obj/item/food/pie/meatpie,
		/obj/item/pizzabox,
	)

#define kW *1000
#define MW kW *1000
#define GW MW *1000

/**
  * # Bluespace Harvester
  *
  * A station goal that consumes enormous amounts of power to generate (mostly fluff) rewards
  *
  * A machine that takes power each tick, generates points based on it
  * and lets you spend those points on rewards. A certain amount of points
  * has to be generated for the station goal to count as completed.
  */
/obj/machinery/power/bluespace_tap
	name = "Bluespace harvester"
	icon = 'icons/obj/machines/bluespace_tap.dmi'
	icon_state = "bluespace_tap"	//sprites by Ionward
	max_integrity = 300
	pixel_x = -32	//shamelessly stolen from dna vault
	pixel_y = -64
	/// For faking having a big machine, dummy 'machines' that are hidden inside the large sprite and make certain tiles dense. See new and destroy.
	var/list/obj/structure/fillers = list()
	use_power = NO_POWER_USE	// power usage is handelled manually
	density = TRUE
	luminosity = 1

	/// Correspond to power required for a mining level, first entry for level 1, etc.
	var/list/power_needs = list(1 kW, 5 kW, 50 kW, 100 kW, 500 kW,
								1 MW, 2 MW, 5 MW, 10 MW, 25 MW,
								50 MW, 75 MW, 125 MW, 200 MW, 500 MW,
								1 GW, 5 GW, 15 GW, 45 GW, 500 GW)

	/// list of possible products
	var/static/product_list = list(
	new /datum/data/bluespace_tap_product("Unknown Exotic Hat", /obj/effect/spawner/lootdrop/bluespace_tap/hat, 5000),
	new /datum/data/bluespace_tap_product("Unknown Snack", /obj/effect/spawner/lootdrop/bluespace_tap/food, 6000),
	new /datum/data/bluespace_tap_product("Unknown Cultural Artifact", /obj/effect/spawner/lootdrop/bluespace_tap/cultural, 15000),
	new /datum/data/bluespace_tap_product("Unknown Biological Artifact", /obj/effect/spawner/lootdrop/bluespace_tap/organic, 20000)
	)

	/// The level the machine is currently mining at. 0 means off
	var/input_level = 0
	/// The machine you WANT the machine to mine at. It will try to match this.
	var/desired_level = 0
	/// Available mining points
	var/points = 0
	/// The total points earned by this machine so far, for tracking station goal and highscore
	var/total_points = 0
	/// How much power the machine needs per processing tick at the current level.
	var/actual_power_usage = 0


	// Tweak these and active_power_usage to balance power generation

	/// Max power input level, I don't expect this to be ever reached
	var/max_level = 20
	/// Amount of points to give per mining level
	var/base_points = 4
	/// How high the machine can be run before it starts having a chance for dimension breaches.
	var/safe_levels = 10
	var/emagged = FALSE

/obj/machinery/power/bluespace_tap/New()
	..()
	//more code stolen from dna vault, inculding comment below. Taking bets on that datum being made ever.
	//TODO: Replace this,bsa and gravgen with some big machinery datum
	var/list/occupied = list()
	for(var/direct in list(EAST, WEST, SOUTHEAST, SOUTHWEST))
		occupied += get_step(src, direct)
	occupied += locate(x + 1, y - 2, z)
	occupied += locate(x - 1, y - 2, z)

	for(var/T in occupied)
		var/obj/structure/filler/F = new(T)
		F.parent = src
		fillers += F
	component_parts = list()
	component_parts += new /obj/item/circuitboard/machine/bluespace_tap(null)
	for(var/i = 1 to 5)	//five of each
		component_parts += new /obj/item/stock_parts/capacitor/quadratic(null)
		component_parts += new /obj/item/stack/ore/bluespace_crystal(null)
	if(!powernet)
		connect_to_network()

/obj/machinery/power/bluespace_tap/Destroy()
	QDEL_LIST(fillers)
	return ..()

/**
  * Increases the desired mining level
  *
  * Increases the desired mining level, that
  * the machine tries to reach if there
  * is enough power for it. Note that it does
  * NOT increase the actual mining level directly.
  */
/obj/machinery/power/bluespace_tap/proc/increase_level()
	if(desired_level < max_level)
		desired_level++
/**
  * Decreases the desired mining level
  *
  * Decreases the desired mining level, that
  * the machine tries to reach if there
  * is enough power for it. Note that it does
  * NOT decrease the actual mining level directly.
  */
/obj/machinery/power/bluespace_tap/proc/decrease_level()
	if(desired_level > 0)
		desired_level--

/**
  * Sets the desired mining level
  *
  * Sets the desired mining level, that
  * the machine tries to reach if there
  * is enough power for it. Note that it does
  * NOT change the actual mining level directly.
  * Arguments:
  * * t_level - The level we try to set it at, between 0 and max_level
 */
/obj/machinery/power/bluespace_tap/proc/set_level(t_level)
	if(t_level < 0)
		return
	if(t_level > max_level)
		return
	desired_level = t_level

/**
  * Gets the amount of power at a set input level
  *
  * Gets the amount of power (in W) a set input level needs.
  * Note that this is not necessarily the current power use.
  * * i_level - The hypothetical input level for which we want to know the power use.
  */
/obj/machinery/power/bluespace_tap/proc/get_power_use(i_level)
	if(!i_level)
		return 0
	return power_needs[i_level]

/obj/machinery/power/bluespace_tap/process()
	actual_power_usage = get_power_use(input_level)
	if(surplus() < actual_power_usage)	//not enough power, so turn down a level
		input_level--
		return	// and no mining gets done
	if(actual_power_usage)
		add_load(actual_power_usage)
		var/points_to_add = (input_level + emagged) * base_points
		points += points_to_add	//point generation, emagging gets you 'free' points at the cost of higher anomaly chance
		total_points += points_to_add
	// actual input level changes slowly
	if(input_level < desired_level && (surplus() >= get_power_use(input_level + 1)))
		input_level++
	else if(input_level > desired_level)
		input_level--
	if(prob(input_level - safe_levels + (emagged * 5)))	//at dangerous levels, start doing freaky shit. prob with values less than 0 treat it as 0
		priority_announce("Nieoczekiwany skok mocy podczas pracy Kombajnu Bluespace. Alarm: intruz z innego wymiaru. Spodziewana lokalizacja: [get_area_name(src)]. [emagged ? "NIEBEZPIECZEŃSTWO: awaryjne wyłączenie nie powiodło się! Przeprowadźcie ręczne wyłączenie." : "Rozpoczęto awaryjne wyłączenie."]", "Awaria Kombajnu Bluespace",sound = SSstation.announcer.get_rand_report_sound())
		if(!emagged)
			input_level = 0	//emergency shutdown unless we're sabotaged
			desired_level = 0
		for(var/i in 1 to rand(1, 3))
			var/turf/location = locate(x + rand(-5, 5), y + rand(-5, 5), z)
			new /obj/structure/spawner/nether/bluespace_tap(location)



/obj/machinery/power/bluespace_tap/ui_data(mob/user)
	var/list/data = list()

	data["desiredLevel"] = desired_level
	data["inputLevel"] = input_level
	data["points"] = points
	data["totalPoints"] = total_points
	data["powerUse"] = actual_power_usage
	data["availablePower"] = surplus()
	data["maxLevel"] = max_level
	data["emagged"] = emagged
	data["safeLevels"] = safe_levels
	data["nextLevelPower"] = get_power_use(input_level + 1)

	/// A list of lists, each inner list equals a datum
	var/list/listed_items = list()
	for(var/key = 1 to length(product_list))
		var/datum/data/bluespace_tap_product/A = product_list[key]
		listed_items[++listed_items.len] = list(
				"key" = key,
				"name" = A.product_name,
				"price" = A.product_cost)
	data["product"] = listed_items
	return data


/obj/machinery/power/bluespace_tap/attack_hand(mob/user, list/modifiers)
	add_fingerprint(user)
	ui_interact(user)

/obj/machinery/power/bluespace_tap/attack_ghost(mob/user)
	ui_interact(user)

/obj/machinery/power/bluespace_tap/attack_ai(mob/user)
	ui_interact(user)

/**
  * Produces the product with the desired key and increases product cost accordingly
  */
/obj/machinery/power/bluespace_tap/proc/produce(key)
	if(key <= 0 || key > length(product_list))	//invalid key
		return
	var/datum/data/bluespace_tap_product/A = product_list[key]
	if(!A)
		return
	if(A.product_cost > points)
		return
	points -= A.product_cost
	A.product_cost = round(1.2 * A.product_cost, 1)
	playsound(src, 'sound/magic/blink.ogg', 50)
	do_sparks(2, FALSE, src)
	new A.product_path(get_turf(src))



//UI stuff below

/obj/machinery/power/bluespace_tap/ui_act(action, params)
	if(..())
		return
	. = TRUE	// we want to refresh in all the cases below
	switch(action)
		if("decrease")
			decrease_level()
		if("increase")
			increase_level()
		if("set")
			set_level(text2num(params["set_level"]))
		if("vend")//it's not really vending as producing, but eh
			var/key = text2num(params["target"])
			produce(key)

/obj/machinery/power/bluespace_tap/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "BluespaceTap", "Bluespace Harvester")
		ui.open()

//emaging provides slightly more points but at much greater risk
/obj/machinery/power/bluespace_tap/emag_act(mob/living/user as mob)
	if(emagged)
		return
	emagged = TRUE
	do_sparks(5, FALSE, src)
	if(user)
		user.visible_message("<span class='warning'>[user] obchodzi protokoły bezpieczeństwa [src].</span>", "<span class='warning'>Obchodzisz protokoły bezpieczeństwa.</span>")

/obj/structure/spawner/nether/bluespace_tap
	spawn_time = 30 SECONDS
	max_mobs = 5		//Dont' want them overrunning the station
	max_integrity = 250

/obj/structure/spawner/nether/bluespace_tap/deconstruct(disassembled)
	new /obj/item/stack/ore/bluespace_crystal(loc)	//have a reward
	return ..()

/obj/item/paper/bluespace_tap
	name = "paper- 'The Experimental NT Bluespace Harvester - Mining other universes for science and profit!'"
	default_raw_text = "<h1>Ważne instrukcje!</h1>Postępuj zgodnie ze wszystkimi instrukcjami montażu, by zapewnić prawidłowe działanie. <br>1. Utwórz węzeł przewodu z dużym dostępem do zapasowej mocy. Urządzenie działa niezależnie od APC. <br>2. Zbuduj na węźle przewodu zwykłą ramę maszyny, uwzględniając wymiary urządzenia (3 na 3 metry). <br>3. Włóż okablowanie, płytkę i wymagane komponenty i dokończ budowę zgodnie ze standardami inżynieryjnymi NT. <br>4. Upewnij się, że urządzenie jest podłączone do właściwej sieci energetycznej, a sieć ma dość mocy. <br>5. Ustaw maszynę na żądany poziom. Okresowo sprawdzaj postęp maszyny. <br>6. Opcjonalnie wydaj zdobyte punkty na zabawne i ekscytujące nagrody. <br><hr><h2>Zasady działania</h2> <p>Kombajn Bluespace potrafi przyjąć niemal nieograniczoną ilość mocy, by przeszukiwać inne wszechświaty w poszukiwaniu cennych rzeczy do odzyskania. Szybkość wyszukiwania reguluje się „poziomem” urządzenia. Choć na niskim poziomie może go zasilać niemal każdy system wytwarzania energii, wyższe poziomy wymagają pracy oddanego zespołu inżynieryjnego. Ponieważ interesuje nas, jak urządzenie radzi sobie pod obciążeniem, zachęcamy do testów obciążeniowych i sprawdzenia, ile mocy jesteście w stanie mu dostarczyć. Z tego powodu łączna produkcja punktów w trakcie zmiany zostanie obliczona i ogłoszona na jej końcu. Wysokie wyniki mogą skutkować premiami dla członków działu inżynieryjnego. <p><p>Dyrektoriat Naukowy NT, Grupa Badawcza Eksploatacji Międzywymiarowej</p> <p><small>Urządzenie wysoce eksperymentalne. Nie na sprzedaż. Nie używać w pobliżu małych dzieci ani ważnych zasobów NT. Nie ingerować w maszynę. W razie egzystencjalnego lęku natychmiast zatrzymać maszynę. Prosimy dokumentować wszelkie wtargnięcia z innych wymiarów. W razie bliskiej śmierci prosimy zostawić tę dokumentację na widoku, by mogły ją odzyskać ekipy sprzątające.</small></p>"

#undef kW
#undef MW
#undef GW
