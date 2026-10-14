// AQUILA - darkspawn: gatunek, język, Mindlink, dźwięk Sakramentu (port z Yogstation)

#define DARKSPAWN_REFLECT_COOLDOWN 15 SECONDS

/datum/species/darkspawn
	name = "Darkspawn"
	id = SPECIES_DARKSPAWN
	sexes = FALSE
	nojumpsuit = TRUE
	changesource_flags = MIRROR_BADMIN
	siemens_coeff = 0
	burnmod = 1.2
	heatmod = 1.5
	no_equip = list(ITEM_SLOT_MASK, ITEM_SLOT_OCLOTHING, ITEM_SLOT_GLOVES, ITEM_SLOT_FEET, ITEM_SLOT_ICLOTHING, ITEM_SLOT_SUITSTORE, ITEM_SLOT_HEAD, ITEM_SLOT_EYES)
	species_traits = list(NOBLOOD, NO_UNDERWEAR, NO_DNA_COPY, NOTRANSSTING, NOEYESPRITES, NOHUSK)
	inherent_traits = list(TRAIT_NOGUNS, TRAIT_RESISTCOLD, TRAIT_RESISTHIGHPRESSURE, TRAIT_RESISTLOWPRESSURE, TRAIT_NOBREATH, TRAIT_RADIMMUNE, TRAIT_VIRUSIMMUNE, TRAIT_PIERCEIMMUNE, TRAIT_NODISMEMBER, TRAIT_NOHUNGER, TRAIT_NOCRITDAMAGE)
	mutanteyes = /obj/item/organ/eyes/night_vision/alien
	species_language_holder = /datum/language_holder/darkspawn
	species_chest = /obj/item/bodypart/chest/darkspawn
	species_head = /obj/item/bodypart/head/darkspawn
	species_l_arm = /obj/item/bodypart/l_arm/darkspawn
	species_r_arm = /obj/item/bodypart/r_arm/darkspawn
	species_l_leg = /obj/item/bodypart/l_leg/darkspawn
	species_r_leg = /obj/item/bodypart/r_leg/darkspawn
	/// Ile pocisków cienie mogą pochłonąć, zanim się odnowią
	var/shadow_charges = 3
	/// Ile leczy na tick w ciemności (nadpisywane z antagonisty)
	var/dark_healing = 8
	/// Ile obrażeń na tick w świetle (nadpisywane z antagonisty)
	var/light_burning = 7

/datum/species/darkspawn/check_roundstart_eligible()
	return FALSE

/datum/species/darkspawn/on_species_gain(mob/living/carbon/C, datum/species/old_species, pref_load)
	. = ..()
	C.fully_replace_character_name(null, pick(GLOB.nightmare_names))

/// Cienie łykają do trzech pocisków, każdy ładunek wraca po 15 sekundach
/datum/species/darkspawn/bullet_act(obj/item/projectile/P, mob/living/carbon/human/H)
	var/turf/T = get_turf(H)
	if(istype(T) && T.get_lumcount() < DARKSPAWN_DIM_LIGHT && shadow_charges > 0)
		shadow_charges--
		addtimer(CALLBACK(src, PROC_REF(regen_shadow)), DARKSPAWN_REFLECT_COOLDOWN)
		H.visible_message("<span class='danger'>Cienie wokół [H] falują, pochłaniając [P]!</span>")
		playsound(H, "bullet_miss", 75, TRUE)
		return BULLET_ACT_BLOCK
	return ..()

/datum/species/darkspawn/proc/regen_shadow()
	shadow_charges = min(shadow_charges + 1, initial(shadow_charges))

/// Wartości z antagonisty (ulepszenia z Psi Web)
/datum/species/darkspawn/proc/sync_with_antag(mob/living/carbon/human/H)
	var/datum/antagonist/darkspawn/antag = isdarkspawn(H)
	if(!antag)
		return
	dark_healing = antag.dark_healing
	light_burning = antag.light_burning
	if(H.physiology)
		H.physiology.brute_mod = antag.brute_mod
		H.physiology.burn_mod = antag.burn_mod
		H.physiology.stamina_mod = antag.stam_mod

/datum/species/darkspawn/spec_life(mob/living/carbon/human/H)
	. = ..()
	sync_with_antag(H)
	var/turf/T = H.loc
	if(!istype(T))
		return
	var/datum/antagonist/darkspawn/dude = isdarkspawn(H)
	var/light_amount = T.get_lumcount()
	if(light_amount < DARKSPAWN_DIM_LIGHT) // leczenie i otrząsanie się w ciemności
		H.adjustBruteLoss(-dark_healing)
		H.adjustFireLoss(-dark_healing)
		H.adjustCloneLoss(-dark_healing)
		H.adjustToxLoss(-dark_healing)
		H.adjustOxyLoss(-dark_healing)
		H.adjustStaminaLoss(-dark_healing * 20)
		H.adjustOrganLoss(ORGAN_SLOT_BRAIN, -dark_healing)
		H.AdjustAllImmobility(-dark_healing * 40)
		H.SetSleeping(0)
		return
	if(dude && HAS_TRAIT(dude, TRAIT_DARKSPAWN_CREEP))
		return
	if(light_amount < DARKSPAWN_BRIGHT_LIGHT) // przyćmione światło lekko przypieka
		if(dude && HAS_TRAIT(dude, TRAIT_DARKSPAWN_LIGHTRES))
			return
		to_chat(H, "<span class='userdanger'>Światło cię przypieka!</span>")
		H.playsound_local(H, 'sound/weapons/sear.ogg', max(30, 40 * light_amount), TRUE)
		H.adjustCloneLoss(light_burning * 0.2)
	else // w jasnym świetle szybka śmierć
		to_chat(H, "<span class='userdanger'>Światło cię pali!</span>")
		H.playsound_local(H, 'sound/weapons/sear.ogg', max(40, 65 * light_amount), TRUE)
		H.adjustCloneLoss(light_burning)

