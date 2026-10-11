/datum/emote
	var/cooldown = 0.8 SECONDS

/// For handling emote cooldown, return true to allow the emote to happen
/datum/emote/proc/check_cooldown(mob/user, intentional)
	if(!intentional)
		return TRUE
	if(user.emotes_used && user.emotes_used[src] + cooldown > world.time)
		return FALSE
	if(!user.emotes_used)
		user.emotes_used = list()
	user.emotes_used[src] = world.time
	return TRUE

/datum/emote
	/// The emote comes from the throat, so it plays at the user's voice pitch (see aquila/code/modules/mob/voice.dm)
	var/voice_emote = FALSE
	var/sound_volume = 40

/// Plays the emote sound. Vocal emotes follow the user's voice, the rest only vary if the emote says so.
/datum/emote/proc/play_emote_sound(mob/user, sound_file)
	var/frequency
	if(voice_emote)
		frequency = user.get_voice_frequency(get_sound_semitones(user))
	if(!frequency && vary)
		frequency = get_rand_frequency()
	playsound(user, sound_file, sound_volume, !!frequency, frequency = frequency)

/// Extra pitch of this emote's sound for this user, in semitones. Lets one recording serve both voices.
/datum/emote/proc/get_sound_semitones(mob/user)
	return 0

/// Picks one of the sounds, but not the one this user heard last from this emote
/datum/emote/proc/pick_emote_sound(mob/user, list/sounds)
	if(length(sounds) < 2)
		return pick(sounds)
	var/last_sound = LAZYACCESS(user.last_emote_sounds, key)
	. = pick(sounds - last_sound)
	LAZYSET(user.last_emote_sounds, key, .)

/mob
	/// Last sound of each emote key, so the same recording does not play twice in a row
	var/list/last_emote_sounds
