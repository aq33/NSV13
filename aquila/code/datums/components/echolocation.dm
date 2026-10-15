/**
 * Echolokacja, uproszczony port tg /datum/component/echolocation.
 *
 * tg robi to filtrami na plane masterach. U nas: czarna zasłona nad oświetleniem,
 * a na niej co chwilę pojawiają się białe obrysy rzeczy w zasięgu (obrazki tylko dla tego klienta).
 * Używają tego domeny „psyker” w bitrunningu.
 */
/datum/component/echolocation
	/// Radius of our echolocation.
	var/echo_range = 5
	/// Co ile odświeżamy obraz
	var/echo_interval = 0.5 SECONDS
	/// Time for the image to start fading out.
	var/image_expiry_time = 1 SECONDS
	/// Time for the image to fade out and delete itself.
	var/fade_out_time = 0.3 SECONDS
	/// Assoc list of world.time to (atom ref -> image)
	var/list/active_images = list()
	/// Typecache rzeczy, które zawsze pokazujemy
	var/static/list/echo_typecache
	/// Typecache rzeczy niebezpiecznych (czerwony obrys)
	var/static/list/danger_typecache
	COOLDOWN_DECLARE(next_echo)

/datum/component/echolocation/Initialize(echo_range = 5)
	var/mob/living/echolocator = parent
	if(!istype(echolocator))
		return COMPONENT_INCOMPATIBLE

	src.echo_range = echo_range

	if(!echo_typecache)
		echo_typecache = typecacheof(list(
			/turf/closed,
			/obj/machinery/door,
			/obj/structure,
			/obj/machinery,
			/obj/item,
			/mob/living,
		))
		danger_typecache = typecacheof(list(
			/turf/open/chasm,
			/turf/open/lava,
			/turf/open/space,
			/turf/open/openspace,
		))

	echolocator.overlay_fullscreen("echolocation", /atom/movable/screen/fullscreen/echo_dark)
	START_PROCESSING(SSfastprocess, src)

/datum/component/echolocation/Destroy(force)
	STOP_PROCESSING(SSfastprocess, src)
	var/mob/living/echolocator = parent
	echolocator.clear_fullscreen("echolocation")
	for(var/time in active_images)
		var/list/image_list = active_images[time]
		for(var/atom_ref in image_list)
			echolocator.client?.images -= image_list[atom_ref]
	active_images.Cut()
	return ..()

/datum/component/echolocation/process()
	var/mob/living/echolocator = parent
	if(echolocator.stat == DEAD || !echolocator.client)
		return
	if(!COOLDOWN_FINISHED(src, next_echo))
		return
	COOLDOWN_START(src, next_echo, echo_interval)
	echolocate()

/datum/component/echolocation/proc/echolocate()
	var/mob/living/echolocator = parent
	var/turf/center = get_turf(echolocator)
	if(!center)
		return

	var/list/known_refs = list()
	for(var/time in active_images)
		for(var/atom_ref in active_images[time])
			known_refs[atom_ref] = time

	var/current_time = "[world.time]"
	var/list/current = list()
	active_images[current_time] = current

	for(var/atom/seen_atom as anything in dview(echo_range, center))
		if(!seen_atom.alpha || seen_atom.invisibility > echolocator.see_invisible)
			continue
		var/danger = is_type_in_typecache(seen_atom, danger_typecache)
		if(!danger && !is_type_in_typecache(seen_atom, echo_typecache))
			continue
		if(seen_atom == echolocator)
			continue

		var/atom_ref = REF(seen_atom)
		if(known_refs[atom_ref])
			var/old_time = known_refs[atom_ref]
			var/image/old_image = active_images[old_time][atom_ref]
			active_images[old_time] -= atom_ref
			current[atom_ref] = old_image
			animate(old_image, alpha = 255, time = 0)
			continue

		var/image/echo = image(seen_atom, seen_atom)
		echo.plane = ABOVE_LIGHTING_PLANE
		echo.layer = 2
		echo.appearance_flags = RESET_COLOR | RESET_TRANSFORM | KEEP_APART
		echo.mouse_opacity = MOUSE_OPACITY_TRANSPARENT
		echo.pixel_x = 0
		echo.pixel_y = 0
		// czarne wypełnienie i biały (albo czerwony) obrys
		echo.color = list(0,0,0,0, 0,0,0,0, 0,0,0,0, 0,0,0,1, 0,0,0,0)
		echo.filters += filter(type = "outline", size = 1, color = danger ? "#ff4040" : "#ffffff")
		current[atom_ref] = echo
		echolocator.client.images += echo

	addtimer(CALLBACK(src, PROC_REF(fade_images), current_time), image_expiry_time)

/datum/component/echolocation/proc/fade_images(from_time)
	var/list/image_list = active_images[from_time]
	if(!length(image_list))
		active_images -= from_time
		return
	for(var/atom_ref in image_list)
		animate(image_list[atom_ref], alpha = 0, time = fade_out_time)
	addtimer(CALLBACK(src, PROC_REF(cleanup_images), from_time), fade_out_time + 0.2 SECONDS)

/datum/component/echolocation/proc/cleanup_images(from_time)
	var/mob/living/echolocator = parent
	var/list/image_list = active_images[from_time]
	for(var/atom_ref in image_list)
		echolocator.client?.images -= image_list[atom_ref]
	active_images -= from_time

/// Czarna zasłona pod obrazkami echolokacji, ale nad grą i oświetleniem
/atom/movable/screen/fullscreen/echo_dark
	icon_state = "blackimageoverlay"
	plane = ABOVE_LIGHTING_PLANE
	layer = 1
	show_when_dead = TRUE
