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

/// Grupa wygładzania: ściany i okna shuttle'ów (tytan, plastytan, syndykat) nie łączą się ze ścianami stacji, jak w Paradise.
/proc/paradise_wall_group(atom/A)
	if(istype(A, /turf/closed/wall/mineral/titanium) || istype(A, /turf/closed/wall/mineral/plastitanium) || istype(A, /turf/closed/wall/r_wall/syndicate))
		return "shuttle"
	if(istype(A, /obj/structure/falsewall/titanium) || istype(A, /obj/structure/falsewall/plastitanium))
		return "shuttle"
	if(istype(A, /obj/structure/window/shuttle) || istype(A, /obj/structure/window/plastitanium) || istype(A, /obj/structure/window/reinforced/survival_pod))
		return "shuttle"
	return "station"

/// Ściany, fałszywe ściany, pełne okna, śluzy, grodzie, rolety i pełne drzwi przeciwpożarowe łączą się ze sobą jak w Paradise.
/// source - kto pyta: ściany łączą się tylko z własną grupą, a w dół tylko z tym, co ma 32x40 i wypełnia wcięcie
/// na dole ściany (grodzie i rolety mają 32x32, więc nad nimi ściana dostaje pełne dolne czoło).
/proc/paradise_structure_connects(turf/T, atom/source)
	if(!T)
		return FALSE
	var/group = source ? paradise_wall_group(source) : null
	var/turf/here = source ? get_turf(source) : null
	var/below = here && T.y < here.y
	if(istype(T, /turf/closed/wall) || istype(T, /turf/closed/indestructible/riveted) || istype(T, /turf/closed/indestructible/fakeglass))
		return !group || paradise_wall_group(T) == group
	for(var/atom/movable/AM as anything in T)
		if(istype(AM, /obj/machinery/door/airlock))
			return TRUE
		if(istype(AM, /obj/machinery/door/poddoor))
			if(below)
				continue
			return TRUE
		if(istype(AM, /obj/machinery/door/firedoor) && !istype(AM, /obj/machinery/door/firedoor/border_only) && !istype(AM, /obj/machinery/door/firedoor/window))
			return TRUE
		if(istype(AM, /obj/structure/falsewall))
			var/obj/structure/falsewall/FW = AM
			if(FW.density && (!group || paradise_wall_group(FW) == group))
				return TRUE
			continue
		if(istype(AM, /obj/structure/window))
			var/obj/structure/window/W = AM
			if(W.fulltile && W.anchored && (!group || paradise_wall_group(W) == group))
				return TRUE
	return FALSE
