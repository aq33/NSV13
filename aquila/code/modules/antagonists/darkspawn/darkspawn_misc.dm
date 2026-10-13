// AQUILA - darkspawn: gatunek, welon, język, Mindlink, dźwięki

// Gatunek

#define DARKSPAWN_REFLECT_COOLDOWN 15 SECONDS

/datum/species/darkspawn
	name = "Darkspawn"
	id = SPECIES_DARKSPAWN
	sexes = FALSE
	nojumpsuit = TRUE
	changesource_flags = MIRROR_BADMIN | MIRROR_MAGIC | WABBAJACK | ERT_SPAWN
	siemens_coeff = 0
	brutemod = 0.9
	heatmod = 1.5
	no_equip = list(ITEM_SLOT_MASK, ITEM_SLOT_OCLOTHING, ITEM_SLOT_GLOVES, ITEM_SLOT_FEET, ITEM_SLOT_ICLOTHING, ITEM_SLOT_SUITSTORE, ITEM_SLOT_HEAD)
	species_traits = list(NOBLOOD, NO_UNDERWEAR, NO_DNA_COPY, NOTRANSSTING, NOEYESPRITES, NOFLASH)
	inherent_traits = list(TRAIT_NOGUNS, TRAIT_RESISTCOLD, TRAIT_RESISTHIGHPRESSURE, TRAIT_RESISTLOWPRESSURE, TRAIT_NOBREATH, TRAIT_RADIMMUNE, TRAIT_VIRUSIMMUNE, TRAIT_PIERCEIMMUNE, TRAIT_NODISMEMBER, TRAIT_NOHUNGER)
	mutanteyes = /obj/item/organ/eyes/night_vision/alien
	species_language_holder = /datum/language_holder/darkspawn
	species_chest = /obj/item/bodypart/chest/darkspawn
	species_head = /obj/item/bodypart/head/darkspawn
	species_l_arm = /obj/item/bodypart/l_arm/darkspawn
	species_r_arm = /obj/item/bodypart/r_arm/darkspawn
	species_l_leg = /obj/item/bodypart/l_leg/darkspawn
	species_r_leg = /obj/item/bodypart/r_leg/darkspawn
	COOLDOWN_DECLARE(reflect_cd_1)
	COOLDOWN_DECLARE(reflect_cd_2)
	COOLDOWN_DECLARE(reflect_cd_3)

/datum/species/darkspawn/check_roundstart_eligible()
	return FALSE

/// Cienie łykają do trzech pocisków co 15 sekund
/datum/species/darkspawn/bullet_act(obj/item/projectile/P, mob/living/carbon/human/H)
	if(prob(50) && (COOLDOWN_FINISHED(src, reflect_cd_1) || COOLDOWN_FINISHED(src, reflect_cd_2) || COOLDOWN_FINISHED(src, reflect_cd_3)))
		if(COOLDOWN_FINISHED(src, reflect_cd_1))
			COOLDOWN_START(src, reflect_cd_1, DARKSPAWN_REFLECT_COOLDOWN)
		else if(COOLDOWN_FINISHED(src, reflect_cd_2))
			COOLDOWN_START(src, reflect_cd_2, DARKSPAWN_REFLECT_COOLDOWN)
		else
			COOLDOWN_START(src, reflect_cd_3, DARKSPAWN_REFLECT_COOLDOWN)
		H.visible_message("<span class='danger'>Cienie wokół [H] falują, pochłaniając [P]!</span>")
		playsound(H, "bullet_miss", 75, TRUE)
		return BULLET_ACT_BLOCK
	return ..()

/datum/species/darkspawn/on_species_gain(mob/living/carbon/C, datum/species/old_species, pref_load)
	. = ..()
	C.fully_replace_character_name(null, pick(GLOB.nightmare_names))

