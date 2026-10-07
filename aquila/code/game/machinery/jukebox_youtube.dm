// AQUILA EDIT - Odtwarzanie playlist z YouTube przez jukebox (yt-dlp / youtube-dl z INVOKE_YOUTUBEDL).
// Dźwięk idzie przez przeglądarkę klienta (tgui_panel), tak jak "Play Internet Sound".
// Słyszą go gracze w okręgu wokół jukeboxa na tym samym z-levelu, ciszej im dalej (hearing_gain()), a z daleka dochodzi echo (echo_amount()).

#define JUKEBOX_YT_MAX_TRACKS 100
#define JUKEBOX_YT_MAX_TRACK_LENGTH (15 MINUTES)
/// Minimalna zmiana głośności, przy której wysyłamy aktualizację do klienta
#define JUKEBOX_YT_GAIN_STEP 0.01

/obj/machinery/jukebox
	/// URL playlisty - domyślna playlista wczytuje się przy pierwszym "Graj"
	var/yt_playlist_url = "https://www.youtube.com/playlist?list=PL3QLD4mbUqkmQytxtaEQY8ShmFBBzTreg"
	/// Lista utworów: list(list("id", "title", "duration"))
	var/list/yt_tracks = list()
	var/yt_index = 0
	var/yt_active = FALSE
	var/yt_shuffle = FALSE
	/// Trwa zapytanie do yt-dlp
	var/yt_busy = FALSE
	var/yt_track_started = 0
	var/yt_track_end = 0
	var/yt_stream_url = null
	var/list/yt_extra = null
	/// Klienci, którym aktualnie gra muzyka z tego jukeboxa, z ostatnio wysłaną głośnością
	var/list/yt_listeners = list()
	/// Ostatnio wysłana ilość echa dla klienta
	var/list/yt_listener_echo = list()

/obj/machinery/jukebox/proc/yt_available()
	return !!CONFIG_GET(string/invoke_youtubedl)

/obj/machinery/jukebox/proc/yt_ui()
	var/list/dat = list()
	dat += "<hr><b>Playlista YouTube</b><br>"
	if(!yt_available())
		dat += "<i>Niedostępne - serwer nie ma skonfigurowanego yt-dlp.</i><br>"
		return dat.Join()
	dat += "<A href='?src=[REF(src)];action=yt_load'>Wczytaj playlistę</A>"
	if(yt_tracks.len || yt_playlist_url)
		dat += " | <A href='?src=[REF(src)];action=yt_toggle'>[yt_active ? "Stop" : "Graj"]</A>"
		dat += " | <A href='?src=[REF(src)];action=yt_skip'>Następny</A>"
		dat += " | <A href='?src=[REF(src)];action=yt_shuffle'>Losowo: [yt_shuffle ? "TAK" : "NIE"]</A>"
	dat += "<br>"
	if(yt_busy)
		dat += "<i>Łączenie z siecią...</i><br>"
	if(yt_tracks.len)
		dat += "Utworów na liście: [yt_tracks.len] - kliknij tytuł, aby go odtworzyć.<br>"
		dat += "<div style='max-height:220px;overflow-y:auto'>"
		for(var/i in 1 to yt_tracks.len)
			var/list/T = yt_tracks[i]
			var/title = html_encode(T["title"])
			var/duration = T["duration"] ? " <span style='color:#888'>([DisplayTimeText(T["duration"] * 10)])</span>" : ""
			if(yt_active && i == yt_index)
				dat += "[i]. <b>&#9654; [title]</b>[duration]<br>"
			else
				dat += "[i]. <A href='?src=[REF(src)];action=yt_play;index=[i]'>[title]</A>[duration]<br>"
		dat += "</div>"
	return dat.Join()

