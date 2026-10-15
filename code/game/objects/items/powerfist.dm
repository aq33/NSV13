/obj/item/melee/powerfist
	name = "power-fist"
	desc = "A metal gauntlet with a piston-powered ram ontop for that extra 'ompfh' in your punch."
	icon_state = "powerfist"
	item_state = "powerfist"
	lefthand_file = 'icons/mob/inhands/weapons/melee_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/melee_righthand.dmi'
	flags_1 = CONDUCT_1
	attack_verb = list("wali", "wali pięścią", "uderza z mocą")
	force = 20
	attack_weight = 1
	throwforce = 10
	throw_range = 7
	w_class = WEIGHT_CLASS_NORMAL
	armor = list("melee" = 0, "bullet" = 0, "laser" = 0, "energy" = 0, "bomb" = 0, "bio" = 0, "rad" = 0, "fire" = 100, "acid" = 40, "stamina" = 0, "bleed" = 0)
	resistance_flags = FIRE_PROOF
	var/click_delay = 1.5
	var/fisto_setting = 1
	var/gasperfist = 3
	var/obj/item/tank/internals/tank = null //Tank used for the gauntlet's piston-ram.
	var/baseforce = 20


/obj/item/melee/powerfist/examine(mob/user)
	. = ..()
	if(!in_range(user, src))
		. += "<span class='notice'>Musisz podejść bliżej, by zobaczyć więcej.</span>"
		return
	if(tank)
		. += "<span class='notice'>[icon2html(tank, user)] Zamontowano [tank].</span>"


/obj/item/melee/powerfist/attackby(obj/item/W, mob/user, params)
	if(istype(W, /obj/item/tank/internals))
		if(!tank)
			var/obj/item/tank/internals/IT = W
			if(IT.volume <= 3)
				to_chat(user, "<span class='warning'>[IT] jest za mały na [src].</span>")
				return
			updateTank(W, 0, user)
	else if(W.tool_behaviour == TOOL_WRENCH)
		switch(fisto_setting)
			if(1)
				fisto_setting = 2
			if(2)
				fisto_setting = 3
			if(3)
				fisto_setting = 1
		W.play_tool_sound(src)
		to_chat(user, "<span class='notice'>Ustawiasz zawór tłoka [src] na [fisto_setting].</span>")
	else if(W.tool_behaviour == TOOL_SCREWDRIVER)
		if(tank)
			updateTank(tank, 1, user)

/obj/item/melee/powerfist/proc/updateTank(obj/item/tank/internals/thetank, removing = 0, mob/living/carbon/human/user)
	if(removing)
		if(!tank)
			to_chat(user, "<span class='notice'>Do [src] nie jest obecnie podłączona żadna butla.</span>")
			return
		to_chat(user, "<span class='notice'>Odłączasz [thetank] od [src].</span>")
		tank.forceMove(get_turf(user))
		user.put_in_hands(tank)
		tank = null
	if(!removing)
		if(tank)
			to_chat(user, "<span class='warning'>[src] ma już butlę.</span>")
			return
		if(!user.transferItemToLoc(thetank, src))
			return
		to_chat(user, "<span class='notice'>Podłączasz [thetank] do [src].</span>")
		tank = thetank


/obj/item/melee/powerfist/attack(mob/living/target, mob/living/user)
	if(!tank)
		to_chat(user, "<span class='warning'>[src] nie działa bez źródła gazu!</span>")
		return
	var/datum/gas_mixture/gasused = tank.air_contents.remove(gasperfist * fisto_setting)
	var/turf/T = get_turf(src)
	if(!T)
		return
	T.assume_air(gasused)
	if(!gasused)
		to_chat(user, "<span class='warning'>Butla [src] jest pusta!</span>")
		force = (baseforce / 5)
		attack_weight = 1
		playsound(loc, 'sound/weapons/punch1.ogg', 50, 1)
		target.visible_message("<span class='danger'>Pięść pneumatyczna [user] wydaje głuche łupnięcie, gdy uderza [target.name]!</span>", \
			"<span class='userdanger'>[user] uderza cię!</span>")
		if(ishuman(target))
			var/mob/living/carbon/human/H = target
			if(H.check_shields(src, force))
				return
		return ..()
	if(gasused.total_moles() < gasperfist * fisto_setting)
		to_chat(user, "<span class='warning'>Tłok [src] wydaje słaby syk, potrzeba więcej gazu!</span>")
		playsound(loc, 'sound/weapons/punch4.ogg', 50, 1)
		force = (baseforce / 2)
		attack_weight = 1
		target.visible_message("<span class='danger'>Pięść pneumatyczna [user] wydaje słaby syk, gdy uderza [target.name]!</span>", \
			"<span class='userdanger'>Cios [user] uderza z siłą!</span>")
		if(ishuman(target))
			var/mob/living/carbon/human/H = target
			if(H.check_shields(src, force))
				return
		return ..()
	force = (baseforce * fisto_setting)
	attack_weight = fisto_setting
	if(ishuman(target))
		var/mob/living/carbon/human/H = target
		if(H.check_shields(src, force))
			return
	target.visible_message("<span class='danger'>Pięść pneumatyczna [user] wydaje głośny syk, gdy uderza [target.name]!</span>", \
		"<span class='userdanger'>Krzyczysz z bólu, gdy cios [user] odrzuca cię do tyłu!</span>")
	new /obj/effect/temp_visual/kinetic_blast(target.loc)
	playsound(loc, 'sound/weapons/resonator_blast.ogg', 50, 1)
	playsound(loc, 'sound/weapons/genhit2.ogg', 50, 1)

	var/atom/throw_target = get_edge_target_turf(target, get_dir(src, get_step_away(target, src)))

	target.throw_at(throw_target, 5 * fisto_setting, 0.5 + (fisto_setting / 2))

	log_combat(user, target, "power fisted", src)

	user.changeNext_move(CLICK_CD_MELEE * click_delay)

	return ..()
