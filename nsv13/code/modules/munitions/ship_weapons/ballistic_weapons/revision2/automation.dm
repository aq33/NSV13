//Allows you to fully automate missile construction
/obj/machinery/missile_builder
	name = "\improper Seegson model 'Ford' robotic autowrench"
	desc = "An advanced robotic arm that can be arrayed with other such devices to form an assembly line for guided munition production. Swipe it with your ID to access maintenance mode options (only on some models!)"
	icon = 'nsv13/icons/obj/munitions/assembly.dmi'
	icon_state = "assemblybase"
	circuit = /obj/item/circuitboard/machine/missile_builder
	anchored = TRUE
	can_be_unanchored = TRUE
	density = TRUE
	processing_flags = START_PROCESSING_MANUALLY //Does not process.
	///Icon state the arm of this device will have
	var/arm_icon_state = "welder3"
	///An overlay for the machine that varies by its arm icon state. For some reason an item and not an overlay or any kind of effect.
	var/obj/item/arm = null //This being an /item makes me scream.
	///List of valid munition types. These are SUPER DIRTY types. DO NOT TRUST THESE TYPES. If you are reading this, new coder, PLEASE keep a common ancestor if you want to access vars and have the things be basically the same!!
	var/munition_types = list(/obj/item/ship_weapon/ammunition/missile/missile_casing, /obj/item/ship_weapon/ammunition/torpedo/torpedo_casing) //This is super bad but I don't feel like rewriting all of missile / torp casing code so it stays :)
	///The target construction states of the missile
	var/list/target_states = list(1, 7, 9)  //Who would magic number these even *after* having to reference them in machines too?? I am not cleaning up after you.. right now at least. -Delta
	///The turf this assembler is tracking
	var/turf/target_turf
	///The timer that tracks how long the arm should be doing arm things.
	var/active_arm_timer_id
	///Next time a success sound can play.
	var/next_success_sound = 0
	///Next time a fail sound can play.
	var/next_fail_sound = 0

/obj/machinery/missile_builder/attackby(obj/item/I, mob/user, params)
	if(default_unfasten_wrench(user, I))
		return
	if(default_deconstruction_screwdriver(user, icon_state, icon_state, I))
		update_icon()
		return
	if(default_deconstruction_crowbar(I))
		return
	. = ..()

/obj/machinery/missile_builder/default_unfasten_wrench(mob/user, obj/item/I, time)
	. = ..()
	if(. != SUCCESSFUL_UNFASTEN)
		return
	update_target_turf() // AQ EDIT

/obj/item/stack/conveyor/slow
	name = "Slow conveyor assembly"
	conveyor_type = /obj/machinery/conveyor/slow
	merge_type = /obj/item/stack/conveyor/slow
	color = list(1,1,0,0, 0,0,0,0, 0,0.1,1,0, 0,0,0,1, 0,0,0,0) //Yellow Belt

/obj/machinery/conveyor/slow
	name = "Slow conveyor"
	subsystem_type = /datum/controller/subsystem/machines
	stack_type = /obj/item/stack/conveyor/slow //What does this conveyor drop when decon'd?
	conveyor_speed = 2 SECONDS
	color = list(1,1,0,0, 0,0,0,0, 0,0.1,1,0, 0,0,0,1, 0,0,0,0) //Yellow Belt

/obj/machinery/missile_builder/wirer
	name = "Seegson model 'Ford' robotic autowirer"
	target_states = list(8)
	circuit = /obj/item/circuitboard/machine/missile_builder/wirer

/obj/machinery/missile_builder/welder
	name = "Seegson model 'Ford' robotic autowelder"
	target_states = list(10)
	circuit = /obj/item/circuitboard/machine/missile_builder/welder

/obj/machinery/missile_builder/screwdriver
	name = "Seegson model 'Ford' robotic bolt driver"
	target_states = list(3,5)
	circuit = /obj/item/circuitboard/machine/missile_builder/screwdriver

