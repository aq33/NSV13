///Ścienny terminal lokalu: kucharz (albo barman) otwiera tu lokal, rozstawia miejsca i widzi zamówienia gości
/obj/machinery/restaurant_terminal
	name = "terminal restauracji"
	desc = "Panel do obsługi gości z portalu: otwieranie lokalu, miejsca przy stołach i lista zamówień."
	icon = 'icons/obj/terminals.dmi'
	icon_state = "dorm_taken"
	density = FALSE
	anchored = TRUE
	layer = ABOVE_WINDOW_LAYER
	use_power = IDLE_POWER_USE
	idle_power_usage = 10
	active_power_usage = 50
	resistance_flags = FIRE_PROOF | ACID_PROOF
	max_integrity = 200
	///Lokal obsługiwany przez terminal. Typ zamieniany w Initialize na instancję
	var/datum/venue/linked_venue = /datum/venue/restaurant
	///Typ projektora miejsc wydawanego przez terminal
	var/obj/item/holosign_creator/robot_seat/projector_type = /obj/item/holosign_creator/robot_seat/restaurant
	///Ostatnio wydany projektor, żeby nie wydawać ich bez końca
	var/datum/weakref/last_projector
	///Ile tylu od portalu szukamy krzeseł przy automatycznym rozstawianiu (tyle samo widzi robot)
	var/auto_seat_range = 7
	///Ile miejsc najwyżej rozstawia automat
	var/max_auto_seats = 10
	COOLDOWN_DECLARE(announce_cooldown)

/obj/machinery/restaurant_terminal/Initialize(mapload)
	. = ..()
	linked_venue = SSrestaurant.get_venue(linked_venue)
	linked_venue.terminals += src
	update_appearance()

/obj/machinery/restaurant_terminal/Destroy()
	if(istype(linked_venue))
		linked_venue.terminals -= src
	linked_venue = null
	return ..()

/obj/machinery/restaurant_terminal/update_icon_state()
	. = ..()
	if(machine_stat & (NOPOWER|BROKEN))
		icon_state = "dorm_off"
	else
		icon_state = linked_venue?.open ? "dorm_available" : "dorm_taken"

/obj/machinery/restaurant_terminal/power_change()
	. = ..()
	update_appearance()

/obj/machinery/restaurant_terminal/examine(mob/user)
	. = ..()
	. += "<span class='notice'>[linked_venue.display_name] jest teraz [linked_venue.open ? "<b>otwarta</b>" : "<b>zamknięta</b>"].</span>"

///Terminal mówi na głos nowe zamówienie
/obj/machinery/restaurant_terminal/proc/announce_order(mob/living/simple_animal/robot_customer/customer, order_name)
	if(machine_stat & (NOPOWER|BROKEN))
		return
	say("[customer.name] zamawia: [order_name].")
	if(COOLDOWN_FINISHED(src, announce_cooldown))
		playsound(src, 'sound/machines/ping.ogg', 40, FALSE)
		COOLDOWN_START(src, announce_cooldown, 3 SECONDS)

/obj/machinery/restaurant_terminal/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "RestaurantTerminal", name)
		ui.set_autoupdate(TRUE)
		ui.open()

/obj/machinery/restaurant_terminal/ui_data(mob/user)
	var/list/data = list()
	data["venue_name"] = linked_venue.display_name
	data["open"] = linked_venue.open
	data["has_portal"] = !!linked_venue.restaurant_portal
	data["has_access"] = linked_venue.has_access(user)
	data["served"] = linked_venue.customers_served
	data["lost"] = linked_venue.customers_lost
	data["income"] = linked_venue.total_income
	data["seats_total"] = length(linked_venue.linked_seats)
	data["seats_free"] = linked_venue.free_seat_count()
	data["max_guests"] = linked_venue.max_guests
	var/obj/item/projector = last_projector?.resolve()
	data["projector_out"] = !QDELETED(projector)

	var/list/guests = list()
	for(var/mob/living/simple_animal/robot_customer/customer as anything in linked_venue.current_visitors)
		var/datum/ai_controller/controller = customer.ai_controller
		if(!controller)
			continue
		var/datum/customer_data/customer_data = controller.blackboard[BB_CUSTOMER_CUSTOMERINFO]
		var/order = controller.blackboard[BB_CUSTOMER_CURRENT_ORDER]
		var/status
		if(controller.blackboard[BB_CUSTOMER_LEAVING])
			status = controller.blackboard[BB_CUSTOMER_EATING] ? "Wychodzi zadowolony" : "Wychodzi"
		else if(controller.blackboard[BB_CUSTOMER_CURRENT_TARGET])
			status = "Bije się!"
		else if(controller.blackboard[BB_CUSTOMER_EATING])
			status = "Je"
		else if(order)
			status = "Czeka na zamówienie"
		else if(controller.blackboard[BB_CUSTOMER_MY_SEAT])
			status = "Idzie do stolika"
		else
			status = "Szuka miejsca"
		var/patience = 0
		if(customer_data?.total_patience)
			patience = clamp(round(100 * controller.blackboard[BB_CUSTOMER_PATIENCE] / customer_data.total_patience), 0, 100)
		guests += list(list(
			"name" = customer.name,
			"order" = order ? linked_venue.get_order_name(order) : null,
			"status" = status,
			"patience" = patience,
			"waiting" = !!order,
		))
	data["guests"] = guests
	return data

