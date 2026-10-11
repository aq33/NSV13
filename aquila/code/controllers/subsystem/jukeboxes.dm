/// Minimalna zmiana głośności, przy której wysyłamy aktualizację do klienta
#define JUKEBOX_GAIN_STEP 0.01
/// Tyle po wyjściu z zasięgu muzyka gra jeszcze wyciszona, zanim ją zatrzymamy (powrót = bez restartu)
#define JUKEBOX_OUT_GRACE (10 SECONDS)
/// Głośność (0-1, przy gałce 100%) nadawania na cały statek - stała w każdym pomieszczeniu, jak z głośników sufitowych
#define JUKEBOX_SHIPWIDE_GAIN 0.35

/// Co 0,5 s wybiera każdemu graczowi jedno źródło muzyki (przeglądarka ma jeden odtwarzacz) i ustawia mu głośność, echo i przytłumienie.
/// Pierwszeństwo: najgłośniejsze źródło w pobliżu (jukebox, włączony amp stack), a gdy nic nie słychać - jukebox nadający na cały statek.
SUBSYSTEM_DEF(jukeboxes)
	name = "Jukeboxes"
	wait = 5
	flags = SS_NO_INIT
	/// Jukeboxy grające teraz z YouTube / SoundCloud
	var/list/obj/machinery/jukebox/yt_jukeboxes = list()
	/// Co gra każdemu klientowi: client -> /datum/jukebox_listening
	var/list/listening = list()

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
	else
		for(var/obj/machinery/jukebox/J as anything in yt_jukeboxes)
			if(J.yt_stream_url && J.can_broadcast_to(M))
				best_jukebox = J
				best_gain = JUKEBOX_SHIPWIDE_GAIN * J.volume / 100
				break
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
	if(enabled)
		var/obj/structure/overmap/ship = J.get_overmap()
		for(var/obj/machinery/jukebox/other in GLOB.machines)
			if(other != J && other.shipwide && other.get_overmap() == ship)
				other.shipwide = FALSE
	J.shipwide = enabled
	update_listeners()

#undef JUKEBOX_GAIN_STEP
#undef JUKEBOX_OUT_GRACE
#undef JUKEBOX_SHIPWIDE_GAIN
