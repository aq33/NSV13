// The upstream assert macros are #undef'd at the end of code/modules/unit_tests/_unit_tests.dm, so this modular test carries its own copies
#define TEST_ASSERT(assertion, reason) if (!(assertion)) { return Fail("Assertion failed: [reason || "No reason"]") }

/// AQUILA - BeeStation stomach pump and identity recalibration surgeries
/datum/unit_test/aquila_bee_surgeries

/datum/unit_test/aquila_bee_surgeries/Run()
	var/mob/living/carbon/human/surgeon = allocate(/mob/living/carbon/human)
	var/mob/living/carbon/human/patient = allocate(/mob/living/carbon/human)

	// Stomach pump purges most chemicals
	patient.reagents.add_reagent(/datum/reagent/toxin, 30)
	var/datum/surgery/stomach_pump/pump = new(patient, BODY_ZONE_CHEST, patient.get_bodypart(BODY_ZONE_CHEST))
	TEST_ASSERT(pump.can_start(surgeon, patient), "Stomach pump cannot start on a human with a stomach")
	var/datum/surgery_step/stomach_pump/pump_step = new
	pump_step.success(surgeon, patient, BODY_ZONE_CHEST, null, pump)
	TEST_ASSERT(patient.reagents.get_reagent_amount(/datum/reagent/toxin) <= 10, "Stomach pump did not purge the toxin")
	qdel(pump)
	qdel(pump_step)

	// Identity recalibration only works on robotic chests, and renames from the card
	var/datum/surgery/rename/rename = new(patient, BODY_ZONE_CHEST, patient.get_bodypart(BODY_ZONE_CHEST))
	var/obj/item/bodypart/organic_chest = patient.get_bodypart(BODY_ZONE_CHEST)
	TEST_ASSERT(!(organic_chest.bodytype & rename.requires_bodypart_type), "Identity recalibration is offered on an organic chest")
	qdel(rename)

	var/mob/living/carbon/human/ipc = allocate(/mob/living/carbon/human)
	ipc.set_species(/datum/species/ipc)
	rename = new(ipc, BODY_ZONE_CHEST, ipc.get_bodypart(BODY_ZONE_CHEST))
	var/obj/item/bodypart/ipc_chest = ipc.get_bodypart(BODY_ZONE_CHEST)
	TEST_ASSERT((ipc_chest.bodytype & rename.requires_bodypart_type) && rename.can_start(surgeon, ipc), "Identity recalibration cannot start on an IPC")
	var/obj/item/card/id/card = allocate(/obj/item/card/id)
	card.registered_name = "Testowy Robot"
	var/datum/surgery_step/rename/rename_step = new
	TEST_ASSERT(rename_step.success(surgeon, ipc, BODY_ZONE_CHEST, card, rename), "Renaming failed")
	TEST_ASSERT(ipc.real_name == "Testowy Robot", "IPC was not renamed from the card")
	qdel(rename)
	qdel(rename_step)

#undef TEST_ASSERT