/datum/species/darkspawn/spec_death(gibbed, mob/living/carbon/human/H)
	. = ..()
	playsound(H, 'aquila/sound/darkspawn/darkspawn_death.ogg', 50, FALSE)

#undef DARKSPAWN_REFLECT_COOLDOWN

/obj/item/bodypart/head/darkspawn
	static_icon = 'aquila/icons/mob/darkspawn/darkspawn_parts.dmi'
	limb_id = SPECIES_DARKSPAWN
	is_dimorphic = FALSE
	should_draw_greyscale = FALSE

/obj/item/bodypart/chest/darkspawn
	static_icon = 'aquila/icons/mob/darkspawn/darkspawn_parts.dmi'
	limb_id = SPECIES_DARKSPAWN
	is_dimorphic = FALSE
	should_draw_greyscale = FALSE

/obj/item/bodypart/l_arm/darkspawn
	static_icon = 'aquila/icons/mob/darkspawn/darkspawn_parts.dmi'
	limb_id = SPECIES_DARKSPAWN
	should_draw_greyscale = FALSE

/obj/item/bodypart/r_arm/darkspawn
	static_icon = 'aquila/icons/mob/darkspawn/darkspawn_parts.dmi'
	limb_id = SPECIES_DARKSPAWN
	should_draw_greyscale = FALSE

/obj/item/bodypart/l_leg/darkspawn
	static_icon = 'aquila/icons/mob/darkspawn/darkspawn_parts.dmi'
	limb_id = SPECIES_DARKSPAWN
	should_draw_greyscale = FALSE

/obj/item/bodypart/r_leg/darkspawn
	static_icon = 'aquila/icons/mob/darkspawn/darkspawn_parts.dmi'
	limb_id = SPECIES_DARKSPAWN
	should_draw_greyscale = FALSE

// Język

// Wiele zdolności darkspawna wypowiada zdania po angielsku przepuszczone przez rot22; odczyta się je rot4.
/datum/language/darkspawn
	name = "Darkspeak"
	desc = "Język darkspawnów. Mimo ostrych sylab spływa z języka jak jedwab."
	speech_verb = "klika"
	ask_verb = "ćwierka"
	exclaim_verb = "skrzeczy"
	syllables = list("ko", "ii", "ma", "an", "sah", "lo", "na")
	flags = NO_STUTTER
	key = "a"
	default_priority = 10
	space_chance = 40
	icon = 'aquila/icons/mob/darkspawn/darkspeak.dmi'
	icon_state = "darkspeak"

/datum/language_holder/darkspawn
	understood_languages = list(/datum/language/common = list(LANGUAGE_ATOM),
								/datum/language/darkspawn = list(LANGUAGE_ATOM))
	spoken_languages = list(/datum/language/common = list(LANGUAGE_ATOM),
							/datum/language/darkspawn = list(LANGUAGE_ATOM))

// Mindlink

/datum/saymode/darkspawn
	key = MODE_KEY_DARKSPAWN
	mode = MODE_DARKSPAWN

/datum/saymode/darkspawn/handle_message(mob/living/user, message, datum/language/language)
	if(!user.mind || !is_team_darkspawn(user))
		return TRUE
	user.log_talk(message, LOG_SAY, tag = "darkspawn")
	var/msg = "<span class='velvet'><b>\[Mindlink\] [user.real_name]:</b> \"[message]\"</span>"
	for(var/mob/M as anything in GLOB.player_list)
		if(M in GLOB.dead_mob_list)
			to_chat(M, "[FOLLOW_LINK(M, user)] [msg]")
		else if(is_team_darkspawn(M))
			to_chat(M, msg)
	return FALSE

// Dźwięk Sakramentu słyszany przez wszystkich graczy

/datum/looping_sound/sacrament
	mid_sounds = list('aquila/sound/darkspawn/sacrament_heartbeat_01.ogg' = 1, 'aquila/sound/darkspawn/sacrament_heartbeat_02.ogg' = 1, 'aquila/sound/darkspawn/sacrament_heartbeat_03.ogg' = 1)
	mid_length = 10
	volume = 30
	var/stage = 1

/datum/looping_sound/sacrament/get_sound(starttime, _mid_sounds)
	mid_length = 12 - (stage * 2)
	volume = 30 + (stage * 10)
	return ..()

/datum/looping_sound/sacrament/play(soundfile)
	var/sound/S = sound(soundfile)
	S.volume = volume
	for(var/mob/M as anything in GLOB.player_list)
		SEND_SOUND(M, S)
