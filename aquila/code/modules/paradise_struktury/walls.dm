// Ściany z Paradise (32x40, perspektywa 3/4). Zastępują ściany NSV13 (goon/bay z legacy_smooth) i ściany statku.
// Typy, których Paradise nie ma (miedź, śnieg, lód, bambus, gładka, skarbiec, hierofant), zostają po staremu na dole pliku.

/turf/closed/wall
	icon = 'aquila/icons/paradise/turf/walls/32x40wall.dmi'
	icon_state = "wall-0"
	base_icon_state = "wall"
	legacy_smooth = FALSE
	bitmask_smooth = TRUE
	color = null
	texture = null
	texture_state = null

/turf/closed/wall/bitmask_connects_to(turf/T)
	return paradise_structure_connects(T, src)

/turf/closed/wall/steel
	color = null

/turf/closed/wall/ship
	icon = 'aquila/icons/paradise/turf/walls/32x40wall.dmi'
	icon_state = "wall-0"
	base_icon_state = "wall"
	legacy_smooth = FALSE

/turf/closed/wall/r_wall
	icon = 'aquila/icons/paradise/turf/walls/32x40reinforced_wall.dmi'
	icon_state = "reinforced_wall-0"
	base_icon_state = "reinforced_wall"
	color = null
	texture = null

/turf/closed/wall/r_wall/ship
	icon = 'aquila/icons/paradise/turf/walls/32x40reinforced_wall.dmi'
	icon_state = "reinforced_wall-0"
	base_icon_state = "reinforced_wall"
	legacy_smooth = FALSE

// Etapy demontażu mają w Paradise własne stany r_wall_1..6 bez wygładzania
/turf/closed/wall/r_wall/update_icon_state()
	. = ..()
	if(!bitmask_smooth)
		return
	if(d_state != INTACT)
		icon_state = "r_wall_[d_state]"
	else
		icon_state = "[base_icon_state]-[smoothing_junction]"

// Smoothing nie może nadpisać etapu demontażu stanem wygładzonej ściany
/turf/closed/wall/r_wall/bitmask_smoothed()
	. = ..()
	if(d_state != INTACT)
		icon_state = "r_wall_[d_state]"

/turf/closed/wall/r_wall/syndicate
	icon = 'aquila/icons/paradise/turf/walls/32x40plastitanium_wall.dmi'
	icon_state = "plastitanium_wall-0"
	base_icon_state = "plastitanium_wall"
	smooth = SMOOTH_MORE

/turf/closed/wall/r_wall/syndicate/nodiagonal
	icon_state = "plastitanium_wall-0"

/turf/closed/wall/r_wall/syndicate/overspace
	icon_state = "plastitanium_wall-0"

/turf/closed/wall/mineral
	icon = 'aquila/icons/paradise/turf/walls/32x40wall.dmi'
	icon_state = "wall-0"
	base_icon_state = "wall"

/turf/closed/wall/mineral/cult
	icon = 'aquila/icons/paradise/turf/walls/32x40cult_wall.dmi'
	icon_state = "cult_wall-0"
	base_icon_state = "cult_wall"
	color = null

/turf/closed/wall/mineral/gold
	icon = 'aquila/icons/paradise/turf/walls/32x40gold_wall.dmi'
	icon_state = "gold_wall-0"
	base_icon_state = "gold_wall"
	color = null

/turf/closed/wall/mineral/silver
	icon = 'aquila/icons/paradise/turf/walls/32x40silver_wall.dmi'
	icon_state = "silver_wall-0"
	base_icon_state = "silver_wall"
	color = null

/turf/closed/wall/mineral/diamond
	icon = 'aquila/icons/paradise/turf/walls/32x40diamond_wall.dmi'
	icon_state = "diamond_wall-0"
	base_icon_state = "diamond_wall"
	color = null

/turf/closed/wall/mineral/sandstone
	icon = 'aquila/icons/paradise/turf/walls/32x40sandstone_wall.dmi'
	icon_state = "sandstone_wall-0"
	base_icon_state = "sandstone_wall"
	color = null
	texture_state = null

/turf/closed/wall/mineral/bananium
	icon = 'aquila/icons/paradise/turf/walls/32x40bananium_wall.dmi'
	icon_state = "bananium_wall-0"
	base_icon_state = "bananium_wall"
	color = null

/turf/closed/wall/mineral/uranium
	icon = 'aquila/icons/paradise/turf/walls/32x40uranium_wall.dmi'
	icon_state = "uranium_wall-0"
	base_icon_state = "uranium_wall"
	color = null
	texture_state = null

/turf/closed/wall/mineral/plasma
	icon = 'aquila/icons/paradise/turf/walls/32x40plasma_wall.dmi'
	icon_state = "plasma_wall-0"
	base_icon_state = "plasma_wall"
	color = null

