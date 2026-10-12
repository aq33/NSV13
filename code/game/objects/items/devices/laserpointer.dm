/obj/item/laser_pointer
	name = "laser pointer"
	desc = "Don't shine it in your eyes!"
	icon = 'icons/obj/device.dmi'
	icon_state = "pointer"
	item_state = "pen"
	var/pointer_icon_state
	flags_1 = CONDUCT_1
	item_flags = NOBLUDGEON
	slot_flags = ITEM_SLOT_BELT
	materials = list(/datum/material/iron=500, /datum/material/glass=500)
	w_class = WEIGHT_CLASS_SMALL
	var/turf/pointer_loc
	var/energy = 5
	var/max_energy = 5
	var/effectchance = 33
	var/recharging = 0
	var/recharge_locked = FALSE
	var/obj/item/stock_parts/micro_laser/diode //used for upgrading!


/obj/item/laser_pointer/red
	pointer_icon_state = "red_laser"
/obj/item/laser_pointer/green
	pointer_icon_state = "green_laser"
/obj/item/laser_pointer/blue
	pointer_icon_state = "blue_laser"
/obj/item/laser_pointer/purple
	pointer_icon_state = "purple_laser"

/obj/item/laser_pointer/Initialize(mapload)
	. = ..()
	diode = new(src)
	if(!pointer_icon_state)
		pointer_icon_state = pick("red_laser","green_laser","blue_laser","purple_laser")

/obj/item/laser_pointer/upgraded/Initialize(mapload)
	. = ..()
	diode = new /obj/item/stock_parts/micro_laser/ultra

/obj/item/laser_pointer/attackby(obj/item/W, mob/user, params)
	if(istype(W, /obj/item/stock_parts/micro_laser))
		if(!diode)
			if(!user.transferItemToLoc(W, src))
				return
			diode = W
			to_chat(user, "<span class='notice'>Instalujesz [diode.name] w [src].</span>")
		else
			to_chat(user, "<span class='notice'>[src] ma już zainstalowaną diodę.</span>")

	else if(W.tool_behaviour == TOOL_SCREWDRIVER)
		if(diode)
			to_chat(user, "<span class='notice'>Wyjmujesz [diode.name] z [src].</span>")
			diode.forceMove(drop_location())
			diode = null
	else
		return ..()

/obj/item/laser_pointer/examine(mob/user)
	. = ..()
	if(in_range(user, src) || isobserver(user))
		if(!diode)
			. += "<span class='notice'>Brakuje diody.</span>"
		else
			. += "<span class='notice'>Zainstalowana jest dioda laserowa klasy <b>[diode.rating]</b>. Jest <i>przykręcona</i>.</span>"

/obj/item/laser_pointer/afterattack(atom/target, mob/living/user, flag, params)
	. = ..()
	laser_act(target, user, params)

