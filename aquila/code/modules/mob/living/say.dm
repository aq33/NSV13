/mob/living/send_speech(message, message_range, obj/source, bubble_type, list/spans, datum/language/message_language, list/message_mods)
	. = ..()

	play_speech_sound(message, message_range, message_mods)
