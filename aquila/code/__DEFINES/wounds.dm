// AQUILA - light version of tgstation wounds (aquila/code/modules/wounds/)

#define WOUND_BLUNT "blunt"
#define WOUND_SLASH "slash"
#define WOUND_BURN "burn"

#define WOUND_SEVERITY_MODERATE 1
#define WOUND_SEVERITY_SEVERE 2
#define WOUND_SEVERITY_CRITICAL 3

/// Hits weaker than this never roll for a wound
#define WOUND_MINIMUM_DAMAGE 5
/// Raise to make wounds rarer, every threshold is multiplied by it
#define WOUND_THRESHOLD_MULTIPLIER 1.2
/// How much a fully damaged limb adds to the roll
#define WOUND_DAMAGED_LIMB_BONUS 15
