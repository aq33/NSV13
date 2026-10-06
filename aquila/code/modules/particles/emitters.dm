// Emitery przeportowane z Yogstation (code/modules/particles/byond_particles/emitter).

/obj/emitter/fire_smoke
	alpha = 150
	particles = new /particles/fire_smoke

/obj/emitter/fire_smoke/Initialize(mapload)
	. = ..()
	add_filter("blur", 1, list(type = "blur", size = 3))

/obj/emitter/flare_smoke
	layer = OBJ_LAYER
	particles = new /particles/smoke

/obj/emitter/flare_smoke/Initialize(mapload)
	. = ..()
	add_filter("blur", 1, list(type = "blur", size = 1.5))
	particles.position = list(8, -10, 0)

/obj/emitter/ipc_smoke
	particles = new /particles/smoke/ipc

/obj/emitter/fire
	alpha = 225
	particles = new /particles/fire
	var/fire_colour = "#FF3300"

/obj/emitter/fire/Initialize(mapload)
	. = ..()
	add_filter("outline", 1, list(type = "outline", size = 3, color = fire_colour))
	add_filter("bloom", 2, list(type = "bloom", threshold = rgb(255, 128, 255), size = 6, offset = 4, alpha = 255))

/obj/emitter/sparks
	plane = ABOVE_LIGHTING_PLANE

/obj/emitter/sparks/fire
	alpha = 225
	particles = new /particles/fire_sparks

/obj/emitter/sparks/flare
	particles = new /particles/flare_sparks

/obj/emitter/sparks/flare/Initialize(mapload)
	. = ..()
	add_filter("bloom", 1, list(type = "bloom", size = 3, offset = 0.5, alpha = 220))
