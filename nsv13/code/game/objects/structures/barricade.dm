/obj/structure/peacekeeper_barricade //CREDIT TO CM FOR THIS. Cleanup up by Kmc.
	icon = 'nsv13/icons/obj/barricades.dmi'
	anchored = TRUE
	density = TRUE
	layer = BELOW_OBJ_LAYER
	climbable = TRUE
	climb_time = 20 //Leaping a barricade is universally much faster than clumsily climbing on a table or rack
	climb_stun = 0
	var/stack_type //The type of stack the barricade dropped when disassembled if any.
	var/stack_amount = 5 //The amount of stack dropped when disassembled at full health
	var/destroyed_stack_amount //to specify a non-zero amount of stack to drop when destroyed
	max_integrity = 100 //Pretty tough. Changes sprites at 300 and 150
	var/base_acid_damage = 2
	var/barricade_resistance = 5 //How much force an item needs to even damage it at all.
	var/barricade_hitsound
	var/barricade_type = "barricade" //"metal", "plasteel", etc.
	var/can_change_dmg_state = TRUE
	var/damage_state = 0
	var/closed = FALSE
	var/can_wire = FALSE
	var/is_wired = FALSE
	var/image/wired_overlay
	var/build_state = 2 // 2 = Fully built.

/obj/structure/peacekeeper_barricade/metal
	name = "metal barricade"
	desc = "A sturdy and easily assembled barricade made of metal plates, often used for quick fortifications. Use a blowtorch to repair."
	icon_state = "metal_0"
	max_integrity = 200
	barricade_resistance = 10
	stack_type = /obj/item/stack/sheet/iron
	stack_amount = 4
	destroyed_stack_amount = 2
	barricade_hitsound = "sound/effects/metalhit.ogg"
	barricade_type = "metal"
	can_wire = TRUE

/obj/structure/peacekeeper_barricade/metal/plasteel
	name = "plasteel barricade"
	desc = "A very sturdy barricade made out of plasteel panels, the pinnacle of strongpoints. Use a blowtorch to repair. Can be flipped down to create a path."
	icon_state = "plasteel_closed_0"
	max_integrity = 400
	barricade_resistance = 20
	stack_type = /obj/item/stack/sheet/plasteel
	stack_amount = 5
	destroyed_stack_amount = 2
	barricade_hitsound = "sound/effects/metalhit.ogg"
	barricade_type = "plasteel"
	density = FALSE
	closed = TRUE

/obj/structure/peacekeeper_barricade/metal/plasteel/deployable //Preset one that starts unanchored and placed down.
	icon_state = "plasteel_0"
	closed = FALSE
	density = TRUE
	anchored = FALSE
	build_state = 0

/obj/structure/peacekeeper_barricade/do_climb(var/mob/living/user)
	if(is_wired) //Even trying this is gonna hurt...
		user.apply_damage(10)
		user.Stun(20) //Scaling barbed wire is VERY bad
	if(loc == user.loc)
		density = FALSE
		. = step(user,get_step(src,src.dir))
		density = TRUE
	else
		. = ..()

/obj/structure/peacekeeper_barricade/metal/plasteel/attack_hand(mob/user as mob)
	. = ..()
	if(.)
		return
	if(!ishuman(user))
		return
	var/turf/target = get_turf(user)
	if(get_dir(loc, target) & dir) //Don't let people who aren't behind the barricade through, as we plan to have PVP where humans are involved. If the barricade is flipped down, then theyre fine to flip it back up.
		if(!closed)
			user.visible_message("<span class='notice'>[user] napiera na [src], próbując go przewrócić!</span>",
			"<span class='notice'>Napierasz na [src], próbując go przewrócić!</span>")
			playsound(src.loc, 'sound/items/jaws_pry.ogg', 25, 1)
			if(!do_after(user, 100, target = src))
				return FALSE
	playsound(src.loc, 'sound/items/ratchet.ogg', 25, 1)
	closed = !closed
	density = !density

	if(closed)
		user.visible_message("<span class='notice'>[user] rozkłada [src].</span>",
		"<span class='notice'>Rozkładasz [src].</span>")
	else
		user.visible_message("<span class='notice'>[user] składa [src].</span>",
		"<span class='notice'>Składasz [src].</span>")

	update_icon()
	update_overlay()

