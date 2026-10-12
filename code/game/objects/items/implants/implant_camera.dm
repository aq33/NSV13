/obj/item/implant/camera
	name = "camera implant"
	desc = "Watchful eye inside you."
	activated = FALSE
	var/obj/machinery/camera/camera

/obj/item/implant/camera/get_data()
	var/dat = {"<b>Specyfikacja implantu:</b><BR><b>Nazwa:</b> Implant kamery<BR><b>Żywotność:</b> 24 godziny po śmierci nosiciela<BR><b>Szczegóły implantu:</b> <BR><b>Działanie:</b> zdalna obserwacja nosiciela."}
	return dat

/obj/item/implant/camera/on_implanted(mob/user)
	camera = new (user)		//Insert the camera directly into the mob so the camera actually shows what it sees
	camera.c_tag = "IMPLANT #[rand(1, 999)]"
	camera.network = list("ss13")
	camera.internal_light = FALSE		//No AI camera light

/obj/item/implant/camera/removed(mob/living/source, silent, special)
	. = ..()
	if(.)
		QDEL_NULL(camera)
		return TRUE
	return FALSE

/obj/item/implanter/camera
	name = "implanter (camera)"
	imp_type = /obj/item/implant/camera

/obj/item/implantcase/camera
	name = "implant case - 'Camera'"
	desc = "A glass case containing a camera implant."
	imp_type = /obj/item/implant/camera
