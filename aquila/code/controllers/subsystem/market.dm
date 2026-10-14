// Black market subsystem (port of tgstation code/controllers/subsystem/market.dm)

SUBSYSTEM_DEF(market)
	name = "Market"
	flags = SS_BACKGROUND
	init_order = INIT_ORDER_DEFAULT

	/// Descriptions for each shipping methods.
	var/shipping_method_descriptions = list(
		SHIPPING_METHOD_LAUNCH = "Wystrzeliwuje towar w stronę statku z kosmosu, z darmową dostawą. Po odbiór trzeba jednak wyjść w próżnię.",
		SHIPPING_METHOD_LTSRBT = "Long-To-Short-Range-Bluespace-Transceiver: maszyna, która odbiera towary spoza statku i teleportuje je w miejsce uplinku.",
		SHIPPING_METHOD_TELEPORT = "Teleportuje towar w losowe miejsce na statku. Masz 60 sekund, żeby dotrzeć tam pierwszy.",
		SHIPPING_METHOD_SUPPLYPOD = "Zrzuca towar kapsułą zaopatrzeniową dokładnie tam, gdzie stoisz. Efektownie, szybko i drogo.",
	)

	/// List of all existing markets.
	var/list/datum/market/markets = list()
	/// List of existing ltsrbts.
	var/list/obj/machinery/ltsrbt/telepads = list()
	/// Currently queued purchases.
	var/list/queued_purchases = list()

/datum/controller/subsystem/market/Initialize(timeofday)
	for(var/market in subtypesof(/datum/market))
		markets[market] += new market

	for(var/path in subtypesof(/datum/market_item))
		initialize_item(path)

	return ..()

/**
 * Follows the standard process for adding an item to the market from a path.
 * @param path The path of the market datum to initialize and add to the market.
 * @param market_whitelist A list of markets to which the item should be added. If null, the item is added to all markets.
 */
/datum/controller/subsystem/market/proc/initialize_item(datum/market_item/path, list/market_whitelist)
	if(!initial(path.item) || !prob(initial(path.availability_prob)))
		return
	var/datum/market_item/item_instance = new path()
	for(var/potential_market in item_instance.markets)
		if(!markets[potential_market])
			stack_trace("SSmarket: Item [item_instance] available in market that does not exist.")
			continue
		if(isnull(market_whitelist) || (potential_market in market_whitelist))
			markets[potential_market].add_item(item_instance)