/obj/structure/peacekeeper_barricade/Initialize(mapload)
	. = ..()
	var/static/list/loc_connections = list(
		COMSIG_ATOM_EXIT = PROC_REF(on_exit),
	)
	AddElement(/datum/element/connect_loc, loc_connections)
	update_icon()

/obj/structure/peacekeeper_barricade/examine(mob/user)
	. = ..()

	if(is_wired)
		. += "<span class='info'>Na szczycie tej barykady rozciągnięto drut.</span>"
	switch(damage_state)
		if(0) . += "<span class='info'>Wydaje się w dobrym stanie.</span>"
		if(1) . += "<span class='warning'>Jest lekko uszkodzona, ale wciąż w pełni sprawna.</span>"
		if(2) . += "<span class='warning'>Jest dość poobijana, ale się trzyma.</span>"
		if(3) . += "<span class='warning'>Rozpada się, jeszcze kilka ciosów i się rozleci.</span>"

/obj/structure/peacekeeper_barricade/hitby(atom/movable/AM, skipcatch, hitpush, blocked, datum/thrownthing/throwingdatum)
	if(AM.throwing && is_wired)
		if(iscarbon(AM))
			var/mob/living/carbon/C = AM
			C.visible_message("<span class='danger'>Drut kolczasty wcina się w [C]!</span>",
			"<span class='danger'>Drut kolczasty wcina się w ciebie!</span>")
			C.apply_damage(10)
			C.Stun(20) //Leaping into barbed wire is VERY bad
	..()

/obj/structure/peacekeeper_barricade/proc/on_exit(datum/source, atom/movable/leaving, direction)
	SIGNAL_HANDLER

	if(closed || !anchored)
		return 0
	if(istype(leaving, /obj/item/projectile))
		return 0 //who cares lol

	if(leaving.throwing)
		if(is_wired && iscarbon(leaving)) //Leaping mob against barbed wire fails
			if(direction & dir)
				return COMPONENT_ATOM_BLOCK_EXIT
		return 0

	if(direction & dir)
		return COMPONENT_ATOM_BLOCK_EXIT
	else
		return 0

/obj/structure/peacekeeper_barricade/CanAllowThrough(atom/movable/mover, turf/target)
	. = ..()
	if(closed)
		return TRUE
	if(mover && mover.throwing)
		if(is_wired && iscarbon(mover)) //Leaping mob against barbed wire fails
			if(get_dir(loc, target) & dir)
				return FALSE
		return TRUE

	if(istype(mover, /obj/vehicle))
		visible_message("<span class='danger'>[mover] przejeżdża po [src], niszcząc go!</span>")
		destroy_structure(0)
		return FALSE

	var/obj/structure/S = locate(/obj/structure) in get_turf(mover)
	if(S && S.climbable && climbable && isliving(mover)) //Climbable objects allow you to universally climb over others
		return TRUE
	if(get_dir(loc, target) & dir)
		return FALSE
	else
		return TRUE

/obj/structure/peacekeeper_barricade/attack_animal(mob/living/simple_animal/M)
	M.do_attack_animation(src)
	obj_integrity -= M.melee_damage
	if(barricade_hitsound)
		playsound(src, barricade_hitsound, 25, 1)
	if(obj_integrity <= 0)
		M.visible_message("<span class='danger'>[M] rozcina [src]!</span>", \
		"<span class='danger'>Rozcinasz [src]!</span>", null, 5)
	else
		M.visible_message("<span class='danger'>[M] slashes [src]!</span>", \
		"<span class='danger'>Tniesz [src]!</span>", null, 5)
	if(is_wired)
		M.visible_message("<span class='danger'>Drut kolczasty wcina się w [M]!</span>",
		"<span class='danger'>Drut kolczasty wcina się w ciebie!</span>", null, 5)
		M.apply_damage(10)
	update_health(TRUE)


