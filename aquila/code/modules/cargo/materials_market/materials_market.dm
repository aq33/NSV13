// AQUILA - galaktyczny rynek materiałów z tgstation (code/modules/cargo/materials_market.dm)
// Sprzedaż: włóż stos arkuszy, dostajesz stock block z ceną zamrożoną na 3 minuty, potem cena „płynie” z rynkiem.
// Kupno: zamówienie z prywatnego konta albo budżetu zaopatrzenia, przylatuje najbliższym promem.

/// Maksymalna liczba pełnych stosów w jednym zamówieniu
#define MAX_STACK_LIMIT 10
/// Ranga, po której rozpoznajemy zamówienia z rynku na liście zakupów
#define GALACTIC_MATERIAL_ORDER "Galaktyczny Rynek Materiałów"

/obj/machinery/materials_market
	name = "galactic materials market"
	desc = "Maszyna do kupna i sprzedaży arkuszy minerałów w całym układzie. \
		Ceny potrafią się zmieniać bardzo często, czasem nawet w ciągu minuty. Wszystkie transakcje są ostateczne."
	icon = 'aquila/icons/obj/economy/bounty_market.dmi'
	icon_state = "mat_market"
	base_icon_state = "mat_market"
	circuit = /obj/item/circuitboard/machine/materials_market
	density = TRUE
	idle_power_usage = 10
	active_power_usage = 100
	light_power = 1
	light_range = 2
	light_color = "#7FFFD4"
	/// Kupujemy z własnej karty (TRUE) czy z budżetu zaopatrzenia
	var/ordering_private = TRUE

/obj/machinery/materials_market/Initialize(mapload)
	. = ..()
	update_light_state()

/obj/machinery/materials_market/update_icon_state()
	if(panel_open)
		icon_state = "[base_icon_state]_open"
	else if(!is_operational || !anchored)
		icon_state = "[base_icon_state]_off"
	else
		icon_state = base_icon_state
	return ..()

/obj/machinery/materials_market/power_change()
	. = ..()
	update_light_state()
	update_appearance()

/obj/machinery/materials_market/proc/update_light_state()
	if(is_operational && anchored)
		set_light(initial(light_range), initial(light_power))
	else
		set_light(0)

/obj/machinery/materials_market/wrench_act(mob/living/user, obj/item/tool)
	. = TRUE
	if(default_unfasten_wrench(user, tool, 15) == SUCCESSFUL_UNFASTEN)
		update_light_state()
		update_appearance()

/obj/machinery/materials_market/attackby(obj/item/I, mob/living/user, params)
	if(default_deconstruction_screwdriver(user, "[base_icon_state]_open", base_icon_state, I))
		update_appearance()
		return TRUE
	if(default_deconstruction_crowbar(I))
		return TRUE
	if(istype(I, /obj/item/stack))
		sell_stack(I, user)
		return TRUE
	return ..()

/// Zamienia stos arkuszy na stock block po aktualnej cenie
/obj/machinery/materials_market/proc/sell_stack(obj/item/stack/exportable, mob/living/user)
	if(!is_operational)
		balloon_alert(user, "brak zasilania!")
		return FALSE
	if(length(exportable.materials) != 1)
		balloon_alert(user, "tylko czyste materiały!")
		return FALSE
	var/datum/material/sold_material = exportable.materials[1]
	var/price = get_market_price(sold_material)
	if(!price)
		balloon_alert(user, "rynek tego nie kupi!")
		return FALSE
	var/sheets = round(exportable.materials[sold_material] * exportable.amount / MINERAL_MATERIAL_AMOUNT)
	if(sheets < 1)
		balloon_alert(user, "za mało materiału!")
		return FALSE
	if(!user.transferItemToLoc(exportable, src))
		to_chat(user, "<span class='warning'>[exportable] przykleiło ci się do ręki!</span>")
		return FALSE

	var/obj/item/stock_block/new_block = new /obj/item/stock_block(drop_location())
	new_block.set_up(sold_material.type, sheets, price)
	to_chat(user, "<span class='notice'>Powstał stock block wart [price * sheets] kr! Sprzedaj go, zanim jego cena zacznie płynąć!</span>")
	playsound(src, 'sound/machines/synth_yes.ogg', 50, FALSE)
	qdel(exportable)
	use_power(active_power_usage)
	return TRUE

