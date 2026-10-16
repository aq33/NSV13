// Kałamarnicoludzie, przywróceni ze starej Aquili (aq33/tgstation). Mówią jak osadnicy z Minecrafta: hrmm.
/datum/species/squid
	name = "\improper Squidperson"
	id = "squid"
	default_color = "b8dfda"
	species_traits = list(MUTCOLORS, EYECOLOR)
	inherent_traits = list(TRAIT_NOSLIPALL, TRAIT_EASYDISMEMBER)
	default_features = list("mcolor" = "FFF", "body_size" = "Normal")
	speedmod = 0.5
	burnmod = 1.5
	heatmod = 1.4
	coldmod = 1.5
	punchdamage = 7 // to tylko macka
	changesource_flags = MIRROR_BADMIN | WABBAJACK | MIRROR_PRIDE | MIRROR_MAGIC | RACE_SWAP | ERT_SPAWN | SLIME_EXTRACT
	attack_verb = "lash"
	attack_sound = 'sound/weapons/whip.ogg'
	miss_sound = 'sound/weapons/etherealmiss.ogg'
	grab_sound = 'sound/weapons/whipgrab.ogg'
	deathsound = 'sound/voice/hiss1.ogg'
	use_skintones = FALSE
	no_equip = list(ITEM_SLOT_FEET)
	skinned_type = /obj/item/stack/sheet/animalhide/human
	species_language_holder = /datum/language_holder/squid
	swimming_component = /datum/component/swimming/squid
	mutanttongue = /obj/item/organ/tongue/squid
	speech_sound = "villager"

	species_chest = /obj/item/bodypart/chest/squid
	species_head = /obj/item/bodypart/head/squid
	species_l_arm = /obj/item/bodypart/l_arm/squid
	species_r_arm = /obj/item/bodypart/r_arm/squid
	species_l_leg = /obj/item/bodypart/l_leg/squid
	species_r_leg = /obj/item/bodypart/r_leg/squid

/mob/living/carbon/human/species/squid
	race = /datum/species/squid

/datum/species/squid/random_name(gender, unique, lastname, attempts)
	if(unique)
		return random_unique_squid_name(gender, lastname, attempts || 10)
	return squid_name(gender, lastname)

/// Kałamarnicze imię i nazwisko: podane nazwisko ma pierwszeństwo przed losowym
/proc/squid_name(gender, lastname)
	if(!lastname)
		lastname = pick(gender == MALE ? GLOB.last_names_male : GLOB.last_names_female)
	return "[pick(gender == MALE ? GLOB.squid_names_male : GLOB.squid_names_female)] [lastname]"

/proc/random_unique_squid_name(gender, lastname, attempts_to_find_unique_name = 10)
	for(var/i in 1 to attempts_to_find_unique_name)
		. = capitalize(squid_name(gender, lastname))
		if(!findname(.))
			break

GLOBAL_LIST_INIT(squid_names_male, world.file2list("strings/names/squid_male.txt"))
GLOBAL_LIST_INIT(squid_names_female, world.file2list("strings/names/squid_female.txt"))

/datum/species/squid/on_species_gain(mob/living/carbon/C, datum/species/old_species, pref_load)
	. = ..()
	var/datum/action/innate/squid_change/change = new
	change.Grant(C)

/datum/species/squid/on_species_loss(mob/living/carbon/human/C, datum/species/new_species, pref_load)
	. = ..()
	var/datum/action/innate/squid_change/change = locate() in C.actions
	qdel(change)

/// Język kałamarnic: hrmm, hmm, hurr
/obj/item/organ/tongue/squid
	name = "squid tongue"
	desc = "Gruba macka pełniąca rolę języka. Najlepiej wychodzi jej mruczenie."
	say_mod = "mruczy"
	toxic_food = TOXIC | FRIED
	modifies_speech = TRUE
	var/static/list/villager_prefixes = list("Hrmm", "Hmm", "Hurr", "Hm", "Hrm")
	var/static/list/villager_suffixes = list("hrmm", "hmm", "hurr", "hm")

