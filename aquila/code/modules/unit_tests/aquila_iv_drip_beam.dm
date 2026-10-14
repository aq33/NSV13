// The upstream assert macros are #undef'd at the end of code/modules/unit_tests/_unit_tests.dm, so this modular test carries its own copies
#define TEST_ASSERT(assertion, reason) if (!(assertion)) { return Fail("Assertion failed: [reason || "No reason"]") }

/// AQUILA - IV drip tube and tug (tgstation#88217)
/datum/unit_test/aquila_iv_drip_beam

/datum/unit_test/aquila_iv_drip_beam/Run()
	var/mob/living/carbon/human/patient = allocate(/mob/living/carbon/human)
	var/obj/machinery/iv_drip/drip = allocate(/obj/machinery/iv_drip, get_step(patient, EAST))
	var/start_x = patient.pixel_x

	drip.attached = patient
	drip.update_icon()
	TEST_ASSERT(drip.attachment, "Attaching the drip made no attachment")
	TEST_ASSERT(patient.GetComponent(/datum/component/tug_towards), "The patient is not tugged towards the drip")
	TEST_ASSERT(patient.pixel_x > start_x, "The patient was not pulled towards the drip")

	drip.attached = null
	drip.update_icon()
	TEST_ASSERT(!drip.attachment, "Detaching the drip left the attachment")
	TEST_ASSERT(!patient.GetComponent(/datum/component/tug_towards), "The patient is still tugged after detaching")
	TEST_ASSERT(patient.pixel_x == start_x, "The patient was not put back after detaching")

#undef TEST_ASSERT
