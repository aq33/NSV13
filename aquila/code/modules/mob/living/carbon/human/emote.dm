/datum/emote/living/carbon/human/fart
	key = "fart"
	key_third_person = "farts"
	emote_type = EMOTE_VISIBLE

/datum/emote/living/carbon/human/fart/run_emote(mob/user, params, type_override, intentional)
	if(!..())
		return
	. = TRUE
	var/mob/living/carbon/human/C = user
	var/turf/T = get_turf(user)
	var/obj/item/organ/butt/B = C.getorganslot(ORGAN_SLOT_BUTT)
	if(!B)
		to_chat(user, "<span class='warning'>Nie masz tyłka!</span>")
		return FALSE

	if(HAS_TRAIT(user, TRAIT_MEGAFART) && HAS_TRAIT(user, TRAIT_TOXICFART))
		user.visible_message("<span class = 'warning'>[user] kuca i zaciska zęby!</span>","<span class = 'warning'>Kucasz i zaciskasz zęby. Nie ruszaj się!</span>")
		to_chat(user, "<span class = 'userdanger'>Masz co do tego bardzo złe przeczucia!</span>")
		if(do_mob(user, user, 3.5 SECONDS))
			explosion(T, -1, 0, 0, 0, 0, flame_range = 2)
			C.Knockdown(2 SECONDS)
			C.adjust_fire_stacks(2)
			C.IgniteMob()
			C.apply_damage(15, BRUTE, BODY_ZONE_CHEST)

	else if(HAS_TRAIT(user, TRAIT_MEGAFART))
		user.visible_message("<span class = 'warning'>[user] kuca i zaciska zęby!</span>","<span class = 'warning'>Kucasz i zaciskasz zęby. Nie ruszaj się!</span>")
		if(do_mob(user, user, 2.5 SECONDS))
			for(var/mob/M in urange(3, user))
				if(!M.stat)
					shake_camera(M, 1, 1)
			goonchem_vortex(T, 1, 2)
			C.Knockdown(1 SECONDS)
			C.apply_damage(20, BRUTE, BODY_ZONE_CHEST)
			//why are we still here? just to suffer?

	else if(HAS_TRAIT(user, TRAIT_TOXICFART))
		user.visible_message("<span class = 'warning'>[user] kuca i zaciska zęby!</span>","<span class = 'warning'>Kucasz i zaciskasz zęby. Nie ruszaj się!</span>")
		if(do_mob(user, user, 1.5 SECONDS))
			if(istype(T, /turf/open))
				T.atmos_spawn_air("plasma=3")
			C.Knockdown(0.5 SECONDS)
			C.apply_damage(20, TOX)

	/*	jeśli ktoś ma pomysł jak to ładniej zakodować, to dajcie znać na discordzie (b4cku#1372).
		miałem do wyboru albo przepisać WSZYSTKIE checki na początku i na końcu zostawić ..(), które by wykonało słyszalną akcję i dźwięk
		albo sprawić żeby ..() wykonało checki na początku, a skutki wklepać ręcznie na koniec.*/

	B.fart(C) // AQ EDIT: butt port from Hippie

/datum/emote/living/carbon/human/cry/get_sound(mob/living/user)
	if(!ishuman(user))
		return
	return 'aquila/sound/voice/human/cry.ogg'

/datum/emote/living/carbon/human/tilt
	key = "tilt"
	key_third_person = "tilts"
	message = "przechyla głowę na bok"
	emote_type = EMOTE_VISIBLE

/datum/emote/living/carbon/human/wing/get_sound(mob/living/carbon/human/user)
	if(istype(user.getorganslot(ORGAN_SLOT_WINGS), /obj/item/organ/wings/moth))
		return 'aquila/sound/emotes/moth_flutter.ogg'

// Łzy na twarzy po *cry (port Yogstation#15690)

/// The time it takes for the crying visual to be removed
#define CRY_DURATION 12.8 SECONDS

/datum/emote/living/carbon/human/cry/run_emote(mob/user, params, type_override, intentional)
	. = ..()
	if(. && ishuman(user)) // Give them a visual crying effect if they're human
		var/mob/living/carbon/human/human_user = user
		ADD_TRAIT(human_user, TRAIT_CRYING, "[type]")
		human_user.update_body()

		// Use a timer to remove the effect after the defined duration has passed
		var/list/key_emotes = GLOB.emote_list["cry"]
		for(var/datum/emote/living/carbon/human/cry/human_emote in key_emotes)
			// The existing timer restarts if it is already running
			addtimer(CALLBACK(human_emote, PROC_REF(end_visual), human_user), CRY_DURATION, TIMER_UNIQUE | TIMER_OVERRIDE)

