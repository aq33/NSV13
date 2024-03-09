/datum/emote/living/carbon
	mob_type_allowed_typecache = list(/mob/living/carbon)

/datum/emote/living/carbon/airguitar
	key = "airguitar"
	message = "is strumming the air and headbanging like a safari chimp"
	restraint_check = TRUE

/datum/emote/living/carbon/blink
	key = "blink"
	key_third_person = "blinks"
	message = "mruga"

/datum/emote/living/carbon/blink_r
	key = "blink_r"
	message = "mruga gwałtownie"

/datum/emote/living/carbon/clap
	key = "clap"
	key_third_person = "claps"
	message = "klaszcze"
	muzzle_ignore = TRUE
	restraint_check = TRUE
	emote_type = EMOTE_AUDIBLE
	vary = TRUE

/datum/emote/living/carbon/clap/get_sound(mob/living/user)
	if(ishuman(user))
		if(!user.get_bodypart(BODY_ZONE_L_ARM) || !user.get_bodypart(BODY_ZONE_R_ARM))
			return
		else
			return pick('sound/misc/clap1.ogg',
							'sound/misc/clap2.ogg',
							'sound/misc/clap3.ogg',
							'sound/misc/clap4.ogg')

/datum/emote/living/carbon/gnarl
	key = "gnarl"
	key_third_person = "gnarls"
	message = "warczy i pokazuje zęby.."
	mob_type_allowed_typecache = list(/mob/living/carbon/monkey)

/datum/emote/living/carbon/moan
	key = "moan"
	key_third_person = "moans"
	message = "jęczy"
	message_mime = "zdaje się jęczeć"
	emote_type = EMOTE_AUDIBLE

/datum/emote/living/carbon/roll
	key = "roll"
	key_third_person = "rolls"
	message = "toczy się"
	mob_type_allowed_typecache = list(/mob/living/carbon/monkey, /mob/living/carbon/alien)
	restraint_check = TRUE

/datum/emote/living/carbon/scratch
	key = "scratch"
	key_third_person = "scratches"
	message = "drapie"
	mob_type_allowed_typecache = list(/mob/living/carbon/monkey, /mob/living/carbon/alien)
	restraint_check = TRUE

/datum/emote/living/carbon/screech
	key = "screech"
	key_third_person = "screeches"
	message = "skrzeczy"
	mob_type_allowed_typecache = list(/mob/living/carbon/monkey)
	emote_type = EMOTE_AUDIBLE

/datum/emote/living/carbon/screech/get_sound(mob/living/user)
	return pick('sound/creatures/monkey/monkey_screech_1.ogg',
				'sound/creatures/monkey/monkey_screech_2.ogg',
				'sound/creatures/monkey/monkey_screech_3.ogg',
				'sound/creatures/monkey/monkey_screech_4.ogg',
				'sound/creatures/monkey/monkey_screech_5.ogg',
				'sound/creatures/monkey/monkey_screech_6.ogg',
				'sound/creatures/monkey/monkey_screech_7.ogg')

/datum/emote/living/carbon/screech/roar
	key = "roar"
	key_third_person = "roars"
	message = "ryczy."

/datum/emote/living/carbon/sign
	key = "sign"
	key_third_person = "signs"
	message_param = "podpisuje numer %t"
	mob_type_allowed_typecache = list(/mob/living/carbon/monkey, /mob/living/carbon/alien)
	restraint_check = TRUE

/datum/emote/living/carbon/sign/select_param(mob/user, params)
	. = ..()
	if(!isnum_safe(text2num(params)))
		return message

/datum/emote/living/carbon/sign/signal
	key = "signal"
	key_third_person = "signals"
	message_param = "unosi %t palce"
	mob_type_allowed_typecache = list(/mob/living/carbon/human)
	restraint_check = TRUE

/datum/emote/living/carbon/tail
	key = "tail"
	message = "macha ogonem"
	mob_type_allowed_typecache = list(/mob/living/carbon/monkey, /mob/living/carbon/alien)

/datum/emote/living/carbon/wink
	key = "wink"
	key_third_person = "winks"
	message = "puszcza oczko"
