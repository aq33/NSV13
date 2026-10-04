// The upstream assert macros are #undef'd at the end of code/modules/unit_tests/_unit_tests.dm, so this modular test carries its own copies
#define TEST_ASSERT(assertion, reason) if (!(assertion)) { return Fail("Assertion failed: [reason || "No reason"]") }

#define TEST_ASSERT_EQUAL(a, b, message) do { \
	var/lhs = ##a; \
	var/rhs = ##b; \
	if (lhs != rhs) { \
		return Fail("Expected [isnull(lhs) ? "null" : lhs] to be equal to [isnull(rhs) ? "null" : rhs].[message ? " [message]" : ""]"); \
	} \
} while (FALSE)

#define TEST_STARMAP "config/starmap/unit_test_campaign.json"
#define TEST_PREFIX "unit_test_campaign"
// CI runs from a deployed folder without the real config/starmap/, so the test brings its own default
#define DEFAULT_STARMAP "config/starmap/unit_test_campaign_default.json"

/// AQUILA - Hard Restart + New Campaign: reset to the default, shutdown save blocking, safe aborts, database untouched
/datum/unit_test/campaign_reset

/datum/unit_test/campaign_reset/Run()
	cleanup()
	var/db_connected = SSdbcore.IsConnected()
	var/db_connection = SSdbcore.connection
	var/list/starmap_files = flist("config/starmap/")
	var/campaign = "\[{\"name\":\"Unit Test Campaign\"}\]"
	var/clean = "\[{\"name\":\"Unit Test Default 1\"},{\"name\":\"Unit Test Default 2\"}\]"
	rustg_file_write(clean, DEFAULT_STARMAP)
	TEST_ASSERT_EQUAL(rustg_file_read(DEFAULT_STARMAP), clean, "Couldn't write the test default starmap")

	// Path checks: only JSON files under config/starmap/
	TEST_ASSERT_EQUAL(campaign_starmap_path(TEST_STARMAP), TEST_STARMAP, "A valid starmap path was rejected")
	TEST_ASSERT(!campaign_starmap_path("config/game_options.txt"), "A non-starmap path was accepted")
	TEST_ASSERT(!campaign_starmap_path("data/starmap.json"), "A starmap outside config/starmap/ was accepted")

	// Success: the active file is the clean default, and no extra file is left behind
	rustg_file_write(campaign, TEST_STARMAP)
	var/list/result = reset_campaign_starmap(TEST_STARMAP, DEFAULT_STARMAP)
	TEST_ASSERT(result["success"], "Reset failed: [result["error"]]")
	TEST_ASSERT_EQUAL(rustg_file_read(TEST_STARMAP), clean, "The starmap wasn't replaced by the default")
	TEST_ASSERT_EQUAL(length(flist("config/starmap/")), length(starmap_files) + 2, "The reset created extra files")
	// What the next round loads (instantiate_systems reads this file) is the clean default campaign
	var/list/loaded = json_decode(rustg_file_read(TEST_STARMAP))
	var/list/default_systems = json_decode(clean)
	TEST_ASSERT_EQUAL(length(loaded), length(default_systems), "The reset starmap doesn't load as the default campaign")

	// While a reset is pending, the shutdown save can't write the old in-memory campaign back
	SSstar_system.campaign_reset_pending = TRUE
	var/blocked = SSstar_system.save(TEST_STARMAP)
	SSstar_system.campaign_reset_pending = FALSE
	TEST_ASSERT_EQUAL(blocked, 1, "save() didn't report the blocked save")
	TEST_ASSERT_EQUAL(rustg_file_read(TEST_STARMAP), clean, "save() overwrote the reset starmap")

	// An ordinary restart still saves the campaign
	TEST_ASSERT_EQUAL(SSstar_system.save(TEST_STARMAP), 0, "An ordinary save failed")
	var/saved = rustg_file_read(TEST_STARMAP)
	TEST_ASSERT(length(saved) && saved != clean, "An ordinary save didn't write the current campaign")

	// Failures abort and keep the campaign: missing default, default as the active map, bad path
	rustg_file_write(campaign, TEST_STARMAP)
	var/list/before = flist("config/starmap/")
	result = reset_campaign_starmap(TEST_STARMAP, "config/starmap/unit_test_missing_default.json")
	TEST_ASSERT(!result["success"] && result["error"], "A reset with no default starmap succeeded")
	TEST_ASSERT_EQUAL(rustg_file_read(TEST_STARMAP), campaign, "A failed reset changed the campaign")
	TEST_ASSERT_EQUAL(length(flist("config/starmap/")), length(before), "A failed reset left files behind")
	result = reset_campaign_starmap(DEFAULT_STARMAP, DEFAULT_STARMAP)
	TEST_ASSERT(!result["success"], "Resetting the default starmap onto itself succeeded")
	TEST_ASSERT_EQUAL(rustg_file_read(DEFAULT_STARMAP), clean, "The default starmap was changed")
	result = reset_campaign_starmap("config/game_options.txt", DEFAULT_STARMAP)
	TEST_ASSERT(!result["success"], "A reset outside config/starmap/ succeeded")
	TEST_ASSERT(!SSstar_system.campaign_reset_pending, "A failed reset left saving blocked")

	// No starmap saved yet (fresh server): nothing to back up, the default is put in place
	fdel(TEST_STARMAP)
	result = reset_campaign_starmap(TEST_STARMAP, DEFAULT_STARMAP)
	TEST_ASSERT(result["success"], "A reset with no saved starmap failed")
	TEST_ASSERT_EQUAL(rustg_file_read(TEST_STARMAP), clean, "A fresh reset didn't write the default")

	// Only starmap test files were created, and the database was never touched
	cleanup()
	TEST_ASSERT_EQUAL(length(flist("config/starmap/")), length(starmap_files), "The reset left files in config/starmap/")
	TEST_ASSERT_EQUAL(SSdbcore.IsConnected(), db_connected, "The database connection state changed")
	TEST_ASSERT_EQUAL(SSdbcore.connection, db_connection, "The database connection changed")

/datum/unit_test/campaign_reset/Destroy()
	cleanup()
	SSstar_system.campaign_reset_pending = FALSE
	return ..()

/datum/unit_test/campaign_reset/proc/cleanup()
	for(var/F in flist("config/starmap/"))
		if(findtext(F, TEST_PREFIX) == 1)
			fdel("config/starmap/[F]")

#undef TEST_STARMAP
#undef TEST_PREFIX
#undef DEFAULT_STARMAP
#undef TEST_ASSERT
#undef TEST_ASSERT_EQUAL
