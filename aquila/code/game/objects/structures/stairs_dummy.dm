//AQ ADDON - these stairs serve only decorative purposes

// dir determines the direction of travel to go upwards

/obj/structure/stairs_dummy
	name = "stairs"
	icon = 'icons/obj/stairs.dmi'
	icon_state = "stairs"
	anchored = TRUE

/obj/structure/stairs_dummy/Destroy()
	return ..()

// Passthrough for 0G travel
/obj/structure/stairs_dummy/attack_hand(mob/user)
	var/turf/T = get_turf(src)
	T.attack_hand(user)

/obj/structure/stairs_dummy/proc/update_surrounding()
	update_icon()
	for(var/i in GLOB.cardinals)
		var/turf/T = get_step(get_turf(src), i)
		var/obj/structure/stairs_dummy/S = locate() in T
		if(S)
			S.update_icon()
