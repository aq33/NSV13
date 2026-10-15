/// Whether this user gets the human emote recordings: humanoids with a throat, not synthetics
/proc/has_human_emote_voice(mob/living/user)
	return ishuman(user) && !isipc(user) && !isandroid(user)

/datum/emote/living/choke
	voice_emote = TRUE

/datum/emote/living/choke/get_sound(mob/living/user)
	if(!has_human_emote_voice(user))
		return
	if(user.gender == FEMALE)
		return 'aquila/sound/voice/human/femalechoke.ogg'
	return 'aquila/sound/voice/human/choke.ogg'

/datum/emote/living/cough
	voice_emote = TRUE

/datum/emote/living/cough/get_sound(mob/living/user)
	if(!has_human_emote_voice(user))
		return
	if(user.gender == FEMALE)
		return pick_emote_sound(user, list('aquila/sound/voice/human/femalecough1.ogg', 'aquila/sound/voice/human/femalecough2.ogg', 'aquila/sound/voice/human/cough.ogg',
			'aquila/sound/voice/human/cough/female_cough1.ogg', 'aquila/sound/voice/human/cough/female_cough2.ogg', 'aquila/sound/voice/human/cough/female_cough3.ogg',
			'aquila/sound/voice/human/cough/female_cough4.ogg', 'aquila/sound/voice/human/cough/female_cough5.ogg', 'aquila/sound/voice/human/cough/female_cough6.ogg',
			'aquila/sound/emotes/female/female_cough_1.ogg', 'aquila/sound/emotes/female/female_cough_2.ogg', 'aquila/sound/emotes/female/female_cough_3.ogg', 'aquila/sound/emotes/female/female_cough_4.ogg', 'aquila/sound/emotes/female/female_cough_5.ogg', 'aquila/sound/emotes/female/female_cough_6.ogg', 'aquila/sound/emotes/female/female_cough_7.ogg'))
	return pick_emote_sound(user, list('aquila/sound/voice/human/malecough1.ogg', 'aquila/sound/voice/human/cough.ogg',
		'aquila/sound/voice/human/cough/male_cough1.ogg', 'aquila/sound/voice/human/cough/male_cough2.ogg', 'aquila/sound/voice/human/cough/male_cough3.ogg',
		'aquila/sound/voice/human/cough/male_cough4.ogg', 'aquila/sound/voice/human/cough/male_cough5.ogg', 'aquila/sound/voice/human/cough/male_cough6.ogg',
			'aquila/sound/emotes/male/male_cough_1.ogg', 'aquila/sound/emotes/male/male_cough_2.ogg', 'aquila/sound/emotes/male/male_cough_3.ogg'))

/datum/emote/living/deathgasp
	voice_emote = TRUE

/datum/emote/living/deathgasp/get_sound(mob/living/user)
	if(ismoth(user))
		return pick_emote_sound(user, list('aquila/sound/voice/moth/moth_death.ogg', 'aquila/sound/emotes/moth/moth_deathgasp.ogg'))
	if(!has_human_emote_voice(user))
		return
	if(user.gender == FEMALE)
		return pickweight(list('aquila/sound/voice/human/femaledeath1.ogg' = 49, 'aquila/sound/voice/human/femaledeath2.ogg' = 49, 'aquila/sound/voice/human/maledeath1.ogg' = 2))
	return pickweight(list('aquila/sound/voice/human/maledeath3.ogg' = 49, 'aquila/sound/voice/human/maledeath5.ogg' = 49, 'aquila/sound/voice/human/maledeath2.ogg' = 1, 'aquila/sound/voice/human/maledeath4.ogg' = 1))

/datum/emote/living/gag
	voice_emote = TRUE

/datum/emote/living/gag/get_sound(mob/living/user)
	if(!has_human_emote_voice(user))
		return
	return pick_emote_sound(user, list('aquila/sound/voice/gag.ogg', 'aquila/sound/voice/human/gag/gag1.ogg', 'aquila/sound/voice/human/gag/gag2.ogg',
		'aquila/sound/voice/human/gag/gag3.ogg', 'aquila/sound/voice/human/gag/gag4.ogg', 'aquila/sound/voice/human/gag/gag5.ogg'))

/datum/emote/living/gasp
	voice_emote = TRUE