/obj/item/organ/tongue/squid/handle_speech(datum/source, list/speech_args)
	var/message = speech_args[SPEECH_MESSAGE]
	if(!message || message[1] == "*")
		return
	if(prob(35))
		message = "[pick(villager_prefixes)]... [message]"
	else if(prob(25))
		var/last = copytext_char(message, -1)
		var/suffix = pick(villager_suffixes)
		if(last in list(".", "!", "?"))
			message = "[copytext_char(message, 1, -1)], [suffix][last]"
		else
			message = "[message], [suffix]."
	speech_args[SPEECH_MESSAGE] = message

/datum/language_holder/squid
	understood_languages = list(/datum/language/common = list(LANGUAGE_ATOM),
								/datum/language/rlyehian = list(LANGUAGE_ATOM))
	spoken_languages = list(/datum/language/common = list(LANGUAGE_ATOM),
							/datum/language/rlyehian = list(LANGUAGE_ATOM))

/// Własny język kałamarnic. Brzmi dokładnie jak handel z osadnikiem.
/datum/language/rlyehian
	name = "R'Lyehian"
	desc = "Mało znany, gardłowy język kałamarnicoludzi. Dla obcych brzmi jak niekończące się „hrmm”."
	speech_verb = "mruczy"
	ask_verb = "hmmczy pytająco"
	exclaim_verb = "hurruje"
	whisper_verb = "pomrukuje cicho"
	key = "q"
	flags = TONGUELESS_SPEECH
	space_chance = 60
	syllables = list("hrmm", "hmm", "hrm", "hurr", "huh", "hm", "hmmm", "hrrm", "hmph", "hrr", "uhm", "hurm")
	icon_state = "rlyehian"
	default_priority = 90

/datum/action/innate/squid_change
	name = "Zmiana koloru"
	desc = "Zmień barwę skóry, jak przystało na kałamarnicę."
	check_flags = AB_CHECK_CONSCIOUS
	icon_icon = 'aquila/icons/mob/species/squid_action.dmi'
	button_icon_state = "squid"
	COOLDOWN_DECLARE(color_cooldown)

/datum/action/innate/squid_change/IsAvailable()
	if(!COOLDOWN_FINISHED(src, color_cooldown))
		return FALSE
	return ..()

/datum/action/innate/squid_change/Activate()
	var/mob/living/carbon/human/H = owner
	if(!istype(H))
		return
	var/new_color = input(H, "Wybierz nowy kolor skóry:", "Zmiana koloru", "#[H.dna.features["mcolor"]]") as color|null
	if(!new_color || QDELETED(H) || !IsAvailable())
		return
	var/list/hsv = ReadHSV(RGBtoHSV(new_color))
	if(hsv[3] < ReadHSV(RGBtoHSV("#7F7F7F"))[3])
		to_chat(H, "<span class='danger'>Ten kolor jest za ciemny.</span>")
		return
	H.dna.features["mcolor"] = sanitize_hexcolor(new_color)
	H.update_body_parts(TRUE)
	H.visible_message("<span class='notice'>Skóra [H] mieni się i zmienia barwę.</span>", "<span class='notice'>Zmieniasz barwę skóry.</span>")
	COOLDOWN_START(src, color_cooldown, 5 SECONDS)
	UpdateButtonIcon()

/obj/item/bodypart/head/squid
	icon = 'aquila/icons/mob/species/egg_squid_parts.dmi'
	limb_id = "squid"
	is_dimorphic = TRUE

/obj/item/bodypart/chest/squid
	icon = 'aquila/icons/mob/species/egg_squid_parts.dmi'
	limb_id = "squid"
	is_dimorphic = TRUE

/obj/item/bodypart/l_arm/squid
	icon = 'aquila/icons/mob/species/egg_squid_parts.dmi'
	limb_id = "squid"

/obj/item/bodypart/r_arm/squid
	icon = 'aquila/icons/mob/species/egg_squid_parts.dmi'
	limb_id = "squid"

/obj/item/bodypart/l_leg/squid
	icon = 'aquila/icons/mob/species/egg_squid_parts.dmi'
	limb_id = "squid"

/obj/item/bodypart/r_leg/squid
	icon = 'aquila/icons/mob/species/egg_squid_parts.dmi'
	limb_id = "squid"
