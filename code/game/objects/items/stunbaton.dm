/obj/item/melee/baton
	name = "stun baton"
	desc = "A stun baton which uses localised electrical shocks to cause muscular fatigue."
	icon_state = "stunbaton"
	item_state = "baton"
	lefthand_file = 'icons/mob/inhands/equipment/security_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/security_righthand.dmi'
	slot_flags = ITEM_SLOT_BELT
	force = 8
	throwforce = 7
	w_class = WEIGHT_CLASS_NORMAL
	attack_verb = list("egzekwuje prawo wobec")
	armor = list("melee" = 0, "bullet" = 0, "laser" = 0, "energy" = 0, "bomb" = 50, "bio" = 0, "rad" = 0, "fire" = 80, "acid" = 80, "stamina" = 0)

	var/stunforce = 75
	var/turned_on = FALSE
	var/obj/item/stock_parts/cell/cell
	var/hitcost = 1000
	var/throw_hit_chance = 35
	var/preload_cell_type //if not empty the baton starts with this type of cell

/obj/item/melee/baton/get_cell()
	return cell

/obj/item/melee/baton/suicide_act(mob/user)
	user.visible_message("<span class='suicide'>[user] wkłada sobie naładowany [name] do ust! Wygląda na to, że próbuje popełnić samobójstwo!</span>")
	return (FIRELOSS)

/obj/item/melee/baton/Initialize(mapload)
	. = ..()
	if(preload_cell_type)
		if(!ispath(preload_cell_type,/obj/item/stock_parts/cell))
			log_mapping("[src] at [AREACOORD(src)] had an invalid preload_cell_type: [preload_cell_type].")
		else
			cell = new preload_cell_type(src)
	update_icon()


/obj/item/melee/baton/Destroy()
	if(cell)
		QDEL_NULL(cell)
	return ..()

/obj/item/melee/baton/handle_atom_del(atom/A)
	if(A == cell)
		cell = null
		turned_on = FALSE
		update_icon()
	return ..()


/obj/item/melee/baton/throw_impact(atom/hit_atom, datum/thrownthing/throwingdatum)
	..()
	//Only mob/living types have stun handling
	if(turned_on && prob(throw_hit_chance) && iscarbon(hit_atom))
		baton_stun(hit_atom)

/obj/item/melee/baton/loaded //this one starts with a cell pre-installed.
	preload_cell_type = /obj/item/stock_parts/cell/high

/obj/item/melee/baton/proc/deductcharge(chrgdeductamt)
	if(cell)
		//Note this value returned is significant, as it will determine
		//if a stun is applied or not
		. = cell.use(chrgdeductamt)
		if(turned_on && cell.charge < hitcost)
			//we're below minimum, turn off
			turned_on = FALSE
			update_icon()
			playsound(src, "sparks", 75, TRUE, -1)


/obj/item/melee/baton/update_icon()
	if(obj_flags & OBJ_EMPED)
		icon_state = "[initial(icon_state)]"
	else if(turned_on)
		icon_state = "[initial(icon_state)]_active"
	else if(!cell)
		icon_state = "[initial(icon_state)]_nocell"
	else
		icon_state = "[initial(icon_state)]"

/obj/item/melee/baton/examine(mob/user)
	. = ..()
	if(cell)
		. += "<span class='notice'>[src] jest naładowany w [round(cell.percent())]%.</span>"
	else
		. += "<span class='warning'>[src] nie ma zainstalowanego źródła zasilania.</span>"

/obj/item/melee/baton/attackby(obj/item/W, mob/user, params)
	if(istype(W, /obj/item/stock_parts/cell))
		var/obj/item/stock_parts/cell/C = W
		if(cell)
			balloon_alert(user, "[src] ma już ogniwo.")
		else
			if(C.maxcharge < hitcost)
				balloon_alert(user, "[src] wymaga ogniwa zasilającego o większej pojemności.")
				return
			if(!user.transferItemToLoc(W, src))
				return
			cell = W
			balloon_alert(user, "Wkładasz ogniwo zasilające.")
			update_icon()

	else if(W.tool_behaviour == TOOL_SCREWDRIVER)
		if(cell)
			cell.update_icon()
			cell.forceMove(get_turf(src))
			cell = null
			balloon_alert(user, "Wyjmujesz ogniwo zasilające.")
			turned_on = FALSE
			update_icon()
	else
		return ..()

/obj/item/melee/baton/attack_self(mob/user)
	if(cell && cell.charge > hitcost && !(obj_flags & OBJ_EMPED))
		turned_on = !turned_on
		balloon_alert(user, "[src] [turned_on ? "on" : "off"]")
		playsound(src, "sparks", 75, TRUE, -1)
	else
		turned_on = FALSE
		if(!cell)
			balloon_alert(user, "Nie ma źródła zasilania!")
		else if(obj_flags & OBJ_EMPED)
			balloon_alert(user, "Nie reaguje!")
	update_icon()
	add_fingerprint(user)

