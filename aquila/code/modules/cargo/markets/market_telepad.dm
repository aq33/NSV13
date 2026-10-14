// Black market (port of tgstation code/modules/cargo/markets/market_telepad.dm)

#define DEFAULT_RESTOCK_COST (MARKET_CRATE_VALUE * 3.375)
#define PLACE_ON_MARKET_COST (MARKET_PAYCHECK_LOWER * 1.2)
#define LTSRBT_MIN_PRICE MARKET_PAYCHECK_LOWER
#define LTSRBT_MAX_PRICE (MARKET_CRATE_VALUE * 50)
#define LTSRBT_MAX_MARKET_ITEMS 40

/obj/item/circuitboard/machine/ltsrbt
	name = "LTSRBT (Machine Board)"
	icon_state = "bluespacearray"
	build_path = /obj/machinery/ltsrbt
	req_components = list(
		/obj/item/stack/ore/bluespace_crystal = 2,
		/obj/item/stock_parts/subspace/ansible = 1,
		/obj/item/stock_parts/micro_laser = 1,
		/obj/item/stock_parts/scanning_module = 2)
	def_components = list(/obj/item/stack/ore/bluespace_crystal = /obj/item/stack/ore/bluespace_crystal/artificial)

/obj/machinery/ltsrbt
	name = "Long-To-Short-Range Bluespace Transceiver"
	desc = "LTSRBT to kompaktowa maszyna teleportacyjna do wysyłania i odbierania towarów na statku i poza nim.\nKorzysta z częstotliwości wykradzionych NT, więc prawie nie da się jej namierzyć.\nNiezbędna przy każdym nielegalnym handlu na statkach NT."
	icon = 'aquila/icons/obj/ltsrbt.dmi'
	icon_state = "ltsrbt_idle"
	circuit = /obj/item/circuitboard/machine/ltsrbt
	density = TRUE
	idle_power_usage = 200
	interaction_flags_atom = INTERACT_ATOM_ATTACK_HAND

	/// Divider for energy_usage_per_teleport.
	var/power_efficiency = 1
	/// Power used per teleported which gets divided by power_efficiency.
	var/energy_usage_per_teleport = 10000
	/// The time it takes for the machine to recharge before being able to send or receive items.
	var/recharge_time = 0
	/// Current recharge progress.
	COOLDOWN_DECLARE(recharge_cooldown)
	/// Base recharge time in seconds which is used to get recharge_time.
	var/base_recharge_time = 10 SECONDS
	/// Current /datum/market_purchase being received.
	var/datum/market_purchase/receiving
	/// Current /datum/market_purchase being sent to the target uplink.
	var/datum/market_purchase/transmitting
	/// Queue for purchases that the machine should receive and send.
	var/list/datum/market_purchase/queue = list()
	/// The name of the market item that we've set on the UI
	var/current_name = ""
	/// The desc of the market item that we've set on the UI
	var/current_desc = ""
	/// The price of the market item that we've set on the UI
	var/current_price = MARKET_CRATE_VALUE
	/**
	 * Attacking the machinery with enough credits will restock the markets, allowing for more/better items.
	 * The cost doubles each time this is done.
	 */
	var/static/restock_cost = DEFAULT_RESTOCK_COST

/obj/machinery/ltsrbt/Initialize(mapload)
	. = ..()
	SSmarket.telepads += src
	update_icon()

/obj/machinery/ltsrbt/Destroy()
	SSmarket.telepads -= src
	// Bye bye orders.
	if(length(SSmarket.telepads))
		for(var/datum/market_purchase/purchase in queue)
			SSmarket.queue_item(purchase)
		if(receiving)
			SSmarket.queue_item(receiving)
	queue = null
	receiving = null
	transmitting = null
	return ..()

/obj/machinery/ltsrbt/examine(mob/user)
	. = ..()
	if(!(machine_stat & NOPOWER))
		. += "<span class='info'>Mały wyświetlacz pokazuje:</span>"
		. += "<span class='notice'>Cena uzupełnienia rynku: <b>[restock_cost] kr</b>.</span>"
		. += "<span class='notice'>Opłata za wystawienie towaru: <b>[PLACE_ON_MARKET_COST] kr</b>.</span>"
		. += "<span class='notice'>Podatek od sprzedaży lokalnych towarów: <b>[MARKET_WITHHOLDING_TAX * 100]%</b>.</span>"
		. += "<span class='notice'>Otwórz i zamknij ręką, włóż przedmiot, a potem <b>prawy klik</b>, żeby wystawić go na rynek. Kredyty uzupełniają rynek.</span>"

/obj/machinery/ltsrbt/update_icon_state()
	. = ..()
	if(machine_stat & NOPOWER)
		icon_state = "ltsrbt_off"
	else
		icon_state = "ltsrbt[(receiving || length(queue) || occupant) ? "" : "_idle"]"

/obj/machinery/ltsrbt/update_overlays()
	. = ..()
	if(!state_open)
		. += "ltsrbt_closed"
	else
		var/mutable_appearance/overlay = mutable_appearance(icon, "ltsrbt_open")
		overlay.pixel_x -= 2
		overlay.pixel_y -= 1
		. += overlay