/// Szuka zamówienia z rynku dla danego płatnika (null = budżet zaopatrzenia)
/obj/machinery/materials_market/proc/find_order(datum/bank_account/paying_account)
	for(var/datum/supply_order/order as anything in SSshuttle.shoppinglist)
		if(order.orderer_rank != GALACTIC_MATERIAL_ORDER)
			continue
		if(order.paying_account == paying_account)
			return order
	return null

/obj/machinery/materials_market/ui_state(mob/user)
	return GLOB.default_state

/obj/machinery/materials_market/ui_interact(mob/user, datum/tgui/ui)
	if(!anchored)
		return
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "MatMarket", name)
		ui.open()

/// Czy ta karta może płacić budżetem zaopatrzenia
/obj/machinery/materials_market/proc/can_use_budget(obj/item/card/id/id_card)
	return id_card && (ACCESS_CARGO in id_card.GetAccess())

/obj/machinery/materials_market/ui_data(mob/user)
	var/list/data = list()

	var/obj/item/card/id/used_id_card = user.get_idcard(TRUE)
	var/can_buy_via_budget = can_use_budget(used_id_card)
	var/is_ordering_private = ordering_private || !can_buy_via_budget

	var/datum/bank_account/account_payable = is_ordering_private ? used_id_card?.registered_account : SSeconomy.get_dep_account(ACCOUNT_CAR)
	var/datum/supply_order/disposable/materials/current_order
	if(account_payable)
		current_order = find_order(is_ordering_private ? account_payable : null)

	var/list/material_data = list()
	for(var/datum/material/traded_mat as anything in SSstock_market.materials_prices)
		var/trend_string
		switch(SSstock_market.materials_trends[traded_mat])
			if(MARKET_TREND_STABLE)
				trend_string = "neutral"
			if(MARKET_TREND_UPWARD)
				trend_string = "up"
			else
				trend_string = "down"

		var/color_string = initial(traded_mat.color) || initial(traded_mat.greyscale_colors) || "#00FFFF"
		color_string = copytext(color_string, 1, 8)

		var/sheet_to_buy = initial(traded_mat.sheet_type)
		var/requested_amount = 0
		if(current_order && sheet_to_buy)
			requested_amount = current_order.pack.contains[sheet_to_buy] || 0

		material_data += list(list(
			"name" = initial(traded_mat.name),
			"price" = SSstock_market.materials_prices[traded_mat],
			"rarity" = initial(traded_mat.market_value),
			"min_threshold" = SSstock_market.price_minimum(traded_mat),
			"max_threshold" = SSstock_market.price_maximum(traded_mat),
			"quantity" = SSstock_market.materials_quantity[traded_mat],
			"trend" = trend_string,
			"color" = color_string,
			"requested" = requested_amount,
		))

	data["materials"] = material_data
	data["creditBalance"] = account_payable ? account_payable.account_balance : 0
	data["orderBalance"] = current_order ? current_order.get_final_cost() : 0
	data["orderingPrive"] = is_ordering_private
	data["canOrderCargo"] = can_buy_via_budget
	data["hasId"] = used_id_card ? TRUE : FALSE
	data["updateTime"] = max(0, SSstock_market.next_fire - world.time)
	return data

