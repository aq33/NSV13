//Bluespace Miners
/datum/config_entry/number/roundstart_bluespace_miners
	min_val = 0

/datum/config_entry/flag/bsminer_researchable

// Allow withdrawing money from department budgets?
/datum/config_entry/flag/allow_budget_money_withdrawal
// Allow conversion of your shift end bank account balance to metacoins?
/datum/config_entry/flag/allow_endround_bank_balance_metacoin_conversion

/datum/config_entry/number/bank_balance_metacoin_conversion_coefficient
	integer = FALSE
	min_val = 0

// Allow nuclear code requests to be automatically accepted after some time
// Admins can cancel this manually if they are quick enough.
/datum/config_entry/flag/allow_nuke_request_auto_accept

// Toggle defacation and all associated things
/datum/config_entry/flag/shitting_enabled
