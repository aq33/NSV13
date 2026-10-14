/////KONTROLER/////
/datum/ai_controller/robot_customer
	ai_movement = /datum/ai_movement/basic_avoidance
	movement_delay = 0.8 SECONDS
	blackboard = list(
		BB_CUSTOMER_CURRENT_ORDER = null,
		BB_CUSTOMER_MY_SEAT = null,
		BB_CUSTOMER_PATIENCE = 999,
		BB_CUSTOMER_CUSTOMERINFO = null,
		BB_CUSTOMER_EATING = FALSE,
		BB_CUSTOMER_LEAVING = FALSE,
		BB_CUSTOMER_ATTENDING_VENUE = null,
		BB_CUSTOMER_SAID_CANT_FIND_SEAT_LINE = FALSE,
	)
	planning_subtrees = list(/datum/ai_planning_subtree/robot_customer)

/datum/ai_controller/robot_customer/Destroy()
	blackboard[BB_CUSTOMER_CURRENT_ORDER] = null
	blackboard[BB_CUSTOMER_CUSTOMERINFO] = null
	return ..()

/datum/ai_controller/robot_customer/TryPossessPawn(atom/new_pawn)
	if(!istype(new_pawn, /mob/living/simple_animal/robot_customer))
		return AI_CONTROLLER_INCOMPATIBLE
	RegisterSignal(new_pawn, COMSIG_PARENT_ATTACKBY, PROC_REF(on_attackby))
	RegisterSignal(new_pawn, COMSIG_ATOM_ATTACK_HAND, PROC_REF(on_get_punched))
	return ..()

/datum/ai_controller/robot_customer/UnpossessPawn(destroy)
	UnregisterSignal(pawn, list(COMSIG_PARENT_ATTACKBY, COMSIG_ATOM_ATTACK_HAND))
	return ..()

/datum/ai_controller/robot_customer/proc/on_attackby(datum/source, obj/item/I, mob/living/user)
	SIGNAL_HANDLER
	var/datum/venue/attending_venue = blackboard[BB_CUSTOMER_ATTENDING_VENUE]
	if(blackboard[BB_CUSTOMER_CURRENT_ORDER] && attending_venue.is_correct_order(I, blackboard[BB_CUSTOMER_CURRENT_ORDER]))
		to_chat(user, "<span class='notice'>Podajesz [I] robotowi [pawn].</span>")
		eat_order(I, attending_venue)
		return COMPONENT_NO_AFTERATTACK
	if(!I.force || !user.combat_mode)
		INVOKE_ASYNC(src, PROC_REF(dont_want_that))
		return COMPONENT_NO_AFTERATTACK
	INVOKE_ASYNC(src, PROC_REF(warn_greytider), user)

///Robot dostaje zamówienie
/datum/ai_controller/robot_customer/proc/eat_order(obj/item/order_item, datum/venue/attending_venue)
	if(blackboard[BB_CUSTOMER_EATING])
		return
	blackboard[BB_CUSTOMER_EATING] = TRUE
	attending_venue.on_get_order(pawn, order_item)
	var/our_order = blackboard[BB_CUSTOMER_CURRENT_ORDER]
	if(isdatum(our_order))
		qdel(our_order)
	blackboard[BB_CUSTOMER_CURRENT_ORDER] = null
	var/mob/living/simple_animal/robot_customer/customer = pawn
	customer.set_order_bubble(null)

/datum/ai_controller/robot_customer/proc/dont_want_that()
	var/mob/living/simple_animal/robot_customer/customer = pawn
	var/datum/customer_data/customer_data = blackboard[BB_CUSTOMER_CUSTOMERINFO]
	customer.customer_say(customer_data.wrong_item_line)

///Ktoś ciągnie robota (wywoływane z can_be_pulled)
/datum/ai_controller/robot_customer/proc/on_get_pulled(mob/living/puller)
	var/mob/living/simple_animal/robot_customer/customer = pawn
	var/datum/customer_data/customer_data = blackboard[BB_CUSTOMER_CUSTOMERINFO]
	var/datum/venue/attending_venue = blackboard[BB_CUSTOMER_ATTENDING_VENUE]
	if(attending_venue.has_access(puller))
		customer.customer_say(customer_data.friendly_pull_line)
		return
	warn_greytider(puller)
	customer.resist()

