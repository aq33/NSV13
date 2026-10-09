
/datum/emote/living/choke/get_sound(mob/living/user)
	if(ishuman(user))
		if(user.gender == FEMALE)
			return 'aquila/sound/voice/human/femalechoke.ogg'
		else
			return 'aquila/sound/voice/human/choke.ogg'

/datum/emote/living/cough/get_sound(mob/living/user)
	if(ishuman(user))
		if(user.gender == FEMALE)
			return pick('aquila/sound/voice/human/femalecough1.ogg', 'aquila/sound/voice/human/femalecough2.ogg', 'aquila/sound/voice/human/cough.ogg')
		else
			return pick('aquila/sound/voice/human/malecough1.ogg', 'aquila/sound/voice/human/cough.ogg')

/datum/emote/living/deathgasp/get_sound(mob/living/user)
	if(ishuman(user))
		if(user.gender == FEMALE)
			return pickweight(list('aquila/sound/voice/human/femaledeath1.ogg'=49, 'aquila/sound/voice/human/femaledeath2.ogg'=49, 'aquila/sound/voice/human/maledeath1.ogg'=2))
		else
			return pickweight(list('aquila/sound/voice/human/maledeath3.ogg'=49, 'aquila/sound/voice/human/maledeath5.ogg'=49, 'aquila/sound/voice/human/maledeath2.ogg'=1, 'aquila/sound/voice/human/maledeath4.ogg'=1))
	else
		return

/datum/emote/living/gag/get_sound(mob/living/user)
	if(ishuman(user))
		return 'aquila/sound/voice/gag.ogg'

/datum/emote/living/gasp/get_sound(mob/living/user)
	if(ishuman(user))
		if(user.gender == FEMALE)
			return pick('aquila/sound/voice/human/femalegasp1.ogg', 'aquila/sound/voice/human/femalegasp2.ogg')
		else
			return 'aquila/sound/voice/human/gasp.ogg'

/datum/emote/living/gnome
	key = "gnome"
	key_third_person = "gnomes"
	message = "gnomuje"
	emote_type = EMOTE_VISIBLE

/datum/emote/living/gnome/get_sound(mob/living/user)
	if(ishuman(user))
		return 'aquila/sound/misc/gnome.ogg'

/datum/emote/living/sigh/get_sound(mob/living/user)
	if(ishuman(user))
		if(user.gender == FEMALE)
			return pick('aquila/sound/voice/human/femalesigh1.ogg', 'aquila/sound/voice/human/femalesigh2.ogg', 'aquila/sound/voice/human/femalesigh3.ogg', 'aquila/sound/voice/human/femalesigh4.ogg')
		else
			return 'aquila/sound/voice/human/sigh.ogg'

/datum/emote/living/sneeze/get_sound(mob/living/user)
	if(ishuman(user))
		if(user.gender == FEMALE)
			return pick('aquila/sound/voice/human/femalesneeze1.ogg', 'aquila/sound/voice/human/femalesneeze2.ogg')
		else
			return pick('aquila/sound/voice/human/malesneeze1.ogg', 'aquila/sound/voice/human/sneeze.ogg')

/datum/emote/living/burp/get_sound(mob/living/user)
	if(ishuman(user))
		return 'aquila/sound/voice/burp.ogg'

/datum/emote/living/dance/get_sound(mob/living/user)
	if(ishuman(user))
		return 'aquila/sound/misc/dance.ogg'

/datum/emote/living/groan/get_sound(mob/living/user)
	if(ishuman(user))
		return 'aquila/sound/voice/groan.ogg'

/datum/emote/living/kiss/get_sound(mob/living/user)
	if(ishuman(user))
		return 'aquila/sound/voice/kiss.ogg'

/datum/emote/living/sniff/get_sound(mob/living/user)
	if(ishuman(user))
		return 'aquila/sound/voice/sniff.ogg'

/datum/emote/living/snore/get_sound(mob/living/user)
	if(ishuman(user))
		return 'aquila/sound/voice/snore.ogg'

/datum/emote/living/yawn/get_sound(mob/living/user)
	if(ishuman(user))
		return 'aquila/sound/voice/yawn.ogg'


/datum/emote/living/jump/run_emote(mob/living/user, params, type_override, intentional)
	. = ..()
	if(!.)
		return FALSE
	animate(user, pixel_y = user.pixel_y + 4, time = 0.1 SECONDS)
	animate(pixel_y = user.pixel_y - 4, time = 0.1 SECONDS)

