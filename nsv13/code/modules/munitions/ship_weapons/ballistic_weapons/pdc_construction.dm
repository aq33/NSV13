/obj/item/wallframe/pdc_frame
	name = "\improper PDC loading rack frame"
	desc = "Used for building PDC loading racks."
	icon = 'nsv13/icons/obj/munitions.dmi'
	icon_state = "pdc_frame"
	result_path = /obj/structure/frame/machine/ship_weapon/pdc_mount
	materials = list(/datum/material/iron=MINERAL_MATERIAL_AMOUNT*5)

/obj/structure/frame/machine/ship_weapon/pdc_mount
	name = "\improper PDC loading rack frame"
	desc = "Used for building PDC loading racks."
	icon = 'nsv13/icons/obj/munitions.dmi'
	icon_state = "pdc_frame"
	pixel_y = 26
	density = FALSE

/obj/structure/frame/machine/ship_weapon/pdc_mount/examine(mob/user)
	. = ..()
	switch(state)
		if(1)
			if(anchored)
				. += "Jest <b>przykręcony</b> do ściany, ale brakuje mu <i>przewodów</i>."
			else
				. += "<i>Śruby</i> są luźne. Pewnie da się go <b>zdjąć</b>."
		if(2)
			. += "Rama jest <b>okablowana</b>, ale brakuje <i>płytki drukowanej</i>."

/obj/structure/frame/machine/ship_weapon/pdc_mount/New(loc, ndir=dir)
	. = ..()
	if(ndir)
		setDir(ndir)
	update_icon()

/obj/structure/frame/machine/ship_weapon/pdc_mount/setDir(newdir)
	. = ..()
	pixel_x = (dir & 3)? 0 : (dir == 4 ? -26 : 26)
	pixel_y = (dir & 3)? (dir == 1 ? -26 : 26) : 0

	update_icon()

/obj/structure/frame/machine/ship_weapon/pdc_mount/attackby(obj/item/P, mob/user, params)
	if(istype(P, /obj/item/circuitboard/machine) && !istype(P, /obj/item/circuitboard/machine/pdc_mount))// Only accept our specific circuitboard
		to_chat(user, "<span class='warning'>Ta rama nie przyjmuje płytek tego typu!</span>")
		return TRUE
	if((state == 1) && (P.tool_behaviour == TOOL_SCREWDRIVER) && !anchored)
		to_chat(user, "<span class='warning'>Najpierw zdejmij to ze ściany!</span>")
		return TRUE
	. = ..()
	icon_state = initial(icon_state)

/obj/structure/frame/machine/ship_weapon/pdc_mount/wrench_act(mob/user, obj/item/tool)
	if(circuit)
		to_chat(user, "<span class='warning'>Najpierw wyjmij płytkę drukowaną!</span>")
		return TRUE
	return ..()

/obj/structure/frame/machine/ship_weapon/pdc_mount/attack_robot(mob/user)
	. = ..()
	attack_hand(user)

/obj/structure/frame/machine/ship_weapon/pdc_mount/attack_hand(mob/user)
	. = ..()
	switch(state)
		if(1)
			if(!do_after(user, 2 SECONDS, target=src))
				return TRUE
			to_chat(user, "<span class='notice'>Zdejmujesz ramę ze ściany.</span>")
			new /obj/item/wallframe/pdc_frame(loc)
			qdel(src)
			return TRUE
		if(2)
			if(anchored)
				to_chat(user, "<span class='warning'>Do tego musisz odkręcić ramę!</span>")
			else
				to_chat(user, "<span class='warning'>Najpierw wyjmij przewody!</span>")
			return TRUE
