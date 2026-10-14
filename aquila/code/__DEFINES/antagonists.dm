#define ANTAG_DATUM_INFILTRATOR		/datum/antagonist/infiltrator
#define ANTAG_DATUM_HIJACKEDAI		/datum/antagonist/hijacked_ai
#define ANTAG_DATUM_SINFULDEMON		/datum/antagonist/sinfuldemon

///File with the thief flavors (tgstation#64144), in the strings directory
#define THIEF_FLAVOR_FILE "thief_flavor.json"

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