///Kolejne ostrzeżenia, a za trzecim razem robot się broni
/datum/ai_controller/robot_customer/proc/warn_greytider(mob/living/greytider)
	var/mob/living/simple_animal/robot_customer/customer = pawn
	var/datum/venue/attending_venue = blackboard[BB_CUSTOMER_ATTENDING_VENUE]
	var/datum/customer_data/customer_data = blackboard[BB_CUSTOMER_CUSTOMERINFO]
	// Żywe moby mają tagi, więc REF jest stały
	attending_venue.mob_blacklist[REF(greytider)] += 1

	switch(attending_venue.mob_blacklist[REF(greytider)])
		if(1)
			customer.customer_say(customer_data.first_warning_line)
			return
		if(2)
			customer.customer_say(customer_data.second_warning_line)
			return
		if(3)
			customer.customer_say(customer_data.self_defense_line)
	blackboard[BB_CUSTOMER_CURRENT_TARGET] = greytider
	CancelActions()

/datum/ai_controller/robot_customer/proc/on_get_punched(datum/source, mob/living/living_hitter)
	SIGNAL_HANDLER
	if(!istype(living_hitter) || !living_hitter.combat_mode)
		return
	var/datum/venue/attending_venue = blackboard[BB_CUSTOMER_ATTENDING_VENUE]
	if(attending_venue.has_access(living_hitter))
		return
	INVOKE_ASYNC(src, PROC_REF(warn_greytider), living_hitter)


/////PLANOWANIE/////
/datum/ai_planning_subtree/robot_customer/SelectBehaviors(datum/ai_controller/controller, delta_time)
	if(controller.blackboard[BB_CUSTOMER_LEAVING])
		var/obj/machinery/restaurant_portal/exit_portal = robot_customer_exit_portal(controller)
		if(!exit_portal) //Portalu nie ma albo jest za daleko, robot po prostu się teleportuje
			qdel(controller.pawn)
			return SUBTREE_RETURN_FINISH_PLANNING
		controller.queue_behavior(/datum/ai_behavior/leave_venue)
		return SUBTREE_RETURN_FINISH_PLANNING

	var/mob/living/target = controller.blackboard[BB_CUSTOMER_CURRENT_TARGET]
	if(target)
		if(QDELETED(target) || target.stat == DEAD)
			controller.blackboard -= BB_CUSTOMER_CURRENT_TARGET
		else
			controller.queue_behavior(/datum/ai_behavior/break_spine, BB_CUSTOMER_CURRENT_TARGET)
			return SUBTREE_RETURN_FINISH_PLANNING

	var/datum/weakref/seat_ref = controller.blackboard[BB_CUSTOMER_MY_SEAT]
	var/obj/structure/holosign/robot_seat/seat_marker = seat_ref?.resolve()

	if(!seat_marker) //Nie mamy jeszcze miejsca
		controller.blackboard[BB_CUSTOMER_MY_SEAT] = null
		controller.queue_behavior(/datum/ai_behavior/find_seat)
		return SUBTREE_RETURN_FINISH_PLANNING

	controller.current_movement_target = seat_marker

	if(!controller.blackboard[BB_CUSTOMER_CURRENT_ORDER] && !controller.blackboard[BB_CUSTOMER_EATING])
		controller.queue_behavior(/datum/ai_behavior/order_food)
		return SUBTREE_RETURN_FINISH_PLANNING

	controller.queue_behavior(/datum/ai_behavior/wait_for_food)
	return SUBTREE_RETURN_FINISH_PLANNING


/////ZACHOWANIA/////
/datum/ai_behavior/find_seat
	action_cooldown = 8 SECONDS

