//////Kitchen Spike
#define VIABLE_MOB_CHECK(X) (isliving(X) && !issilicon(X) && !isbot(X))

/obj/structure/kitchenspike_frame
	name = "meatspike frame"
	icon = 'icons/obj/service/kitchen.dmi'
	icon_state = "spikeframe"
	desc = "The frame of a meat spike."
	density = TRUE
	anchored = FALSE
	max_integrity = 200

/obj/structure/kitchenspike_frame/attackby(obj/item/I, mob/user, params)
	add_fingerprint(user)
	if(default_unfasten_wrench(user, I))
		return
	else if(istype(I, /obj/item/stack/rods))
		var/obj/item/stack/rods/R = I
		if(R.get_amount() >= 4)
			R.use(4)
			to_chat(user, "<span class='notice'>Dodajesz kolce do ramy.</span>")
			var/obj/F = new /obj/structure/kitchenspike(src.loc)
			transfer_fingerprints_to(F)
			qdel(src)
	else if(I.tool_behaviour == TOOL_WELDER)
		if(!I.tool_start_check(user, amount=0))
			return
		to_chat(user, "<span class='notice'>Zaczynasz rozcinać [src]...</span>")
		if(I.use_tool(src, user, 50, volume=50))
			visible_message("<span class='notice'>[user] rozcina [src].</span>",
				"<span class='notice'>Rozcinasz [src] za pomocą [I].</span>",
				"<span class='italics'>Słyszysz spawanie.</span>")
			new /obj/item/stack/sheet/iron(src.loc, 4)
			qdel(src)
		return
	else
		return ..()

/obj/structure/kitchenspike
	name = "meat spike"
	icon = 'icons/obj/service/kitchen.dmi'
	icon_state = "spike"
	desc = "A spike for collecting meat from animals."
	density = TRUE
	anchored = TRUE
	buckle_lying = 0
	can_buckle = 1
	max_integrity = 250

/obj/structure/kitchenspike/attack_paw(mob/user)
	return attack_hand(user)

/obj/structure/kitchenspike/crowbar_act(mob/living/user, obj/item/I)
	if(has_buckled_mobs())
		to_chat(user, "<span class='notice'>Nie możesz tego zrobić, gdy coś wisi na haku!</span>")
		return TRUE

	if(I.use_tool(src, user, 20, volume=100))
		to_chat(user, "<span class='notice'>Wyważasz kolce z ramy.</span>")
		deconstruct(TRUE)
	return TRUE

//ATTACK HAND IGNORING PARENT RETURN VALUE
/obj/structure/kitchenspike/attack_hand(mob/living/user)
	if(VIABLE_MOB_CHECK(user.pulling) && user.combat_mode && !has_buckled_mobs())
		var/mob/living/L = user.pulling
		if(do_mob(user, src, 120))
			if(has_buckled_mobs()) //to prevent spam/queing up attacks
				return
			if(L.buckled)
				return
			if(user.pulling != L)
				return
			playsound(src.loc, 'sound/effects/splat.ogg', 25, 1)
			L.visible_message("<span class='danger'>[user] nabija [L] na hak rzeźnicki!</span>", "<span class='userdanger'>[user] nabija cię na hak rzeźnicki!</span>", "<span class='italics'>Słyszysz mokre mlaśnięcie.</span>")
			L.forceMove(drop_location())
			L.emote("scream")
			L.add_splatter_floor()
			L.adjustBruteLoss(30)
			L.setDir(2)
			buckle_mob(L, force=1)
			var/matrix/m180 = matrix(L.transform)
			m180.Turn(180)
			animate(L, transform = m180, time = 3)
			L.pixel_y = L.get_standard_pixel_y_offset(TRUE)
	else if (has_buckled_mobs())
		for(var/mob/living/L in buckled_mobs)
			user_unbuckle_mob(L, user)
	else
		..()



/obj/structure/kitchenspike/user_buckle_mob(mob/living/M, mob/user, check_loc = TRUE) //Don't want them getting put on the rack other than by spiking
	return

/obj/structure/kitchenspike/user_unbuckle_mob(mob/living/buckled_mob, mob/living/carbon/human/user)
	if(buckled_mob)
		var/mob/living/M = buckled_mob
		if(M != user)
			M.visible_message(\
				"[user] próbuje zdjąć [M] z [src]!",\
				"<span class='notice'>[user] próbuje zdjąć cię z [src], otwierając świeże rany!</span>",\
				"<span class='italics'>Słyszysz mokre mlaśnięcie.</span>")
			if(!do_after(user, 300, target = src))
				if(M?.buckled)
					M.visible_message(\
					"[user] nie udaje się uwolnić [M]!",\
					"<span class='notice'>[user] nie udaje się zdjąć cię z [src].</span>")
				return

		else
			M.visible_message(\
			"<span class='warning'>[M] próbuje uwolnić się z [src]!</span>",\
			"<span class='notice'>Próbujesz uwolnić się z [src], pogarszając swoje rany! (Nie ruszaj się przez dwie minuty.)</span>",\
			"<span class='italics'>Słyszysz mokre mlaskanie..</span>")
			M.adjustBruteLoss(30)
			if(!do_after(M, 1200, target = src))
				if(M && M.buckled)
					to_chat(M, "<span class='warning'>Nie udaje ci się uwolnić!</span>")
				return
		if(!M.buckled)
			return
		release_mob(M)

/obj/structure/kitchenspike/proc/release_mob(mob/living/M)
	var/matrix/m180 = matrix(M.transform)
	m180.Turn(180)
	animate(M, transform = m180, time = 3)
	M.pixel_y = M.base_pixel_y + M.get_standard_pixel_y_offset(TRUE)
	M.adjustBruteLoss(30)
	src.visible_message(text("<span class='danger'>[M] spada z [src]!</span>"))
	unbuckle_mob(M,force=1)
	M.emote("scream")
	M.AdjustParalyzed(20)

/obj/structure/kitchenspike/Destroy()
	if(has_buckled_mobs())
		for(var/mob/living/L in buckled_mobs)
			release_mob(L)
	return ..()

/obj/structure/kitchenspike/deconstruct(disassembled = TRUE)
	if(disassembled)
		var/obj/F = new /obj/structure/kitchenspike_frame(src.loc)
		transfer_fingerprints_to(F)
	else
		new /obj/item/stack/sheet/iron(src.loc, 4)
	new /obj/item/stack/rods(loc, 4)
	qdel(src)

#undef VIABLE_MOB_CHECK
