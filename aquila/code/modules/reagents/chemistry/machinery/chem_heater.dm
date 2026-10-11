/datum/looping_sound/chem_heater
	mid_sounds = list('aquila/sound/machines/chemheater_loop.ogg' = 1)
	mid_length = 4 SECONDS
	volume = 15

/obj/machinery/chem_heater
	var/datum/looping_sound/chem_heater/soundloop
	/// Whether the ding for reaching the target temperature already played
	var/reached_target = FALSE

/obj/machinery/chem_heater/Initialize(mapload)
	. = ..()
	soundloop = new(src, FALSE)

/obj/machinery/chem_heater/Destroy()
	QDEL_NULL(soundloop)
	return ..()

/obj/machinery/chem_heater/process(delta_time)
	. = ..()
	var/heating = on && !(machine_stat & NOPOWER) && beaker?.reagents.total_volume
	if(!heating)
		soundloop.stop()
		reached_target = FALSE
		return
	soundloop.start()
	if(abs(beaker.reagents.chem_temp - target_temperature) <= 1)
		if(!reached_target)
			reached_target = TRUE
			playsound(src, 'sound/machines/ding.ogg', 40, TRUE)
	else
		reached_target = FALSE
