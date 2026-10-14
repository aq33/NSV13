// The upstream assert macros are #undef'd at the end of code/modules/unit_tests/_unit_tests.dm, so this modular test carries its own copies
#define TEST_ASSERT(assertion, reason) if (!(assertion)) { return Fail("Assertion failed: [reason || "No reason"]") }

/// AQUILA - every surgery gets a picture in the radial surgery menu
/datum/unit_test/aquila_surgery_radial

/datum/unit_test/aquila_surgery_radial/Run()
	var/obj/item/surgical_drapes/drapes = allocate(/obj/item/surgical_drapes)
	var/datum/component/surgery_initiator/initiator = drapes.GetComponent(/datum/component/surgery_initiator)
	TEST_ASSERT(initiator, "Surgical drapes have no surgery initiator")
	for(var/datum/surgery/surgery as anything in GLOB.surgeries_list)
		var/image/picture = initiator.get_surgery_radial_image(surgery)
		TEST_ASSERT(istype(picture) && picture.icon, "[surgery.type] has no radial picture")

#undef TEST_ASSERT
