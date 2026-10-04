// The upstream assert macros are #undef'd at the end of code/modules/unit_tests/_unit_tests.dm, so this modular test carries its own copies
#define TEST_ASSERT(assertion, reason) if (!(assertion)) { return Fail("Assertion failed: [reason || "No reason"]") }

#define TEST_ASSERT_EQUAL(a, b, message) do { \
	var/lhs = ##a; \
	var/rhs = ##b; \
	if (lhs != rhs) { \
		return Fail("Expected [isnull(lhs) ? "null" : lhs] to be equal to [isnull(rhs) ? "null" : rhs].[message ? " [message]" : ""]"); \
	} \
} while (FALSE)

/// AQUILA - departmental budget cards can not be used for withdrawals unless the config allows it (moved from code/game/objects/items/cards_ids.dm)
/datum/unit_test/aquila_budget_card_withdrawal

/datum/unit_test/aquila_budget_card_withdrawal/Run()
	var/mob/living/carbon/human/user = allocate(/mob/living/carbon/human)
	var/obj/item/card/id/departmental_budget/card = allocate(/obj/item/card/id/departmental_budget/civ)
	var/old_value = CONFIG_GET(flag/allow_budget_money_withdrawal)
	CONFIG_SET(flag/allow_budget_money_withdrawal, FALSE)
	var/result = card.alt_click_can_use_id(user)
	CONFIG_SET(flag/allow_budget_money_withdrawal, old_value)
	TEST_ASSERT(!result, "Budget card allowed a withdrawal with the config flag off")

#undef TEST_ASSERT
#undef TEST_ASSERT_EQUAL
