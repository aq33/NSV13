// Pozostałe drzwi z Paradise: przeciwpożarowe, grodzie, rolety, drzwi okienne, mineralne i kostnicy.
// Pliki są połączone: stany Paradise + nasze, których Paradise nie ma (np. lampki alarmu), dosunięte do dołu.

/obj/machinery/door/firedoor
	icon = 'aquila/icons/paradise/obj/doors/doorfireglass.dmi'

/obj/machinery/door/firedoor/heavy
	icon = 'aquila/icons/paradise/obj/doors/doorfire.dmi'

// Pełne drzwi przeciwpożarowe obracają się do ściany jak śluzy
/obj/machinery/door/firedoor/Initialize(mapload)
	. = ..()
	if(istype(src, /obj/machinery/door/firedoor/border_only) || istype(src, /obj/machinery/door/firedoor/window))
		return
	var/direction = paradise_door_direction(src)
	if(direction)
		setDir(direction)

/obj/machinery/door/firedoor/border_only
	icon = 'aquila/icons/paradise/obj/doors/edge_doorfire.dmi'

/obj/structure/firelock_frame
	icon = 'aquila/icons/paradise/obj/doors/doorfire.dmi'

/obj/structure/firelock_frame/border
	icon = 'aquila/icons/paradise/obj/doors/edge_doorfire.dmi'

/obj/machinery/door/poddoor
	icon = 'aquila/icons/paradise/obj/doors/blastdoor.dmi'

/obj/machinery/door/poddoor/shutters
	icon = 'aquila/icons/paradise/obj/doors/shutters.dmi'

/obj/machinery/door/poddoor/ship
	icon = 'aquila/icons/paradise/obj/doors/blastdoor.dmi'

/obj/machinery/door/poddoor/shutters/ship
	icon = 'aquila/icons/paradise/obj/doors/shutters.dmi'

/obj/machinery/door/window
	icon = 'aquila/icons/paradise/obj/doors/windoor.dmi'

/obj/structure/windoor_assembly
	icon = 'aquila/icons/paradise/obj/doors/windoor.dmi'

/obj/structure/mineral_door
	icon = 'aquila/icons/paradise/obj/doors/mineral_doors.dmi'

/obj/machinery/door/morgue
	icon = 'aquila/icons/paradise/obj/doors/doormorgue.dmi'
