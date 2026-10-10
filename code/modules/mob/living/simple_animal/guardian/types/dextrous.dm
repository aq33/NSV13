//Dextrous
/mob/living/simple_animal/hostile/guardian/dextrous
	melee_damage = 10
	damage_coeff = list(BRUTE = 0.75, BURN = 0.75, TOX = 0.75, CLONE = 0.75, STAMINA = 0, OXY = 0.75)
	playstyle_string = "<span class='holoparasite'>Jako typ <b>dextrous</b> możesz trzymać przedmioty, przechowywać jeden w sobie i masz średnią odporność na obrażenia, ale zadajesz niewielkie obrażenia. Powrót do użytkownika i ściągnięcie smyczą zmuszają cię do upuszczenia nieschowanych przedmiotów!</span>"
	magic_fluff_string = "<span class='holoparasite'>...I wyciągasz Drona, zręcznego mistrza budowy i napraw.</span>"
	tech_fluff_string = "<span class='holoparasite'>Sekwencja startowa zakończona. Wczytano zręczne moduły bojowe. Rój holoparazytów aktywny.</span>"
	carp_fluff_string = "<span class='holoparasite'>KARP KARP KARP! Złowiony! Potrafi trzymać rzeczy w płetwach, tak jakby.</span>"
	hive_fluff_string = "<span class='holoparasite'>Masa wydaje się zdolna do... trzymania rzeczy?</span>"
	dextrous = TRUE
	held_items = list(null, null)
	var/obj/item/internal_storage //what we're storing within ourself

/mob/living/simple_animal/hostile/guardian/dextrous/death(gibbed)
	..()
	if(internal_storage)
		dropItemToGround(internal_storage)

/mob/living/simple_animal/hostile/guardian/dextrous/examine(mob/user)
	if(dextrous)
		. = list("<span class='info'>*To [icon2html(src)] <b>[src]</b>!\n[desc]")
		for(var/obj/item/I in held_items)
			if(!(I.item_flags & ABSTRACT))
				. += "Trzyma [I.get_examine_string(user)] ([get_held_index_name(get_held_index_of_item(I))])."
		if(internal_storage && !(internal_storage.item_flags & ABSTRACT))
			. += "W wewnętrznym schowku trzyma [internal_storage.get_examine_string(user)]."
		. += "</span>"
	else
		return ..()

/mob/living/simple_animal/hostile/guardian/dextrous/Recall(forced)
	if(!summoner || loc == summoner || (cooldown > world.time && !forced))
		return FALSE
	drop_all_held_items()
	return ..() //lose items, then return

/mob/living/simple_animal/hostile/guardian/dextrous/snapback()
	if(summoner && !(get_dist(get_turf(summoner),get_turf(src)) <= range))
		drop_all_held_items()
		..() //lose items, then return

//SLOT HANDLING BULLSHIT FOR INTERNAL STORAGE
/mob/living/simple_animal/hostile/guardian/dextrous/doUnEquip(obj/item/I, force)
	if(..())
		update_inv_hands()
		if(I == internal_storage)
			internal_storage = null
			update_inv_internal_storage()
		return 1
	return 0

/mob/living/simple_animal/hostile/guardian/dextrous/can_equip(obj/item/I, slot, disable_warning = FALSE, bypass_equip_delay_self = FALSE)
	switch(slot)
		if(ITEM_SLOT_DEX_STORAGE)
			if(internal_storage)
				return 0
			return 1
	..()

/mob/living/simple_animal/hostile/guardian/dextrous/equip_to_slot(obj/item/I, slot)
	if(!..())
		return

	switch(slot)
		if(ITEM_SLOT_DEX_STORAGE)
			internal_storage = I
			update_inv_internal_storage()
		else
			to_chat(src, "<span class='danger'>You are trying to equip this item to an unsupported inventory slot. Report this to a coder!</span>")

/mob/living/simple_animal/hostile/guardian/dextrous/getBackSlot()
	return ITEM_SLOT_DEX_STORAGE

/mob/living/simple_animal/hostile/guardian/dextrous/getBeltSlot()
	return ITEM_SLOT_DEX_STORAGE

/mob/living/simple_animal/hostile/guardian/dextrous/proc/update_inv_internal_storage()
	if(internal_storage && client && hud_used && hud_used.hud_shown)
		internal_storage.screen_loc = ui_id
		client.screen += internal_storage

/mob/living/simple_animal/hostile/guardian/dextrous/regenerate_icons()
	..()
	update_inv_internal_storage()
