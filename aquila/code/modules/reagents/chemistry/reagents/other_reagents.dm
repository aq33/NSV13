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

/datum/reagent/water/holywater/on_mob_life(mob/living/carbon/M)
	if(ishuman(M) && is_sinfuldemon(M) && prob(80))
		switch(data)
			if(1 to 4)
				to_chat(M, "<span_class='warning'>Your unholy blood begins to burn as holy power creeps through you.</span>")
				M.adjustFireLoss(1)
			if(5 to 10)
				to_chat(M, "<span class='danger'The burning deepens and strengthens!</span>")
				M.adjustFireLoss(2)
			if(11 to 12)
				to_chat(M, "<span class='danger'Your flesh itself begins to melt apart in agony!</span>")
				M.adjustFireLoss(3)
				M.emote("scream")
			if(13 to INFINITY)
				M.visible_message("<span class='danger'>[M] suddenly ignites in a brilliant flash of white!<span>")
				M.adjust_fire_stacks(3)
				M.IgniteMob()
				M.adjustFireLoss(4)
	.=..()

/datum/reagent/silver/reaction_mob(mob/living/M, method=TOUCH, reac_volume)
	if(ishuman(M) && is_sinfuldemon(M) && prob(80)) //sinful demons have a lesser reaction to silver
		M.reagents.add_reagent(/datum/reagent/toxin, reac_volume)
	..()
