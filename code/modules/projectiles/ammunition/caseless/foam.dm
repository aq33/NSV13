/obj/item/ammo_casing/caseless/foam_dart
	name = "foam dart"
	desc = "It's nerf or nothing! Ages 8 and up."
	projectile_type = /obj/item/projectile/bullet/reusable/foam_dart
	caliber = "foam_force"
	icon = 'icons/obj/guns/toy.dmi'
	icon_state = "foamdart"
	materials = list(/datum/material/iron = 11.25)
	harmful = FALSE
	var/modified = FALSE

/obj/item/ammo_casing/caseless/foam_dart/update_icon()
	..()
	if (modified)
		icon_state = "foamdart_empty"
		desc = "It's nerf or nothing! ... Although, this one doesn't look too safe."
		if(BB)
			BB.icon_state = "foamdart_empty"
	else
		icon_state = initial(icon_state)
		desc = "It's nerf or nothing! Ages 8 and up."
		if(BB)
			BB.icon_state = initial(BB.icon_state)


/obj/item/ammo_casing/caseless/foam_dart/attackby(obj/item/A, mob/user, params)
	var/obj/item/projectile/bullet/reusable/foam_dart/FD = BB
	if (A.tool_behaviour == TOOL_SCREWDRIVER && !modified)
		modified = TRUE
		FD.modified = TRUE
		FD.damage_type = BRUTE
		to_chat(user, "<span class='notice'>Zdejmujesz nasadkę zabezpieczającą z [src].</span>")
		update_icon()
	else if (istype(A, /obj/item/pen))
		if(modified)
			if(!FD.pen)
				harmful = TRUE
				if(!user.transferItemToLoc(A, FD))
					return
				FD.pen = A
				FD.damage = 5
				FD.nodamage = FALSE
				to_chat(user, "<span class='notice'>Wkładasz [A] do [src].</span>")
			else
				to_chat(user, "<span class='warning'>W [src] już coś jest.</span>")
		else
			to_chat(user, "<span class='warning'>Nasadka zabezpieczająca nie pozwala ci włożyć [A] do [src].</span>")
	else
		return ..()

/obj/item/ammo_casing/caseless/foam_dart/attack_self(mob/living/user)
	var/obj/item/projectile/bullet/reusable/foam_dart/FD = BB
	if(FD.pen)
		FD.damage = initial(FD.damage)
		FD.nodamage = initial(FD.nodamage)
		user.put_in_hands(FD.pen)
		to_chat(user, "<span class='notice'>Wyjmujesz [FD.pen] z [src].</span>")
		FD.pen = null

/obj/item/ammo_casing/caseless/foam_dart/riot
	name = "riot foam dart"
	desc = "Whose smart idea was it to use toys as crowd control? Ages 18 and up."
	projectile_type = /obj/item/projectile/bullet/reusable/foam_dart/riot
	icon_state = "foamdart_riot"
	materials = list(/datum/material/iron = 1125)