/datum/species/darkspawn/spec_life(mob/living/carbon/human/H)
	. = ..()
	var/datum/antagonist/darkspawn/darkspawn = isdarkspawn(H)
	var/list/upgrades = darkspawn?.upgrades || list()
	var/turf/T = H.loc
	if(!istype(T))
		return
	var/light_amount = T.get_lumcount()
	if(light_amount < DARKSPAWN_DIM_LIGHT) // szybkie leczenie i otrząsanie się w ciemności
		var/healing_amount = DARKSPAWN_DARK_HEAL
		if(upgrades["dark_healing"])
			healing_amount *= 1.25
		H.adjustBruteLoss(-healing_amount)
		H.adjustFireLoss(-healing_amount)
		H.adjustToxLoss(-healing_amount)
		H.adjustStaminaLoss(-healing_amount * 20)
		H.AdjustStun(-healing_amount * 40)
		H.AdjustKnockdown(-healing_amount * 40)
		H.AdjustUnconscious(-healing_amount * 40)
		H.SetSleeping(0)
		H.setOrganLoss(ORGAN_SLOT_BRAIN, 0)
		H.setCloneLoss(0)
	else if(light_amount < DARKSPAWN_BRIGHT_LIGHT && !upgrades["light_resistance"]) // przyćmione światło
		H.adjustFireLoss(1)
	else if(light_amount > DARKSPAWN_BRIGHT_LIGHT && !H.has_status_effect(/datum/status_effect/darkspawn_creep)) // w świetle szybka śmierć
		if(upgrades["spacewalking"] && isspaceturf(T))
			return
		if(!upgrades["light_resistance"])
			to_chat(H, "<span class='userdanger'>Światło cię pali!</span>")
			H.playsound_local(H, 'sound/weapons/sear.ogg', max(40, 65 * light_amount), TRUE)
			H.adjustFireLoss(DARKSPAWN_LIGHT_BURN)
		else
			to_chat(H, "<span class='userdanger'>Światło cię przypieka!</span>")
			H.playsound_local(H, 'sound/weapons/sear.ogg', max(30, 50 * light_amount), TRUE)
			H.adjustFireLoss(DARKSPAWN_LIGHT_BURN * 0.5)

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
// Sam Darkspeak tak nie działa.
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
	if(!user.mind)
		return TRUE
	if(!is_darkspawn_or_veil(user))
		return TRUE
	user.log_talk(message, LOG_SAY, tag = "darkspawn")
	var/msg = "<span class='velvet'><b>\[Mindlink\] [user.real_name]:</b> \"[message]\"</span>"
	var/turf/sender = get_turf(user)
	for(var/mob/M as anything in GLOB.player_list)
		if(M in GLOB.dead_mob_list)
			to_chat(M, "[FOLLOW_LINK(M, user)] [msg]")
		else if(is_darkspawn_or_veil(M))
			var/turf/receiver = get_turf(M)
			if(receiver?.get_virtual_z_level() != sender?.get_virtual_z_level())
				if(prob(25))
					to_chat(M, "<span class='warning'>Mindlink drży od słów, ale są za daleko, żeby je rozróżnić...</span>")
				continue
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

// Welon

/datum/antagonist/veil
	name = "Welon darkspawnów"
	roundend_category = "welony"
	antagpanel_category = "Darkspawn"
	banning_key = ROLE_DARKSPAWN
	show_in_antagpanel = FALSE
	show_name_in_check_antagonists = TRUE
	var/mutable_appearance/veil_sigils
	var/datum/team/darkspawn/team

/datum/antagonist/veil/get_team()
	return team

/datum/antagonist/veil/on_gain()
	team = get_darkspawn_team()
	team.veils |= owner
	owner.special_role = "veil"
	message_admins("[key_name_admin(owner.current)] was veiled by a darkspawn!")
	log_game("[key_name(owner.current)] was veiled by a darkspawn!")
	var/datum/objective/veil_serve/objective = new
	objective.owner = owner
	objectives += objective
	return ..()

/datum/antagonist/veil/on_removal()
	team?.veils -= owner
	message_admins("[key_name_admin(owner.current)] was deveiled!")
	log_game("[key_name(owner.current)] was deveiled!")
	if(owner.special_role == "veil")
		owner.special_role = null
	var/mob/living/M = owner.current
	if(M)
		if(issilicon(M))
			M.audible_message("<span class='notice'>[M] wydaje krótki pisk, a potem niskie piknięcie.</span>")
			to_chat(M, "<span class='userdanger'>Zostałeś zamieniony w [iscyborg(M) ? "cyborga" : "SI"]! Nie jesteś już welonem! Choć się starasz, nie pamiętasz niczego ze swojej służby...</span>")
		else
			M.visible_message("<span class='big'>[M] wygląda, jakby znów był panem własnego umysłu!</span>")
			to_chat(M, "<span class='userdanger'>Przenikliwe białe światło zalewa twoje oczy. Twój umysł znów należy do ciebie! Choć się starasz, nie pamiętasz niczego o darkspawnach ani o czasie pod ich władzą...</span>")
		M.update_sight()
	return ..()

