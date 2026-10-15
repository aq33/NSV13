/datum/emote/living/alien
	mob_type_allowed_typecache = list(/mob/living/carbon/alien)

/datum/emote/living/alien/gnarl
	key = "gnarl"
	key_third_person = "gnarls"
	message = "warczy i pokazuje zęby..."
	emote_type = EMOTE_VISIBLE

/datum/emote/living/alien/hiss
	key = "hiss"
	key_third_person = "hisses"
	message_alien = "syczy."
	message_larva = "cicho syczy."
	emote_type = EMOTE_AUDIBLE | EMOTE_VISIBLE

/datum/emote/living/alien/hiss/get_sound(mob/living/user)
	if(isalienadult(user))
		return "hiss"

/datum/emote/living/alien/roar
	key = "roar"
	key_third_person = "roars"
	message_alien = "ryczy."
	message_larva = "cicho ryczy."
	vary = TRUE
	emote_type = EMOTE_AUDIBLE | EMOTE_VISIBLE

/datum/emote/living/alien/roar/get_sound(mob/living/user)
	if(isalienadult(user))
		return 'sound/voice/hiss5.ogg'
