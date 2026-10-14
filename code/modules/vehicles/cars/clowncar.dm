/obj/vehicle/sealed/car/clowncar
	name = "clown car"
	desc = "How someone could even fit in there is beyond me."
	icon_state = "clowncar"
	max_integrity = 150
	armor = list("melee" = 70, "bullet" = 40, "laser" = 40, "energy" = 0, "bomb" = 30, "bio" = 0, "rad" = 0, "fire" = 80, "acid" = 80, "stamina" = 0, "bleed" = 0)
	enter_delay = 20
	max_occupants = 50
	movedelay = 0.6
	car_traits = CAN_KIDNAP
	key_type = /obj/item/bikehorn
	key_type_exact = FALSE
	var/droppingoil = FALSE
	var/RTDcooldown = 150
	var/lastRTDtime = 0
	var/thankscount
	var/cannonmode = FALSE
	var/cannonbusy = FALSE

/obj/vehicle/sealed/car/clowncar/generate_actions()
	. = ..()
	initialize_controller_action_type(/datum/action/vehicle/sealed/horn/clowncar, VEHICLE_CONTROL_DRIVE)
	initialize_controller_action_type(/datum/action/vehicle/sealed/Thank, VEHICLE_CONTROL_KIDNAPPED)

/obj/vehicle/sealed/car/clowncar/auto_assign_occupant_flags(mob/M)
	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		if(H.mind?.assigned_role == JOB_NAME_CLOWN) //Ensures only clowns can drive the car. (Including more at once)
			add_control_flags(H, VEHICLE_CONTROL_DRIVE|VEHICLE_CONTROL_PERMISSION)
			RegisterSignal(H, COMSIG_MOB_CLICKON, PROC_REF(FireCannon))
			return
	add_control_flags(M, VEHICLE_CONTROL_KIDNAPPED)

/obj/vehicle/sealed/car/clowncar/mob_forced_enter(mob/M, silent = FALSE)
	. = ..()
	playsound(src, pick('sound/vehicles/clowncar_load1.ogg', 'sound/vehicles/clowncar_load2.ogg'), 75)

/obj/vehicle/sealed/car/clowncar/after_add_occupant(mob/M, control_flags)
	. = ..()
	if(return_controllers_with_flag(VEHICLE_CONTROL_KIDNAPPED).len >= 30)
		for(var/i in return_drivers())
			var/mob/voreman = i
			voreman.client.give_award(/datum/award/achievement/misc/round_and_full, voreman)

/obj/vehicle/sealed/car/clowncar/attack_animal(mob/living/simple_animal/M)
	if((M.loc != src) || M.environment_smash & (ENVIRONMENT_SMASH_WALLS|ENVIRONMENT_SMASH_RWALLS))
		return ..()

/obj/vehicle/sealed/car/clowncar/mob_exit(mob/M, silent = FALSE, randomstep = FALSE)
	. = ..()
	UnregisterSignal(M, COMSIG_MOB_CLICKON)

/obj/vehicle/sealed/car/clowncar/take_damage(damage_amount, damage_type = BRUTE, damage_flag = 0, sound_effect = 1, attack_dir)
	. = ..()
	if(prob(33))
		visible_message("<span class='danger'>[src] wyrzuca z siebie tonę kosmicznego smaru!</span>")
		new /obj/effect/particle_effect/foam(loc) //YEET

/obj/vehicle/sealed/car/clowncar/attacked_by(obj/item/I, mob/living/user)
	. = ..()
	if(istype(I, /obj/item/food/grown/banana))
		var/obj/item/food/grown/banana/banana = I
		obj_integrity += min(banana.seed.potency, max_integrity-obj_integrity)
		to_chat(user, "<span class='danger'>Naprawiasz [src] za pomocą [banana]!</span>")
		qdel(banana)

/obj/vehicle/sealed/car/clowncar/remove_occupant(mob/M)
	. = ..()
	if(iscarbon(M))
		var/mob/living/carbon/C = M
		C.uncuff()

