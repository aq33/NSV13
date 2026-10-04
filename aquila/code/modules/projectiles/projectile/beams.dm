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