/obj/item/laser_pointer/proc/laser_act(atom/target, mob/living/user, params)
	if( !(can_see(user,target,6)) )
		return
	if (!diode)
		to_chat(user, "<span class='notice'>Celujesz [src] w [target], ale nic się nie dzieje!</span>")
		return
	if (!user.IsAdvancedToolUser())
		to_chat(user, "<span class='warning'>Brakuje ci zręczności, by to zrobić!</span>")
		return
	if(HAS_TRAIT(user, TRAIT_NOGUNS))
		to_chat(user, "<span class='warning'>Twoje palce nie mogą wcisnąć przycisku!</span>")
		return
	if(user.has_dna())
		var/mob/living/carbon/C = user
		if(C.dna.check_mutation(HULK))
			to_chat(user, "<span class='warning'>Twoje palce nie mogą wcisnąć przycisku!</span>")
			return

	add_fingerprint(user)

	//nothing happens if the battery is drained
	if(recharge_locked)
		to_chat(user, "<span class='notice'>Celujesz [src] w [target], ale wciąż się ładuje.</span>")
		return

	var/outmsg
	var/turf/targloc = get_turf(target)

	//human/alien mobs
	if(iscarbon(target))
		var/mob/living/carbon/C = target
		if(user.zone_selected == BODY_ZONE_PRECISE_EYES)
			log_combat(user, C, "shone in the eyes", src)

			var/severity = 1
			if(prob(33))
				severity = 2
			else if(prob(50))
				severity = 0

			//chance to actually hit the eyes depends on internal component
			if(prob(effectchance * diode.rating) && C.flash_act(severity))
				outmsg = "<span class='notice'>Oślepiasz [C], świecąc mu [src] w oczy.</span>"
			else
				outmsg = "<span class='warning'>Nie udaje ci się oślepić [C], świecąc mu [src] w oczy!</span>"

	//robots
	else if(iscyborg(target))
		var/mob/living/silicon/S = target
		log_combat(user, S, "shone in the sensors", src)
		//chance to actually hit the eyes depends on internal component
		if(prob(effectchance * diode.rating))
			S.flash_act(affect_silicon = 1)
			S.Paralyze(rand(100,200))
			to_chat(S, "<span class='danger'>Twoje czujniki zostały przeciążone laserem!</span>")
			outmsg = "<span class='notice'>Przeciążasz [S], świecąc [src] w jego czujniki.</span>"
		else
			outmsg = "<span class='warning'>Nie udaje ci się przeciążyć [S], świecąc [src] w jego czujniki!</span>"

	//cameras
	else if(istype(target, /obj/machinery/camera))
		var/obj/machinery/camera/C = target
		if(prob(effectchance * diode.rating))
			C.emp_act(EMP_HEAVY)
			outmsg = "<span class='notice'>Trafiasz [src] w obiektyw [C], tymczasowo wyłączając kamerę!</span>"
			log_combat(user, C, "EMPed", src)
		else
			outmsg = "<span class='warning'>Chybiasz obiektywu [C]!</span>"

	// For luring whatever mobs that are "interested" in laser pointers
	for(var/mob/M as() in viewers(1,targloc))
		if(M.incapacitated())
			return
		var/mob/living/carbon/human/H = M
		if(iscatperson(H) && !H.eye_blind) //catpeople!
			if(user.mobility_flags & MOBILITY_STAND)
				H.setDir(get_dir(H,targloc)) // kitty always looks at the light
				if(prob(effectchance))
					H.visible_message("<span class='warning'>[H] próbuje złapać światełko!</span>","<span class='userdanger'>LIGHT!</span>")
					H.Move(targloc)
					log_combat(user, H, "moved with a laser pointer",src)
				else
					H.visible_message("<span class='notice'>[H] na chwilę daje się rozproszyć światełku.</span>","<span class = 'warning'> Przez chwilę kusi cię błyszczące światełko... </span>")
			else
				M.visible_message("<span class='notice'>[M] wpatruje się w światełko</span>","<span class = 'warning'> Wpatrujesz się w światełko... </span>")
		else if(iscat(M)) //cats!
			var/mob/living/simple_animal/pet/cat/C = M
			if(prob(50))
				C.visible_message("<span class='notice'>[C] rzuca się na światełko!</span>","<span class='warning'>LIGHT!</span>")
				C.Move(targloc)
				C.set_resting(TRUE, FALSE)
			else
				C.visible_message("<span class='notice'>[C] nie jest zainteresowany twoimi zabawami.</span>","<span class='warning'>Zauważasz, że [user] świeci w ciebie [src]. Co za obraza!</span>")

	//laser pointer image
	icon_state = "pointer_[pointer_icon_state]"
	var/image/I = image('icons/obj/projectiles.dmi',targloc,pointer_icon_state,10)
	var/list/click_params = params2list(params)
	if(click_params)
		if(click_params["icon-x"])
			I.pixel_x = (text2num(click_params["icon-x"]) - 16)
		if(click_params["icon-y"])
			I.pixel_y = (text2num(click_params["icon-y"]) - 16)
	else
		I.pixel_x = target.pixel_x + rand(-5,5)
		I.pixel_y = target.pixel_y + rand(-5,5)

	if(outmsg)
		to_chat(user, outmsg)
	else
		to_chat(user, "<span class='info'>Celujesz [src] w [target].</span>")

	energy -= 1
	if(energy <= max_energy)
		if(!recharging)
			recharging = 1
			START_PROCESSING(SSobj, src)
		if(energy <= 0)
			to_chat(user, "<span class='warning'>Bateria [src] jest przeciążona, musi się naładować!</span>")
			recharge_locked = TRUE

	flick_overlay_view(I, targloc, 10)
	icon_state = "pointer"

/obj/item/laser_pointer/process(delta_time)
	if(!diode)
		recharging = FALSE
		return PROCESS_KILL
	if(DT_PROB(10 + diode.rating*10 - recharge_locked*1, delta_time)) //t1 is 20, 2 40
		energy += 1
		if(energy >= max_energy)
			energy = max_energy
			recharging = 0
			recharge_locked = FALSE
			..()
