// The upstream assert macros are #undef'd at the end of code/modules/unit_tests/_unit_tests.dm, so this modular test carries its own copies
#define TEST_ASSERT(assertion, reason) if (!(assertion)) { return Fail("Assertion failed: [reason || "No reason"]") }
#define TEST_ASSERT_EQUAL(a, b, message) if ((a) != (b)) { return Fail("Expected [isnull(a) ? "null" : a] to be equal to [isnull(b) ? "null" : b].[message ? " [message]" : ""]") }

/// AQUILA - spy port from tgstation: the black market has sane goods, spies get an uplink with bounties,
/// and stolen goods are fenced on the black market
/datum/unit_test/aquila_spy

/datum/unit_test/aquila_spy/Run()
	// Market goods (tgstation unit test "market")
	for(var/datum/market_item/prototype as anything in subtypesof(/datum/market_item))
		if(initial(prototype.abstract_path) == prototype)
			continue
		TEST_ASSERT(initial(prototype.category), "[prototype] doesn't have a set category (or the abstract path var isn't correctly set)")
		TEST_ASSERT(initial(prototype.item), "[prototype] doesn't have a set item (or the abstract path var isn't correctly set)")
		TEST_ASSERT(!isnull(initial(prototype.price)) || initial(prototype.price_max) > initial(prototype.price_min), "[prototype] doesn't have a correctly set random price")
		TEST_ASSERT(!isnull(initial(prototype.stock)) || initial(prototype.stock_max) >= initial(prototype.stock_min), "[prototype] doesn't have a correctly set random stock")
		TEST_ASSERT(isnum(initial(prototype.availability_prob)), "[prototype] doesn't have a set availability_prob")
		TEST_ASSERT(initial(prototype.name), "[prototype] doesn't have a set name")
		TEST_ASSERT(initial(prototype.desc), "[prototype] doesn't have a set desc")

	var/datum/market/blackmarket = SSmarket.markets[/datum/market/blackmarket]
	TEST_ASSERT(blackmarket, "There is no black market")
	TEST_ASSERT(length(blackmarket.categories), "The black market has no goods")

	// Spy-only rewards never show up in the traitor uplink
	for(var/datum/uplink_item/spy_unique/spy_item as anything in subtypesof(/datum/uplink_item/spy_unique))
		TEST_ASSERT(!(initial(spy_item.purchasable_from) & UPLINK_TRAITORS), "[spy_item] can be bought by traitors")
		TEST_ASSERT(ispath(initial(spy_item.item)), "[spy_item] has no item")

	// A spy gets an uplink in their pen and a list of bounties
	var/mob/living/carbon/human/spy_mob = allocate(/mob/living/carbon/human)
	spy_mob.mind_initialize()
	var/obj/item/pen/pen = allocate(/obj/item/pen)
	spy_mob.put_in_hands(pen)
	var/datum/antagonist/spy/spy = new
	spy.silent = TRUE
	spy_mob.mind.add_antag_datum(spy)
	var/datum/component/spy_uplink/uplink = pen.GetComponent(/datum/component/spy_uplink)
	TEST_ASSERT(uplink, "The spy got no uplink in their pen")
	TEST_ASSERT(IS_SPY(spy_mob), "IS_SPY does not see the spy")
	TEST_ASSERT(length(spy.objectives), "The spy got no objectives")
	for(var/datum/objective/objective as anything in spy.objectives)
		TEST_ASSERT(!findtext(objective.explanation_text, "@pick"), "A spy objective was not filled in: [objective.explanation_text]")
	TEST_ASSERT(uplink.handler, "The spy uplink has no bounty handler")
	TEST_ASSERT(length(uplink.handler.possible_uplink_items[SPY_DIFFICULTY_EASY]), "There are no easy spy rewards")
	for(var/datum/spy_bounty/bounty as anything in uplink.handler.get_all_bounties())
		TEST_ASSERT(bounty.initalized, "[bounty.type] is in the bounty list but not initialized")
		TEST_ASSERT(bounty.name && bounty.help, "[bounty.type] has no name or help text")
		TEST_ASSERT(bounty.reward_item, "[bounty.type] has no reward")
	var/list/ui_data = uplink.ui_data(spy_mob)
	TEST_ASSERT(islist(ui_data["bounties"]), "The spy uplink sends no bounty list")

	// Stolen goods are fenced on the black market and go away with the item
	var/obj/item/stolen = allocate(/obj/item/toy/gun)
	var/datum/spy_bounty/objective_item/random_easy/fake_bounty = new(uplink.handler)
	fake_bounty.difficulty = SPY_DIFFICULTY_EASY
	TEST_ASSERT(fake_bounty.send_to_black_market(stolen, FALSE, FALSE), "The stolen item was not put on the black market")
	TEST_ASSERT(isnull(stolen.loc), "The stolen item is not in nullspace")
	var/list/fenced = blackmarket.available_items[BLACKMARKET_CATEGORY_FENCED_GOODS]
	TEST_ASSERT(length(fenced), "The stolen item is not in the fenced goods")
	var/fenced_count = length(fenced)
	qdel(stolen)
	TEST_ASSERT_EQUAL(length(blackmarket.available_items[BLACKMARKET_CATEGORY_FENCED_GOODS]), fenced_count - 1, "Deleting the stolen item did not remove it from the market")
	qdel(fake_bounty)

	spy_mob.mind.remove_antag_datum(/datum/antagonist/spy)
	TEST_ASSERT(!pen.GetComponent(/datum/component/spy_uplink), "The spy uplink stayed after the spy was removed")

#undef TEST_ASSERT
#undef TEST_ASSERT_EQUAL
