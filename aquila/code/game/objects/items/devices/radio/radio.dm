// Radio sounds (tgstation, aquila/sound/items/radio).
// Talking: a short click from the radio that the speaker and people right next to them hear.
// Receiving: a beep sent only to the listener; the old one was a positional sound, so everyone in range heard every listener's beep.

/obj/item/radio/proc/play_radio_talk_sound()
	playsound(src, 'aquila/sound/items/radio/radio_talk.ogg', 25, TRUE, -6, ignore_walls = FALSE)

/// Plays the receive beep to one listener; command and CentCom channels get a more urgent one
/proc/play_radio_receive_sound(mob/listener, atom/movable/virtualspeaker/speaker, frequency)
	if(isobserver(listener) || listener == speaker?.source || !listener.can_hear())
		return
	var/important = frequency == FREQ_COMMAND || frequency == FREQ_CENTCOM
	var/sound/beep = sound(important ? 'aquila/sound/items/radio/radio_important.ogg' : 'aquila/sound/items/radio/radio_receive.ogg')
	beep.volume = important ? 35 : 25
	beep.frequency = rand(95, 105) / 100
	beep.channel = SSsounds.random_available_channel()
	SEND_SOUND(listener, beep)
