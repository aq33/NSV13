// AQUILA - okno pustki, w które wędrowiec zamienia ściany (tg: voidwalker_window.dm)

/obj/structure/window/fulltile/voidwalker
	name = "void-smeared window"
	desc = "Okno tak przyciemnione, że po drugiej stronie widać tylko blask gwiazd. Nic się w nim nie odbija."
	max_integrity = 75 // bez odporności okna wzmocnionego
	/// Cząsteczki, żeby okno wyglądało upiornie
	var/obj/effect/abstract/voidwalker_particles/spooky_particles

/obj/structure/window/fulltile/voidwalker/Initialize(mapload, direct)
	. = ..()
	spooky_particles = new(src, /particles/void_window)
	vis_contents += spooky_particles
	add_atom_colour("#642a949d", FIXED_COLOUR_PRIORITY)

/obj/structure/window/fulltile/voidwalker/Destroy()
	vis_contents -= spooky_particles
	QDEL_NULL(spooky_particles)
	return ..()

/particles/void_window
	icon = 'aquila/icons/effects/voidwalker_goop.dmi'
	icon_state = list("goop_1" = 6, "goop_2" = 2, "goop_3" = 1)
	width = 100
	height = 100
	count = 100
	spawning = 2
	lifespan = 2 SECONDS
	fade = 4 SECONDS
	velocity = list(0, 0.2, 0)
	position = generator("box", list(-8, -16, 0), list(8, 16, 0), NORMAL_RAND)
	drift = generator("box", list(-8, -16, 0), list(8, 16, 0), NORMAL_RAND)
	spin = generator("num", -5, 5, NORMAL_RAND)
	friction = 0.5
	gravity = list(0, 0)
	grow = 0.05
	color = "#26114d9d"
	scale = list(0.75, 0.85)
