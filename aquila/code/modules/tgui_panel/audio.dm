// AQUILA EDIT - zmiana głośności muzyki z przeglądarki w trakcie odtwarzania (jukebox YouTube cichnie z odległością).

/**
 * Ustawia mnożnik głośności (0-1) aktualnie granej muzyki, bez restartu utworu.
 * Suwak głośności muzyki gracza dalej działa - wynikowa głośność to suwak * gain.
 * echo (0-1) - ilość echa/pogłosu z oddali, muffle (0-1) - przytłumienie jak zza ściany (inny pokład).
 */
/datum/tgui_panel/proc/set_music_gain(gain, echo = 0, muffle = 0)
	if(!is_ready())
		return
	window.send_message("audio/setMusicGain", list("gain" = clamp(gain, 0, 1), "echo" = clamp(echo, 0, 1), "muffle" = clamp(muffle, 0, 1)))
