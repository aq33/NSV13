/datum/surgery/organ_manipulation
	name = "organ manipulation"
	target_mobtypes = list(/mob/living/carbon/human, /mob/living/carbon/monkey)
	possible_locs = list(BODY_ZONE_CHEST, BODY_ZONE_HEAD)
	requires_real_bodypart = 1
	steps = list(
		/datum/surgery_step/incise,
		/datum/surgery_step/retract_skin,
		/datum/surgery_step/saw,
		/datum/surgery_step/clamp_bleeders,
		/datum/surgery_step/incise,
		/datum/surgery_step/manipulate_organs,
		//there should be bone fixing
		/datum/surgery_step/close
		)

/datum/surgery/organ_manipulation/soft
	possible_locs = list(BODY_ZONE_PRECISE_GROIN, BODY_ZONE_PRECISE_EYES, BODY_ZONE_PRECISE_MOUTH, BODY_ZONE_L_ARM, BODY_ZONE_R_ARM)
	self_operable = TRUE
	steps = list(
		/datum/surgery_step/incise,
		/datum/surgery_step/retract_skin,
		/datum/surgery_step/clamp_bleeders,
		/datum/surgery_step/incise,
		/datum/surgery_step/manipulate_organs,
		/datum/surgery_step/close
		)

/datum/surgery/organ_manipulation/alien
	name = "alien organ manipulation"
	possible_locs = list(BODY_ZONE_CHEST, BODY_ZONE_HEAD, BODY_ZONE_PRECISE_GROIN, BODY_ZONE_PRECISE_EYES, BODY_ZONE_PRECISE_MOUTH, BODY_ZONE_L_ARM, BODY_ZONE_R_ARM)
	target_mobtypes = list(/mob/living/carbon/alien/humanoid)
	steps = list(
		/datum/surgery_step/saw,
		/datum/surgery_step/incise,
		/datum/surgery_step/retract_skin,
		/datum/surgery_step/saw,
		/datum/surgery_step/manipulate_organs,
		/datum/surgery_step/close
		)

/datum/surgery/organ_manipulation/mechanic
	name = "prosthesis organ manipulation"
	possible_locs = list(BODY_ZONE_CHEST, BODY_ZONE_HEAD)
	requires_bodypart_type = BODYTYPE_ROBOTIC
	lying_required = FALSE
	self_operable = TRUE
	speed_modifier = 0.8 //on a surgery bed you can do prosthetic manipulation relatively risk-free
	steps = list(
		/datum/surgery_step/mechanic_open,
		/datum/surgery_step/open_hatch,
		/datum/surgery_step/mechanic_unwrench,
		/datum/surgery_step/prepare_electronics,
		/datum/surgery_step/manipulate_organs,
		/datum/surgery_step/mechanic_wrench,
		/datum/surgery_step/mechanic_close
		)

/datum/surgery/organ_manipulation/mechanic/soft
	possible_locs = list(BODY_ZONE_PRECISE_GROIN, BODY_ZONE_PRECISE_EYES, BODY_ZONE_PRECISE_MOUTH, BODY_ZONE_L_ARM, BODY_ZONE_R_ARM)
	steps = list(
		/datum/surgery_step/mechanic_open,
		/datum/surgery_step/open_hatch,
		/datum/surgery_step/prepare_electronics,
		/datum/surgery_step/manipulate_organs,
		/datum/surgery_step/mechanic_close
		)

/datum/surgery_step/manipulate_organs
	time = 64
	name = "manipulate organs"
	repeatable = 1
	implements = list(/obj/item/organ = 100, /obj/item/organ_storage = 100)
	var/implements_extract = list(TOOL_HEMOSTAT = 100, TOOL_CROWBAR = 55)
	var/current_type
	var/obj/item/organ/I = null
	preop_sound = 'sound/surgery/organ2.ogg'
	success_sound = 'sound/surgery/organ1.ogg'

/datum/surgery_step/manipulate_organs/New()
	..()
	implements = implements + implements_extract