/datum/emote/living/carbon/human/cry/proc/end_visual(mob/living/carbon/human/human_user)
	if(!QDELETED(human_user))
		REMOVE_TRAIT(human_user, TRAIT_CRYING, "[type]")
		human_user.update_body()

#undef CRY_DURATION

// Oryginał przepisuje rysowanie oczu na /obj/item/organ/eyes/proc/generate_body_overlay().
// U nas oczy rysuje dalej core, a łzy dochodzą jednym hookiem w species.dm i update_icons.dm.

#define OFFSET_X 1
#define OFFSET_Y 2

/// Returns the tears overlays for this human's face, or an empty list if they are not crying or have no eyes
/mob/living/carbon/human/proc/get_tears_overlays()
	. = list()
	if(!HAS_TRAIT(src, TRAIT_CRYING) || !getorganslot(ORGAN_SLOT_EYES))
		return
	var/mutable_appearance/tears_overlay = mutable_appearance('aquila/icons/mob/tears.dmi', "tears", -BODY_ADJ_LAYER)
	tears_overlay.color = COLOR_DARK_CYAN
	if(OFFSET_FACE in dna?.species.offset_features)
		var/offset = dna.species.offset_features[OFFSET_FACE]
		tears_overlay.pixel_x += offset[OFFSET_X]
		tears_overlay.pixel_y += offset[OFFSET_Y]
	. += tears_overlay

#undef OFFSET_X
#undef OFFSET_Y

/datum/emote/living/carbon/human/scream
	voice_emote = TRUE

/// Species without their own scream used to be silent
/datum/emote/living/carbon/human/scream/get_sound(mob/living/user)
	if(!ishuman(user) || user.mind?.miming)
		return
	var/mob/living/carbon/human/screamer = user
	if(isplasmaman(screamer))
		return pick_emote_sound(user, list('aquila/sound/voice/plasmaman/plasmeme_scream_1.ogg', 'aquila/sound/voice/plasmaman/plasmeme_scream_2.ogg', 'aquila/sound/voice/plasmaman/plasmeme_scream_3.ogg'))
	if(is_species(screamer, /datum/species/shadow))
		return 'aquila/sound/voice/shadow/shadow_wail.ogg'
	if(isipc(screamer) || isandroid(screamer))
		return 'sound/machines/buzz-two.ogg'
	. = ..()
	if(. && (!ishumanbasic(screamer) || iscatperson(screamer)))
		return
	// Humans and every other humanoid without a species scream
	if(screamer.gender == FEMALE)
		return pick_emote_sound(user, list('sound/voice/human/femalescream_1.ogg', 'sound/voice/human/femalescream_2.ogg', 'sound/voice/human/femalescream_3.ogg',
			'sound/voice/human/femalescream_4.ogg', 'aquila/sound/voice/human/femalescream_5.ogg'))
	if(prob(1))
		return 'sound/voice/human/wilhelm_scream.ogg'
	return pick_emote_sound(user, list('sound/voice/human/malescream_1.ogg', 'sound/voice/human/malescream_2.ogg', 'sound/voice/human/malescream_3.ogg',
		'sound/voice/human/malescream_4.ogg', 'sound/voice/human/malescream_5.ogg', 'aquila/sound/voice/human/malescream_6.ogg'))

/datum/emote/living/carbon/human/cry
	voice_emote = TRUE

/datum/emote/living/carbon/human/cry/get_sound(mob/living/user)
	if(!has_human_emote_voice(user))
		return
	if(user.gender == FEMALE)
		return pick_emote_sound(user, list('aquila/sound/voice/human/cry.ogg', 'aquila/sound/voice/human/cry/female_cry1.ogg', 'aquila/sound/voice/human/cry/female_cry2.ogg'))
	return pick_emote_sound(user, list('aquila/sound/voice/human/cry.ogg', 'aquila/sound/voice/human/cry/male_cry1.ogg', 'aquila/sound/voice/human/cry/male_cry2.ogg', 'aquila/sound/voice/human/cry/male_cry3.ogg'))

/datum/emote/living/carbon/human/mumble
	voice_emote = TRUE

/datum/emote/living/carbon/human/mumble/get_sound(mob/living/user)
	if(has_human_emote_voice(user))
		return 'aquila/sound/voice/human/emotes/mumble_m.ogg'

