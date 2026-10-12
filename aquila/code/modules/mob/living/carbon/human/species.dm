/datum/species
	var/gendered_speech = FALSE	// If true, will play different speech sounds based on gender.
	var/speech_sound = ""

	// defecation multiplier
	// instead of setting this to 0
	// add TRAIT_NOSHITTING to inherent traits
	var/shitmod = 1

/// Body sizes this species can pick in preferences. "Polak" is human-only.
/datum/species/proc/get_body_sizes()
	if(id == SPECIES_HUMAN)
		return GLOB.body_sizes
	return GLOB.body_sizes - "Polak"

/// The "Polak" belly drawn over the chest in the skin colour.
/datum/species/proc/get_polak_overlays(mob/living/carbon/human/H)
	. = list()
	if(id != SPECIES_HUMAN || H.dna.features["body_size"] != "Polak" || HAS_TRAIT(H, TRAIT_HUSK))
		return
	var/obj/item/bodypart/chest/chest = H.get_bodypart(BODY_ZONE_CHEST)
	if(!chest || !IS_ORGANIC_LIMB(chest))
		return
	// Clothing sprites are drawn for a slim body, so the belly is only shown when naked
	if(H.w_uniform || H.wear_suit)
		return
	if((H.underwear && H.underwear != "Nude") || (H.undershirt && H.undershirt != "Nude"))
		return
	var/mutable_appearance/belly = mutable_appearance('aquila/icons/mob/zachary.dmi', "polak_(grayscale)", -BODY_LAYER)
	if(chest.draw_color)
		belly.color = "#[chest.draw_color]"
	. += belly

/datum/species/proc/eat_text(fullness, eatverb, obj/O, mob/living/carbon/C, mob/user)
	if(C == user)
		if(fullness<=50)
			user.visible_message("<span class='notice'>[user] gorączkowo [eatverb] [O], pochłaniając to!</span>", "<span class='>notice'Gorączkowo jesz [O], pochłaniając to!</span>")
		else if((fullness > 50 && fullness < 150) || HAS_TRAIT(C, TRAIT_BOTTOMLESS_STOMACH))
			user.visible_message("<span class='notice'>[user] łapczywie [eatverb] [O].</span>", "<span class='>notice'Łapczywie jesz [O].</span>")
		else if(fullness > 500 && fullness < 600)
			user.visible_message("<span class='notice'>[user] niechętnie [eatverb] kawałek [O].</span>", "<span class='notice'>Niechętnie jesz kawałek [O].</span>")
		else if(fullness > (600 * (1 + C.overeatduration / 2000)))	// The more you eat - the more you can eat
			user.visible_message("<span class='warning'>[user] nie może wcisnąć sobie do gardła już ani kawałka [O]!</span>", "<span class='warning'>Nie możesz wcisnąć sobie do gardła już ani kawałka [O]!</span>")
			return FALSE