/datum/emote/living/gasp/get_sound(mob/living/user)
	if(!has_human_emote_voice(user))
		return
	if(user.gender == FEMALE)
		return pick_emote_sound(user, list('aquila/sound/voice/human/femalegasp1.ogg', 'aquila/sound/voice/human/femalegasp2.ogg',
			'aquila/sound/voice/human/gasp/gasp_female1.ogg', 'aquila/sound/voice/human/gasp/gasp_female2.ogg', 'aquila/sound/voice/human/gasp/gasp_female3.ogg',
			'aquila/sound/voice/human/gasp/gasp_f1.ogg', 'aquila/sound/voice/human/gasp/gasp_f2.ogg', 'aquila/sound/voice/human/gasp/gasp_f3.ogg',
			'aquila/sound/voice/human/gasp/gasp_f4.ogg', 'aquila/sound/voice/human/gasp/gasp_f5.ogg', 'aquila/sound/voice/human/gasp/gasp_f6.ogg'))
	return pick_emote_sound(user, list('aquila/sound/voice/human/gasp.ogg', 'aquila/sound/voice/human/gasp/gasp_male1.ogg', 'aquila/sound/voice/human/gasp/gasp_male2.ogg',
		'aquila/sound/voice/human/gasp/gasp_m1.ogg', 'aquila/sound/voice/human/gasp/gasp_m2.ogg', 'aquila/sound/voice/human/gasp/gasp_m3.ogg',
		'aquila/sound/voice/human/gasp/gasp_m4.ogg', 'aquila/sound/voice/human/gasp/gasp_m5.ogg', 'aquila/sound/voice/human/gasp/gasp_m6.ogg'))

/datum/emote/living/gnome
	key = "gnome"
	key_third_person = "gnomes"
	message = "gnomuje"
	emote_type = EMOTE_VISIBLE

/datum/emote/living/gnome/get_sound(mob/living/user)
	if(ishuman(user))
		return 'aquila/sound/misc/gnome.ogg'

/datum/emote/living/sigh
	voice_emote = TRUE

/datum/emote/living/sigh/get_sound(mob/living/user)
	if(!has_human_emote_voice(user))
		return
	if(user.gender == FEMALE)
		return pick_emote_sound(user, list('aquila/sound/voice/human/femalesigh1.ogg', 'aquila/sound/voice/human/femalesigh2.ogg', 'aquila/sound/voice/human/femalesigh3.ogg', 'aquila/sound/voice/human/femalesigh4.ogg',
			'aquila/sound/voice/human/sigh/female_sigh1.ogg', 'aquila/sound/voice/human/sigh/female_sigh2.ogg', 'aquila/sound/voice/human/sigh/female_sigh3.ogg',
			'aquila/sound/emotes/female/female_sigh.ogg'))
	return pick_emote_sound(user, list('aquila/sound/voice/human/sigh.ogg', 'aquila/sound/voice/human/sigh/male_sigh1.ogg', 'aquila/sound/voice/human/sigh/male_sigh2.ogg', 'aquila/sound/voice/human/sigh/male_sigh3.ogg',
			'aquila/sound/emotes/male/male_sigh.ogg'))

/datum/emote/living/sneeze
	voice_emote = TRUE

/datum/emote/living/sneeze/get_sound(mob/living/user)
	if(!has_human_emote_voice(user))
		return
	if(user.gender == FEMALE)
		return pick_emote_sound(user, list('aquila/sound/voice/human/femalesneeze1.ogg', 'aquila/sound/voice/human/femalesneeze2.ogg', 'aquila/sound/voice/human/sneeze/female_sneeze1.ogg',
			'aquila/sound/emotes/female/female_sneeze1.ogg', 'aquila/sound/emotes/female/female_sneeze2.ogg'))
	return pick_emote_sound(user, list('aquila/sound/voice/human/malesneeze1.ogg', 'aquila/sound/voice/human/sneeze.ogg', 'aquila/sound/voice/human/sneeze/male_sneeze1.ogg',
			'aquila/sound/emotes/male/male_sneeze1.ogg', 'aquila/sound/emotes/male/male_sneeze2.ogg'))

/datum/emote/living/burp
	voice_emote = TRUE

/datum/emote/living/burp/get_sound(mob/living/user)
	if(ishuman(user))
		return 'aquila/sound/voice/burp.ogg'

