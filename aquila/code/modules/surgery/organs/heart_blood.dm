// AQUILA - tgstation#96129: hearts regenerate blood. No heart, a stopped or failing heart: no blood regeneration.

/obj/item/organ/heart
	/// The rate at which blood is pumped by the heart is multiplied by this (value of 0 disables blood regeneration entirely)
	var/blood_regeneration_multiplier = 1

/// Returns how effectively this heart regenerates the owner's blood based on organ health
/obj/item/organ/heart/proc/get_blood_regeneration_multiplier()
	if(!beating || (organ_flags & ORGAN_FAILING))
		return 0
	var/health_percent = clamp((maxHealth - damage) / maxHealth, 0, 1)
	return blood_regeneration_multiplier * health_percent

/**
 * Returns a multiplier representing how effectively this mob can regenerate blood
 *
 * A return value of 0 means the mob cannot regenerate blood at all. (missing heart or the heart has stopped or is failing)
 * Mobs that do not require a heart always return 1, as their blood regeneration is unaffected by heart status.
 */
/mob/living/carbon/proc/get_heart_blood_regeneration_multiplier()
	if(!needs_heart())
		return 1
	var/obj/item/organ/heart/heart = getorganslot(ORGAN_SLOT_HEART)
	if(isnull(heart))
		return 0
	return heart.get_blood_regeneration_multiplier()
