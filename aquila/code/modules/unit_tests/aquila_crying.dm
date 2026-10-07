// The upstream assert macros are #undef'd at the end of code/modules/unit_tests/_unit_tests.dm, so this modular test carries its own copies
#define TEST_ASSERT(assertion, reason) if (!(assertion)) { return Fail("Assertion failed: [reason || "No reason"]") }

#define TEST_ASSERT_EQUAL(a, b, message) do { \
	var/lhs = ##a; \
	var/rhs = ##b; \
	if (lhs != rhs) { \
		return Fail("Expected [isnull(lhs) ? "null" : lhs] to be equal to [isnull(rhs) ? "null" : rhs].[message ? " [message]" : ""]"); \
	} \
} while (FALSE)

/// AQUILA - Yogstation#15690 port: *cry shows tears on the face until the timer clears them
/datum/unit_test/aquila_crying

/datum/unit_test/aquila_crying/Run()
	var/mob/living/carbon/human/crier = allocate(/mob/living/carbon/human)
	TEST_ASSERT_EQUAL(length(crier.get_tears_overlays()), 0, "A human who is not crying has tears")

	TEST_ASSERT(crier.emote("cry"), "The cry emote did not run")
	TEST_ASSERT(HAS_TRAIT(crier, TRAIT_CRYING), "Crying did not add TRAIT_CRYING")
	TEST_ASSERT_EQUAL(length(crier.get_tears_overlays()), 1, "A crying human has no tears overlay")

	// No eyes, no tears
	var/obj/item/organ/eyes/eyes = crier.getorganslot(ORGAN_SLOT_EYES)
	eyes.Remove(crier)
	TEST_ASSERT_EQUAL(length(crier.get_tears_overlays()), 0, "A crying human without eyes has tears")
	eyes.Insert(crier)

	// The timer callback clears the trait
	var/datum/emote/living/carbon/human/cry/cry_emote = locate() in GLOB.emote_list["cry"]
	TEST_ASSERT(cry_emote, "The human cry emote is not registered")
	cry_emote.end_visual(crier)
	TEST_ASSERT(!HAS_TRAIT(crier, TRAIT_CRYING), "end_visual() did not remove TRAIT_CRYING")
	TEST_ASSERT_EQUAL(length(crier.get_tears_overlays()), 0, "Tears stayed after crying ended")

#undef TEST_ASSERT
#undef TEST_ASSERT_EQUAL
