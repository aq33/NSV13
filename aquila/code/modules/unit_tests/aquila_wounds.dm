// The upstream assert macros are #undef'd at the end of code/modules/unit_tests/_unit_tests.dm, so this modular test carries its own copies
#define TEST_ASSERT(assertion, reason) if (!(assertion)) { return Fail("Assertion failed: [reason || "No reason"]") }

/// AQUILA - light wounds: applying, effects, healing
/datum/unit_test/aquila_wounds

/datum/unit_test/aquila_wounds/Run()
	var/mob/living/carbon/human/patient = allocate(/mob/living/carbon/human)
	var/obj/item/bodypart/leg = patient.get_bodypart(BODY_ZONE_L_LEG)

	TEST_ASSERT(!patient.check_wounding(leg, WOUND_MINIMUM_DAMAGE - 1, WOUND_BLUNT), "A scratch caused a wound")

	var/datum/wound/fracture = new /datum/wound/blunt/fracture()
	fracture.apply_wound(leg, silent = TRUE)
	TEST_ASSERT(leg.get_wound(WOUND_BLUNT) == fracture, "The fracture is not on the leg")
	TEST_ASSERT(LAZYACCESS(patient.movespeed_modification, "aq_wounds"), "A broken leg does not slow down")
	TEST_ASSERT(length(patient.get_wound_scan_lines()) == 1, "The analyzer does not see the fracture")

	var/obj/item/stack/medical/gauze/gauze = allocate(/obj/item/stack/medical/gauze)
	TEST_ASSERT(patient.get_treatable_wound(leg, gauze) == fracture, "Gauze cannot splint a fracture")

	var/datum/wound/compound = patient.check_wounding(leg, 200, WOUND_BLUNT)
	if(compound)
		TEST_ASSERT(QDELETED(fracture), "A worse fracture did not replace the old one")
		TEST_ASSERT(length(leg.wounds) == 1, "Two blunt wounds on one leg")

	var/obj/item/bodypart/arm = patient.get_bodypart(BODY_ZONE_R_ARM)
	var/datum/wound/artery = new /datum/wound/slash/artery()
	artery.apply_wound(arm, silent = TRUE)
	TEST_ASSERT(patient.is_bleeding(), "A torn artery does not bleed")
	var/obj/item/stack/medical/suture/suture = allocate(/obj/item/stack/medical/suture)
	TEST_ASSERT(patient.get_treatable_wound(arm, suture) == artery, "Sutures cannot close a torn artery")
	var/datum/wound/sutured = artery.replace_with(/datum/wound/slash/deep)
	TEST_ASSERT(arm.get_wound(WOUND_SLASH) == sutured && QDELETED(artery), "A sutured artery did not become a deep cut")

	var/obj/item/bodypart/chest = patient.get_bodypart(BODY_ZONE_CHEST)
	var/datum/wound/burn/burn = new /datum/wound/burn/third_degree()
	burn.apply_wound(chest, silent = TRUE)
	burn.wound_effects(100)
	TEST_ASSERT(patient.getToxLoss() > 0, "An infected burn does not poison")

	patient.fully_heal()
	TEST_ASSERT(!length(leg.wounds) && !length(arm.wounds) && !length(chest.wounds), "Full heal left wounds")
	TEST_ASSERT(!LAZYACCESS(patient.movespeed_modification, "aq_wounds"), "Full heal left the limp")

/// AQUILA - every medkit and the tgstation dressings have a sprite
/datum/unit_test/aquila_medkit_icons

/datum/unit_test/aquila_medkit_icons/Run()
	var/list/types = subtypesof(/obj/item/storage/firstaid) + typesof(/obj/item/stack/medical/suture) + typesof(/obj/item/stack/medical/mesh)
	for(var/obj/item/path as anything in types)
		var/state = initial(path.icon_state)
		var/icon_file = initial(path.icon)
		if(!icon_file || !state)
			continue
		TEST_ASSERT(state in icon_states(icon_file), "[path] has no sprite '[state]' in [icon_file]")

#undef TEST_ASSERT
