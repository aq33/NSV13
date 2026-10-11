/// Minimalna zmiana głośności, przy której wysyłamy aktualizację do klienta
#define JUKEBOX_GAIN_STEP 0.01
/// Tyle po wyjściu z zasięgu muzyka gra jeszcze wyciszona, zanim ją zatrzymamy (powrót = bez restartu)
#define JUKEBOX_OUT_GRACE (10 SECONDS)

/// Co 0,5 s wybiera każdemu graczowi jedno źródło muzyki (przeglądarka ma jeden odtwarzacz) i ustawia mu głośność, echo i przytłumienie:
/// najgłośniejsze z miejsc, z których słychać grające jukeboxy (sam jukebox, włączone amp stacki, a przy nadawaniu na cały statek
/// głośniki nagłośnienia na korytarzach). Na starcie rundy rozwiesza głośniki nagłośnienia na korytarzach.
SUBSYSTEM_DEF(jukeboxes)
	name = "Jukeboxes"
	wait = 5
	/// Jukeboxy grające teraz z YouTube / SoundCloud
	var/list/obj/machinery/jukebox/yt_jukeboxes = list()
	/// Co gra każdemu klientowi: client -> /datum/jukebox_listening
	var/list/listening = list()
	/// Wszystkie głośniki nagłośnienia
	var/list/obj/machinery/ceiling_speaker/ceiling_speakers = list()

/// Stan słuchania jednego klienta
/datum/jukebox_listening
	/// Jukebox, którego utwór gra temu klientowi
	var/obj/machinery/jukebox/jukebox
	/// Który utwór (czas startu) - zmiana oznacza nowy utwór do wysłania
	var/track_started = 0
	var/gain = 0
	/// Ostatnio wysłane echo i przytłumienie: "echo|muffle"
	var/fx
	/// Od kiedy klient jest poza zasięgiem (muzyka wyciszona, ale jeszcze gra)
	var/out_since = 0

/datum/controller/subsystem/jukeboxes/Initialize(start_timeofday)
	place_ceiling_speakers()
	return ..()

/// Rozwiesza głośniki nagłośnienia na ścianach korytarzy statku (zasięg JUKEBOX_CEILING_RANGE), a potem mniejsze
/// w kwaterach, przebieralniach i toaletach (JUKEBOX_CEILING_SMALL_RANGE). Głośniki tej samej wielkości mają rozłączne
/// zasięgi (między nimi muzyka cichnie); mały wisi tylko tam, gdzie nie sięga żaden inny.
/datum/controller/subsystem/jukeboxes/proc/place_ceiling_speakers()
	var/static/list/blocking_types = typecacheof(list(
		/obj/machinery/door, /obj/machinery/firealarm, /obj/machinery/airalarm, /obj/machinery/power/apc,
		/obj/machinery/light, /obj/machinery/light_switch, /obj/machinery/button, /obj/machinery/newscaster,
		/obj/machinery/status_display, /obj/machinery/requests_console, /obj/machinery/computer/security/telescreen,
		/obj/item/radio/intercom, /obj/structure/extinguisher_cabinet, /obj/structure/sign, /obj/structure/noticeboard,
		/obj/machinery/ceiling_speaker))
	var/list/placed = ceiling_speakers.Copy()
	var/list/areas = list() // area -> zasięg głośników; najpierw korytarze, żeby to one dostały głośniki, a nie sąsiednie kwatery
	for(var/area/hallway/A in world)
		areas[A] = JUKEBOX_CEILING_RANGE
	for(var/area/crew_quarters/A in world)
		if(istype(A, /area/crew_quarters/dorms) || istype(A, /area/crew_quarters/toilet) || istype(A, /area/crew_quarters/locker))
			areas[A] = JUKEBOX_CEILING_SMALL_RANGE
	for(var/area/A as anything in areas)
		var/range = areas[A]
		for(var/turf/open/floor/T in A)
			if(!is_station_level(T.z))
				continue
			var/wall_dir = ceiling_speaker_wall(T, blocking_types)
			if(!wall_dir)
				continue
			var/too_close = FALSE
			for(var/obj/machinery/ceiling_speaker/other as anything in placed)
				// korytarz z korytarzem: zasięgi rozłączne; mały głośnik tylko tam, gdzie nie sięga żaden inny (skraje mogą lekko zachodzić)
				var/min_distance = (range == other.speaker_range) ? other.speaker_range + range : max(other.speaker_range, range)
				if(other.z == T.z && get_dist_euclidian(other, T) <= min_distance)
					too_close = TRUE
					break
			if(too_close)
				continue
			var/obj/machinery/ceiling_speaker/speaker = new(T, range)
			speaker.mount_on(wall_dir)
			placed += speaker
		CHECK_TICK
	log_game("Jukebox: rozwieszono [length(placed)] głośników nagłośnienia")

