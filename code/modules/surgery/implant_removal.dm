/datum/surgery/implant_removal
	name = "Implant removal"
	steps = list(/datum/surgery_step/incise, /datum/surgery_step/clamp_bleeders, /datum/surgery_step/retract_skin, /datum/surgery_step/extract_implant, /datum/surgery_step/close)
	target_mobtypes = list(/mob/living/carbon/human, /mob/living/carbon/monkey)
	possible_locs = list(BODY_ZONE_CHEST)

//extract implant
/datum/surgery_step/extract_implant
	name = "extract implant"
	implements = list(TOOL_HEMOSTAT = 100, TOOL_CROWBAR = 65)
	time = 64
	var/obj/item/implant/I = null
	success_sound = 'sound/surgery/hemostat1.ogg'

/datum/surgery_step/extract_implant/preop(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	for(var/obj/item/O in target.implants)
		I = O
		break
	if(I)
		display_results(user, target, "<span class='notice'>Zaczynasz wydobywać [I] z ciała [target] ([strefa_pl(target_zone)])...</span>",
			"[user] zaczyna wydobywać [I] z ciała [target] ([strefa_pl(target_zone)]).",
			"[user] zaczyna coś wydobywać z ciała [target] ([strefa_pl(target_zone)]).")
	else
		display_results(user, target, "<span class='notice'>Szukasz implantu w ciele [target] ([strefa_pl(target_zone)])...</span>",
			"[user] szuka implantu w ciele [target] ([strefa_pl(target_zone)]).",
			"[user] szuka czegoś w ciele [target] ([strefa_pl(target_zone)]).")

/datum/surgery_step/extract_implant/success(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	if(I)
		display_results(user, target, "<span class='notice'>Pomyślnie usuwasz [I] z ciała [target] ([strefa_pl(target_zone)]).</span>",
			"[user] pomyślnie usuwa [I] z ciała [target] ([strefa_pl(target_zone)])!",
			"[user] pomyślnie usuwa coś z ciała [target] ([strefa_pl(target_zone)])!")
		I.removed(target)

		var/obj/item/implantcase/case
		for(var/obj/item/implantcase/ic in user.held_items)
			case = ic
			break
		if(!case)
			case = locate(/obj/item/implantcase) in get_turf(target)
		if(case && !case.imp)
			case.imp = I
			I.forceMove(case)
			case.update_icon()
			display_results(user, target, "<span class='notice'>Umieszczasz [I] w [case].</span>",
				"[user] umieszcza [I] w [case]!",
				"[user] umieszcza to w [case]!")
		else
			qdel(I)

	else
		to_chat(user, "<span class='warning'>Nie możesz niczego znaleźć w ciele [target] ([strefa_pl(target_zone)])!</span>")
	return 1

/datum/surgery/implant_removal/mechanic
	name = "implant removal"
	requires_bodypart_type = BODYTYPE_ROBOTIC
	steps = list(
		/datum/surgery_step/mechanic_open,
		/datum/surgery_step/open_hatch,
		/datum/surgery_step/mechanic_unwrench,
		/datum/surgery_step/extract_implant,
		/datum/surgery_step/mechanic_wrench,
		/datum/surgery_step/mechanic_close)