/obj/machinery/jukebox/proc/yt_topic(action, list/href_list, mob/user)
	switch(action)
		if("yt_load")
			if(yt_busy)
				return
			if(active)
				to_chat(user, "<span class='warning'>Najpierw zatrzymaj odtwarzanie lokalnego utworu.</span>")
				return
			var/url = input(user, "Podaj link do playlisty YouTube", "Playlista", yt_playlist_url) as text|null
			if(!url || QDELETED(src))
				return
			url = trim(url)
			if(!findtext(url, GLOB.is_http_protocol))
				to_chat(user, "<span class='warning'>Dozwolone są tylko linki http(s).</span>")
				return
			INVOKE_ASYNC(src, .proc/yt_load_playlist, url, user)
		if("yt_toggle")
			if(yt_active)
				yt_stop()
			else if(active)
				to_chat(user, "<span class='warning'>Najpierw zatrzymaj odtwarzanie lokalnego utworu.</span>")
			else if(!yt_busy)
				if(!yt_tracks.len && yt_playlist_url)
					INVOKE_ASYNC(src, .proc/yt_load_playlist, yt_playlist_url, user, TRUE)
				else
					INVOKE_ASYNC(src, .proc/yt_next)
		if("yt_play")
			var/index = text2num(href_list["index"])
			if(!index || index < 1 || index > yt_tracks.len || yt_busy)
				return
			if(active)
				to_chat(user, "<span class='warning'>Najpierw zatrzymaj odtwarzanie lokalnego utworu.</span>")
				return
			INVOKE_ASYNC(src, .proc/yt_next, index)
		if("yt_skip")
			if(yt_active && !yt_busy)
				INVOKE_ASYNC(src, .proc/yt_next)
		if("yt_shuffle")
			yt_shuffle = !yt_shuffle
	updateUsrDialog()

/obj/machinery/jukebox/proc/yt_load_playlist(url, mob/user, autoplay = FALSE)
	var/ytdl = CONFIG_GET(string/invoke_youtubedl)
	if(!ytdl)
		return
	yt_busy = TRUE
	updateUsrDialog()
	var/list/output = world.shelleo("[ytdl] --flat-playlist --dump-single-json --playlist-end [JUKEBOX_YT_MAX_TRACKS] -- \"[shell_url_scrub(url)]\"")
	yt_busy = FALSE
	if(QDELETED(src))
		return
	if(output[SHELLEO_ERRORLEVEL])
		say("Błąd pobierania playlisty.")
		log_game("Jukebox YT playlist load failed ([url]): [output[SHELLEO_STDERR]]")
		updateUsrDialog()
		return
	var/list/data
	try
		data = json_decode(output[SHELLEO_STDOUT])
	catch
		say("Błąd odczytu playlisty.")
		updateUsrDialog()
		return
	var/list/entries = data["entries"]
	if(!islist(entries)) // pojedynczy film zamiast playlisty
		entries = list(data)
	var/list/new_tracks = list()
	for(var/list/E in entries)
		if(!E["id"])
			continue
		var/duration = text2num("[E["duration"]]")
		if(duration && duration * 10 > JUKEBOX_YT_MAX_TRACK_LENGTH)
			continue
		new_tracks += list(list("id" = "[E["id"]]", "title" = "[E["title"] || E["id"]]", "duration" = duration))
	if(!new_tracks.len)
		say("Playlista jest pusta lub zawiera tylko zbyt długie utwory.")
		updateUsrDialog()
		return
	if(yt_active)
		yt_stop()
	yt_playlist_url = url
	yt_tracks = new_tracks
	yt_index = 0
	say("Wczytano [yt_tracks.len] utworów.")
	log_game("[key_name(user)] loaded YouTube playlist [url] into [src] at [AREACOORD(src)]")
	message_admins("[ADMIN_LOOKUPFLW(user)] wczytał(a) playlistę YT do jukeboxa: [url] [ADMIN_JMP(src)]")
	updateUsrDialog()
	if(autoplay)
		yt_next()

/// Odtwarza wybrany utwór (index) albo następny (kolejny lub losowy), pobiera link do strumienia i puszcza go słuchaczom.
/obj/machinery/jukebox/proc/yt_next(index)
	if(!yt_tracks.len || yt_busy || QDELETED(src))
		return
	if(machine_stat & (BROKEN|NOPOWER) || !mains || !anchored)
		yt_stop()
		return
	var/ytdl = CONFIG_GET(string/invoke_youtubedl)
	if(!ytdl)
		return
	yt_busy = TRUE
	updateUsrDialog()
	// próbujemy kilku utworów, bo pojedyncze filmy mogą być niedostępne
	for(var/attempt in 1 to min(5, yt_tracks.len))
		if(attempt == 1 && index)
			yt_index = index
		else
			yt_index = yt_shuffle ? rand(1, yt_tracks.len) : (yt_index % yt_tracks.len) + 1
		var/list/T = yt_tracks[yt_index]
		var/list/output = world.shelleo("[ytdl] --geo-bypass --format \"bestaudio\[ext=m4a]/bestaudio\[ext=mp3]/bestaudio\[ext=aac]/best\[ext=mp4]\[height<=360]\" --dump-single-json --no-playlist -- \"https://www.youtube.com/watch?v=[shell_url_scrub(T["id"])]\"")
		if(QDELETED(src))
			return
		if(output[SHELLEO_ERRORLEVEL])
			continue
		var/list/data
		try
			data = json_decode(output[SHELLEO_STDOUT])
		catch
			continue
		var/stream = data["url"]
		if(!stream || !findtext(stream, GLOB.is_http_protocol))
			continue
		var/duration = text2num("[data["duration"]]") || T["duration"]
		if(!duration || duration * 10 > JUKEBOX_YT_MAX_TRACK_LENGTH)
			continue
		yt_busy = FALSE
		if(active) // ktoś włączył lokalny utwór w trakcie pobierania
			updateUsrDialog()
			return
		yt_start_track(stream, data, duration)
		return
	yt_busy = FALSE
	say("Nie udało się odtworzyć żadnego utworu z playlisty.")
	yt_stop()