/obj/machinery/missile_builder/AltClick(mob/user)
	. = ..()
	// AQ EDIT - check the distance before touching the tracked turf, an alt-click from afar used to leave the arm watching nothing
	if(!user.TurfAdjacent(get_turf(src))) //Checks if mob is adjacent to the machine's turf before allowing rotation
		return
	setDir(turn(src.dir, -90))
	update_target_turf()

/// AQ EDIT - Watches the turf in front of the arm while anchored, and nothing while unanchored.
/obj/machinery/missile_builder/proc/update_target_turf()
	if(target_turf)
		UnregisterSignal(target_turf, COMSIG_ATOM_ENTERED)
		target_turf = null
	if(!anchored)
		return
	target_turf = get_step(src, dir)
	if(target_turf)
		RegisterSignal(target_turf, COMSIG_ATOM_ENTERED, PROC_REF(attempt_assembler_action))

/obj/machinery/missile_builder/Initialize(mapload)
	. = ..()
	arm = new /obj/item(src) //WHY IS THIS AN ITEM (worse, basetype..) and not an overlay or something else that would make more sense?!
	arm.icon = icon
	arm.icon_state = arm_icon_state
	vis_contents += arm
	arm.mouse_opacity = FALSE
	update_target_turf() // AQ EDIT

/obj/machinery/missile_builder/Destroy()
	qdel(arm)
	if(target_turf)
		UnregisterSignal(target_turf, COMSIG_ATOM_ENTERED)
		target_turf = null
	if(active_arm_timer_id)
		deltimer(active_arm_timer_id)
		active_arm_timer_id = null
	return ..()

/**
 * This beautiful proc handles interacting with objects that enter the turf we watch. Which is much more effective than processing all the time.
 * * Does not return anything. SHOULD NOT RETURN ANYTHING.
**/
/obj/machinery/missile_builder/proc/attempt_assembler_action(turf/source, atom/movable/entering, old_loc, old_locs)
	SIGNAL_HANDLER
	if(QDELETED(entering)) //How would this happen? Who knows.. but this is NSV after all.
		return
	if(!isobj(entering) || iseffect(entering))
		return
	if(!(entering.type in munition_types))
		visible_message("[src] shakes its arm melancholically.")
		arm.shake_animation()
		if(world.time >= next_fail_sound)
			playsound(src, 'sound/machines/buzz-sigh.ogg', 50, 0)
			next_fail_sound = world.time + 0.2 SECONDS
		return
	switch(entering.type) //This is VERY BAD but they do not share a common type.
		if(/obj/item/ship_weapon/ammunition/missile/missile_casing)
			var/obj/item/ship_weapon/ammunition/missile/missile_casing/missile_target = entering
			if(!(missile_target.state in target_states))
				visible_message("<span class='notice'>[src] sighs.</span>")
				if(world.time >= next_fail_sound)
					playsound(src, 'sound/machines/buzz-sigh.ogg', 50, 0)
					next_fail_sound = world.time + 0.5 SECONDS
				return
			trigger_arm_animation()
			missile_target.state++ //Next step!
			missile_target.check_completion()
			if(world.time >= next_success_sound)
				do_sparks(4, TRUE, missile_target)
				playsound(src, 'sound/items/welder.ogg', 100, 1)
				next_success_sound = world.time + 0.2 SECONDS
		if(/obj/item/ship_weapon/ammunition/torpedo/torpedo_casing)
			var/obj/item/ship_weapon/ammunition/torpedo/torpedo_casing/torpedo_target = entering
			if(!(torpedo_target.state in target_states))
				visible_message("<span class='notice'>[src] sighs.</span>")
				if(world.time >= next_fail_sound)
					playsound(src, 'sound/machines/buzz-sigh.ogg', 50, 0)
					next_fail_sound = world.time + 0.5 SECONDS
				return
			trigger_arm_animation()
			torpedo_target.state++ //Next step!
			torpedo_target.check_completion()
			if(world.time >= next_success_sound)
				do_sparks(4, TRUE, torpedo_target)
				playsound(src, 'sound/items/welder.ogg', 100, 1)
				next_success_sound = world.time + 0.2 SECONDS
		else
			CRASH("Please stop handing the missile assemblers invalid types as valid ammunition. Type: [entering.type]. ALL valid casings must be missile or torpedo types.")