/datum/surgery_step/manipulate_organs/preop(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	I = null
	if(istype(tool, /obj/item/organ_storage))
		if(!tool.contents.len)
			to_chat(user, "<span class='notice'>W [tool] nic nie ma!</span>")
			return -1
		I = tool.contents[1]
		if(!isorgan(I))
			to_chat(user, "<span class='notice'>Nie możesz włożyć [I] do ciała [target] ([strefa_pl(target_zone)])!</span>")
			return -1
		tool = I
	if(isorgan(tool))
		current_type = "insert"
		I = tool
		if(target_zone != I.zone || target.getorganslot(I.slot))
			to_chat(user, "<span class='notice'>W ciele [target] ([strefa_pl(target_zone)]) nie ma miejsca na [I]!</span>")
			return -1
		if(istype(I, /obj/item/organ/brain/positron))
			var/obj/item/bodypart/affected = target.get_bodypart(check_zone(I.zone))
			if(!affected)
				return -1
			if(IS_ORGANIC_LIMB(affected))
				to_chat(user, "<span class='notice'>Nie możesz włożyć [I] do mięsnej obudowy!</span>")
				return -1
			if(!isipc(target))
				to_chat(user, "<span class='notice'>[target] nie ma odpowiednich złączy, by połączyć się z [I].</span>")
				return -1
		var/obj/item/organ/meatslab = tool
		if(!meatslab.useable)
			to_chat(user, "<span class='warning'>[I] wygląda na pogryziony, nie możesz tego użyć!</span>")
			return -1
		display_results(user, target, "<span class='notice'>Zaczynasz wkładać [tool] do ciała [target] ([strefa_pl(target_zone)])...</span>",
			"<span class='notice'>[user] zaczyna wkładać [tool] do ciała [target] ([strefa_pl(target_zone)]).</span>",
			"<span class='notice'>[user] zaczyna coś wkładać do ciała [target] ([strefa_pl(target_zone)]).</span>")

	else if(implement_type in implements_extract)
		current_type = "extract"
		var/list/organs = target.getorganszone(target_zone)
		var/mob/living/simple_animal/horror/H = target.has_horror_inside() // AQ EDIT - Yogstation#13033
		if(H)
			user.visible_message("[user] zaczyna wyciągać [H] z ciała [target].",
				"<span class='notice'>Zaczynasz wyciągać [H] z ciała [target]...</span>")
			return TRUE
		if(!organs.len)
			to_chat(user, "<span class='notice'>W ciele [target] ([strefa_pl(target_zone)]) nie ma narządów, które można usunąć!</span>")
			return -1
		else
			for(var/obj/item/organ/O in organs)
				O.on_find(user)
				organs -= O
				organs[O.name] = O

			I = input("Który narząd usunąć?", "Surgery", null, null) as null|anything in sortList(organs)
			if(I && user && target && user.Adjacent(target) && user.get_active_held_item() == tool)
				I = organs[I]
				if(!I)
					return -1
				display_results(user, target, "<span class='notice'>Zaczynasz wydobywać [I] z ciała [target] ([strefa_pl(target_zone)])...</span>",
					"[user] zaczyna wydobywać [I] z ciała [target] ([strefa_pl(target_zone)]).",
					"[user] zaczyna coś wydobywać z ciała [target] ([strefa_pl(target_zone)]).")
			else
				return -1

/datum/surgery_step/manipulate_organs/success(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	if(current_type == "insert")
		if(istype(tool, /obj/item/organ_storage))
			I = tool.contents[1]
			tool.icon_state = initial(tool.icon_state)
			tool.desc = initial(tool.desc)
			tool.cut_overlays()
			tool = I
		else
			I = tool
		user.temporarilyRemoveItemFromInventory(I, TRUE)
		I.Insert(target)
		display_results(user, target, "<span class='notice'>Wkładasz [tool] do ciała [target] ([strefa_pl(target_zone)]).</span>",
			"[user] wkłada [tool] do ciała [target] ([strefa_pl(target_zone)])!",
			"[user] wkłada coś do ciała [target] ([strefa_pl(target_zone)])!")

	else if(current_type == "extract")
		var/mob/living/simple_animal/horror/H = target.has_horror_inside() // AQ EDIT - Yogstation#13033
		if(H && H.victim == target)
			user.visible_message("[user] wyciąga [H] z ciała [target]!",
				"<span class='notice'>Udało ci się wyciągnąć [H] z ciała [target].</span>")
			log_combat(user, target, "surgically removed [H] from", addition="COMBAT MODE: [uppertext(user.combat_mode)]")
			H.leave_victim()
			return FALSE
		if(istype(I, /obj/item/organ/shadowtumor/thrall)) // AQ EDIT - darkspawn z Yogstation: przytomny thrall odpycha operujących
			var/obj/item/organ/shadowtumor/thrall/tumor = I
			if(tumor.resist(target))
				return FALSE
		if(I && I.owner == target)
			display_results(user, target, "<span class='notice'>Pomyślnie wydobywasz [I] z ciała [target] ([strefa_pl(target_zone)]).</span>",
				"[user] pomyślnie wydobywa [I] z ciała [target] ([strefa_pl(target_zone)])!",
				"[user] pomyślnie wydobywa coś z ciała [target] ([strefa_pl(target_zone)])!")
			log_combat(user, target, "surgically removed [I.name] from", addition="INTENT: [uppertext(user.a_intent)]")
			I.Remove(target)
			I.forceMove(get_turf(target))
		else
			display_results(user, target, "<span class='notice'>Nie możesz niczego wydobyć z ciała [target] ([strefa_pl(target_zone)])!</span>",
				"[user] nie może niczego wydobyć z ciała [target] ([strefa_pl(target_zone)])!",
				"[user] nie może niczego wydobyć z ciała [target] ([strefa_pl(target_zone)])!")
	return 0
