// The upstream assert macros are #undef'd at the end of code/modules/unit_tests/_unit_tests.dm, so this modular test carries its own copies
#define TEST_ASSERT(assertion, reason) if (!(assertion)) { return Fail("Assertion failed: [reason || "No reason"]") }

/// AQUILA - BeeStation#8776: the PreferencesMenu window works on our preferences data
/datum/unit_test/aquila_preferences_menu

/datum/unit_test/aquila_preferences_menu/Run()
	// Every entry has a unique key and storage
	var/list/seen_keys = list()
	for(var/preference_type in GLOB.preference_entries)
		var/datum/preference/preference = GLOB.preference_entries[preference_type]
		TEST_ASSERT(preference.db_key, "[preference_type] has no db_key")
		TEST_ASSERT(!seen_keys[preference.db_key], "[preference.db_key] is used twice")
		seen_keys[preference.db_key] = TRUE

	// Constant window data
	var/datum/asset/json/preferences/json_asset = get_asset_datum(/datum/asset/json/preferences)
	var/list/constant_data = json_asset.generate()
	for(var/key in list("species", "jobs", "quirks", "loadout", "antags", "names", "random", "hair_style_name", "underwear", "skin_tone"))
		TEST_ASSERT(constant_data[key], "preferences.json has no [key]")
	var/list/jobs = constant_data["jobs"]
	TEST_ASSERT(jobs["departments"]["Munitions"], "The Munitions department is missing")
	TEST_ASSERT(jobs["jobs"][JOB_NAME_PILOT]["department"] == "Munitions", "Pilots are not in Munitions")
	var/list/species = constant_data["species"]
	TEST_ASSERT("hair_style_name" in species[SPECIES_HUMAN]["enabled_features"], "Humans cannot pick hair")
	TEST_ASSERT("feature_lizard_tail" in species[SPECIES_LIZARD]["enabled_features"], "Lizards cannot pick a tail")
	TEST_ASSERT(!("feature_lizard_tail" in species[SPECIES_HUMAN]["enabled_features"]), "Humans can pick a lizard tail")

	// Icons
	var/datum/asset/spritesheet/preferences/sheet = get_asset_datum(/datum/asset/spritesheet/preferences)
	TEST_ASSERT(sheet.sprites["backbag___[sanitize_css_class_name(DBACKPACK)]"], "No backpack icon")
	var/datum/asset/spritesheet/preferences/huge/huge_sheet = get_asset_datum(/datum/asset/spritesheet/preferences/huge)
	TEST_ASSERT(length(huge_sheet.sprites) >= length(GLOB.hair_styles_list) / 2, "Missing hairstyle icons")
	var/datum/asset/spritesheet/antagonists/antag_sheet = get_asset_datum(/datum/asset/spritesheet/antagonists)
	TEST_ASSERT(antag_sheet.sprites[serialize_antag_name("[/datum/role_preference/antagonist/traitor]")], "No traitor icon")
	// Every role has an icon in its sheet (one BYOND icon cannot hold all of them)
	for(var/pref_type in GLOB.role_preference_entries)
		var/sheet_name = antag_icon_sheet(pref_type)
		var/datum/asset/spritesheet/role_sheet
		for(var/sheet_type in typesof(/datum/asset/spritesheet/antagonists))
			var/datum/asset/spritesheet/candidate = get_asset_datum(sheet_type)
			if(candidate.name == sheet_name)
				role_sheet = candidate
		TEST_ASSERT(role_sheet?.sprites[serialize_antag_name("[pref_type]")], "No icon for [pref_type] in [sheet_name]")
	var/datum/asset/spritesheet/species/species_sheet = get_asset_datum(/datum/asset/spritesheet/species)
	for(var/species_id in GLOB.roundstart_races)
		TEST_ASSERT(species_sheet.sprites[sanitize_css_class_name(species_id)], "No species icon for [species_id]")

	// A preferences datum without a client (no database in tests)
	var/datum/preferences/prefs = new(null)
	TEST_ASSERT(prefs.active_character, "No active character")
	prefs.current_window = PREFERENCE_TAB_CHARACTER_PREFERENCES
	var/list/compiled = prefs.compile_character_preferences(null)
	TEST_ASSERT(compiled[PREFERENCE_CATEGORY_MISC]["species"] == prefs.active_character.pref_species.id, "Species is not sent")
	TEST_ASSERT(compiled[PREFERENCE_CATEGORY_NAMES]["real_name"] == prefs.active_character.real_name, "Name is not sent")
	TEST_ASSERT(!(("ghost_form") in compiled[PREFERENCE_CATEGORY_GAME_PREFERENCES]), "Game preferences leak into the character page")

	// Character values land in active_character
	TEST_ASSERT(prefs.update_preference(GLOB.preference_entries[/datum/preference/numeric/age], 40), "Age was rejected")
	TEST_ASSERT(prefs.active_character.age == 40, "Age is [prefs.active_character.age]")
	TEST_ASSERT(!prefs.update_preference(GLOB.preference_entries[/datum/preference/choiced/backpack], "Not a backpack"), "An invalid backpack was accepted")
	prefs.update_preference(GLOB.preference_entries[/datum/preference/choiced/species], SPECIES_HUMAN)
	TEST_ASSERT(prefs.update_preference(GLOB.preference_entries[/datum/preference/color/hair_color], "#123456"), "Hair color was rejected")
	TEST_ASSERT(prefs.active_character.hair_color == "123456", "Hair color is [prefs.active_character.hair_color]")
	TEST_ASSERT(prefs.update_preference(GLOB.preference_entries[/datum/preference/choiced/species], SPECIES_LIZARD), "Species change was rejected")
	TEST_ASSERT(istype(prefs.active_character.pref_species, /datum/species/lizard), "Species did not change")
	TEST_ASSERT(prefs.update_preference(GLOB.preference_entries[/datum/preference/choiced/species_feature/lizard_tail], "Dark Tiger"), "Tail was rejected")
	TEST_ASSERT(prefs.active_character.features["tail_lizard"] == "Dark Tiger", "Tail is [prefs.active_character.features["tail_lizard"]]")
	TEST_ASSERT(prefs.update_preference(GLOB.preference_entries[/datum/preference/choiced/gender], MALE), "Gender was rejected")
	TEST_ASSERT(prefs.update_preference(GLOB.preference_entries[/datum/preference/choiced/gender], FEMALE), "Gender was rejected")
	TEST_ASSERT(prefs.active_character.features["body_model"] == FEMALE, "Body model did not follow gender")
	TEST_ASSERT(prefs.update_preference(GLOB.preference_entries[/datum/preference/choiced/random_toggle/body], RANDOM_ENABLED), "Random body was rejected")
	TEST_ASSERT(prefs.active_character.be_random_body, "Random body is off")

	// Player values land in our toggles
	TEST_ASSERT(prefs.update_preference(GLOB.preference_entries[/datum/preference/toggle/player/death_rattle], FALSE), "Death rattle was rejected")
	TEST_ASSERT(prefs.toggles & PREFTOGGLE_DISABLE_DEATHRATTLE, "Inverted toggle did not set the disable bit")
	TEST_ASSERT(prefs.update_preference(GLOB.preference_entries[/datum/preference/toggle/player/tgui_input], FALSE), "TGUI input was rejected")
	TEST_ASSERT(!(prefs.toggles2 & PREFTOGGLE_2_TGUI_INPUT), "TGUI input bit is still set")
	TEST_ASSERT(prefs.update_preference(GLOB.preference_entries[/datum/preference/choiced/parallax], "Low"), "Parallax was rejected")
	TEST_ASSERT(prefs.parallax == PARALLAX_LOW, "Parallax is [prefs.parallax]")
	TEST_ASSERT(prefs.update_preference(GLOB.preference_entries[/datum/preference/choiced/ghost_named/others], GHOST_OTHERS_SIMPLE_NAME), "Ghost others was rejected")
	TEST_ASSERT(prefs.ghost_others == GHOST_OTHERS_SIMPLE, "Ghost others is [prefs.ghost_others]")

	// Keybindings: the window sends name -> keys, we keep key -> names
	var/datum/preference_middleware/keybindings/keybindings = new(prefs)
	var/kb_name = GLOB.keybindings_by_name[1]
	keybindings.set_keybindings(list("keybind_name" = kb_name, "hotkeys" = list("Ctrl-Shift-K")), null)
	TEST_ASSERT(kb_name in prefs.key_bindings["Ctrl-Shift-K"], "Keybinding was not stored by key")
	prefs.current_window = PREFERENCE_TAB_GAME_PREFERENCES
	var/list/by_name = keybindings.get_ui_static_data(null)["keybindings"]
	TEST_ASSERT(by_name[kb_name] ~= list("Ctrl-Shift-K"), "Keybinding [kb_name] is sent as [json_encode(by_name[kb_name])], stored [json_encode(prefs.key_bindings)]")
	qdel(keybindings)

	qdel(prefs)

#undef TEST_ASSERT
