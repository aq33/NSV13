
/////AUGMENTATION SURGERIES//////


//SURGERY STEPS

/datum/surgery_step/replace_limb
	name = "replace limb"
	implements = list(/obj/item/bodypart = 100, /obj/item/organ_storage = 100)
	time = 32
	var/obj/item/bodypart/L = null // L because "limb"


/datum/surgery_step/replace_limb/preop(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	if(istype(tool, /obj/item/organ_storage) && istype(tool.contents[1], /obj/item/bodypart))
		tool = tool.contents[1]
	var/obj/item/bodypart/aug = tool
	if(IS_ORGANIC_LIMB(aug))
		to_chat(user, "<span class='warning'>To nie jest augmentacja, głuptasie!</span>")
		return -1
	if(aug.body_zone != target_zone)
		to_chat(user, "<span class='warning'>[tool] nie pasuje do tej części ciała ([strefa_pl(target_zone)]).</span>")
		return -1
	L = surgery.operated_bodypart
	if(L)
		if(L.is_disabled() == BODYPART_DISABLED_PARALYSIS)
			to_chat(user, "<span class='warning'>Nie możesz augmentować sparaliżowanej kończyny!</span>")
			return -1
		else
			display_results(user, target, "<span class ='notice'>Zaczynasz augmentować [strefa_pl(user.zone_selected, TRUE)] [target]...</span>",
				"[user] zaczyna augmentować [strefa_pl(user.zone_selected, TRUE)] [target] za pomocą [aug].",
				"[user] zaczyna augmentować [strefa_pl(user.zone_selected, TRUE)] [target].")
	else
		user.visible_message("[user] szuka u [target] części ciała: [strefa_pl(user.zone_selected)].", "<span class ='notice'>Szukasz u [target] części ciała: [strefa_pl(user.zone_selected)]...</span>")


//ACTUAL SURGERIES

/datum/surgery/augmentation
	name = "Augmentation"
	steps = list(/datum/surgery_step/incise, /datum/surgery_step/clamp_bleeders, /datum/surgery_step/retract_skin, /datum/surgery_step/replace_limb)
	target_mobtypes = list(/mob/living/carbon/human)
	possible_locs = list(BODY_ZONE_R_ARM,BODY_ZONE_L_ARM,BODY_ZONE_R_LEG,BODY_ZONE_L_LEG,BODY_ZONE_CHEST,BODY_ZONE_HEAD)
	requires_real_bodypart = TRUE



/datum/surgery/augmentation/can_start(mob/user, mob/living/carbon/target)
	return ..() && !isoozeling(target)

//SURGERY STEP SUCCESSES

/datum/surgery_step/replace_limb/success(mob/user, mob/living/carbon/target, target_zone, obj/item/bodypart/tool, datum/surgery/surgery)
	if(L)
		if(istype(tool, /obj/item/organ_storage))
			tool.icon_state = initial(tool.icon_state)
			tool.desc = initial(tool.desc)
			tool.cut_overlays()
			tool = tool.contents[1]
		if(istype(tool) && user.temporarilyRemoveItemFromInventory(tool))
			tool.replace_limb(target, TRUE)
		display_results(user, target, "<span class='notice'>Pomyślnie augmentujesz [strefa_pl(target_zone, TRUE)] [target].</span>",
			"[user] pomyślnie augmentuje [strefa_pl(target_zone, TRUE)] [target] za pomocą [tool]!",
			"[user] pomyślnie augmentuje [strefa_pl(target_zone, TRUE)] [target]!")
		log_combat(user, target, "augmented", addition="by giving him new [parse_zone(target_zone)] INTENT: [uppertext(user.a_intent)]")
	else
		to_chat(user, "<span class='warning'>[target] nie ma tam organicznej części ciała ([strefa_pl(target_zone)])!</span>")
	return TRUE
