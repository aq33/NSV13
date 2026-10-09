// AQUILA EDIT - Odtwarzanie playlist z YouTube przez jukebox (yt-dlp / youtube-dl z INVOKE_YOUTUBEDL).
// Dźwięk idzie przez przeglądarkę klienta (tgui_panel), tak jak "Play Internet Sound".
// Słyszą go gracze w okręgu wokół jukeboxa na tym samym z-levelu, ciszej im dalej (hearing_gain()), a z daleka dochodzi echo (echo_amount()).

/// Maksymalna liczba grywalnych utworów na liście
#define JUKEBOX_YT_MAX_TRACKS 200
/// Ile pozycji playlisty czytamy (część odpadnie jako prywatne/usunięte)
#define JUKEBOX_YT_PLAYLIST_SCAN 400
#define JUKEBOX_YT_MAX_TRACK_LENGTH (15 MINUTES)
/// Minimalna zmiana głośności, przy której wysyłamy aktualizację do klienta
#define JUKEBOX_YT_GAIN_STEP 0.01
/// Tyle po wyjściu z zasięgu strumień gra jeszcze wyciszony, zanim go zatrzymamy
#define JUKEBOX_YT_OUT_GRACE (10 SECONDS)
/// Na tyle przed końcem utworu pobieramy link do następnego, żeby nie było przerwy
#define JUKEBOX_YT_PREFETCH_TIME (45 SECONDS)
/// Po takim czasie uznajemy, że yt-dlp się zawiesił, i odblokowujemy jukebox
#define JUKEBOX_YT_BUSY_TIMEOUT (90 SECONDS)
/// Wspólne argumenty yt-dlp: limit czasu połączenia i ponowień, żeby zapytanie nie wisiało w nieskończoność
#define JUKEBOX_YT_ARGS "--socket-timeout 10 --retries 2 --extractor-retries 1 --no-warnings"

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
	var/yt_busy_since = 0
	/// Trwa pobieranie linku do następnego utworu w tle
	var/yt_prefetching = FALSE
	/// Gotowy następny utwór: list("index", "stream", "data", "duration")
	var/list/yt_prefetched = null
	var/yt_track_started = 0
	var/yt_track_end = 0
	var/yt_stream_url = null
	var/list/yt_extra = null
	/// Tempo bieżącego utworu (kable vaporwave/nightcore), ustalane przy starcie utworu
	var/yt_speed = 1
	/// Ostatnio wpisane wyszukiwanie na playliście: ckey -> tekst
	var/list/yt_search_queries = list()
	/// Klienci, którym aktualnie gra muzyka z tego jukeboxa, z ostatnio wysłaną głośnością
	var/list/yt_listeners = list()
	/// Ostatnio wysłane echo i przytłumienie dla klienta: "echo|muffle"
	var/list/yt_listener_fx = list()
	/// Od kiedy klient jest poza zasięgiem (muzyka wyciszona, ale jeszcze gra)
	var/list/yt_listener_out = list()

/// Polecenie yt-dlp: INVOKE_YOUTUBEDL z konfigu, a gdy go brak - yt-dlp.exe z katalogu gry (leży w repo).
/proc/aquila_ytdl_command()
	. = CONFIG_GET(string/invoke_youtubedl)
	if(!. && world.system_type == MS_WINDOWS && fexists("yt-dlp.exe"))
		return ".\\yt-dlp.exe --no-check-certificate"

/obj/machinery/jukebox/proc/yt_available()
	return !!aquila_ytdl_command()

/// Czas w sekundach jako m:ss
/proc/jukebox_time_text(seconds)
	seconds = max(0, round(seconds))
	var/secs = seconds % 60
	return "[round(seconds / 60)]:[secs < 10 ? "0" : ""][secs]"

/obj/machinery/jukebox/proc/yt_link(action, text, extra = "", css = "jb-btn")
	return "<a class='[css]' href='byond://?src=[REF(src)];action=[action][extra]'>[text]</a>"

