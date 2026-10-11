// Voices: speech sounds and vocal emotes play at the speaker's own pitch.
// The pitch is a character preference (features["voice_pitch"], in semitones), so it travels with the DNA.

#define VOICE_CLEAR 0
/// Mask or helmet over the mouth: the voice loses its high end
#define VOICE_MUFFLED 1
/// Gagged: only muffled grunts come out
#define VOICE_GAGGED 2

/atom/movable
	/// Voice pitch in semitones for things without DNA, rolled on first use
	var/voice_pitch

/// The base pitch of this voice in semitones, or null if it should not be modulated
/atom/movable/proc/get_voice_semitones()
	return null

/mob/living/get_voice_semitones()
	if(isnull(voice_pitch))
		voice_pitch = VOICE_PITCH_RANDOM
	return voice_pitch

/mob/living/carbon/get_voice_semitones()
	if(!dna)
		return ..()
	var/semitones = dna.features["voice_pitch"]
	if(!isnum(semitones))
		semitones = VOICE_PITCH_RANDOM
		dna.features["voice_pitch"] = semitones
	if(InCritical())
		semitones -= 2
	if(drunkenness > 10)
		semitones += rand(-100, 100) / 100 * min(drunkenness / 30, 2)
	return semitones

/mob/living/silicon/get_voice_semitones()
	return 0

/// Whether each sound of this voice wobbles a little. Machines speak evenly.
/atom/movable/proc/voice_has_jitter()
	return TRUE

/mob/living/silicon/voice_has_jitter()
	return FALSE

/mob/living/carbon/human/voice_has_jitter()
	return !(isipc(src) || isandroid(src))

/// Playback multiplier for one sound of this voice, or null if the voice is not modulated
/atom/movable/proc/get_voice_frequency(extra_semitones = 0)
	var/semitones = get_voice_semitones()
	if(isnull(semitones))
		return null
	semitones += extra_semitones
	if(voice_has_jitter())
		semitones += rand(-VOICE_JITTER, VOICE_JITTER) / 100
	return SEMITONES_TO_FREQUENCY(clamp(semitones, -12, 12))

/// Whether something covers the mouth, see VOICE_CLEAR
/atom/movable/proc/get_voice_muffling()
	return VOICE_CLEAR

/mob/living/carbon/get_voice_muffling()
	if(is_muzzled())
		return VOICE_GAGGED
	if((wear_mask?.flags_cover & MASKCOVERSMOUTH) || (head?.flags_cover & HEADCOVERSMOUTH))
		return VOICE_MUFFLED
	return VOICE_CLEAR

/// The sfx key of the speech sound. Gendered voices of a neuter body fall back to the male set, which has no "neuter" sfx.
/atom/movable/proc/get_speech_sound_key()
	return speech_sound

/mob/living/carbon/get_speech_sound_key()
	. = speech_sound
	if(dna?.species?.gendered_speech && !(gender in list(MALE, FEMALE, PLURAL)))
		return dna.species.speech_sound + MALE

/// Plays the speech sound for a message: one phrase per SPEECH_PHRASE_CHARS characters, with the pitch following the punctuation
/atom/movable/proc/play_speech_sound(message, range, list/message_mods)
	if(!speech_sound || speech_sound_cd > world.time)
		return
	var/text = trim(message)
	var/length = length_char(text)
	if(!length)
		return
	var/last_char = copytext_char(text, -1)
	var/volume = 30
	if(message_mods?[WHISPER_MODE])
		volume = 15
	else if(last_char == "!" || (length > 3 && uppertext(text) == text && lowertext(text) != text))
		volume = 40

	var/phrases = clamp(CEILING(length / SPEECH_PHRASE_CHARS, 1), 1, SPEECH_PHRASES_MAX)
	speech_sound_cd = world.time + max(speech_sound_delay, phrases * SPEECH_PHRASE_DELAY)

	var/muffling = get_voice_muffling()
	var/sound_key = muffling == VOICE_GAGGED ? "muffspeech" : get_speech_sound_key()
	for(var/i in 1 to phrases)
		// A question goes up at the end
		var/extra_semitones = (i == phrases && last_char == "?") ? 2 : 0
		if(i == 1)
			play_voice_phrase(sound_key, volume, range, extra_semitones, muffling)
		else
			addtimer(CALLBACK(src, PROC_REF(play_voice_phrase), sound_key, volume, range, extra_semitones, muffling), (i - 1) * SPEECH_PHRASE_DELAY)

/atom/movable/proc/play_voice_phrase(sound_key, volume, range, extra_semitones, muffling)
	if(QDELETED(src))
		return
	var/frequency = get_voice_frequency(extra_semitones)
	var/sound/voice = sound(get_sfx(sound_key))
	if(muffling == VOICE_MUFFLED)
		volume *= 0.75
		voice.echo = get_muffled_voice_echo()
	playsound(src, voice, volume, TRUE, (-7 + range), frequency = frequency, ignore_walls = FALSE)

/// /sound/var/echo of a voice behind a mask: the direct sound loses its high frequencies
/proc/get_muffled_voice_echo()
	var/static/list/muffled_echo = list(
		0, // Direct
		VOICE_MUFFLE_DIRECT_HF, // DirectHF
		-10000, // Room
		-10000, // RoomHF
		0, // Obstruction
		0, // ObstructionLFRatio
		0, // Occlusion
		0.25, // OcclusionLFRatio
		1.5, // OcclusionRoomRatio
		1.0, // OcclusionDirectRatio
		0, // Exclusion
		1.0, // ExclusionLFRatio
		0, // OutsideVolumeHF
		0, // DopplerFactor
		0, // RolloffFactor
		0, // RoomRolloffFactor
		1.0, // AirAbsorptionFactor
		0, // Flags
	)
	return muffled_echo.Copy()

#undef VOICE_CLEAR
#undef VOICE_MUFFLED
#undef VOICE_GAGGED
