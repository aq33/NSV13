/obj/effect/proc_holder/spell/targeted/barnyardcurse
	name = "Curse of the Barnyard"
	desc = "This spell dooms an unlucky soul to possess the speech and facial attributes of a barnyard animal."
	school = "transmutation"
	charge_type = "recharge"
	charge_max	= 150
	clothes_req = FALSE
	stat_allowed = FALSE
	invocation = "KN'A FTAGHU, PUCK 'BTHNK!"
	invocation_type = "shout"
	range = 7
	cooldown_min = 30
	selection_type = "range"
	var/static/list/compatible_mobs_typecache = typecacheof(list(/mob/living/carbon/human, /mob/living/carbon/monkey))

	action_icon_state = "barn"

/obj/effect/proc_holder/spell/targeted/barnyardcurse/cast(list/targets, mob/user = usr)
	if(!length(targets))
		to_chat(user, "<span class='notice'>W zasięgu nie znaleziono celu.</span>")
		return

	var/mob/living/carbon/target = targets[1]


	if(!compatible_mobs_typecache[target.type])
		to_chat(user, "<span class='notice'>Nie możesz przekląć głowy [target]!</span>")
		return

	if(!(target in oview(range)))
		to_chat(user, "<span class='notice'>Cel jest za daleko!</span>")
		return

	if(target.anti_magic_check() || HAS_TRAIT(target, TRAIT_WARDED))
		to_chat(user, "<span class='warning'>Zaklęcie nie zadziałało!</span>")
		target.visible_message("<span class='danger'>Twarz [target] staje w płomieniach, które natychmiast rozchodzą się na zewnątrz, nie robiąc [target] krzywdy!</span>", \
						   "<span class='danger'>Twoja twarz zaczyna płonąć, ale płomienie odpiera twoja ochrona antymagiczna!</span>")
		return

	var/list/masks = list(/obj/item/clothing/mask/pig/cursed, /obj/item/clothing/mask/cowmask/cursed, /obj/item/clothing/mask/horsehead/cursed)

	var/choice = pick(masks)
	var/obj/item/clothing/mask/magichead = new choice(get_turf(target))
	target.visible_message("<span class='danger'>Twarz [target] staje w płomieniach, a jej miejsce zajmuje głowa zwierzęcia z zagrody!</span>", \
						   "<span class='danger'>Twoja twarz płonie, a chwilę po ogniu uświadamiasz sobie, że masz twarz zwierzęcia z zagrody!</span>")
	if(!target.dropItemToGround(target.wear_mask))
		qdel(target.wear_mask)
	target.equip_to_slot_if_possible(magichead, ITEM_SLOT_MASK, 1, 1)

	target.flash_act()
