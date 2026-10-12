// Disposal pipe construction
// This is the pipe that you drag around, not the attached ones.

/obj/structure/disposalconstruct
	name = "disposal pipe segment"
	desc = "A huge pipe segment used for constructing disposal systems."
	icon = 'icons/obj/atmospherics/pipes/disposal.dmi'
	icon_state = "conpipe"
	anchored = FALSE
	density = FALSE
	pressure_resistance = 5*ONE_ATMOSPHERE
	level = 2
	max_integrity = 200
	var/obj/pipe_type = /obj/structure/disposalpipe/segment
	var/pipename

/obj/structure/disposalconstruct/Initialize(mapload, _pipe_type, _dir = SOUTH, flip = FALSE, obj/make_from)
	. = ..()

	if(make_from)
		pipe_type = make_from.type
		setDir(make_from.dir)
		anchored = TRUE
		density = initial(pipe_type.density)
		make_from.transfer_fingerprints_to(src)

	else
		if(_pipe_type)
			pipe_type = _pipe_type
		setDir(_dir)

	pipename = initial(pipe_type.name)

	if(flip)
		flip_construct()

	update_icon()

/obj/structure/disposalconstruct/Move()
	var/old_dir = dir
	..()
	setDir(old_dir) //pipes changing direction when moved is just annoying and buggy

// update iconstate and dpdir due to dir and type
/obj/structure/disposalconstruct/update_icon()
	icon_state = initial(pipe_type.icon_state)
	if(is_pipe())
		icon_state = "con[icon_state]"
		if(anchored)
			level = initial(pipe_type.level)
			layer = initial(pipe_type.layer)
		else
			level = initial(level)
			layer = initial(layer)

	else if(ispath(pipe_type, /obj/machinery/disposal/bin))
		// Disposal bins receive special icon treating
		if(anchored)
			icon_state = "disposal"
		else
			icon_state = "condisposal"


// hide called by levelupdate if turf intact status changes
// change visibility status and force update of icon
/obj/structure/disposalconstruct/hide(var/intact)
	invisibility = (intact && level==1) ? INVISIBILITY_MAXIMUM: 0	// hide if floor is intact
	update_icon()

/obj/structure/disposalconstruct/proc/get_disposal_dir()
	if(!is_pipe())
		return NONE

	var/obj/structure/disposalpipe/temp = pipe_type
	var/initialize_dirs = initial(temp.initialize_dirs)
	var/dpdir = NONE

	if(dir in GLOB.diagonals) // Bent pipes
		return dir

	if(initialize_dirs != DISP_DIR_NONE)
		dpdir = dir

		if(initialize_dirs & DISP_DIR_LEFT)
			dpdir |= turn(dir, 90)
		if(initialize_dirs & DISP_DIR_RIGHT)
			dpdir |= turn(dir, -90)
		if(initialize_dirs & DISP_DIR_FLIP)
			dpdir |= turn(dir, 180)
	return dpdir

/obj/structure/disposalconstruct/ComponentInitialize()
	. = ..()
	AddComponent(/datum/component/simple_rotation, AfterRotation = CALLBACK(src, PROC_REF(after_rot)))

/// Port Bee #11899: rotation component no longer flips, so flipping is done here (right click, or the verb in the legacy mode)
/obj/structure/disposalconstruct/proc/flip_construct()
	setDir(turn(dir, ROTATION_FLIP))
	after_rot(null, ROTATION_FLIP)

/obj/structure/disposalconstruct/attack_hand_secondary(mob/user, list/modifiers)
	. = ..()
	if(. == SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN)
		return
	if(!can_be_rotated(user, ROTATION_FLIP))
		return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN
	flip_construct()
	return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN

/obj/structure/disposalconstruct/verb/flip_pipe()
	set category = "Object"
	set name = "Flip Pipe"
	set src in view(1)
	if(usr.incapacitated() || !isliving(usr) || !can_be_rotated(usr, ROTATION_FLIP))
		return
	flip_construct()

