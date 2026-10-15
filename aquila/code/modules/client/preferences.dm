/datum/preferences
	clientfps = 60

/// Body sizes the active character can pick. "Polak" also needs its loadout unlock.
/datum/preferences/proc/get_body_size_choices()
	var/datum/gear/ooc/polak/polak_unlock = /datum/gear/ooc/polak
	if(md5(initial(polak_unlock.display_name)) in purchased_gear)
		return active_character.pref_species.get_body_sizes()
	return active_character.pref_species.get_body_sizes() - "Polak"

// Voice pitch of the character, stored in features["voice_pitch"] (semitones), see aquila/code/modules/mob/voice.dm

/proc/random_voice_pitch()
	return VOICE_PITCH_RANDOM

/// Old characters have no voice yet. They get one from their name, so it stays the same until it is saved.
/proc/sanitize_voice_pitch(value, real_name)
	if(isnum(value))
		return clamp(round(value), VOICE_PITCH_MIN, VOICE_PITCH_MAX)
	if(!real_name)
		return random_voice_pitch()
	var/hash = text2num(copytext(md5(real_name), 1, 3), 16)
	return (hash % (VOICE_PITCH_MAX - VOICE_PITCH_MIN + 1)) + VOICE_PITCH_MIN

/datum/preferences/proc/voice_pitch_pref_html()
	var/pitch = active_character.features["voice_pitch"]
	var/pitch_text = pitch > 0 ? "+[pitch]" : "[pitch]"
	. = "<b>Wysokość głosu:</b> <a href='byond://?_src_=prefs;preference=voice_pitch;task=input'>[pitch_text]</a> "
	. += "<a href='byond://?_src_=prefs;preference=voice_pitch_test;task=input'>Posłuchaj</a> "
	. += "<a href='byond://?_src_=prefs;preference=voice_pitch;task=random'>Losuj</a><BR>"

/datum/preferences/proc/ask_voice_pitch(mob/user)
	var/new_pitch = input(user, "Wysokość głosu postaci w półtonach, od [VOICE_PITCH_MIN] (niski) do [VOICE_PITCH_MAX] (wysoki). Działa na mowę i emotki głosowe.", "Wysokość głosu", active_character.features["voice_pitch"]) as num|null
	if(isnull(new_pitch))
		return
	active_character.features["voice_pitch"] = clamp(round(new_pitch), VOICE_PITCH_MIN, VOICE_PITCH_MAX)
	play_voice_pitch_test(user)

/// Plays a speech sound of the character's species and gender at the chosen pitch, only to the player
/datum/preferences/proc/play_voice_pitch_test(mob/user)
	var/datum/species/species = active_character.pref_species
	var/sound_key = species?.speech_sound || "human"
	if(species?.gendered_speech)
		sound_key += active_character.gender == FEMALE ? FEMALE : MALE
	var/pitch = active_character.features["voice_pitch"]
	var/sound/voice = sound(get_sfx(sound_key))
	voice.volume = 50
	voice.channel = SSsounds.random_available_channel()
	voice.frequency = SEMITONES_TO_FREQUENCY(isnum(pitch) ? pitch : 0)
	SEND_SOUND(user, voice)
