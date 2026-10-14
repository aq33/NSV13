// The upstream assert macros are #undef'd at the end of code/modules/unit_tests/_unit_tests.dm, so this modular test carries its own copies
#define TEST_ASSERT(assertion, reason) if (!(assertion)) { return Fail("Assertion failed: [reason || "No reason"]") }

#define TEST_ASSERT_EQUAL(a, b, message) do { \
	var/lhs = ##a; \
	var/rhs = ##b; \
	if (lhs != rhs) { \
		return Fail("Expected [isnull(lhs) ? "null" : lhs] to be equal to [isnull(rhs) ? "null" : rhs].[message ? " [message]" : ""]"); \
	} \
} while (FALSE)

/// AQUILA - every job category rolls valid civilian bounties and every job gets a non-empty pick list
/datum/unit_test/civilian_bounty_generation

/datum/unit_test/civilian_bounty_generation/Run()
	for(var/category in 1 to MAXIMUM_BOUNTY_JOBS)
		for(var/i in 1 to 5)
			var/bounty_type = get_random_civ_bounty_type(category)
			TEST_ASSERT(ispath(bounty_type, /datum/bounty), "Category [category] returned [bounty_type || "null"] instead of a bounty type")
			var/datum/bounty/rolled = new bounty_type
			TEST_ASSERT(rolled.name && rolled.description, "[bounty_type] has no name or description")
			TEST_ASSERT(rolled.get_bounty_reward() > 0 || !rolled.can_get(), "[bounty_type] would pay nothing")
			qdel(rolled)

	for(var/datum/job/job as anything in SSjob.occupations)
		var/list/picks = generate_civ_bounty_list(job.bounty_types)
		TEST_ASSERT(length(picks), "[job.title] got no civilian bounties to pick from")
		QDEL_LIST(picks)

/// AQUILA - the bounty cube splits its value between the bounty holders and cargo
/datum/unit_test/civilian_bounty_cube_payout

/datum/unit_test/civilian_bounty_cube_payout/Run()
	var/datum/bank_account/holder = new("Test Holder", SSjob.GetJobType(/datum/job/assistant))
	var/obj/item/bounty_cube/cube = allocate(/obj/item/bounty_cube)
	cube.bounty_value = 1000
	cube.bounty_holder_accounts = list()
	cube.bounty_holder_accounts[holder] = 1

	var/start_balance = holder.account_balance
	// 1000 + 20% speed bonus - 30% holder cut
	TEST_ASSERT_EQUAL(cube.pay_out(dry_run = TRUE), 900, "Cargo share of the cube is wrong")
	TEST_ASSERT_EQUAL(holder.account_balance, start_balance, "A dry run paid the holder")
	TEST_ASSERT_EQUAL(cube.pay_out(), 900, "Cargo share of the cube changed after paying out")
	TEST_ASSERT_EQUAL(holder.account_balance, start_balance + 300, "The holder did not get their 30% cut")
	qdel(holder)

/// AQUILA - market prices stay inside their limits and stock blocks sell for their locked price
/datum/unit_test/stock_market_prices

/datum/unit_test/stock_market_prices/Run()
	TEST_ASSERT(length(SSstock_market.materials_prices), "No materials are traded on the stock market")
	for(var/datum/material/mat as anything in SSstock_market.materials_prices)
		TEST_ASSERT(initial(mat.sheet_type), "[mat] is traded but has no sheet type to deliver")
		for(var/i in 1 to 30)
			SSstock_market.handle_trends_and_price(mat)
			var/price = SSstock_market.materials_prices[mat]
			TEST_ASSERT(price >= SSstock_market.price_minimum(mat) && price <= SSstock_market.price_maximum(mat), "[mat] price [price] left its limits")
			var/quantity = SSstock_market.materials_quantity[mat]
			TEST_ASSERT(quantity >= 0 && quantity <= initial(mat.tradable_base_quantity) * 2, "[mat] quantity [quantity] left its limits")
	for(var/datum/stock_market_event/event as anything in SSstock_market.active_events.Copy())
		event.end_event()

	var/obj/item/stock_block/block = allocate(/obj/item/stock_block)
	block.set_up(/datum/material/gold, 10, 77)
	var/datum/export/stock_block/block_export = new
	TEST_ASSERT_EQUAL(block_export.get_cost(block), 770, "A locked stock block did not sell for its locked price")
	qdel(block_export)

/// AQUILA - only real income counts towards the earnings report: no player transfers, cash deposits, starting money or refunds
/datum/unit_test/economy_round_income

/datum/unit_test/economy_round_income/Run()
	var/datum/job/assistant = SSjob.GetJobType(/datum/job/assistant)
	var/datum/bank_account/earner = new("Test Earner", assistant)
	var/datum/bank_account/friend = new("Test Friend", assistant)
	var/datum/bank_account/department/budget = SSeconomy.get_dep_account(ACCOUNT_CIV)

	earner.payday(5, TRUE)
	TEST_ASSERT_EQUAL(earner.round_income, 0, "Starting paychecks counted as income")

	friend.adjust_money(1000)
	earner.transfer_money(friend, 500)
	TEST_ASSERT_EQUAL(earner.round_income, 0, "A transfer from another player counted as income")

	earner.refund_money(100)
	TEST_ASSERT_EQUAL(earner.round_income, 0, "A refund counted as income")

	budget.adjust_money(1000)
	earner.transfer_money(budget, 200)
	TEST_ASSERT_EQUAL(earner.round_income, 200, "A transfer from a department budget did not count as income")

	earner.adjust_money(300)
	TEST_ASSERT_EQUAL(earner.round_income, 500, "A plain payment did not count as income")

	var/obj/item/card/id/card = allocate(/obj/item/card/id)
	card.registered_account = earner
	var/obj/item/stack/spacecash/c100/cash = allocate(/obj/item/stack/spacecash/c100)
	card.insert_money(cash, null)
	TEST_ASSERT_EQUAL(earner.round_income, 500, "A cash deposit counted as income")

	qdel(earner)
	qdel(friend)

/// AQUILA - a market crash drops every material to its minimum price and multiplies vending prices
/datum/unit_test/economy_market_crash

/datum/unit_test/economy_market_crash/Run()
	var/obj/machinery/vending/cola/vendor = allocate(/obj/machinery/vending/cola)
	var/base_price = vendor.default_price
	SSeconomy.market_crashing = TRUE
	SSeconomy.inflation_value = 3
	vendor.reset_prices()
	var/crash_price = vendor.default_price
	SSstock_market.handle_market_crash()
	var/list/bad_prices = list()
	for(var/datum/material/mat as anything in SSstock_market.materials_prices)
		if(SSstock_market.materials_prices[mat] != SSstock_market.price_minimum(mat))
			bad_prices += "[mat]"
	SSeconomy.market_crashing = FALSE
	SSeconomy.inflation_value = 1
	vendor.reset_prices()

	TEST_ASSERT_EQUAL(crash_price, base_price * 3, "Vending prices were not multiplied during the crash")
	TEST_ASSERT_EQUAL(vendor.default_price, base_price, "Vending prices did not go back after the crash")
	TEST_ASSERT(!length(bad_prices), "Materials not at minimum during the crash: [bad_prices.Join(", ")]")

#undef TEST_ASSERT
#undef TEST_ASSERT_EQUAL