/obj/structure/disposalconstruct/proc/after_rot(mob/user,rotation_type)
	if(rotation_type == ROTATION_FLIP)
		var/obj/structure/disposalpipe/temp = pipe_type
		if(initial(temp.flip_type))
			if(dir in GLOB.diagonals)	// Fix RPD-induced diagonal turning
				setDir(turn(dir, 45))
			pipe_type = initial(temp.flip_type)
	update_icon()

/obj/structure/disposalconstruct/proc/can_be_rotated(mob/user,rotation_type)
	if(anchored)
		to_chat(user, "<span class='warning'>Musisz odkręcić rurę, zanim ją obrócisz!</span>")
		return FALSE
	return TRUE

// construction/deconstruction
// wrench: (un)anchor
// weldingtool: convert to real pipe
/obj/structure/disposalconstruct/wrench_act(mob/living/user, obj/item/I)
	if(anchored)
		anchored = FALSE
		density = FALSE
		to_chat(user, "<span class='notice'>Odłączasz [pipename] od podłoża.</span>")
	else
		var/ispipe = is_pipe() // Indicates if we should change the level of this pipe

		var/turf/T = get_turf(src)
		if(T.intact && isfloorturf(T))
			to_chat(user, "<span class='warning'>Możesz przymocować [pipename] tylko wtedy, gdy płyty podłogowe są zdjęte!</span>")
			return TRUE

		if(!ispipe && iswallturf(T))
			to_chat(user, "<span class='warning'>Na ścianach nie możesz budować [pipename], tylko rury zsypowe!</span>")
			return TRUE

		if(ispipe)
			var/dpdir = get_disposal_dir()
			for(var/obj/structure/disposalpipe/CP in T)
				var/pdir = CP.dpdir
				if(istype(CP, /obj/structure/disposalpipe/broken))
					pdir = CP.dir
				if(pdir & dpdir)
					to_chat(user, "<span class='warning'>W tym miejscu jest już rura zsypowa!</span>")
					return TRUE

		else	// Disposal or outlet
			var/found_trunk = FALSE
			for(var/obj/structure/disposalpipe/CP in T)
				if(istype(CP, /obj/structure/disposalpipe/trunk))
					found_trunk = TRUE
					break

			if(!found_trunk)
				to_chat(user, "<span class='warning'>Do działania [pipename] potrzebuje pod spodem rury głównej!</span>")
				return TRUE

		anchored = TRUE
		density = initial(pipe_type.density)
		to_chat(user, "<span class='notice'>Przymocowujesz [pipename] do podłoża.</span>")
	I.play_tool_sound(src, 100)
	update_icon()
	return TRUE

/obj/structure/disposalconstruct/welder_act(mob/living/user, obj/item/I)
	if(anchored)
		if(!I.tool_start_check(user, amount=0))
			return TRUE

		add_fingerprint(user)
		to_chat(user, "<span class='notice'>Zaczynasz przyspawywać [pipename] na miejscu...</span>")
		if(I.use_tool(src, user, 8, volume=50))
			to_chat(user, "<span class='notice'>[pipename] zostaje przyspawana na miejscu.</span>")
			var/obj/O = new pipe_type(loc, src)
			transfer_fingerprints_to(O)
			qdel(src)
	else
		to_chat(user, "<span class='warning'>Najpierw musisz przymocować to do poszycia!</span>")
	return TRUE

/obj/structure/disposalconstruct/proc/is_pipe()
	return ispath(pipe_type, /obj/structure/disposalpipe)

//helper proc that makes sure you can place the construct (i.e no dense objects stacking)
/obj/structure/disposalconstruct/proc/can_place()
	if(is_pipe())
		return TRUE

	for(var/obj/structure/disposalconstruct/DC in get_turf(src))
		if(DC == src)
			continue

		if(!DC.is_pipe()) //there's already a chute/outlet/bin there
			return FALSE

	return TRUE