//overrides parent.
/obj/machinery/missile_builder/assembler/attempt_assembler_action(turf/source, atom/movable/entering, old_loc, old_locs)
	if(QDELETED(entering)) //How would this happen? Who knows.. but this is NSV after all.
		return
	if(!isobj(entering) || iseffect(entering))
		return
	if(entering.loc != source)
		return
	if(tracked_component_type && istype(entering, tracked_component_type)) //Please do throw these hungry machines some components. AQ EDIT - any part of the tracked kind
		var/obj/item/entering_item = entering
		visible_message("<span class='notice'>[src] happily adds [entering_item] to its component storage.</span>")
		if(world.time >= next_success_sound)
			playsound(src, 'sound/machines/ping.ogg', 50, 0)
			next_success_sound = world.time + 0.2 SECONDS
		entering_item.do_pickup_animation(src)
		entering_item.forceMove(src)
		held_components += entering_item
		return
	if(!(entering.type in munition_types))
		visible_message("[src] shakes its arm melancholically.")
		arm.shake_animation()
		if(world.time >= next_fail_sound)
			playsound(src, 'sound/machines/buzz-sigh.ogg', 50, 0)
			next_fail_sound = world.time + 0.2 SECONDS
		return
	// AQ EDIT - missile and torpedo casings share the construction states and part vars, one path for both.
	// The arm used to only ever try its first stored part, so one mismatched part stalled the whole line.
	var/obj/item/ship_weapon/ammunition/casing = entering
	var/obj/item/ship_weapon/ammunition/missile/missile_casing/missile_target = entering
	var/obj/item/ship_weapon/ammunition/torpedo/torpedo_casing/torpedo_target = entering
	var/is_missile = istype(entering, /obj/item/ship_weapon/ammunition/missile/missile_casing)
	var/obj/item/ship_weapon/parts/missile/part = find_part_for(casing, is_missile ? missile_target.state : torpedo_target.state)
	if(!part)
		visible_message("<span class='notice'>[src] sighs.</span>")
		if(world.time >= next_fail_sound)
			playsound(src, 'sound/machines/buzz-sigh.ogg', 50, 0)
			next_fail_sound = world.time + 0.5 SECONDS
		return
	trigger_arm_animation()
	do_item_attack_animation(casing, used_item = part)

	held_components -= part
	part.forceMove(casing)
	if(is_missile)
		missile_target.register_part(part)
		missile_target.state++ //Next step!
		missile_target.check_completion()
	else
		torpedo_target.register_part(part)
		torpedo_target.state++
		torpedo_target.check_completion()
	if(world.time >= next_success_sound)
		do_sparks(4, TRUE, casing)
		playsound(src, 'sound/machines/ping.ogg', 50, 0)
		next_success_sound = world.time + 0.2 SECONDS

/// AQ EDIT - First stored part that fits the casing at its current construction state.
/obj/machinery/missile_builder/assembler/proc/find_part_for(obj/item/ship_weapon/ammunition/casing, casing_state)
	for(var/obj/item/ship_weapon/parts/missile/part as anything in held_components)
		if(QDELETED(part) || part.loc != src)
			held_components -= part
			continue
		if(part.target_state != casing_state)
			continue
		if(part.fits_type && !istype(casing, part.fits_type))
			continue
		return part

/// AQ EDIT - Remembers a part put in by the assembler arm the same way installing it by hand does, so the casing can still be worked on (and examined) by hand.
/obj/item/ship_weapon/ammunition/missile/missile_casing/proc/register_part(obj/item/ship_weapon/parts/missile/part)
	if(istype(part, /obj/item/ship_weapon/parts/missile/warhead))
		wh = part
	else if(istype(part, /obj/item/ship_weapon/parts/missile/guidance_system))
		gs = part
	else if(istype(part, /obj/item/ship_weapon/parts/missile/propulsion_system))
		ps = part
	else if(istype(part, /obj/item/ship_weapon/parts/missile/iff_card))
		iff = part

