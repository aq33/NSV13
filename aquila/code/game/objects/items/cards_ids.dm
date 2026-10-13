/// Withdrawing cash from departmental budget cards is gated behind the ALLOW_BUDGET_MONEY_WITHDRAWAL config flag
/obj/item/card/id/departmental_budget/alt_click_can_use_id(mob/living/user)
	if(!CONFIG_GET(flag/allow_budget_money_withdrawal))
		return

	. = ..()

#define BUDGET_ACTION_WITHDRAW "Wypłata gotówki"
#define BUDGET_ACTION_TRANSFER "Przelew do departamentu"

/// Alt-klik na karcie budżetowej: przelew do innego departamentu, a jeśli config pozwala, także wypłata gotówki
/obj/item/card/id/departmental_budget/AltClick(mob/living/user)
	if(!can_use_budget_card(user))
		return

	var/action = BUDGET_ACTION_TRANSFER
	if(CONFIG_GET(flag/allow_budget_money_withdrawal))
		action = tgui_alert(user, "Co chcesz zrobić z budżetem ([registered_account.account_holder], $[registered_account.account_balance])?", "[department_name]", list(BUDGET_ACTION_TRANSFER, BUDGET_ACTION_WITHDRAW))
		if(!action || !can_use_budget_card(user))
			return

	if(action == BUDGET_ACTION_WITHDRAW)
		return ..()
	transfer_to_department(user)

/obj/item/card/id/departmental_budget/proc/can_use_budget_card(mob/living/user)
	if(!isliving(user) || !user.canUseTopic(src, BE_CLOSE, FALSE, NO_TK))
		return FALSE
	if(!registered_account)
		return FALSE
	if(world.time < registered_account.withdrawDelay)
		registered_account.bank_card_talk("<span class='warning'>ERROR: UNABLE TO LOGIN DUE TO SCHEDULED MAINTENANCE. MAINTENANCE IS SCHEDULED TO COMPLETE IN [(registered_account.withdrawDelay - world.time)/10] SECONDS.</span>", TRUE)
		return FALSE
	return TRUE

/obj/item/card/id/departmental_budget/proc/transfer_to_department(mob/living/user)
	var/list/targets = list()
	for(var/dep_id in SSeconomy.department_accounts)
		var/datum/bank_account/department/target = SSeconomy.get_dep_account(dep_id)
		if(!target || target == registered_account)
			continue
		targets["[target.account_holder] ($[target.account_balance])"] = target

	if(!length(targets))
		to_chat(user, "<span class='warning'>Nie ma żadnego innego budżetu, na który można przelać kredyty.</span>")
		return

	var/picked = tgui_input_list(user, "Na który budżet przelać kredyty? Na koncie: $[registered_account.account_balance]", "Przelew z: [registered_account.account_holder]", targets)
	if(!picked || !can_use_budget_card(user))
		return
	var/datum/bank_account/department/target = targets[picked]

	var/amount = tgui_input_number(user, "Ile kredytów przelać do: [target.account_holder]? Na koncie: $[registered_account.account_balance]", "Przelew", 0, registered_account.account_balance, 0)
	if(!amount || amount <= 0 || !can_use_budget_card(user) || QDELETED(target))
		return
	amount = FLOOR(amount, 1)

	if(!target.transfer_money(registered_account, amount))
		var/difference = amount - registered_account.account_balance
		registered_account.bank_card_talk("<span class='warning'>BŁĄD: Na koncie brakuje [difference] kredytów do wykonania przelewu.</span>", TRUE)
		return

	registered_account.bank_card_talk("Przelew $[amount] do: [target.account_holder] wykonany. Na koncie zostało $[registered_account.account_balance].", TRUE)
	target.bank_card_talk("Otrzymano przelew $[amount] z: [registered_account.account_holder]. Na koncie jest teraz $[target.account_balance].")
	to_chat(user, "<span class='notice'>Przelewasz [amount] kredytów z [registered_account.account_holder] do [target.account_holder].</span>")
	log_game("[key_name(user)] transferred [amount] credits from [registered_account.account_holder] to [target.account_holder] at [AREACOORD(user)]")

/obj/item/card/id/departmental_budget/examine(mob/user)
	. = ..()
	if(registered_account)
		. += "<span class='info'>Alt-klik pozwala przelać kredyty z tego budżetu do innego departamentu.</span>"

#undef BUDGET_ACTION_WITHDRAW
#undef BUDGET_ACTION_TRANSFER