/obj/machinery/materials_market/ui_act(action, params)
	. = ..()
	if(.)
		return
	if(!is_operational || !isliving(usr))
		return

	var/mob/living/living_user = usr
	var/obj/item/card/id/used_id_card = living_user.get_idcard(TRUE)
	if(isnull(used_id_card))
		say("Nie znaleziono karty identyfikacyjnej.")
		return
	var/can_buy_via_budget = can_use_budget(used_id_card)
	var/is_ordering_private = ordering_private || !can_buy_via_budget

	switch(action)
		if("buy")
			buy_material(living_user, used_id_card, params["material"], text2num(params["quantity"]), is_ordering_private)
			return TRUE
		if("toggle_budget")
			if(!can_buy_via_budget)
				return
			ordering_private = !ordering_private
			return TRUE
		if("clear")
			var/datum/bank_account/account_payable = is_ordering_private ? used_id_card.registered_account : SSeconomy.get_dep_account(ACCOUNT_CAR)
			if(!account_payable)
				return
			var/datum/supply_order/current_order = find_order(is_ordering_private ? account_payable : null)
			if(current_order)
				SSshuttle.shoppinglist -= current_order
				qdel(current_order)
				return TRUE

/obj/machinery/materials_market/proc/buy_material(mob/living/user, obj/item/card/id/used_id_card, material_name, quantity, is_ordering_private)
	quantity = round(quantity)
	if(!quantity || quantity < 1)
		return FALSE

	var/datum/material/material_bought
	for(var/datum/material/mat as anything in SSstock_market.materials_prices)
		if(initial(mat.name) == material_name)
			material_bought = mat
			break
	if(!material_bought)
		return FALSE
	var/sheet_to_buy = initial(material_bought.sheet_type)
	if(!sheet_to_buy)
		return FALSE

	var/datum/bank_account/account_payable = is_ordering_private ? used_id_card.registered_account : SSeconomy.get_dep_account(ACCOUNT_CAR)
	if(!account_payable)
		say("Nie wykryto konta bankowego!")
		return FALSE

	if(quantity > SSstock_market.materials_quantity[material_bought])
		say("Na rynku nie ma tyle tego materiału!")
		return FALSE

	var/unit_price = SSstock_market.materials_prices[material_bought]
	var/cost = unit_price * quantity

	var/datum/supply_order/disposable/materials/current_order = find_order(is_ordering_private ? account_payable : null)
	if(current_order)
		var/datum/supply_pack/custom/minerals/pack = current_order.pack
		var/prior_sheets = pack.contains[sheet_to_buy] || 0
		if(prior_sheets + quantity > SSstock_market.materials_quantity[material_bought])
			say("Na rynku nie ma tyle arkuszy! Poczekaj, aż ktoś coś sprzeda, zanim dorzucisz więcej.")
			playsound(src, 'sound/machines/synth_no.ogg', 35, FALSE)
			return FALSE
		if(pack.total_stacks() >= MAX_STACK_LIMIT)
			say("W zamówieniu jest już [MAX_STACK_LIMIT] stosów! Poczekaj na dostawę, zanim zamówisz więcej.")
			playsound(src, 'sound/machines/synth_no.ogg', 35, FALSE)
			return FALSE
		if(current_order.get_final_cost() + cost > account_payable.account_balance)
			say("Zamówienie przekracza dostępne środki! Wyślij je, zanim dokupisz więcej.")
			return FALSE
		pack.add_sheets(sheet_to_buy, material_bought, quantity, unit_price)
		return TRUE

	var/datum/supply_pack/custom/minerals/mineral_pack = new(is_ordering_private ? user.real_name : "Zaopatrzenie")
	mineral_pack.add_sheets(sheet_to_buy, material_bought, quantity, unit_price)
	var/datum/supply_order/disposable/materials/new_order = new(mineral_pack, user.real_name, GALACTIC_MATERIAL_ORDER, user.ckey, "Galaktyczny rynek materiałów", is_ordering_private ? account_payable : null)
	if(new_order.get_final_cost() > account_payable.account_balance)
		say("Za mało środków, by złożyć zamówienie!")
		qdel(new_order)
		return FALSE

	say("Dziękujemy za zakup! Towar przyleci najbliższym promem zaopatrzenia.")
	SSshuttle.shoppinglist += new_order
	return TRUE

