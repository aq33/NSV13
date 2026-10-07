// Aquila lasers are hitscan
/obj/item/projectile/beam/laser
	hitscan = TRUE

/obj/item/projectile/beam/weak
	hitscan = TRUE

/obj/item/projectile/beam/practice
	hitscan = TRUE

/obj/item/projectile/beam/xray
	hitscan = TRUE

// Hitscan emitter beam with its own tracer; no green impact effect, it uses the plain /obj/item/projectile/beam one
/obj/item/projectile/beam/emitter
	impact_effect_type = /obj/effect/temp_visual/impact_effect/red_laser
	tracer_type = /obj/effect/projectile/tracer/emitter
	muzzle_type = /obj/effect/projectile/muzzle/emitter
	impact_type = /obj/effect/projectile/impact/emitter
	hitscan = TRUE

// Turf fires (port of Yogstation #19738): some beams set the floor they hit on fire
/obj/item/projectile/beam/laser
	/// Whether this laser sets fire to the turf it hits
	var/fire_hazard = FALSE

/obj/item/projectile/beam/laser/heavylaser
	fire_hazard = TRUE

/obj/item/projectile/beam/laser/on_hit(atom/target, blocked = FALSE)
	. = ..()
	if(fire_hazard)
		var/turf/open/target_turf = get_turf(target)
		if(istype(target_turf))
			target_turf.IgniteTurf(rand(8, 16))

/obj/item/projectile/beam/pulse/on_hit(atom/target, blocked = FALSE)
	. = ..()
	var/turf/open/target_turf = get_turf(target)
	if(istype(target_turf))
		target_turf.IgniteTurf(rand(8, 22), "blue")
