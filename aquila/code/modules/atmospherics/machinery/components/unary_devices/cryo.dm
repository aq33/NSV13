/// Bubbling of a working cryo cell (BeeStation #14436)
/obj/machinery/atmospherics/components/unary/cryo_cell
	var/datum/looping_sound/cryo_cell/soundloop

/obj/machinery/atmospherics/components/unary/cryo_cell/Initialize(mapload)
	. = ..()
	soundloop = new(src, FALSE)

/obj/machinery/atmospherics/components/unary/cryo_cell/Destroy()
	QDEL_NULL(soundloop)
	return ..()

/obj/machinery/atmospherics/components/unary/cryo_cell/process(delta_time)
	. = ..()
	if(on && !(machine_stat & (NOPOWER|BROKEN)))
		soundloop?.start()
	else
		soundloop?.stop()
