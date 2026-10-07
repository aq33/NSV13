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
	var/active = FALSE
	var/stop = 0
	var/selection = 1
	var/channel = null
	var/state_base = "jukebox"
	var/seconds_electrified = MACHINE_NOT_ELECTRIFIED
	var/speed_servo_regulator_cut = FALSE //vaporwave
	var/speed_servo_resistor_cut = FALSE //nightcore
	var/mains = TRUE
	var/verify = TRUE
	var/speed_potentiometer = 1.0
	var/selection_blocked = FALSE
	var/stop_blocked = FALSE
	var/list_source = list()
	/// Gałka głośności w procentach
	var/volume = 50
	/// Promień (w kratkach) okręgu, w którym słychać muzykę
	var/music_range = 12
	/// Do tej odległości muzyka gra pełną głośnością, dalej cichnie
	var/music_full_range = 2

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
	list_source = SSjukeboxes.song_lib
	update_icon()

/obj/machinery/jukebox/Destroy()
	if(!isnull(channel))
		SSjukeboxes.remove_jukebox(channel)
		channel = null
	yt_stop()
	QDEL_NULL(wires)
	return ..()

/obj/machinery/jukebox/power_change()
	..()
	update_icon()
	if((machine_stat & NOPOWER) || !mains)
		stop = 0

/obj/machinery/jukebox/obj_break()
	. = ..()
	if(.)
		stop = 0
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
		stop = 0
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
			if(active || yt_active)
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
	if(!SSjukeboxes.songs.len && !yt_available())
		to_chat(user,"<span class='warning'>Błąd: nie znaleziono żadnych utworów. Skonsultuj się z Centralą.</span>")
		playsound(src,'sound/machines/deniedbeep.ogg', 50, 1)
		return
	var/list/dat = list()
	dat += "<div class='statusDisplay' style='text-align:center'>"
	if(active)
		dat += "Teraz gra: <b>[SSjukeboxes.songs[selection].name]</b><br>"
	else if(yt_active && yt_index)
		dat += "Teraz gra: <b>[html_encode(yt_tracks[yt_index]["title"])]</b><br>"
	else
		dat += "<i>Cisza</i><br>"
	if(active || yt_active)
		dat += "<a href='?src=[REF(src)];action=stop'>Zatrzymaj</a> "
	dat += "Głośność: <a href='?src=[REF(src)];action=volume;delta=-10'>-</a> [volume]% <a href='?src=[REF(src)];action=volume;delta=10'>+</a>"
	dat += "</div>"
	if(SSjukeboxes.songs.len)
		dat += "<b>Utwory z pokładowej płytoteki</b> | <a href='?src=[REF(src)];action=random'>Losowy utwór</a><br>"
		dat += "<div style='max-height:180px;overflow-y:auto'>"
		for(var/song_name in list_source)
			var/song_id = list_source[song_name]
			var/datum/track/T = SSjukeboxes.songs[song_id]
			var/label = "<a href='?src=[REF(src)];action=play;track=[song_id]'>[song_name]</a>"
			if(active && song_id == selection)
				label = "<b>&#9654; [song_name]</b>"
			dat += "[label] <span style='color:#888'>([DisplayTimeText(T.length)])</span><br>"
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
			if(yt_active)
				yt_stop()
			if(active)
				if (stop_blocked)
					to_chat(usr, "<span class='warning'>Wciskasz przycisk zatrzymania odtwarzania, ale nic się nie dzieje. Dziwne.</span>")
				else
					stop = 0
		if("volume")
			volume = clamp(volume + text2num(href_list["delta"]), 10, 100)
			if(yt_active)
				yt_update_listeners()
		if("play", "random")
			if(active)
				to_chat(usr, "<span class='warning'>Nie można wybrać innego utworu gdy trwa odtwarzanie.</span>")
				playsound(src, 'sound/machines/deniedbeep.ogg', 50, 1)
				return
			if(selection_blocked)
				to_chat(usr, "<span class='warning'>Wciskasz przycisk wyboru utworu, ale nic się nie dzieje. Smutne!</span>")
				return
			if(href_list["action"] == "random")
				if(!length(list_source))
					return
				selection = list_source[pick(list_source)]
			else
				var/track = text2num(href_list["track"])
				var/found = FALSE
				for(var/song_name in list_source)
					if(list_source[song_name] == track)
						found = TRUE
						break
				if(!found)
					return
				selection = track
			if(yt_active)
				yt_stop()
			attempt_playback()
	updateUsrDialog()

/obj/machinery/jukebox/proc/activate_music()
	if(machine_stat & (BROKEN|NOPOWER) || !mains)
		return FALSE
	var/speed_factor = get_speed_factor()
	channel = SSjukeboxes.add_jukebox(src, selection, speed_factor)
	if(isnull(channel))
		return null
	active = TRUE
	playsound(src,'sound/machines/terminal_on.ogg',50,TRUE)
	update_icon()
	stop = world.time + (SSjukeboxes.songs[selection].length * (1/speed_factor))
	START_PROCESSING(SSobj, src)
	return TRUE

/obj/machinery/jukebox/process()
	if(seconds_electrified > MACHINE_NOT_ELECTRIFIED)
		seconds_electrified--
	if(world.time >= stop && active)
		active = FALSE
		if(!yt_active)
			STOP_PROCESSING(SSobj, src)
		playsound(src,'sound/machines/terminal_off.ogg',50,TRUE)
		updateUsrDialog()
		update_icon()
		SSjukeboxes.remove_jukebox(channel)
		channel = null
		stop = world.time + 25
	if(yt_active)
		yt_process()

/obj/machinery/jukebox/proc/get_speed_factor()
	var/speed_factor = 1.0
	if (speed_servo_regulator_cut)
		speed_factor *= 0.73
	if (speed_servo_resistor_cut)
		speed_factor *= 1.25
	speed_factor *= speed_potentiometer
	return speed_factor

/obj/machinery/jukebox/proc/pick_random(specific_list = list_source)
	var/selected = pick(specific_list)
	if(QDELETED(src) || !selected)
		return
	selection = specific_list[selected]
	updateUsrDialog()

/obj/machinery/jukebox/proc/attempt_playback()
	if (QDELETED(src))
		return
	if(yt_active)
		yt_stop()
	if(stop > world.time)
		to_chat(usr, "<span class='warning'>Urządzenie wciąż parkuje płytę, spróbuj ponownie za [DisplayTimeText(stop-world.time)].</span>")
		playsound(src, 'sound/machines/deniedbeep.ogg', 50, TRUE)
		return
	if(!activate_music())
		to_chat(usr, "<span class='warning'>Błąd sprzętowy, spróbuj ponownie.</span>")
		playsound(src, 'sound/machines/deniedbeep.ogg', 50, TRUE)
		return
	updateUsrDialog()

/// Mnożnik głośności 0-1 dla danego gracza: okrąg o promieniu music_range, im dalej tym ciszej.
/obj/machinery/jukebox/proc/hearing_gain(mob/M)
	if(!M?.client || !(M.client.prefs.toggles & PREFTOGGLE_SOUND_INSTRUMENTS) || !M.can_hear())
		return 0
	var/turf/T = get_turf(M)
	var/turf/our_turf = get_turf(src)
	if(!T || !our_turf || T.z != our_turf.z)
		return 0
	var/distance = sqrt((T.x - our_turf.x) ** 2 + (T.y - our_turf.y) ** 2)
	if(distance > music_range)
		return 0
	if(distance <= music_full_range)
		return 1
	var/falloff = 1 - (distance - music_full_range) / (music_range - music_full_range)
	return falloff * falloff
