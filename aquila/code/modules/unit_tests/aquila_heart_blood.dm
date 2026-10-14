// The upstream assert macros are #undef'd at the end of code/modules/unit_tests/_unit_tests.dm, so this modular test carries its own copies
#define TEST_ASSERT(assertion, reason) if (!(assertion)) { return Fail("Assertion failed: [reason || "No reason"]") }

/// AQUILA - hearts regenerate blood (tgstation#96129)
/datum/unit_test/aquila_heart_blood

/datum/unit_test/aquila_heart_blood/Run()
	var/mob/living/carbon/human/patient = allocate(/mob/living/carbon/human)
	var/obj/item/organ/heart/heart = patient.getorganslot(ORGAN_SLOT_HEART)
	TEST_ASSERT(heart, "Human has no heart")
	TEST_ASSERT(patient.get_heart_blood_regeneration_multiplier() == 1, "A healthy heart does not regenerate blood at full speed")

	heart.applyOrganDamage(heart.maxHealth / 2)
	var/half = patient.get_heart_blood_regeneration_multiplier()
	TEST_ASSERT(half > 0 && half < 1, "A damaged heart regenerates at the wrong speed ([half])")

	heart.Stop()
	TEST_ASSERT(patient.get_heart_blood_regeneration_multiplier() == 0, "A stopped heart still regenerates blood")

	heart.Remove(patient)
	qdel(heart)
	TEST_ASSERT(patient.get_heart_blood_regeneration_multiplier() == 0, "A heartless human still regenerates blood")

	patient.blood_volume = BLOOD_VOLUME_SAFE
	patient.nutrition = NUTRITION_LEVEL_FED
	patient.handle_blood()
	TEST_ASSERT(patient.blood_volume == BLOOD_VOLUME_SAFE, "Blood regenerated without a heart")

#undef TEST_ASSERT