/datum/emote/living/dance/get_sound(mob/living/user)
	if(ishuman(user))
		return 'aquila/sound/misc/dance.ogg'

/datum/emote/living/groan
	voice_emote = TRUE

/datum/emote/living/groan/get_sound(mob/living/user)
	if(has_human_emote_voice(user))
		return 'aquila/sound/voice/groan.ogg'

/datum/emote/living/kiss/get_sound(mob/living/user)
	if(ishuman(user))
		return 'aquila/sound/voice/kiss.ogg'

/datum/emote/living/sniff
	voice_emote = TRUE

/datum/emote/living/sniff/get_sound(mob/living/user)
	if(!has_human_emote_voice(user))
		return
	if(user.gender == FEMALE)
		return pick_emote_sound(user, list('aquila/sound/voice/sniff.ogg', 'aquila/sound/voice/human/sniff/female_sniff.ogg',
			'aquila/sound/emotes/female/female_sniff.ogg'))
	return pick_emote_sound(user, list('aquila/sound/voice/sniff.ogg', 'aquila/sound/voice/human/sniff/male_sniff.ogg',
			'aquila/sound/emotes/male/male_sniff.ogg'))

/datum/emote/living/snore
	voice_emote = TRUE

/datum/emote/living/snore/get_sound(mob/living/user)
	if(!has_human_emote_voice(user))
		return
	if(prob(2))
		return pick('aquila/sound/voice/human/snore/snore_mimimi1.ogg', 'aquila/sound/voice/human/snore/snore_mimimi2.ogg')
	if(user.gender == FEMALE)
		return pick_emote_sound(user, list('aquila/sound/voice/human/snore/snore_female1.ogg', 'aquila/sound/voice/human/snore/snore_female2.ogg', 'aquila/sound/voice/human/snore/snore_female3.ogg'))
	return pick_emote_sound(user, list('aquila/sound/voice/snore.ogg', 'aquila/sound/voice/human/snore/snore_male1.ogg', 'aquila/sound/voice/human/snore/snore_male2.ogg',
		'aquila/sound/voice/human/snore/snore_male3.ogg', 'aquila/sound/voice/human/snore/snore_male4.ogg', 'aquila/sound/voice/human/snore/snore_male5.ogg'))

/datum/emote/living/yawn
	voice_emote = TRUE

/datum/emote/living/yawn/get_sound(mob/living/user)
	if(has_human_emote_voice(user))
		return 'aquila/sound/voice/yawn.ogg'

/datum/emote/living/laugh
	voice_emote = TRUE

/datum/emote/living/laugh/get_sound(mob/living/user)
	if(ishuman(user) && !user.mind?.miming)
		if(islizard(user))
			return 'aquila/sound/voice/lizard/lizard_laugh1.ogg'
		if(ismoth(user))
			return pick_emote_sound(user, list('aquila/sound/voice/moth/moth_laugh1.ogg', 'aquila/sound/emotes/moth/mothlaugh.ogg'))
	return ..()

/datum/emote/living/giggle
	voice_emote = TRUE

/datum/emote/living/chuckle
	voice_emote = TRUE

/datum/emote/living/chuckle/get_sound(mob/living/user)
	if(!has_human_emote_voice(user))
		return
	if(user.gender == FEMALE)
		return 'aquila/sound/voice/human/emotes/chuckle_f.ogg'
	return pick_emote_sound(user, list('aquila/sound/voice/human/emotes/chuckle_m.ogg', 'aquila/sound/voice/human/emotes/chuckle_m_alt.ogg'))

/datum/emote/living/hum
	voice_emote = TRUE

/datum/emote/living/hum/get_sound(mob/living/user)
	if(!has_human_emote_voice(user))
		return
	if(user.gender == FEMALE)
		return 'aquila/sound/voice/human/emotes/hum_f.ogg'
	return 'aquila/sound/voice/human/emotes/hum_m.ogg'

/datum/emote/living/whimper
	voice_emote = TRUE

/datum/emote/living/whimper/get_sound(mob/living/user)
	if(!has_human_emote_voice(user))
		return
	if(user.gender == FEMALE)
		return 'aquila/sound/voice/human/emotes/whimper_f.ogg'
	return 'aquila/sound/voice/human/emotes/whimper_m.ogg'

