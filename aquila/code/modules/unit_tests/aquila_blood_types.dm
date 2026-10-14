// The upstream assert macros are #undef'd at the end of code/modules/unit_tests/_unit_tests.dm, so this modular test carries its own copies
#define TEST_ASSERT(assertion, reason) if (!(assertion)) { return Fail("Assertion failed: [reason || "No reason"]") }

#define TEST_ASSERT_EQUAL(a, b, message) do { \
	var/lhs = ##a; \
	var/rhs = ##b; \
	if (lhs != rhs) { \
		return Fail("Expected [isnull(lhs) ? "null" : lhs] to be equal to [isnull(rhs) ? "null" : rhs].[message ? " [message]" : ""]"); \
	} \
} while (FALSE)

/// AQUILA - blood type datums and species blood colours (BeeStation #13410)
/datum/unit_test/aquila_blood_types

/datum/unit_test/aquila_blood_types/Run()
	// Compatibility keeps the old table
	var/list/safe = get_safe_blood("A+")
	TEST_ASSERT("O-" in safe, "A+ cannot take O-")
	TEST_ASSERT(!("B+" in safe), "A+ can take B+")
	TEST_ASSERT_EQUAL(length(get_safe_blood("O-")), 1, "O- should only take O-")
	TEST_ASSERT("L" in get_safe_blood("U"), "Universal blood type cannot take lizard blood")
	TEST_ASSERT(!length(get_safe_blood("nonsense")), "Unknown blood type is compatible with something")

	// Every random human blood type has a datum
	for(var/i in 1 to 20)
		TEST_ASSERT(get_blood_type(random_blood_type()), "random_blood_type() gave a type without a datum")

	// Species colours
	var/mob/living/carbon/human/lizard = allocate(/mob/living/carbon/human)
	lizard.set_species(/datum/species/lizard)
	TEST_ASSERT_EQUAL(lizard.dna.blood_type, "L", "Lizards don't have L blood")
	TEST_ASSERT_EQUAL(lizard.get_blood_color(), "#009696", "Lizard blood is not teal")

	var/mob/living/carbon/human/ipc = allocate(/mob/living/carbon/human)
	ipc.set_species(/datum/species/ipc)
	TEST_ASSERT_EQUAL(ipc.dna.blood_type, "Coolant", "IPCs don't use coolant")
	TEST_ASSERT_EQUAL(ipc.get_blood_id(), /datum/reagent/blood, "IPC coolant is not a blood reagent")

	var/mob/living/carbon/human/ethereal = allocate(/mob/living/carbon/human)
	ethereal.set_species(/datum/species/ethereal)
	TEST_ASSERT_EQUAL(ethereal.dna.blood_type, "E", "Ethereals don't have E blood")
	var/datum/blood_type/ethereal_blood = get_blood_type("E")
	TEST_ASSERT(ethereal_blood?.glowy, "Ethereal blood does not glow")

	// Blood decals take the colour of the newest blood on them
	var/obj/effect/decal/cleanable/blood/splat = allocate(/obj/effect/decal/cleanable/blood)
	TEST_ASSERT_EQUAL(lowertext(splat.color), lowertext(COLOR_BLOOD), "Default blood is not red")
	splat.add_blood_DNA(lizard.get_blood_dna_list())
	TEST_ASSERT_EQUAL(lowertext(splat.color), "#009696", "Lizard blood did not turn the decal teal")

	// Blood reagents too
	var/list/blood_data = lizard.get_blood_data(/datum/reagent/blood)
	var/datum/reagent/blood/blood_reagent = new
	blood_reagent.on_new(blood_data)
	TEST_ASSERT_EQUAL(blood_reagent.color, "#009696", "Lizard blood reagent is not teal")
	qdel(blood_reagent)

#undef TEST_ASSERT
#undef TEST_ASSERT_EQUAL
