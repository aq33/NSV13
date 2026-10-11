/atom/movable
	var/speech_sound = ""
	var/speech_sound_cd
	var/speech_sound_delay = 3 SECONDS

/atom/movable/send_speech(message, range, obj/source, bubble_type, list/spans, datum/language/message_language, list/message_mods)
	. = ..()

	play_speech_sound(message, range, message_mods)
