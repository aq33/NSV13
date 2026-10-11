/obj/machinery/computer
	var/datum/looping_sound/computer/soundloop


/obj/machinery/computer/Initialize(mapload, obj/item/circuitboard/C)
	. = ..()
	soundloop = new(src, FALSE)

/obj/machinery/computer/Destroy()
	QDEL_NULL(soundloop)
	return ..()


/// Keyboard clicks on every console action (BeeStation #14383), they replace the old keystroke sounds
/obj/machinery/computer
	clicksound = "keyboard_clicks"
	clickvol = 70 // the recordings are much quieter than the old keystrokes