/obj/structure/peacekeeper_barricade/metal/attackby(obj/item/I, mob/user, params)

	for(var/obj/effect/acid/A in get_turf(src))
		if(A.target == get_turf(src))
			to_chat(user, "Nie możesz się do tego zbliżyć, topi się!")
			return

	if(istype(I, /obj/item/stack/barbed_wire))
		var/obj/item/stack/barbed_wire/B = I
		if(!can_wire)
			return

		user.visible_message("<span class='notice'>[user] zaczyna rozkładać [I] na [src].</span>",
		"<span class='notice'>Zaczynasz rozkładać [I] na [src].</span>")
		if(!do_after(user, 20, target=src) || !can_wire)
			return

		playsound(loc, 'nsv13/sound/effects/barbed_wire_movement.ogg', 25, 1)
		user.visible_message("<span class='notice'>[user] rozkłada [I] na [src].</span>",
		"<span class='notice'>Rozkładasz [I] na [src].</span>")

		if(!closed)
			wired_overlay = image('nsv13/icons/obj/barricades.dmi', icon_state = "[barricade_type]_wire")
		else
			wired_overlay = image('nsv13/icons/obj/barricades.dmi', icon_state = "[barricade_type]_closed_wire")

		B.use(1)
		overlays += wired_overlay
		max_integrity += 50
		obj_integrity += 50
		update_health()
		can_wire = FALSE
		is_wired = TRUE
		return FALSE

	if(I.tool_behaviour == TOOL_WIRECUTTER)
		if(!is_wired)
			return

		user.visible_message("<span class='notice'>[user] zaczyna usuwać drut kolczasty z [src].</span>",
		"<span class='notice'>Zaczynasz usuwać drut kolczasty z [src].</span>")
		if(!I.use_tool(src, user, 20, volume=25))
			return

		user.visible_message("<span class='notice'>[user] usuwa drut kolczasty z [src].</span>",
		"<span class='notice'>Usuwasz drut kolczasty z [src].</span>")
		overlays -= wired_overlay
		max_integrity -= 50
		obj_integrity -= 50
		update_health()
		can_wire = TRUE
		is_wired = FALSE
		climbable = TRUE
		new /obj/item/stack/barbed_wire(loc)

	if(I.tool_behaviour == TOOL_WELDER)
		if(obj_integrity <= max_integrity * 0.3)
			to_chat(user, "<span class='warning'>[src] jest zbyt uszkodzona strukturalnie, by ją naprawić.</span>")
			return

		if(obj_integrity == max_integrity)
			to_chat(user, "<span class='warning'>[src] nie wymaga naprawy.</span>")
			return

		if(!I.tool_start_check(user, 1))
			return

		user.visible_message("<span class='notice'>[user] zaczyna naprawiać [src].</span>",
		"<span class='notice'>Zaczynasz naprawiać uszkodzenia [src].</span>")

		if(!I.use_tool(src, user, 50, 1, volume=25))
			return

		user.visible_message("<span class='notice'>[user] naprawia część uszkodzeń [src].</span>",
		"<span class='notice'>Naprawiasz [src].</span>")
		obj_integrity += 150
		update_health()

	switch(build_state)
		if(2) //Fully constructed step. Use screwdriver to remove the protection panels to reveal the bolts
			if(I.tool_behaviour == TOOL_SCREWDRIVER)
				if(!I.use_tool(src, user, 10, volume=25))
					return

				user.visible_message("<span class='notice'>[user] zdejmuje panel ochronny [src].</span>",
				"<span class='notice'>Zdejmujesz panele ochronne [src], odsłaniając śruby kotwiczące.</span>")
				build_state = 1
				return FALSE
		if(1) //Protection panel removed step. Screwdriver to put the panel back, wrench to unsecure the anchor bolts
			if(I.tool_behaviour == TOOL_SCREWDRIVER)
				if(!I.use_tool(src, user, 10, volume=25))
					return

				user.visible_message("<span class='notice'>[user] zakłada z powrotem panel ochronny [src].</span>",
				"<span class='notice'>Zakładasz z powrotem panel ochronny [src].</span>")
				build_state = 2
				return FALSE

			else if(I.tool_behaviour == TOOL_WRENCH)
				if(!I.use_tool(src, user, 10, volume=25))
					return

				user.visible_message("<span class='notice'>[user] luzuje śruby kotwiczące [src].</span>",
				"<span class='notice'>Luzujesz śruby kotwiczące [src].</span>")
				anchored = FALSE
				build_state = 0
				update_icon() //unanchored changes layer
				return FALSE
		if(0) //Anchor bolts loosened step. Apply crowbar to unseat the panel and take apart the whole thing. Apply wrench to resecure anchor bolts
			if(I.tool_behaviour == TOOL_WRENCH)
				for(var/obj/structure/peacekeeper_barricade/B in loc)
					if(B != src && B.dir == dir)
						to_chat(user, "<span class='warning'>Tu już jest barykada.</span>")
						return

				if(!I.use_tool(src, user, 10, volume=25))
					return

				user.visible_message("<span class='notice'>[user] dokręca śruby kotwiczące [src].</span>",
				"<span class='notice'>Dokręcasz śruby kotwiczące [src].</span>")
				build_state = 1
				anchored = TRUE
				update_icon() //unanchored changes layer
				return FALSE

			else if(I.tool_behaviour == TOOL_CROWBAR)

				user.visible_message("<span class='notice'>[user] zaczyna zdejmować panele [src].</span>",
				"<span class='notice'>Zaczynasz zdejmować panele [src].</span>")

				if(!I.use_tool(src, user, 50, volume=25))
					return

				user.visible_message("<span class='notice'>[user] rozbiera panele [src].</span>",
				"<span class='notice'>Rozbierasz panele [src].</span>")
				destroy_structure(TRUE) //Note : Handles deconstruction too !
				return FALSE
	. = ..()

