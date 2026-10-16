// Okna, kraty i dźwigary z Paradise. Pełne okna są 32x40 z bitmaską i osobną nakładką ramy (edges),
// cienkie okna, kraty i dźwigary biorą stany z połączonego structures.dmi (Paradise + nasze brakujące).

/obj/structure/window
	icon = 'aquila/icons/paradise/obj/structures.dmi'
	/// AQUILA - plik z ramą pełnego okna, stan "[smoothing_junction]"
	var/edge_overlay_file
	var/mutable_appearance/edge_overlay
	/// AQUILA - nieprzezroczyste tło pod szybą
	var/mutable_appearance/glass_backing

/obj/structure/window/bitmask_connects_to(turf/T)
	return paradise_structure_connects(T, src)

/obj/structure/window/bitmask_smoothed()
	for(var/obj/machinery/door/airlock/A in get_step(src, SOUTH))
		if(A.paradise_sprites)
			A.paradise_face_walls()
	cut_overlay(edge_overlay)
	edge_overlay = null
	update_glass_backing()
	if(!edge_overlay_file)
		return
	edge_overlay = mutable_appearance(edge_overlay_file, "[smoothing_junction]", layer + 0.01, appearance_flags = RESET_COLOR)
	add_overlay(edge_overlay)

/// Szyba Paradise jest półprzezroczysta, a na naszych mapach pod oknami leżą podłogi, kable i naklejki zamiast samej kraty.
/// Pod szybę idzie nieprzezroczyste, ciemne tło w kształcie okna, żeby nie było widać, co jest pod nim.
/obj/structure/window/proc/update_glass_backing()
	underlays -= glass_backing
	glass_backing = null
	if(!bitmask_smooth)
		return
	glass_backing = mutable_appearance(icon, icon_state)
	// Kolor stały, alfa razy 10: każdy piksel okna staje się pełny
	glass_backing.color = list(0,0,0,0, 0,0,0,0, 0,0,0,0, 0,0,0,10, 0.11,0.15,0.2,0)
	glass_backing.appearance_flags = RESET_COLOR | RESET_ALPHA
	underlays += glass_backing

// Odkręcone okno nie łączy się z niczym
/obj/structure/window/calculate_bitmask_junction()
	if(!anchored)
		return 0
	return ..()

/obj/structure/window/fulltile
	icon = 'aquila/icons/paradise/obj/smooth_structures/windows/32x40window.dmi'
	icon_state = "window-0"
	base_icon_state = "window"
	edge_overlay_file = 'aquila/icons/paradise/obj/smooth_structures/windows/window_edges.dmi'
	legacy_smooth = FALSE
	bitmask_smooth = TRUE
	alpha = 255
	color = null

/obj/structure/window/reinforced/fulltile
	icon = 'aquila/icons/paradise/obj/smooth_structures/windows/32x40reinforced_window.dmi'
	icon_state = "reinforced_window-0"
	base_icon_state = "reinforced_window"
	edge_overlay_file = 'aquila/icons/paradise/obj/smooth_structures/windows/reinforced_window_edges.dmi'
	legacy_smooth = FALSE
	bitmask_smooth = TRUE
	alpha = 255
	color = null

/obj/structure/window/plasma/fulltile
	icon = 'aquila/icons/paradise/obj/smooth_structures/windows/32x40plasma_window.dmi'
	icon_state = "plasma_window-0"
	base_icon_state = "plasma_window"
	edge_overlay_file = 'aquila/icons/paradise/obj/smooth_structures/windows/window_edges.dmi'
	legacy_smooth = FALSE
	bitmask_smooth = TRUE
	alpha = 255
	color = null

/obj/structure/window/plasma/reinforced/fulltile
	icon = 'aquila/icons/paradise/obj/smooth_structures/windows/32x40rplasma_window.dmi'
	icon_state = "rplasma_window-0"
	base_icon_state = "rplasma_window"
	edge_overlay_file = 'aquila/icons/paradise/obj/smooth_structures/windows/reinforced_window_edges.dmi'
	legacy_smooth = FALSE
	bitmask_smooth = TRUE
	alpha = 255
	color = null

