// Typy cząsteczek przeportowane z Yogstation (code/modules/particles/byond_particles/particle).
// Bazowe /particles/smoke i /particles/smoke/steam są już w nsv13/code/game/objects/effects/particles/smoke.dm.

/// Gęsty biały dym nad ogniem (ognisko)
/particles/fire_smoke
	icon = 'nsv13/icons/effects/smoke.dmi'
	icon_state = "smoke_3"
	width = 500
	height = 500
	count = 3000
	spawning = 3
	bound1 = list(-1000, 0, -1000)
	bound2 = list(1000, 75, 1000)
	lifespan = 20
	fade = 30
	fadein = 5
	velocity = list(0, 2)
	gravity = list(0, 1)
	position = generator("vector", list(-12, 8, 0), list(12, 8, 0))
	grow = list(0.3, 0.3)
	friction = 0.2
	drift = generator("vector", list(-0.16, -0.2), list(0.16, 0.2))
	color = "white"

/// Dym z przegrzanego IPC, bez przesunięcia
/particles/smoke/ipc
	position = list(0, 0, 0)

/// Płomienie (ognisko)
/particles/fire
	width = 500
	height = 500
	count = 3000
	spawning = 3
	lifespan = 10
	fade = 10
	velocity = list(0, 0)
	position = generator("vector", list(-9, 3, 0), list(9, 3, 0), NORMAL_RAND)
	drift = generator("vector", list(0, -0.2), list(0, 0.2))
	gravity = list(0, 0.65)
	color = "white"

/// Iskry z ognia (ognisko)
/particles/fire_sparks
	width = 500
	height = 500
	count = 3000
	spawning = 1
	lifespan = 40
	fade = 20
	position = 0
	gravity = list(0, 1)
	friction = 0.25
	drift = generator("sphere", 0, 2)
	gradient = list(0, "yellow", 1, "red")
	color = "yellow"

/// Iskry z flary
/particles/flare_sparks
	width = 500
	height = 500
	count = 2000
	spawning = 12
	lifespan = 0.75 SECONDS
	fade = 0.95 SECONDS
	position = generator("vector", list(8, -10, 0), list(8, -10, 0), NORMAL_RAND)
	velocity = generator("circle", -6, 6, NORMAL_RAND)
	friction = 0.15
	gradient = list(0, COLOR_WHITE, 0.4, COLOR_RED)
	color_change = 0.125
