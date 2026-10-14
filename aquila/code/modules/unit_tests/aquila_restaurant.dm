// The upstream assert macros are #undef'd at the end of code/modules/unit_tests/_unit_tests.dm, so this modular test carries its own copies
#define TEST_ASSERT(assertion, reason) if (!(assertion)) { return Fail("Assertion failed: [reason || "No reason"]") }

#define TEST_ASSERT_EQUAL(a, b, message) do { \
	var/lhs = ##a; \
	var/rhs = ##b; \
	if (lhs != rhs) { \
		return Fail("Expected [isnull(lhs) ? "null" : lhs] to be equal to [isnull(rhs) ? "null" : rhs].[message ? " [message]" : ""]"); \
	} \
} while (FALSE)

/// AQUILA - every order of every robot tourist exists and can be drawn in the thought bubble
/datum/unit_test/aquila_restaurant_orders

/datum/unit_test/aquila_restaurant_orders/Run()
	var/datum/venue/restaurant = SSrestaurant.get_venue(/datum/venue/restaurant)
	var/datum/venue/bar = SSrestaurant.get_venue(/datum/venue/bar)
	for(var/customer_type in subtypesof(/datum/customer_data))
		var/datum/customer_data/customer = SSrestaurant.get_customer(customer_type)
		TEST_ASSERT(length(customer.name_prefixes), "[customer_type] has no name prefixes")
		for(var/order in customer.orderable_objects[VENUE_RESTAURANT])
			if(ispath(order, /datum/custom_order))
				continue
			TEST_ASSERT(ispath(order, /obj/item), "[customer_type] orders [order] in the restaurant, which is not an item")
			TEST_ASSERT(restaurant.get_food_appearance(order), "No order bubble for [order]")
		for(var/order in customer.orderable_objects[VENUE_BAR])
			TEST_ASSERT(ispath(order, /datum/reagent), "[customer_type] orders [order] in the bar, which is not a reagent")
			TEST_ASSERT(bar.get_food_appearance(order), "No order bubble for [order]")

/// AQUILA - a robot tourist pays for the right order, refuses the wrong one, and the terminal puts seats next to tables
/datum/unit_test/aquila_restaurant_service