/obj/structure/window/reinforced/tinted/fulltile
	icon = 'aquila/icons/paradise/obj/smooth_structures/windows/32x40tinted_window.dmi'
	icon_state = "tinted_window-0"
	base_icon_state = "tinted_window"
	legacy_smooth = FALSE
	bitmask_smooth = TRUE

/obj/structure/window/shuttle
	icon = 'aquila/icons/paradise/obj/smooth_structures/windows/32x40shuttle_window.dmi'
	icon_state = "shuttle_window-0"
	base_icon_state = "shuttle_window"
	edge_overlay_file = 'aquila/icons/paradise/obj/smooth_structures/windows/shuttle_window_edges.dmi'
	bitmask_smooth = TRUE

/obj/structure/window/shuttle/survival_pod
	icon = 'aquila/icons/paradise/obj/smooth_structures/windows/32x40pod_window.dmi'
	icon_state = "pod_window-0"
	base_icon_state = "pod_window"
	edge_overlay_file = 'aquila/icons/paradise/obj/smooth_structures/windows/pod_window_edges.dmi'

/obj/structure/window/plastitanium
	icon = 'aquila/icons/paradise/obj/smooth_structures/windows/32x40plastitanium_window.dmi'
	icon_state = "plastitanium_window-0"
	base_icon_state = "plastitanium_window"
	edge_overlay_file = 'aquila/icons/paradise/obj/smooth_structures/windows/plastitanium_window_edges.dmi'
	bitmask_smooth = TRUE

/obj/structure/window/bronze/fulltile
	icon = 'aquila/icons/paradise/obj/smooth_structures/windows/32x40clockwork_window.dmi'
	icon_state = "clockwork_window-0"
	base_icon_state = "clockwork_window"
	edge_overlay_file = 'aquila/icons/paradise/obj/smooth_structures/windows/clockwork_window_edges.dmi'
	bitmask_smooth = TRUE

// Cienkie okna statku (szyby goon) jako zwykłe cienkie okna
/obj/structure/window/reinforced/ship
	icon = 'aquila/icons/paradise/obj/structures.dmi'
	icon_state = "rwindow"
	color = null

/obj/structure/window/ship
	icon = 'aquila/icons/paradise/obj/structures.dmi'
	icon_state = "window"
	color = null

// Brak w Paradise: lodowe okno zostaje jak dotąd
/obj/structure/window/reinforced/fulltile/ice
	bitmask_smooth = FALSE
	legacy_smooth = TRUE
	edge_overlay_file = null
	alpha = 200
	color = "#94bbd1"

// Krata pod ścianą: inaczej jej czarna siatka wyłazi spod okna i spod górnej części ściany od południa
/obj/structure/grille
	icon = 'aquila/icons/paradise/obj/structures.dmi'
	layer = GRILLE_LAYER

// Kraty „ścienne” NSV jako zwykła krata, jak w Paradise
/obj/structure/grille/wall
	icon = 'aquila/icons/paradise/obj/structures.dmi'
	icon_state = "grille"
	color = null
	smooth = SMOOTH_FALSE
	legacy_smooth = FALSE
	canSmoothWith = null

/obj/structure/girder
	icon = 'aquila/icons/paradise/obj/structures.dmi'

/turf/closed/indestructible/fakeglass
	icon = 'aquila/icons/paradise/obj/smooth_structures/windows/32x40reinforced_window.dmi'
	icon_state = "reinforced_window-0"
	base_icon_state = "reinforced_window"
	bitmask_smooth = TRUE

/turf/closed/indestructible/fakeglass/bitmask_connects_to(turf/T)
	return paradise_structure_connects(T, src)
