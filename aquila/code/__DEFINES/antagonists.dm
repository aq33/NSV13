#define ANTAG_DATUM_INFILTRATOR		/datum/antagonist/infiltrator
#define ANTAG_DATUM_HIJACKEDAI		/datum/antagonist/hijacked_ai
#define ANTAG_DATUM_SINFULDEMON		/datum/antagonist/sinfuldemon


/// drain_APC() demona impulsu zwraca to, gdy APC jest właśnie przejmowane
#define PULSEDEMON_SOURCE_DRAIN_INVALID -1
/// Sieć musi mieć tyle W, żeby demon impulsu mógł się w niej pojawić (wartość z Paradise)
#define PULSEDEMON_REQUIRED_POWER 1000

// Weighted rotation (master mode "weighted") threat pools, as written in the WEIGHTED_POOL config entries
#define WEIGHTED_POOL_LOW "low"
#define WEIGHTED_POOL_MEDIUM "medium"
#define WEIGHTED_POOL_HIGH "high"

/// Powyżej tej jasności pola demon cieni się pali i nie może wejść w cień (wartość z Paradise)
#define SHADOW_DEMON_LIGHT_THRESHOLD 0.2

// Traitor factions and backstory motivations (BeeStation/BeeStation-Hornet#9126)
#define TRAITOR_FACTION_BLACK_MARKET "black_market"
#define TRAITOR_FACTION_SYNDICATE "syndicate"
#define TRAITOR_FACTION_INDEPENDENT "independent"
/// The backstory involves being forced into the job
#define TRAITOR_MOTIVATION_FORCED "Forced Into It"
/// The backstory does not involve being forced into the job
#define TRAITOR_MOTIVATION_NOT_FORCED "Not Forced Into It"
/// Motivated by money or personal gain
#define TRAITOR_MOTIVATION_MONEY "Money"
/// Politically motivated, wanting to "change the world"
#define TRAITOR_MOTIVATION_POLITICAL "Political"
/// Motivated by love (family, friends...)
#define TRAITOR_MOTIVATION_LOVE "Love"
/// Motivated by reputation or knowledge (blackmail)
#define TRAITOR_MOTIVATION_REPUTATION "Reputation"
/// Motivated by the threat of death or personal harm
#define TRAITOR_MOTIVATION_DEATH_THREAT "Death Threat"
/// Motivated by their faction or presence in an organization
#define TRAITOR_MOTIVATION_AUTHORITY "Authority"
/// Motivated by themselves or the activity
#define TRAITOR_MOTIVATION_FUN "Fun"
