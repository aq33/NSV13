// Pozostałe drzwi z Paradise: przeciwpożarowe, grodzie, rolety, drzwi okienne, mineralne i kostnicy.
// Pliki są połączone: stany Paradise + nasze, których Paradise nie ma (np. lampki alarmu), dosunięte do dołu.

/obj/machinery/door/firedoor
	icon = 'aquila/icons/paradise/obj/doors/doorfireglass.dmi'

/obj/machinery/door/firedoor/heavy
	icon = 'aquila/icons/paradise/obj/doors/doorfire.dmi'

// Pełne drzwi przeciwpożarowe obracają się do ściany jak śluzy
/obj/machinery/door/firedoor/Initialize(mapload)
	. = ..()
	paradise_face_walls()

/obj/machinery/door/firedoor/proc/paradise_face_walls()
	if(istype(src, /obj/machinery/door/firedoor/border_only) || istype(src, /obj/machinery/door/firedoor/window))
		return
	var/direction = paradise_door_direction(src)
	if(direction)
		setDir(direction)

// Postawiona albo rozebrana ściana obok drzwi: drzwi obracają się na nowo, inaczej zostają w starym kierunku
/turf/AfterChange(flags)
	. = ..()
	for(var/direction in GLOB.cardinals)
		var/turf/T = get_step(src, direction)
		if(!T)
			continue
		for(var/obj/machinery/door/airlock/A in T)
			if(A.paradise_sprites && (A.flags_1 & INITIALIZED_1))
				A.paradise_face_walls()
		for(var/obj/machinery/door/firedoor/F in T)
			if(F.flags_1 & INITIALIZED_1)
				F.paradise_face_walls()

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