/// AQ EDIT - See /obj/item/ship_weapon/ammunition/missile/missile_casing/proc/register_part()
/obj/item/ship_weapon/ammunition/torpedo/torpedo_casing/proc/register_part(obj/item/ship_weapon/parts/missile/part)
	if(istype(part, /obj/item/ship_weapon/parts/missile/warhead))
		wh = part
	else if(istype(part, /obj/item/ship_weapon/parts/missile/guidance_system))
		gs = part
	else if(istype(part, /obj/item/ship_weapon/parts/missile/propulsion_system))
		ps = part
	else if(istype(part, /obj/item/ship_weapon/parts/missile/iff_card))
		iff = part

/// AQ EDIT - The kind of part (warhead, guidance, propulsion, IFF) the arm picks up from its belt, so every warhead variant counts as a warhead.
/obj/machinery/missile_builder/assembler/proc/part_kind(obj/item/ship_weapon/parts/missile/part)
	var/static/list/kinds = list(
		/obj/item/ship_weapon/parts/missile/warhead,
		/obj/item/ship_weapon/parts/missile/guidance_system,
		/obj/item/ship_weapon/parts/missile/propulsion_system,
		/obj/item/ship_weapon/parts/missile/iff_card,
	)
	for(var/kind in kinds)
		if(istype(part, kind))
			return kind
	return part.type

/// AQ EDIT - Stores a part and starts picking up parts of its kind from the belt.
/obj/machinery/missile_builder/assembler/proc/store_part(obj/item/ship_weapon/parts/missile/part)
	part.forceMove(src)
	held_components |= part
	if(!tracked_component_type)
		tracked_component_type = part_kind(part)

///Starts the machine's arm animation to reset after some time.
/obj/machinery/missile_builder/proc/trigger_arm_animation()
	if(arm.icon_state != "[arm_icon_state]_anim")
		arm.icon_state = "[arm_icon_state]_anim"
		visible_message("<span class='notice'>[src] whirrs into life!</span>")
	if(active_arm_timer_id)
		deltimer(active_arm_timer_id)
	active_arm_timer_id = addtimer(CALLBACK(src, PROC_REF(stop_arm_animation)), 1 SECONDS, TIMER_STOPPABLE)

///Stops the machine's arm animation after some time.
/obj/machinery/missile_builder/proc/stop_arm_animation()
	arm.icon_state = arm_icon_state
	active_arm_timer_id = null

/obj/machinery/missile_builder/assembler
	name = "Robotic Missile Part Applicator"
	arm_icon_state = "assembler2"
	desc = "An assembly arm which can slot a multitude of missile components into casings for you! Swipe it with an ID to release its stored components."
	req_one_access = list(ACCESS_MUNITIONS)
	circuit = /obj/item/circuitboard/machine/missile_builder/assembler
	///Currently loaded missile components.
	var/list/held_components = list()
	///Currently tracked type for autopickup
	var/tracked_component_type = null

/obj/machinery/missile_builder/assembler/examine(mob/user)
	. = ..()
	if(!length(held_components))
		return
	. += "<span class='notice'>It currently holds...</span>"
	var/listofitems = list()
	for(var/obj/item/C in held_components)
		var/path = C.type
		if(listofitems[path])
			listofitems[path]["amount"]++
		else
			listofitems[path] = list("name" = C.name, "amount" = 1)
	for(var/i in listofitems)
		. += "<span class='notice'>[listofitems[i]["name"]] x[listofitems[i]["amount"]]</span>"

/obj/machinery/missile_builder/assembler/Initialize(mapload)
	. = ..()
	if(mapload)
		return INITIALIZE_HINT_LATELOAD

