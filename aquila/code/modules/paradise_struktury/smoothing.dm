// Struktury z Paradise (ParadiseSS13/Paradise, grafiki CC BY-SA 3.0): ściany, okna i drzwi w perspektywie 3/4.
// Sprite'y Paradise są rysowane osobno dla każdego z 47 układów sąsiadów (bitmaska z tg), więc nie da się ich
// rozłożyć na narożniki starego smoothingu. Atom z bitmask_smooth = TRUE pomija narożniki i legacy_smooth
// i dostaje icon_state "[base_icon_state]-[smoothing_junction]". Wywołanie jest w smooth_icon().

#define BITMASK_NORTH (1<<0)
#define BITMASK_SOUTH (1<<1)
#define BITMASK_EAST (1<<2)
#define BITMASK_WEST (1<<3)
#define BITMASK_NORTHEAST (1<<4)
#define BITMASK_SOUTHEAST (1<<5)
#define BITMASK_SOUTHWEST (1<<6)
#define BITMASK_NORTHWEST (1<<7)

/atom
	/// AQUILA - smoothing bitmaską (sprite'y z Paradise) zamiast narożników
	var/bitmask_smooth = FALSE
	/// AQUILA - ostatnio policzony układ sąsiadów, 0-255 w zapisie tg
	var/smoothing_junction = 0

/// Czy atom łączy się wizualnie z turfem T albo czymś, co na nim stoi.
/atom/proc/bitmask_connects_to(turf/T)
	return FALSE

/atom/proc/calculate_bitmask_junction()
	var/turf/here = get_turf(src)
	if(!here)
		return 0
	. = 0
	if(bitmask_connects_to(get_step(here, NORTH)))
		. |= BITMASK_NORTH
	if(bitmask_connects_to(get_step(here, SOUTH)))
		. |= BITMASK_SOUTH
	if(bitmask_connects_to(get_step(here, EAST)))
		. |= BITMASK_EAST
	if(bitmask_connects_to(get_step(here, WEST)))
		. |= BITMASK_WEST
	// Skosy liczą się tylko przy obu sąsiednich kierunkach, tak jak w zestawie 47 stanów z tg
	if((. & (BITMASK_NORTH|BITMASK_EAST)) == (BITMASK_NORTH|BITMASK_EAST) && bitmask_connects_to(get_step(here, NORTHEAST)))
		. |= BITMASK_NORTHEAST
	if((. & (BITMASK_SOUTH|BITMASK_EAST)) == (BITMASK_SOUTH|BITMASK_EAST) && bitmask_connects_to(get_step(here, SOUTHEAST)))
		. |= BITMASK_SOUTHEAST
	if((. & (BITMASK_SOUTH|BITMASK_WEST)) == (BITMASK_SOUTH|BITMASK_WEST) && bitmask_connects_to(get_step(here, SOUTHWEST)))
		. |= BITMASK_SOUTHWEST
	if((. & (BITMASK_NORTH|BITMASK_WEST)) == (BITMASK_NORTH|BITMASK_WEST) && bitmask_connects_to(get_step(here, NORTHWEST)))
		. |= BITMASK_NORTHWEST

/atom/proc/bitmask_smooth_icon()
	smoothing_junction = calculate_bitmask_junction()
	if(base_icon_state)
		icon_state = "[base_icon_state]-[smoothing_junction]"
	bitmask_smoothed()

/// Wołane po każdym przeliczeniu układu, np. dla ramek okien.
/atom/proc/bitmask_smoothed()
	return

/// Ściany, fałszywe ściany, pełne okna, śluzy i pełne drzwi przeciwpożarowe łączą się ze sobą jak w Paradise.
/proc/paradise_structure_connects(turf/T)
	if(!T)
		return FALSE
	if(istype(T, /turf/closed/wall) || istype(T, /turf/closed/indestructible/riveted) || istype(T, /turf/closed/indestructible/fakeglass))
		return TRUE
	for(var/atom/movable/AM as anything in T)
		if(istype(AM, /obj/machinery/door/airlock))
			return TRUE
		if(istype(AM, /obj/machinery/door/firedoor) && !istype(AM, /obj/machinery/door/firedoor/border_only) && !istype(AM, /obj/machinery/door/firedoor/window))
			return TRUE
		if(istype(AM, /obj/structure/falsewall))
			var/obj/structure/falsewall/FW = AM
			if(FW.density)
				return TRUE
			continue
		if(istype(AM, /obj/structure/window))
			var/obj/structure/window/W = AM
			if(W.fulltile && W.anchored)
				return TRUE
	return FALSE
