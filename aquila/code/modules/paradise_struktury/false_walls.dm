// Fałszywe ściany jak ściany z Paradise. Stany otwierania (fwall_*) są w tych samych plikach co ściany.

/obj/structure/falsewall
	icon = 'aquila/icons/paradise/turf/walls/32x40wall.dmi'
	icon_state = "wall-0"
	base_icon_state = "wall"
	legacy_smooth = FALSE
	bitmask_smooth = TRUE
	color = null
	texture = null
	texture_state = null

/obj/structure/falsewall/bitmask_connects_to(turf/T)
	return paradise_structure_connects(T)

/obj/structure/falsewall/update_icon()
	if(!bitmask_smooth)
		return ..()
	if(opening)
		// Jak w Paradise: drzwi otwierają się w stronę sąsiedniej ściany
		var/turf/here = get_turf(src)
		for(var/direction in GLOB.cardinals)
			if(isclosedturf(get_step(here, direction)))
				setDir(direction)
				break
		if(density)
			icon_state = "fwall_opening"
			smooth = SMOOTH_FALSE
		else
			icon_state = "fwall_closing"
	else
		if(density)
			icon_state = "[base_icon_state]-[smoothing_junction]"
			smooth = SMOOTH_TRUE
			queue_smooth(src)
		else
			icon_state = "fwall_open"
	queue_smooth_neighbors(src)

/obj/structure/falsewall/reinforced
	icon = 'aquila/icons/paradise/turf/walls/32x40reinforced_wall.dmi'
	icon_state = "reinforced_wall-0"
	base_icon_state = "reinforced_wall"
	texture = null
	color = null

/obj/structure/falsewall/durasteel
	icon = 'aquila/icons/paradise/turf/walls/32x40wall.dmi'
	icon_state = "wall-0"
	base_icon_state = "wall"
	legacy_smooth = FALSE

/obj/structure/falsewall/duranium
	icon = 'aquila/icons/paradise/turf/walls/32x40reinforced_wall.dmi'
	icon_state = "reinforced_wall-0"
	base_icon_state = "reinforced_wall"
	legacy_smooth = FALSE

/obj/structure/falsewall/gold
	icon = 'aquila/icons/paradise/turf/walls/32x40gold_wall.dmi'
	icon_state = "gold_wall-0"
	base_icon_state = "gold_wall"
	color = null

/obj/structure/falsewall/silver
	icon = 'aquila/icons/paradise/turf/walls/32x40silver_wall.dmi'
	icon_state = "silver_wall-0"
	base_icon_state = "silver_wall"
	color = null

/obj/structure/falsewall/diamond
	icon = 'aquila/icons/paradise/turf/walls/32x40diamond_wall.dmi'
	icon_state = "diamond_wall-0"
	base_icon_state = "diamond_wall"
	color = null

/obj/structure/falsewall/sandstone
	icon = 'aquila/icons/paradise/turf/walls/32x40sandstone_wall.dmi'
	icon_state = "sandstone_wall-0"
	base_icon_state = "sandstone_wall"
	color = null
	texture_state = null

/obj/structure/falsewall/bananium
	icon = 'aquila/icons/paradise/turf/walls/32x40bananium_wall.dmi'
	icon_state = "bananium_wall-0"
	base_icon_state = "bananium_wall"
	color = null

/obj/structure/falsewall/uranium
	icon = 'aquila/icons/paradise/turf/walls/32x40uranium_wall.dmi'
	icon_state = "uranium_wall-0"
	base_icon_state = "uranium_wall"
	color = null
	texture_state = null

/obj/structure/falsewall/plasma
	icon = 'aquila/icons/paradise/turf/walls/32x40plasma_wall.dmi'
	icon_state = "plasma_wall-0"
	base_icon_state = "plasma_wall"
	color = null

/obj/structure/falsewall/iron
	icon = 'aquila/icons/paradise/turf/walls/32x40iron_wall.dmi'
	icon_state = "iron_wall-0"
	base_icon_state = "iron_wall"
	color = null

/obj/structure/falsewall/wood
	icon = 'aquila/icons/paradise/turf/walls/32x40wood_wall.dmi'
	icon_state = "wood_wall-0"
	base_icon_state = "wood_wall"
	color = null

/obj/structure/falsewall/abductor
	icon = 'aquila/icons/paradise/turf/walls/32x40abductor_wall.dmi'
	icon_state = "abductor_wall-0"
	base_icon_state = "abductor_wall"

/obj/structure/falsewall/titanium
	icon = 'aquila/icons/paradise/turf/walls/32x40plastinum_wall.dmi'
	icon_state = "plastinum_wall-0"
	base_icon_state = "plastinum_wall"

/obj/structure/falsewall/plastitanium
	icon = 'aquila/icons/paradise/turf/walls/32x40plastitanium_wall.dmi'
	icon_state = "plastitanium_wall-0"
	base_icon_state = "plastitanium_wall"

/obj/structure/falsewall/brass
	icon = 'aquila/icons/paradise/turf/walls/32x40clockwork_wall.dmi'
	icon_state = "clockwork_wall-0"
	base_icon_state = "clockwork_wall"

// Brak w Paradise: zostają nasze
/obj/structure/falsewall/copper
	bitmask_smooth = FALSE
	legacy_smooth = TRUE

/obj/structure/falsewall/bamboo
	bitmask_smooth = FALSE
	legacy_smooth = TRUE