/obj/machinery/restaurant_terminal/ui_act(action, list/params)
	. = ..()
	if(.)
		return
	var/mob/user = usr
	if(!linked_venue.has_access(user))
		to_chat(user, "<span class='warning'>Brak dostępu. Potrzebna jest karta z dostępem do tego lokalu.</span>")
		playsound(src, 'sound/machines/terminal_prompt_deny.ogg', 40, FALSE)
		return
	switch(action)
		if("toggle")
			if(!linked_venue.open && !linked_venue.restaurant_portal)
				to_chat(user, "<span class='warning'>Ten lokal nie ma portalu dla gości.</span>")
				return
			linked_venue.toggle_open(user)
			playsound(src, 'sound/machines/terminal_prompt_confirm.ogg', 40, FALSE)
			say(linked_venue.open ? "[linked_venue.display_name] otwarta. Portal przyjmuje gości." : "[linked_venue.display_name] zamknięta. Goście kończą i wychodzą.")
			if(linked_venue.open && !length(linked_venue.linked_seats))
				say("Uwaga: nie ma miejsc dla gości. Rozstaw je przyciskiem albo projektorem.")
			return TRUE
		if("auto_seats")
			var/placed = auto_place_seats()
			say(placed ? "Rozstawiono miejsca: [placed]." : "Nie znaleziono wolnych krzeseł ani stołów przy portalu.")
			return TRUE
		if("clear_seats")
			var/removed = 0
			for(var/obj/structure/holosign/robot_seat/seat as anything in linked_venue.linked_seats.Copy())
				if(linked_venue.linked_seats[seat])
					continue
				qdel(seat)
				removed++
			say("Zdjęto wolne miejsca: [removed].")
			return TRUE
		if("projector")
			var/obj/item/projector = last_projector?.resolve()
			if(!QDELETED(projector))
				to_chat(user, "<span class='warning'>Projektor został już wydany. Poszukaj go w okolicy.</span>")
				return
			projector = new projector_type(drop_location())
			last_projector = WEAKREF(projector)
			user.put_in_hands(projector)
			playsound(src, 'sound/machines/click.ogg', 40, FALSE)
			return TRUE

/**
 * Stawia miejsca w pomieszczeniu z portalem, w zasięgu jego wzroku.
 * Najpierw krzesła przy stołach. Jeśli takich nie ma, wolne pola obok stołów, a na końcu dowolne krzesła.
 */
/obj/machinery/restaurant_terminal/proc/auto_place_seats()
	var/obj/machinery/restaurant_portal/portal = linked_venue.restaurant_portal
	if(!portal)
		return 0
	var/area/dining_area = get_area(portal)
	var/obj/structure/holosign/robot_seat/seat_type = initial(projector_type.holosign_type)
	var/list/facing_table = list()
	var/list/next_to_table = list()
	var/list/floor_by_table = list()
	var/list/other_chairs = list()
	for(var/turf/open/candidate in view(auto_seat_range, get_turf(portal)))
		if(get_area(candidate) != dining_area || candidate == get_turf(portal))
			continue
		if(locate(/obj/structure/holosign/robot_seat) in candidate)
			continue
		if(is_blocked_turf(candidate, TRUE))
			continue
		var/obj/structure/chair/chair = locate() in candidate
		var/table_dir = robot_seat_table_dir(candidate)
		if(chair)
			if(table_dir == chair.dir)
				facing_table += candidate
			else if(table_dir)
				next_to_table += candidate
			else
				other_chairs += candidate
		else if(table_dir && !(locate(/obj/machinery) in candidate) && !(locate(/obj/structure) in candidate))
			floor_by_table += candidate
	// Pola przy stołach i krzesła bez stołu tylko wtedy, gdy nie ma lepszych miejsc
	var/list/targets = facing_table + next_to_table
	if(!length(targets))
		targets = floor_by_table
	if(!length(targets))
		targets = other_chairs
	var/limit = max(max_auto_seats - length(linked_venue.linked_seats), 0)
	var/placed = 0
	for(var/turf/target as anything in targets)
		if(placed >= limit)
			break
		new seat_type(target)
		placed++
	return placed

///Kierunek do sąsiedniego stołu (najpierw ten, w który patrzy krzesło), albo 0, gdy obok nie ma stołu
/proc/robot_seat_table_dir(turf/seat_turf)
	var/obj/structure/chair/chair = locate() in seat_turf
	if(chair)
		var/turf/front = get_step(seat_turf, chair.dir)
		if(front && (locate(/obj/structure/table) in front))
			return chair.dir
	for(var/direction in GLOB.cardinals)
		var/turf/neighbour = get_step(seat_turf, direction)
		if(neighbour && (locate(/obj/structure/table) in neighbour))
			return direction
	return 0


/obj/machinery/restaurant_terminal/restaurant
	name = "terminal restauracji"
	linked_venue = /datum/venue/restaurant
	projector_type = /obj/item/holosign_creator/robot_seat/restaurant

/obj/machinery/restaurant_terminal/bar
	name = "terminal baru"
	desc = "Panel do obsługi gości z portalu baru: otwieranie lokalu, miejsca przy ladzie i lista zamówień."
	linked_venue = /datum/venue/bar
	projector_type = /obj/item/holosign_creator/robot_seat/bar
