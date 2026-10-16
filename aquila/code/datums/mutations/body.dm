/datum/mutation/jellybones
	name = "Jelly Bones"
	desc = "All of that yoga seems to have paid off."
	quality = POSITIVE
	text_gain_indication = "<span class='notice'>Twoje kości wydają się galaretowate, pewnie dałbyś radę wcisnąć się do szybu wentylacyjnego.</span>"
	text_lose_indication = "<span class='notice'>Twoje kości znów wydają się twarde.</span>"
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
	text_gain_indication = "<span class='notice'>Twoje płuca wydają się wypełnione powietrzem.</span>"
	text_lose_indication = "<span class='notice'>Twoje płuca znów wydają się puste.</span>"
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
	text_gain_indication = "<span class='notice'>Twój żołądek wydaje się ciężki.</span>"
	text_lose_indication = "<span class='notice'>Twój żołądek znów wydaje się lekki.</span>"
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
	text_gain_indication = "<span class='notice'>Czujesz się wzdęty i pełen gazów.</span>"
	text_lose_indication = "<span class='notice'>Znów czujesz się lekko.</span>"
	instability = 25

/datum/mutation/megafart/on_acquiring(mob/living/carbon/human/owner)
	if(..())
		return
	ADD_TRAIT(owner, TRAIT_MEGAFART, GENETIC_MUTATION)

/datum/mutation/megafart/on_losing(mob/living/carbon/human/owner)
	if(..())
		return
	REMOVE_TRAIT(owner, TRAIT_MEGAFART, GENETIC_MUTATION)

// Genetyka 2.0: mutacje z changelogu dostępne dla każdego, a składniki receptur do znalezienia w puli
/datum/mutation/thermal
	locked = FALSE

/datum/mutation/catclaws
	name = "Claws"
	desc = "Subject's hands grow sharpened claws."
	locked = FALSE
	species_allowed = list()

/datum/mutation/firebreath
	desc = "An ancient mutation that lets the subject breathe fire."
	locked = FALSE
	species_allowed = list()