/// Pouting comes with a short huff through the nose
/datum/emote/living/pout
	voice_emote = TRUE
	sound_volume = 30

/datum/emote/living/pout/get_sound(mob/living/user)
	if(!has_human_emote_voice(user))
		return
	if(user.gender == FEMALE)
		return 'aquila/sound/voice/human/emotes/exhale_f.ogg'
	return 'aquila/sound/voice/human/emotes/exhale_m.ogg'

/datum/emote/living/whistle
	voice_emote = TRUE

/datum/emote/living/hiss
	voice_emote = TRUE

/datum/emote/living/hiss/get_sound(mob/living/user)
	. = ..()
	if(.)
		return
	if(isethereal(user))
		return 'aquila/sound/voice/ethereal/ethereal_hiss.ogg'
	if(has_human_emote_voice(user))
		return 'aquila/sound/voice/human/human_hiss.ogg'

/datum/emote/living/growl
	voice_emote = TRUE

/// Animals and other non-humans had a silent scream
/datum/emote/living/scream
	voice_emote = TRUE

/datum/emote/living/scream/get_sound(mob/living/user)
	if(ismonkey(user))
		return pick('sound/creatures/monkey/monkey_screech_1.ogg', 'sound/creatures/monkey/monkey_screech_2.ogg', 'sound/creatures/monkey/monkey_screech_3.ogg',
			'sound/creatures/monkey/monkey_screech_4.ogg', 'sound/creatures/monkey/monkey_screech_5.ogg', 'sound/creatures/monkey/monkey_screech_6.ogg',
			'sound/creatures/monkey/monkey_screech_7.ogg')
	if(isalien(user))
		return "hiss"
	if(istype(user, /mob/living/simple_animal/pet/dog))
		return 'aquila/sound/voice/speech/dog1.ogg'
	if(istype(user, /mob/living/simple_animal/pet/cat))
		return 'nsv13/sound/voice/felinid/scream_cat.ogg'
	if(istype(user, /mob/living/simple_animal/cow))
		return 'aquila/sound/creatures/cow.ogg'
	if(issilicon(user))
		return 'sound/machines/buzz-two.ogg'

/datum/emote/living/collapse/get_sound(mob/living/user)
	return pick('sound/effects/bodyfall1.ogg', 'sound/effects/bodyfall2.ogg', 'sound/effects/bodyfall3.ogg', 'sound/effects/bodyfall4.ogg')

/datum/emote/living/surrender/get_sound(mob/living/user)
	return pick('sound/effects/bodyfall1.ogg', 'sound/effects/bodyfall2.ogg', 'sound/effects/bodyfall3.ogg', 'sound/effects/bodyfall4.ogg')

/datum/emote/living/jump/get_sound(mob/living/user)
	return 'sound/weapons/thudswoosh.ogg'

// Animacje emotek: port z BeeStation-Hornet (code/modules/mob/living/emote.dm)
#define SHIVER_LOOP_DURATION (1 SECONDS)
/datum/emote/living/shiver/run_emote(mob/living/user, params, type_override, intentional)
	. = ..()
	if(!.)
		return
	animate(user, pixel_x = 1, time = 0.1 SECONDS, flags = ANIMATION_RELATIVE|ANIMATION_PARALLEL)
	for(var/i in 1 to SHIVER_LOOP_DURATION / (0.2 SECONDS)) //desired total duration divided by the iteration duration to give the necessary iteration count
		animate(pixel_x = -2, time = 0.1 SECONDS, flags = ANIMATION_RELATIVE|ANIMATION_CONTINUE)
		animate(pixel_x = 2, time = 0.1 SECONDS, flags = ANIMATION_RELATIVE|ANIMATION_CONTINUE)
	animate(pixel_x = -1, time = 0.1 SECONDS, flags = ANIMATION_RELATIVE)
#undef SHIVER_LOOP_DURATION

/datum/emote/living/smirk
	key = "smirk"
	key_third_person = "smirks"
	message = "uśmiecha się krzywo"
	emote_type = EMOTE_VISIBLE