/datum/controller/subsystem/market/fire(resumed)
	while(length(queued_purchases))
		var/datum/market_purchase/purchase = queued_purchases[1]
		queued_purchases.Cut(1,2)

		var/mob/buyer = recursive_loc_check(purchase.uplink.loc, /mob)

		switch(purchase.method)
			// Find a ltsrbt pad and make it handle the shipping.
			if(SHIPPING_METHOD_LTSRBT)
				if(!length(telepads))
					to_chat(buyer, "<span class='warning'>[purchase.uplink] wyświetla komunikat: brak LTSRBT, zamówienie anulowane.</span>")
					qdel(purchase)
					continue
				// Prioritize pads that don't have a cooldown active.
				var/obj/machinery/ltsrbt/lowest_cd_pad
				// The time left of the shortest cooldown amongst all telepads.
				var/lowest_timeleft = INFINITY
				for(var/obj/machinery/ltsrbt/pad as anything in telepads)
					if(!COOLDOWN_FINISHED(pad, recharge_cooldown) || (pad.machine_stat & NOPOWER))
						var/timeleft = pad.machine_stat & NOPOWER ? INFINITY - 1 : COOLDOWN_TIMELEFT(pad, recharge_cooldown)
						if(timeleft <= lowest_timeleft)
							lowest_cd_pad = pad
							lowest_timeleft = timeleft
						continue
					lowest_cd_pad = pad
					break

				lowest_cd_pad.add_to_queue(purchase)

				to_chat(buyer, "<span class='notice'>[purchase.uplink] wyświetla komunikat: zamówienie obsługuje [lowest_cd_pad].</span>")

			// Get random area, throw it somewhere there.
			if(SHIPPING_METHOD_TELEPORT)
				var/turf/targetturf = get_safe_random_station_turfs()
				// This shouldn't happen.
				if (!targetturf)
					to_chat(buyer, "<span class='warning'>[purchase.uplink] wyświetla komunikat: nie znaleziono miejsca dostawy, zamówienie anulowane.</span>")
					qdel(purchase)
					continue
				queued_purchases -= purchase

				to_chat(buyer, "<span class='notice'>[purchase.uplink] wyświetla komunikat: zamówienie zostanie teleportowane do [get_area(targetturf)] za 60 sekund.</span>")

				// do_teleport does not want to teleport items from nullspace, so it just forceMoves and does sparks.
				addtimer(CALLBACK(src, TYPE_PROC_REF(/datum/controller/subsystem/market, fake_teleport), purchase, targetturf), 60 SECONDS)

			// Get the current location of the uplink if it exists, then throws the item from space at the station from a random direction.
			if(SHIPPING_METHOD_LAUNCH)
				var/startSide = pick(GLOB.cardinals)
				var/turf/T = get_turf(purchase.uplink)
				var/pickedloc = spaceDebrisStartLoc(startSide, T.z)
				var/obj/delivery_pod = new /obj/structure/closet/crate(pickedloc)

				var/atom/movable/item = purchase.entry.spawn_item(delivery_pod, purchase)
				purchase.post_purchase_effects(item)
				delivery_pod.throw_at(purchase.uplink, 3, 3, spin = FALSE)

				to_chat(buyer, "<span class='notice'>[purchase.uplink] wyświetla komunikat: zamówienie leci w stronę statku od strony: [dir2text(startSide)].</span>")
				qdel(purchase)

			if(SHIPPING_METHOD_SUPPLYPOD)
				var/atom/movable/item = purchase.entry.spawn_item(null, purchase)
				purchase.post_purchase_effects(item)
				new /obj/effect/pod_landingzone(get_turf(purchase.uplink), /obj/structure/closet/supplypod/bluespacepod, item)

				to_chat(buyer, "<span class='notice'>[purchase.uplink] wyświetla komunikat: zamówienie leci prosto na ciebie. Tu i teraz!</span>")
				qdel(purchase)

		if(MC_TICK_CHECK)
			break

/// Used to make a teleportation effect as do_teleport does not like moving items from nullspace.
/datum/controller/subsystem/market/proc/fake_teleport(datum/market_purchase/purchase, turf/target)
	// Oopsie, whoopsie, the item is gone. So long, and thanks for all the money.
	if(QDELETED(purchase))
		return
	var/atom/movable/thing = purchase.entry.spawn_item(target, purchase)
	purchase.post_purchase_effects(thing)
	do_sparks(5, TRUE, target)
	qdel(purchase)

/// Used to add /datum/market_purchase to queued_purchases var. Returns TRUE when queued.
/datum/controller/subsystem/market/proc/queue_item(datum/market_purchase/purchase)
	if((purchase.method == SHIPPING_METHOD_LTSRBT && !telepads.len) || isnull(purchase.uplink))
		qdel(purchase)
		return FALSE
	queued_purchases += purchase
	return TRUE

///A proc that restocks one or more markets, or all if the market_whitelist is null.
/datum/controller/subsystem/market/proc/restock(list/market_whitelist)
	var/market_name = "Rynki"
	if(market_whitelist && !islist(market_whitelist))
		var/datum/market/market_path = market_whitelist
		market_name = initial(market_path.name)
		market_whitelist = list(market_path)

	var/list/existing_types = list()
	for(var/path in markets)
		if(isnull(market_whitelist) || (path in market_whitelist))
			markets[path].restock(existing_types)

	for(var/datum/market_item/path as anything in (subtypesof(/datum/market_item) - existing_types))
		if(!initial(path.restockable))
			continue
		initialize_item(path, market_whitelist)

	for(var/obj/machinery/ltsrbt/pad as anything in telepads)
		pad.say("[market_name]: dostawa uzupełniona!")
		playsound(pad, 'sound/effects/cashregister.ogg', 40, FALSE)
