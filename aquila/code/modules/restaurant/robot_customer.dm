///Robot-turysta, który przychodzi przez portal coś zjeść albo wypić
/mob/living/simple_animal/robot_customer
	name = "robot-turysta"
	desc = "Ciekawe, co zamówi..."
	maxHealth = 150
	health = 150
	gender = NEUTER
	icon = 'aquila/icons/mob/tourists.dmi'
	icon_state = "amerifat"
	icon_living = "amerifat"
	can_have_ai = FALSE
	AIStatus = AI_OFF
	del_on_death = TRUE
	mob_biotypes = list(MOB_ROBOTIC, MOB_HUMANOID)
	sentience_type = SENTIENCE_ARTIFICIAL
	ai_controller = /datum/ai_controller/robot_customer
	unsuitable_atmos_damage = 0
	minbodytemp = 0
	maxbodytemp = 1000
	do_footstep = TRUE
	speak_emote = list("mówi")
	///Stan ikony ubrania
	var/clothes_set = "amerifat_clothes"
	///Dymek z zamówieniem nad głową
	var/image/order_bubble

/mob/living/simple_animal/robot_customer/Initialize(mapload, datum/customer_data/customer_data = /datum/customer_data/american, datum/venue/attending_venue)
	ADD_TRAIT(src, TRAIT_NOMOBSWAP, INNATE_TRAIT)
	ADD_TRAIT(src, TRAIT_NO_TELEPORT, INNATE_TRAIT)
	if(!attending_venue)
		attending_venue = SSrestaurant.get_venue(/datum/venue/restaurant)
	var/datum/customer_data/customer_info = SSrestaurant.get_customer(customer_data)
	clothes_set = pick(customer_info.clothing_sets)
	ai_controller = customer_info.ai_controller_used
	. = ..()
	ai_controller.blackboard[BB_CUSTOMER_CUSTOMERINFO] = customer_info
	ai_controller.blackboard[BB_CUSTOMER_ATTENDING_VENUE] = attending_venue
	ai_controller.blackboard[BB_CUSTOMER_PATIENCE] = customer_info.total_patience
	icon = customer_info.base_icon
	icon_state = customer_info.base_icon_state
	icon_living = icon_state
	name = "[pick(customer_info.name_prefixes)]-bot"
	real_name = name
	color = rgb(rand(80, 255), rand(80, 255), rand(80, 255))
	update_appearance()

///Sprzątamy miejsce i listę gości, gdy robot wychodzi albo ginie
/mob/living/simple_animal/robot_customer/Destroy()
	var/datum/venue/attending_venue = ai_controller?.blackboard[BB_CUSTOMER_ATTENDING_VENUE]
	if(attending_venue)
		attending_venue.current_visitors -= src
		var/datum/weakref/seat_ref = ai_controller.blackboard[BB_CUSTOMER_MY_SEAT]
		var/obj/structure/holosign/robot_seat/our_seat = seat_ref?.resolve()
		if(our_seat && attending_venue.linked_seats[our_seat] == src)
			attending_venue.linked_seats[our_seat] = null
	order_bubble = null
	return ..()

/mob/living/simple_animal/robot_customer/spawn_gibs()
	new /obj/effect/gibspawner/robot(drop_location(), src)

/mob/living/simple_animal/robot_customer/update_overlays()
	. = ..()
	var/datum/customer_data/customer_info = ai_controller?.blackboard[BB_CUSTOMER_CUSTOMERINFO]
	if(!customer_info)
		return

	var/new_underlays = customer_info.get_underlays(src)
	if(new_underlays)
		underlays.Cut()
		underlays += new_underlays

	var/mutable_appearance/features = mutable_appearance(icon, "[icon_state]_features")
	features.appearance_flags = RESET_COLOR
	. += features

	var/mutable_appearance/clothes = mutable_appearance(icon, clothes_set)
	clothes.appearance_flags = RESET_COLOR
	. += clothes

	var/bonus_overlays = customer_info.get_overlays(src)
	if(bonus_overlays)
		. += bonus_overlays

	if(order_bubble)
		. += order_bubble

///Ustawia (albo zdejmuje, gdy null) dymek z zamówieniem
/mob/living/simple_animal/robot_customer/proc/set_order_bubble(image/food_image)
	if(food_image)
		var/mutable_appearance/bubble = new(food_image)
		bubble.pixel_y = 24
		bubble.pixel_x = 12
		bubble.appearance_flags = RESET_COLOR | KEEP_APART
		bubble.layer = ABOVE_MOB_LAYER
		bubble.plane = GAME_PLANE
		order_bubble = bubble
	else
		order_bubble = null
	update_appearance()

///Mowa robota razem z jego dźwiękiem
/mob/living/simple_animal/robot_customer/proc/customer_say(message)
	if(!message || stat)
		return
	say(message, forced = "robot customer")
	var/datum/customer_data/customer_info = ai_controller?.blackboard[BB_CUSTOMER_CUSTOMERINFO]
	if(customer_info?.speech_sound)
		playsound(src, customer_info.speech_sound, 30, extrarange = MEDIUM_RANGE_SOUND_EXTRARANGE, falloff_distance = 5)

/mob/living/simple_animal/robot_customer/examine(mob/user)
	. = ..()
	var/wanted_item = ai_controller?.blackboard[BB_CUSTOMER_CURRENT_ORDER]
	if(wanted_item)
		var/datum/venue/attending_venue = ai_controller.blackboard[BB_CUSTOMER_ATTENDING_VENUE]
		. += "<span class='notice'>Zamówienie: [attending_venue.get_order_name(wanted_item)].</span>"
		. += "<span class='notice'>Podaj mu je do ręki albo połóż na stole przed nim.</span>"

/mob/living/simple_animal/robot_customer/bullet_act(obj/item/projectile/Proj, def_zone, piercing_hit = FALSE)
	. = ..()
	if(!Proj.nodamage && (Proj.damage || Proj.stamina) && isliving(Proj.firer))
		report_harm(Proj.firer)

/mob/living/simple_animal/robot_customer/hitby(atom/movable/AM, skipcatch, hitpush = TRUE, blocked = FALSE, datum/thrownthing/throwingdatum)
	. = ..()
	if(isitem(AM))
		var/obj/item/thrown_item = AM
		if(thrown_item.throwforce && throwingdatum?.thrower)
			report_harm(throwingdatum.thrower)

/mob/living/simple_animal/robot_customer/attack_animal(mob/living/simple_animal/M)
	. = ..()
	if(.)
		report_harm(M)

/mob/living/simple_animal/robot_customer/attack_paw(mob/living/carbon/monkey/M)
	. = ..()
	if(M.combat_mode)
		report_harm(M)

///Przekazuje AI, kto skrzywdził robota
/mob/living/simple_animal/robot_customer/proc/report_harm(mob/living/attacker)
	var/datum/ai_controller/robot_customer/controller = ai_controller
	if(istype(controller) && stat != DEAD)
		controller.on_harmed(attacker)

///Ciągnięcie robota: obsługa lokalu może go prowadzić, reszta dostaje ostrzeżenie
/mob/living/simple_animal/robot_customer/can_be_pulled(user, grab_state, force)
	. = ..()
	if(!. || !isliving(user))
		return
	var/datum/ai_controller/robot_customer/controller = ai_controller
	if(istype(controller))
		INVOKE_ASYNC(controller, TYPE_PROC_REF(/datum/ai_controller/robot_customer, on_get_pulled), user)
