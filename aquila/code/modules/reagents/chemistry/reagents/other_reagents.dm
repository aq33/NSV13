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
		to_chat(H, "<span class='warning'>Stajesz się: [initial(species_type.name)]!</span>")
		return TRUE
	return ..()

/datum/reagent/concentrated_bz
	name = "Concentrated BZ"
	description = "Hiperskoncentrowana ciekła postać gazu BZ, znana z wywoływania wyjątkowo silnej reakcji u zmiennokształtnych. Powoduje też lekkie uszkodzenia mózgu."
	color = "#FAFF00"
	taste_description = "cierpki cynamon"


/datum/reagent/concentrated_bz/on_mob_life(mob/living/L)
	if(L.mind)
		var/datum/antagonist/changeling/changeling = L.mind.has_antag_datum(/datum/antagonist/changeling)
		if(changeling)
			changeling.chem_charges = max(changeling.chem_charges-2, 0)
			if(prob(30))
				L.losebreath += 1
				L.adjustOxyLoss(3,5)
				L.emote("gasp")
				to_chat(L, "<font size=3 color=red><b>Nie możesz oddychać!</b></font>")

		L.adjustOrganLoss(ORGAN_SLOT_BRAIN, 2, 50)
	return ..()

/datum/reagent/fake_cbz
	name = "Concentrated BZ"
	description = "Hiperskoncentrowana ciekła postać gazu BZ, znana z wywoływania wyjątkowo silnej reakcji u zmiennokształtnych. Powoduje też lekkie uszkodzenia mózgu."
	color = "#FAFF00"
	taste_description = "cierpki cynamon"


/datum/reagent/fake_cbz/on_mob_life(mob/living/L)
	L.adjustOrganLoss(ORGAN_SLOT_BRAIN, 2, 50)
	if(prob(15))
		to_chat(L, "Prawie nic nie czujesz")

/datum/reagent/water/holywater/on_mob_life(mob/living/carbon/M)
	if(ishuman(M) && is_sinfuldemon(M) && prob(80) && islist(data))
		switch(data["misc"])
			if(1 to 4)
				to_chat(M, span_warning("Twoja nieświęta krew zaczyna płonąć, gdy przenika cię święta moc."))
				M.adjustFireLoss(1)
			if(5 to 10)
				to_chat(M, span_danger("Pieczenie się pogłębia i wzmaga!"))
				M.adjustFireLoss(2)
			if(11 to 12)
				to_chat(M, span_danger("Twoje ciało zaczyna rozpadać się w agonii!"))
				M.adjustFireLoss(3)
				M.emote("scream")
			if(13 to INFINITY)
				M.visible_message(span_danger("[M] nagle staje w płomieniach w olśniewającym białym blasku!"), span_userdanger("Nagle stajesz w świętym ogniu!"))
				M.adjust_fire_stacks(3)
				M.IgniteMob()
				M.adjustFireLoss(4)
	.=..()

/datum/reagent/silver/reaction_mob(mob/living/M, method=TOUCH, reac_volume)
	if(ishuman(M) && is_sinfuldemon(M) && prob(80)) //sinful demons have a lesser reaction to silver
		M.reagents.add_reagent(/datum/reagent/toxin, reac_volume)
	..()
