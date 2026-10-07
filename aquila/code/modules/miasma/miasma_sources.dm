// AQUILA - Miasma sources. Each one registers with SSmiasma and answers miasma_emission() when polled.

// Corpses: registered on death, unregistered lazily on the next poll after a revive.
// Most corpse spawners kill with death(TRUE), so most mapped corpses never rot. death() returns null for a mob that
// was already dead, so a fully rotted corpse doesn't get a fresh budget.
/mob/living/carbon/death(gibbed)
	. = ..()
	if(. && !gibbed && stat == DEAD)
		SSmiasma.add_source(src, MIASMA_CORPSE_BUDGET)

/mob/living/carbon/miasma_emission(seconds)
	if(stat != DEAD)
		return null
	if(!(MOB_ORGANIC in mob_biotypes) && !(MOB_UNDEAD in mob_biotypes))
		return null
	if(world.time - timeofdeath < MIASMA_CORPSE_GRACE_PERIOD)
		return 0
	// Properly stored corpses don't rot
	if(istype(loc, /obj/structure/closet/crate/coffin) || istype(loc, /obj/structure/closet/body_bag) || istype(loc, /obj/structure/bodycontainer))
		return 0
	// Nor do chilled, embalmed or charred ones
	if(bodytemperature <= T0C - 10 || HAS_TRAIT(src, TRAIT_HUSK) || reagents?.has_reagent(/datum/reagent/toxin/formaldehyde, 15))
		return 0
	return MIASMA_CORPSE_MOLES * seconds

// Gibs, mapped ones included: mapload is also TRUE for gibs made while a map loads in the background
// (FTL jumps), and the budget keeps mapped gibs cheap
/obj/effect/decal/cleanable/blood/gibs/Initialize(mapload, list/datum/disease/diseases)
	. = ..()
	if(. != INITIALIZE_HINT_QDEL)
		SSmiasma.add_source(src, MIASMA_GIBS_BUDGET)

/obj/effect/decal/cleanable/blood/gibs/miasma_emission(seconds)
	return MIASMA_GIBS_MOLES * seconds