/obj/machinery/ltsrbt/attack_hand(mob/user, list/modifiers)
	. = ..()
	if(.)
		return
	if(!state_open)
		open_machine()
		density = TRUE
		playsound(src, 'sound/machines/oven/oven_open.ogg', 75, TRUE)
	else
		close_machine()
		playsound(src, 'sound/machines/oven/oven_close.ogg', 75, TRUE)
	return TRUE

/obj/machinery/ltsrbt/interact(mob/user)
	return

/obj/machinery/ltsrbt/close_machine(atom/movable/target)
	. = ..()
	if(occupant)
		current_name = occupant.name
		current_desc = occupant.desc
	update_icon()

/obj/machinery/ltsrbt/can_be_occupant(atom/movable/am)
	return isitem(am) && !am.anchored

/obj/machinery/ltsrbt/Exited(atom/movable/gone, direction)
	. = ..()
	if(gone == occupant)
		occupant = null
		current_price = initial(current_price)
		current_name = ""
		current_desc = ""
		update_icon()

/obj/machinery/ltsrbt/attack_hand_secondary(mob/user, list/modifiers)
	. = ..()
	if(. == SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN)
		return
	if(state_open)
		balloon_alert(user, "najpierw zamknij!")
		return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN
	if(!occupant)
		balloon_alert(user, "pusto!")
		return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN
	if(machine_stat & NOPOWER)
		balloon_alert(user, "brak zasilania!")
		return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN
	if(!COOLDOWN_FINISHED(src, recharge_cooldown))
		balloon_alert(user, "ładuje się!")
		return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN
	ui_interact(user)
	return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN

/obj/machinery/ltsrbt/attackby(obj/item/tool, mob/user, params)
	if(user.combat_mode || default_deconstruction_screwdriver(user, "ltsrbt_off", "ltsrbt_idle", tool) || default_deconstruction_crowbar(tool))
		return ..()

	var/creds_value = tool.get_item_credit_value()

	if(state_open)
		if(locate(/mob/living) in tool.GetAllContents())
			say("Wykryto żywą istotę, sprzedaż niemożliwa!")
			playsound(src, 'sound/machines/buzz-sigh.ogg', 40, FALSE)
			return TRUE
		if(!user.transferItemToLoc(tool, src))
			balloon_alert(user, "przykleiło się do ręki!")
			return TRUE
		balloon_alert(user, "załadowano")
		close_machine(tool)
		return TRUE
	else if(!creds_value)
		balloon_alert(user, "otwórz maszynę!")
		return TRUE

	if(machine_stat & NOPOWER)
		return TRUE

	if(creds_value < restock_cost)
		say("Za mało kredytów!")
		playsound(src, 'sound/machines/buzz-sigh.ogg', 40, FALSE)
		return TRUE

	if(istype(tool, /obj/item/holochip))
		var/obj/item/holochip/chip = tool
		chip.spend(restock_cost)
	else
		qdel(tool)
		if(creds_value != restock_cost)
			var/obj/item/holochip/change = new(loc, creds_value - restock_cost)
			user.put_in_hands(change)

	SSmarket.restock()
	restock_cost *= 2
	return TRUE

/obj/machinery/ltsrbt/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "LTSRBT", name)
		ui.open()

/obj/machinery/ltsrbt/ui_state(mob/user)
	if(!occupant || !COOLDOWN_FINISHED(src, recharge_cooldown))
		return GLOB.never_state //close it.
	return GLOB.default_state

/obj/machinery/ltsrbt/ui_static_data(mob/user)
	var/list/data = list()
	data["loaded_icon"] = occupant ? icon2base64(getFlatIcon(occupant, no_anim=TRUE)) : null
	data["min_price"] = LTSRBT_MIN_PRICE
	data["max_price"] = LTSRBT_MAX_PRICE
	return data

/obj/machinery/ltsrbt/ui_data(mob/user)
	var/list/data = list()
	data["name"] = current_name
	data["price"] = current_price
	data["desc"] = current_desc
	return data

/obj/machinery/ltsrbt/ui_act(action, list/params)
	. = ..()
	if(.)
		return
	switch(action)
		if("change_name")
			var/value = params["value"]
			if(!istext(value) || CHAT_FILTER_CHECK(value))
				return TRUE
			current_name = trim(strip_html_simple(value), MAX_NAME_LEN)
			return TRUE
		if("change_desc")
			var/value = params["value"]
			if(!istext(value) || CHAT_FILTER_CHECK(value))
				return TRUE
			current_desc = trim(strip_html_simple(value), MAX_MESSAGE_LEN)
			return TRUE
		if("change_price")
			var/value = params["value"]
			if(!isnum(value) || isnan(value))
				return
			current_price = clamp(round(value), LTSRBT_MIN_PRICE, LTSRBT_MAX_PRICE)
			return TRUE
		if("place_on_market")
			place_on_market(usr)
			return TRUE