/obj/vehicle/sealed/car/clowncar/Bump(atom/movable/M)
	. = ..()
	if(isliving(M))
		if(ismegafauna(M))
			return
		var/mob/living/L = M
		if(iscarbon(L))
			var/mob/living/carbon/C = L
			C.Paralyze(40) //I play to make sprites go horizontal
			restraintarget(C)
		L.visible_message("<span class='warning'>[src] taranuje [L] i go wciąga!</span>") //fuck off shezza this isn't ERP.
		mob_forced_enter(L)
		playsound(src, pick('sound/vehicles/clowncar_ram1.ogg', 'sound/vehicles/clowncar_ram2.ogg', 'sound/vehicles/clowncar_ram3.ogg'), 75)
	else if(istype(M, /turf/closed))
		visible_message("<span class='warning'>[src] taranuje [M] i się rozbija!</span>")
		playsound(src, pick('sound/vehicles/clowncar_crash1.ogg', 'sound/vehicles/clowncar_crash2.ogg'), 75)
		playsound(src, 'sound/vehicles/clowncar_crashpins.ogg', 75)
		DumpMobs(TRUE)

/obj/vehicle/sealed/car/clowncar/RunOver(mob/living/carbon/human/H)
	mob_forced_enter(H)
	H.visible_message("<span class='warning'>[src] przejeżdża po [H] i go wciąga!</span>")
	restraintarget(H)

/obj/vehicle/sealed/car/clowncar/proc/restraintarget(mob/living/carbon/C)
	if(istype(C))
		if(!C.handcuffed)
			if(C.get_num_arms(FALSE) >= 2 || C.get_arm_ignore())
				C.handcuffed = new /obj/item/restraints/handcuffs/energy/used(C)
				C.update_handcuffed()
				to_chat(C, "<span class = 'danger'> Ręce blokuje ci sama liczba pasażerów w samochodzie!</span>")

/obj/item/restraints/handcuffs/energy/used/clown
	name = "tangle of limbs"
	desc = "You are restrained in a tangle of bodies!"

/obj/vehicle/sealed/car/clowncar/emag_act(mob/user)
	if(obj_flags & EMAGGED)
		return
	obj_flags |= EMAGGED
	to_chat(user, "<span class='danger'>Rozwalasz zabezpieczenie przed dziećmi w samochodzie klauna i pojawia się panel z 6 kolorowymi przyciskami!</span>")
	initialize_controller_action_type(/datum/action/vehicle/sealed/RollTheDice, VEHICLE_CONTROL_DRIVE)
	initialize_controller_action_type(/datum/action/vehicle/sealed/Cannon, VEHICLE_CONTROL_DRIVE)
	AddComponent(/datum/component/waddling)

/obj/vehicle/sealed/car/clowncar/Destroy()
  playsound(src, 'sound/vehicles/clowncar_fart.ogg', 100)
  return ..()

/obj/vehicle/sealed/car/clowncar/after_move(direction)
	. = ..()
	if(droppingoil)
		new /obj/effect/decal/cleanable/oil/slippery(loc)

/obj/vehicle/sealed/car/clowncar/proc/RollTheDice(mob/user)
	if(world.time - lastRTDtime < RTDcooldown)
		to_chat(user, "<span class='notice'>Panel przycisków się ładuje.</span>")
		return
	lastRTDtime = world.time
	var/randomnum = rand(1,6)
	switch(randomnum)
		if(1)
			visible_message("<span class='danger'>[user] naciska jeden z kolorowych przycisków w [src], a ze środka wypada specjalna skórka od banana.</span>")
			new /obj/item/grown/bananapeel/specialpeel(loc)
		if(2)
			visible_message("<span class='danger'>[user] naciska jeden z kolorowych przycisków w [src], a ze środka wylewają się nieznane substancje.</span>")
			var/datum/reagents/R = new/datum/reagents(300)
			R.my_atom = src
			R.add_reagent(get_random_reagent_id(CHEMICAL_RNG_GENERAL), 100)
			var/datum/effect_system/foam_spread/foam = new
			foam.set_up(200, loc, R)
			foam.start()
		if(3)
			visible_message("<span class='danger'>[user] naciska jeden z kolorowych przycisków w [src], a samochód klauna włącza system maskowania jako osobliwość.</span>")
			icon = 'icons/obj/singularity.dmi'
			icon_state = "singularity_s1"
			addtimer(CALLBACK(src, PROC_REF(ResetIcon)), 100)
		if(4)
			visible_message("<span class='danger'>[user] naciska jeden z kolorowych przycisków w [src], a samochód klauna wypuszcza chmurę gazu rozweselającego.</span>")
			var/datum/reagents/R = new/datum/reagents(300)
			R.my_atom = src
			R.add_reagent(/datum/reagent/consumable/superlaughter, 50)
			var/datum/effect_system/smoke_spread/chem/smoke = new()
			smoke.set_up(R, 4)
			smoke.attach(src)
			smoke.start()
		if(5)
			visible_message("<span class='danger'>[user] naciska jeden z kolorowych przycisków w [src], a samochód klauna zaczyna zostawiać za sobą ślad oleju.</span>")
			droppingoil = TRUE
			addtimer(CALLBACK(src, PROC_REF(StopDroppingOil)), 30)
		if(6)
			visible_message("<span class='danger'>[user] naciska jeden z kolorowych przycisków w [src], a samochód klauna wydaje komiczny klakson.</span>")
			playsound(src, 'sound/vehicles/clowncar_fart.ogg', 100)
			for(var/mob/living/L in oviewers(6, loc))
				L.emote("laughs")
			for(var/mob/living/L in occupants)
				L.emote("laughs")

