
/obj/structure/closet/body_bag
	name = "body bag"
	desc = "A plastic bag designed for the storage and transportation of cadavers."
	icon = 'icons/obj/bodybag.dmi'
	icon_state = "bodybag"
	density = FALSE
	mob_storage_capacity = 2
	open_sound = 'sound/items/zip.ogg'
	close_sound = 'sound/items/zip.ogg'
	open_sound_volume = 15
	close_sound_volume = 15
	integrity_failure = 0
	material_drop = /obj/item/stack/sheet/cotton/cloth
	delivery_icon = null //unwrappable
	anchorable = FALSE
	mouse_drag_pointer = MOUSE_ACTIVE_POINTER
	drag_slowdown = 0
	door_anim_time = 0 // no animation
	var/foldedbag_path = /obj/item/bodybag
	var/obj/item/bodybag/foldedbag_instance = null
	var/tagged = 0 // so closet code knows to put the tag overlay back

/obj/structure/closet/body_bag/Destroy()
	// If we have a stored bag, and it's in nullspace (not in someone's hand), delete it.
	if (foldedbag_instance && !foldedbag_instance.loc)
		QDEL_NULL(foldedbag_instance)
	return ..()

/obj/structure/closet/body_bag/attackby(obj/item/I, mob/user, params)
	if (istype(I, /obj/item/pen) || istype(I, /obj/item/toy/crayon))
		if(!user.is_literate())
			to_chat(user, "<span class='notice'>Bazgrzesz nieczytelnie na [src]!</span>")
			return
		var/t = stripped_input(user, "Jaka ma być etykieta?", name, null, 53)
		if(user.get_active_held_item() != I)
			return
		if(!user.canUseTopic(src, BE_CLOSE))
			return
		if(t)
			name = "body bag - [t]"
			tagged = 1
			update_icon()
		else
			name = "body bag"
		return
	else if(I.tool_behaviour == TOOL_WIRECUTTER)
		to_chat(user, "<span class='notice'>Odcinasz przywieszkę z [src].</span>")
		name = "body bag"
		tagged = 0
		update_icon()

/obj/structure/closet/body_bag/update_icon()
	..()
	if (tagged)
		add_overlay("bodybag_label")

/obj/structure/closet/body_bag/open(mob/living/user)
	. = ..()
	if(.)
		mouse_drag_pointer = MOUSE_INACTIVE_POINTER

/obj/structure/closet/body_bag/close()
	. = ..()
	if(.)
		density = FALSE
		mouse_drag_pointer = MOUSE_ACTIVE_POINTER

/obj/structure/closet/body_bag/MouseDrop(over_object, src_location, over_location)
	. = ..()
	if(over_object == usr && Adjacent(usr) && (in_range(src, usr) || usr.contents.Find(src)))
		if(!ishuman(usr))
			return
		if(opened)
			to_chat(usr, "<span class='warning'>Mocujesz się z [src], ale nie da się go złożyć, gdy jest rozpięty.</span>")
			return
		if(contents.len)
			to_chat(usr, "<span class='warning'>W [src] jest za dużo rzeczy, by go złożyć!</span>")
			return
		visible_message("<span class='notice'>[usr] składa [src].</span>")
		var/obj/item/bodybag/B = foldedbag_instance || new foldedbag_path
		usr.put_in_hands(B)
		qdel(src)


/obj/structure/closet/body_bag/bluespace
	name = "bluespace body bag"
	desc = "A bluespace body bag designed for the storage and transportation of cadavers."
	icon = 'icons/obj/bodybag.dmi'
	icon_state = "bluebodybag"
	foldedbag_path = /obj/item/bodybag/bluespace
	mob_storage_capacity = 15
	max_mob_size = MOB_SIZE_LARGE

/obj/structure/closet/body_bag/bluespace/MouseDrop(over_object, src_location, over_location)
	. = ..()
	if(over_object == usr && Adjacent(usr) && (in_range(src, usr) || usr.contents.Find(src)))
		if(!ishuman(usr))
			return
		if(opened)
			to_chat(usr, "<span class='warning'>Mocujesz się z [src], ale nie da się go złożyć, gdy jest rozpięty.</span>")
			return
		if(contents.len >= mob_storage_capacity / 2)
			to_chat(usr, "<span class='warning'>W [src] jest za dużo rzeczy, by go złożyć!</span>")
			return
		for(var/obj/item/bodybag/bluespace/B in src)
			to_chat(usr, "<span class='warning'>Nie możesz rekurencyjnie składać worków na zwłoki bluespace!</span>" )
			return
		visible_message("<span class='notice'>[usr] składa [src].</span>")
		var/obj/item/bodybag/B = foldedbag_instance || new foldedbag_path
		usr.put_in_hands(B)
		for(var/atom/movable/A in contents)
			A.forceMove(B)
			if(isliving(A))
				to_chat(A, "<span class='userdanger'>Nagle zostajesz wepchnięty w maleńką, ściśniętą przestrzeń!</span>")
		qdel(src)
