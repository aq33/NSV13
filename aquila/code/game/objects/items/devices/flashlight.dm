// Dym i iskry z zapalonej flary (port z Yogstation).

/obj/item/flashlight/flare
	/// Czy zapalona flara emituje dym i iskry
	var/flare_particle = TRUE

/obj/item/flashlight/flare/torch
	flare_particle = FALSE

/obj/item/flashlight/flare/update_brightness(mob/user = null)
	..()
	if(on && flare_particle)
		add_emitter(/obj/emitter/sparks/flare, "spark", 10)
		add_emitter(/obj/emitter/flare_smoke, "smoke", 9)
	else
		remove_emitter("spark")
		remove_emitter("smoke")
