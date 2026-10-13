//Alium nests. Essentially beds with an unbuckle delay that only aliums can buckle mobs to.

/obj/structure/bed/nest
	name = "alien nest"
	desc = "It's a gruesome pile of thick, sticky resin shaped like a nest."
	icon = 'icons/obj/smooth_structures/alien/nest.dmi'
	icon_state = "nest"
	max_integrity = 120
	smooth = SMOOTH_TRUE
	can_be_unanchored = FALSE
	canSmoothWith = null
	buildstacktype = null
	flags_1 = NODECONSTRUCT_1
	bolts = FALSE
	var/static/mutable_appearance/nest_overlay = mutable_appearance('icons/mob/alien.dmi', "nestoverlay", LYING_MOB_LAYER)

/obj/structure/bed/nest/user_unbuckle_mob(mob/living/buckled_mob, mob/living/user)
	if(has_buckled_mobs())
		for(var/buck in buckled_mobs) //breaking a nest releases all the buckled mobs, because the nest isn't holding them down anymore
			var/mob/living/M = buck

			if(user.getorgan(/obj/item/organ/alien/plasmavessel))
				unbuckle_mob(M)
				add_fingerprint(user)
				return

			if(M != user)
				M.visible_message(\
					"[user.name] wyciąga [M.name] z lepkiego gniazda!",\
					"<span class='notice'>[user.name] wyciąga cię z galaretowatej żywicy.</span>",\
					"<span class='italics'>Słyszysz mlaskanie...</span>")
			else
				M.visible_message(\
					"<span class='warning'>[M.name] próbuje wyrwać się z galaretowatej żywicy!</span>",\
					"<span class='notice'>Próbujesz wyrwać się z galaretowatej żywicy... (Nie ruszaj się przez dwie minuty.)</span>",\
					"<span class='italics'>Słyszysz mlaskanie...</span>")
				if(!do_after(M, 1200, target = src))
					if(M?.buckled)
						to_chat(M, "<span class='warning'>Nie udaje ci się uwolnić!</span>")
					return
				if(!M.buckled)
					return
				M.visible_message(\
					"<span class='warning'>[M.name] wyrywa się z galaretowatej żywicy!</span>",\
					"<span class='notice'>Wyrywasz się z galaretowatej żywicy!</span>",\
					"<span class='italics'>Słyszysz mlaskanie...</span>")

			unbuckle_mob(M)
			add_fingerprint(user)

/obj/structure/bed/nest/user_buckle_mob(mob/living/M, mob/living/user, check_loc = TRUE)
	if(!ismob(M) || (get_dist(src, user) > 1) || (M.loc != src.loc) || user.incapacitated() || M.buckled)
		return

	if(M.getorgan(/obj/item/organ/alien/plasmavessel))
		return
	if(!user.getorgan(/obj/item/organ/alien/plasmavessel))
		return

	if(has_buckled_mobs())
		unbuckle_all_mobs()

	if(buckle_mob(M))
		M.visible_message(\
			"[user.name] wydziela gęstą, obrzydliwą maź, unieruchamiając [M.name] w [src]!",\
			"<span class='danger'>[user.name] oblewa cię cuchnącą żywicą, więżąc cię w [src]!</span>",\
			"<span class='italics'>Słyszysz mlaskanie...</span>")

/obj/structure/bed/nest/post_buckle_mob(mob/living/M)
	M.pixel_y = M.base_pixel_y
	M.pixel_x = M.base_pixel_x + 2
	M.layer = BELOW_MOB_LAYER
	add_overlay(nest_overlay)

/obj/structure/bed/nest/post_unbuckle_mob(mob/living/M)
	M.pixel_x = M.base_pixel_x + M.get_standard_pixel_x_offset(M.lying)
	M.pixel_y = M.base_pixel_y + M.get_standard_pixel_y_offset(M.lying)
	M.layer = initial(M.layer)
	cut_overlay(nest_overlay)

/obj/structure/bed/nest/play_attack_sound(damage_amount, damage_type = BRUTE, damage_flag = 0)
	switch(damage_type)
		if(BRUTE)
			playsound(loc, 'sound/effects/attackblob.ogg', 100, 1)
		if(BURN)
			playsound(loc, 'sound/items/welder.ogg', 100, 1)

/obj/structure/bed/nest/attack_alien(mob/living/carbon/alien/user)
	if(!user.combat_mode)
		return attack_hand(user)
	else
		return ..()
