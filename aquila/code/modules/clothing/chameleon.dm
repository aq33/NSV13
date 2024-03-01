/datum/action/item_action/chameleon/change/update_item(obj/item/picked_item, obj/item/target = src.target) //yogs -- add support for cham hardsuits
	target.name = initial(picked_item.name)
	target.desc = initial(picked_item.desc)
	target.icon_state = initial(picked_item.icon_state)
	if(isitem(target))
		var/obj/item/I = target
		I.item_state = initial(picked_item.item_state)
		//I.item_color = initial(picked_item.item_color)
		//I.alternate_worn_icon = initial(picked_item.alternate_worn_icon)
		if(istype(I, /obj/item/clothing) && istype(initial(picked_item), /obj/item/clothing))
			var/obj/item/clothing/CL = I
			var/obj/item/clothing/PCL = picked_item
			CL.flags_cover = initial(PCL.flags_cover)
	if(istype(target, /obj/item/clothing/suit/space/hardsuit/infiltration)) //YOGS START
		var/obj/item/clothing/suit/space/hardsuit/infiltration/I = target
		var/obj/item/clothing/suit/space/hardsuit/HS = picked_item
		var/obj/item/clothing/head/helmet/helmet = initial(HS.helmettype)
		//I.head_piece.initial_state = initial(helmet.icon_state)
		update_item(helmet, I.head_piece)
		I.head_piece.update_icon()
		qdel(helmet)
		//YOGS END
	target.icon = initial(picked_item.icon)
