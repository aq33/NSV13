// Spy antagonist (port of tgstation code/modules/antagonists/spy)

#define ROLE_SPY "Spy"

#define IS_SPY(mob) (mob?.mind?.has_antag_datum(/datum/antagonist/spy))

/// Spy objective flavor texts, in core strings/ because tools/deploy.sh only ships that folder
#define SPY_OBJECTIVE_FILE "spy_objective.json"

/// Uplink items costing this much or less go to the easy spy reward pool
#define SPY_LOWER_COST_THRESHOLD 5
/// Uplink items costing more than this go to the hard spy reward pool
#define SPY_UPPER_COST_THRESHOLD 12

#define SPY_DIFFICULTY_EASY "Easy"
#define SPY_DIFFICULTY_MEDIUM "Medium"
#define SPY_DIFFICULTY_HARD "Hard"

/// Time between bounty refreshes
#define SPY_BOUNTY_REFRESH_TIME (12 MINUTES)
/// How many hard bounties get unlocked per refresh, until the max is reached
#define SPY_HARD_BOUNTIES_PER_REFRESH 1

///From /datum/component/spy_uplink/proc/try_steal(): (mob/living/spy, datum/spy_bounty/bounty)
#define COMSIG_MOVABLE_SPY_STEALING "movable_spy_stealing"
