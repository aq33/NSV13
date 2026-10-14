// The upstream assert macros are #undef'd at the end of code/modules/unit_tests/_unit_tests.dm, so this modular test carries its own copies
#define TEST_ASSERT(assertion, reason) if (!(assertion)) { return Fail("Assertion failed: [reason || "No reason"]") }

/// AQUILA - every objective of the traitor pool sets up and checks completion without runtimes, the forging never gives up,
/// traitor on traitor warns the victim and the master R&D server holds its HDD
/datum/unit_test/aquila_traitor_objectives

/datum/unit_test/aquila_traitor_objectives/Run()
	var/runtimes_before = GLOB.total_runtimes
	var/mob/living/carbon/human/first = make_crew("Traitor Pierwszy", JOB_NAME_ASSISTANT)
	var/mob/living/carbon/human/second = make_crew("Traitor Drugi", JOB_NAME_COOK)
	make_crew("Kapitan Testowy", JOB_NAME_CAPTAIN)
	make_crew("Oficer Testowy", JOB_NAME_HEADOFPERSONNEL)

	var/datum/antagonist/traitor/first_traitor = new
	first_traitor.give_objectives = FALSE
	first_traitor.should_equip = FALSE
	first.mind.add_antag_datum(first_traitor)
	var/datum/antagonist/traitor/second_traitor = new
	second_traitor.give_objectives = FALSE
	second_traitor.should_equip = FALSE
	second.mind.add_antag_datum(second_traitor)

	var/list/types = list(
		/datum/objective/assassinate,
		/datum/objective/assassinate/once,
		/datum/objective/assassinate/behead,
		/datum/objective/assassinate/calling_card,
		/datum/objective/assassinate/photo,
		/datum/objective/breakout,
		/datum/objective/steal,
		/datum/objective/steal/hdd,
		/datum/objective/steal/heirloom,
		/datum/objective/tcomms_data,
		/datum/objective/forged_manifest,
		/datum/objective/steal_five_of_type/organs,
		/datum/objective/steal_five_of_type/summon_guns/thief,
		/datum/objective/hoarder,
		/datum/objective/hoarder/bodies,
		/datum/objective/break_machinery,
		/datum/objective/plant_device/bomb,
		/datum/objective/plant_device/bug,
		/datum/objective/plant_device/tide,
		/datum/objective/sabotage/power_sink,
		/datum/objective/sabotage/integrity,
		/datum/objective/air_sabotage,
		/datum/objective/sabotage/ai_law,
		/datum/objective/hack_comms,
		/datum/objective/sabotage/supermatter,
		/datum/objective/iff_subvert,
		/datum/objective/poison_items,
	)
	for(var/objective_type in types)
		var/datum/objective/objective = new objective_type
		objective.owner = first.mind
		if(objective.traitor_roll_setup(first_traitor))
			objective.update_explanation_text()
			TEST_ASSERT(objective.explanation_text && objective.explanation_text != "Nothing", "[objective_type] has no explanation text")
			objective.check_completion()
		qdel(objective)
	TEST_ASSERT(GLOB.total_runtimes == runtimes_before, "Setting up the objectives caused [GLOB.total_runtimes - runtimes_before] runtime(s)")

	// The forging always ends up with an objective
	for(var/i in 1 to 30)
		var/list/objectives_before = first_traitor.objectives.Copy()
		first_traitor.forge_aquila_human_objective()
		// Wymiana dokumentów w 20% dokłada upstreamowy cel backstab, to nie jest drugi wylosowany cel
		var/list/added = first_traitor.objectives - objectives_before
		for(var/datum/objective/steal/exchange/backstab/bonus in added)
			added -= bonus
		TEST_ASSERT(length(added) == 1, "Forging round [i] added [length(added)] objectives")
	for(var/datum/objective/objective as anything in first_traitor.objectives)
		objective.check_completion()
	TEST_ASSERT(GLOB.total_runtimes == runtimes_before, "Forging the objectives caused [GLOB.total_runtimes - runtimes_before] runtime(s)")

	// Documents exchange: any two traitors can be paired
	if(SSticker.mode)
		var/old_red = SSticker.mode.exchange_red
		var/old_blue = SSticker.mode.exchange_blue
		SSticker.mode.exchange_red = null
		SSticker.mode.exchange_blue = null
		TEST_ASSERT(second_traitor.try_document_exchange(), "Two traitors could not be paired for the exchange")
		TEST_ASSERT(locate(/datum/objective/steal/exchange) in first_traitor.objectives, "The partner got no exchange objective")
		TEST_ASSERT(locate(/datum/objective/steal/exchange) in second_traitor.objectives, "The traitor got no exchange objective")
		TEST_ASSERT(!first_traitor.try_document_exchange(), "A second exchange was set up in the same round")
		SSticker.mode.exchange_red = old_red
		SSticker.mode.exchange_blue = old_blue

	// The XO gets the captain as target
	var/datum/objective/assassinate/captain_replacement/promotion = new
	promotion.owner = second.mind
	promotion.find_target()
	TEST_ASSERT(promotion.target?.assigned_role == JOB_NAME_CAPTAIN, "Captain replacement targets [promotion.target?.assigned_role || "nobody"]")
	qdel(promotion)

	// Traitor on traitor warns the victim
	var/datum/objective/assassinate/traitor/backstab = new
	backstab.owner = second.mind
	TEST_ASSERT(backstab.traitor_roll_setup(second_traitor), "Traitor on traitor found no other traitor")
	TEST_ASSERT(backstab.target == first.mind, "Traitor on traitor targets [backstab.target]")
	TEST_ASSERT(locate(/datum/objective/potentially_backstabbed) in first_traitor.objectives, "The victim got no warning")
	qdel(backstab)

	// The master server keeps its HDD, research runs at full speed
	for(var/obj/machinery/rnd/server/master/master_server as anything in SSresearch.master_servers)
		TEST_ASSERT(master_server.source_code_hdd, "[master_server] has no source code HDD")
		TEST_ASSERT(SSresearch.source_code_multiplier() == 1, "Research is slowed down while the HDD is in place")

	// Contact poison: picking the item up without gloves gives the dose, then it's gone
	var/obj/item/poison_paper/paper = allocate(/obj/item/poison_paper)
	var/obj/item/poisoned = allocate(/obj/item/pen)
	poisoned.AddComponent(/datum/component/contact_poison, paper.reagents)
	TEST_ASSERT(!paper.reagents.total_volume, "The poison stayed on the paper")
	var/mob/living/carbon/human/victim = make_crew("Ofiara Testowa", JOB_NAME_ASSISTANT)
	victim.put_in_hands(poisoned)
	TEST_ASSERT(victim.reagents.has_reagent(/datum/reagent/toxin/initropidril), "Picking the poisoned item up did not poison")
	TEST_ASSERT(!length(poisoned.GetComponents(/datum/component/contact_poison)), "The poison stayed on the item after the dose")

	// The beacon of the blood brothers sets up without runtimes, whatever the map has
	var/datum/objective/brother_beacon/beacon = new
	beacon.owner = second.mind
	if(beacon.setup_beacon())
		TEST_ASSERT(!isnull(beacon.channel), "Beacon objective has no channel")
		TEST_ASSERT(locate(/obj/item/brother_beacon) in second.GetAllContents(), "The brother got no beacon")
	qdel(beacon)

	// Backstory (BeeStation#9126): picked after the objectives, the faction decides about the codewords
	var/mob/living/carbon/human/storyteller = make_crew("Zdrajca Historii", JOB_NAME_ASSISTANT)
	var/datum/antagonist/traitor/story_traitor = new
	story_traitor.give_objectives = FALSE
	storyteller.mind.add_antag_datum(story_traitor)
	TEST_ASSERT(story_traitor.uses_backstory(), "A plain traitor does not use the backstory menu")
	story_traitor.setup_backstories(FALSE, FALSE)
	TEST_ASSERT(length(story_traitor.allowed_backstories) == length(GLOB.traitor_backstories), "Not every backstory is allowed without murderbone")
	TEST_ASSERT(story_traitor.ui_name == "TraitorBackstoryMenu", "The traitor window is [story_traitor.ui_name]")
	story_traitor.setup_backstories(TRUE, FALSE)
	for(var/path in story_traitor.allowed_backstories)
		var/datum/traitor_backstory/allowed = GLOB.traitor_backstories[path]
		TEST_ASSERT(!allowed.has_motivation(TRAITOR_MOTIVATION_FORCED), "A forced backstory is allowed for a murderbone traitor")
	TEST_ASSERT(!story_traitor.faction && !story_traitor.has_codewords, "The traitor got a faction before picking one")
	story_traitor.set_faction(GLOB.traitor_factions_to_datum[TRAITOR_FACTION_BLACK_MARKET])
	TEST_ASSERT(story_traitor.faction?.key == TRAITOR_FACTION_BLACK_MARKET, "The faction was not set")
	TEST_ASSERT(!story_traitor.has_codewords, "A black market traitor got the codewords")
	story_traitor.set_backstory(GLOB.traitor_backstories["[/datum/traitor_backstory/greedy]"])
	TEST_ASSERT(findtext(story_traitor.backstory_roundend_text(), "Chciwiec"), "The round end report does not show the backstory")
	TEST_ASSERT(GLOB.total_runtimes == runtimes_before, "The backstory caused [GLOB.total_runtimes - runtimes_before] runtime(s)")

	var/unbreathable = get_unbreathable_percent()
	TEST_ASSERT(unbreathable >= 0 && unbreathable <= 100, "Unbreathable percent is [unbreathable]")
	TEST_ASSERT(GLOB.total_runtimes == runtimes_before, "The test caused [GLOB.total_runtimes - runtimes_before] runtime(s)")

