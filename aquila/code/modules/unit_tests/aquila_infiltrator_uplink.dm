// The upstream assert macros are #undef'd at the end of code/modules/unit_tests/_unit_tests.dm, so this modular test carries its own copy
#define TEST_ASSERT(assertion, reason) if (!(assertion)) { return Fail("Assertion failed: [reason || "No reason"]") }

/// AQUILA - infiltrator uplink restrictions only strip UPLINK_INFILTRATORS and never widen what core allows for other uplinks
/datum/unit_test/aquila_infiltrator_uplink

/datum/unit_test/aquila_infiltrator_uplink/Run()
	// Infiltrator-only gear
	var/datum/uplink_item/manifest = new /datum/uplink_item/services/manifest_spoof
	TEST_ASSERT(manifest.purchasable_from & UPLINK_INFILTRATORS, "Infiltrators can't buy the crew manifest spoof")
	TEST_ASSERT(!(manifest.purchasable_from & UPLINK_TRAITORS), "Traitors can buy the crew manifest spoof")
	var/datum/uplink_item/access_kit = new /datum/uplink_item/infiltration/access_kit
	TEST_ASSERT(access_kit.purchasable_from & UPLINK_INFILTRATORS, "Infiltrators can't buy the access kit")

	// Murderbone gear is excluded for infiltrators, but still available to traitors
	var/datum/uplink_item/sword = new /datum/uplink_item/dangerous/sword
	TEST_ASSERT(!(sword.purchasable_from & UPLINK_INFILTRATORS), "Infiltrators can buy an energy sword")
	TEST_ASSERT(sword.purchasable_from & UPLINK_TRAITORS, "Traitors can't buy an energy sword")
	TEST_ASSERT(!(sword.purchasable_from & UPLINK_CLOWN_OPS), "Infiltrator exclusion unlocked the energy sword for clown ops")

	var/datum/uplink_item/guardian = new /datum/uplink_item/dangerous/guardian
	TEST_ASSERT(!(guardian.purchasable_from & UPLINK_INFILTRATORS), "Infiltrators can buy holoparasites")
	TEST_ASSERT(!(guardian.purchasable_from & UPLINK_NUKE_OPS), "Infiltrator exclusion unlocked holoparasites for nuke ops")

	var/datum/uplink_item/c4 = new /datum/uplink_item/explosives/c4
	TEST_ASSERT(!(c4.purchasable_from & UPLINK_INFILTRATORS), "Infiltrators can buy explosives")

	// The implant uplink has to use the infiltrator flag
	var/obj/item/implant/infiltrator/implant = allocate(/obj/item/implant/infiltrator)
	TEST_ASSERT(implant.uplink.uplink_flag == UPLINK_INFILTRATORS, "Infiltrator implant uplink doesn't use UPLINK_INFILTRATORS")

	qdel(manifest)
	qdel(access_kit)
	qdel(sword)
	qdel(guardian)
	qdel(c4)

#undef TEST_ASSERT
