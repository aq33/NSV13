/obj/item/inducer
	name = "heavy-duty inducer"
	desc = "A tool for inductively charging internal power cells. It is ruggedized for frequent use."
	icon = 'icons/obj/tools.dmi'
	icon_state = "inducer-engi"
	item_state = "inducer-engi"
	lefthand_file = 'icons/mob/inhands/equipment/tools_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/tools_righthand.dmi'
	force = 7
	var/powertransfer = 1000
	var/opened = FALSE
	var/cell_type = /obj/item/stock_parts/cell/high
	var/obj/item/stock_parts/cell/cell
	var/recharging = FALSE

/obj/item/inducer/Initialize(mapload)
	. = ..()
	if(!cell && cell_type)
		cell = new cell_type

/obj/item/inducer/proc/induce(obj/item/stock_parts/cell/target, coefficient)
	var/totransfer = min(cell.charge,(powertransfer * coefficient))
	var/transferred = target.give(totransfer)
	cell.use(transferred)
	cell.update_icon()
	target.update_icon()

/obj/item/inducer/get_cell()
	return cell

/obj/item/inducer/emp_act(severity)
	. = ..()
	if(cell && !(. & EMP_PROTECT_CONTENTS))
		cell.emp_act(severity)

/obj/item/inducer/attack_obj(obj/O, mob/living/carbon/user)
	if(user.a_intent == INTENT_HARM)
		return ..()

	if(cantbeused(user))
		return

	if(recharge(O, user))
		return

	return ..()

/obj/item/inducer/proc/cantbeused(mob/user)
	if(!user.IsAdvancedToolUser())
		to_chat(user, "<span class='warning'>Brakuje ci zręczności, by użyć [src]!</span>")
		return TRUE

	if(!cell)
		to_chat(user, "<span class='warning'>W [src] nie ma zainstalowanego ogniwa zasilającego!</span>")
		return TRUE

	if(!cell.charge)
		to_chat(user, "<span class='warning'>Bateria [src] jest wyczerpana!</span>")
		return TRUE
	return FALSE


/obj/item/inducer/attackby(obj/item/W, mob/user)
	if(W.tool_behaviour == TOOL_SCREWDRIVER)
		W.play_tool_sound(src)
		if(!opened)
			to_chat(user, "<span class='notice'>Odkręcasz komorę baterii.</span>")
			opened = TRUE
			update_icon()
			return
		else
			to_chat(user, "<span class='notice'>Zamykasz komorę baterii.</span>")
			opened = FALSE
			update_icon()
			return
	if(istype(W, /obj/item/stock_parts/cell))
		if(opened)
			if(!cell)
				if(!user.transferItemToLoc(W, src))
					return
				to_chat(user, "<span class='notice'>Wkładasz [W] do [src].</span>")
				cell = W
				update_icon()
				return
			else
				to_chat(user, "<span class='notice'>W [src] jest już zainstalowane [cell]!</span>")
				return

	if(cantbeused(user))
		return

	if(recharge(W, user))
		return

	return ..()

/obj/item/inducer/proc/recharge(atom/movable/A, mob/user)
	if(!isturf(A) && user.loc == A)
		return FALSE
	if(recharging)
		return TRUE
	else
		recharging = TRUE
	var/obj/item/stock_parts/cell/C = A.get_cell()
	var/obj/O
	var/coefficient = 1
	var/obj/item/organ/stomach/battery/battery
	if(istype(A, /obj/item/gun/energy))
		to_chat(user,"Błąd: nie można połączyć się z urządzeniem")
		return FALSE
	if(istype(A, /obj))
		O = A
	if(iscarbon(A))
		var/mob/living/carbon/human_target = A
		if(HAS_TRAIT(human_target, TRAIT_POWERHUNGRY))
			battery = human_target.getorganslot(ORGAN_SLOT_STOMACH)
			if(!istype(battery))
				return

	var/maxcharge = battery?.max_charge || C?.maxcharge
	if(C || battery)
		var/done_any = FALSE
		if((battery?.charge || C.charge) >= maxcharge)
			to_chat(user, "<span class='notice'>[A] jest w pełni naładowany!</span>")
			recharging = FALSE
			return TRUE
		user.visible_message("[user] zaczyna ładować [A] za pomocą [src].","<span class='notice'>Zaczynasz ładować [A] za pomocą [src].</span>")
		while((battery?.charge || C.charge) < maxcharge)
			if(do_after(user, 10, target = user) && cell.charge)
				done_any = TRUE
				if(battery)
					battery.adjust_charge(min(cell.charge,250))
				else
					induce(C, coefficient)
				do_sparks(1, FALSE, A)
				if(O)
					O.update_icon()
			else
				break
		if(done_any) // Only show a message if we succeeded at least once
			user.visible_message("[user] recharged [A]!","<span class='notice'>Ładujesz [A]!</span>")
		recharging = FALSE
		return TRUE
	recharging = FALSE


/obj/item/inducer/attack(mob/M, mob/user)
	if(user.a_intent == INTENT_HARM)
		return ..()

	if(cantbeused(user))
		return

	if(recharge(M, user))
		return
	return ..()


/obj/item/inducer/attack_self(mob/user)
	if(opened && cell)
		user.visible_message("[user] wyjmuje [cell] z [src]!","<span class='notice'>Wyjmujesz [cell].</span>")
		cell.update_icon()
		user.put_in_hands(cell)
		cell = null
		update_icon()
	if(!opened)
		recharge(user, user)


/obj/item/inducer/examine(mob/living/M)
	. = ..()
	if(cell)
		. += "<span class='notice'>Wyświetlacz pokazuje: [display_energy(cell.charge)].</span>"
	else
		. += "<span class='notice'>Wyświetlacz jest ciemny.</span>"
	if(opened)
		. += "<span class='notice'>Komora baterii jest otwarta.</span>"

/obj/item/inducer/update_icon()
	cut_overlays()
	if(opened)
		if(!cell)
			add_overlay("inducer-nobat")
		else
			add_overlay("inducer-bat")

///Starts empty for engineering protolathe
/obj/item/inducer/eng
	name = "heavy-duty inducer"
	cell_type = null
	opened = TRUE

/obj/item/inducer/eng/Initialize(mapload)
	. = ..()
	update_icon()

/obj/item/inducer/sci
	name = "inducer"
	icon_state = "inducer-sci"
	item_state = "inducer-sci"
	desc = "A tool for inductively charging internal power cells. This one has a science color scheme, and is less potent than its engineering counterpart."
	cell_type = null
	powertransfer = 500
	opened = TRUE

/obj/item/inducer/sci/Initialize(mapload)
	. = ..()
	update_icon()
