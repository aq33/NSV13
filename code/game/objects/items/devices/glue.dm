/obj/item/syndie_glue
	name = "bottle of super glue"
	desc = "A black market brand of high strength adhesive, rarely sold to the public. Do not ingest."
	icon = 'icons/obj/tools.dmi'
	icon_state	= "glue"
	w_class = WEIGHT_CLASS_SMALL
	var/uses = 1

/obj/item/syndie_glue/suicide_act(mob/living/carbon/M)
	return //todo

/obj/item/syndie_glue/afterattack(atom/target, mob/user, proximity)
	. = ..()
	if(!proximity || !target)
		return
	else
		if(uses == 0)
			to_chat(user, "<span class='warning'>Butelka kleju jest pusta!</span>")
			return
		if(istype(target, /obj/item))
			var/obj/item/I = target
			if(HAS_TRAIT_FROM(I, TRAIT_NODROP, GLUED_ITEM_TRAIT))
				to_chat(user, "<span class='warning'>[I] już się klei!</span>")
				return
			uses -= 1
			ADD_TRAIT(I, TRAIT_NODROP, GLUED_ITEM_TRAIT)
			I.desc += " Wygląda na lepki."
			to_chat(user, "<span class='notice'>Smarujesz [I] klejem, przez co staje się niesamowicie lepki!</span>")
			if(uses == 0)
				icon_state = "glue_used"
				name = "empty bottle of super glue"
			return
