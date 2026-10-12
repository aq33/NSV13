/datum/surgery/embedded_removal
	name = "removal of embedded objects"
	steps = list(/datum/surgery_step/incise, /datum/surgery_step/remove_object)
	possible_locs = list(BODY_ZONE_R_ARM,BODY_ZONE_L_ARM,BODY_ZONE_R_LEG,BODY_ZONE_L_LEG,BODY_ZONE_CHEST,BODY_ZONE_HEAD)
	self_operable = TRUE


/datum/surgery_step/remove_object
	name = "remove embedded objects"
	time = 32
	accept_hand = 1
	var/obj/item/bodypart/L = null


/datum/surgery_step/remove_object/preop(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	L = surgery.operated_bodypart
	if(L)
		user.visible_message("[user] szuka ciał obcych w ciele [target] ([strefa_pl(user.zone_selected)]).", "<span class='notice'>Szukasz ciał obcych w ciele [target] ([strefa_pl(user.zone_selected)])...</span>")
		display_results(user, target, "<span class='notice'>Szukasz ciał obcych w ciele [target] ([strefa_pl(user.zone_selected)])...</span>",
			"[user] szuka ciał obcych w ciele [target] ([strefa_pl(user.zone_selected)]).",
			"[user] szuka czegoś w ciele [target] ([strefa_pl(user.zone_selected)]).")
	else
		user.visible_message("[user] szuka u [target] części ciała: [strefa_pl(user.zone_selected)].", "<span class='notice'>Szukasz u [target] części ciała: [strefa_pl(user.zone_selected)]...</span>")


/datum/surgery_step/remove_object/success(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	if(L)
		if(ishuman(target))
			var/mob/living/carbon/human/H = target
			var/objects = 0
			for(var/obj/item/I in L.embedded_objects)
				objects++
				H.remove_embedded_object(I)

			if(objects > 0)
				display_results(user, target, "<span class='notice'>Pomyślnie usuwasz ciała obce ([objects]) z [H] ([L.name]).</span>",
					"[user] pomyślnie usuwa ciała obce ([objects]) z [H] ([L])!",
					"[user] pomyślnie usuwa ciała obce ([objects]) z [H] ([L])!")
			else
				to_chat(user, "<span class='warning'>Nie znajdujesz żadnych ciał obcych w [H] ([L])!</span>")

	else
		to_chat(user, "<span class='warning'>Nie możesz znaleźć u [target] części ciała ([strefa_pl(user.zone_selected)]), a co dopiero tkwiących w niej ciał obcych!</span>")

	return 1
