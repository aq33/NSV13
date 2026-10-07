// Jukebox gra wyłącznie playlisty z YouTube (jukebox_youtube.dm). Tutaj: maszyna, UI i zasięg słyszenia.

/obj/machinery/jukebox
	name = "Jukebox"
	desc = "Tradycyjny odtwarzacz muzyczny."
	icon = 'aquila/icons/obj/jukebox.dmi'
	icon_state = "jukebox"
	verb_say = "states"
	density = TRUE
	req_access = list(ACCESS_BAR)
	interaction_flags_machine = INTERACT_MACHINE_SET_MACHINE | INTERACT_MACHINE_OPEN | INTERACT_MACHINE_ALLOW_SILICON | INTERACT_MACHINE_OPEN_SILICON
	max_integrity = 500
	integrity_failure = 250
	var/state_base = "jukebox"
	var/seconds_electrified = MACHINE_NOT_ELECTRIFIED
	var/speed_servo_regulator_cut = FALSE //vaporwave
	var/speed_servo_resistor_cut = FALSE //nightcore
	var/mains = TRUE
	var/verify = TRUE
	var/speed_potentiometer = 1.0
	/// Przecięty kabel: nie da się wybrać utworu z listy
	var/selection_blocked = FALSE
	/// Przecięty kabel: nie da się zatrzymać muzyki
	var/stop_blocked = FALSE
	/// Gałka głośności w procentach
	var/volume = 50
	/// Promień (w kratkach) okręgu, w którym słychać muzykę
	var/music_range = 20
	/// Do tej odległości muzyka gra pełną głośnością, dalej cichnie
	var/music_full_range = 3

/obj/machinery/jukebox/disco
	name = "Disco Jukebox"
	desc = "Odtwarzacz muzyczny w wersji Disco."

/obj/machinery/jukebox/disco/indestructible
	name = "Niezniszczalny Disco Jukebox"
	req_access = null
	anchored = TRUE
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF
	flags_1 = NODECONSTRUCT_1

/obj/machinery/jukebox/Initialize()
	. = ..()
	wires = new /datum/wires/jukebox(src)
	update_icon()

/obj/machinery/jukebox/Destroy()
	yt_stop()
	QDEL_NULL(wires)
	return ..()

/obj/machinery/jukebox/power_change()
	..()
	update_icon()
	if(((machine_stat & NOPOWER) || !mains) && yt_active)
		yt_stop()

/obj/machinery/jukebox/obj_break()
	. = ..()
	if(.)
		yt_stop()
		playsound(loc, 'sound/effects/glassbr3.ogg', 100, 1)

/obj/machinery/jukebox/attackby(obj/item/I, mob/user, params)
	if(default_unfasten_wrench(user, I))
		return
	if(default_deconstruction_screwdriver(user, icon_state, icon_state, I))
		update_icon()
		return
	if(panel_open && is_wire_tool(I))
		wires.interact(user)
		return TRUE
	if(I.tool_behaviour == TOOL_WELDER && user.a_intent == INTENT_HELP)
		if(obj_integrity < max_integrity)
			if(!I.tool_start_check(user, amount=5))
				return
			to_chat(user, "<span class='notice'>You begin repairing [src].</span>")
			if(I.use_tool(src, user, 40, amount=5, volume=50))
				obj_integrity = max_integrity
				machine_stat &= ~BROKEN
				update_icon()
				to_chat(user, "<span class='notice'>You repair [src].</span>")
				return
	return ..()

/obj/machinery/jukebox/default_unfasten_wrench(mob/user, obj/item/I, time = 20)
	. = ..()
	if(. == SUCCESSFUL_UNFASTEN)
		if(!anchored)
			yt_stop()
		update_icon()

/obj/machinery/jukebox/_try_interact(mob/user)
	if(seconds_electrified)
		if(shock(user, 100))
			return
	return ..()

/obj/machinery/jukebox/proc/shock(mob/user, prb)
	if(machine_stat & NOPOWER || !mains)
		return FALSE
	if(!prob(prb))
		return FALSE
	do_sparks(5, TRUE, src)
	var/check_range = TRUE
	if(electrocute_mob(user, get_area(src), src, 0.7, check_range))
		return TRUE
	else
		return FALSE

/obj/machinery/jukebox/update_icon()
	overlays = 0
	icon_state = "[state_base]"
	if((machine_stat & MAINT) || panel_open)
		overlays += image(icon = icon, icon_state = "[state_base]-panel")
	if(!(machine_stat & NOPOWER) && anchored && mains)
		if(machine_stat & BROKEN)
			overlays += image(icon = icon, icon_state = "[state_base]-broken")
		else
			overlays += image(icon = icon, icon_state = "[state_base]-powered")
			if(yt_active)
				overlays += image(icon = icon, icon_state = "[state_base]-playing")

