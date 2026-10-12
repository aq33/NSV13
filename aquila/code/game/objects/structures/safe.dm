// Okno sejfu w TGUI (zamiast HTML z code/game/objects/structures/safe.dm). Mechanika zapadek bez zmian.

/obj/structure/safe/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "Safe", name)
		ui.open()

/obj/structure/safe/ui_state(mob/user)
	return GLOB.physical_state

/obj/structure/safe/ui_data(mob/user)
	var/list/data = list()
	data["open"] = open
	data["dial"] = dial
	data["broken"] = explosion_count > 2
	data["space"] = space
	data["max_space"] = maxspace
	var/list/items = list()
	if(open)
		for(var/i in length(contents) to 1 step -1)
			var/obj/item/item = contents[i]
			items += list(list("name" = item.name, "ref" = REF(item)))
	data["contents"] = items
	return data

/obj/structure/safe/ui_act(action, list/params)
	. = ..()
	if(.)
		return
	if(!ishuman(usr))
		return
	var/mob/living/carbon/human/user = usr
	if(!user.canUseTopic(src, BE_CLOSE))
		return
	var/canhear = user.is_holding_item_of_type(/obj/item/clothing/neck/stethoscope)

	switch(action)
		if("open")
			if(!check_unlocked())
				to_chat(user, "<span class='warning'>Nie da się [open ? "zamknąć" : "otworzyć"] [src], zamek jest zablokowany!</span>")
				return
			to_chat(user, "<span class='notice'>[open ? "Zamykasz" : "Otwierasz"] [src].</span>")
			open = !open
			update_icon()
			return TRUE
		if("turn")
			// Obrót o kilka ząbków to kilka pojedynczych kroków, więc zapadki działają jak przy klikaniu po jednym
			var/steps = clamp(round(text2num(params["steps"])), -10, 10)
			if(!steps)
				return
			for(var/i in 1 to abs(steps))
				if(steps > 0)
					turn_dial_up(user, canhear)
				else
					turn_dial_down(user, canhear)
			return TRUE
		if("retrieve")
			if(!open)
				return
			var/obj/item/item = locate(params["ref"]) in src
			if(item && in_range(src, user))
				user.put_in_hands(item)
				space -= item.w_class
			return TRUE

/// Jeden ząbek w dół (logika z dawnego Topic())
/obj/structure/safe/proc/turn_dial_down(mob/user, canhear)
	dial = decrement(dial)
	if(dial == tumbler_1_pos + 1 || dial == tumbler_1_pos - 71)
		tumbler_1_pos = decrement(tumbler_1_pos)
		if(canhear)
			to_chat(user, "<span class='italics'>You hear a [pick("clack", "scrape", "clank")] from [src].</span>")
		if(tumbler_1_pos == tumbler_2_pos + 37 || tumbler_1_pos == tumbler_2_pos - 35)
			tumbler_2_pos = decrement(tumbler_2_pos)
			if(canhear)
				to_chat(user, "<span class='italics'>You hear a [pick("click", "chink", "clink")] from [src].</span>")
		check_unlocked(user, canhear)

/// Jeden ząbek w górę (logika z dawnego Topic())
/obj/structure/safe/proc/turn_dial_up(mob/user, canhear)
	dial = increment(dial)
	if(dial == tumbler_1_pos - 1 || dial == tumbler_1_pos + 71)
		tumbler_1_pos = increment(tumbler_1_pos)
		if(canhear)
			to_chat(user, "<span class='italics'>You hear a [pick("clack", "scrape", "clank")] from [src].</span>")
		if(tumbler_1_pos == tumbler_2_pos - 37 || tumbler_1_pos == tumbler_2_pos + 35)
			tumbler_2_pos = increment(tumbler_2_pos)
			if(canhear)
				to_chat(user, "<span class='italics'>You hear a [pick("click", "chink", "clink")] from [src].</span>")
		check_unlocked(user, canhear)