/obj/machinery/jukebox/proc/yt_start_track(stream, list/data, duration)
	yt_stop_listeners()
	yt_stream_url = stream
	yt_extra = list("title" = data["title"], "link" = data["webpage_url"])
	yt_track_started = world.time
	yt_track_end = world.time + duration * 10 + 2 SECONDS
	if(!yt_active)
		yt_active = TRUE
		playsound(src, 'sound/machines/terminal_on.ogg', 50, TRUE)
		START_PROCESSING(SSobj, src)
	SSjukeboxes.yt_jukeboxes |= src
	update_icon()
	yt_update_listeners()
	updateUsrDialog()

/obj/machinery/jukebox/proc/yt_stop()
	var/was_active = yt_active
	yt_active = FALSE
	yt_stream_url = null
	SSjukeboxes.yt_jukeboxes -= src
	yt_stop_listeners()
	if(was_active)
		if(!active)
			STOP_PROCESSING(SSobj, src)
		playsound(src, 'sound/machines/terminal_off.ogg', 50, TRUE)
	update_icon()
	updateUsrDialog()

/obj/machinery/jukebox/proc/yt_stop_listeners()
	for(var/client/C as anything in yt_listeners)
		C?.tgui_panel?.stop_music()
	yt_listeners.Cut()
	yt_listener_echo.Cut()

/// Głośność 0-1 wysyłana do przeglądarki gracza (mnożona jeszcze przez jego suwak głośności muzyki).
/obj/machinery/jukebox/proc/yt_gain_for(mob/M)
	return round(JUKEBOX_YT_MAX_GAIN * volume / 100 * hearing_gain(M), 0.01)

/obj/machinery/jukebox/proc/yt_echo_for(mob/M)
	return round(echo_amount(M), 0.05)

/// Dołącza graczy wchodzących w zasięg, wycisza tych, którzy wyszli, i ścisza/podgłaśnia wg odległości.
/obj/machinery/jukebox/proc/yt_update_listeners()
	if(!yt_stream_url)
		return
	for(var/client/C as anything in yt_listeners)
		var/gain = (!QDELETED(C) && C.mob) ? yt_gain_for(C.mob) : 0
		if(gain <= 0)
			yt_listeners -= C
			yt_listener_echo -= C
			C?.tgui_panel?.stop_music()
			continue
		var/echo = yt_echo_for(C.mob)
		if(abs(gain - yt_listeners[C]) >= JUKEBOX_YT_GAIN_STEP || echo != yt_listener_echo[C])
			yt_listeners[C] = gain
			yt_listener_echo[C] = echo
			C.tgui_panel?.set_music_gain(gain, echo)
	for(var/mob/M as anything in GLOB.player_list)
		var/client/C = M.client
		if(!C || (C in yt_listeners))
			continue
		var/gain = yt_gain_for(M)
		if(gain <= 0)
			continue
		var/list/extra = yt_extra.Copy()
		extra["start"] = round((world.time - yt_track_started) / 10)
		extra["volume"] = gain
		extra["echo"] = yt_echo_for(M)
		C.tgui_panel?.play_music(yt_stream_url, extra)
		yt_listeners[C] = gain
		yt_listener_echo[C] = extra["echo"]

/obj/machinery/jukebox/proc/yt_process()
	if(machine_stat & (BROKEN|NOPOWER) || !mains || !anchored)
		yt_stop()
		return
	if(yt_busy)
		return
	if(world.time >= yt_track_end)
		INVOKE_ASYNC(src, .proc/yt_next)

#undef JUKEBOX_YT_MAX_TRACKS
#undef JUKEBOX_YT_MAX_TRACK_LENGTH
#undef JUKEBOX_YT_GAIN_STEP
