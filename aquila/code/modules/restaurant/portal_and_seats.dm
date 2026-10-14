/////PORTAL/////
///Brama, przez którą przychodzą i odchodzą roboty-turyści
/obj/machinery/restaurant_portal
	name = "portal restauracyjny"
	desc = "Brama tylko dla robotów, prowadząca prosto do cudów kuchni stacji kosmicznej. Otwiera się terminalem lokalu albo kartą z dostępem."
	icon = 'aquila/icons/obj/restaurant/restaurant_portal.dmi'
	icon_state = "portal"
	anchored = TRUE
	density = FALSE
	layer = BELOW_OBJ_LAYER
	use_power = NO_POWER_USE
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF
	///Lokal obsługiwany przez ten portal. Typ zamieniany w Initialize na instancję
	var/datum/venue/linked_venue = /datum/venue/restaurant

/obj/machinery/restaurant_portal/Initialize(mapload)
	. = ..()
	linked_venue = SSrestaurant.get_venue(linked_venue)
	// Lokal ma jeden portal. Nowy (np. postawiony przez admina) przejmuje gości
	linked_venue.restaurant_portal = src
	update_appearance()

/obj/machinery/restaurant_portal/Destroy()
	if(linked_venue?.restaurant_portal == src)
		linked_venue.restaurant_portal = null
		linked_venue.close()
		linked_venue.update_machines()
	linked_venue = null
	return ..()

/obj/machinery/restaurant_portal/update_overlays()
	. = ..()
	if(!linked_venue?.open)
		. += mutable_appearance(icon, "portal_door")

/obj/machinery/restaurant_portal/examine(mob/user)
	. = ..()
	. += "<span class='notice'>Lokal: [linked_venue.display_name] ([linked_venue.open ? "otwarty" : "zamknięty"]).</span>"

/obj/machinery/restaurant_portal/attack_hand(mob/living/user)
	. = ..()
	if(.)
		return
	var/obj/item/card/id/used_id = user.get_idcard(TRUE)
	if(!used_id)
		return
	if(!linked_venue.has_access(user))
		to_chat(user, "<span class='warning'>Ta karta nie ma dostępu do tego lokalu.</span>")
		return TRUE
	linked_venue.toggle_open(user)
	to_chat(user, "<span class='notice'>[linked_venue.open ? "Otwierasz" : "Zamykasz"] lokal: [linked_venue.display_name].</span>")
	return TRUE

/obj/machinery/restaurant_portal/restaurant
	name = "portal restauracji"
	linked_venue = /datum/venue/restaurant

/obj/machinery/restaurant_portal/bar
	name = "portal baru"
	linked_venue = /datum/venue/bar


/////MIEJSCA DLA GOŚCI/////
///Hologram oznaczający miejsce, na którym może usiąść robot
/obj/structure/holosign/robot_seat
	name = "miejsce dla gościa"
	desc = "Hologram wskazujący robotom-turystom, gdzie mogą usiąść. Lepiej na nim nie stawać."
	icon = 'aquila/icons/obj/restaurant/restaurant_portal.dmi'
	icon_state = "eating_zone"
	density = FALSE
	layer = BELOW_MOB_LAYER
	var/datum/venue/linked_venue = /datum/venue/restaurant

/obj/structure/holosign/robot_seat/Initialize(mapload)
	. = ..()
	// Zwykłe hologramy rysują się nad mobami, miejsce ma być pod robotem
	if(LAZYLEN(managed_vis_overlays))
		SSvis_overlays.remove_vis_overlay(src, managed_vis_overlays)
	alpha = 255
	linked_venue = SSrestaurant.get_venue(linked_venue)
	linked_venue.linked_seats[src] = null

/obj/structure/holosign/robot_seat/Destroy()
	if(istype(linked_venue))
		linked_venue.linked_seats -= src
	linked_venue = null
	return ..()

///Miejsca nie da się rozbić ręką, zdejmuje się je projektorem albo z terminala
/obj/structure/holosign/robot_seat/attack_hand(mob/living/user)
	return

/obj/structure/holosign/robot_seat/restaurant
	name = "miejsce w restauracji"
	linked_venue = /datum/venue/restaurant

/obj/structure/holosign/robot_seat/bar
	name = "miejsce w barze"
	linked_venue = /datum/venue/bar

///Projektor miejsc dla gości
/obj/item/holosign_creator/robot_seat
	name = "projektor miejsc dla gości"
	desc = "Stawia holograficzne miejsca, na których siadają roboty-turyści. Kliknij hologram jeszcze raz, żeby go zdjąć."
	icon = 'aquila/icons/obj/restaurant/seat_projector.dmi'
	icon_state = "signmaker_service"
	creation_time = 1 SECONDS
	holosign_type = /obj/structure/holosign/robot_seat/restaurant
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF

/obj/item/holosign_creator/robot_seat/afterattack(atom/target, mob/user, proximity_flag)
	if(proximity_flag)
		var/obj/structure/holosign/robot_seat/seat = locate(/obj/structure/holosign/robot_seat) in get_turf(target)
		if(seat && seat.type != holosign_type)
			to_chat(user, "<span class='warning'>Tu jest już miejsce innego lokalu.</span>")
			return
		if(seat && seat.linked_venue.linked_seats[seat])
			to_chat(user, "<span class='warning'>Na tym miejscu ktoś siedzi.</span>")
			return
	return ..()

///Ręczne wciśnięcie nie kasuje wszystkich miejsc naraz, robi się to z terminala
/obj/item/holosign_creator/robot_seat/attack_self(mob/user)
	return

/obj/item/holosign_creator/robot_seat/restaurant
	name = "projektor miejsc restauracji"
	holosign_type = /obj/structure/holosign/robot_seat/restaurant

/obj/item/holosign_creator/robot_seat/bar
	name = "projektor miejsc baru"
	holosign_type = /obj/structure/holosign/robot_seat/bar