/obj/item/circuitboard/machine/materials_market
	name = "galactic materials market (Machine Board)"
	icon_state = "supply"
	build_path = /obj/machinery/materials_market
	req_components = list(
		/obj/item/stack/sheet/glass = 1,
		/obj/item/stock_parts/scanning_module = 1,
		/obj/item/stock_parts/micro_laser = 1,
	)
	needs_anchored = FALSE

/// Zamówienie, które usuwa swoją paczkę razem ze sobą
/datum/supply_order/disposable

/datum/supply_order/disposable/Destroy(force)
	QDEL_NULL(pack)
	return ..()

/// Zamówienie z rynku materiałów
/datum/supply_order/disposable/materials

/// Paczka z arkuszami zamówionymi na rynku; zawartość podaje się przy zamówieniu
/datum/supply_pack/custom/minerals
	name = "materials order"
	crate_name = "skrzynia dostawy z galaktycznego rynku materiałów"
	access = FALSE
	cost = 0
	crate_type = /obj/structure/closet/crate
	/// Typ arkusza => typ materiału
	var/list/sheet_materials = list()
	/// Typ arkusza => zapłacona cena za arkusz
	var/list/sheet_prices = list()

/datum/supply_pack/custom/minerals/New(purchaser)
	. = ..()
	// bez kupującego to tylko szablon tworzony przez SSshuttle - pusty contains trzyma go z dala od konsoli zaopatrzenia
	if(!purchaser)
		return
	name = "Zamówienie materiałów: [purchaser]"
	contains = list()

/datum/supply_pack/custom/minerals/get_cost()
	return cost

/datum/supply_pack/custom/minerals/proc/add_sheets(sheet_type, datum/material/mat, quantity, unit_price)
	contains[sheet_type] = (contains[sheet_type] || 0) + quantity
	sheet_materials[sheet_type] = mat
	sheet_prices[sheet_type] = unit_price
	cost += unit_price * quantity

/// Ile pełnych stosów jest w zamówieniu
/datum/supply_pack/custom/minerals/proc/total_stacks()
	. = 0
	for(var/obj/item/stack/sheet_type as anything in contains)
		. += CEILING(contains[sheet_type] / initial(sheet_type.max_amount), 1)

/// Rozlicza zamówienie z rynkiem: zmniejsza podaż, podbija cenę i zwraca pieniądze za arkusze, których zabrakło
/datum/supply_pack/custom/minerals/proc/adjust_market(datum/bank_account/paying_account)
	var/refund = 0
	for(var/obj/item/stack/sheet_type as anything in contains.Copy())
		var/datum/material/mat = sheet_materials[sheet_type]
		var/market_quantity = SSstock_market.materials_quantity[mat] || 0
		var/available_quantity = contains[sheet_type]
		if(available_quantity > market_quantity)
			refund += (available_quantity - market_quantity) * sheet_prices[sheet_type]
			available_quantity = market_quantity
			if(!available_quantity)
				contains -= sheet_type
				continue
		contains[sheet_type] = available_quantity

		// cena rośnie, gdy materiału na rynku zostaje mało
		var/fraction = available_quantity
		if(market_quantity != available_quantity)
			fraction /= (market_quantity - available_quantity)
		SSstock_market.adjust_material_price(mat, SSstock_market.materials_prices[mat] * fraction)
		SSstock_market.adjust_material_quantity(mat, -available_quantity)

	if(refund)
		var/datum/bank_account/refund_account = paying_account || SSeconomy.get_dep_account(ACCOUNT_CAR)
		refund_account?.adjust_money(refund)
		refund_account?.bank_card_talk("Na rynku zabrakło części zamówionych arkuszy. Zwrot: [refund] kr.")

/datum/supply_pack/custom/minerals/generate(atom/A, datum/bank_account/paying_account)
	adjust_market(paying_account)
	return ..()

