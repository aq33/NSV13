// The upstream assert macros are #undef'd at the end of code/modules/unit_tests/_unit_tests.dm, so this modular test carries its own copies
#define TEST_ASSERT(assertion, reason) if (!(assertion)) { return Fail("Assertion failed: [reason || "No reason"]") }

/// AQUILA - stage 4 of the BeeStation UI port: the DM side of the windows taken from Bee
/// sends the data those windows expect.
/datum/unit_test/aquila_bee_windows

/datum/unit_test/aquila_bee_windows/Run()
	// icon_ref_map knows compiled-in .dmi files, DmIcon looks icons up in it
	var/list/icon_map = get_asset_datum(/datum/asset/json/icon_ref_map).generate()
	TEST_ASSERT(length(icon_map) > 100, "icon_ref_map has only [length(icon_map)] icons")
	TEST_ASSERT(icon_map["icons/obj/vending.dmi"], "icon_ref_map does not know icons/obj/vending.dmi")

	// Changelog months come from html/changelogs/archive
	var/datum/changelog/changelog = new
	var/list/changelog_data = changelog.ui_static_data()
	TEST_ASSERT(length(changelog_data["dates"]), "The changelog has no months")
	TEST_ASSERT(findtext(changelog_data["dates"][1], regex(@"^\d{4}-\d{2}$")), "Bad changelog month: [changelog_data["dates"][1]]")
	var/list/parsed = parse_github_changelog("Opis\n:cl: Joker\nadd: Nowa rzecz\nfix: Naprawa\n/:cl:\nkoniec")
	TEST_ASSERT(length(parsed["add"]) == 1 && length(parsed["fix"]) == 1, "The :cl: block was not parsed: [json_encode(parsed)]")

	// Crew manifest: command order and job icons
	var/list/manifest_static = GLOB.crew_manifest_tgui.ui_static_data()
	TEST_ASSERT(manifest_static["command"]["order"][JOB_HUD_CAPTAIN] == 1, "The captain is not first in the command section")
	TEST_ASSERT(manifest_static["order"][JOB_HUD_CAPTAIN], "Jobs have no ordering")

	// Traitor window: codewords and uplink info
	var/mob/living/carbon/human/traitor_mob = allocate(/mob/living/carbon/human)
	traitor_mob.mind_initialize()
	var/datum/antagonist/traitor/traitor = new
	traitor.give_objectives = FALSE
	traitor.should_equip = FALSE
	traitor.silent = TRUE
	traitor_mob.mind.add_antag_datum(traitor)
	TEST_ASSERT(traitor.info_button_ref?.resolve(), "The traitor has no info button")
	var/list/traitor_data = traitor.ui_static_data(traitor_mob)
	TEST_ASSERT(traitor_data["antag_name"] == traitor.name, "Wrong traitor window name")
	TEST_ASSERT(traitor_data["has_codewords"] && length(traitor_data["phrases"]), "The traitor window has no codewords")
	TEST_ASSERT(traitor.ui_name == "AntagInfoTraitor", "Wrong traitor window: [traitor.ui_name]")
	traitor_mob.mind.remove_antag_datum(/datum/antagonist/traitor)
	TEST_ASSERT(!traitor.info_button_ref, "The info button stayed after losing the antag")

	// Language menu: every language is listed with what the speaker can do
	var/datum/language_menu/language_menu = new(traitor_mob.get_language_holder())
	var/list/language_data = language_menu.ui_data(traitor_mob)
	TEST_ASSERT(length(language_data["languages"]) == length(GLOB.all_languages), "The language menu does not list every language")
	var/found_common = FALSE
	var/datum/language/common_type = /datum/language/common
	for(var/list/language in language_data["languages"])
		if(language["name"] == initial(common_type.name))
			found_common = language["can_speak"] && language["can_understand"]
	TEST_ASSERT(found_common, "A human cannot speak Galactic Common according to the language menu")
	qdel(language_menu)

	// Newscaster (BeeStation #7779): channels, articles and the window data
	GLOB.news_network.create_feed_channel("Aquila Test Channel", "Unit Test", "A test channel")
	GLOB.news_network.submit_article("Hello station", "Unit Test", "Aquila Test Channel", null)
	var/datum/feed_channel/test_channel
	for(var/datum/feed_channel/channel as anything in GLOB.news_network.network_channels)
		if(channel.channel_name == "Aquila Test Channel")
			test_channel = channel
	TEST_ASSERT(test_channel, "The feed channel was not created")
	TEST_ASSERT(length(test_channel.messages) == 1, "The article was not posted")
	var/obj/machinery/newscaster/newscaster = allocate(/obj/machinery/newscaster)
	var/list/news_data = newscaster.ui_data(traitor_mob)
	TEST_ASSERT(islist(news_data["channels"]) && length(news_data["channels"]), "The newscaster window has no channels")
	TEST_ASSERT(ispath(/obj/machinery/newscaster/security_unit/north), "Map path /obj/machinery/newscaster/security_unit/north is gone")

#undef TEST_ASSERT
