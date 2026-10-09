// AQUILA EDIT - wygłuszenie dźwięku przez przeszkody (na razie używa go jukebox).
// Wartość to ile przytłumienia (0-1) dokłada jedna przeszkoda na linii między źródłem a słuchaczem.

/atom
	var/sound_dampening = 0

/// Aktualne wygłuszenie - np. otwarte drzwi nie tłumią
/atom/proc/get_sound_dampening()
	return sound_dampening

/turf/closed
	sound_dampening = 0.35

/turf/closed/wall/r_wall
	sound_dampening = 0.5

/obj/structure/window
	sound_dampening = 0.1

/obj/structure/window/fulltile
	sound_dampening = 0.2

/obj/structure/window/reinforced
	sound_dampening = 0.15

/obj/structure/window/reinforced/fulltile
	sound_dampening = 0.25

/obj/machinery/door
	sound_dampening = 0.25

/obj/machinery/door/get_sound_dampening()
	return density ? sound_dampening : 0

/obj/structure/falsewall
	sound_dampening = 0.35

/obj/structure/falsewall/get_sound_dampening()
	return density ? sound_dampening : 0
