// The upstream assert macros are #undef'd at the end of code/modules/unit_tests/_unit_tests.dm, so this modular test carries its own copies
#define TEST_ASSERT(assertion, reason) if (!(assertion)) { return Fail("Assertion failed: [reason || "No reason"]") }

/// AQUILA - the vampire and hijacked AI antag HUDs point at real antag HUDs in GLOB.huds, not past its end or at the NSV13 squad HUD
/datum/unit_test/aquila_antag_huds

/datum/unit_test/aquila_antag_huds/Run()
	TEST_ASSERT(ANTAG_HUD_VAMPIRE <= length(GLOB.huds), "ANTAG_HUD_VAMPIRE ([ANTAG_HUD_VAMPIRE]) is past the end of GLOB.huds ([length(GLOB.huds)])")
	var/datum/atom_hud/antag/vamphud = GLOB.huds[ANTAG_HUD_VAMPIRE]
	TEST_ASSERT(istype(vamphud, /datum/atom_hud/antag/hidden), "GLOB.huds\[ANTAG_HUD_VAMPIRE\] is [vamphud?.type || "null"], not the vampire antag HUD")
	TEST_ASSERT(vamphud != GLOB.huds[DATA_HUD_SQUAD], "The vampire HUD is the NSV13 squad HUD")
	var/datum/atom_hud/antag/synd_hud = GLOB.huds[ANTAG_HUD_OPS]
	TEST_ASSERT(istype(synd_hud, /datum/atom_hud/antag), "GLOB.huds\[ANTAG_HUD_OPS\] is [synd_hud?.type || "null"]")

	var/runtimes_before = GLOB.total_runtimes
	// Mobs get a mind that is not registered with the ticker, the HUD procs only need mob.mind
	var/mob/living/carbon/human/vampire = allocate(/mob/living/carbon/human)
	var/datum/mind/vampire_mind = new("aquila_antag_huds_vampire")
	vampire_mind.current = vampire
	vampire.mind = vampire_mind
	SSticker.mode.update_vampire_icons_added(vampire_mind)
	var/joined = (vampire in vamphud.hudatoms) && vampire_mind.antag_hud == vamphud
	SSticker.mode.update_vampire_icons_removed(vampire_mind)
	var/left = !(vampire in vamphud.hudatoms) && !vampire_mind.antag_hud
	TEST_ASSERT(joined, "A vampire did not join the vampire HUD")
	TEST_ASSERT(left, "A vampire stayed in the vampire HUD after losing it")

	var/mob/living/carbon/human/hijacked = allocate(/mob/living/carbon/human)
	var/datum/mind/hijacked_mind = new("aquila_antag_huds_hijacked")
	hijacked_mind.current = hijacked
	hijacked.mind = hijacked_mind
	var/datum/antagonist/hijacked_ai/hijack = new
	hijack.update_synd_icons_added(hijacked)
	joined = (hijacked in synd_hud.hudatoms) && synd_hud.hudusers[hijacked]
	hijack.update_synd_icons_removed(hijacked)
	left = !(hijacked in synd_hud.hudatoms) && !synd_hud.hudusers[hijacked]
	qdel(hijack)
	TEST_ASSERT(joined, "A hijacked AI did not join the syndicate HUD")
	TEST_ASSERT(left, "A hijacked AI stayed in the syndicate HUD after losing it")

	TEST_ASSERT(GLOB.total_runtimes == runtimes_before, "[GLOB.total_runtimes - runtimes_before] runtimes while joining and leaving the antag HUDs")

/datum/unit_test/aquila_antag_huds/Destroy()
	// The test minds are not owned by the ticker, drop them with their mobs
	for(var/mob/living/carbon/human/test_mob in allocated)
		var/datum/mind/test_mind = test_mob.mind
		if(test_mind)
			test_mob.mind = null
			test_mind.current = null
			qdel(test_mind)
	return ..()

#undef TEST_ASSERT
