/*!
 * Restauracja z robotami-turystami, port z tgstation (tgstation/tgstation#57010 i późniejsze, stan z tg@03900dcdf4).
 *
 * Lokal (venue) to abstrakcja kuchni albo baru. Gdy jest otwarty, przez portal przychodzą roboty,
 * siadają na holograficznych miejscach i zamawiają jedzenie lub napoje. Za podane zamówienie płacą holochipem.
 * Lokal włącza się terminalem na ścianie kuchni (albo baru) lub kartą ID przyłożoną do portalu.
 */
SUBSYSTEM_DEF(restaurant)
	name = "Restaurant"
	flags = SS_NO_FIRE
	init_order = INIT_ORDER_ATOMS + 1
	///Wszystkie lokale, typ => instancja
	var/list/all_venues = list()
	///Wszystkie rodzaje klientów, typ => instancja
	var/list/all_customers = list()
	///Wygląd zamawianych przedmiotów, typ => appearance, żeby nie tworzyć ich za każdym razem
	var/list/food_appearance_cache = list()

/datum/controller/subsystem/restaurant/Initialize(timeofday)
	for(var/venue_type in subtypesof(/datum/venue))
		get_venue(venue_type)
	for(var/customer_type in subtypesof(/datum/customer_data))
		get_customer(customer_type)
	return ..()

///Zwraca instancję lokalu, tworząc ją przy pierwszym użyciu (portale i terminale z mapy mogą pytać przed Initialize)
/datum/controller/subsystem/restaurant/proc/get_venue(venue_type)
	var/datum/venue/venue = all_venues[venue_type]
	if(!venue)
		venue = new venue_type()
		all_venues[venue_type] = venue
	return venue

/datum/controller/subsystem/restaurant/proc/get_customer(customer_type)
	var/datum/customer_data/customer = all_customers[customer_type]
	if(!customer)
		customer = new customer_type()
		all_customers[customer_type] = customer
	return customer

///Abstrakcyjny lokal gastronomiczny
/datum/venue
	///Nazwa lokalu, używana też jako stan ikony w restaurant_portal.dmi
	var/name = "lokal"
	///Nazwa wyświetlana graczom
	var/display_name = "lokal"
	///Rodzaj lokalu: VENUE_RESTAURANT albo VENUE_BAR
	var/venue_type = VENUE_RESTAURANT
	///Maksymalna liczba gości naraz
	var/max_guests = 6
	///Ważona lista rodzajów klientów
	var/list/customer_types
	///Czy lokal jest otwarty
	var/open = FALSE
	///Portal, przez który przychodzą goście
	var/obj/machinery/restaurant_portal/restaurant_portal
	///Wszystkie portale tego lokalu; po zniknięciu aktywnego goście wracają do poprzedniego
	var/list/obj/machinery/restaurant_portal/all_portals = list()
	///Terminale obsługujące ten lokal
	var/list/obj/machinery/restaurant_terminal/terminals = list()
	///Obecni goście
	var/list/current_visitors = list()
	///Odliczanie do następnego gościa
	COOLDOWN_DECLARE(visit_cooldown)
	///Minimalny odstęp między gośćmi
	var/min_time_between_visitor = 60 SECONDS
	///Maksymalny odstęp między gośćmi
	var/max_time_between_visitor = 90 SECONDS
	///Dostęp potrzebny do otwierania lokalu
	var/req_access = ACCESS_KITCHEN
	///Ile robotów dostało to, co zamówiło
	var/customers_served = 0
	///Ile robotów wyszło głodnych
	var/customers_lost = 0
	///Łączny zarobek lokalu
	var/total_income = 0
	///Kto zaczepiał roboty. Klucz to REF moba, wartość to liczba ostrzeżeń
	var/list/mob_blacklist = list()
	///Miejsca dla gości. Klucz to hologram miejsca, wartość to robot, który je zajął (albo null)
	var/list/linked_seats = list()
	///Kto ostatnio otworzył lokal (ćmy zamawiają jego ubrania)
	var/datum/weakref/opened_by

/datum/venue/Destroy()
	close()
	restaurant_portal = null
	terminals.Cut()
	return ..()

/datum/venue/process(delta_time)
	if(!restaurant_portal)
		close()
		return
	if(!COOLDOWN_FINISHED(src, visit_cooldown))
		return
	COOLDOWN_START(src, visit_cooldown, rand(min_time_between_visitor, max_time_between_visitor))
	if(length(current_visitors) < max_guests && length(current_visitors) < length(linked_seats) + 1) //Jeden gość może czekać na stojąco
		create_new_customer()

///Tworzy nowego gościa przy portalu
/datum/venue/proc/create_new_customer()
	var/list/customer_types_to_choose = customer_types
	var/datum/customer_data/customer_type

	while(length(customer_types_to_choose))
		customer_type = pickweight(customer_types_to_choose)

		var/datum/customer_data/customer = SSrestaurant.get_customer(customer_type)
		if(customer.can_use(src))
			break

		// Kopiujemy listę tylko raz, żeby nie zmieniać oryginału
		if(customer_types_to_choose == customer_types)
			customer_types_to_choose = customer_types.Copy()

		customer_types_to_choose -= customer_type
		customer_type = null

	if(!customer_type)
		return

	if(initial(customer_type.is_unique))
		customer_types -= customer_type

	var/mob/living/simple_animal/robot_customer/new_customer = new(get_turf(restaurant_portal), customer_type, src)
	current_visitors += new_customer
	new_customer.ai_controller?.blackboard[BB_CUSTOMER_EXIT_PORTAL] = WEAKREF(restaurant_portal)
	playsound(restaurant_portal, 'sound/effects/phasein.ogg', 30, TRUE)
	return new_customer

