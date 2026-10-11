// AQUILA EDIT - Odtwarzanie playlist z YouTube i SoundCloud przez jukebox (yt-dlp / youtube-dl z INVOKE_YOUTUBEDL).
// Dźwięk idzie przez przeglądarkę klienta (tgui_panel), tak jak "Play Internet Sound".
// Kto i jak głośno słyszy muzykę, wybiera SSjukeboxes (jukebox, podłączone amp stacki, nadawanie na cały statek).

/// Maksymalna liczba grywalnych utworów na liście
#define JUKEBOX_YT_MAX_TRACKS 200
/// Ile pozycji playlisty czytamy (część odpadnie jako prywatne/usunięte)
#define JUKEBOX_YT_PLAYLIST_SCAN 400
#define JUKEBOX_YT_MAX_TRACK_LENGTH (15 MINUTES)
/// Na tyle przed końcem utworu pobieramy link do następnego, żeby nie było przerwy
#define JUKEBOX_YT_PREFETCH_TIME (45 SECONDS)
/// Po takim czasie uznajemy, że yt-dlp się zawiesił, i odblokowujemy jukebox
#define JUKEBOX_YT_BUSY_TIMEOUT (90 SECONDS)
/// Wspólne argumenty yt-dlp: limit czasu połączenia i ponowień, żeby zapytanie nie wisiało w nieskończoność
/// (tylko opcje znane też staremu youtube-dl, gdyby nadal był używany)
#define JUKEBOX_YT_ARGS "--socket-timeout 10 --retries 2 --no-warnings"
/// Format audio: tylko zwykły plik przez HTTP(S) - przeglądarka nie zagra strumieni HLS (m3u8), które SoundCloud też oferuje
#define JUKEBOX_YT_FORMAT "bestaudio\[protocol^=http]\[ext=m4a]/bestaudio\[protocol^=http]\[ext=mp3]/bestaudio\[protocol^=http]/best\[protocol^=http]\[ext=mp4]\[height<=360]"
/// Linki SoundCloud wygasają po ok. 5 minutach - po tym czasie nowym słuchaczom dajemy świeży link
#define JUKEBOX_YT_STREAM_REFRESH (4 MINUTES)

/obj/machinery/jukebox
	/// URL playlisty - domyślna playlista wczytuje się przy pierwszym "Graj"
	var/yt_playlist_url = "https://www.youtube.com/playlist?list=PL3QLD4mbUqkmQytxtaEQY8ShmFBBzTreg"
	/// Lista utworów: list(list("id", "url", "title", "duration")); url to strona utworu (YouTube/SoundCloud)
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
	/// Po tym czasie link do strumienia może wygasnąć (SoundCloud), null = nie wygasa
	var/yt_stream_expires = null
	/// Trwa pobieranie świeżego linku do bieżącego utworu
	var/yt_refreshing = FALSE
	var/list/yt_extra = null
	/// Tempo bieżącego utworu (kable vaporwave/nightcore), ustalane przy starcie utworu
	var/yt_speed = 1
	/// Ostatnio wpisane wyszukiwanie na playliście: ckey -> tekst
	var/list/yt_search_queries = list()

/// Polecenie yt-dlp: yt-dlp.exe z katalogu gry (leży w repo), a gdy go brak - INVOKE_YOUTUBEDL z konfigu.
/// yt-dlp.exe ma pierwszeństwo - stary youtube-dl z konfigu nie radzi sobie z YouTube i nie zna części opcji.
/proc/aquila_ytdl_command()
	if(world.system_type == MS_WINDOWS && fexists("yt-dlp.exe"))
		return ".\\yt-dlp.exe --no-check-certificate"
	return CONFIG_GET(string/invoke_youtubedl)

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
	dat += "<div class='jb-label'>Playlista YouTube / SoundCloud[yt_tracks.len ? " &middot; [yt_tracks.len] utworów" : ""]</div>"
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
			var/url = input(user, "Podaj link do playlisty lub utworu z YouTube albo SoundCloud", "Playlista", yt_playlist_url) as text|null
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
		var/duration = text2num("[E["duration"]]")
		var/title = "[E["title"]]"
		var/extractor = "[E["ie_key"] || E["extractor_key"]]"
		var/is_youtube = !extractor || findtext(extractor, "Youtube")
		// YouTube: prywatne i usunięte filmy przychodzą jako "[Private video]" / "[Deleted video]" bez długości,
		// transmisje na żywo też nie mają długości - żadnego z nich nie da się zagrać.
		// SoundCloud na stronach profili nie podaje długości, więc tam jej brak nie oznacza niedostępnego utworu.
		if((is_youtube && !duration) || title == "\[Private video]" || title == "\[Deleted video]" || (E["availability"] && !(E["availability"] in list("public", "unlisted"))))
			skipped++
			continue
		if(duration && duration * 10 > JUKEBOX_YT_MAX_TRACK_LENGTH)
			skipped++
			continue
		// webpage_url ma pierwszeństwo: przy pojedynczym utworze (nie playliście) "url" to bezpośredni, szybko wygasający link do pliku
		var/track_url = "[E["webpage_url"] || E["url"]]"
		if(!findtext(track_url, GLOB.is_http_protocol))
			track_url = is_youtube ? "https://www.youtube.com/watch?v=[E["id"]]" : url
		new_tracks += list(list("id" = "[E["id"]]", "url" = track_url, "title" = title || "[E["id"]]", "duration" = duration))
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
	log_game("[key_name(user)] loaded jukebox playlist [url] into [src] at [AREACOORD(src)]")
	message_admins("[ADMIN_LOOKUPFLW(user)] wczytał(a) playlistę do jukeboxa: [url] [ADMIN_JMP(src)]")
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
	var/track_url = T["url"] || "https://www.youtube.com/watch?v=[T["id"]]"
	var/list/output = world.shelleo("[ytdl] [JUKEBOX_YT_ARGS] --geo-bypass --format \"[JUKEBOX_YT_FORMAT]\" --dump-single-json --no-playlist -- \"[shell_url_scrub(track_url)]\"")
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
	yt_set_stream(stream)
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
	SSjukeboxes.update_listeners() // nowy utwór słychać od razu, bez czekania na tick podsystemu
	updateUsrDialog()