/obj/structure/peacekeeper_barricade/proc/destroy_structure(deconstruct)
	if(deconstruct && is_wired)
		new /obj/item/stack/barbed_wire(loc)
	if(stack_type)
		var/stack_amt
		if(!deconstruct && destroyed_stack_amount)
			stack_amt = destroyed_stack_amount
		else
			stack_amt = round(stack_amount * (obj_integrity/max_integrity)) //Get an amount of sheets back equivalent to remaining health. Obviously, fully destroyed means 0

		if(stack_amt)
			new stack_type (loc, stack_amt)
	qdel(src)

/obj/structure/peacekeeper_barricade/ex_act(severity)
	switch(severity)
		if(1.0)
			visible_message("<span class='danger'>[src] zostaje rozerwana na kawałki!</span>")
			qdel(src)
			return
		if(2.0)
			obj_integrity -= rand(33, 66)
		if(3.0)
			obj_integrity -= rand(10, 33)
	update_health()

/obj/structure/peacekeeper_barricade/setDir(newdir)
	. = ..()
	update_icon()

/obj/structure/peacekeeper_barricade/update_icon()
	if(!closed)
		if(can_change_dmg_state)
			icon_state = "[barricade_type]_[damage_state]"
		else
			icon_state = "[barricade_type]"
		switch(dir)
			if(SOUTH)
				layer = ABOVE_MOB_LAYER
			if(NORTH)
				layer = initial(layer) - 0.01
			else
				layer = initial(layer)
		if(!anchored)
			layer = initial(layer)
	else
		if(can_change_dmg_state)
			icon_state = "[barricade_type]_closed_[damage_state]"
		else
			icon_state = "[barricade_type]_closed"
		layer = OBJ_LAYER

