/datum/surgery/cavity_implant
	name = "cavity implant"
	steps = list(/datum/surgery_step/incise, /datum/surgery_step/clamp_bleeders, /datum/surgery_step/retract_skin, /datum/surgery_step/incise, /datum/surgery_step/handle_cavity, /datum/surgery_step/close)
	target_mobtypes = list(/mob/living/carbon/human, /mob/living/carbon/monkey)
	possible_locs = list(BODY_ZONE_CHEST)
	self_operable = TRUE


//handle cavity
/datum/surgery_step/handle_cavity
	name = "implant item"
	accept_hand = 1
	implements = list(/obj/item = 100)
	repeatable = TRUE
	time = 32
	var/obj/item/IC = null
	preop_sound = 'sound/surgery/organ1.ogg'
	success_sound = 'sound/surgery/organ2.ogg'

/datum/surgery_step/handle_cavity/tool_check(mob/user, obj/item/tool)
	if(istype(tool, /obj/item/cautery) || istype(tool, /obj/item/gun/energy/laser))
		return FALSE
	return !tool.is_hot()

/datum/surgery_step/handle_cavity/preop(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/surgery/surgery)
	var/obj/item/bodypart/chest/CH = target.get_bodypart(BODY_ZONE_CHEST)
	IC = CH.cavity_item
	if(tool)
		display_results(user, target, "<span class='notice'>Zaczynasz wkładać [tool] do ciała [target] ([strefa_pl(target_zone)])...</span>",
			"[user] zaczyna wkładać [tool] do ciała [target] ([strefa_pl(target_zone)]).",
			"[user] zaczyna wkładać [tool.w_class > WEIGHT_CLASS_SMALL ? tool : "coś"] do ciała [target] ([strefa_pl(target_zone)]).")
	else
		display_results(user, target, "<span class='notice'>Szukasz przedmiotów w ciele [target] ([strefa_pl(target_zone)])...</span>",
			"[user] szuka przedmiotów w ciele [target] ([strefa_pl(target_zone)]).",
			"[user] szuka czegoś w ciele [target] ([strefa_pl(target_zone)]).")

/datum/surgery_step/handle_cavity/success(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/surgery/surgery)
	var/obj/item/bodypart/chest/CH = target.get_bodypart(BODY_ZONE_CHEST)
	if(tool)
		if(IC || tool.w_class > WEIGHT_CLASS_NORMAL || HAS_TRAIT(tool, TRAIT_NODROP) || istype(tool, /obj/item/organ))
			to_chat(user, "<span class='warning'>Nie możesz zmieścić [tool] w ciele [target] ([strefa_pl(target_zone)])!</span>")
			return 0
		else
			display_results(user, target, "<span class='notice'>Wpychasz [tool] do ciała [target] ([strefa_pl(target_zone)]).</span>",
				"[user] wpycha [tool] do ciała [target] ([strefa_pl(target_zone)])!",
				"[user] wpycha [tool.w_class > WEIGHT_CLASS_SMALL ? tool : "coś"] do ciała [target] ([strefa_pl(target_zone)]).")
			user.transferItemToLoc(tool, target, TRUE)
			CH.cavity_item = tool
			return 1
	else
		if(IC)
			display_results(user, target, "<span class='notice'>Wyciągasz [IC] z ciała [target] ([strefa_pl(target_zone)]).</span>",
				"[user] wyciąga [IC] z ciała [target] ([strefa_pl(target_zone)])!",
				"[user] wyciąga [IC.w_class > WEIGHT_CLASS_SMALL ? IC : "coś"] z ciała [target] ([strefa_pl(target_zone)]).")
			user.put_in_hands(IC)
			CH.cavity_item = null
			return 1
		else
			to_chat(user, "<span class='warning'>Nie znajdujesz niczego w ciele [target] ([strefa_pl(target_zone)]).</span>")
			return 0
