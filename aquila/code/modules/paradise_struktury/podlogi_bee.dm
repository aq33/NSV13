// Podłogi z BeeStation (BeeStation/BeeStation-Hornet, grafiki CC BY-SA 3.0) zamiast podłóg NSV13 i starych dywanów.
// icons/turf/floors.dmi ma już stany Bee; tu przechodzą na nie podłogi, które brały grafikę z innych plików.
// Dywany, trawa i szklane podłogi Bee są rysowane bitmaską (47 układów), tak jak ściany z Paradise.

// Podłogi NSV13 (durasteel) dostają najbliższe podłogi Bee i ich stany uszkodzeń
/turf/open/floor/durasteel
	icon = 'icons/turf/floors.dmi'
	icon_state = "floor"
	broken_states = list("damaged1", "damaged2", "damaged3", "damaged4", "damaged5")
	burnt_states = list("floorscorched1", "floorscorched2")

/turf/open/floor/durasteel/alt
	icon = 'icons/turf/floors.dmi'
	icon_state = "floor"

/turf/open/floor/durasteel/riveted
	icon_state = "textured"

/turf/open/floor/durasteel/padded
	icon_state = "darkfull"

/turf/open/floor/durasteel/eris_techfloor
	icon_state = "techmaint"

/turf/open/floor/durasteel/eris_techfloor_alt
	icon_state = "techmaint"

/turf/open/floor/durasteel/lino
	icon = 'icons/turf/floors.dmi'
	icon_state = "darkfull"

/turf/open/floor/durasteel/techfloor
	icon = 'icons/turf/floors.dmi'
	icon_state = "techfloor_grey"

/turf/open/floor/durasteel/techfloor_grid
	icon = 'icons/turf/floors.dmi'
	icon_state = "techfloor_grid"

/turf/open/floor/monofloor/corner
	icon = 'icons/turf/floors.dmi'
	icon_state = "floor"
	base_icon_state = "floor"

/turf/open/floor/plating/rusty_techgrid
	icon = 'icons/turf/floors.dmi'
	icon_state = "techfloor_grid"
	base_icon_state = "techfloor_grid"
	broken_states = list("damaged1", "damaged2")
	burnt_states = list("floorscorched1", "floorscorched2")

// Kafle w stylu NSV (tiled, monotile) też są w floors.dmi Bee, ale mieszały się na mapach z podstawowymi podłogami Bee.
// Dla spójności dostają podstawowe podłogi Bee: szarą, białą i ciemną.
/turf/open/floor/plasteel/tiled
	icon_state = "floor"
	base_icon_state = "floor"

/turf/open/floor/plasteel/tiled/light
	icon_state = "white"
	base_icon_state = "white"

/turf/open/floor/monotile
	icon_state = "floor"

/turf/open/floor/monotile/steel
	icon_state = "floor"

/turf/open/floor/monotile/dark
	icon_state = "darkfull"

/turf/open/floor/monotile/light
	icon_state = "white"

/turf/open/floor/monofloor
	icon_state = "floor"

// W Bee podłogi antypoślizgowe wyglądają jak zwykłe podłogi danego koloru
/turf/open/floor/noslip/white
	icon_state = "white"

/turf/open/floor/noslip/blue
	icon_state = "bluefull"

/turf/open/floor/bronze
	icon = 'icons/turf/floors.dmi'
	icon_state = "clockwork_floor"

// Dywany: bitmaska, każdy kolor łączy się tylko ze swoim
/turf/open/floor/carpet
	icon = 'aquila/icons/bee/turf/floors/carpet.dmi'
	icon_state = "carpet-255"
	base_icon_state = "carpet"
	bitmask_smooth = TRUE
	/// AQUILA - z jakim typem dywan łączy się w bitmasce
	var/carpet_connect_type = /turf/open/floor/carpet

/turf/open/floor/carpet/bitmask_connects_to(turf/T)
	return istype(T, carpet_connect_type)

/turf/open/floor/carpet/black
	icon = 'aquila/icons/bee/turf/floors/carpet_black.dmi'
	icon_state = "carpet_black-255"
	base_icon_state = "carpet_black"
	carpet_connect_type = /turf/open/floor/carpet/black

/turf/open/floor/carpet/blue
	icon = 'aquila/icons/bee/turf/floors/carpet_blue.dmi'
	icon_state = "carpet_blue-255"
	base_icon_state = "carpet_blue"
	carpet_connect_type = /turf/open/floor/carpet/blue

/turf/open/floor/carpet/cyan
	icon = 'aquila/icons/bee/turf/floors/carpet_cyan.dmi'
	icon_state = "carpet_cyan-255"
	base_icon_state = "carpet_cyan"
	carpet_connect_type = /turf/open/floor/carpet/cyan

/turf/open/floor/carpet/green
	icon = 'aquila/icons/bee/turf/floors/carpet_green.dmi'
	icon_state = "carpet_green-255"
	base_icon_state = "carpet_green"
	carpet_connect_type = /turf/open/floor/carpet/green

/turf/open/floor/carpet/orange
	icon = 'aquila/icons/bee/turf/floors/carpet_orange.dmi'
	icon_state = "carpet_orange-255"
	base_icon_state = "carpet_orange"
	carpet_connect_type = /turf/open/floor/carpet/orange

