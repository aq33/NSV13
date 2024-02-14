/datum/reagent/mutationtoxin/lizard/on_mob_life(mob/living/carbon/human/H)
	if(current_cycle >= cycles_to_turn) //overwrite since we want more races
		var/list/random_races = list(/datum/species/zombie,
									/datum/species/skeleton,
									/datum/species/vampire,
									/datum/species/snail,
									/datum/species/apid)
		var/datum/species/species_type = pick(random_races)
		H.set_species(species_type)
		H.reagents.del_reagent(type)
		to_chat(H, "<span class='warning'>You've become \a [initial(species_type.name)]!</span>")
		return TRUE
	return ..()

/datum/reagent/concentrated_bz
	name = "Concentrated BZ"
	description = "A hyperconcentrated liquid form of BZ gas, known to cause an extremely adverse reaction to changelings. Also causes minor brain damage."
	color = "#FAFF00"
	taste_description = "acrid cinnamon"


/datum/reagent/concentrated_bz/on_mob_life(mob/living/L)
	if(L.mind)
		var/datum/antagonist/changeling/changeling = L.mind.has_antag_datum(/datum/antagonist/changeling)
		if(changeling)
			changeling.chem_charges = max(changeling.chem_charges-2, 0)
			if(prob(30))
				L.losebreath += 1
				L.adjustOxyLoss(3,5)
				L.emote("gasp")
				to_chat(L, "<font size=3 color=red><b>You can't breathe!</b></font>")

		L.adjustOrganLoss(ORGAN_SLOT_BRAIN, 2, 50)
	return ..()

/datum/reagent/fake_cbz
	name = "Concentrated BZ"
	description = "A hyperconcentrated liquid form of BZ gas, known to cause an extremely adverse reaction to changelings. Also causes minor brain damage."
	color = "#FAFF00"
	taste_description = "acrid cinnamon"


/datum/reagent/fake_cbz/on_mob_life(mob/living/L)
	L.adjustOrganLoss(ORGAN_SLOT_BRAIN, 2, 50)
	if(prob(15))
		to_chat(L, "You don't feel much of anything")