/datum/antagonist/veil/apply_innate_effects(mob/living/mob_override)
	var/mob/living/current_mob = mob_override || owner.current
	current_mob.maxHealth -= 40
	veil_sigils = mutable_appearance('aquila/icons/mob/darkspawn/actions_darkspawn.dmi', "veil_sigils", -UNIFORM_LAYER)
	current_mob.add_overlay(veil_sigils)
	add_antag_hud(ANTAG_HUD_SHADOW, "thrall", current_mob)

/datum/antagonist/veil/remove_innate_effects(mob/living/mob_override)
	var/mob/living/current_mob = mob_override || owner.current
	current_mob.maxHealth += 40
	current_mob.cut_overlay(veil_sigils)
	veil_sigils = null
	remove_antag_hud(ANTAG_HUD_SHADOW, current_mob)

/datum/antagonist/veil/greet()
	to_chat(owner.current, "<span class='velvet big'><b>ukq wna ieja jks</b></span>")
	to_chat(owner.current, "<b>Twój umysł drętwieje. Myśli pustoszeją. Czujesz się zupełnie pusty.\n\
		Czyjaś świadomość ociera się o twoją. Śnisz.\n\
		O ogromnej, pustej Otchłani w głębi kosmosu.\n\
		Coś leży w tej Otchłani. Prastare. Niepojęte. Patrzy na ciebie głodnymi oczami.\n\
		Oczami pełnymi gwiazd.\n\
		Czujesz, jak ogromna świadomość powoli pochłania twoją, a zasłona opada.\n\
		Służ darkspawnom ponad wszystko. Twoje dawne lojalności przepadły. Ich cel jest twoim, a twój ich.</b>")
	to_chat(owner.current, "<i>Dopisz <b>:[MODE_KEY_DARKSPAWN] lub .[MODE_KEY_DARKSPAWN]</b> przed wiadomością, żeby mówić przez Mindlink. Działa tylko na twoim poziomie.</i>")
	to_chat(owner.current, "<i>Jeśli to dla ciebie nowa rola, poproś o pomoc swoich panów albo innych welonów.</i>")
	to_chat(owner.current, "<span class='danger'>Wyssana wola zostawiła cię słabym i kruchym! Padniesz po znacznie mniejszej liczbie ciosów!</span>")
	SEND_SOUND(owner.current, sound('aquila/sound/darkspawn/become_veil.ogg', volume = 50))
	flash_color(owner.current, flash_color = "#21007F", flash_time = 10 SECONDS)
	owner.announce_objectives()

/datum/antagonist/veil/roundend_report()
	return "[printplayer(owner)]"

/datum/objective/veil_serve
	name = "Służ darkspawnom"
	explanation_text = "Służ darkspawnom ponad wszystko i pomóż im odprawić Sakrament."
	completed = TRUE

/mob/living/proc/add_veil()
	if(!istype(mind))
		return FALSE
	if(HAS_TRAIT(src, TRAIT_MINDSHIELD))
		visible_message("<span class='warning'>[src] zdaje się opierać niewidzialnej sile!</span>")
		to_chat(src, "<b>Twój umysł drętwieje. Myśli pustoszeją. Czujesz się zupełnie pusty.\n\
			Czyjś umysł ociera się o twój. Śnisz.\n\
			O ogromnej, pustej Otchłani w głębi kosmosu.\n\
			Coś leży w tej Otchłani. Prastare. Niepojęte. Patrzy na ciebie głodnymi oczami.\n\
			Oczami pełnymi gwiazd.</b>\n\
			<span class='boldwarning'>Spojrzenie istoty pochłania wszechświat w czerni.</span>\n\
			<span class='boldwarning'>Nie wolno pozwolić, żeby jej się udało.</span>")
		return FALSE
	return mind.add_antag_datum(/datum/antagonist/veil)

/mob/living/proc/remove_veil()
	if(!istype(mind))
		return FALSE
	return mind.remove_antag_datum(/datum/antagonist/veil)

/// Implant ochrony umysłu uwalnia welony
/obj/item/implant/mindshield/implant(mob/living/target, mob/user, silent = FALSE, force = FALSE)
	. = ..()
	if(. && isveil(target))
		target.remove_veil()
