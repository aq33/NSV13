/obj/machinery/autodoc
	name = "autodoc"
	desc = "An advanced machine used for inserting organs and implants into the occupant."
	density = TRUE
	state_open = FALSE
	icon = 'icons/obj/machines/autodoc.dmi'
	icon_state = "autodoc_machine"
	verb_say = "stwierdza"
	idle_power_usage = 500
	circuit = null
	var/obj/item/organ/storedorgan
	var/organ_type = /obj/item/organ
	var/processing = FALSE
	var/surgerytime = 300

/obj/machinery/autodoc/Initialize()
	. = ..()
	update_icon()

/obj/machinery/autodoc/RefreshParts()
	var/max_time = 350
	for(var/obj/item/stock_parts/L in component_parts)
		max_time -= (L.rating*10)
	surgerytime = max(max_time,10)

/obj/machinery/autodoc/examine(mob/user)
	. = ..()
	if((obj_flags & EMAGGED) && panel_open)
		. += "<span class='warning'>Protokoły chirurgiczne [src] zostały uszkodzone!</span>"
	if(processing)
		. += "<span class='notice'>[src] wszczepia właśnie [storedorgan] do ciała [occupant].</span>"
	else if(storedorgan)
		. += "<span class='notice'>[src] jest gotowy do wszczepienia [storedorgan].</span>"

/obj/machinery/autodoc/close_machine(mob/user)
	..()
	playsound(src, 'sound/machines/click.ogg', 50)
	if(occupant)
		if(!iscarbon(occupant))
			occupant.forceMove(drop_location())
			occupant = null
			return
		to_chat(occupant, "<span class='notice'>Drzwi [src] zatrzaskują się za tobą.</span>")

		dosurgery()

/obj/machinery/autodoc/proc/dosurgery()
	if(!storedorgan && !(obj_flags & EMAGGED))
		to_chat(occupant, "<span class='notice'>[src] nie zawiera obecnie żadnego implantu.</span>")
		return

	occupant.visible_message("<span class='notice'>[occupant] naciska przycisk na [src]. Słychać mechaniczne buczenie.</span>", "<span class='notice'>Czujesz ostre ukłucie, gdy [src] zaczyna wszczepiać narząd do twojego ciała.</span>")
	playsound(get_turf(occupant), 'sound/weapons/circsawhit.ogg', 50, 1)
	processing = TRUE
	update_icon()
	var/mob/living/carbon/C = occupant
	if(obj_flags & EMAGGED)

		for(var/obj/item/bodypart/BP in reverseList(C.bodyparts)) //Chest and head are first in bodyparts, so we invert it to make them suffer more
			C.emote("scream")
			if(!HAS_TRAIT(C, TRAIT_NODISMEMBER))
				BP.dismember()
			else
				C.apply_damage(40, BRUTE, BP)
			sleep(5) //2 seconds to get outta there before dying
			if(!processing)
				return

		occupant.visible_message("<span class='warning'>[src] dismembers [occupant]!", "<span class='warning'>[src] rozpiłowuje twoje ciało!</span>")

	else
		sleep(surgerytime)
		if(!processing)
			return
		var/obj/item/organ/currentorgan = C.getorganslot(storedorgan.slot)
		if(currentorgan)
			currentorgan.Remove(C)
			currentorgan.forceMove(get_turf(src))
		storedorgan.Insert(occupant)//insert stored organ into the user
		storedorgan = null
		occupant.visible_message("<span class='notice'>[src] kończy procedurę chirurgiczną.", "<span class='notice'>[src] wszczepia narząd do twojego ciała.</span>")
	playsound(src, 'sound/machines/microwave/microwave-end.ogg', 100, 0)
	processing = FALSE
	use_power(5000)
	open_machine()

/obj/machinery/autodoc/open_machine(mob/user)
	if(processing)
		occupant.visible_message("<span class='notice'>[user] cancels [src]'s procedure.", "<span class='notice'>[src] przestaje wszczepiać narząd do twojego ciała.</span>")
		processing = FALSE
	if(occupant)
		occupant.forceMove(drop_location())
		occupant = null
	..(FALSE)

/obj/machinery/autodoc/interact(mob/user)
	if(panel_open)
		to_chat(user, "<span class='notice'>Najpierw zamknij panel serwisowy.</span>")
		return

	if(state_open)
		close_machine()
		return

	open_machine()

/obj/machinery/autodoc/attackby(obj/item/I, mob/user, params)
	if(istype(I, organ_type))
		if(storedorgan)
			to_chat(user, "<span class='notice'>[src] już zawiera implant.</span>")
			return
		if(!user.transferItemToLoc(I, src))
			return
		storedorgan = I
		I.forceMove(src)
		to_chat(user, "<span class='notice'>Wkładasz [I] do [src].</span>")
	else
		return ..()

/obj/machinery/autodoc/screwdriver_act(mob/living/user, obj/item/I)
	. = TRUE
	if(..())
		return
	if(occupant)
		to_chat(user, "<span class='warning'>[src] jest obecnie zajęty!</span>")
		return
	if(state_open)
		to_chat(user, "<span class='warning'>[src] musi być zamknięty, by [panel_open ? "zamknąć" : "otworzyć"] właz serwisowy!</span>")
		return
	if(default_deconstruction_screwdriver(user, icon_state, icon_state, I))
		if(storedorgan)
			storedorgan.forceMove(drop_location())
			storedorgan = null
		update_icon()
		return
	return FALSE

/obj/machinery/autodoc/crowbar_act(mob/living/user, obj/item/I)
	if(default_deconstruction_crowbar(I))
		return TRUE


/obj/machinery/autodoc/update_icon()
	overlays.Cut()
	if(!state_open)
		if(processing)
			overlays += "[icon_state]_door_on"
			overlays += "[icon_state]_stack"
			overlays += "[icon_state]_smoke"
			overlays += "[icon_state]_green"
		else
			overlays += "[icon_state]_door_off"
			if(occupant)
				if(powered(AREA_USAGE_EQUIP))
					overlays += "[icon_state]_stack"
					overlays += "[icon_state]_yellow"
			else
				overlays += "[icon_state]_red"
	else if(powered(AREA_USAGE_EQUIP))
		overlays += "[icon_state]_red"
	if(panel_open)
		overlays += "[icon_state]_panel"

/obj/machinery/autodoc/emag_act(mob/user)
	if(obj_flags & EMAGGED)
		return
	obj_flags |= EMAGGED
	to_chat(user, "<span class='warning'>Przeprogramowujesz procedury chirurgiczne [src].</span>")