/datum/supply_pack/custom/minerals/fill(obj/structure/closet/crate/C)
	for(var/obj/item/stack/sheet_type as anything in contains)
		var/sheets_to_spawn = contains[sheet_type]
		var/max_stack = initial(sheet_type.max_amount)
		while(sheets_to_spawn > 0)
			var/spawn_quantity = min(sheets_to_spawn, max_stack)
			new sheet_type(C, spawn_quantity)
			sheets_to_spawn -= spawn_quantity

/// Stock block: arkusze sprzedane na rynku, do wysłania promem zaopatrzenia
/obj/item/stock_block
	name = "stock block"
	desc = "Blok udziałów, wart tyle, ile ustaliła sprzedaż na rynku materiałów. Wyślij go promem zaopatrzenia, by dostać pieniądze."
	icon = 'aquila/icons/obj/economy/bounty_market.dmi'
	icon_state = "stock_block"
	w_class = WEIGHT_CLASS_SMALL
	/// Typ sprzedanego materiału
	var/datum/material/block_material
	/// Ile arkuszy sprzedano
	var/sheets = 0
	/// Cena za arkusz
	var/export_value = 0
	/// Czy cena już płynie z rynkiem
	var/fluid = FALSE

/obj/item/stock_block/proc/set_up(datum/material/mat, sheet_count, price)
	block_material = mat
	sheets = sheet_count
	export_value = price
	addtimer(CALLBACK(src, PROC_REF(value_warning)), 1.5 MINUTES, TIMER_DELETE_ME)
	addtimer(CALLBACK(src, PROC_REF(become_liquid)), 3 MINUTES, TIMER_DELETE_ME)

/obj/item/stock_block/examine(mob/user)
	. = ..()
	if(!block_material)
		return
	if(fluid)
		update_value()
		. += "<span class='warning'>[src] jest płynny! Jego wartość zależy od ceny rynkowej.</span>"
	else
		. += "<span class='notice'>Wartość [src] jest wciąż <b>zamrożona</b>. <b>Sprzedaj go</b>, zanim zacznie płynąć!</span>"
	. += "<span class='notice'>[src] jest wart [sheets * export_value] kr za [sheets] arkuszy: [initial(block_material.name)].</span>"

/obj/item/stock_block/proc/value_warning()
	visible_message("<span class='warning'>[src] zaczyna płynąć!</span>")
	icon_state = "stock_block_fluid"
	update_appearance()

/obj/item/stock_block/proc/become_liquid()
	update_value()
	icon_state = "stock_block_liquid"
	update_appearance()
	visible_message("<span class='warning'>[src] staje się płynny!</span>")
	fluid = TRUE

/// Odświeża cenę płynnego bloku z giełdy
/obj/item/stock_block/proc/update_value()
	var/price = get_market_price(block_material)
	if(!isnull(price))
		export_value = price
	return export_value

/datum/export/stock_block
	cost = 1
	k_elasticity = 0
	unit_name = "stock block"
	export_types = list(/obj/item/stock_block)

/datum/export/stock_block/get_amount(obj/O)
	var/obj/item/stock_block/block = O
	return istype(block) ? block.sheets : 0

/datum/export/stock_block/get_cost(obj/O, allowed_categories = NONE, apply_elastic = TRUE)
	var/obj/item/stock_block/block = O
	if(!istype(block) || !block.block_material)
		return 0
	var/unit_value = block.fluid ? block.update_value() : block.export_value
	return round(unit_value * block.sheets)

/datum/export/stock_block/sell_object(obj/O, datum/export_report/report, dry_run = TRUE, allowed_categories = EXPORT_CARGO, apply_elastic = TRUE)
	. = ..(O, report, dry_run, allowed_categories, FALSE)
	if(!. || dry_run)
		return
	var/obj/item/stock_block/block = O
	market_sale(block.block_material, block.sheets)

#undef MAX_STACK_LIMIT
#undef GALACTIC_MATERIAL_ORDER
