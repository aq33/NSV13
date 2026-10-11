// AQUILA EDIT - amp stack: głośnik podłączany multitoolem do jukeboxa. Gra jego muzykę ze swojego miejsca,
// ciszej, na mniejszy zasięg i słabiej przebija ściany. Kliknięcie włącza/wyłącza.

/obj/machinery/jukebox_speaker
	name = "amp stack"
	desc = "Wzmacniacz z kolumną. Podłączony multitoolem do jukeboxa gra jego muzykę - ciszej niż jukebox i słabiej przez ściany. Kliknij, aby włączyć lub wyłączyć."
	icon = 'goon/icons/obj/loudspeakers.dmi'
	icon_state = "amp_stack"
	density = TRUE
	anchored = TRUE
	use_power = IDLE_POWER_USE
	idle_power_usage = 20
	circuit = /obj/item/circuitboard/machine/jukebox_speaker
	/// Jukebox, którego muzykę gra
	var/obj/machinery/jukebox/jukebox
	/// Włączony kliknięciem; wyłączony nie gra
	var/enabled = TRUE
	/// Maksymalna głośność względem jukeboxa
	var/max_gain = 0.7
	/// Zasięg w kratkach
	var/speaker_range = 8
	var/datum/music_emitter/emitter

/obj/machinery/jukebox_speaker/Initialize(mapload)
	. = ..()
	// mniejszy zasięg, pełna głośność tylko tuż obok, ściany tłumią dwa razy mocniej niż przy jukeboxie
	emitter = new(src, speaker_range, 1, 2, 2)

/obj/machinery/jukebox_speaker/Destroy()
	unlink()
	QDEL_NULL(emitter)
	return ..()

/obj/machinery/jukebox_speaker/examine(mob/user)
	. = ..()
	if(jukebox)
		. += "<span class='notice'>Podłączony do: [jukebox] ([get_area_name(jukebox, TRUE)]).</span>"
	else
		. += "<span class='notice'>Niepodłączony. Zapisz jukebox w multitoolu i kliknij nim ten głośnik.</span>"
	. += "<span class='notice'>Jest [enabled ? "włączony" : "wyłączony"].</span>"

/obj/machinery/jukebox_speaker/proc/link_to(obj/machinery/jukebox/new_jukebox)
	unlink()
	jukebox = new_jukebox
	jukebox.speakers |= src
	update_icon()

/obj/machinery/jukebox_speaker/proc/unlink()
	if(!jukebox)
		return
	jukebox.speakers -= src
	jukebox = null
	update_icon()

/// Czy ten głośnik może teraz grać (włączony, przykręcony, zasilony, sprawny)
/obj/machinery/jukebox_speaker/proc/can_play()
	return enabled && anchored && !(machine_stat & (BROKEN|NOPOWER))

/obj/machinery/jukebox_speaker/multitool_act(mob/living/user, obj/item/I)
	if(!multitool_check_buffer(user, I))
		return TRUE
	var/obj/item/multitool/M = I
	if(!istype(M.buffer, /obj/machinery/jukebox) || QDELETED(M.buffer))
		to_chat(user, "<span class='warning'>W pamięci [I] nie ma jukeboxa. Najpierw kliknij nim jukebox.</span>")
		return TRUE
	if(M.buffer == jukebox)
		to_chat(user, "<span class='notice'>[src] jest już podłączony do [jukebox].</span>")
		return TRUE
	var/obj/machinery/jukebox/new_jukebox = M.buffer
	if(new_jukebox.get_overmap() != get_overmap())
		to_chat(user, "<span class='warning'>[new_jukebox] jest poza zasięgiem - musi być na tym samym statku.</span>")
		return TRUE
	link_to(new_jukebox)
	to_chat(user, "<span class='notice'>Podłączasz [src] do [jukebox].</span>")
	SSjukeboxes.update_listeners()
	return TRUE

/obj/machinery/jukebox_speaker/interact(mob/user)
	. = ..()
	enabled = !enabled
	to_chat(user, "<span class='notice'>[enabled ? "Włączasz" : "Wyłączasz"] [src].</span>")
	playsound(src, 'sound/machines/click.ogg', 30, TRUE)
	update_icon()
	SSjukeboxes.update_listeners()

/obj/machinery/jukebox_speaker/attackby(obj/item/I, mob/user, params)
	if(default_unfasten_wrench(user, I))
		update_icon()
		return
	if(default_deconstruction_screwdriver(user, icon_state, icon_state, I))
		return
	if(default_deconstruction_crowbar(I))
		return
	return ..()

/obj/machinery/jukebox_speaker/power_change()
	. = ..()
	update_icon()

/obj/machinery/jukebox_speaker/update_icon_state()
	icon_state = (can_play() && jukebox?.yt_active) ? "amp_stack_actv" : "amp_stack"
	return ..()

/// Do skrzyni z cargo - luzem, do przykręcenia kluczem na miejscu
/obj/machinery/jukebox_speaker/unanchored
	anchored = FALSE

/obj/item/circuitboard/machine/jukebox_speaker
	name = "amp stack (Machine Board)"
	icon_state = "service"
	build_path = /obj/machinery/jukebox_speaker
	req_components = list(
		/obj/item/stock_parts/capacitor = 1,
		/obj/item/stack/cable_coil = 5)

/datum/design/board/jukebox_speaker
	name = "Machine Design (Amp Stack)"
	desc = "Płytka amp stacka - głośnika podłączanego do jukeboxa."
	id = "jukebox_speaker"
	materials = list(/datum/material/glass = 1000)
	build_path = /obj/item/circuitboard/machine/jukebox_speaker
	departmental_flags = DEPARTMENTAL_FLAG_SERVICE | DEPARTMENTAL_FLAG_ENGINEERING
	category = list("Misc. Machinery")

/// Dostępne od początku rundy, bez badań
/datum/techweb_node/aquila_audio
	id = "aquila_audio"
	tech_tier = 0
	starting_node = TRUE
	display_name = "Nagłośnienie"
	description = "Głośniki podłączane do jukeboxa i małe radio."
	design_ids = list("jukebox_speaker", "jukebox_radio")