/// Całe okno jukeboxa
/obj/machinery/jukebox/proc/yt_ui(mob/user)
	var/list/dat = list()
	dat += {"<style>
		.jb-box {background:rgba(0,0,0,0.25); border:1px solid #40628a; padding:8px 10px; margin-bottom:8px;}
		.jb-label {color:#8ba5c4; font-size:11px; text-transform:uppercase;}
		.jb-title {font-size:15px; font-weight:bold; margin:2px 0 4px 0;}
		.jb-muted {color:#8a8a8a;}
		.jb-row {margin-top:6px;}
		a.jb-btn {display:inline-block; padding:2px 8px; margin:2px 2px 2px 0; border:1px solid #40628a; background:#2a3f5a; color:#fff; text-decoration:none;}
		a.jb-btn:hover {background:#40628a;}
		a.jb-on {background:#2f6b3a; border-color:#3f8a4c;}
		#jb-q {width:70%; padding:2px 4px;}
		.jb-list {max-height:330px; overflow-y:auto; border:1px solid #333;}
		.jb-list table {width:100%; border-collapse:collapse;}
		.jb-list td {padding:3px 5px; border-bottom:1px solid #2a2a2a;}
		.jb-list tr.jb-alt td {background:rgba(255,255,255,0.03);}
		.jb-list tr.jb-cur td {background:#2f4a2f; font-weight:bold;}
		.jb-list td.jb-n {width:30px; text-align:right; color:#8a8a8a;}
		.jb-list td.jb-d {width:45px; text-align:right; color:#8a8a8a;}
		.jb-list a {color:#9fc7ff; text-decoration:none;}
		.jb-list a:hover {text-decoration:underline;}
	</style>"}
	// teraz gra
	dat += "<div class='jb-box'>"
	dat += "<div class='jb-label'>Teraz gra</div>"
	if(yt_busy)
		dat += "<div class='jb-title jb-muted'>Łączenie z siecią...</div>"
	else if(yt_active && yt_index)
		var/list/current = yt_tracks[yt_index]
		dat += "<div class='jb-title'>[html_encode(current["title"])]</div>"
		var/elapsed = (world.time - yt_track_started) / 10 * yt_speed
		dat += "<div class='jb-muted'>Utwór [yt_index] z [yt_tracks.len] &middot; [jukebox_time_text(elapsed)] / [jukebox_time_text(current["duration"])]</div>"
	else
		dat += "<div class='jb-title jb-muted'>Cisza</div>"
	if(yt_available())
		dat += "<div class='jb-row'>"
		if(yt_tracks.len || yt_playlist_url)
			dat += yt_link("yt_toggle", yt_active ? "&#9632; Stop" : "&#9654; Graj")
			dat += yt_link("yt_skip", "&#9658;&#9658; Następny")
			dat += yt_link("yt_shuffle", "Losowo: [yt_shuffle ? "wł." : "wył."]", css = yt_shuffle ? "jb-btn jb-on" : "jb-btn")
		dat += "</div>"
	dat += "<div class='jb-row'>Głośność: "
	dat += yt_link("volume", "&minus;", ";delta=-10")
	dat += " <b>[volume]%</b> "
	dat += yt_link("volume", "+", ";delta=10")
	dat += "</div></div>"
	// playlista
	dat += "<div class='jb-box'>"
	if(!yt_available())
		dat += "<span class='jb-muted'>Niedostępne - brak yt-dlp na serwerze (INVOKE_YOUTUBEDL w konfigu ani yt-dlp.exe w katalogu gry).</span></div>"
		return dat.Join()
	dat += "<div class='jb-label'>Playlista YouTube[yt_tracks.len ? " &middot; [yt_tracks.len] utworów" : ""]</div>"
	dat += "<div class='jb-row'>[yt_link("yt_load", "Wczytaj playlistę")]</div>"
	if(!yt_tracks.len)
		dat += "<div class='jb-row jb-muted'>Brak wczytanej playlisty - &quot;Graj&quot; wczyta domyślną.</div></div>"
		return dat.Join()
	var/query = user?.ckey ? yt_search_queries[user.ckey] : null
	dat += "<div class='jb-row'>Szukaj: <input id='jb-q' type='text' value='[html_encode(query)]' onkeyup='jbFilter(true)' oninput='jbFilter(true)'> "
	dat += "<a class='jb-btn' href='#' onclick='document.getElementById(\"jb-q\").value=\"\";jbFilter(true);return false;'>&times;</a></div>"
	dat += "<div class='jb-row jb-list'><table>"
	for(var/i in 1 to yt_tracks.len)
		var/list/T = yt_tracks[i]
		var/title = html_encode(T["title"])
		var/duration = T["duration"] ? jukebox_time_text(T["duration"]) : ""
		var/row_class = (yt_active && i == yt_index) ? "jb-cur" : (i % 2 ? "" : "jb-alt")
		var/title_cell = (yt_active && i == yt_index) ? "&#9654; [title]" : "<a href='byond://?src=[REF(src)];action=yt_play;index=[i]'>[title]</a>"
		dat += "<tr class='[row_class]'><td class='jb-n'>[i]</td><td class='jb-t'>[title_cell]</td><td class='jb-d'>[duration]</td></tr>"
	dat += "</table><div id='jb-none' class='jb-muted' style='display:none;padding:6px'>Brak wyników.</div></div></div>"
	// filtrowanie po stronie przeglądarki; wpisany tekst zapamiętujemy na serwerze, żeby przetrwał odświeżenie okna
	dat += {"<script>
		var jbTimer = null;
		function jbFilter(save) {
			var q = document.getElementById('jb-q').value.toLowerCase();
			var rows = document.querySelectorAll('.jb-list tr');
			var shown = 0;
			for (var i = 0; i < rows.length; i++) {
				var text = rows\[i].innerText.toLowerCase();
				var match = !q || text.indexOf(q) !== -1;
				rows\[i].style.display = match ? '' : 'none';
				if (match) shown++;
			}
			document.getElementById('jb-none').style.display = shown ? 'none' : 'block';
			if (save) {
				clearTimeout(jbTimer);
				jbTimer = setTimeout(function () {
					window.location = 'byond://?src=[REF(src)];action=yt_search;q=' + encodeURIComponent(document.getElementById('jb-q').value);
				}, 600);
			}
		}
		jbFilter(false);
	</script>"}
	return dat.Join()

/// Ustawia flagę zajętości (z czasem startu dla strażnika zawieszenia)
/obj/machinery/jukebox/proc/yt_set_busy(busy)
	yt_busy = busy
	yt_busy_since = busy ? world.time : 0

/// Odblokowuje jukebox, gdy zapytanie do yt-dlp wisi za długo
/obj/machinery/jukebox/proc/yt_check_stuck()
	if(yt_busy && world.time - yt_busy_since > JUKEBOX_YT_BUSY_TIMEOUT)
		log_game("Jukebox YT request timed out at [AREACOORD(src)]")
		yt_set_busy(FALSE)
	if(yt_prefetching && world.time - yt_busy_since > JUKEBOX_YT_BUSY_TIMEOUT)
		yt_prefetching = FALSE

/obj/machinery/jukebox/proc/yt_topic(action, list/href_list, mob/user)
	yt_check_stuck()
	if(action == "yt_search") // tylko zapamiętanie tekstu, bez odświeżania okna (nie gubimy kursora)
		if(user?.ckey)
			yt_search_queries[user.ckey] = copytext_char(href_list["q"], 1, 101)
		return
	switch(action)
		if("yt_load")
			if(yt_busy)
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
			yt_toggle_playback(user)
		if("yt_play")
			var/index = text2num(href_list["index"])
			if(!index || index < 1 || index > yt_tracks.len || yt_busy)
				return
			if(selection_blocked)
				to_chat(user, "<span class='warning'>Wciskasz przycisk wyboru utworu, ale nic się nie dzieje. Smutne!</span>")
				return
			INVOKE_ASYNC(src, .proc/yt_next, index)
		if("yt_skip")
			if(yt_active && !yt_busy)
				INVOKE_ASYNC(src, .proc/yt_next)
		if("yt_shuffle")
			yt_shuffle = !yt_shuffle
	updateUsrDialog()

/// Graj/Stop - z UI i z kabla WIRE_PLAY
/obj/machinery/jukebox/proc/yt_toggle_playback(mob/user)
	if(yt_active)
		if(stop_blocked)
			if(user)
				to_chat(user, "<span class='warning'>Wciskasz przycisk zatrzymania odtwarzania, ale nic się nie dzieje. Dziwne.</span>")
			return
		yt_stop()
	else if(!yt_busy && yt_available())
		if(!yt_tracks.len && yt_playlist_url)
			INVOKE_ASYNC(src, .proc/yt_load_playlist, yt_playlist_url, user, TRUE)
		else
			INVOKE_ASYNC(src, .proc/yt_next)

/// Losowy utwór z playlisty - z kabla WIRE_LISTING
/obj/machinery/jukebox/proc/yt_play_random()
	if(yt_busy || !yt_tracks.len)
		return
	INVOKE_ASYNC(src, .proc/yt_next, rand(1, yt_tracks.len))

/obj/machinery/jukebox/proc/yt_load_playlist(url, mob/user, autoplay = FALSE)
	var/ytdl = aquila_ytdl_command()
	if(!ytdl)
		return
	yt_set_busy(TRUE)
	updateUsrDialog()
	var/list/output = world.shelleo("[ytdl] [JUKEBOX_YT_ARGS] --flat-playlist --dump-single-json --playlist-end [JUKEBOX_YT_PLAYLIST_SCAN] -- \"[shell_url_scrub(url)]\"")
	yt_set_busy(FALSE)
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
	var/skipped = 0
	for(var/list/E in entries)
		if(!E["id"])
			continue
		// prywatne i usunięte filmy przychodzą jako "[Private video]" / "[Deleted video]" bez długości,
		// transmisje na żywo też nie mają długości - żadnego z nich nie da się zagrać
		var/duration = text2num("[E["duration"]]")
		var/title = "[E["title"]]"
		if(!duration || title == "\[Private video]" || title == "\[Deleted video]" || (E["availability"] && !(E["availability"] in list("public", "unlisted"))))
			skipped++
			continue
		if(duration * 10 > JUKEBOX_YT_MAX_TRACK_LENGTH)
			skipped++
			continue
		new_tracks += list(list("id" = "[E["id"]]", "title" = title || "[E["id"]]", "duration" = duration))
		if(new_tracks.len >= JUKEBOX_YT_MAX_TRACKS)
			break
	if(!new_tracks.len)
		say("Playlista jest pusta albo ma tylko prywatne, usunięte lub zbyt długie utwory.")
		updateUsrDialog()
		return
	if(yt_active)
		yt_stop()
	yt_playlist_url = url
	yt_tracks = new_tracks
	yt_index = 0
	yt_prefetched = null
	say("Wczytano [yt_tracks.len] utworów[skipped ? " (pominięto [skipped] prywatnych, usuniętych lub zbyt długich)" : ""].")
	log_game("[key_name(user)] loaded YouTube playlist [url] into [src] at [AREACOORD(src)]")
	message_admins("[ADMIN_LOOKUPFLW(user)] wczytał(a) playlistę YT do jukeboxa: [url] [ADMIN_JMP(src)]")
	updateUsrDialog()
	if(autoplay)
		yt_next()

/// Indeks następnego utworu (kolejny albo losowy)
/obj/machinery/jukebox/proc/yt_pick_next_index(after)
	if(yt_shuffle && yt_tracks.len > 1)
		var/index = after
		while(index == after)
			index = rand(1, yt_tracks.len)
		return index
	return (after % yt_tracks.len) + 1

/// Pyta yt-dlp o link do strumienia utworu. Zwraca list("stream", "data", "duration") albo null.
/obj/machinery/jukebox/proc/yt_resolve(index)
	var/ytdl = aquila_ytdl_command()
	if(!ytdl || index < 1 || index > yt_tracks.len)
		return null
	var/list/T = yt_tracks[index]
	var/list/output = world.shelleo("[ytdl] [JUKEBOX_YT_ARGS] --geo-bypass --format \"bestaudio\[ext=m4a]/bestaudio\[ext=mp3]/bestaudio\[ext=aac]/best\[ext=mp4]\[height<=360]\" --dump-single-json --no-playlist -- \"https://www.youtube.com/watch?v=[shell_url_scrub(T["id"])]\"")
	if(QDELETED(src) || output[SHELLEO_ERRORLEVEL])
		return null
	var/list/data
	try
		data = json_decode(output[SHELLEO_STDOUT])
	catch
		return null
	var/stream = data["url"]
	if(!stream || !findtext(stream, GLOB.is_http_protocol))
		return null
	var/duration = text2num("[data["duration"]]") || T["duration"]
	if(!duration || duration * 10 > JUKEBOX_YT_MAX_TRACK_LENGTH)
		return null
	return list("stream" = stream, "data" = data, "duration" = duration)

/// W tle pobiera link do następnego utworu, żeby po końcu obecnego zagrać go od razu.
/obj/machinery/jukebox/proc/yt_prefetch()
	if(yt_prefetching || yt_busy || yt_prefetched || !yt_tracks.len)
		return
	yt_prefetching = TRUE
	yt_busy_since = world.time
	var/index = yt_pick_next_index(yt_index)
	var/list/result = yt_resolve(index)
	if(QDELETED(src))
		return
	yt_prefetching = FALSE
	if(result && yt_active)
		result["index"] = index
		yt_prefetched = result

/// Odtwarza wybrany utwór (index) albo następny (kolejny lub losowy), pobiera link do strumienia i puszcza go słuchaczom.
/obj/machinery/jukebox/proc/yt_next(index)
	if(!yt_tracks.len || yt_busy || QDELETED(src))
		return
	if(machine_stat & (BROKEN|NOPOWER) || !mains || !anchored)
		yt_stop()
		return
	// następny utwór już czeka - bez przerwy
	var/list/ready = yt_prefetched
	yt_prefetched = null
	if(ready && (!index || index == ready["index"]))
		yt_index = ready["index"]
		yt_start_track(ready["stream"], ready["data"], ready["duration"])
		return
	if(!aquila_ytdl_command())
		return
	yt_set_busy(TRUE)
	updateUsrDialog()
	// próbujemy kilku utworów, bo pojedyncze filmy mogą być niedostępne
	for(var/attempt in 1 to min(3, yt_tracks.len))
		yt_index = (attempt == 1 && index) ? index : yt_pick_next_index(yt_index)
		var/list/result = yt_resolve(yt_index)
		if(QDELETED(src))
			return
		if(!result)
			continue
		yt_set_busy(FALSE)
		yt_start_track(result["stream"], result["data"], result["duration"])
		return
	yt_set_busy(FALSE)
	say("Nie udało się odtworzyć żadnego utworu z playlisty.")
	yt_stop()

/obj/machinery/jukebox/proc/yt_start_track(stream, list/data, duration)
	yt_stop_listeners()
	yt_stream_url = stream
	yt_speed = get_speed_factor()
	yt_extra = list("title" = data["title"], "link" = data["webpage_url"], "pitch" = yt_speed)
	yt_track_started = world.time
	yt_track_end = world.time + duration * 10 / yt_speed + 1 SECONDS
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
	yt_prefetched = null
	SSjukeboxes.yt_jukeboxes -= src
	yt_stop_listeners()
	if(was_active)
		STOP_PROCESSING(SSobj, src)
		playsound(src, 'sound/machines/terminal_off.ogg', 50, TRUE)
	update_icon()
	updateUsrDialog()

/obj/machinery/jukebox/proc/yt_stop_listeners()
	for(var/client/C as anything in yt_listeners)
		C?.tgui_panel?.stop_music()
	yt_listeners.Cut()
	yt_listener_fx.Cut()
	yt_listener_out.Cut()

/// Głośność 0-1 wysyłana do przeglądarki gracza (mnożona jeszcze przez jego suwak głośności muzyki).
/obj/machinery/jukebox/proc/yt_gain_for(mob/M)
	return round(JUKEBOX_YT_MAX_GAIN * volume / 100 * hearing_gain(M), 0.01)

/obj/machinery/jukebox/proc/yt_echo_for(mob/M)
	return round(echo_amount(M), 0.05)

/obj/machinery/jukebox/proc/yt_muffle_for(mob/M)
	return round(muffle_amount(M), 0.05)

/// Dołącza graczy wchodzących w zasięg, wycisza tych, którzy wyszli, i ścisza/podgłaśnia wg odległości.
/obj/machinery/jukebox/proc/yt_update_listeners()
	if(!yt_stream_url)
		return
	for(var/client/C as anything in yt_listeners)
		if(QDELETED(C) || !C.mob)
			yt_drop_listener(C)
			continue
		var/gain = yt_gain_for(C.mob)
		if(gain <= 0)
			// poza zasięgiem: przeglądarka płynnie wycisza, strumień gra dalej po cichu,
			// a zatrzymujemy go dopiero po JUKEBOX_YT_OUT_GRACE (powrót = bez restartu)
			if(!yt_listener_out[C])
				yt_listener_out[C] = world.time
				yt_listeners[C] = 0
				C.tgui_panel?.set_music_gain(0, 0, 0)
			else if(world.time - yt_listener_out[C] > JUKEBOX_YT_OUT_GRACE)
				yt_drop_listener(C)
			continue
		yt_listener_out -= C
		var/echo = yt_echo_for(C.mob)
		var/muffle = yt_muffle_for(C.mob)
		var/fx = "[echo]|[muffle]"
		if(abs(gain - yt_listeners[C]) >= JUKEBOX_YT_GAIN_STEP || fx != yt_listener_fx[C])
			yt_listeners[C] = gain
			yt_listener_fx[C] = fx
			C.tgui_panel?.set_music_gain(gain, echo, muffle)
	for(var/mob/M as anything in GLOB.player_list)
		var/client/C = M.client
		if(!C || (C in yt_listeners))
			continue
		var/gain = yt_gain_for(M)
		if(gain <= 0)
			continue
		var/list/extra = yt_extra.Copy()
		extra["start"] = round((world.time - yt_track_started) / 10 * yt_speed)
		extra["volume"] = gain
		extra["echo"] = yt_echo_for(M)
		extra["muffle"] = yt_muffle_for(M)
		C.tgui_panel?.play_music(yt_stream_url, extra)
		yt_listeners[C] = gain
		yt_listener_fx[C] = "[extra["echo"]]|[extra["muffle"]]"

/obj/machinery/jukebox/proc/yt_drop_listener(client/C)
	yt_listeners -= C
	yt_listener_fx -= C
	yt_listener_out -= C
	C?.tgui_panel?.stop_music()

/obj/machinery/jukebox/proc/yt_process()
	if(machine_stat & (BROKEN|NOPOWER) || !mains || !anchored)
		yt_stop()
		return
	yt_check_stuck()
	if(yt_busy)
		return
	if(world.time >= yt_track_end)
		INVOKE_ASYNC(src, .proc/yt_next)
	else if(yt_track_end - world.time <= JUKEBOX_YT_PREFETCH_TIME && !yt_prefetched && !yt_prefetching)
		INVOKE_ASYNC(src, .proc/yt_prefetch)

#undef JUKEBOX_YT_MAX_TRACKS
#undef JUKEBOX_YT_PLAYLIST_SCAN
#undef JUKEBOX_YT_MAX_TRACK_LENGTH
#undef JUKEBOX_YT_GAIN_STEP
#undef JUKEBOX_YT_OUT_GRACE
#undef JUKEBOX_YT_PREFETCH_TIME
#undef JUKEBOX_YT_BUSY_TIMEOUT
#undef JUKEBOX_YT_ARGS
