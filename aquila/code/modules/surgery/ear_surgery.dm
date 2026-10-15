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
		to_chat(user, "Trudno operować komuś uszy, gdy ich nie ma.")
		return FALSE
	return TRUE

//fix ears
/datum/surgery_step/fix_ears
	name = "fix ears"
	implements = list(TOOL_HEMOSTAT = 100, TOOL_SCREWDRIVER = 45, /obj/item/pen = 25)
	time = 64

/datum/surgery_step/fix_ears/preop(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	display_results(user, target, "<span class='notice'>Zaczynasz naprawiać uszy [target]...</span>",
		"[user] zaczyna naprawiać uszy [target].",
		"[user] zaczyna operację uszu [target].")

/datum/surgery_step/fix_ears/success(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	var/obj/item/organ/ears/E = target.getorganslot(ORGAN_SLOT_EARS)
	display_results(user, target, "<span class='notice'>Udaje ci się naprawić uszy [target].</span>",
		"[user] naprawia uszy [target]!",
		"[user] kończy operację uszu [target].")
	if(E) // they could have been removed mid-surgery
		to_chat(target, "<span class='notice'>Kręci ci się w głowie, ale chyba czujesz, że słuch wraca!</span>")
		E.setOrganDamage(0)
		E.deaf = 20 // deafness works off ticks, so this wears off after about 30-40 seconds
	return TRUE

/datum/surgery_step/fix_ears/failure(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	if(target.getorgan(/obj/item/organ/brain))
		display_results(user, target, "<span class='warning'>Przypadkiem dźgasz [target] prosto w mózg!</span>",
			"<span class='warning'>[user] przypadkiem dźga [target] prosto w mózg!</span>",
			"<span class='warning'>[user] przypadkiem dźga [target] prosto w mózg!</span>")
		target.adjustOrganLoss(ORGAN_SLOT_BRAIN, 70)
	else
		display_results(user, target, "<span class='warning'>Przypadkiem dźgasz [target] prosto w mózg! A raczej dźgnąłbyś, gdyby [target] miał mózg.</span>",
			"<span class='warning'>[user] przypadkiem dźga [target] prosto w mózg! A raczej dźgnąłby, gdyby [target] miał mózg.</span>",
			"<span class='warning'>[user] przypadkiem dźga [target] prosto w mózg!</span>")
	return FALSE
