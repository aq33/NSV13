// AQUILA - aq33/NSV13#268, port of tgstation/tgstation#71651
// Head surgery that repairs the ears organ, written like eye_surgery.dm

/datum/surgery/ear_surgery
	name = "ear surgery"
	steps = list(
		/datum/surgery_step/incise,
		/datum/surgery_step/retract_skin,
		/datum/surgery_step/saw,
		/datum/surgery_step/clamp_bleeders,
		/datum/surgery_step/fix_ears,
		/datum/surgery_step/close,
	)
	target_mobtypes = list(/mob/living/carbon/human, /mob/living/carbon/monkey)
	possible_locs = list(BODY_ZONE_HEAD)
	requires_bodypart_type = 0

/datum/surgery/ear_surgery/can_start(mob/user, mob/living/carbon/target)
	var/obj/item/organ/ears/E = target.getorganslot(ORGAN_SLOT_EARS)
	if(!E)
		to_chat(user, "It's hard to do surgery on someone's ears when [target.p_they()] [target.p_do()]n't have any.")
		return FALSE
	return TRUE

//fix ears
/datum/surgery_step/fix_ears
	name = "fix ears"
	implements = list(TOOL_HEMOSTAT = 100, TOOL_SCREWDRIVER = 45, /obj/item/pen = 25)
	time = 64

/datum/surgery_step/fix_ears/preop(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	display_results(user, target, "<span class='notice'>You begin to fix [target]'s ears...</span>",
		"[user] begins to fix [target]'s ears.",
		"[user] begins to perform surgery on [target]'s ears.")

/datum/surgery_step/fix_ears/success(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	var/obj/item/organ/ears/E = target.getorganslot(ORGAN_SLOT_EARS)
	display_results(user, target, "<span class='notice'>You succeed in fixing [target]'s ears.</span>",
		"[user] successfully fixes [target]'s ears!",
		"[user] completes the surgery on [target]'s ears.")
	if(E) // they could have been removed mid-surgery
		to_chat(target, "<span class='notice'>Your head swims, but it seems like you can feel your hearing coming back!</span>")
		E.setOrganDamage(0)
		E.deaf = 20 // deafness works off ticks, so this wears off after about 30-40 seconds
	return TRUE

/datum/surgery_step/fix_ears/failure(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	if(target.getorgan(/obj/item/organ/brain))
		display_results(user, target, "<span class='warning'>You accidentally stab [target] right in the brain!</span>",
			"<span class='warning'>[user] accidentally stabs [target] right in the brain!</span>",
			"<span class='warning'>[user] accidentally stabs [target] right in the brain!</span>")
		target.adjustOrganLoss(ORGAN_SLOT_BRAIN, 70)
	else
		display_results(user, target, "<span class='warning'>You accidentally stab [target] right in the brain! Or would have, if [target] had a brain.</span>",
			"<span class='warning'>[user] accidentally stabs [target] right in the brain! Or would have, if [target] had a brain.</span>",
			"<span class='warning'>[user] accidentally stabs [target] right in the brain!</span>")
	return FALSE
