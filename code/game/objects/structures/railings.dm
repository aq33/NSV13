/obj/structure/railing
	name = "railing"
	desc = "Basic railing meant to protect idiots like you from falling."
	icon = 'icons/obj/fluff.dmi'
	icon_state = "railing"
	density = TRUE
	anchored = TRUE
	climbable = TRUE
	///Initial direction of the railing.
	var/ini_dir

/obj/structure/railing/corner //aesthetic corner sharp edges hurt oof ouch
	icon_state = "railing_corner"
	density = FALSE
	climbable = FALSE

/obj/structure/railing/Initialize(mapload)
	. = ..()
	ini_dir = dir

	AddComponent(/datum/component/simple_rotation, ROTATION_NEEDS_ROOM, AfterRotation = CALLBACK(src, PROC_REF(after_rotation)))
	init_connect_loc_element()

/obj/structure/railing/attackby(obj/item/I, mob/living/user, params)
	add_fingerprint(user)

	if(I.tool_behaviour == TOOL_WELDER && !user.combat_mode)
		if(obj_integrity < max_integrity)
			if(!I.tool_start_check(user, amount=0))
				return

			to_chat(user, "<span class='notice'>Zaczynasz naprawiać [src]...</span>")
			if(I.use_tool(src, user, 40, volume=50))
				obj_integrity = max_integrity
				to_chat(user, "<span class='notice'>Naprawiasz [src].</span>")
		else
			to_chat(user, "<span class='warning'>[src] jest już w dobrym stanie!</span>")
		return

/obj/structure/railing/AltClick(mob/user)
	return ..() // This hotkey is BLACKLISTED since it's used by /datum/component/simple_rotation

/obj/structure/railing/wirecutter_act(mob/living/user, obj/item/I)
	. = ..()
	if(!anchored)
		to_chat(user, "<span class='warning'>Rozcinasz barierkę.</span>")
		I.play_tool_sound(src, 100)
		deconstruct()
		return TRUE

/obj/structure/railing/deconstruct(disassembled)
	. = ..()
	if(!loc) //quick check if it's qdeleted already.
		return
	if(!(flags_1 & NODECONSTRUCT_1))
		var/obj/item/stack/rods/rod = new /obj/item/stack/rods(drop_location(), 3)
		transfer_fingerprints_to(rod)
		qdel(src)
///Implements behaviour that makes it possible to unanchor the railing.
/obj/structure/railing/wrench_act(mob/living/user, obj/item/I)
	. = ..()
	if(flags_1&NODECONSTRUCT_1)
		return
	to_chat(user, "<span class='notice'>Zaczynasz [anchored ? "odczepiać barierkę od":"mocować barierkę do"] podłogi...</span>")
	if(I.use_tool(src, user, 1 SECONDS, volume = 75, extra_checks = CALLBACK(src, PROC_REF(check_anchored), anchored)))
		setAnchored(!anchored)
		to_chat(user, "<span class='notice'>[anchored ? "Mocujesz barierkę do":"Odczepiasz barierkę od"] podłogi.</span>")
	return TRUE

/obj/structure/railing/CanPass(atom/movable/mover, turf/target)
	. = ..()
	if(get_dir(loc, target) & dir)
		var/checking = FLYING | FLOATING
		return . || mover.movement_type & checking
	return TRUE

/obj/structure/railing/corner/CanPass()
	..()
	return TRUE

/obj/structure/railing/proc/init_connect_loc_element()
	var/static/list/loc_connections = list(
		COMSIG_ATOM_EXIT = PROC_REF(on_exit),
	)

	AddElement(/datum/element/connect_loc, loc_connections)

/obj/structure/railing/proc/on_exit(datum/source, atom/movable/leaving, direction)
	SIGNAL_HANDLER

	if(!(direction & dir))
		return

	if (!density)
		return

	if (leaving.throwing)
		return

	if (leaving.movement_type & (FLYING | FLOATING))
		return

	if (leaving.move_force >= MOVE_FORCE_EXTREMELY_STRONG)
		return

	leaving.Bump(src)
	return COMPONENT_ATOM_BLOCK_EXIT

// Corner railings don't block anything, so they don't create the element.
/obj/structure/railing/corner/init_connect_loc_element()
	return
/obj/structure/railing/proc/check_anchored(checked_anchored)
	if(anchored == checked_anchored)
		return TRUE

/obj/structure/railing/proc/after_rotation(mob/user,rotation_type)
	ini_dir = dir
	add_fingerprint(user)

//NSV13 - railings don't completely block the turf for A* purposes
/obj/structure/railing/CanAStarPass(obj/item/card/id/ID, to_dir, atom/movable/caller)
	. = ..()
	if(.)
		return
	if(!(dir in dir_to_cardinal_dirs(to_dir)))
		return TRUE
	if(isknpc(caller))	//They can climb
		return TRUE
	return FALSE
//NSV13 end
