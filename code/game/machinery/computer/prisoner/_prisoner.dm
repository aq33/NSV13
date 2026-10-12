/obj/machinery/computer/prisoner
	var/obj/item/card/id/gulag/contained_id

/obj/machinery/computer/prisoner/Destroy()
	if(contained_id)
		contained_id.forceMove(get_turf(src))
	return ..()


/obj/machinery/computer/prisoner/examine(mob/user)
	. = ..()
	if(contained_id)
		. += "<span class='notice'><b>Alt-kliknij</b>, by wysunąć kartę ID.</span>"



/obj/machinery/computer/prisoner/AltClick(mob/user)
	id_eject(user)

/obj/machinery/computer/prisoner/proc/id_insert(mob/user, obj/item/card/id/gulag/P)
	if(!P)
		var/obj/item/held_item = user.get_active_held_item()
		if(istype(held_item, /obj/item/card/id/gulag))
			P = held_item

	if(istype(P))
		if(contained_id)
			to_chat(user, "<span class='warning'>W konsoli już jest karta ID!</span>")
			return
		if(!user.transferItemToLoc(P, src))
			return
		contained_id = P
		user.visible_message("<span class='notice'>[user] wkłada kartę ID do konsoli.</span>", \
							"<span class='notice'>Wkładasz kartę ID do konsoli.</span>")
		playsound(src, 'sound/machines/terminal_insert_disc.ogg', 50, FALSE)
		updateUsrDialog()

/obj/machinery/computer/prisoner/proc/id_eject(mob/user)
	if(!contained_id)
		to_chat(user, "<span class='warning'>W konsoli nie ma karty ID!</span>")
		return
	else
		contained_id.forceMove(drop_location())
		if(!issilicon(user) && Adjacent(user))
			user.put_in_hands(contained_id)
		contained_id = null
		user.visible_message("<span class='notice'>[user] wyjmuje kartę ID z konsoli.</span>", \
							"<span class='notice'>Wyjmujesz kartę ID z konsoli.</span>")
		playsound(src, 'sound/machines/terminal_insert_disc.ogg', 50, FALSE)
		updateUsrDialog()

/obj/machinery/computer/prisoner/attackby(obj/item/I, mob/user)
	if(istype(I, /obj/item/card/id/gulag))
		id_insert(user, I)
	else
		return ..()
