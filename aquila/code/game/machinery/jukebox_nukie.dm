// AQUILA EDIT - głośnik Syndykatu: mały jukebox nukies na ich promie, żeby mogli puścić muzykę podczas ataku.
// Gra też odkręcony, więc można go ciągnąć za sobą - muzyka idzie razem z nim.

/obj/machinery/jukebox/nukie
	name = "głośnik Syndykatu"
	desc = "Przenośna kolumna Syndykatu z własnym odtwarzaczem. Gra też odkręcona, więc można ją ciągnąć za sobą podczas abordażu."
	icon = 'goon/icons/obj/loudspeakers.dmi'
	icon_state = "nukie_speaker"
	density = FALSE
	req_access = list(ACCESS_SYNDICATE)
	music_range = 14
	needs_anchoring = FALSE
	can_broadcast = FALSE
	anchored = FALSE

/obj/machinery/jukebox/nukie/update_icon()
	var/playing = yt_active && mains && !(machine_stat & (BROKEN|NOPOWER))
	icon_state = playing ? "nukie_speaker_actv" : "nukie_speaker"
