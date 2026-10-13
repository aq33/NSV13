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

// Allow response team requests to be automatically accepted after some time
// Admins can cancel this manually if they are quick enough.
/datum/config_entry/flag/allow_ert_request_auto_accept

// Allow crew wake requests (ghosts respawning as assistants at the cryopods) to be automatically accepted after some time
// Admins can cancel this manually if they are quick enough.
/datum/config_entry/flag/allow_crew_wake_request_auto_accept

// Toggle defacation and all associated things
/datum/config_entry/flag/shitting_enabled

// Do antagonist roles need required_living_playtime hours of living time? Off = no hour limits for antags.
/datum/config_entry/flag/antag_living_playtime_requirements

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

// Weighted rotation (master mode "weighted"): which threat pool a game mode belongs to - low, medium or high
// Modes without an entry are never picked by the weighted rotation
/datum/config_entry/keyed_list/weighted_pool
	key_mode = KEY_MODE_TEXT
	value_mode = VALUE_MODE_TEXT

/datum/config_entry/keyed_list/weighted_pool/ValidateListEntry(key_name, key_value)
	return (key_name in config.modes) && (lowertext(key_value) in list(WEIGHTED_POOL_LOW, WEIGHTED_POOL_MEDIUM, WEIGHTED_POOL_HIGH))

// Weighted rotation: the most roundstart antagonists a mode may get, no matter the population (a random amount from 1 to this)
/datum/config_entry/keyed_list/weighted_max_antags
	key_mode = KEY_MODE_TEXT
	value_mode = VALUE_MODE_NUM

/datum/config_entry/keyed_list/weighted_max_antags/ValidateListEntry(key_name, key_value)
	return (key_name in config.modes) && key_value >= 1