/datum/ai_behavior/find_seat/perform(delta_time, datum/ai_controller/controller)
	. = ..()
	var/mob/living/simple_animal/robot_customer/customer_pawn = controller.pawn
	var/datum/customer_data/customer_data = controller.blackboard[BB_CUSTOMER_CUSTOMERINFO]
	var/datum/venue/attending_venue = controller.blackboard[BB_CUSTOMER_ATTENDING_VENUE]

	var/obj/structure/holosign/robot_seat/found_seat

	for(var/obj/structure/holosign/robot_seat/potential_seat in oview(7, controller.pawn))
		if(potential_seat.linked_venue != attending_venue) //Inny lokal
			continue
		if(attending_venue.linked_seats[potential_seat]) //Zajęte
			continue
		if(is_blocked_turf(get_turf(potential_seat)))
			continue
		var/mob/living/sitter = locate() in get_turf(potential_seat)
		if(sitter) //Ktoś na nim stoi
			continue
		found_seat = potential_seat
		break

	if(found_seat)
		customer_pawn.customer_say(pick(customer_data.found_seat_lines))
		controller.blackboard[BB_CUSTOMER_MY_SEAT] = WEAKREF(found_seat)
		attending_venue.linked_seats[found_seat] = customer_pawn
		finish_action(controller, TRUE)
		return

	// Mniej więcej 60% szans, że turysta ponarzeka co najmniej raz na minutę
	if(!controller.blackboard[BB_CUSTOMER_SAID_CANT_FIND_SEAT_LINE] || DT_PROB(1.5, delta_time))
		customer_pawn.customer_say(pick(customer_data.cant_find_seat_lines))
		controller.blackboard[BB_CUSTOMER_SAID_CANT_FIND_SEAT_LINE] = TRUE

	// Cierpliwość kończy się też na stojąco
	controller.blackboard[BB_CUSTOMER_PATIENCE] -= action_cooldown
	if(controller.blackboard[BB_CUSTOMER_PATIENCE] < 0)
		give_up(controller)

	finish_action(controller, FALSE)

/datum/ai_behavior/find_seat/proc/give_up(datum/ai_controller/controller)
	var/mob/living/simple_animal/robot_customer/customer_pawn = controller.pawn
	var/datum/customer_data/customer_data = controller.blackboard[BB_CUSTOMER_CUSTOMERINFO]
	var/datum/venue/attending_venue = controller.blackboard[BB_CUSTOMER_ATTENDING_VENUE]
	controller.blackboard[BB_CUSTOMER_LEAVING] = TRUE
	attending_venue.customers_lost += 1
	customer_pawn.customer_say(pick(customer_data.leave_mad_lines))
	customer_pawn.update_appearance()

///Robot dochodzi do miejsca, siada i zamawia
/datum/ai_behavior/order_food
	behavior_flags = AI_BEHAVIOR_REQUIRE_MOVEMENT
	required_distance = 0

/datum/ai_behavior/order_food/perform(delta_time, datum/ai_controller/controller)
	. = ..()
	var/mob/living/simple_animal/robot_customer/customer_pawn = controller.pawn
	var/datum/customer_data/customer_data = controller.blackboard[BB_CUSTOMER_CUSTOMERINFO]

	sit_down(controller)

	var/datum/venue/attending_venue = controller.blackboard[BB_CUSTOMER_ATTENDING_VENUE]
	controller.blackboard[BB_CUSTOMER_CURRENT_ORDER] = attending_venue.order_food(customer_pawn, customer_data)

	finish_action(controller, TRUE)

///Robot na swoim miejscu obraca się do stołu, a jeśli go nie ma, tak jak krzesło
/proc/robot_customer_sit_down(datum/ai_controller/controller)
	var/datum/weakref/seat_ref = controller.blackboard[BB_CUSTOMER_MY_SEAT]
	var/obj/structure/holosign/robot_seat/seat_marker = seat_ref?.resolve()
	var/turf/seat_turf = get_turf(seat_marker)
	if(!seat_marker || seat_turf != get_turf(controller.pawn))
		return
	var/table_dir = robot_seat_table_dir(seat_turf)
	if(table_dir)
		controller.pawn.setDir(table_dir)
		return
	var/obj/structure/chair/my_seat = locate(/obj/structure/chair) in seat_turf
	if(my_seat)
		controller.pawn.setDir(my_seat.dir)

/datum/ai_behavior/order_food/proc/sit_down(datum/ai_controller/controller)
	robot_customer_sit_down(controller)

///Robot czeka na zamówienie i sprawdza, czy nie leży przed nim na stole
/datum/ai_behavior/wait_for_food
	behavior_flags = AI_BEHAVIOR_REQUIRE_MOVEMENT | AI_BEHAVIOR_MOVE_AND_PERFORM
	required_distance = 0

