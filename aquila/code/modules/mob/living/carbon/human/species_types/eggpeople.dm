// Jajoludzie, przywróceni ze starej Aquili (aq33/tgstation). Im bardziej usmażeni, tym twardsza skorupka.
#define EGG_MAXBRUTEMOD 1.5
#define EGG_ALPHA 0.00018
#define EGG_BETA (-0.027)

/datum/species/egg
	name = "\improper Eggperson"
	id = "egg"
	fixed_mut_color = "FFE7C9"
	default_features = list("body_size" = "Normal")
	offset_features = list(OFFSET_EARS = list(0,2), OFFSET_HEAD = list(0,2))
	species_traits = list(MUTCOLORS)
	inherent_biotypes = list(MOB_ORGANIC, MOB_HUMANOID)
	brutemod = EGG_MAXBRUTEMOD // nie najtwardsze jajko w tuzinie
	heatmod = 1.1 // łatwo je ugotować
	changesource_flags = MIRROR_BADMIN | WABBAJACK | MIRROR_PRIDE | MIRROR_MAGIC | RACE_SWAP | ERT_SPAWN | SLIME_EXTRACT
	attack_verb = "slash"
	attack_sound = 'sound/weapons/slash.ogg'
	miss_sound = 'sound/weapons/slashmiss.ogg'
	meat = /obj/item/food/omelette
	skinned_type = /obj/item/stack/sheet/animalhide/egg
	exotic_blood = /datum/reagent/consumable/eggyolk
	species_language_holder = /datum/language_holder/egg
	mutanttongue = /obj/item/organ/tongue/egg
	speech_sound = "eggcrack"

	species_chest = /obj/item/bodypart/chest/egg
	species_head = /obj/item/bodypart/head/egg
	species_l_arm = /obj/item/bodypart/l_arm/egg
	species_r_arm = /obj/item/bodypart/r_arm/egg
	species_l_leg = /obj/item/bodypart/l_leg/egg
	species_r_leg = /obj/item/bodypart/r_leg/egg

/mob/living/carbon/human/species/egg
	race = /datum/species/egg

/datum/species/egg/apply_damage(damage, damagetype = BRUTE, def_zone = null, blocked, mob/living/carbon/human/H, forced = FALSE)
	if(damagetype == BRUTE)
		// Odporność skorupki zależy od oparzeń: im bardziej usmażone jajko, tym twardsze. https://www.desmos.com/calculator/dwxdxwt0rl
		var/x = H.getFireLoss()
		brutemod = EGG_ALPHA * x*x + EGG_BETA * x + EGG_MAXBRUTEMOD
		if(H.getBruteLoss() >= 200) // cios *po* przekroczeniu 200 obrażeń rozbija jajko
			H.visible_message("<span class='danger'>[H] pęka z głośnym chrupnięciem!</span>", "<span class='userdanger'>Twoja skorupka się rozpada!</span>")
			playsound(H, 'aquila/sound/voice/speech/eggcrack4.ogg', 80, TRUE)
			H.gib(FALSE)
			return TRUE
		if(damage >= 5 && !forced)
			playsound(H, "eggcrack", 50, TRUE)
	return ..()

/obj/item/organ/tongue/egg
	name = "egg tongue"
	desc = "Pomarszczony kawałek białka, który jakoś potrafi trzeszczeć słowami."
	say_mod = "trzeszczy"
	liked_food = MEAT // jajoludzie to mięsożercy
	disliked_food = GROSS | DAIRY | BREAKFAST
	toxic_food = TOXIC

/obj/item/stack/sheet/animalhide/egg
	name = "egg shell pieces"
	desc = "Roztrzaskane szczątki jajoczłowieka."
	singular_name = "egg shell pieces"
	icon_state = "sheet-gondola"
	item_state = "sheet-gondola"

/datum/language_holder/egg
	understood_languages = list(/datum/language/common = list(LANGUAGE_ATOM),
								/datum/language/ovarian = list(LANGUAGE_ATOM))
	spoken_languages = list(/datum/language/common = list(LANGUAGE_ATOM),
							/datum/language/ovarian = list(LANGUAGE_ATOM))

/datum/language/ovarian
	name = "Ovarian"
	desc = "Wspólny język jajoludzi, złożony z syczących trzasków i bulgotów."
	speech_verb = "bulgocze"
	ask_verb = "trzeszczy pytająco"
	exclaim_verb = "skwierczy"
	whisper_verb = "chrupie cicho"
	key = "e"
	flags = TONGUELESS_SPEECH
	space_chance = 40
	syllables = list("blurb", "blub", "blab", "gurgle", "crack", "crick", "blirb", "krak", "chrup", "trzask")
	icon = 'aquila/icons/mob/species/egg_language.dmi'
	icon_state = "egg"
	default_priority = 90

/obj/item/bodypart/head/egg
	icon = 'aquila/icons/mob/species/egg_squid_parts.dmi'
	limb_id = "egg"
	is_dimorphic = TRUE

/obj/item/bodypart/chest/egg
	icon = 'aquila/icons/mob/species/egg_squid_parts.dmi'
	limb_id = "egg"
	is_dimorphic = TRUE

/obj/item/bodypart/l_arm/egg
	icon = 'aquila/icons/mob/species/egg_squid_parts.dmi'
	limb_id = "egg"

/obj/item/bodypart/r_arm/egg
	icon = 'aquila/icons/mob/species/egg_squid_parts.dmi'
	limb_id = "egg"

/obj/item/bodypart/l_leg/egg
	icon = 'aquila/icons/mob/species/egg_squid_parts.dmi'
	limb_id = "egg"

/obj/item/bodypart/r_leg/egg
	icon = 'aquila/icons/mob/species/egg_squid_parts.dmi'
	limb_id = "egg"

#undef EGG_MAXBRUTEMOD
#undef EGG_ALPHA
#undef EGG_BETA
