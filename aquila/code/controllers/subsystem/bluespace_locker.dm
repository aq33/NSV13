// AQUILA - Bluespace locker (port of aq33/tgstation#833), see aquila/code/modules/bluespace_locker/bluespace_locker.dm
SUBSYSTEM_DEF(bluespace_locker)
	name = "Bluespace Locker"
	flags = SS_NO_FIRE
	var/obj/structure/closet/bluespace/internal/internal_locker = null
	var/obj/structure/closet/bluespace/external/external_locker = null
	/// Reserved block holding the bluespace room
	var/datum/turf_reservation/room_reservation
	/// Turf inside the room that maps onto the external locker's turf for the mirage
	var/turf/room_origin

/datum/controller/subsystem/bluespace_locker/Initialize(start_timeofday)
	for(var/path in typesof(/obj/structure/closet/bluespace))
		GLOB.blacklisted_cargo_types[path] = TRUE
	if(load_room())
		bluespaceify_random_locker()
	return ..()

/datum/controller/subsystem/bluespace_locker/proc/load_room()
	var/datum/map_template/bluespace_locker/template = new
	room_reservation = SSmapping.RequestBlockReservation(template.width, template.height)
	if(!room_reservation)
		log_world("SSbluespace_locker: unable to reserve space for the bluespace locker room")
		return FALSE
	var/turf/bottom_left = locate(room_reservation.bottom_left_coords[1], room_reservation.bottom_left_coords[2], room_reservation.bottom_left_coords[3])
	if(!template.load(bottom_left))
		log_world("SSbluespace_locker: unable to load the bluespace locker room template")
		return FALSE
	for(var/turf/T as anything in room_reservation.reserved_turfs)
		var/obj/effect/landmark/bluespace_locker_origin/L = locate() in T
		if(L)
			room_origin = T
			qdel(L)
			break
	if(!internal_locker || !room_origin)
		log_world("SSbluespace_locker: the bluespace locker room template is missing its internal locker or origin landmark")
		return FALSE
	return TRUE

/datum/controller/subsystem/bluespace_locker/proc/bluespaceify_random_locker()
	if(external_locker || !internal_locker)
		return
	// basically any normal-looking locker that isn't a secure one
	var/static/list/valid_lockers = typecacheof(typesof(/obj/structure/closet) - typesof(/obj/structure/closet/body_bag)\
	- typesof(/obj/structure/closet/secure_closet) - typesof(/obj/structure/closet/cabinet)\
	- typesof(/obj/structure/closet/cardboard) - typesof(/obj/structure/closet/crate)\
	- typesof(/obj/structure/closet/supplypod) - typesof(/obj/structure/closet/stasis)\
	- typesof(/obj/structure/closet/abductor) - typesof(/obj/structure/closet/bluespace), only_root_path = TRUE)

	var/list/lockers_list = list()
	for(var/obj/structure/closet/L in world)
		if(isturf(L.loc) && !L.wall_mounted && is_station_level(L.z) && is_type_in_typecache(L, valid_lockers))
			lockers_list += L
	if(!length(lockers_list))
		// Congratulations, you managed to destroy all the lockers somehow.
		// Now let's make a new one.
		var/turf/target_turf = find_safe_turf()
		if(!target_turf && length(GLOB.blobstart))
			target_turf = get_turf(pick(GLOB.blobstart))
		if(!target_turf)
			CRASH("Unable to find a location for the bluespace locker")
		lockers_list += new /obj/structure/closet(target_turf)
	var/obj/structure/closet/L = pick(lockers_list)

	var/obj/structure/closet/bluespace/external/E = new(L.loc)
	E.name = L.name
	E.desc = L.desc
	E.dir = L.dir
	E.pixel_x = L.pixel_x
	E.pixel_y = L.pixel_y
	E.anchored = L.anchored
	E.icon = L.icon
	E.icon_state = L.icon_state
	E.icon_door = L.icon_door
	E.icon_door_override = L.icon_door_override
	E.icon_welded = L.icon_welded
	E.door_anim_time = L.door_anim_time
	E.door_hinge = L.door_hinge
	E.door_anim_angle = L.door_anim_angle
	E.door_anim_squish = L.door_anim_squish
	E.open_sound = L.open_sound
	E.close_sound = L.close_sound
	for(var/atom/movable/AM as anything in L.contents)
		AM.forceMove(E)
	if(L.opened)
		E.opened = TRUE
		E.density = FALSE
	else
		E.take_contents() // mapped lockers grab what lies on them with a timer that won't fire after the qdel below
	E.update_icon()
	qdel(L)

	relink_lockers()

/datum/controller/subsystem/bluespace_locker/proc/relink_lockers()
	if(!internal_locker)
		return
	room_reservation?.overmap_fallback = external_locker?.get_overmap() // NSV13 ship systems (alerts, get_overmap()) treat the room as part of the locker's ship
	internal_locker.update_mirage()
	if(external_locker)
		if(external_locker.opened)
			internal_locker.close()
		else
			external_locker.transfer_contents_to(internal_locker)
			internal_locker.open()
		external_locker.update_icon()
	internal_locker.update_icon()

/// The external locker was destroyed - pick a new one once the current destruction is done
/datum/controller/subsystem/bluespace_locker/proc/on_external_locker_lost()
	if(!initialized)
		return
	relink_lockers()
	addtimer(CALLBACK(src, PROC_REF(bluespaceify_random_locker)), 1)