/// There is only a male recording, so women mumble it a few semitones higher
/datum/emote/living/carbon/human/mumble/get_sound_semitones(mob/user)
	return user.gender == FEMALE ? 4 : 0

/datum/emote/living/carbon/human/grumble
	voice_emote = TRUE
	sound_volume = 40

/datum/emote/living/carbon/human/grumble/get_sound(mob/living/user)
	if(has_human_emote_voice(user))
		return 'aquila/sound/voice/human/emotes/mumble_m.ogg'

/datum/emote/living/carbon/human/grumble/get_sound_semitones(mob/user)
	return user.gender == FEMALE ? 2 : -2

/datum/emote/living/carbon/human/dap/get_sound(mob/living/user)
	return 'aquila/sound/effects/emotes/dap.ogg'

/datum/emote/living/carbon/human/salute
	sound_volume = 40

/datum/emote/living/carbon/human/salute/get_sound(mob/living/user)
	return 'aquila/sound/voice/human/salute.ogg'

/datum/emote/living/carbon/human/crack
	key = "crack"
	key_third_person = "cracks"
	message = "strzela kostkami palców"
	restraint_check = TRUE
	emote_type = EMOTE_AUDIBLE | EMOTE_VISIBLE

/datum/emote/living/carbon/human/crack/get_sound(mob/living/user)
	return 'aquila/sound/voice/human/knuckles.ogg'

/datum/emote/living/carbon/human/hiccup
	key = "hiccup"
	key_third_person = "hiccups"
	message = "czka"
	emote_type = EMOTE_AUDIBLE
	voice_emote = TRUE

/datum/emote/living/carbon/human/hiccup/get_sound(mob/living/user)
	if(has_human_emote_voice(user))
		return 'aquila/sound/voice/human/hiccup.ogg'

/datum/emote/living/carbon/human/slowclap
	key = "slowclap"
	key_third_person = "slowclaps"
	message = "powoli klaszcze"
	restraint_check = TRUE
	emote_type = EMOTE_AUDIBLE | EMOTE_VISIBLE

/datum/emote/living/carbon/human/slowclap/get_sound(mob/living/user)
	if(user.get_bodypart(BODY_ZONE_L_ARM) && user.get_bodypart(BODY_ZONE_R_ARM))
		return 'sound/machines/slowclap.ogg'

/datum/emote/living/carbon/human/squeak
	key = "squeak"
	key_third_person = "squeaks"
	message = "piszczy"
	emote_type = EMOTE_AUDIBLE
	voice_emote = TRUE

/datum/emote/living/carbon/human/squeak/can_run_emote(mob/user, status_check = TRUE, intentional)
	return ismoth(user) && ..()

/datum/emote/living/carbon/human/squeak/get_sound(mob/living/user)
	return pick_emote_sound(user, list('aquila/sound/voice/moth/moth_squeak.ogg', 'aquila/sound/emotes/moth/mothsqueak.ogg'))

/datum/emote/living/carbon/human/chitter
	key = "chitter"
	key_third_person = "chitters"
	message = "terkocze"
	emote_type = EMOTE_AUDIBLE
	voice_emote = TRUE

/datum/emote/living/carbon/human/chitter/can_run_emote(mob/user, status_check = TRUE, intentional)
	return ismoth(user) && ..()

/datum/emote/living/carbon/human/chitter/get_sound(mob/living/user)
	return pick_emote_sound(user, list('aquila/sound/voice/moth/moth_chitter.ogg', 'aquila/sound/emotes/moth/mothchitter.ogg'))

/datum/emote/living/carbon/human/sweatdrop
	key = "sweatdrop"
	key_third_person = "sweatdrops"
	message = "poci się"
	emote_type = EMOTE_VISIBLE
	sound_volume = 25
	vary = TRUE
	sound = 'aquila/sound/emotes/sweatdrop.ogg'

/// Same as *sweatdrop, people use either
/datum/emote/living/carbon/human/sweatdrop/sweat
	key = "sweat"
	key_third_person = "sweats"

/datum/emote/living/carbon/human/annoyed
	key = "annoyed"
	message = "okazuje irytację"
	emote_type = EMOTE_VISIBLE
	sound_volume = 25
	vary = TRUE
	sound = 'aquila/sound/emotes/annoyed.ogg'

/datum/emote/living/carbon/human/robot_tongue/dwoop
	key = "dwoop"
	key_third_person = "dwoops"
	message = "wydaje dźwięk \"dwoop\""
	emote_type = EMOTE_AUDIBLE
	sound = 'aquila/sound/emotes/dwoop.ogg'