/turf/closed/wall/mineral/iron
	icon = 'aquila/icons/paradise/turf/walls/32x40iron_wall.dmi'
	icon_state = "iron_wall-0"
	base_icon_state = "iron_wall"
	color = null

/turf/closed/wall/mineral/wood
	icon = 'aquila/icons/paradise/turf/walls/32x40wood_wall.dmi'
	icon_state = "wood_wall-0"
	base_icon_state = "wood_wall"
	color = null

/turf/closed/wall/mineral/abductor
	icon = 'aquila/icons/paradise/turf/walls/32x40abductor_wall.dmi'
	icon_state = "abductor_wall-0"
	base_icon_state = "abductor_wall"

// Tytan w Paradise to „plastinum”
/turf/closed/wall/mineral/titanium
	icon = 'aquila/icons/paradise/turf/walls/32x40plastinum_wall.dmi'
	icon_state = "plastinum_wall-0"
	base_icon_state = "plastinum_wall"
	smooth = SMOOTH_MORE

/turf/closed/wall/mineral/titanium/nodiagonal
	icon = 'aquila/icons/paradise/turf/walls/32x40plastinum_wall.dmi'
	icon_state = "plastinum_wall-0"

/turf/closed/wall/mineral/titanium/overspace
	icon = 'aquila/icons/paradise/turf/walls/32x40plastinum_wall.dmi'
	icon_state = "plastinum_wall-0"

/turf/closed/wall/mineral/titanium/survival
	icon = 'aquila/icons/paradise/turf/walls/32x40survival_pod_walls.dmi'
	icon_state = "survival_pod_walls-0"
	base_icon_state = "survival_pod_walls"

/turf/closed/wall/mineral/plastitanium
	icon = 'aquila/icons/paradise/turf/walls/32x40plastitanium_wall.dmi'
	icon_state = "plastitanium_wall-0"
	base_icon_state = "plastitanium_wall"
	smooth = SMOOTH_MORE

/turf/closed/wall/mineral/plastitanium/nodiagonal
	icon_state = "plastitanium_wall-0"

/turf/closed/wall/mineral/plastitanium/overspace
	icon_state = "plastitanium_wall-0"

/turf/closed/wall/clockwork
	icon = 'aquila/icons/paradise/turf/walls/32x40clockwork_wall.dmi'
	icon_state = "clockwork_wall-0"
	base_icon_state = "clockwork_wall"

/turf/closed/wall/mineral/bronze
	icon = 'aquila/icons/paradise/turf/walls/32x40clockwork_wall.dmi'
	icon_state = "clockwork_wall-0"
	base_icon_state = "clockwork_wall"

/turf/closed/indestructible/riveted
	icon = 'aquila/icons/paradise/turf/walls/32x40reinforced_wall.dmi'
	icon_state = "reinforced_wall-0"
	base_icon_state = "reinforced_wall"
	bitmask_smooth = TRUE

/turf/closed/indestructible/riveted/bitmask_connects_to(turf/T)
	return paradise_structure_connects(T, src)

/turf/closed/indestructible/riveted/boss
	icon = 'aquila/icons/paradise/turf/walls/32x40boss_wall.dmi'
	icon_state = "boss_wall-0"
	base_icon_state = "boss_wall"

/turf/closed/indestructible/riveted/uranium
	icon = 'aquila/icons/paradise/turf/walls/32x40uranium_wall.dmi'
	icon_state = "uranium_wall-0"
	base_icon_state = "uranium_wall"

// Brak w Paradise: zostają nasze sprite'y i stary sposób wygładzania
/turf/closed/wall/mineral/copper
	bitmask_smooth = FALSE
	legacy_smooth = TRUE

/turf/closed/wall/mineral/snow
	bitmask_smooth = FALSE
	legacy_smooth = TRUE

/turf/closed/wall/ice
	bitmask_smooth = FALSE
	legacy_smooth = TRUE

/turf/closed/wall/mineral/bamboo
	bitmask_smooth = FALSE
	legacy_smooth = TRUE

/turf/closed/wall/smooth
	bitmask_smooth = FALSE
	legacy_smooth = TRUE

/turf/closed/wall/vault
	bitmask_smooth = FALSE
	legacy_smooth = TRUE

/turf/closed/indestructible/riveted/hierophant
	bitmask_smooth = FALSE

/turf/closed/wall/mineral/titanium/nosmooth
	bitmask_smooth = FALSE

/turf/closed/wall/mineral/plastitanium/nosmooth
	bitmask_smooth = FALSE

/turf/closed/wall/r_wall/syndicate/nosmooth
	bitmask_smooth = FALSE