/datum/unit_test/aquila_restaurant_service/Run()
	var/datum/venue/restaurant/venue = SSrestaurant.get_venue(/datum/venue/restaurant)
	var/old_served = venue.customers_served
	var/old_income = venue.total_income
	var/obj/machinery/restaurant_portal/map_portal = venue.restaurant_portal
	var/turf/start = run_loc_floor_bottom_left

	var/obj/machinery/restaurant_portal/portal = allocate(/obj/machinery/restaurant_portal/restaurant, start)
	TEST_ASSERT_EQUAL(venue.restaurant_portal, portal, "Portal did not link to the restaurant")

	// Krzesło zwrócone na wschód, stół na wschód od niego
	var/turf/chair_turf = locate(start.x + 2, start.y, start.z)
	var/turf/table_turf = locate(start.x + 3, start.y, start.z)
	var/obj/structure/chair/chair = allocate(/obj/structure/chair, chair_turf)
	chair.setDir(EAST)
	allocate(/obj/structure/table, table_turf)

	var/obj/machinery/restaurant_terminal/restaurant/terminal = allocate(/obj/machinery/restaurant_terminal/restaurant, start)
	TEST_ASSERT(terminal in venue.terminals, "Terminal did not register with the restaurant")
	TEST_ASSERT_EQUAL(terminal.auto_place_seats(), 1, "Terminal should place exactly one seat, on the chair by the table")
	TEST_ASSERT(locate(/obj/structure/holosign/robot_seat/restaurant) in chair_turf, "Seat was not placed on the chair")
	TEST_ASSERT_EQUAL(robot_seat_table_dir(chair_turf), EAST, "Seat should face the table")

	var/mob/living/simple_animal/robot_customer/customer = allocate(/mob/living/simple_animal/robot_customer, start, /datum/customer_data/american, venue)
	venue.current_visitors += customer
	var/datum/ai_controller/robot_customer/controller = customer.ai_controller
	TEST_ASSERT(istype(controller), "Robot customer has no robot customer AI")
	controller.set_ai_status(AI_STATUS_OFF) // Nie chcemy, żeby chodził w trakcie testu
	controller.blackboard[BB_CUSTOMER_CURRENT_ORDER] = /obj/item/food/burger/plain

	var/obj/item/food/wrong = allocate(/obj/item/food/fries, start)
	TEST_ASSERT(!venue.is_correct_order(wrong, /obj/item/food/burger/plain), "Fries were accepted as a plain burger")

	var/obj/item/food/burger = allocate(/obj/item/food/burger/plain, table_turf)
	TEST_ASSERT(venue.is_correct_order(burger, /obj/item/food/burger/plain), "Plain burger was not accepted as a plain burger")
	controller.eat_order(burger, venue)
	TEST_ASSERT(QDELETED(burger), "Robot did not eat the burger")
	TEST_ASSERT_EQUAL(venue.customers_served, old_served + 1, "Served customers did not go up")
	TEST_ASSERT_EQUAL(venue.total_income, old_income + FOOD_PRICE_CHEAP, "Income does not match the burger price")
	var/obj/item/holochip/payment = locate() in table_turf
	TEST_ASSERT(payment, "Robot did not leave a holochip on the table")
	TEST_ASSERT_EQUAL(payment.credits, FOOD_PRICE_CHEAP, "Robot paid the wrong amount")
	TEST_ASSERT(!controller.blackboard[BB_CUSTOMER_CURRENT_ORDER], "Order was not cleared after eating")

	// Personel z dostępem może robota ciągnąć, ale bicie zawsze daje ostrzeżenie
	var/mob/living/carbon/human/staff = allocate(/mob/living/carbon/human, chair_turf)
	staff.equip_to_slot_or_del(new /obj/item/clothing/under/color/grey(staff), ITEM_SLOT_ICLOTHING)
	var/obj/item/card/id/staff_card = new(staff)
	staff_card.access = list(ACCESS_KITCHEN)
	staff.equip_to_slot_or_del(staff_card, ITEM_SLOT_ID)
	TEST_ASSERT(venue.has_access(staff), "Kitchen card does not grant venue access")
	controller.on_get_pulled(staff)
	TEST_ASSERT(!venue.mob_blacklist[REF(staff)], "Pulling by kitchen staff gave a warning")
	staff.combat_mode = TRUE
	customer.attack_hand(staff, list())
	customer.attack_hand(staff, list())
	TEST_ASSERT_EQUAL(venue.mob_blacklist[REF(staff)], 2, "Punches from kitchen staff did not give warnings")
	venue.mob_blacklist -= REF(staff)

	venue.close()
	for(var/seat in venue.linked_seats.Copy())
		qdel(seat)
	venue.customers_served = old_served
	venue.total_income = old_income
	// Po usunięciu testowego portalu lokal sam wraca do portalu z mapy (jeśli mapa go ma)
	qdel(portal)
	TEST_ASSERT_EQUAL(venue.restaurant_portal, map_portal, "Venue did not fall back to the previous portal")

/// AQUILA - the bar only accepts a glass that is mostly the ordered drink
/datum/unit_test/aquila_restaurant_bar_orders

/datum/unit_test/aquila_restaurant_bar_orders/Run()
	var/datum/venue/bar/bar = SSrestaurant.get_venue(/datum/venue/bar)
	var/obj/item/reagent_containers/food/drinks/drinkingglass/glass = allocate(/obj/item/reagent_containers/food/drinks/drinkingglass)

	glass.reagents.add_reagent(/datum/reagent/consumable/ethanol/beer, 5)
	TEST_ASSERT(!bar.is_correct_order(glass, /datum/reagent/consumable/ethanol/beer), "5u of beer was accepted")

	glass.reagents.add_reagent(/datum/reagent/consumable/ethanol/beer, 15)
	TEST_ASSERT(bar.is_correct_order(glass, /datum/reagent/consumable/ethanol/beer), "20u of beer was not accepted")
	TEST_ASSERT(!bar.is_correct_order(glass, /datum/reagent/consumable/ethanol/vodka), "Beer was accepted as vodka")

	glass.reagents.add_reagent(/datum/reagent/water, 25)
	TEST_ASSERT(!bar.is_correct_order(glass, /datum/reagent/consumable/ethanol/beer), "Watered down beer was accepted")

#undef TEST_ASSERT
#undef TEST_ASSERT_EQUAL
