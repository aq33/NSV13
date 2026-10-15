/datum/emote/living/carbon/wink/get_sound(mob/living/user)
	if(ishuman(user))
		return 'aquila/sound/misc/wink.ogg'

/datum/emote/living/carbon/moan
	voice_emote = TRUE

/datum/emote/living/carbon/moan/get_sound(mob/living/user)
	if(!has_human_emote_voice(user))
		return
	if(user.gender == FEMALE)
		return 'aquila/sound/voice/human/emotes/moan_f.ogg'
	return 'aquila/sound/voice/human/emotes/moan_m.ogg'

/// Humans scratch too, not only monkeys and aliens
/datum/emote/living/carbon/scratch
	mob_type_allowed_typecache = list(/mob/living/carbon/monkey, /mob/living/carbon/alien, /mob/living/carbon/human)
	sound_volume = 35

/datum/emote/living/carbon/scratch/get_sound(mob/living/user)
	return pick_emote_sound(user, list('aquila/sound/effects/emotes/scratch1.ogg', 'aquila/sound/effects/emotes/scratch2.ogg'))

/datum/emote/living/carbon/gnarl
	voice_emote = TRUE

/datum/emote/living/carbon/gnarl/get_sound(mob/living/user)
	return pick('aquila/sound/voice/speech/monkey1.ogg', 'aquila/sound/voice/speech/monkey2.ogg')

/datum/emote/living/alien/gnarl/get_sound(mob/living/user)
	return "hiss"
