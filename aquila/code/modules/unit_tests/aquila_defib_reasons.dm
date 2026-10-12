// The upstream assert macros are #undef'd at the end of code/modules/unit_tests/_unit_tests.dm, so this modular test carries its own copies
#define TEST_ASSERT(assertion, reason) if (!(assertion)) { return Fail("Assertion failed: [reason || "No reason"]") }

/// AQUILA - defibrillation without a time limit: the heart and brain decide (tgstation style)
/datum/unit_test/aquila_defib_reasons

/datum/unit_test/aquila_defib_reasons/Run()
	var/mob/living/carbon/human/patient = allocate(/mob/living/carbon/human)
	var/obj/item/shockpaddles/paddles = allocate(/obj/item/shockpaddles)
	patient.death()
	patient.timeofdeath = world.time - 60 MINUTES
	TEST_ASSERT(patient.is_defib_possible(), "A body dead for an hour with a healthy heart and brain cannot be defibrillated")
	TEST_ASSERT(paddles.can_defib(patient), "The paddles refuse a revivable body")

	var/obj/item/organ/heart/heart = patient.getorgan(/obj/item/organ/heart)
	heart.applyOrganDamage(heart.maxHealth)
	TEST_ASSERT(!patient.is_defib_possible(), "A failing heart can still be defibrillated")
	heart.setOrganDamage(0)
	TEST_ASSERT(patient.is_defib_possible(), "A repaired heart cannot be defibrillated")

	var/obj/item/organ/brain/brain = patient.getorgan(/obj/item/organ/brain)
	brain.applyOrganDamage(brain.maxHealth)
	TEST_ASSERT(!paddles.can_defib(patient), "A failing brain can still be defibrillated")

	TEST_ASSERT(!patient.has_dnr(), "A body without a player counts as DNR")

#undef TEST_ASSERT
