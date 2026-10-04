/// Withdrawing cash from departmental budget cards is gated behind the ALLOW_BUDGET_MONEY_WITHDRAWAL config flag
/obj/item/card/id/departmental_budget/alt_click_can_use_id(mob/living/user)
	if(!CONFIG_GET(flag/allow_budget_money_withdrawal))
		return

	. = ..()
