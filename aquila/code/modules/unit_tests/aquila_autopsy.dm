// The upstream assert macros are #undef'd at the end of code/modules/unit_tests/_unit_tests.dm, so this modular test carries its own copies
#define TEST_ASSERT(assertion, reason) if (!(assertion)) { return Fail("Assertion failed: [reason || "No reason"]") }

/// AQUILA - autopsy surgery and scanner (tgstation coroner)
/datum/unit_test/aquila_autopsy

/datum/unit_test/aquila_autopsy/Run()
	var/mob/living/carbon/human/coroner = allocate(/mob/living/carbon/human)
	var/mob/living/carbon/human/body = allocate(/mob/living/carbon/human)
	var/obj/item/autopsy_scanner/scanner = allocate(/obj/item/autopsy_scanner)
	var/datum/surgery/autopsy/autopsy = new(body, BODY_ZONE_CHEST, body.get_bodypart(BODY_ZONE_CHEST))
	TEST_ASSERT(!autopsy.can_start(coroner, body), "Autopsy can start on a living patient")

	body.reagents.add_reagent(/datum/reagent/toxin, 10)
	body.death()
	TEST_ASSERT(autopsy.can_start(coroner, body), "Autopsy cannot start on a body")

	var/datum/surgery_step/autopsy/step = new
	step.success(coroner, body, BODY_ZONE_CHEST, scanner, autopsy)
	var/obj/item/paper/report = locate() in coroner.held_items
	TEST_ASSERT(report, "Autopsy printed no report")
	TEST_ASSERT(!autopsy.can_start(coroner, body), "The same body can be autopsied twice")

	body.revive(full_heal = TRUE, admin_revive = TRUE)
	body.death()
	TEST_ASSERT(autopsy.can_start(coroner, body), "A revived and dead again body cannot be autopsied")

	qdel(autopsy)
	qdel(step)

#undef TEST_ASSERT
