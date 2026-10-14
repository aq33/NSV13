// AQUILA - defibrillation like tgstation: no time limit, the body itself decides.
// A dead heart decays to failing in about 5 minutes (fixable with surgery or medicine), the brain in about 30.
// The defib refuses with a reason; DNR patients cannot be shocked back.

/// TRUE if the body could be defibrillated right now, not counting whether the player is in it
/mob/living/carbon/proc/is_defib_possible()
	if(suiciding || ishellbound() || HAS_TRAIT(src, TRAIT_HUSK))
		return FALSE
	if((getBruteLoss() >= MAX_REVIVE_BRUTE_DAMAGE) || (getFireLoss() >= MAX_REVIVE_FIRE_DAMAGE))
		return FALSE
	var/obj/item/organ/heart/heart = getorgan(/obj/item/organ/heart)
	if(!heart || (heart.organ_flags & ORGAN_FAILING))
		return FALSE
	var/obj/item/organ/brain/brain = getorgan(/obj/item/organ/brain)
	if(QDELETED(brain) || brain.brain_death || (brain.organ_flags & ORGAN_FAILING) || brain.suicided)
		return FALSE
	return TRUE

/// TRUE if the player of this body chose Do Not Resuscitate
/mob/living/carbon/proc/has_dnr()
	if(!mind)
		return FALSE
	var/mob/dead/observer/ghost = get_ghost(TRUE)
	return ghost && !ghost.can_reenter_corpse

// Keep the medical HUD honest: the "can be revived" icon goes away once the heart or brain decays
/obj/item/organ/heart/applyOrganDamage(d, maximum = maxHealth)
	. = ..()
	if(owner?.stat == DEAD)
		owner.med_hud_set_status()

/obj/item/organ/brain/applyOrganDamage(d, maximum = maxHealth)
	. = ..()
	if(owner?.stat == DEAD)
		owner.med_hud_set_status()