/datum/emote/living/jump/get_sound(mob/living/user)
	return 'sound/weapons/thudswoosh.ogg'

#define SHIVER_LOOP_DURATION (1 SECONDS)
/datum/emote/living/shiver/run_emote(mob/living/user, params, type_override, intentional)
	. = ..()
	if(!.)
		return FALSE
	animate(user, pixel_x = user.pixel_x + 1, time = 0.1 SECONDS)
	for(var/i in 1 to SHIVER_LOOP_DURATION / (0.2 SECONDS)) //desired total duration divided by the iteration duration to give the necessary iteration count
		animate(pixel_x = user.pixel_x - 1, time = 0.1 SECONDS)
		animate(pixel_x = user.pixel_x + 1, time = 0.1 SECONDS)
	animate(pixel_x = user.pixel_x - 1, time = 0.1 SECONDS)
#undef SHIVER_LOOP_DURATION

/datum/emote/living/smirk
	key = "smirk"
	key_third_person = "smirks"
	message = "uśmiecha się krzywo"
	emote_type = EMOTE_VISIBLE

/datum/emote/living/sway/run_emote(mob/living/user, params, type_override, intentional)
	. = ..()
	if(!.)
		return FALSE
	animate(user, pixel_x = user.pixel_x + 2, time = 0.5 SECONDS)
	for(var/i in 1 to 2)
		animate(pixel_x = user.pixel_x - 4, time = 1.0 SECONDS)
		animate(pixel_x = user.pixel_x + 4, time = 1.0 SECONDS)
	animate(pixel_x = user.pixel_x - 2, time = 0.5 SECONDS)

#define TREMBLE_LOOP_DURATION (4.4 SECONDS)
/datum/emote/living/tremble/run_emote(mob/living/user, params, type_override, intentional)
	. = ..()
	if(!.)
		return FALSE
	animate(user, pixel_x = user.pixel_x + 2, time = 0.2 SECONDS)
	for(var/i in 1 to TREMBLE_LOOP_DURATION / (0.4 SECONDS)) //desired total duration divided by the iteration duration to give the necessary iteration count
		animate(pixel_x = user.pixel_x - 2, time = 0.2 SECONDS)
		animate(pixel_x = user.pixel_x + 2, time = 0.2 SECONDS)
	animate(pixel_x = user.pixel_x - 2, time = 0.2 SECONDS)
#undef TREMBLE_LOOP_DURATION

/datum/emote/living/twitch/run_emote(mob/living/user, params, type_override, intentional)
	. = ..()
	if(!.)
		return FALSE
	animate(user, pixel_x = user.pixel_x - 1, time = 0.1 SECONDS)
	animate(pixel_x = user.pixel_x + 1, time = 0.1 SECONDS)
	animate(time = 0.1 SECONDS)
	animate(pixel_x = user.pixel_x - 1, time = 0.1 SECONDS)
	animate(pixel_x = user.pixel_x + 1, time = 0.1 SECONDS)

/datum/emote/living/twitch_s/run_emote(mob/living/user, params, type_override, intentional)
	. = ..()
	if(!.)
		return FALSE
	animate(user, pixel_x = user.pixel_x - 1, time = 0.1 SECONDS)
	animate(pixel_x = user.pixel_x + 1, time = 0.1 SECONDS)

/datum/emote/living/giggle/get_sound(mob/living/user)
	if(!ishuman(user))
		return
	if(user.gender == FEMALE)
		return pick('aquila/sound/emotes/female_giggle_1.ogg', 'aquila/sound/emotes/female_giggle_2.ogg')
	return pick('aquila/sound/emotes/male_giggle_1.ogg', 'aquila/sound/emotes/male_giggle_2.ogg', 'aquila/sound/emotes/male_giggle_3.ogg')

/datum/emote/living/collapse/get_sound(mob/living/user)
	return pick('sound/effects/bodyfall1.ogg', 'sound/effects/bodyfall2.ogg', 'sound/effects/bodyfall3.ogg', 'sound/effects/bodyfall4.ogg')

/datum/emote/living/surrender/get_sound(mob/living/user)
	return pick('sound/effects/bodyfall1.ogg', 'sound/effects/bodyfall2.ogg', 'sound/effects/bodyfall3.ogg', 'sound/effects/bodyfall4.ogg')
