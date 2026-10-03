// AQUILA - Bluespace locker (port of aq33/tgstation#833, autor: Dejaku51)
// Losowa szafka na stacji staje się "bluespace lockerem" połączonym z ukrytym pokojem.
// Zamknięcie szafki z kimś w środku przenosi zawartość do pokoju i odwrotnie.
// Pokój jest ładowany jako szablon w zarezerwowanej przestrzeni przez SSbluespace_locker.

/area/bluespace_locker
	name = "Bluespace Locker"
	icon_state = "away"
	requires_power = FALSE
	has_gravity = STANDARD_GRAVITY
	dynamic_lighting = DYNAMIC_LIGHTING_FORCED
	area_flags = HIDDEN_AREA | UNIQUE_AREA

/// The room counts as being wherever the external locker currently is (radio, telecomms, crew monitor, pinpointers...)
/area/bluespace_locker/get_virtual_z(turf/T)
	var/obj/structure/closet/bluespace/external/external = SSbluespace_locker.external_locker
	if(!QDELETED(external))
		var/turf/external_turf = get_turf(external)
		if(external_turf && !istype(external_turf.loc, /area/bluespace_locker)) // the locker was somehow brought inside itself
			return external_turf.get_virtual_z_level()
	return ..()

/obj/structure/closet/bluespace
	name = "bluespace locker"

/// The locker on the other end of the link. Only the subsystem's internal/external pair is linked, a stray spawned bluespace locker acts like a normal one
/obj/structure/closet/bluespace/proc/get_other_locker()
	return null

/// Moves everything inside us into the other locker, dumping it out if that locker is already open
/obj/structure/closet/bluespace/proc/transfer_contents_to(obj/structure/closet/other)
	for(var/atom/movable/AM as anything in contents)
		AM.forceMove(other)
	if(other.opened)
		other.dump_contents()

/obj/structure/closet/bluespace/open(mob/living/user)
	var/obj/structure/closet/other = get_other_locker()
	if(!other)
		return ..()
	if(opened)
		return
	. = ..()
	if(!.)
		return
	other.close(user)
	dump_contents()

/obj/structure/closet/bluespace/close(mob/living/user)
	var/obj/structure/closet/other = get_other_locker()
	if(!other)
		return ..()
	if(!opened)
		return FALSE
	. = ..()
	if(!.)
		return
	transfer_contents_to(other)
	other.open(user)

// Internal locker - the "portal" inside the bluespace room. Mimics the look of the external locker.

/obj/structure/closet/bluespace/internal
	name = "bluespace locker portal"
	icon_state = null
	desc = ""
	cutting_tool = null
	can_weld_shut = FALSE
	anchorable = FALSE
	anchored = TRUE
	door_anim_time = 0 // the door overlays come from the external locker's icon, the stock animation can't draw them
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF
	var/list/mirage_whitelist = list()

/obj/structure/closet/bluespace/internal/Initialize(mapload)
	. = ..()
	if(SSbluespace_locker.internal_locker && SSbluespace_locker.internal_locker != src)
		return INITIALIZE_HINT_QDEL
	SSbluespace_locker.internal_locker = src

/obj/structure/closet/bluespace/internal/Destroy()
	if(SSbluespace_locker.internal_locker == src)
		SSbluespace_locker.internal_locker = null
	mirage_whitelist = null
	return ..()

/obj/structure/closet/bluespace/internal/get_other_locker()
	if(SSbluespace_locker.internal_locker != src)
		return null
	return SSbluespace_locker.external_locker

/obj/structure/closet/bluespace/internal/can_open(mob/living/user)
	var/obj/structure/closet/other = get_other_locker()
	if(!other)
		return FALSE
	if(!other.opened)
		return TRUE
	return other.can_close(user)

/obj/structure/closet/bluespace/internal/can_close(mob/living/user)
	var/obj/structure/closet/other = get_other_locker()
	if(!other || other.opened)
		return TRUE
	return other.can_open(user)

/obj/structure/closet/bluespace/internal/tool_interact(obj/item/W, mob/user)
	return

