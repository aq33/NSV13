// Sounds for emotes that had none

/datum/emote/inhale
	sound = 'sound/effects/inhale.ogg'

/datum/emote/brain/alarm
	sound = 'sound/machines/alarm.ogg'

/datum/emote/brain/alert
	sound = 'sound/effects/alert.ogg'

/datum/emote/brain/notice
	sound = 'sound/misc/notice1.ogg'

/datum/emote/brain/whistle
	sound = 'aquila/sound/emotes/whistle1.ogg'

/datum/emote/silicon/boop
	sound = 'aquila/sound/emotes/boop.ogg'

/datum/emote/slime/bounce
	sound = 'sound/effects/footstep/slime1.ogg'

/datum/emote/slime/jiggle
	sound = 'sound/effects/footstep/slime1.ogg'

/datum/emote/slime/vibrate
	sound = 'sound/effects/footstep/slime1.ogg'

/datum/emote/inhale
	voice_emote = TRUE

/datum/emote/exhale
	voice_emote = TRUE

/datum/emote/exhale/get_sound(mob/living/user)
	if(!isliving(user) || issilicon(user))
		return
	if(user.gender == FEMALE && has_human_emote_voice(user))
		return 'aquila/sound/voice/human/emotes/exhale_f.ogg'
	return 'aquila/sound/voice/human/emotes/exhale_m.ogg'

/datum/emote/living/moo
	key = "moo"
	key_third_person = "moos"
	message = "muczy"
	emote_type = EMOTE_AUDIBLE
	mob_type_allowed_typecache = list(/mob/living/simple_animal/cow)
	sound = 'aquila/sound/creatures/cow.ogg'
