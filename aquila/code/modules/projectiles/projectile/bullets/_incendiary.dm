// Turf fires (port of Yogstation #19738): incendiary rounds set the floor they hit on fire
/obj/item/projectile/bullet/incendiary/on_hit(atom/target, blocked = FALSE)
	. = ..()
	var/turf/open/target_turf = get_turf(target)
	if(istype(target_turf))
		target_turf.IgniteTurf(rand(8, 22))