/datum/ai_behavior/wait_for_food/perform(delta_time, datum/ai_controller/controller)
	. = ..()
	if(controller.blackboard[BB_CUSTOMER_EATING])
		finish_action(controller, TRUE)
		return

	controller.blackboard[BB_CUSTOMER_PATIENCE] -= delta_time * 10 // delta_time w sekundach, cierpliwość w decysekundach
	if(controller.blackboard[BB_CUSTOMER_PATIENCE] < 0 || controller.blackboard[BB_CUSTOMER_LEAVING])
		finish_action(controller, FALSE)
		return

	// Mniej więcej 40% szans na komentarz co minutę
	if(DT_PROB(0.85, delta_time))
		var/mob/living/simple_animal/robot_customer/customer_pawn = controller.pawn
		var/datum/customer_data/customer_data = controller.blackboard[BB_CUSTOMER_CUSTOMERINFO]
		customer_pawn.customer_say(pick(customer_data.wait_for_food_lines))

	robot_customer_sit_down(controller)

	// Czy zamówienie leży przed nami?
	var/datum/venue/attending_venue = controller.blackboard[BB_CUSTOMER_ATTENDING_VENUE]
	var/turf/infront_turf = get_step(controller.pawn, controller.pawn.dir)
	if(!infront_turf)
		return
	for(var/obj/item/I in infront_turf.contents)
		if(attending_venue.is_correct_order(I, controller.blackboard[BB_CUSTOMER_CURRENT_ORDER]))
			var/datum/ai_controller/robot_customer/customer = controller
			customer.eat_order(I, attending_venue)
			break

/datum/ai_behavior/wait_for_food/finish_action(datum/ai_controller/controller, succeeded)
	. = ..()
	var/mob/living/simple_animal/robot_customer/customer_pawn = controller.pawn
	if(QDELETED(customer_pawn))
		return
	// Przerwane, bo robot idzie komuś przyłożyć
	if(controller.blackboard[BB_CUSTOMER_CURRENT_TARGET])
		return
	// Jeszcze nie skończyliśmy czekać (np. przerwane przez CancelActions)
	if(!succeeded && controller.blackboard[BB_CUSTOMER_PATIENCE] >= 0 && !controller.blackboard[BB_CUSTOMER_LEAVING])
		return
	var/datum/customer_data/customer_data = controller.blackboard[BB_CUSTOMER_CUSTOMERINFO]
	var/datum/venue/attending_venue = controller.blackboard[BB_CUSTOMER_ATTENDING_VENUE]
	controller.blackboard[BB_CUSTOMER_LEAVING] = TRUE
	customer_pawn.set_order_bubble(null) //Też odświeża wygląd, np. francuską flagę przy wyjściu
	if(succeeded)
		customer_pawn.customer_say(pick(customer_data.leave_happy_lines))
	else
		attending_venue.customers_lost += 1
		customer_pawn.customer_say(pick(customer_data.leave_mad_lines))

///Robot wraca do portalu i znika
/datum/ai_behavior/leave_venue
	behavior_flags = AI_BEHAVIOR_REQUIRE_MOVEMENT
	required_distance = 1

/datum/ai_behavior/leave_venue/setup(datum/ai_controller/controller)
	. = ..()
	var/obj/machinery/restaurant_portal/exit_portal = robot_customer_exit_portal(controller)
	if(!exit_portal)
		return FALSE
	controller.current_movement_target = exit_portal

///Portal, którym robot wyjdzie: ten, którym przyszedł, a jeśli go nie ma, aktywny portal lokalu. Null, gdy żaden nie jest w zasięgu
/proc/robot_customer_exit_portal(datum/ai_controller/controller)
	var/datum/weakref/portal_ref = controller.blackboard[BB_CUSTOMER_EXIT_PORTAL]
	var/obj/machinery/restaurant_portal/portal = portal_ref?.resolve()
	if(QDELETED(portal))
		var/datum/venue/attending_venue = controller.blackboard[BB_CUSTOMER_ATTENDING_VENUE]
		portal = attending_venue?.restaurant_portal
	if(QDELETED(portal) || portal.z != controller.pawn.z || get_dist(portal, controller.pawn) > controller.max_target_distance)
		return null
	return portal

/datum/ai_behavior/leave_venue/perform(delta_time, datum/ai_controller/controller)
	. = ..()
	var/mob/living/pawn = controller.pawn
	pawn.visible_message("<span class='notice'>[pawn] wchodzi do portalu i znika.</span>")
	playsound(get_turf(pawn), 'sound/effects/phasein.ogg', 30, TRUE)
	finish_action(controller, TRUE)
	qdel(pawn)
