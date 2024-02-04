/datum/mutation/jellybones
	name = "Jelly Bones"
	desc = "All of that yoga seems to have paid off."
	quality = POSITIVE
	text_gain_indication = "<span class='notice'>Your bones feel like they're made of jelly, you could probably squeeze into a vent.</span>"
	text_lose_indication = "<span class='notice'>Your bones feel solid again.</span>"
	difficulty = 14
	instability = 25

/datum/mutation/jellybones/on_acquiring(mob/living/carbon/human/owner)
	if(..())
		return
	owner.ventcrawler = VENTCRAWLER_NUDE

/datum/mutation/jellybones/on_losing(mob/living/carbon/human/owner)
	if(..())
		return
	owner.ventcrawler = VENTCRAWLER_NONE

/datum/mutation/breathless
	name = "Breathless"
	desc = "Affected person does not need to breathe."
	quality = POSITIVE
	text_gain_indication = "<span class='notice'>Your lungs feel like they are filled with air.</span>"
	text_lose_indication = "<span class='notice'>Your lungs feel empty again.</span>"
	difficulty = 14
	instability = 35

/datum/mutation/breathless/on_acquiring(mob/living/carbon/human/owner)
	if(..())
		return
	ADD_TRAIT(owner, TRAIT_NOBREATH, GENETIC_MUTATION)

/datum/mutation/breathless/on_losing(mob/living/carbon/human/owner)
	if(..())
		return
	REMOVE_TRAIT(owner, TRAIT_NOBREATH, GENETIC_MUTATION)

/datum/mutation/toxicfart
	name = "Toxic Fart"
	desc = "A mutation that causes the subject to synthesize plasma in their intestines."
	quality = POSITIVE
	text_gain_indication = "<span class='notice'>Your stomach feels heavy.</span>"
	text_lose_indication = "<span class='notice'>Your stomach feels light again.</span>"
	difficulty = 16
	instability = 20

/datum/mutation/toxicfart/on_acquiring(mob/living/carbon/human/owner)
	if(..())
		return
	ADD_TRAIT(owner, TRAIT_TOXICFART, GENETIC_MUTATION)

/datum/mutation/toxicfart/on_losing(mob/living/carbon/human/owner)
	if(..())
		return
	REMOVE_TRAIT(owner, TRAIT_TOXICFART, GENETIC_MUTATION)


/datum/mutation/megafart
	name = "Mega Fart"
	desc = "A mutation that causes the subject to fart with enough force to knock everyone around them back."
	locked = TRUE
	text_gain_indication = "<span class='notice'>You feel bloated and gassy.</span>"
	text_lose_indication = "<span class='notice'>You feel light again.</span>"
	instability = 25

/datum/mutation/megafart/on_acquiring(mob/living/carbon/human/owner)
	if(..())
		return
	ADD_TRAIT(owner, TRAIT_MEGAFART, GENETIC_MUTATION)

/datum/mutation/megafart/on_losing(mob/living/carbon/human/owner)
	if(..())
		return
	REMOVE_TRAIT(owner, TRAIT_MEGAFART, GENETIC_MUTATION)