/obj/machinery/ltsrbt/proc/place_on_market(mob/user)
	if(QDELETED(occupant))
		return
	if(locate(/mob/living) in occupant.GetAllContents())
		say("Wykryto żywą istotę, sprzedaż niemożliwa!")
		playsound(src, 'sound/machines/buzz-sigh.ogg', 40, FALSE)
		return
	var/datum/bank_account/account
	var/datum/market/our_market = SSmarket.markets[/datum/market/blackmarket]
	if(!IsAdminGhost(user))
		if(!isliving(user))
			return
		if(length(our_market.available_items[BLACKMARKET_CATEGORY_LOCAL_GOODS]) >= LTSRBT_MAX_MARKET_ITEMS)
			say("Lokalny rynek przesycony, najpierw coś kupcie!")
			playsound(src, 'sound/machines/buzz-sigh.ogg', 40, FALSE)
			return
		var/mob/living/living_user = user
		var/obj/item/card/id/card = living_user.get_idcard(TRUE)
		if(!(card?.registered_account))
			say("Nie wykryto konta bankowego do pobrania opłaty!")
			playsound(src, 'sound/machines/buzz-sigh.ogg', 40, FALSE)
			return
		if(!card.registered_account.adjust_money(-PLACE_ON_MARKET_COST))
			say("Za mało kredytów!")
			playsound(src, 'sound/machines/buzz-sigh.ogg', 40, FALSE)
			return
		account = card.registered_account

	var/obj/item/item = occupant //occupant, name, price and desc will be null'd once it exits the machine so we need this.
	var/name_to_use = current_name || item.name
	var/desc_to_use = current_desc
	if(account)
		desc_to_use += "[current_desc ? " - " : ""]Sprzedawca: [account.account_holder]"
	var/price_to_use = current_price
	item.moveToNullspace()
	//Something happened and the item was deleted or relocated as soon as it was moved to nullspace.
	if(QDELETED(item) || item.loc != null)
		say("Runtime at market_placement.dm, line 153: item gone!") //metajoke
		return
	var/datum/market_item/local_good/new_item = new(item, account)
	new_item.name = name_to_use
	new_item.desc = desc_to_use
	new_item.price = price_to_use

	our_market.add_item(new_item)

	say("Towar wystawiony na rynek!")
	playsound(src, 'sound/effects/cashregister.ogg', 40, FALSE)
	COOLDOWN_START(src, recharge_cooldown, recharge_time * 3)

/obj/machinery/ltsrbt/RefreshParts()
	recharge_time = base_recharge_time
	// On tier 4 recharge_time should be 20 and by default it is 80 as scanning modules should be tier 1.
	for(var/obj/item/stock_parts/scanning_module/scanning_module in component_parts)
		recharge_time -= scanning_module.rating * 1 SECONDS

	power_efficiency = 0
	for(var/obj/item/stock_parts/micro_laser/laser in component_parts)
		power_efficiency += laser.rating
	// Shouldn't happen but you never know.
	if(!power_efficiency)
		power_efficiency = 1

/// Adds /datum/market_purchase to queue unless the machine is free, then it sets the purchase to be instantly received
/obj/machinery/ltsrbt/proc/add_to_queue(datum/market_purchase/purchase)
	if(COOLDOWN_FINISHED(src, recharge_cooldown) && !receiving && !transmitting)
		receiving = purchase
		update_icon()
	else
		queue += purchase

	RegisterSignal(purchase, COMSIG_PARENT_QDELETING, PROC_REF(on_purchase_del))

/obj/machinery/ltsrbt/proc/on_purchase_del(datum/market_purchase/purchase)
	SIGNAL_HANDLER
	queue -= purchase
	if(receiving == purchase)
		receiving = null
	if(transmitting == purchase)
		transmitting = null

	update_icon()

/obj/machinery/ltsrbt/process(delta_time)
	if(machine_stat & NOPOWER)
		return

	if(!COOLDOWN_FINISHED(src, recharge_cooldown) && isnull(receiving) && isnull(transmitting))
		return

	var/turf/turf = get_turf(src)
	if(receiving)

		receiving.item = receiving.entry.spawn_item(turf, receiving)
		receiving.post_purchase_effects(receiving.item)

		use_power(energy_usage_per_teleport / power_efficiency)
		do_sparks(5, TRUE, src)
		transmitting = receiving
		receiving = null

		return
	if(transmitting)
		if(transmitting.item && transmitting.item.loc == turf)
			do_teleport(transmitting.item, get_turf(transmitting.uplink), no_effects = TRUE, channel = TELEPORT_CHANNEL_BLUESPACE)
			use_power(energy_usage_per_teleport / power_efficiency)
		QDEL_NULL(transmitting)
		COOLDOWN_START(src, recharge_cooldown, recharge_time)
		return

	if(length(queue))
		receiving = pick_n_take(queue)

#undef DEFAULT_RESTOCK_COST
#undef PLACE_ON_MARKET_COST
#undef LTSRBT_MIN_PRICE
#undef LTSRBT_MAX_PRICE
#undef LTSRBT_MAX_MARKET_ITEMS