/// AQ EDIT - Mappers place a part on the arm's own tile, load it so the arm starts out knowing which parts to collect.
/obj/machinery/missile_builder/assembler/LateInitialize()
	. = ..()
	for(var/obj/item/ship_weapon/parts/missile/part in loc)
		store_part(part)

/obj/machinery/missile_builder/assembler/Exited(atom/movable/gone, direction)
	. = ..()
	held_components -= gone // AQ EDIT - parts taken out any other way (deconstruction, explosions) do not stay in the list

/obj/machinery/missile_builder/assembler/attackby(obj/item/I, mob/living/user, params)
	// AQ EDIT - parts and IDs are handled before the parent proc, which used to also hit the machine with them
	if(istype(I, /obj/item/ship_weapon/parts/missile))
		if(!do_after(user, 0.5 SECONDS, target=src))
			return TRUE
		if(!user.transferItemToLoc(I, src))
			return TRUE
		to_chat(user, "<span class='notice'>You slot [I] into [src], ready for construction.</span>")
		tracked_component_type = part_kind(I)
		store_part(I)
		return TRUE
	if(istype(I, /obj/item/card/id) && allowed(user))
		to_chat(user, "<span class='warning'>You dump [src]'s contents out.</span>")
		for(var/obj/item/X in held_components)
			X.forceMove(get_turf(src))
		held_components.Cut()
		tracked_component_type = null
		return TRUE
	return ..()

/obj/machinery/missile_builder/assembler/MouseDrop_T(obj/structure/A, mob/user)
	. = ..()
	if(!isliving(user) || !user.Adjacent(src) || !user.Adjacent(A))
		return FALSE
	if(istype(A, /obj/structure/closet))
		// AQ EDIT - LAZYFIND looked for the type path itself in the contents, so loading from a crate never worked
		if(!(locate(/obj/item/ship_weapon/parts/missile) in A))
			to_chat(user, "<span class='warning'>There's nothing in [A] that can be loaded into [src]...</span>")
			return FALSE
		to_chat(user, "<span class='notice'>You start to load [src] with the contents of [A]...</span>")
		if(do_after(user, 4 SECONDS , target = src))
			for(var/obj/item/ship_weapon/parts/missile/P in A)
				store_part(P)

/datum/design/board/ammo_sorter_computer
	name = "Ammo sorter console (circuitboard)"
	desc = "The central control console for ammo sorters.."
	id = "ammo_sorter_computer"
	materials = list(/datum/material/glass = 2000, /datum/material/copper = 1000, /datum/material/gold = 500)
	build_path = /obj/item/circuitboard/computer/ammo_sorter
	category = list("Advanced Munitions")
	departmental_flags = DEPARTMENTAL_FLAG_MUNITIONS

/datum/design/board/ammo_sorter
	name = "Ammo sorter (circuitboard)"
	desc = "A helpful storage unit that allows for mass storage of ammunition, with the ability to retrieve it all from a central console."
	id = "ammo_sorter"
	materials = list(/datum/material/glass = 2000, /datum/material/copper = 1000, /datum/material/gold = 500)
	build_path = /obj/item/circuitboard/machine/ammo_sorter
	category = list("Advanced Munitions")
	departmental_flags = DEPARTMENTAL_FLAG_MUNITIONS

/obj/item/circuitboard/computer/ammo_sorter
	name = "ammo sorter console (circuitboard)"
	build_path = /obj/machinery/computer/ammo_sorter

/obj/item/circuitboard/machine/ammo_sorter
	name = "ammo sorter (circuitboard)"
	req_components = list(/obj/item/stock_parts/matter_bin = 3)
	build_path = /obj/machinery/ammo_sorter
	needs_anchored = FALSE

/obj/item/circuitboard/machine/ammo_sorter/upgraded
	def_components = list(/obj/item/stock_parts/matter_bin = /obj/item/stock_parts/matter_bin/bluespace) //item capacity of 21 (12+9)
