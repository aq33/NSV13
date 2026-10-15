/obj/structure
	icon = 'icons/obj/structures.dmi'
	pressure_resistance = 8
	max_integrity = 300
	interaction_flags_atom = INTERACT_ATOM_ATTACK_HAND | INTERACT_ATOM_UI_INTERACT
	layer = BELOW_OBJ_LAYER
	pass_flags_self = PASSSTRUCTURE

	var/climb_time = 20
	var/climb_stun = 20
	var/climbable = FALSE
	var/mob/living/structureclimber
	var/broken = 0 //similar to machinery's stat BROKEN

	flags_ricochet = RICOCHET_HARD
	ricochet_chance_mod = 0.5

/obj/structure/Initialize(mapload)
	if (!armor)
		armor = list("melee" = 0, "bullet" = 0, "laser" = 0, "energy" = 0, "bomb" = 0, "bio" = 0, "rad" = 0, "fire" = 50, "acid" = 50, "stamina" = 0)
	. = ..()
	if(smooth)
		queue_smooth(src)
		queue_smooth_neighbors(src)
		icon_state = ""
	GLOB.cameranet.updateVisibility(src)

/obj/structure/Destroy()
	GLOB.cameranet.updateVisibility(src)
	if(smooth)
		queue_smooth_neighbors(src)
	return ..()

/obj/structure/attack_hand(mob/user)
	. = ..()
	if(.)
		return
	if(structureclimber && structureclimber != user)
		user.changeNext_move(CLICK_CD_MELEE)
		user.do_attack_animation(src)
		structureclimber.Paralyze(40)
		structureclimber.visible_message("<span class='warning'>[structureclimber] zostaje zrzucony z [src].", "Zostajesz zrzucony z [src]!", "Widzisz, jak [structureclimber] zostaje zrzucony z [src].</span>")

/obj/structure/ui_act(action, params)
	. = ..()
	add_fingerprint(usr)

/obj/structure/MouseDrop_T(atom/movable/O, mob/user)
	. = ..()
	if(!climbable)
		return
	if(user == O && iscarbon(O))
		var/mob/living/carbon/C = O
		if(C.mobility_flags & MOBILITY_MOVE)
			climb_structure(user)
			return
	if(!istype(O, /obj/item) || user.get_active_held_item() != O)
		return
	if(iscyborg(user))
		return
	if(!user.dropItemToGround(O))
		return
	if (O.loc != src.loc)
		step(O, get_dir(O, src))

/obj/structure/proc/do_climb(atom/movable/A)
	if(climbable)
		density = FALSE
		. = step(A,get_dir(A,src.loc))
		density = TRUE

/obj/structure/proc/climb_structure(mob/living/user)
	add_fingerprint(user)
	user.visible_message("<span class='warning'>[user] starts climbing onto [src].</span>", \
								"<span class='notice'>Zaczynasz wspinać się na [src]...</span>")
	var/adjusted_climb_time = climb_time
	if(user.restrained()) //climbing takes twice as long when restrained.
		adjusted_climb_time *= 2
	if(isalien(user))
		adjusted_climb_time *= 0.25 //aliens are terrifyingly fast
	if(HAS_TRAIT(user, TRAIT_FREERUNNING)) //do you have any idea how fast I am???
		adjusted_climb_time *= 0.8
	structureclimber = user
	if(do_mob(user, user, adjusted_climb_time))
		if(src.loc) //Checking if structure has been destroyed
			if(do_climb(user))
				user.visible_message("<span class='warning'>[user] climbs onto [src].</span>", \
									"<span class='notice'>Wspinasz się na [src].</span>")
				log_combat(user, src, "climbed onto")
				if(climb_stun)
					user.Stun(climb_stun)
				. = 1
			else
				to_chat(user, "<span class='warning'>Nie udaje ci się wspiąć na [src].</span>")
	structureclimber = null

/obj/structure/examine(mob/user)
	. = ..()
	if(!(resistance_flags & INDESTRUCTIBLE))
		if(resistance_flags & ON_FIRE)
			. += "<span class='warning'>Płonie!</span>"
		if(broken)
			. += "<span class='notice'>Wygląda na zepsuty.</span>"
		var/examine_status = examine_status(user)
		if(examine_status)
			. += examine_status

/obj/structure/proc/examine_status(mob/user) //An overridable proc, mostly for falsewalls.
	var/healthpercent = (obj_integrity/max_integrity) * 100
	switch(healthpercent)
		if(50 to 99)
			return  "Wygląda na lekko uszkodzony."
		if(25 to 50)
			return  "Wygląda na mocno uszkodzony."
		if(0 to 25)
			if(!broken)
				return  "<span class='warning'>Rozpada się!</span>"

/obj/structure/rust_heretic_act()
	take_damage(500, BRUTE, "melee", 1)
	return TRUE
