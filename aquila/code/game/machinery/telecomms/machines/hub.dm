/// Server hum of the telecommunications hub (BeeStation #14383)
/obj/machinery/telecomms/hub
	var/datum/looping_sound/server/sound_loop

/obj/machinery/telecomms/hub/Initialize(mapload)
	. = ..()
	sound_loop = new(src, on)

/obj/machinery/telecomms/hub/Destroy()
	QDEL_NULL(sound_loop)
	return ..()

/obj/machinery/telecomms/hub/update_power()
	. = ..()
	if(on)
		sound_loop?.start()
	else
		sound_loop?.stop()