/// Ustawia link do strumienia bieżącego utworu i czas, po którym trzeba go odświeżyć
/obj/machinery/jukebox/proc/yt_set_stream(stream)
	yt_stream_url = stream
	// linki YouTube są ważne godzinami; SoundCloud (sndcdn.com) ok. 5 minut
	yt_stream_expires = findtext(stream, "sndcdn.com") ? world.time + JUKEBOX_YT_STREAM_REFRESH : null

/// Pobiera świeży link do bieżącego utworu dla graczy, którzy dopiero wchodzą w zasięg.
/// Gracze, którym już gra, mają utwór zbuforowany i grają dalej.
/obj/machinery/jukebox/proc/yt_refresh_stream()
	if(yt_refreshing || !yt_active || !yt_index)
		return
	yt_refreshing = TRUE
	var/started = yt_track_started
	var/list/result = yt_resolve(yt_index)
	if(QDELETED(src))
		return
	yt_refreshing = FALSE
	if(yt_active && yt_track_started == started) // w międzyczasie nie zmienił się utwór
		if(result)
			yt_set_stream(result["stream"])
		else
			yt_stream_expires = world.time + 30 SECONDS // spróbujemy ponownie za chwilę

/obj/machinery/jukebox/proc/yt_stop()
	var/was_active = yt_active
	yt_active = FALSE
	yt_stream_url = null
	yt_stream_expires = null
	yt_prefetched = null
	SSjukeboxes.yt_jukeboxes -= src
	SSjukeboxes.release_jukebox(src)
	if(was_active)
		STOP_PROCESSING(SSobj, src)
		playsound(src, 'sound/machines/terminal_off.ogg', 50, TRUE)
	update_icon()
	updateUsrDialog()

/// Czy link do strumienia nadaje się dla nowego słuchacza. Wygasły (SoundCloud) jest odświeżany w tle - nowi słuchacze poczekają.
/obj/machinery/jukebox/proc/yt_stream_ready()
	if(!yt_stream_url)
		return FALSE
	if(yt_stream_expires && world.time > yt_stream_expires)
		INVOKE_ASYNC(src, .proc/yt_refresh_stream)
		return FALSE
	return TRUE

/// Dane do odtworzenia bieżącego utworu u nowego słuchacza (od właściwego miejsca)
/obj/machinery/jukebox/proc/yt_play_data()
	var/list/extra = yt_extra.Copy()
	extra["start"] = round((world.time - yt_track_started) / 10 * yt_speed)
	return extra

/// Miejsca, z których słychać ten jukebox: on sam i włączone, zasilone amp stacki
/obj/machinery/jukebox/proc/active_emitters()
	. = list(emitter)
	for(var/obj/machinery/jukebox_speaker/speaker as anything in speakers)
		if(speaker.can_play())
			. += speaker.emitter

/// Maksymalna głośność (0-1) z danego miejsca przy obecnej gałce
/obj/machinery/jukebox/proc/emitter_max_gain(datum/music_emitter/source)
	var/obj/machinery/jukebox_speaker/speaker = source.parent
	var/source_gain = istype(speaker) ? speaker.max_gain : 1
	return JUKEBOX_YT_MAX_GAIN * volume / 100 * source_gain

/// Jak gracz słyszy nadawanie tego jukeboxa na cały statek:
/// 0 - normalnie (pomieszczenie lub korytarz statku); 0-1 - w maincie, im dalej od korytarza, tym bliżej 1;
/// null - nie słyszy (inny statek, kosmos, za daleko w głąb mainta, wyłączone instrumenty, głuchy).
/obj/machinery/jukebox/proc/broadcast_depth(mob/M)
	if(!shipwide || !M?.client || !(M.client.prefs.toggles & PREFTOGGLE_SOUND_INSTRUMENTS) || !M.can_hear())
		return null
	var/obj/structure/overmap/our_ship = get_overmap()
	if(!our_ship || M.get_overmap() != our_ship)
		return null
	var/turf/T = get_turf(M)
	if(!T || istype(T.loc, /area/space))
		return null
	if(SSjukeboxes.is_broadcast_area(T.loc))
		return 0
	if(!istype(T.loc, /area/maintenance))
		return null
	var/distance = SSjukeboxes.broadcast_area_distance(T)
	return distance ? distance / (JUKEBOX_MAINT_HEARING_RANGE + 1) : null

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
#undef JUKEBOX_YT_PREFETCH_TIME
#undef JUKEBOX_YT_BUSY_TIMEOUT
#undef JUKEBOX_YT_ARGS
#undef JUKEBOX_YT_FORMAT
#undef JUKEBOX_YT_STREAM_REFRESH
