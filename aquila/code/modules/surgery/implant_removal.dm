/datum/surgery_step/extract_implant/success(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	if(I)
		I.removed(target)
		if (QDELETED(I)) // yogs: properly handle self-deleting implants
			display_results(user, target, "<span class='notice'>Usuwasz [I] z ciała [target] ([strefa_pl(target_zone)]), niszcząc go przy tym!</span>",
				"[user] usuwa [I] z ciała [target] ([strefa_pl(target_zone)]), niszcząc go przy tym!",
				"[user] usuwa coś z ciała [target] ([strefa_pl(target_zone)]), niszcząc to przy tym!")
		else
			display_results(user, target, "<span class='notice'>Pomyślnie usuwasz [I] z ciała [target] ([strefa_pl(target_zone)]).</span>",
				"[user] pomyślnie usuwa [I] z ciała [target] ([strefa_pl(target_zone)])!",
				"[user] pomyślnie usuwa coś z ciała [target] ([strefa_pl(target_zone)])!")
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
	return TRUE
