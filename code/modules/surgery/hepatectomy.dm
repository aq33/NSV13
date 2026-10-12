/datum/surgery/hepatectomy
	name = "Hepatectomy"
	target_mobtypes = list(/mob/living/carbon/human, /mob/living/carbon/monkey)
	possible_locs = list(BODY_ZONE_CHEST)
	requires_real_bodypart = TRUE
	steps = list(/datum/surgery_step/incise,
		/datum/surgery_step/retract_skin,
		/datum/surgery_step/saw,
		/datum/surgery_step/clamp_bleeders,
		/datum/surgery_step/incise,
		/datum/surgery_step/hepatectomy,
		/datum/surgery_step/close
		)

/datum/surgery/hepatectomy/can_start(mob/user, mob/living/carbon/target)
	var/obj/item/organ/liver/L = target.getorganslot(ORGAN_SLOT_LIVER)
	if(L?.damage > 50 && !(L.organ_flags & ORGAN_FAILING))
		return TRUE

////hepatectomy, removes damaged parts of the liver so that the liver may regenerate properly
//95% chance of success, not 100 because organs are delicate
/datum/surgery_step/hepatectomy
	name = "remove damaged liver section"
	implements = list(TOOL_SCALPEL = 95, /obj/item/melee/transforming/energy/sword = 65, /obj/item/kitchen/knife = 45,
		/obj/item/shard = 35)
	time = 52

/datum/surgery_step/hepatectomy/preop(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	display_results(user, target, "<span class='notice'>Zaczynasz wycinać uszkodzony fragment wątroby [target]...</span>",
		"<span class='notice'>[user] zaczyna nacinać [target].</span>",
		"<span class='notice'>[user] zaczyna nacinać [target].</span>")

/datum/surgery_step/hepatectomy/success(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	var/mob/living/carbon/human/H = target
	H.setOrganLoss(ORGAN_SLOT_LIVER, 10) //not bad, not great
	display_results(user, target, "<span class='notice'>Pomyślnie usuwasz uszkodzoną część wątroby [target].</span>",
		"<span class='notice'>[user] pomyślnie usuwa uszkodzoną część wątroby [target].",
		"<span class='notice'>[user] pomyślnie usuwa uszkodzoną część wątroby [target].")
	return TRUE

/datum/surgery_step/hepatectomy/failure(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery)
	var/mob/living/carbon/human/H = target
	H.adjustOrganLoss(ORGAN_SLOT_LIVER, 15)
	display_results(user, target, "<span class='warning'>Wycinasz nie tę część wątroby [target]!</span>",
		"<span class='warning'>[user] wycina nie tę część wątroby [target]!",
		"<span class='warning'>[user] wycina nie tę część wątroby [target]!")
