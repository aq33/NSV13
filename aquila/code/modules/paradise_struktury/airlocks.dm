// Śluzy z Paradise: klasyczna animacja klatkami (LEGACY_OVERLAYS) zamiast ruchomych części z Bee,
// sprite 32x40 w czterech kierunkach. Kierunek wybiera się jak w Paradise: w stronę sąsiedniej ściany
// (E/W = widok z przodu w poziomej ścianie, N/S = widok z boku w pionowej).

/obj/machinery/door/airlock
	LEGACY_OVERLAYS = TRUE
	anim_parts = ""
	// Bez KEEP_TOGETHER: grupa była przycinana do kafla i sprite 32x40 tracił górne 8 px (czubek drzwi w ścianie nad nimi)
	appearance_flags = TILE_BOUND | LONG_GLIDE | PIXEL_SCALE
	/// AQUILA - drzwi używają sprite'ów z Paradise i obracają się do ściany
	var/paradise_sprites = TRUE

/obj/machinery/door/airlock/Initialize(mapload)
	. = ..()
	if(!paradise_sprites)
		return
	paradise_face_walls()
	update_icon()
	if(!mapload)
		queue_smooth_neighbors(src)

/obj/machinery/door/airlock/Destroy()
	var/turf/T = get_turf(src)
	. = ..()
	if(paradise_sprites && T)
		queue_smooth_neighbors(T)

// NSV13 obraca śluzy statku po swojemu w Initialize, tu bierze górę wersja z Paradise
/obj/machinery/door/airlock/set_smooth_dir()
	. = ..()
	if(paradise_sprites)
		paradise_face_walls()

/obj/machinery/door/airlock/proc/paradise_face_walls()
	var/direction = paradise_door_direction(src)
	if(direction)
		setDir(direction)

// Śluza na dwa kafle ma stały kierunek z mapy
/obj/machinery/door/airlock/glass_large/paradise_face_walls()
	return

/// Kierunek jak get_current_direction() w Paradise: najpierw ściana, potem pełne okno, potem inne drzwi.
/proc/paradise_door_direction(atom/A)
	var/turf/here = get_turf(A)
	if(!here)
		return
	for(var/direction in GLOB.cardinals)
		if(isclosedturf(get_step(here, direction)))
			return direction
	for(var/direction in GLOB.cardinals)
		for(var/obj/structure/window/W in get_step(here, direction))
			if(W.fulltile)
				return direction
	for(var/direction in GLOB.cardinals)
		if(locate(/obj/machinery/door) in get_step(here, direction))
			return direction

// Zestawy montażowe wyglądają jak śluza, którą z nich zbudujemy
/obj/structure/door_assembly
	icon = 'aquila/icons/paradise/obj/doors/airlocks/station/public.dmi'
	overlays_file = 'aquila/icons/paradise/obj/doors/airlocks/station/overlays.dmi'

/obj/structure/door_assembly/Initialize(mapload)
	. = ..()
	var/obj/machinery/door/airlock/airlock = airlock_type
	if(ispath(airlock) && initial(airlock.paradise_sprites))
		icon = initial(airlock.icon)
		overlays_file = initial(airlock.overlays_file)
		var/direction = paradise_door_direction(src)
		if(direction)
			setDir(direction)
		update_icon()

// Brak w Paradise: zostają nasze śluzy z ruchomymi częściami
/obj/machinery/door/airlock/copper
	appearance_flags = TILE_BOUND | LONG_GLIDE | PIXEL_SCALE | KEEP_TOGETHER
	icon = 'icons/obj/doors/airlocks/station/copper.dmi'
	overlays_file = 'icons/obj/doors/airlocks/station/overlays.dmi'
	paradise_sprites = FALSE
	LEGACY_OVERLAYS = FALSE
	anim_parts = "left=-14,0;right=13,0"

/obj/machinery/door/airlock/arrivals_external
	appearance_flags = TILE_BOUND | LONG_GLIDE | PIXEL_SCALE | KEEP_TOGETHER
	paradise_sprites = FALSE
	LEGACY_OVERLAYS = FALSE

/obj/machinery/door/airlock/turbolift
	appearance_flags = TILE_BOUND | LONG_GLIDE | PIXEL_SCALE | KEEP_TOGETHER
	paradise_sprites = FALSE
	LEGACY_OVERLAYS = FALSE
	anim_parts = "left=-14,0;right=13,0"
