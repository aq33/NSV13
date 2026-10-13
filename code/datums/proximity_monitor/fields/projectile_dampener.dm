
//Generic projectile dampening field, the projector decides what happens to captured projectiles via COMSIG_DAMPENER_CAPTURE/RELEASE.
//Used by the MODsuit projectile dampener module. Only use square radius for this!
/datum/proximity_monitor/advanced/projectile_dampener
	var/static/image/edgeturf_south = image('icons/effects/fields.dmi', icon_state = "projectile_dampen_south")
	var/static/image/edgeturf_north = image('icons/effects/fields.dmi', icon_state = "projectile_dampen_north")
	var/static/image/edgeturf_west = image('icons/effects/fields.dmi', icon_state = "projectile_dampen_west")
	var/static/image/edgeturf_east = image('icons/effects/fields.dmi', icon_state = "projectile_dampen_east")
	var/static/image/northwest_corner = image('icons/effects/fields.dmi', icon_state = "projectile_dampen_northwest")
	var/static/image/southwest_corner = image('icons/effects/fields.dmi', icon_state = "projectile_dampen_southwest")
	var/static/image/northeast_corner = image('icons/effects/fields.dmi', icon_state = "projectile_dampen_northeast")
	var/static/image/southeast_corner = image('icons/effects/fields.dmi', icon_state = "projectile_dampen_southeast")
	var/static/image/generic_edge = image('icons/effects/fields.dmi', icon_state = "projectile_dampen_generic")
	var/list/obj/item/projectile/tracked = list()
	var/list/obj/item/projectile/staging = list()
	// lazylist that keeps track of the overlays added to the edge of the field
	var/list/edgeturf_effects

/datum/proximity_monitor/advanced/projectile_dampener/New(atom/_host, range, _ignore_if_not_on_turf = TRUE, atom/projector)
	..()
	RegisterSignal(projector, COMSIG_PARENT_QDELETING, PROC_REF(on_projector_del))
	recalculate_field()
	START_PROCESSING(SSfastprocess, src)

/datum/proximity_monitor/advanced/projectile_dampener/Destroy()
	STOP_PROCESSING(SSfastprocess, src)
	for(var/obj/item/projectile/projectile in tracked)
		release_projectile(projectile)
	return ..()

/datum/proximity_monitor/advanced/projectile_dampener/process()
	var/list/ranged = list()
	for(var/obj/item/projectile/projectile in range(current_range, get_turf(host)))
		ranged += projectile
	for(var/obj/item/projectile/projectile in tracked)
		if(!(projectile in ranged) || !projectile.loc)
			release_projectile(projectile)

/datum/proximity_monitor/advanced/projectile_dampener/setup_edge_turf(turf/target)
	. = ..()
	var/image/overlay = get_edgeturf_overlay(get_edgeturf_direction(target))
	var/obj/effect/abstract/effect = new(target) // Makes the field visible to players.
	effect.icon = overlay.icon
	effect.icon_state = overlay.icon_state
	effect.mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	effect.layer = ABOVE_ALL_MOB_LAYER
	LAZYSET(edgeturf_effects, target, effect)

/datum/proximity_monitor/advanced/projectile_dampener/cleanup_edge_turf(turf/target)
	. = ..()
	var/obj/effect/abstract/effect = LAZYACCESS(edgeturf_effects, target)
	LAZYREMOVE(edgeturf_effects, target)
	if(effect)
		qdel(effect)

/datum/proximity_monitor/advanced/projectile_dampener/proc/get_edgeturf_overlay(direction)
	switch(direction)
		if(NORTH)
			return edgeturf_north
		if(SOUTH)
			return edgeturf_south
		if(EAST)
			return edgeturf_east
		if(WEST)
			return edgeturf_west
		if(NORTHEAST)
			return northeast_corner
		if(NORTHWEST)
			return northwest_corner
		if(SOUTHEAST)
			return southeast_corner
		if(SOUTHWEST)
			return southwest_corner
		else
			return generic_edge

/datum/proximity_monitor/advanced/projectile_dampener/proc/capture_projectile(obj/item/projectile/projectile)
	if(projectile in tracked)
		return
	SEND_SIGNAL(src, COMSIG_DAMPENER_CAPTURE, projectile)
	tracked += projectile

/datum/proximity_monitor/advanced/projectile_dampener/proc/release_projectile(obj/item/projectile/projectile)
	SEND_SIGNAL(src, COMSIG_DAMPENER_RELEASE, projectile)
	tracked -= projectile

/datum/proximity_monitor/advanced/projectile_dampener/proc/on_projector_del(datum/source)
	SIGNAL_HANDLER

	qdel(src)

/datum/proximity_monitor/advanced/projectile_dampener/field_edge_uncrossed(atom/movable/movable, turf/location)
	if(istype(movable, /obj/item/projectile) && get_dist(movable, host) > current_range)
		if(movable in tracked)
			release_projectile(movable)

/datum/proximity_monitor/advanced/projectile_dampener/field_edge_crossed(atom/movable/movable, turf/location)
	if(istype(movable, /obj/item/projectile) && !(movable in tracked))
		capture_projectile(movable)
