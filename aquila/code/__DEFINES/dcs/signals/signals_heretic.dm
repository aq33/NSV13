/// Heretic signals

/// From /obj/item/melee/touch_attack/mansus_fist/on_mob_hit : (mob/living/source, mob/living/target)
	/// Default behavior is to use the hand, so return this to blocks the mansus fist from being consumed after use.
	#define COMPONENT_BLOCK_HAND_USE (1<<0)
/// From /obj/item/melee/touch_attack/mansus_fist/afterattack_secondary : (mob/living/source, atom/target)
#define COMSIG_HERETIC_MANSUS_GRASP_ATTACK_SECONDARY "mansus_grasp_attack_secondary"
	/// Default behavior is to continue attack chain and do nothing else, so return this to use up the hand after use.
	#define COMPONENT_USE_HAND (1<<0)

