/obj/item/implanter
	name = "implanter"
	desc = "A sterile automatic implant injector."
	icon = 'icons/obj/syringe.dmi'
	icon_state = "implanter0"
	item_state = "syringe_0"
	lefthand_file = 'icons/mob/inhands/equipment/medical_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/medical_righthand.dmi'
	throw_speed = 3
	throw_range = 5
	w_class = WEIGHT_CLASS_SMALL
	materials = list(/datum/material/iron=600, /datum/material/glass=200)
	var/obj/item/implant/imp = null
	var/imp_type = null


/obj/item/implanter/update_icon()
	if(imp)
		icon_state = "implanter1"
	else
		icon_state = "implanter0"


/obj/item/implanter/attack(mob/living/M, mob/user)
	if(!istype(M))
		return
	if(user && imp)
		if(M != user)
			M.visible_message("<span class='warning'>[user] próbuje wszczepić implant [M].</span>", \
				"<span class='userdanger'>[user] próbuje wszczepić ci [src]!</span>")

		var/turf/T = get_turf(M)
		if(T && (M == user || do_mob(user, M, 50)))
			if(src && imp)
				if(imp.implant(M, user))
					if (M == user)
						to_chat(user, "<span class='notice'>Wszczepiasz sobie implant.</span>")
					else
						M.visible_message("[user] wszczepia implant [M].", "<span class='notice'>[user] wszczepia ci implant.</span>")
					imp = null
					update_icon()
				else
					to_chat(user, "<span class='warning'>[src] nie udaje się wszczepić implantu [M].</span>")

/obj/item/implanter/attackby(obj/item/W, mob/user, params)
	if(istype(W, /obj/item/pen))
		if(!user.is_literate())
			to_chat(user, "<span class='notice'>Szturchasz [src] za pomocą [W]!</span>")
			return
		var/t = stripped_input(user, "Jaka ma być etykieta?", name, null)
		if(user.get_active_held_item() != W)
			return
		if(!user.canUseTopic(src, BE_CLOSE))
			return
		if(t)
			name = "implanter ([t])"
		else
			name = "implanter"
	else
		return ..()

/obj/item/implanter/Initialize(mapload)
	. = ..()
	if(!imp && imp_type)
		imp = new imp_type(src)
	update_icon()
