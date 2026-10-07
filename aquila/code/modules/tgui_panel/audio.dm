// AQUILA EDIT - zmiana głośności muzyki z przeglądarki w trakcie odtwarzania (jukebox YouTube cichnie z odległością).

/**
 * Ustawia mnożnik głośności (0-1) aktualnie granej muzyki, bez restartu utworu.
 * Suwak głośności muzyki gracza dalej działa - wynikowa głośność to suwak * gain.
 */
/datum/tgui_panel/proc/set_music_gain(gain)
	if(!is_ready())
		return
	window.send_message("audio/setMusicGain", list("gain" = clamp(gain, 0, 1)))