/obj/item/melee/baton/attack(mob/M, mob/living/carbon/human/user)
	if(turned_on && HAS_TRAIT(user, TRAIT_CLUMSY) && prob(50) && !(obj_flags & OBJ_EMPED))
		user.visible_message("<span class='danger'>[user] przypadkiem uderza się [src], mocno się porażając!</span>", \
							"<span class='userdanger'>Przypadkiem uderzasz się [src], mocno się porażając!</span>")
		user.adjustStaminaLoss(stunforce*3)
		user.stuttering = 20
		user.do_jitter_animation(20)
		deductcharge(hitcost)
		return

	if(iscyborg(M))
		return ..()


	if(ishuman(M))
		var/mob/living/carbon/human/L = M
		if(check_martial_counter(L, user))
			return

	if(user.a_intent != INTENT_HARM)
		if(turned_on)
			if(baton_stun(M, user))
				user.do_attack_animation(M)
				return
		else
			M.visible_message("<span class='warning'>[user] szturcha [M] za pomocą [src]. Na szczęście była wyłączona.</span>", \
							"<span class='warning'>[user] szturcha cię [src]. Na szczęście była wyłączona</span>")
	else
		if(turned_on)
			baton_stun(M, user)
		return ..()

/obj/item/melee/baton/proc/baton_stun(mob/living/target, mob/living/user)
	if(obj_flags & OBJ_EMPED)
		return FALSE
	if(ishuman(target))
		var/mob/living/carbon/human/H = target
		if(H.check_shields(src, 0, "[user]'s [name]", MELEE_ATTACK)) //No message; check_shields() handles that
			playsound(H, 'sound/weapons/genhit.ogg', 50, TRUE)
			return FALSE
	if(iscyborg(loc))
		var/mob/living/silicon/robot/R = loc
		if(!R || !R.cell || !R.cell.use(hitcost))
			return FALSE
	else
		if(!deductcharge(hitcost))
			return FALSE

	target.Paralyze(stunforce) //NSV13 - re-added stun, removed stamina damage
	target.apply_effect(EFFECT_STUTTER, stunforce)
	SEND_SIGNAL(target, COMSIG_LIVING_MINOR_SHOCK) //Only used for nanites
	target.stuttering = 20
	target.do_jitter_animation(20)
	if(user)
		target.lastattacker = user.real_name
		target.lastattackerckey = user.ckey
		target.visible_message("<span class='danger'>[user] razi [target] prądem za pomocą [src]!</span>", \
								"<span class='userdanger'>[user] razi cię prądem za pomocą [src]!</span>")
		log_combat(user, target, "stunned")

	playsound(src, 'sound/weapons/egloves.ogg', 50, TRUE, -1)

	if(ishuman(target))
		var/mob/living/carbon/human/H = target
		H.force_say(user)


	return 1

/obj/item/melee/baton/emp_act(severity)
	. = ..()
	if (!(. & EMP_PROTECT_SELF) && !(obj_flags & OBJ_EMPED))
		obj_flags |= OBJ_EMPED
		update_icon()
		addtimer(CALLBACK(src, PROC_REF(emp_reset)), rand(1, 200 / severity))
		playsound(src, 'sound/machines/capacitor_discharge.ogg', 60, TRUE)

/obj/item/melee/baton/proc/emp_reset()
	obj_flags &= ~OBJ_EMPED
	update_icon()
	playsound(src, 'sound/machines/capacitor_charge.ogg', 100, TRUE)

//Makeshift stun baton. Replacement for stun gloves.
/obj/item/melee/baton/cattleprod
	name = "stunprod"
	desc = "An improvised stun baton."
	icon_state = "stunprod"
	item_state = "prod"
	lefthand_file = 'icons/mob/inhands/weapons/melee_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/melee_righthand.dmi'
	w_class = WEIGHT_CLASS_BULKY
	force = 3
	throwforce = 5
	stunforce = 70
	hitcost = 2000
	throw_hit_chance = 10
	slot_flags = ITEM_SLOT_BACK
	var/obj/item/assembly/igniter/sparkler = 0

/obj/item/melee/baton/cattleprod/Initialize(mapload)
	. = ..()
	sparkler = new (src)

/obj/item/melee/baton/cattleprod/baton_stun()
	if(obj_flags & OBJ_EMPED)
		return FALSE
	if(sparkler.activate())
		..()

/obj/item/melee/baton/cattleprod/Destroy()
	if(sparkler)
		QDEL_NULL(sparkler)
	return ..()