/obj/structure/peacekeeper_barricade/proc/update_overlay()
	if(!is_wired)
		return

	overlays -= wired_overlay
	if(!closed)
		wired_overlay = image('nsv13/icons/obj/barricades.dmi', icon_state = "[src.barricade_type]_wire")
	else
		wired_overlay = image('nsv13/icons/obj/barricades.dmi', icon_state = "[src.barricade_type]_closed_wire")
	overlays += wired_overlay

/obj/structure/peacekeeper_barricade/take_damage(damage_amount, damage_type = BRUTE, damage_flag = 0, sound_effect = 1, attack_dir, armour_penetration = 0)
	. = ..()
	update_health()
	playsound(src, "ricochet", 50, TRUE)

/obj/structure/peacekeeper_barricade/proc/update_health(nomessage)
	obj_integrity = CLAMP(obj_integrity, 0, max_integrity)

	if(!obj_integrity)
		if(!nomessage)
			visible_message("<span class='danger'>[src] się rozpada!</span>")
		destroy_structure()
		return

	update_damage_state()
	update_icon()

/obj/structure/peacekeeper_barricade/proc/update_damage_state()
	var/health_percent = round(obj_integrity/max_integrity * 100)
	switch(health_percent)
		if(0 to 25) damage_state = 3
		if(25 to 50) damage_state = 2
		if(50 to 75) damage_state = 1
		if(75 to INFINITY) damage_state = 0

/obj/structure/peacekeeper_barricade/AltClick(mob/user)
	. = ..()
	revrotate()

/obj/structure/peacekeeper_barricade/verb/rotate()
	set name = "Rotate Barricade Counter-Clockwise"
	set category = "Object"
	set src in oview(1)

	if(!isliving(usr))
		return FALSE
	var/mob/living/living_user = usr
	if(!Adjacent(living_user) || living_user.incapacitated())
		return FALSE
	if(anchored)
		to_chat(usr, "<span class='warning'>Jest przymocowana do podłogi, nie możesz jej obrócić!</span>")
		return FALSE

	setDir(turn(dir, 90))
	return

/obj/structure/peacekeeper_barricade/verb/revrotate()
	set name = "Rotate Barricade Clockwise"
	set category = "Object"
	set src in oview(1)

	if(!isliving(usr))
		return FALSE
	var/mob/living/living_user = usr
	if(!Adjacent(living_user) || living_user.incapacitated())
		return FALSE
	if(anchored)
		to_chat(usr, "<span class='warning'>Jest przymocowana do podłogi, nie możesz jej obrócić!</span>")
		return FALSE

	setDir(turn(dir, 270))
	return

/obj/structure/peacekeeper_barricade/CanAStarPass(obj/item/card/id/ID, to_dir, atom/movable/caller)
	. = ..()
	if(.)
		return
	if(!(dir in to_dir))
		return TRUE
	if(isknpc(caller))	//They can climb
		return TRUE
	return FALSE

/obj/item/stack/barbed_wire
	name = "barbed wire"
	desc = "A spiky length of wire."
	icon = 'nsv13/icons/obj/barricades.dmi'
	icon_state = "barbed_wire"
	singular_name = "length"
	w_class = WEIGHT_CLASS_SMALL
	force = 2
	throwforce = 5
	throw_speed = 5
	throw_range = 20
	attack_verb = list("uderza", "wali", "kroi")
	max_amount = 20
	merge_type = /obj/item/stack/barbed_wire

//small stack
/obj/item/stack/barbed_wire/five
	amount = 5

//half stack
/obj/item/stack/barbed_wire/ten
	amount = 10

//full stack
/obj/item/stack/barbed_wire/full
	amount = 20
