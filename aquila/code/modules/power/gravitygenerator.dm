/obj/machinery/gravity_generator/part/get_status()
	return main_part?.get_status()

/// Hum of a running gravity generator (BeeStation #14318)
/obj/machinery/gravity_generator/main
	var/datum/looping_sound/grav_gen/soundloop

/obj/machinery/gravity_generator/main/Initialize(mapload)
	. = ..()
	soundloop = new(src, on, FALSE, TRUE)

/obj/machinery/gravity_generator/main/Destroy()
	QDEL_NULL(soundloop)
	return ..()

/obj/machinery/gravity_generator/main/set_state(new_state)
	. = ..()
	if(on)
		soundloop?.start()
	else
		soundloop?.stop()