/obj/machinery/jukebox/ui_interact(mob/user)
	. = ..()
	if(machine_stat & (BROKEN|NOPOWER) || !mains)
		return
	if(!user.canUseTopic(src, !issilicon(user)))
		return
	if (!anchored)
		to_chat(user,"<span class='warning'>To urządzenie musi wpierw był przykręcone do podłoża!</span>")
		return
	var/list/dat = list()
	dat += "<div class='statusDisplay' style='text-align:center'>"
	if(yt_active && yt_index)
		dat += "Teraz gra: <b>[html_encode(yt_tracks[yt_index]["title"])]</b><br>"
	else
		dat += "<i>Cisza</i><br>"
	if(yt_active)
		dat += "<a href='?src=[REF(src)];action=stop'>Zatrzymaj</a> "
	dat += "Głośność: <a href='?src=[REF(src)];action=volume;delta=-10'>-</a> [volume]% <a href='?src=[REF(src)];action=volume;delta=10'>+</a>"
	dat += "</div>"
	dat += yt_ui()
	var/datum/browser/popup = new(user, "vending", "[name]", 450, 600)
	popup.set_content(dat.Join())
	popup.open()

/obj/machinery/jukebox/Topic(href, href_list)
	if(..())
		return
	if(machine_stat & (BROKEN|NOPOWER) || !mains)
		return
	if(!anchored)
		to_chat(usr, "<span class='warning'>To urządzenie musi najpierw być przykręcone do podłoża!</span>")
		return
	if(!allowed(usr) && verify)
		to_chat(usr,"<span class='warning'>Nie masz uprawnień, aby korzystać z tego urządzenia.</span>")
		playsound(src,'sound/machines/deniedbeep.ogg', 50, 1)
		return
	add_fingerprint(usr)
	if(seconds_electrified)
		if(shock(usr, 100))
			return
	if(findtext(href_list["action"], "yt_") == 1)
		yt_topic(href_list["action"], href_list, usr)
		return
	switch(href_list["action"])
		if("stop")
			if(stop_blocked)
				to_chat(usr, "<span class='warning'>Wciskasz przycisk zatrzymania odtwarzania, ale nic się nie dzieje. Dziwne.</span>")
			else
				yt_stop()
		if("volume")
			volume = clamp(volume + text2num(href_list["delta"]), 10, 100)
			if(yt_active)
				yt_update_listeners()
	updateUsrDialog()

/obj/machinery/jukebox/process()
	if(seconds_electrified > MACHINE_NOT_ELECTRIFIED)
		seconds_electrified--
	if(yt_active)
		yt_process()

/// Tempo odtwarzania ustawiane kablami (vaporwave / nightcore)
/obj/machinery/jukebox/proc/get_speed_factor()
	var/speed_factor = 1.0
	if (speed_servo_regulator_cut)
		speed_factor *= 0.73
	if (speed_servo_resistor_cut)
		speed_factor *= 1.25
	speed_factor *= speed_potentiometer
	return speed_factor

/// Jak daleko gracz jest w strefie wyciszania: 0 = przy jukeboxie (pełna głośność), 1 = na krawędzi okręgu.
/// null gdy gracz nic nie słyszy (poza okręgiem, inny z-level, wyłączone instrumenty, głuchy).
/obj/machinery/jukebox/proc/hearing_fraction(mob/M)
	if(!M?.client || !(M.client.prefs.toggles & PREFTOGGLE_SOUND_INSTRUMENTS) || !M.can_hear())
		return null
	var/turf/T = get_turf(M)
	var/turf/our_turf = get_turf(src)
	if(!T || !our_turf || T.z != our_turf.z)
		return null
	var/distance = sqrt((T.x - our_turf.x) ** 2 + (T.y - our_turf.y) ** 2)
	if(distance > music_range)
		return null
	return clamp((distance - music_full_range) / (music_range - music_full_range), 0, 1)

/// Mnożnik głośności 0-1: okrąg o promieniu music_range, cichnie płynnie (krzywa cosinusowa, bez skoków na początku i końcu).
/obj/machinery/jukebox/proc/hearing_gain(mob/M)
	var/fraction = hearing_fraction(M)
	if(isnull(fraction))
		return 0
	return (1 + cos(180 * fraction)) / 2

/// Ilość echa 0-1: brak przy jukeboxie, rośnie z odległością.
/obj/machinery/jukebox/proc/echo_amount(mob/M)
	var/fraction = hearing_fraction(M)
	if(isnull(fraction))
		return 0
	return clamp((fraction - 0.2) / 0.8, 0, 1)