/obj/structure/closet/bluespace/internal/attack_hand(mob/living/user)
	var/obj/structure/closet/other = get_other_locker()
	if(!other || other.opened || !(other.welded || other.locked))
		return ..()
	// The other side is welded or locked - push it open from here
	user.changeNext_move(CLICK_CD_BREAKOUT)
	user.last_special = world.time + CLICK_CD_BREAKOUT
	if(ismovableatom(other.loc))
		var/atom/movable/AM = other.loc
		AM.relay_container_resist(user, other)
		return
	other.visible_message("<span class='warning'>[other] begins to shake violently!</span>")
	to_chat(user, "<span class='notice'>You start pushing the door open... (this will take about [DisplayTimeText(other.breakout_time)].)</span>")
	if(do_after(user, other.breakout_time, target = src))
		if(QDELETED(other) || user.stat != CONSCIOUS || other.opened || (!other.locked && !other.welded))
			return
		other.bust_open()
		user.visible_message("<span class='danger'>[user] successfully broke out of [other]!</span>",
							"<span class='notice'>You successfully break out of [other]!</span>")
	else if(!QDELETED(other) && !other.opened)
		to_chat(user, "<span class='warning'>You fail to break out of [other]!</span>")

/obj/structure/closet/bluespace/internal/update_icon()
	cut_overlays()
	var/obj/structure/closet/other = get_other_locker()
	if(!other)
		other = src
	var/mutable_appearance/masked_icon = mutable_appearance('aquila/icons/obj/bluespace_locker.dmi', "bluespace_locker_mask")
	masked_icon.appearance_flags = KEEP_TOGETHER
	var/mutable_appearance/masking_icon = mutable_appearance(other.icon, other.icon_state)
	masking_icon.blend_mode = BLEND_MULTIPLY
	masked_icon.add_overlay(masking_icon)
	add_overlay(masked_icon)
	if(!opened)
		layer = OBJ_LAYER
		add_overlay(image(other.icon, "[other.icon_door || other.icon_state]_door"))
	else
		layer = BELOW_OBJ_LAYER
		add_overlay(image(other.icon, "[other.icon_door_override ? other.icon_door : other.icon_state]_open"))

/obj/structure/closet/bluespace/internal/proc/update_mirage()
	var/area/A = get_area(src)
	for(var/atom/movable/M in A)
		if(M == src) // in case someone somehow manages to teleport the bluespace locker inside of itself
			continue
		M.update_parallax_contents()
	var/turf/internal_origin = SSbluespace_locker.room_origin
	var/turf/external_origin = get_turf(get_other_locker())
	mirage_whitelist.Cut()
	if(external_origin)
		for(var/turf/T in view(11, external_origin))
			mirage_whitelist[T] = TRUE
	for(var/turf/open/space/bluespace_locker_mirage/T in A)
		T.internal_origin = internal_origin
		T.external_origin = external_origin
		T.turf_whitelist = mirage_whitelist
		T.update_mirage()

// External locker - the locker on the station that replaced a random normal one

/obj/structure/closet/bluespace/external/Initialize(mapload)
	. = ..()
	if(SSbluespace_locker.external_locker && SSbluespace_locker.external_locker != src)
		return INITIALIZE_HINT_QDEL
	SSbluespace_locker.external_locker = src

/obj/structure/closet/bluespace/external/get_other_locker()
	if(SSbluespace_locker.external_locker != src)
		return null
	return SSbluespace_locker.internal_locker

/obj/structure/closet/bluespace/external/Destroy()
	if(SSbluespace_locker.external_locker == src)
		SSbluespace_locker.external_locker = null
		SSbluespace_locker.on_external_locker_lost()
	return ..()

/obj/structure/closet/bluespace/external/can_open(mob/living/user)
	return !(welded || locked)

/obj/structure/closet/bluespace/external/can_close(mob/living/user)
	return !(welded || locked)

/obj/structure/closet/bluespace/external/Moved(atom/OldLoc, Dir)
	. = ..()
	var/obj/structure/closet/bluespace/internal/C = get_other_locker()
	C?.update_mirage()

/obj/structure/closet/bluespace/external/afterShuttleMove(turf/oldT, list/movement_force, shuttle_dir, shuttle_preferred_direction, move_dir, rotation)
	. = ..()
	var/obj/structure/closet/bluespace/internal/C = get_other_locker()
	C?.update_mirage()

/obj/effect/landmark/bluespace_locker_origin
	name = "bluespace locker origin"

// Mirage - shows the surroundings of the external locker around the bluespace room

/turf/open/space/bluespace_locker_mirage
	density = TRUE
	blocks_air = TRUE
	name = "holographic projection"
	desc = "A holographic projection of the area surrounding the bluespace locker"
	var/turf/internal_origin
	var/turf/external_origin
	var/turf/external_origin_prev
	var/turf/external_origin_prev_prev
	var/external_origin_prev_time = -1
	var/list/turf_whitelist
	var/reset_timer_id

