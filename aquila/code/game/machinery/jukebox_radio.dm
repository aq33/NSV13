// AQUILA EDIT - radio: mały jukebox do zbudowania z płytki. Własna playlista, mniejszy zasięg, dostęp dla każdego;
// amp stacki podłącza się do niego multitoolem tak samo jak do jukeboxa. Nie nadaje na cały statek (tylko jukebox).
// Ikona: boombox z tgstation (icons/obj/devices/voice.dmi, CC BY-SA 3.0), przyciemniony.

/obj/machinery/jukebox/radio
	name = "radio"
	desc = "Małe radio z odtwarzaczem playlist. Słychać je w pobliżu; multitoolem można podłączyć do niego amp stacki."
	icon = 'aquila/icons/obj/jukebox_radio.dmi'
	icon_state = "boombox"
	density = FALSE
	req_access = null
	max_integrity = 150
	integrity_failure = 75
	music_range = 10
	can_broadcast = FALSE
	circuit = /obj/item/circuitboard/machine/jukebox_radio

/obj/machinery/jukebox/radio/update_icon()
	var/playing = yt_active && mains && is_secured() && !(machine_stat & (BROKEN|NOPOWER))
	icon_state = playing ? "boombox_on" : "boombox"
	for(var/obj/machinery/jukebox_speaker/speaker as anything in speakers)
		speaker.update_icon()

/obj/machinery/jukebox/radio/attackby(obj/item/I, mob/user, params)
	if(panel_open && default_deconstruction_crowbar(I))
		return
	return ..()

/obj/item/circuitboard/machine/jukebox_radio
	name = "radio (Machine Board)"
	icon_state = "service"
	build_path = /obj/machinery/jukebox/radio
	req_components = list(
		/obj/item/stock_parts/capacitor = 1,
		/obj/item/stack/cable_coil = 2)

/datum/design/board/jukebox_radio
	name = "Machine Design (Radio)"
	desc = "Płytka małego radia z odtwarzaczem playlist."
	id = "jukebox_radio"
	materials = list(/datum/material/glass = 1000)
	build_path = /obj/item/circuitboard/machine/jukebox_radio
	departmental_flags = DEPARTMENTAL_FLAG_SERVICE | DEPARTMENTAL_FLAG_ENGINEERING
	category = list("Misc. Machinery")