/obj/vehicle/sealed/car/clowncar/proc/ResetIcon()
	icon = initial(icon)
	icon_state = initial(icon_state)

/obj/vehicle/sealed/car/clowncar/proc/StopDroppingOil()
	droppingoil = FALSE

/obj/vehicle/sealed/car/clowncar/proc/ToggleCannon()
	cannonbusy = TRUE
	if(cannonmode)
		cannonmode = FALSE
		flick("clowncar_fromfire", src)
		icon_state = "clowncar"
		addtimer(CALLBACK(src, PROC_REF(LeaveCannonMode)), 20)
		playsound(src, 'sound/vehicles/clowncar_cannonmode2.ogg', 75)
		visible_message("<span class='danger'>[src] zaczyna wracać do trybu jazdy.</span>")
	else
		canmove = FALSE
		flick("clowncar_tofire", src)
		icon_state = "clowncar_fire"
		visible_message("<span class='danger'>[src] się otwiera, odsłaniając wielkie działo.</span>")
		addtimer(CALLBACK(src, PROC_REF(EnterCannonMode)), 20)
		playsound(src, 'sound/vehicles/clowncar_cannonmode1.ogg', 75)


/obj/vehicle/sealed/car/clowncar/proc/EnterCannonMode()
	mouse_pointer = 'icons/mecha/mecha_mouse.dmi'
	cannonmode = TRUE
	cannonbusy = FALSE
	for(var/mob/living/L in return_controllers_with_flag(VEHICLE_CONTROL_DRIVE))
		L.update_mouse_pointer()

/obj/vehicle/sealed/car/clowncar/proc/LeaveCannonMode()
	canmove = TRUE
	cannonbusy = FALSE
	mouse_pointer = null
	for(var/mob/living/L in return_controllers_with_flag(VEHICLE_CONTROL_DRIVE))
		L.update_mouse_pointer()

/obj/vehicle/sealed/car/clowncar/proc/FireCannon(mob/user, atom/A, params)
	SIGNAL_HANDLER

	if(cannonmode && return_controllers_with_flag(VEHICLE_CONTROL_KIDNAPPED).len)
		var/mob/living/L = pick(return_controllers_with_flag(VEHICLE_CONTROL_KIDNAPPED))
		mob_exit(L, TRUE)
		flick("clowncar_recoil", src)
		playsound(src, pick('sound/vehicles/carcannon1.ogg', 'sound/vehicles/carcannon2.ogg', 'sound/vehicles/carcannon3.ogg'), 75)
		L.throw_at(A, 10, 2)
		return COMSIG_MOB_CANCEL_CLICKON

/obj/vehicle/sealed/car/clowncar/proc/ThanksCounter()
	thankscount++
	if(thankscount >= 100)
		for(var/i in return_drivers())
			var/mob/busdriver = i
			busdriver.client.give_award(/datum/award/achievement/misc/the_best_driver, busdriver)