/datum/emote/living/sway/run_emote(mob/living/user, params, type_override, intentional)
	. = ..()
	if(!.)
		return
	animate(user, pixel_x = 2, time = 0.5 SECONDS, flags = ANIMATION_RELATIVE|ANIMATION_PARALLEL)
	for(var/i in 1 to 2)
		animate(pixel_x = -6, time = 1.0 SECONDS, flags = ANIMATION_RELATIVE|ANIMATION_CONTINUE)
		animate(pixel_x = 6, time = 1.0 SECONDS, flags = ANIMATION_RELATIVE|ANIMATION_CONTINUE)
	animate(pixel_x = -2, time = 0.5 SECONDS, flags = ANIMATION_RELATIVE)

#define TREMBLE_LOOP_DURATION (4.4 SECONDS)
/datum/emote/living/tremble/run_emote(mob/living/user, params, type_override, intentional)
	. = ..()
	if(!.)
		return
	animate(user, pixel_x = 2, time = 0.2 SECONDS, flags = ANIMATION_RELATIVE|ANIMATION_PARALLEL)
	for(var/i in 1 to TREMBLE_LOOP_DURATION / (0.4 SECONDS)) //desired total duration divided by the iteration duration to give the necessary iteration count
		animate(pixel_x = -4, time = 0.2 SECONDS, flags = ANIMATION_RELATIVE|ANIMATION_CONTINUE)
		animate(pixel_x = 4, time = 0.2 SECONDS, flags = ANIMATION_RELATIVE|ANIMATION_CONTINUE)
	animate(pixel_x = -2, time = 0.2 SECONDS, flags = ANIMATION_RELATIVE)
#undef TREMBLE_LOOP_DURATION

/datum/emote/living/twitch/run_emote(mob/living/user, params, type_override, intentional)
	. = ..()
	if(!.)
		return
	animate(user, pixel_x = 1, time = 0.1 SECONDS, flags = ANIMATION_RELATIVE|ANIMATION_PARALLEL)
	animate(pixel_x = -2, time = 0.1 SECONDS, flags = ANIMATION_RELATIVE)
	animate(time = 0.1 SECONDS)
	animate(pixel_x = 2, time = 0.1 SECONDS, flags = ANIMATION_RELATIVE)
	animate(pixel_x = -1, time = 0.1 SECONDS, flags = ANIMATION_RELATIVE)

/datum/emote/living/twitch_s/run_emote(mob/living/user, params, type_override, intentional)
	. = ..()
	if(!.)
		return
	animate(user, pixel_x = -1, time = 0.1 SECONDS, flags = ANIMATION_RELATIVE|ANIMATION_PARALLEL)
	animate(pixel_x = 1, time = 0.1 SECONDS, flags = ANIMATION_RELATIVE)


/datum/emote/living/giggle/get_sound(mob/living/user)
	if(!ishuman(user))
		return
	if(user.gender == FEMALE)
		return pick('aquila/sound/emotes/female_giggle_1.ogg', 'aquila/sound/emotes/female_giggle_2.ogg')
	return pick('aquila/sound/emotes/male_giggle_1.ogg', 'aquila/sound/emotes/male_giggle_2.ogg', 'aquila/sound/emotes/male_giggle_3.ogg')

/// Snapping the fingers twice and thrice (BeeStation #7804)
/datum/emote/living/snap/two
	key = "snap2"
	key_third_person = "snaps2"
	message = "pstryka palcami dwa razy"
	message_param = "pstryka palcami na %t dwa razy"

/datum/emote/living/snap/two/get_sound(mob/living/user)
	return 'aquila/sound/emotes/snap2.ogg'

/datum/emote/living/snap/three
	key = "snap3"
	key_third_person = "snaps3"
	message = "pstryka palcami trzy razy"
	message_param = "pstryka palcami na %t trzy razy"

/datum/emote/living/snap/three/get_sound(mob/living/user)
	return 'aquila/sound/emotes/snap3.ogg'

// Animacja skoku: jak jump_animation z tgstation, ale względnie, żeby nie nadpisać obrotu leżenia
/datum/emote/living/jump/run_emote(mob/living/user, params, type_override, intentional)
	. = ..()
	if(!.)
		return
	animate(user, pixel_y = 4, time = 0.1 SECONDS, flags = ANIMATION_RELATIVE|ANIMATION_PARALLEL)
	animate(pixel_y = -4, time = 0.1 SECONDS, flags = ANIMATION_RELATIVE)
