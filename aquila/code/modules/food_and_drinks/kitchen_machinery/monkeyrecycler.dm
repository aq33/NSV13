// AQUILA - port tgstation/tgstation#90775: fioletowe paski, żeby recykler małp nie wyglądał jak maszynka do mięsa
/obj/machinery/monkey_recycler/Initialize(mapload)
	. = ..()
	update_icon()

/obj/machinery/monkey_recycler/update_overlays()
	. = ..()
	. += mutable_appearance('aquila/icons/obj/monkey_recycler.dmi', "grinder_monkey")