/datum/unit_test/aquila_traitor_objectives/proc/make_crew(new_name, job_title)
	var/mob/living/carbon/human/crew = allocate(/mob/living/carbon/human)
	crew.fully_replace_character_name(null, new_name)
	crew.dna.real_name = new_name
	var/datum/mind/crew_mind = new("aquila_traitor_[ckey(new_name)]")
	crew_mind.current = crew
	crew.mind = crew_mind
	crew_mind.assigned_role = job_title
	crew.job = job_title
	// manifest_inject() doesn't wait for its photos, only the locked record is needed to be a valid target
	var/datum/data/record/locked = new
	locked.fields["name"] = new_name
	locked.fields["rank"] = job_title
	locked.fields["mindref"] = crew_mind
	GLOB.data_core.locked += locked
	return crew

/datum/unit_test/aquila_traitor_objectives/Destroy()
	for(var/mob/living/carbon/human/test_mob in allocated)
		var/datum/mind/test_mind = test_mob.mind
		if(!test_mind)
			continue
		for(var/datum/data/record/R as anything in GLOB.data_core.locked.Copy())
			if(R.fields["mindref"] == test_mind)
				GLOB.data_core.locked -= R
		test_mind.remove_all_antag_datums()
		test_mob.mind = null
		test_mind.current = null
		qdel(test_mind)
	return ..()

#undef TEST_ASSERT
