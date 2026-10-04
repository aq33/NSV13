// The upstream assert macros are #undef'd at the end of code/modules/unit_tests/_unit_tests.dm, so this modular test carries its own copies
#define TEST_ASSERT(assertion, reason) if (!(assertion)) { return Fail("Assertion failed: [reason || "No reason"]") }

/// AQUILA - the paradox clone (tgstation#71141 port) copies its original, gets the right objective and HUD, and hides from the crew
/datum/unit_test/aquila_paradox_clone

/datum/unit_test/aquila_paradox_clone/Run()
	var/runtimes_before = GLOB.total_runtimes
	var/datum/job/assistant = SSjob.GetJob(JOB_NAME_ASSISTANT)
	TEST_ASSERT(assistant, "No [JOB_NAME_ASSISTANT] job to dress the original in")

	// Lizard original, plain copy
	var/mob/living/carbon/human/original = make_original("Paradox Original", /datum/species/lizard, assistant)
	var/mob/living/carbon/human/clone = original.make_full_human_copy(run_loc_floor_top_right)
	allocated += clone
	TEST_ASSERT(clone.real_name == original.real_name, "Clone is named [clone.real_name], not [original.real_name]")
	TEST_ASSERT(clone.dna.species.type == original.dna.species.type, "Clone is a [clone.dna.species.type], not a [original.dna.species.type]")
	TEST_ASSERT(clone.dna.uni_identity == original.dna.uni_identity, "Clone does not share the original's appearance DNA")
	TEST_ASSERT(clone.dna.unique_enzymes == original.dna.unique_enzymes, "Clone does not share the original's enzymes")
	TEST_ASSERT(clone.job == assistant.title, "Clone has job [clone.job || "null"], not [assistant.title]")
	TEST_ASSERT(istype(clone.w_uniform, /obj/item/clothing/under), "Clone was not dressed in the original's job outfit")

	// The antagonist itself
	var/datum/mind/clone_mind = new("aquila_paradox_clone")
	clone_mind.current = clone
	clone.mind = clone_mind
	var/datum/antagonist/paradox_clone/clone_datum = clone_mind.add_antag_datum(/datum/antagonist/paradox_clone)
	TEST_ASSERT(istype(clone_datum), "add_antag_datum did not return a paradox clone datum")
	clone_datum.original_ref = WEAKREF(original.mind)
	clone_datum.setup_clone()

	var/datum/objective/assassinate/paradox_clone/kill = locate() in clone_datum.objectives
	TEST_ASSERT(kill, "Paradox clone has no assassinate objective")
	TEST_ASSERT(kill.target == original.mind, "Paradox clone objective targets [kill.target || "nobody"], not the original")
	TEST_ASSERT(clone_mind.special_role == ROLE_PARADOX_CLONE, "Clone special_role is [clone_mind.special_role || "null"]")
	TEST_ASSERT(clone_mind.assigned_role == ROLE_PARADOX_CLONE, "Clone assigned_role is [clone_mind.assigned_role || "null"]")

	var/datum/atom_hud/antag/clone_hud = GLOB.huds[ANTAG_HUD_PARADOX_CLONE]
	TEST_ASSERT(istype(clone_hud, /datum/atom_hud/antag/hidden), "GLOB.huds\[ANTAG_HUD_PARADOX_CLONE\] is [clone_hud?.type || "null"]")
	TEST_ASSERT(GLOB.huds[ANTAG_HUD_VAMPIRE] != clone_hud, "The paradox clone HUD is the vampire HUD")
	TEST_ASSERT(clone in clone_hud.hudatoms, "Clone did not join the paradox clone HUD")
	TEST_ASSERT(("paradox_clone" in icon_states('icons/mob/hud.dmi')), "icons/mob/hud.dmi has no paradox_clone state")

	for(var/obj/item/modular_computer/messenger in clone.GetAllContents())
		TEST_ASSERT(messenger.messenger_invisible, "Clone's [messenger] still shows up in messenger lists")
	var/obj/item/clothing/under/sensor_clothes = clone.w_uniform
	TEST_ASSERT(sensor_clothes.sensor_mode == SENSOR_OFF, "Clone's suit sensors are still on")

	clone_mind.remove_antag_datum(/datum/antagonist/paradox_clone)
	TEST_ASSERT(!(clone in clone_hud.hudatoms), "Clone stayed in the paradox clone HUD after losing the antag")
	TEST_ASSERT(!clone_mind.special_role, "Clone kept special_role [clone_mind.special_role] after losing the antag")

	// Plasmaman original: envirosuit from the job and internals on (tgstation#73567)
	var/mob/living/carbon/human/plasma_original = make_original("Paradox Plasma", /datum/species/plasmaman, assistant)
	var/mob/living/carbon/human/plasma_clone = plasma_original.make_full_human_copy(run_loc_floor_top_right)
	allocated += plasma_clone
	TEST_ASSERT(isplasmaman(plasma_clone), "Plasmaman clone is a [plasma_clone.dna.species.type]")
	TEST_ASSERT(istype(plasma_clone.w_uniform, /obj/item/clothing/under/plasmaman), "Plasmaman clone has no envirosuit")
	TEST_ASSERT(plasma_clone.internal, "Plasmaman clone is not breathing from internals")

	TEST_ASSERT(GLOB.total_runtimes == runtimes_before, "[GLOB.total_runtimes - runtimes_before] runtimes while making a paradox clone")

/datum/unit_test/aquila_paradox_clone/proc/make_original(new_name, species_type, datum/job/job)
	var/mob/living/carbon/human/original = allocate(/mob/living/carbon/human)
	original.set_species(species_type)
	original.fully_replace_character_name(null, new_name)
	original.dna.real_name = new_name
	// Minds are not registered with the ticker, the clone procs only need mob.mind
	var/datum/mind/original_mind = new("aquila_paradox_[ckey(new_name)]")
	original_mind.current = original
	original.mind = original_mind
	original_mind.assigned_role = job.title
	original.job = job.title
	return original

/datum/unit_test/aquila_paradox_clone/Destroy()
	// The test minds are not owned by the ticker, drop them with their mobs
	for(var/mob/living/carbon/human/test_mob in allocated)
		var/datum/mind/test_mind = test_mob.mind
		if(test_mind)
			test_mob.mind = null
			test_mind.current = null
			qdel(test_mind)
	return ..()

#undef TEST_ASSERT
