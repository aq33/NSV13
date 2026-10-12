/obj/item/projectile/bullet/dnainjector
	name = "\improper DNA injector"
	icon_state = "syringeproj"
	var/obj/item/dnainjector/injector
	damage = 5
	hitsound_wall = "shatter"

/obj/item/projectile/bullet/dnainjector/on_hit(atom/target, blocked = FALSE)
	if(iscarbon(target))
		var/mob/living/carbon/M = target
		if(blocked != 100)
			if(M.can_inject(target_zone = def_zone))
				if(injector.inject(M, firer))
					QDEL_NULL(injector)
					return BULLET_ACT_HIT
			else
				blocked = 100
				target.visible_message("<span class='danger'>[src] zostaje odbity!</span>", \
									   "<span class='userdanger'>Ochroniono cię przed [src]!</span>")
	return ..()

/obj/item/projectile/bullet/dnainjector/Destroy()
	QDEL_NULL(injector)
	return ..()
