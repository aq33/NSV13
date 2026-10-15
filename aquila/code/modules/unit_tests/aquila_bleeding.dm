// The upstream assert macros are #undef'd at the end of code/modules/unit_tests/_unit_tests.dm, so this modular test carries its own copies
#define TEST_ASSERT(assertion, reason) if (!(assertion)) { return Fail("Assertion failed: [reason || "No reason"]") }

#define TEST_ASSERT_EQUAL(a, b, message) do { \
	var/lhs = ##a; \
	var/rhs = ##b; \
	if (lhs != rhs) { \
		return Fail("Expected [isnull(lhs) ? "null" : lhs] to be equal to [isnull(rhs) ? "null" : rhs].[message ? " [message]" : ""]"); \
	} \
} while (FALSE)

/// AQUILA - BeeStation bleeding port (BeeStation #10372): bleeding status effect, bandaging, cauterising, armour
/datum/unit_test/aquila_bleeding

/datum/unit_test/aquila_bleeding/Run()
	var/mob/living/carbon/human/patient = allocate(/mob/living/carbon/human)
	TEST_ASSERT(!patient.is_bleeding(), "A fresh human is bleeding")

	// A deep wound starts the bleeding status effect and drains blood
	patient.add_bleeding(BLEED_DEEP_WOUND)
	TEST_ASSERT(patient.is_bleeding(), "add_bleeding() did not start bleeding")
	TEST_ASSERT_EQUAL(patient.get_bleed_rate(), BLEED_DEEP_WOUND, "Wrong bleed rate")
	var/datum/status_effect/bleeding/bleed = patient.has_status_effect(STATUS_EFFECT_BLEED)
	TEST_ASSERT(bleed, "No bleeding status effect")
	var/blood_before = patient.blood_volume
	bleed.tick()
	TEST_ASSERT(patient.blood_volume < blood_before, "Bleeding did not drain any blood")

	// A second wound merges into the same effect and raises the rate
	patient.add_bleeding(BLEED_SURFACE)
	TEST_ASSERT_EQUAL(patient.has_status_effect(STATUS_EFFECT_BLEED), bleed, "A second wound made a second effect")
	TEST_ASSERT(patient.get_bleed_rate() > BLEED_DEEP_WOUND, "A second wound did not raise the bleed rate")

	// Bandaging turns all of it into bandaged bleeding, which loses no blood
	patient.suppress_bloodloss(BLEED_CRITICAL * 2)
	TEST_ASSERT(!patient.is_bleeding(), "Bandage did not stop the bleeding")
	TEST_ASSERT(patient.is_bandaged(), "Bandaged bleeding not tracked")
	blood_before = patient.blood_volume
	bleed.tick()
	TEST_ASSERT_EQUAL(patient.blood_volume, blood_before, "Bandaged wounds still drain blood")

	// Cauterising removes the effect entirely
	patient.add_bleeding(BLEED_CUT)
	patient.cauterise_wounds()
	TEST_ASSERT(!patient.has_status_effect(STATUS_EFFECT_BLEED), "Cauterising left the bleeding effect")

	// Bleeding armour: an armour list with "bleed" keeps the value through getArmor()
	var/datum/armor/armour = getArmor(arglist(list("melee" = 10, "bleed" = 50)))
	TEST_ASSERT_EQUAL(armour.bleed, 50, "Armour lost the bleed value")
	TEST_ASSERT_EQUAL(armour.getList()["bleed"], 50, "Armour list has no bleed entry")

	// Robots leak instead of bleed
	var/mob/living/carbon/human/ipc = allocate(/mob/living/carbon/human)
	ipc.set_species(/datum/species/ipc)
	ipc.add_bleeding(BLEED_CUT)
	TEST_ASSERT(ipc.has_status_effect(/datum/status_effect/bleeding/robotic), "IPC bleeding is not the robotic leak")

#undef TEST_ASSERT
#undef TEST_ASSERT_EQUAL