/turf/open/space/bluespace_locker_mirage/CanBuildHere()
	return FALSE

/turf/open/space/bluespace_locker_mirage/proc/update_mirage()
	if(!internal_origin || !external_origin)
		vis_contents.Cut()
		cut_overlays()
		external_origin_prev = null
		return
	if(external_origin == external_origin_prev)
		return
	if(world.time == external_origin_prev_time)
		external_origin_prev = external_origin_prev_prev
	cut_overlays()
	var/glide_dir = 0
	if(external_origin_prev && external_origin_prev.z == external_origin.z && abs(external_origin.x - external_origin_prev.x) <= 1 && abs(external_origin.y - external_origin_prev.y) <= 1)
		glide_dir = get_dir(external_origin_prev, external_origin)
	var/turf/target_turf = locate(external_origin.x + x - internal_origin.x, external_origin.y + y - internal_origin.y, external_origin.z)
	if(!target_turf || (turf_whitelist && !turf_whitelist[target_turf]))
		vis_contents.Cut()
		var/mutable_appearance/M = mutable_appearance('icons/turf/space.dmi', "black")
		M.layer = TURF_LAYER
		M.plane = FLOOR_PLANE
		add_overlay(M)
	else
		vis_contents = list(target_turf)
		if(glide_dir)
			glide_mirage(target_turf, glide_dir)
	external_origin_prev_time = world.time
	external_origin_prev_prev = external_origin_prev
	external_origin_prev = external_origin

/// Smoothly scrolls the projection when the external locker moves by one tile
/turf/open/space/bluespace_locker_mirage/proc/glide_mirage(turf/target_turf, glide_dir)
	var/dx = 0
	var/dy = 0
	var/px = 0
	var/py = 0
	var/add_reset_timer = FALSE
	if(glide_dir & NORTH)
		dy++
	if(glide_dir & SOUTH)
		dy--
	if(glide_dir & EAST)
		dx++
	if(glide_dir & WEST)
		dx--
	var/list/fullbrights = list()
	var/area/A = target_turf.loc
	if(!IS_DYNAMIC_LIGHTING(A))
		fullbrights += fullbright_appearance()
	for(var/cdir in GLOB.cardinals)
		if(!(glide_dir & cdir))
			continue
		var/odir = turn(cdir, 180)
		var/turf/T = get_step(src, odir)
		if(T && T.type != /turf/open/space/bluespace_locker_mirage)
			vis_contents += get_step(target_turf, odir)
			add_reset_timer = TRUE
			if(odir == WEST)
				px = -32
			if(odir == SOUTH)
				py = -32
			if(!IS_DYNAMIC_LIGHTING(A))
				var/mutable_appearance/F = fullbright_appearance()
				switch(odir)
					if(NORTH)
						F.pixel_y = 32
					if(SOUTH)
						F.pixel_y = -32
					if(EAST)
						F.pixel_x = 32
					if(WEST)
						F.pixel_x = -32
				fullbrights += F
	for(var/mutable_appearance/F as anything in fullbrights)
		F.pixel_x -= px // cancel out the pixel_x/y in the parent
		F.pixel_y -= py
	add_overlay(fullbrights)
	if(add_reset_timer)
		reset_timer_id = addtimer(CALLBACK(src, PROC_REF(reset_to_self)), world.tick_lag * 4, TIMER_UNIQUE | TIMER_OVERRIDE | TIMER_STOPPABLE)
	else if(reset_timer_id)
		deltimer(reset_timer_id)
		reset_timer_id = null
	pixel_x = px + dx * 32
	pixel_y = py + dy * 32
	animate(src, pixel_x = px, pixel_y = py, time = world.tick_lag * 4, flags = ANIMATION_END_NOW)

/turf/open/space/bluespace_locker_mirage/proc/fullbright_appearance()
	var/mutable_appearance/F = mutable_appearance('icons/effects/alphacolors.dmi', "white", LIGHTING_LAYER, LIGHTING_PLANE)
	F.blend_mode = BLEND_ADD
	return F

/turf/open/space/bluespace_locker_mirage/proc/reset_to_self()
	reset_timer_id = null
	external_origin_prev = null
	update_mirage()

/datum/map_template/bluespace_locker
	name = "Bluespace locker room"
	mappath = 'aquila/_maps/templates/bluespace_locker.dmm'

// Survival capsules must not overwrite the room
/datum/map_template/shelter/New()
	. = ..()
	banned_areas[/area/bluespace_locker] = TRUE
