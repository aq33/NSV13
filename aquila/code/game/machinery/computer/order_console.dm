/**
 * Konsola zamówień, port /obj/machinery/computer/order_console z tg.
 * Używa jej sklep bitrunnerów (NexaCache). Inne konsole mogą dziedziczyć.
 */

///List of all items that can be found in the different types of order consoles, to purchase.
GLOBAL_LIST_EMPTY(order_console_products)

/obj/machinery/computer/order_console
	name = "konsola zamówień"
	desc = "Interfejs do zamawiania towarów przez zaopatrzenie, z droższą opcją ekspresową."
	icon_screen = "request"
	icon_keyboard = "generic_key"
	light_color = LIGHT_COLOR_ORANGE
	///Tooltip for the express button in TGUI
	var/express_tooltip = "Wysyła zakupy od razu, ale blokuje konsolę na dłużej i podnosi cenę!"
	///Tooltip for the purchase button in TGUI
	var/purchase_tooltip = "Zakupy przylecą promem zaopatrzenia i miejmy nadzieję, że ktoś je dostarczy."

	///Cooldown between order uses.
	COOLDOWN_DECLARE(order_cooldown)
	///Cooldown time between uses, express console will have extra time depending on express_cost_multiplier.
	var/cooldown_time = 60 SECONDS
	///The channel we will attempt to speak into through our radio.
	var/radio_channel = RADIO_CHANNEL_SUPPLY
	///What line we should announce on ordering_groceries
	var/announcement_line

	///The kind of cash does the console use.
	var/credit_type = "kr"
	///Whether the console can only use express mode ONLY
	var/forced_express = FALSE
	///Multiplied cost to use for cargo mode
	var/cargo_cost_multiplier = 1
	///Multiplied cost to use for express mode
	var/express_cost_multiplier = 2
	///The categories of orderable items this console can view and purchase.
	var/list/order_categories = list()
	///The current list of things we're trying to order, waiting for checkout.
	var/list/datum/orderable_item/grocery_list = list()
	///For blackbox logging, what kind of order is this? set nothing to not tally, like golem orders
	var/blackbox_key

/obj/machinery/computer/order_console/Initialize(mapload)
	. = ..()

	if(length(GLOB.order_console_products))
		return
	for(var/datum/orderable_item/path as anything in subtypesof(/datum/orderable_item))
		if(!initial(path.purchase_path))
			continue
		GLOB.order_console_products += new path

/obj/machinery/computer/order_console/proc/get_total_cost()
	var/cost = 0
	for(var/datum/orderable_item/item as anything in grocery_list)
		cost += grocery_list[item] * item.cost_per_order
	return cost

/obj/machinery/computer/order_console/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "ProduceConsole", name)
		ui.open()

/**
 * points is any type of currency this machine accepts(money, mining points etc) which is displayed on the ui
 * Args:
 * card - The ID card we retrieve these points from
 */
/obj/machinery/computer/order_console/proc/retrieve_points(obj/item/card/id/id_card)
	return round(id_card.registered_account?.account_balance)

/obj/machinery/computer/order_console/ui_data(mob/user)
	var/list/data = list()
	data["total_cost"] = get_total_cost()
	data["free_uses"] = null
	data["off_cooldown"] = COOLDOWN_FINISHED(src, order_cooldown)
	data["item_amts"] = list()

	for(var/datum/orderable_item/item as anything in GLOB.order_console_products)
		if(!(item.category_index in order_categories))
			continue
		data["item_amts"] += list(list(
			"name" = item.name,
			"amt" = grocery_list[item] || 0,
		))
	if(isliving(user))
		var/mob/living/living_user = user
		var/obj/item/card/id/id_card = living_user.get_idcard(TRUE)
		if(id_card)
			data["points"] = retrieve_points(id_card)

	return data

/obj/machinery/computer/order_console/ui_static_data(mob/user)
	var/list/data = list()
	data["credit_type"] = credit_type
	data["express_tooltip"] = express_tooltip
	data["purchase_tooltip"] = purchase_tooltip
	data["forced_express"] = forced_express
	data["cargo_value"] = 200
	data["cargo_cost_multiplier"] = cargo_cost_multiplier
	data["express_cost_multiplier"] = express_cost_multiplier
	data["order_categories"] = order_categories
	data["order_datums"] = list()
	for(var/datum/orderable_item/item as anything in GLOB.order_console_products)
		if(!(item.category_index in order_categories))
			continue

		var/obj/item_type = item.purchase_path
		data["order_datums"] += list(list(
			"name" = item.name,
			"desc" = item.desc,
			"cat" = item.category_index,
			"ref" = REF(item),
			"cost" = round(item.cost_per_order * cargo_cost_multiplier),
			"icon" = "[initial(item_type.icon)]",
			"icon_state" = initial(item_type.icon_state),
			"product_icon" = icon2base64(icon(initial(item_type.icon), initial(item_type.icon_state), SOUTH, 1)),
			"max" = item.max_per_order,
		))
	return data

