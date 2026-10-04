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

// Paradox Clone (tgstation#71141 port): can it roll on its own, as a random event or a dynamic midround?
// Admins can always force it through Trigger Event.
/datum/config_entry/flag/paradox_clone_enabled

/datum/config_entry/number/paradox_clone_weight
	config_entry_value = 8
	min_val = 0

/datum/config_entry/number/paradox_clone_max_occurrences
	config_entry_value = 1
	min_val = 0

/datum/config_entry/number/paradox_clone_min_players
	config_entry_value = 10
	min_val = 0

// In minutes
/datum/config_entry/number/paradox_clone_earliest_start
	config_entry_value = 20
	min_val = 0
