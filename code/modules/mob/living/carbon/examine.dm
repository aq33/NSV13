/mob/living/carbon/examine(mob/user)
	var/t_his = p_their()

	. = list("<span class='info'>To jest [icon2html(src, user)] <EM>[src]</EM>!")
	var/obscured = check_obscured_slots()

	if(handcuffed)
		. += "<span class='warning'>Ma założone kajdanki: [handcuffed]!</span>"
	if(legcuffed)
		. += "<span class='warning'>Ma skute nogi: [legcuffed]!</span>"
	if(head)
		. += "Na głowie ma [head.get_examine_string(user)]. "
	if(wear_mask && !(obscured & ITEM_SLOT_MASK))
		. += "Na twarzy ma [wear_mask.get_examine_string(user)]."
	if(wear_neck && !(obscured & ITEM_SLOT_NECK))
		. += "Na szyi ma [wear_neck.get_examine_string(user)]."

	for(var/obj/item/I in held_items)
		if(!(I.item_flags & ABSTRACT))
			. += "W ręce ([get_held_index_name(get_held_index_of_item(I))]) trzyma [I.get_examine_string(user)]."

	if(back)
		. += "Na plecach ma [back.get_examine_string(user)]."
	var/appears_dead = 0
	if(stat == DEAD)
		appears_dead = 1
		if(getorgan(/obj/item/organ/brain))
			. += "<span class='deadsay'>Leży bezwładnie, bez reakcji i bez oznak życia.</span>"
		else if(get_bodypart(BODY_ZONE_HEAD))
			. += "<span class='deadsay'>Wygląda na to, że brakuje mu mózgu.</span>"

	var/list/msg = list("<span class='warning'>")
	var/list/missing = list(BODY_ZONE_HEAD, BODY_ZONE_CHEST, BODY_ZONE_R_ARM, BODY_ZONE_L_ARM, BODY_ZONE_R_LEG, BODY_ZONE_L_LEG)
	var/list/disabled = list()
	for(var/obj/item/bodypart/BP as() in bodyparts)
		if(BP.disabled)
			disabled += BP
		missing -= BP.body_zone
		for(var/obj/item/I in BP.embedded_objects)
			if(I.isEmbedHarmless())
				msg += "<B>Do kończyny ([BP.name]) przylega [icon2html(I, user)] [I]!</B>\n"
			else
				msg += "<B>W kończynie ([BP.name]) tkwi [icon2html(I, user)] [I]!</B>\n"

	for(var/X in disabled)
		var/obj/item/bodypart/BP = X
		var/damage_text
		if(!(BP.get_damage(include_stamina = FALSE) >= BP.max_damage)) //Stamina is disabling the limb
			damage_text = "bezwładny i martwy"
		else
			damage_text = (BP.brute_dam >= BP.burn_dam) ? BP.heavy_brute_msg : BP.heavy_burn_msg
		msg += "<B>[capitalize(t_his)] [BP.name] is [damage_text]!</B>\n"

	for(var/t in missing)
		if(t==BODY_ZONE_HEAD)
			msg += "<span class='deadsay'><B>Brakuje kończyny: [parse_zone(t)]!</B></span>\n"
			continue
		msg += "<span class='warning'><B>Brakuje kończyny: [parse_zone(t)]!</B></span>\n"


	var/temp = getBruteLoss()
	if(!(user == src && src.hal_screwyhud == SCREWYHUD_HEALTHY)) //fake healthy
		if(temp)
			if (temp < 25)
				msg += "Ma drobne siniaki.\n"
			else if (temp < 50)
				msg += "Ma <b>średnie</b> siniaki!\n"
			else
				msg += "<B>Ma poważne siniaki!</B>\n"

		temp = getFireLoss()
		if(temp)
			if (temp < 25)
				msg += "Ma drobne oparzenia.\n"
			else if (temp < 50)
				msg += "Ma <b>średnie</b> oparzenia!\n"
			else
				msg += "<B>Ma poważne oparzenia!</B>\n"

		temp = getCloneLoss()
		if(temp)
			if(temp < 25)
				msg += "Jest lekko zdeformowany.\n"
			else if(temp < 50)
				msg += "Jest <b>średnio</b> zdeformowany!\n"
			else
				msg += "<b>Jest poważnie zdeformowany!</b>\n"

	if(HAS_TRAIT(src, TRAIT_DUMB))
		msg += "Wydaje się niezdarny i niezdolny do myślenia.\n"

	if(fire_stacks > 0)
		msg += "Jest pokryty czymś łatwopalnym.\n"
	if(fire_stacks < 0)
		msg += "Wygląda na trochę przemoczonego.\n"

	if(pulledby?.grab_state)
		msg += "Trzyma go mocny chwyt [pulledby].\n"

	msg += "</span>"

	. += msg.Join("")

	if(!appears_dead)
		if(stat == UNCONSCIOUS)
			. += "Nie reaguje na nic wokół i wydaje się spać."
		else if(InCritical())
			. += "Oddycha płytko i z trudem."

	var/trait_exam = common_trait_examine()
	if(!isnull(trait_exam))
		. += trait_exam

	var/datum/component/mood/mood = src.GetComponent(/datum/component/mood)
	if(mood)
		switch(mood.shown_mood)
			if(-INFINITY to MOOD_LEVEL_SAD4)
				. += "Wygląda na przygnębionego."
			if(MOOD_LEVEL_SAD4 to MOOD_LEVEL_SAD3)
				. += "Wygląda na bardzo smutnego."
			if(MOOD_LEVEL_SAD3 to MOOD_LEVEL_SAD2)
				. += "Wygląda na trochę przybitego."
			if(MOOD_LEVEL_HAPPY2 to MOOD_LEVEL_HAPPY3)
				. += "Wygląda na całkiem szczęśliwego."
			if(MOOD_LEVEL_HAPPY3 to MOOD_LEVEL_HAPPY4)
				. += "Wygląda na bardzo szczęśliwego."
			if(MOOD_LEVEL_HAPPY4 to INFINITY)
				. += "Wygląda na wniebowziętego."
	. += "</span>"