/obj/machinery/computer/order_console/ui_act(action, list/params)
	. = ..()
	if(.)
		return
	if(!isliving(usr))
		return
	var/mob/living/living_user = usr
	switch(action)
		if("add_one")
			var/datum/orderable_item/wanted_item = locate(params["target"]) in GLOB.order_console_products
			if(!wanted_item || grocery_list[wanted_item] >= wanted_item.max_per_order)
				return
			grocery_list[wanted_item] += 1
		if("remove_one")
			var/datum/orderable_item/wanted_item = locate(params["target"]) in GLOB.order_console_products
			if(!wanted_item || !grocery_list[wanted_item])
				return
			grocery_list[wanted_item] -= 1
			if(grocery_list[wanted_item] <= 0)
				grocery_list -= wanted_item
		if("cart_set")
			var/datum/orderable_item/wanted_item = locate(params["target"]) in GLOB.order_console_products
			if(!wanted_item)
				return
			grocery_list[wanted_item] = clamp(text2num("[params["amt"]]"), 0, wanted_item.max_per_order)
			if(!grocery_list[wanted_item])
				grocery_list -= wanted_item
		if("purchase")
			if(!length(grocery_list) || !COOLDOWN_FINISHED(src, order_cooldown))
				return
			if(forced_express)
				return ui_act("express", params)

			var/obj/item/card/id/used_id_card = living_user.get_idcard(TRUE)
			if(!used_id_card || !used_id_card.registered_account)
				say("Nie wykryto konta bankowego!")
				return
			if(!purchase_items(used_id_card))
				return
			if(blackbox_key)
				SSblackbox.record_feedback("tally", "non_express_[blackbox_key]_order", 1, name)
			order_groceries(living_user, used_id_card, grocery_list)
			grocery_list.Cut()
			COOLDOWN_START(src, order_cooldown, cooldown_time)
		if("express")
			if(!length(grocery_list) || !COOLDOWN_FINISHED(src, order_cooldown))
				return
			var/obj/item/card/id/used_id_card = living_user.get_idcard(TRUE)
			if(!used_id_card || !used_id_card.registered_account)
				say("Nie wykryto konta bankowego!")
				return
			if(!purchase_items(used_id_card, express = TRUE))
				return
			var/say_message = "Dziękujemy za zakup!"
			if(express_cost_multiplier > 1)
				say_message += " Uwaga: cena i czas blokady konsoli zostały pomnożone przez [express_cost_multiplier]!"
			COOLDOWN_START(src, order_cooldown, cooldown_time * express_cost_multiplier)
			say(say_message)
			if(blackbox_key)
				SSblackbox.record_feedback("tally", "express_[blackbox_key]_order", 1, name)
			var/obj/structure/closet/supplypod/bluespacepod/pod = new()
			for(var/datum/orderable_item/item as anything in grocery_list)//every order
				if(!(item.category_index in order_categories))
					grocery_list.Remove(item)
					continue
				var/purchase_path = item.get_purchased_item(living_user, used_id_card)
				for(var/amt in 1 to grocery_list[item])//every order amount
					new purchase_path(pod)
			new /obj/effect/pod_landingzone(get_turf(living_user), pod)
			grocery_list.Cut()
	return TRUE

/**
 * Checks if an ID card is able to afford the total cost of the current console's groceries
 * and deducts the cost if they can.
 */
/obj/machinery/computer/order_console/proc/purchase_items(obj/item/card/id/card, express = FALSE)
	var/final_cost = round(get_total_cost() * (express ? express_cost_multiplier : cargo_cost_multiplier))
	if(final_cost > 0 && !subtract_points(final_cost, card))
		say("Przykro mi, ale masz za mało [credit_type].")
		return FALSE
	return TRUE

/// Odejmuje punkty z karty. Zwraca TRUE, jeśli się udało.
/obj/machinery/computer/order_console/proc/subtract_points(final_cost, obj/item/card/id/card)
	return card.registered_account.adjust_money(-final_cost)

/**
 * start of the shipment of your order
 * Args:
 * purchaser - The mob who is making this purchase
 * card - The card used to place this order
 * groceries - the list of orders to be placed
 */
/obj/machinery/computer/order_console/proc/order_groceries(mob/living/purchaser, obj/item/card/id/card, list/groceries)
	return


///A datum for ordering options from order consoles.
/datum/orderable_item
	///Name of the item shown in the shop.
	var/name
	///Description shown in the shop, set automatically unless it's hard set by the subtype
	var/desc
	///Path of the item that is purchased when ordering us.
	var/atom/movable/purchase_path
	///The category this item will be displayed in.
	var/category_index = NONE
	///How much this item costs to order.
	var/cost_per_order = 10
	/// Max amount of this item that can be ordered at once.
	var/max_per_order = null

/datum/orderable_item/New()
	. = ..()
	if(!category_index)
		CRASH("[type] doesn't have a category_index assigned!")
	if(!purchase_path)
		CRASH("[type] orderable item datum with no item path was created!")
	if(!name)
		name = initial(purchase_path.name)
	if(!desc)
		desc = initial(purchase_path.desc)
	if(!max_per_order)
		max_per_order = (cost_per_order <= 10 ? 50 : (cost_per_order <= 25 ? 20 : 10))

/datum/orderable_item/proc/get_purchased_item(mob/living/user, obj/item/card/id/card)
	return purchase_path


/// Paczka zamówienia z konsoli, dostarczana normalnym promem zaopatrzenia (zapłacona z góry)
/datum/supply_pack/order_console
	name = "zamówienie z konsoli"
	hidden = TRUE
	cost = 0
	crate_name = "skrzynia z zamówieniem"

/datum/supply_pack/order_console/New(purchaser, list/contains, access)
	. = ..()
	name = "Zamówienie: [purchaser]"
	src.contains = contains
	src.access = access