/turf/open/floor/carpet/purple
	icon = 'aquila/icons/bee/turf/floors/carpet_purple.dmi'
	icon_state = "carpet_purple-255"
	base_icon_state = "carpet_purple"
	carpet_connect_type = /turf/open/floor/carpet/purple

/turf/open/floor/carpet/red
	icon = 'aquila/icons/bee/turf/floors/carpet_red.dmi'
	icon_state = "carpet_red-255"
	base_icon_state = "carpet_red"
	carpet_connect_type = /turf/open/floor/carpet/red

/turf/open/floor/carpet/royalblack
	icon = 'aquila/icons/bee/turf/floors/carpet_royalblack.dmi'
	icon_state = "carpet_royalblack-255"
	base_icon_state = "carpet_royalblack"
	carpet_connect_type = /turf/open/floor/carpet/royalblack

/turf/open/floor/carpet/royalblue
	icon = 'aquila/icons/bee/turf/floors/carpet_royalblue.dmi'
	icon_state = "carpet_royalblue-255"
	base_icon_state = "carpet_royalblue"
	carpet_connect_type = /turf/open/floor/carpet/royalblue

/turf/open/floor/carpet/grimy
	icon = 'aquila/icons/bee/turf/floors/carpet_grimy.dmi'
	icon_state = "carpet_grimy-255"
	base_icon_state = "carpet_grimy"
	carpet_connect_type = /turf/open/floor/carpet/grimy

// Dywany statku NSV13 na odpowiedniki z Bee; beżowego Bee nie ma, więc dostaje klasyczny brązowy
/turf/open/floor/carpet/ship
	icon = 'aquila/icons/bee/turf/floors/carpet_black.dmi'
	icon_state = "carpet_black-255"
	base_icon_state = "carpet_black"
	carpet_connect_type = /turf/open/floor/carpet/ship

/turf/open/floor/carpet/ship/blue
	icon = 'aquila/icons/bee/turf/floors/carpet_blue.dmi'
	icon_state = "carpet_blue-255"
	base_icon_state = "carpet_blue"
	carpet_connect_type = /turf/open/floor/carpet/ship/blue

/turf/open/floor/carpet/ship/orange_carpet
	icon = 'aquila/icons/bee/turf/floors/carpet_orange.dmi'
	icon_state = "carpet_orange-255"
	base_icon_state = "carpet_orange"
	carpet_connect_type = /turf/open/floor/carpet/ship/orange_carpet

/turf/open/floor/carpet/ship/purple_carpet
	icon = 'aquila/icons/bee/turf/floors/carpet_purple.dmi'
	icon_state = "carpet_purple-255"
	base_icon_state = "carpet_purple"
	carpet_connect_type = /turf/open/floor/carpet/ship/purple_carpet

/turf/open/floor/carpet/ship/beige_carpet
	icon = 'aquila/icons/bee/turf/floors/carpet.dmi'
	icon_state = "carpet-255"
	base_icon_state = "carpet"
	carpet_connect_type = /turf/open/floor/carpet/ship/beige_carpet

/turf/open/floor/carpet/ship/red_carpet
	icon = 'aquila/icons/bee/turf/floors/carpet_red.dmi'
	icon_state = "carpet_red-255"
	base_icon_state = "carpet_red"
	carpet_connect_type = /turf/open/floor/carpet/ship/red_carpet

// Trawa Bee: sprite 50x50 przesunięty o 9 px, brzegi wychodzą na sąsiednie kafle
/turf/open/floor/grass
	icon = 'aquila/icons/bee/turf/floors/grass.dmi'
	icon_state = "grass"
	base_icon_state = "grass"
	broken_states = list("damaged")
	layer = EDGED_TURF_LAYER
	smooth = SMOOTH_TRUE
	bitmask_smooth = TRUE

/turf/open/floor/grass/Initialize(mapload)
	. = ..()
	if(bitmask_smooth)
		transform = matrix(1, 0, -9, 0, 1, -9)

/turf/open/floor/grass/bitmask_connects_to(turf/T)
	return istype(T, /turf/open/floor/grass)

/turf/open/floor/grass/fairy
	icon = 'aquila/icons/bee/turf/floors/grass_fairy.dmi'
	icon_state = "grass"

// Szklane podłogi Bee
/turf/open/floor/glass
	icon = 'aquila/icons/bee/turf/floors/glass.dmi'
	icon_state = "glass-0"
	base_icon_state = "glass"
	bitmask_smooth = TRUE

/turf/open/floor/glass/bitmask_connects_to(turf/T)
	return istype(T, /turf/open/floor/glass)

/turf/open/floor/glass/reinforced
	icon = 'aquila/icons/bee/turf/floors/reinf_glass.dmi'
	icon_state = "reinf_glass-0"
	base_icon_state = "reinf_glass"

// Śnieg dziedziczy po trawie, ale ma własną ikonę bez bitmaski
/turf/open/floor/grass/snow
	base_icon_state = null
	broken_states = null
	layer = TURF_LAYER
	smooth = SMOOTH_FALSE
	bitmask_smooth = FALSE
