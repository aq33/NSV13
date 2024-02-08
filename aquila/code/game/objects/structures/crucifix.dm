/*****************************\
|*********** KRZYŻ ***********|
\*****************************/
#define VIABLE_MOB_CHECK(X) (isliving(X) && !issilicon(X) && !isbot(X))

/obj/structure/kitchenspike/crucifix
	name = "krzyż"
	icon = 'aquila/icons/obj/structures/tallstructures.dmi'
	icon_state = "crucifix"
	desc = "Degeneraci tacy jak ty powinni być ukrzyżowani."
	density = TRUE
	anchored = TRUE
	buckle_lying = 0
	can_buckle = 1
	max_integrity = 250
	layer = ABOVE_MOB_LAYER

/obj/structure/kitchenspike/crucifix/crowbar_act(mob/living/user, obj/item/I)
	return

/obj/structure/kitchenspike/crucifix/wrench_act(mob/living/user, obj/item/I)
	if(has_buckled_mobs())
		to_chat(user, "<span class='notice'>Nie możesz tego zrobić póki ktoś jest na krzyżu!</span>")
		return TRUE

	if(I.use_tool(src, user, 20, volume=100))
		to_chat(user, "<span class='notice'>Rozkręcasz krzyż.</span>")
		deconstruct(TRUE)
	return TRUE

/obj/structure/kitchenspike/crucifix/attack_hand(mob/user)
	if(VIABLE_MOB_CHECK(user.pulling) && user.a_intent == INTENT_GRAB && !has_buckled_mobs())
		var/mob/living/L = user.pulling
		if(do_mob(user, src, 120))
			if(has_buckled_mobs())
				return
			if(L.buckled)
				return
			if(user.pulling != L)
				return
			L.visible_message("<span class='danger'>[user] ukrzyżowuje [L]!</span>", "<span class='userdanger'>[user] ukrzyżowuje ciebie!</span>", "<span class='italics'>Słyszysz jak ktoś jest na coś nabijany!</span>")
			L.forceMove(drop_location())
			L.emote("scream")
			L.adjustBruteLoss(30)
			L.setDir(2)
			L.pixel_y = 20
			L.layer = 4.2
			buckle_mob(L, force=1)
	else if (has_buckled_mobs())
		for(var/mob/living/L in buckled_mobs)
			user_unbuckle_mob(L, user)
	else
		..()

/obj/structure/kitchenspike/crucifix/user_unbuckle_mob(mob/living/buckled_mob, mob/living/carbon/human/user)
	if(buckled_mob)
		var/mob/living/M = buckled_mob
		if(M != user)
			M.visible_message(\
				"[user] próbuje zdjąć [M] z [src]!",\
				"<span class='notice'>[user] usiłuje zdjąć ciebie z [src], otwierając świeże rany!</span>",\
				"<span class='italics'>Słychać miekki, mokry dźwięk.</span>")
			if(!do_after(user, 300, target = src))
				if(M?.buckled)
					M.visible_message(\
					"[user] nie udaje się uwolnić [M]!",\
					"<span class='notice'>[user] nie zdołał zdjąć ciebie z [src].</span>")
				return

		else
			M.visible_message(\
			"<span class='warning'>[M] usiłuje uwolnić z [src]!</span>",\
			"<span class='notice'>Walczysz, żeby się uwolnić ze [src], rozcinając twoje rany! (nie ruszaj się przez dwie minuty.)</span>",\
			"<span class='italics'>Słyszysz miekki, mokry dźwięk.</span>")
			M.adjustBruteLoss(30)
			if(!do_after(M, 1200, target = src))
				if(M && M.buckled)
					to_chat(M, "<span class='warning'>Nie udało ci się uwolnić!</span>")
				return
		if(!M.buckled)
			return
		release_mob_c(M)

/obj/structure/kitchenspike/crucifix/proc/release_mob_c(mob/living/M)
	M.adjustBruteLoss(30)
	src.visible_message(text("<span class='danger'>[M] spada z [src]!</span>"))
	unbuckle_mob(M,force=1)
	M.emote("scream")
	M.AdjustParalyzed(20)
	M.pixel_y = -20
	M.layer = 4

/obj/structure/kitchenspike/crucifix/deconstruct(disassembled = TRUE)
	new /obj/item/stack/sheet/mineral/wood(src.loc, 5)
	qdel(src)

#undef VIABLE_MOB_CHECK
