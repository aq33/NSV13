// The upstream assert macros are #undef'd at the end of code/modules/unit_tests/_unit_tests.dm, so this modular test carries its own copies
#define TEST_ASSERT_EQUAL(a, b, message) do { \
	var/lhs = ##a; \
	var/rhs = ##b; \
	if (lhs != rhs) { \
		return Fail("Expected [isnull(lhs) ? "null" : lhs] to be equal to [isnull(rhs) ? "null" : rhs].[message ? " [message]" : ""]"); \
	} \
} while (FALSE)

/// AQUILA - the Create Antagonist panel gets exactly the old Aquila buttons appended (core one_click_antag() hook)
/datum/unit_test/aquila_one_click_antag_links

/datum/unit_test/aquila_one_click_antag_links/Run()
	var/datum/admin_rank/rank = new("AquilaUnitTest", 0)
	var/datum/admins/holder = new(rank, "aquilaunittestadmin")
	var/links = holder.aquila_one_click_antag_links()
	// Same text the old full-copy override had after the upstream buttons
	var/expected = {"<a href='?src=[REF(holder)];[HrefToken()];makeAntag=infiltrator'>Make Infiltration Team (Requires Ghosts)</a>
		<a href='?src=[REF(holder)];[HrefToken()];makeAntag=vampire'>Make Vampire</a>
		"}
	GLOB.deadmins -= holder.target
	GLOB.admin_datums -= holder.target
	qdel(holder)
	qdel(rank)
	TEST_ASSERT_EQUAL(links, expected, "Aquila Create Antagonist buttons changed")

#undef TEST_ASSERT_EQUAL
