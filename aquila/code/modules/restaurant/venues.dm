///Ile robot płaci za ten przedmiot w restauracji. 0 = cena domyślna lokalu
/obj/item/var/venue_value = 0
///Ile robot płaci za szklankę tego napoju w barze. 0 = cena domyślna lokalu
/datum/reagent/var/glass_price = 0

/////RESTAURACJA/////
/datum/venue/restaurant
	name = "restaurant"
	display_name = "Restauracja"
	req_access = ACCESS_KITCHEN
	venue_type = VENUE_RESTAURANT
	min_time_between_visitor = 80 SECONDS
	max_time_between_visitor = 100 SECONDS
	customer_types = list(
		/datum/customer_data/american = 50,
		/datum/customer_data/italian = 30,
		/datum/customer_data/french = 30,
		/datum/customer_data/mexican = 30,
		/datum/customer_data/japanese = 30,
		/datum/customer_data/japanese/salaryman = 20,
		/datum/customer_data/british/bobby = 20,
		/datum/customer_data/british/gent = 20,
		/datum/customer_data/polish = 30,
		/datum/customer_data/moth = 1,
		/datum/customer_data/malfunction = 1,
	)

/datum/venue/restaurant/get_food_appearance(order)
	var/appearance = SSrestaurant.food_appearance_cache[order]

	if(!appearance) //Pierwsze takie zamówienie, robimy tymczasowy przedmiot, żeby skopiować jego wygląd razem z nakładkami
		var/obj/item/temp_object = new order()
		appearance = temp_object.appearance
		SSrestaurant.food_appearance_cache[order] = appearance
		qdel(temp_object)

	var/image/food_image = new
	food_image.appearance = appearance
	food_image.underlays += mutable_appearance(icon = 'aquila/icons/obj/restaurant/restaurant_portal.dmi', icon_state = "thought_bubble")
	return food_image

/datum/venue/restaurant/is_correct_order(atom/movable/object_used, wanted_item)
	. = ..()
	return . || (ispath(wanted_item) && object_used.type == wanted_item)

/datum/venue/restaurant/get_order_name(order)
	if(ispath(order, /atom))
		var/atom/object_to_order = order
		return initial(object_to_order.name)
	return ..()

/datum/venue/restaurant/get_order_price(obj/item/order_item, order)
	if(order_item.venue_value)
		return order_item.venue_value
	return FOOD_PRICE_NORMAL


/////BAR/////
/datum/venue/bar
	name = "bar"
	display_name = "Bar"
	req_access = ACCESS_BAR
	venue_type = VENUE_BAR
	min_time_between_visitor = 40 SECONDS
	max_time_between_visitor = 60 SECONDS
	customer_types = list(
		/datum/customer_data/american = 50,
		/datum/customer_data/italian = 30,
		/datum/customer_data/french = 30,
		/datum/customer_data/mexican = 30,
		/datum/customer_data/japanese = 30,
		/datum/customer_data/japanese/salaryman = 20,
		/datum/customer_data/british/bobby = 20,
		/datum/customer_data/british/gent = 20,
		/datum/customer_data/polish = 30,
		/datum/customer_data/malfunction = 1,
	)

/datum/venue/bar/get_food_appearance(order)
	var/image/food_image = image(icon = 'aquila/icons/obj/restaurant/restaurant_portal.dmi', icon_state = "thought_bubble")
	if(!ispath(order, /datum/reagent))
		return food_image
	var/datum/reagent/reagent_to_order = order
	var/glass_state = initial(reagent_to_order.glass_icon_state)
	if(glass_state)
		food_image.add_overlay(mutable_appearance('icons/obj/drinks.dmi', glass_state))
	else
		food_image.add_overlay(mutable_appearance('icons/obj/drinks.dmi', "glass_empty"))
		var/mutable_appearance/drink_color = mutable_appearance('icons/obj/drinks.dmi', "glassoverlay")
		drink_color.color = initial(reagent_to_order.color)
		food_image.add_overlay(drink_color)
	return food_image

/datum/venue/bar/get_order_name(order)
	if(ispath(order, /datum/reagent))
		var/datum/reagent/reagent_to_order = order
		return "[initial(reagent_to_order.name)] w szklance"
	return ..()

///W barze napój musi być w naczyniu, przeważać w nim i mieć co najmniej VENUE_BAR_MINIMUM_REAGENTS jednostek
/datum/venue/bar/is_correct_order(atom/movable/object_used, wanted_item)
	. = ..()
	if(.)
		return
	if(!ispath(wanted_item, /datum/reagent) || !istype(object_used, /obj/item/reagent_containers/food/drinks))
		return FALSE
	var/datum/reagents/holder = object_used.reagents
	if(!holder?.total_volume)
		return FALSE
	var/datum/reagent/master_reagent = holder.get_master_reagent()
	if(master_reagent?.type != wanted_item)
		return FALSE
	var/amount = holder.get_reagent_amount(wanted_item)
	// Co najmniej jedna trzecia zawartości, żeby nie rozcieńczać napojów wodą
	return amount >= VENUE_BAR_MINIMUM_REAGENTS && amount >= holder.total_volume / 3

/datum/venue/bar/get_order_price(obj/item/order_item, order)
	if(ispath(order, /datum/reagent))
		var/datum/reagent/ordered_reagent = order
		var/price = initial(ordered_reagent.glass_price)
		if(price)
			return price
	return DRINK_PRICE_MEDIUM

/datum/venue/bar/consume_order(mob/living/simple_animal/robot_customer/customer_pawn, obj/item/order_item)
	if(!order_item.reagents)
		return ..()
	customer_pawn.visible_message("<span class='danger'>[customer_pawn] wychyla [order_item] duszkiem!</span>", "<span class='danger'>Wychylasz [order_item] duszkiem.</span>")
	playsound(get_turf(customer_pawn), 'sound/items/drink.ogg', 50, TRUE)
	order_item.reagents.clear_reagents()