/// Kierunek ściany, na której można powiesić głośnik nad tą kratką, albo 0
/datum/controller/subsystem/jukeboxes/proc/ceiling_speaker_wall(turf/open/floor/T, list/blocking_types)
	for(var/atom/movable/AM as anything in T)
		if(AM.density || is_type_in_typecache(AM, blocking_types))
			return 0
	for(var/wall_dir in list(NORTH, WEST, EAST)) // ściana południowa jest widoczna od góry - głośnik wyglądałby jak wbity w nią
		if(isclosedturf(get_step(T, wall_dir)))
			return wall_dir
	return 0

/// Ikony głośników nagłośnienia: grają, gdy na ich statku nadaje grający jukebox
/datum/controller/subsystem/jukeboxes/proc/update_ceiling_speakers()
	var/list/broadcasting_ships = list()
	for(var/obj/machinery/jukebox/J as anything in yt_jukeboxes)
		if(J.shipwide && J.yt_active)
			broadcasting_ships |= J.get_overmap()
	for(var/obj/machinery/ceiling_speaker/speaker as anything in ceiling_speakers)
		var/playing = !!(speaker.get_ship() in broadcasting_ships)
		if(speaker.playing != playing)
			speaker.playing = playing
			speaker.update_icon()

/datum/controller/subsystem/jukeboxes/fire()
	update_listeners()

/datum/controller/subsystem/jukeboxes/proc/update_listeners()
	for(var/client/C as anything in GLOB.clients)
		if(!C?.mob)
			continue
		update_client(C)
	for(var/client/C as anything in listening)
		if(QDELETED(C))
			listening -= C

/// Wybiera klientowi źródło i wysyła mu muzykę albo zmiany głośności
/datum/controller/subsystem/jukeboxes/proc/update_client(client/C)
	var/mob/M = C.mob
	var/obj/machinery/jukebox/best_jukebox
	var/datum/music_emitter/best_emitter
	var/best_gain = 0
	for(var/obj/machinery/jukebox/J as anything in yt_jukeboxes)
		if(!J.yt_stream_url)
			continue
		for(var/datum/music_emitter/source as anything in J.active_emitters())
			var/gain = source.hearing_gain(M) * J.emitter_max_gain(source)
			if(gain > best_gain)
				best_gain = gain
				best_jukebox = J
				best_emitter = source
	var/echo = 0
	var/muffle = 0
	if(best_emitter)
		echo = round(best_emitter.echo_amount(M), 0.05)
		muffle = round(best_emitter.muffle_amount(M), 0.05)
	best_gain = round(best_gain, 0.01)

	var/datum/jukebox_listening/state = listening[C]
	if(best_jukebox && best_gain > 0)
		if(state && state.jukebox == best_jukebox && state.track_started == best_jukebox.yt_track_started)
			// to samo źródło - tylko głośność/efekty (np. przejście od jukeboxa do jego amp stacka nie restartuje utworu)
			state.out_since = 0
			var/fx = "[echo]|[muffle]"
			if(abs(best_gain - state.gain) >= JUKEBOX_GAIN_STEP || fx != state.fx)
				state.gain = best_gain
				state.fx = fx
				C.tgui_panel?.set_music_gain(best_gain, echo, muffle)
			return
		if(best_jukebox.yt_stream_ready())
			var/list/extra = best_jukebox.yt_play_data()
			extra["volume"] = best_gain
			extra["echo"] = echo
			extra["muffle"] = muffle
			C.tgui_panel?.play_music(best_jukebox.yt_stream_url, extra)
			if(!state)
				state = new
				listening[C] = state
			state.jukebox = best_jukebox
			state.track_started = best_jukebox.yt_track_started
			state.gain = best_gain
			state.fx = "[echo]|[muffle]"
			state.out_since = 0
			return
	if(!state)
		return
	// nic nie słychać: przeglądarka płynnie wycisza, a zatrzymujemy dopiero po JUKEBOX_OUT_GRACE
	if(!state.out_since)
		state.out_since = world.time
		state.gain = 0
		C.tgui_panel?.set_music_gain(0, 0, 0)
	else if(world.time - state.out_since > JUKEBOX_OUT_GRACE)
		listening -= C
		C.tgui_panel?.stop_music()

/// Zatrzymuje muzykę wszystkim, którym gra ten jukebox (wyłączony, zniszczony)
/datum/controller/subsystem/jukeboxes/proc/release_jukebox(obj/machinery/jukebox/J)
	for(var/client/C as anything in listening)
		var/datum/jukebox_listening/state = listening[C]
		if(state.jukebox != J)
			continue
		listening -= C
		C?.tgui_panel?.stop_music()

/// Włącza jukebox jako nadający na cały statek; poprzedni nadający na tym samym statku przestaje
/datum/controller/subsystem/jukeboxes/proc/set_shipwide(obj/machinery/jukebox/J, enabled)
	if(enabled && !J.can_broadcast) // radio i głośnik Syndykatu nie nadają na cały statek
		return
	if(enabled)
		var/obj/structure/overmap/ship = J.get_overmap()
		for(var/obj/machinery/jukebox/other in GLOB.machines)
			if(other != J && other.shipwide && other.get_overmap() == ship)
				other.shipwide = FALSE
	J.shipwide = enabled
	update_ceiling_speakers()
	update_listeners()

#undef JUKEBOX_GAIN_STEP
#undef JUKEBOX_OUT_GRACE
