/datum/surgery_step/extract_implant/success(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	if(I)
		if (QDELETED(I)) // yogs: properly handle self-deleting implants
			display_results(user, target, "<span class='notice'>You remove [I] from [target]'s [target_zone], destroying it in the process!</span>",
				"[user] removes [I] from [target]'s [target_zone], destroying it in the process!",
				"[user] removes something from [target]'s [target_zone], destroying it in the process!")
		else
			display_results(user, target, "<span class='notice'>You successfully remove [I] from [target]'s [target_zone].</span>",
				"[user] successfully removes [I] from [target]'s [target_zone]!",
				"[user] successfully removes something from [target]'s [target_zone]!")
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
				display_results(user, target, "<span class='notice'>You place [I] into [case].</span>",
					"[user] places [I] into [case]!",
					"[user] places it into [case]!")
			else
				qdel(I)
