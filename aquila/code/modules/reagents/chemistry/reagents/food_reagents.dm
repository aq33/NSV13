/datum/reagent/consumable
	/// How much does this raise the need to defecate per tick?
	var/defecation_factor = 0

/datum/reagent/consumable/on_mob_life(mob/living/carbon/M)
	if(defecation_factor && ishuman(M) && CONFIG_GET(flag/shitting_enabled))
		var/mob/living/carbon/human/H = M
		H.adjust_defecation(defecation_factor * H.physiology.defecation_mod * H.dna.species.shitmod)
	return ..()

// Coffee gets things moving
/datum/reagent/consumable/coffee
	defecation_factor = 0.75 * REAGENTS_METABOLISM

/datum/reagent/consumable/icecoffee
	defecation_factor = 0.75 * REAGENTS_METABOLISM

/datum/reagent/consumable/soy_latte
	defecation_factor = 0.75 * REAGENTS_METABOLISM

/datum/reagent/consumable/cafe_latte
	defecation_factor = 0.75 * REAGENTS_METABOLISM

/datum/reagent/consumable/pumpkin_latte
	defecation_factor = 0.75 * REAGENTS_METABOLISM

/datum/reagent/consumable/navy_coffee
	defecation_factor = 1.5 * REAGENTS_METABOLISM

/datum/reagent/consumable/ethanol/irishcoffee
	defecation_factor = 0.75 * REAGENTS_METABOLISM

// So does spicy food
/datum/reagent/consumable/capsaicin
	defecation_factor = 1.25 * REAGENTS_METABOLISM

/datum/reagent/consumable/hell_ramen
	defecation_factor = 1.25 * REAGENTS_METABOLISM

/datum/reagent/consumable/castor_oil
	name = "Olej rycynowy"
	description = "Silny środek przeczyszczający. Wypróżnienie po nim oczyszcza organizm z innych substancji."
	color = "#F2E6B1"
	chem_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_FUN
	taste_description = "thick oily bitterness"
	nutriment_factor = 0
	hydration_factor = 0
	defecation_factor = 7.5 * REAGENTS_METABOLISM
	/// How much of every other reagent is flushed out when the bowels are emptied
	var/purge_amount = 10

/// Flushes other reagents out of the mob when it empties its bowels
/datum/reagent/consumable/castor_oil/proc/purge(mob/living/L)
	for(var/datum/reagent/R as anything in L.reagents.reagent_list.Copy())
		if(R != src)
			L.reagents.remove_reagent(R.type, purge_amount)
	to_chat(L, "<span class='notice'>Czujesz, jak twój organizm się oczyszcza.</span>")