///Robot wybiera zamówienie i je wypowiada
/datum/venue/proc/order_food(mob/living/simple_animal/robot_customer/customer_pawn, datum/customer_data/customer_data)
	var/order = pickweight(customer_data.orderable_objects[venue_type])
	if(!order)
		return
	var/image/food_image
	var/food_line

	if(ispath(order, /datum/custom_order))
		var/datum/custom_order/custom_order = new order(src)
		food_image = custom_order.get_order_appearance(src)
		food_line = custom_order.get_order_line(src)
		order = custom_order.dispense_order()
	else
		food_image = get_food_appearance(order)
		food_line = order_food_line(order)

	customer_pawn.customer_say(food_line)
	customer_pawn.set_order_bubble(food_image)
	announce_order(customer_pawn, order)
	return order

///Terminale lokalu ogłaszają nowe zamówienie, żeby kucharz nie musiał biegać do gości
/datum/venue/proc/announce_order(mob/living/simple_animal/robot_customer/customer_pawn, order)
	for(var/obj/machinery/restaurant_terminal/terminal as anything in terminals)
		terminal.announce_order(customer_pawn, get_order_name(order))

///Czy podany przedmiot jest tym, co zamówił robot
/datum/venue/proc/is_correct_order(atom/movable/object_used, wanted_item)
	if(istype(wanted_item, /datum/custom_order))
		var/datum/custom_order/custom_order = wanted_item
		return custom_order.is_correct_order(object_used)
	return FALSE

///Wygląd zamówienia w dymku nad robotem
/datum/venue/proc/get_food_appearance(order)
	return image(icon = 'aquila/icons/obj/restaurant/restaurant_portal.dmi', icon_state = "thought_bubble")

///Nazwa zamówienia do terminala i opisu
/datum/venue/proc/get_order_name(order)
	if(istype(order, /datum/custom_order))
		var/datum/custom_order/custom_order = order
		return custom_order.get_order_name(src)
	return "coś"

///Co robot mówi, gdy zamawia
/datum/venue/proc/order_food_line(order)
	return "Poproszę: [get_order_name(order)]."

///Ile robot płaci za to zamówienie
/datum/venue/proc/get_order_price(obj/item/order_item, order)
	return FOOD_PRICE_NORMAL

///Robot dostał zamówienie: płaci i je
/datum/venue/proc/on_get_order(mob/living/simple_animal/robot_customer/customer_pawn, obj/item/order_item)
	var/order = customer_pawn.ai_controller.blackboard[BB_CUSTOMER_CURRENT_ORDER]
	var/price = get_order_price(order_item, order)
	var/turf/pay_turf = get_turf(order_item) || get_turf(customer_pawn)
	if(price > 0)
		new /obj/item/holochip(pay_turf, price)
		total_income += price
		playsound(pay_turf, 'sound/effects/cashregister.ogg', 60, TRUE)
	customers_served += 1
	consume_order(customer_pawn, order_item)

///Co robot robi z zamówieniem
/datum/venue/proc/consume_order(mob/living/simple_animal/robot_customer/customer_pawn, obj/item/order_item)
	customer_pawn.visible_message("<span class='danger'>[customer_pawn] wpycha [order_item] do otworu w kształcie ust!</span>", "<span class='danger'>Wpychasz [order_item] do otworu w kształcie ust.</span>")
	playsound(get_turf(customer_pawn), 'sound/items/eatfood.ogg', rand(10, 50), TRUE)
	qdel(order_item)

///Przełącza lokal między otwartym i zamkniętym
/datum/venue/proc/toggle_open(mob/user)
	if(open)
		close()
	else
		open(user)

/datum/venue/proc/open(mob/user)
	if(open || !restaurant_portal)
		return FALSE
	open = TRUE
	if(user)
		opened_by = WEAKREF(user)
	COOLDOWN_START(src, visit_cooldown, 4 SECONDS) //Pierwszy gość przychodzi szybciej
	START_PROCESSING(SSobj, src)
	update_machines()
	return TRUE

/datum/venue/proc/close()
	if(!open)
		return FALSE
	open = FALSE
	STOP_PROCESSING(SSobj, src)
	for(var/mob/living/simple_animal/robot_customer/robot_customer as anything in current_visitors)
		robot_customer.ai_controller?.blackboard[BB_CUSTOMER_LEAVING] = TRUE
	update_machines()
	return TRUE

/datum/venue/proc/update_machines()
	restaurant_portal?.update_appearance()
	for(var/obj/machinery/restaurant_terminal/terminal as anything in terminals)
		terminal.update_appearance()

///Czy ten mob może zarządzać lokalem
/datum/venue/proc/has_access(mob/user)
	if(issiliconoradminghost(user))
		return TRUE
	var/obj/item/card/id/used_id = user.get_idcard(TRUE)
	return used_id && (req_access in used_id.GetAccess())

///Wolne miejsca (bez robota)
/datum/venue/proc/free_seat_count()
	. = 0
	for(var/seat in linked_seats)
		if(!linked_seats[seat])
			.++
