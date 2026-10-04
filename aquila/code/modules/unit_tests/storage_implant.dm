// The upstream assert macros are #undef'd at the end of code/modules/unit_tests/_unit_tests.dm, so this modular test carries its own copies
#define TEST_ASSERT(assertion, reason) if (!(assertion)) { return Fail("Assertion failed: [reason || "No reason"]") }

#define TEST_ASSERT_EQUAL(a, b, message) do { \
	var/lhs = ##a; \
	var/rhs = ##b; \
	if (lhs != rhs) { \
		return Fail("Expected [isnull(lhs) ? "null" : lhs] to be equal to [isnull(rhs) ? "null" : rhs].[message ? " [message]" : ""]"); \
	} \
} while (FALSE)

/// AQUILA - deleting a human with a storage implant drops the contents without runtiming on its missing bodyparts
/datum/unit_test/storage_implant_deletion

/datum/unit_test/storage_implant_deletion/Run()
	var/mob/living/carbon/human/host = allocate(/mob/living/carbon/human)
	var/turf/host_turf = get_turf(host)
	var/obj/item/implant/storage/imp = allocate(/obj/item/implant/storage, host)
	TEST_ASSERT(imp.implant(host, null, TRUE), "Storage implant could not be implanted")
	var/obj/item/pen/stored = allocate(/obj/item/pen)
	TEST_ASSERT(SEND_SIGNAL(imp, COMSIG_TRY_STORAGE_INSERT, stored, null, TRUE, TRUE), "Item could not be put into the storage implant")

	var/runtimes_before = GLOB.total_runtimes
	qdel(host)
	TEST_ASSERT_EQUAL(GLOB.total_runtimes, runtimes_before, "Runtimes while deleting a human with a storage implant")
	TEST_ASSERT(QDELETED(imp), "Storage implant survived its implantee")
	TEST_ASSERT(!QDELETED(stored), "Stored item was deleted with the implantee")
	TEST_ASSERT_EQUAL(stored.loc, host_turf, "Stored item was not dropped where the implantee was")

/// AQUILA - removing a storage implant from a living human still spills its contents and hurts the chest
/datum/unit_test/storage_implant_removal

/datum/unit_test/storage_implant_removal/Run()
	var/mob/living/carbon/human/host = allocate(/mob/living/carbon/human)
	var/obj/item/implant/storage/imp = allocate(/obj/item/implant/storage, host)
	TEST_ASSERT(imp.implant(host, null, TRUE), "Storage implant could not be implanted")
	var/obj/item/pen/stored = allocate(/obj/item/pen)
	TEST_ASSERT(SEND_SIGNAL(imp, COMSIG_TRY_STORAGE_INSERT, stored, null, TRUE, TRUE), "Item could not be put into the storage implant")

	imp.removed(host)
	TEST_ASSERT_EQUAL(stored.loc, get_turf(host), "Stored item was not spilled on removal")
	TEST_ASSERT_EQUAL(host.getBruteLoss(), 20, "Removal did not rupture the chest")
	TEST_ASSERT(!(imp in host.implants), "Implant still listed after removal")

#undef TEST_ASSERT
#undef TEST_ASSERT_EQUAL
