// The upstream assert macros are #undef'd at the end of code/modules/unit_tests/_unit_tests.dm, so this modular test carries its own copies
#define TEST_ASSERT(assertion, reason) if (!(assertion)) { return Fail("Assertion failed: [reason || "No reason"]") }

/// AQUILA - Miasma: the gas exists, corpses and gibs register with SSmiasma, emission respects the local cap, heat sterilizes it
/datum/unit_test/miasma

/datum/unit_test/miasma/Run()
	TEST_ASSERT(GLOB.gas_data.ids[GAS_MIASMA], "Miasma is not registered with auxgm")
	var/datum/gas_mixture/mix = new
	mix.set_moles(GAS_MIASMA, 5)
	TEST_ASSERT(mix.get_moles(GAS_MIASMA) == 5, "auxmos does not store miasma")

	// Corpses register on death and only rot after the grace period
	var/mob/living/carbon/human/corpse = allocate(/mob/living/carbon/human)
	corpse.death()
	TEST_ASSERT(SSmiasma.sources[corpse], "A corpse did not register as a miasma source")
	TEST_ASSERT(corpse.miasma_emission(10) == 0, "A fresh corpse is already rotting")
	corpse.timeofdeath -= MIASMA_CORPSE_GRACE_PERIOD
	TEST_ASSERT(corpse.miasma_emission(10) > 0, "A corpse past the grace period does not rot")
	corpse.reagents.add_reagent(/datum/reagent/toxin/formaldehyde, 20)
	TEST_ASSERT(corpse.miasma_emission(10) == 0, "An embalmed corpse rots")
	corpse.reagents.clear_reagents()

	// A revived corpse stops rotting, a deleted one unregisters
	corpse.revive(TRUE, TRUE)
	TEST_ASSERT(isnull(corpse.miasma_emission(10)), "A revived mob still rots")
	qdel(corpse)
	TEST_ASSERT(!SSmiasma.sources[corpse], "A deleted corpse is still registered")

	// Gibs rot
	var/obj/effect/decal/cleanable/blood/gibs/gibs = allocate(/obj/effect/decal/cleanable/blood/gibs)
	TEST_ASSERT(SSmiasma.sources[gibs] == MIASMA_GIBS_BUDGET, "Gibs did not register with their budget")

	// Emission goes into the turf's air and stops at the local cap
	var/turf/open/T = get_turf(gibs)
	TEST_ASSERT(istype(T) && T.air, "The test turf has no air")
	T.air.set_moles(GAS_MIASMA, 0)
	SSmiasma.emit(T, 1)
	TEST_ASSERT(T.air.get_moles(GAS_MIASMA) > 0.99, "Emission did not reach the turf's air")
	SSmiasma.emit(T, MIASMA_LOCAL_CAP_MOLES * 10)
	TEST_ASSERT(T.air.get_moles(GAS_MIASMA) <= MIASMA_LOCAL_CAP_MOLES + 0.01, "Emission went past the local cap")
	T.air.set_moles(GAS_MIASMA, 0)

	// Hot, dry air burns miasma into oxygen
	var/datum/gas_mixture/hot = new
	hot.set_moles(GAS_MIASMA, 10)
	hot.set_moles(GAS_N2, 10)
	hot.set_temperature(1000)
	hot.react()
	TEST_ASSERT(hot.get_moles(GAS_MIASMA) < 10, "Dry heat sterilization did not remove miasma")
	TEST_ASSERT(hot.get_moles(GAS_O2) > 0, "Dry heat sterilization did not produce oxygen")

#undef TEST_ASSERT
