// AQUILA EDIT - głośnik Syndykatu: mały jukebox nukies na ich promie, żeby mogli puścić muzykę podczas ataku.

/obj/machinery/jukebox/nukie
	name = "głośnik Syndykatu"
	desc = "Przenośna kolumna Syndykatu z własnym odtwarzaczem. Idealna do puszczania muzyki podczas abordażu."
	icon = 'goon/icons/obj/loudspeakers.dmi'
	icon_state = "nukie_speaker"
	density = FALSE
	req_access = list(ACCESS_SYNDICATE)
	music_range = 14

/obj/machinery/jukebox/nukie/update_icon()
	var/playing = yt_active && anchored && mains && !(machine_stat & (BROKEN|NOPOWER))
	icon_state = playing ? "nukie_speaker_actv" : "nukie_speaker"
