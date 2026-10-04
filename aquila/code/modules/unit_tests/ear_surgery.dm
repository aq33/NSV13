// The upstream assert macros are #undef'd at the end of code/modules/unit_tests/_unit_tests.dm, so this modular test carries its own copies
#define TEST_ASSERT(assertion, reason) if (!(assertion)) { return Fail("Assertion failed: [reason || "No reason"]") }

#define TEST_ASSERT_EQUAL(a, b, message) do { \
	var/lhs = ##a; \
	var/rhs = ##b; \
	if (lhs != rhs) { \
		return Fail("Expected [isnull(lhs) ? "null" : lhs] to be equal to [isnull(rhs) ? "null" : rhs].[message ? " [message]" : ""]"); \
	} \
} while (FALSE)

/// AQUILA - Ear surgery (#268): repairs failed ears, failure stabs the brain, needs ears to start
/datum/unit_test/ear_surgery

/datum/unit_test/ear_surgery/Run()
	var/mob/living/carbon/human/surgeon = allocate(/mob/living/carbon/human)
	var/mob/living/carbon/human/patient = allocate(/mob/living/carbon/human)
	var/obj/item/hemostat/hemostat = allocate(/obj/item/hemostat)
	var/obj/item/organ/ears/ears = patient.getorganslot(ORGAN_SLOT_EARS)
	TEST_ASSERT(ears, "Patient has no ears")
	TEST_ASSERT(locate(/datum/surgery/ear_surgery) in GLOB.surgeries_list, "Ear surgery is not in the surgery list")

	// Ears destroyed by a loud noise: failing and deaf
	ears.applyOrganDamage(ears.maxHealth)
	ears.deaf = 200
	TEST_ASSERT(ears.organ_flags & ORGAN_FAILING, "Fully damaged ears are not failing")

	var/datum/surgery/ear_surgery/surgery = new(patient, BODY_ZONE_HEAD, patient.get_bodypart(BODY_ZONE_HEAD))
	TEST_ASSERT(surgery.can_start(surgeon, patient), "Ear surgery cannot start on a patient with ears")
	var/datum/surgery_step/fix_ears/step = new

	// An interrupted step (only preop) changes nothing
	step.preop(surgeon, patient, BODY_ZONE_HEAD, hemostat, surgery)
	TEST_ASSERT(ears.organ_flags & ORGAN_FAILING, "Starting the step already fixed the ears")

	// A botched step stabs the brain and leaves the ears broken
	var/brain_before = patient.getOrganLoss(ORGAN_SLOT_BRAIN)
	TEST_ASSERT(!step.failure(surgeon, patient, BODY_ZONE_HEAD, hemostat, surgery), "Failure counted as success")
	TEST_ASSERT(patient.getOrganLoss(ORGAN_SLOT_BRAIN) > brain_before, "Failure did not damage the brain")
	TEST_ASSERT(ears.organ_flags & ORGAN_FAILING, "Failure fixed the ears")

	// Success: healthy ears, a short temporary deafness, still exactly one pair of ears
	TEST_ASSERT(step.success(surgeon, patient, BODY_ZONE_HEAD, hemostat, surgery), "Success returned FALSE")
	TEST_ASSERT_EQUAL(ears.damage, 0, "Ears still damaged")
	TEST_ASSERT(!(ears.organ_flags & ORGAN_FAILING), "Ears still failing")
	TEST_ASSERT_EQUAL(ears.deaf, 20, "Deafness not reset to the short recovery time")
	TEST_ASSERT_EQUAL(patient.getorganslot(ORGAN_SLOT_EARS), ears, "Ears were replaced")
	var/ear_count = 0
	for(var/obj/item/organ/ears/E in patient.internal_organs)
		ear_count++
	TEST_ASSERT_EQUAL(ear_count, 1, "Wrong number of ears after surgery")
	for(var/i in 1 to 25) // the recovery deafness wears off on its own
		ears.on_life()
	TEST_ASSERT_EQUAL(ears.deaf, 0, "Recovery deafness did not wear off")

	// No ears, no surgery, and a success step on an earless patient does not runtime
	ears.Remove(patient)
	qdel(ears)
	TEST_ASSERT(!surgery.can_start(surgeon, patient), "Ear surgery can start without ears")
	TEST_ASSERT(step.success(surgeon, patient, BODY_ZONE_HEAD, hemostat, surgery), "Success step broke without ears")
	qdel(surgery)
	qdel(step)

#undef TEST_ASSERT
#undef TEST_ASSERT_EQUAL
