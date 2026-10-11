/obj/machinery/suit_storage_unit/infiltrator
	suit_type = /obj/item/clothing/suit/space/hardsuit/infiltration
	mask_type = /obj/item/clothing/mask/gas/syndicate
	storage_type = /obj/item/tank/jetpack/oxygen/harness

/// Hum of the UV cycle and a ding once it is done
/datum/looping_sound/suit_storage_uv
	mid_sounds = list('aquila/sound/machines/thermal/thermal_mid.ogg' = 1)
	mid_length = 2
	volume = 25

/obj/machinery/suit_storage_unit
	var/datum/looping_sound/suit_storage_uv/uv_soundloop

/obj/machinery/suit_storage_unit/Destroy()
	QDEL_NULL(uv_soundloop)
	return ..()

/obj/machinery/suit_storage_unit/cook()
	if(uv_cycles)
		if(!uv_soundloop)
			uv_soundloop = new(src, FALSE)
		uv_soundloop.start()
	else
		uv_soundloop?.stop()
		playsound(src, 'sound/machines/ding.ogg', 40, TRUE)
	return ..()
