/obj/item/lipstick
	gender = PLURAL
	name = "red lipstick"
	desc = "A generic brand of lipstick."
	icon = 'icons/obj/items_and_weapons.dmi'
	icon_state = "lipstick"
	w_class = WEIGHT_CLASS_TINY
	var/colour = "red"
	var/open = FALSE

/obj/item/lipstick/purple
	name = "purple lipstick"
	colour = "purple"

/obj/item/lipstick/jade
	//It's still called Jade, but theres no HTML color for jade, so we use lime.
	name = "jade lipstick"
	colour = "lime"

/obj/item/lipstick/black
	name = "black lipstick"
	colour = "black"

/obj/item/lipstick/random
	name = "lipstick"
	icon_state = "random_lipstick"

/obj/item/lipstick/random/Initialize(mapload)
	. = ..()
	icon_state = "lipstick"
	colour = pick("red","purple","lime","black","green","blue","white")
	name = "[colour] lipstick"

/obj/item/lipstick/attack_self(mob/user)
	cut_overlays()
	to_chat(user, "<span class='notice'>[open ? "Zakręcasz" : "Odkręcasz"] [src].</span>")
	open = !open
	if(open)
		var/mutable_appearance/colored_overlay = mutable_appearance(icon, "lipstick_uncap_color")
		colored_overlay.color = colour
		icon_state = "lipstick_uncap"
		add_overlay(colored_overlay)
	else
		icon_state = "lipstick"

/obj/item/lipstick/attack(mob/M, mob/user)
	if(!open)
		return

	if(!ismob(M))
		return

	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		if(H.is_mouth_covered())
			to_chat(user, "<span class='warning'>Zdejmij [ H == user ? "swoją maskę" : "mu maskę" ]!</span>")
			return
		if(H.lip_style)	//if they already have lipstick on
			to_chat(user, "<span class='warning'>Najpierw musisz zetrzeć starą szminkę!</span>")
			return
		if(H == user)
			user.visible_message("<span class='notice'>[user] maluje sobie usta [src].</span>", \
								 "<span class='notice'>Poświęcasz chwilę na nałożenie [src]. Idealnie!</span>")
			H.lip_style = "lipstick"
			H.lip_color = colour
			H.update_body()
		else
			user.visible_message("<span class='warning'>[user] zaczyna malować usta [H] za pomocą [src].</span>", \
								 "<span class='notice'>Zaczynasz nakładać [src] na usta [H]...</span>")
			if(do_after(user, 20, target = H))
				user.visible_message("[user] maluje usta [H] za pomocą [src].", \
									 "<span class='notice'>Nakładasz [src] na usta [H].</span>")
				H.lip_style = "lipstick"
				H.lip_color = colour
				H.update_body()
	else
		to_chat(user, "<span class='warning'>Gdzie to ma usta?</span>")

//you can wipe off lipstick with paper!
/obj/item/paper/attack(mob/M, mob/user)
	if(user.zone_selected == BODY_ZONE_PRECISE_MOUTH)
		if(!ismob(M))
			return

		if(ishuman(M))
			var/mob/living/carbon/human/H = M
			if(H == user)
				to_chat(user, "<span class='notice'>Ścierasz szminkę za pomocą [src].</span>")
				H.lip_style = null
				H.update_body()
			else
				user.visible_message("<span class='warning'>[user] zaczyna ścierać szminkę [H] za pomocą [src].</span>", \
								 	 "<span class='notice'>Zaczynasz ścierać szminkę [H]...</span>")
				if(do_after(user, 10, target = H))
					user.visible_message("[user] ściera szminkę [H] za pomocą [src].", \
										 "<span class='notice'>Ścierasz szminkę [H].</span>")
					H.lip_style = null
					H.update_body()
	else
		..()

/obj/item/razor
	name = "electric razor"
	desc = "The latest and greatest power razor born from the science of shaving."
	icon = 'icons/obj/items_and_weapons.dmi'
	icon_state = "razor"
	flags_1 = CONDUCT_1
	w_class = WEIGHT_CLASS_TINY
	var/extended = 1

/obj/item/razor/suicide_act(mob/living/carbon/user)
	user.visible_message("<span class='suicide'>[user] zaczyna się golić bez osłony maszynki! Wygląda na to, że próbuje popełnić samobójstwo!</span>")
	shave(user, BODY_ZONE_PRECISE_MOUTH)
	shave(user, BODY_ZONE_HEAD)//doesnt need to be BODY_ZONE_HEAD specifically, but whatever
	return BRUTELOSS

/obj/item/razor/proc/shave(mob/living/carbon/human/H, location = BODY_ZONE_PRECISE_MOUTH)
	if(location == BODY_ZONE_PRECISE_MOUTH)
		H.facial_hair_style = "Shaved"
	else
		H.hair_style = "Skinhead"

	H.update_hair()
	playsound(loc, 'sound/items/welder2.ogg', 20, 1)


/obj/item/razor/attack(mob/M, mob/user)
	if(ishuman(M) && extended == 1 && user.a_intent != INTENT_HARM)
		var/mob/living/carbon/human/H = M
		var/location = user.zone_selected
		var/mirror = FALSE
		if(HAS_TRAIT(H, TRAIT_SELF_AWARE) || locate(/obj/structure/mirror) in range(1, H))
			mirror = TRUE
		if((location in list(BODY_ZONE_PRECISE_EYES, BODY_ZONE_PRECISE_MOUTH, BODY_ZONE_HEAD)) && !H.get_bodypart(BODY_ZONE_HEAD))
			to_chat(user, "<span class='warning'>[H] nie ma głowy!</span>")
			return
		if(location == BODY_ZONE_PRECISE_MOUTH)
			if(user.a_intent == INTENT_HELP)
				if(H.gender == MALE)
					INVOKE_ASYNC(src, PROC_REF(new_facial_hairstyle), H, user, mirror)
					return
				else
					return
			else
				if(!(FACEHAIR in H.dna.species.species_traits))
					to_chat(user, "<span class='warning'>Nie ma zarostu do golenia!</span>")
					return
				if(!get_location_accessible(H, location))
					to_chat(user, "<span class='warning'>Maska przeszkadza!</span>")
					return
				if(H.facial_hair_style == "Shaved")
					to_chat(user, "<span class='warning'>Już jest gładko ogolony!</span>")
					return

				if(H == user) //shaving yourself
					user.visible_message("[user] zaczyna golić zarost za pomocą [src].", \
										 "<span class='notice'>Poświęcasz chwilę na zgolenie zarostu za pomocą [src]...</span>")
					if(do_after(user, 50, target = H))
						user.visible_message("[user] gładko goli zarost za pomocą [src].", \
											 "<span class='notice'>Kończysz golenie za pomocą [src]. Szybko i czysto!</span>")
						shave(H, location)
				else
					user.visible_message("<span class='warning'>[user] próbuje zgolić zarost [H] za pomocą [src].</span>", \
										 "<span class='notice'>Zaczynasz golić zarost [H]...</span>")
					if(do_after(user, 50, target = H))
						user.visible_message("<span class='warning'>[user] zgala zarost [H] za pomocą [src].</span>", \
											 "<span class='notice'>Gładko golisz zarost [H].</span>")
						shave(H, location)

		else if(location == BODY_ZONE_HEAD)
			if(user.a_intent == INTENT_HELP)
				INVOKE_ASYNC(src, PROC_REF(new_hairstyle), H, user)
				return
			else
				if(!(HAIR in H.dna.species.species_traits))
					to_chat(user, "<span class='warning'>Nie ma włosów do golenia!</span>")
					return
				if(!get_location_accessible(H, location))
					to_chat(user, "<span class='warning'>Nakrycie głowy przeszkadza!</span>")
					return
				if(H.hair_style == "Bald" || H.hair_style == "Balding Hair" || H.hair_style == "Skinhead")
					to_chat(user, "<span class='warning'>Zostało za mało włosów do golenia!</span>")
					return

				if(H == user) //shaving yourself
					user.visible_message("[user] zaczyna golić głowę za pomocą [src].", \
										 "<span class='notice'>Zaczynasz golić głowę za pomocą [src]...</span>")
					if(do_after(user, 5, target = H))
						user.visible_message("[user] goli głowę za pomocą [src].", \
											 "<span class='notice'>Kończysz golenie za pomocą [src].</span>")
						shave(H, location)
				else
					var/turf/H_loc = H.loc
					user.visible_message("<span class='warning'>[user] próbuje ogolić głowę [H] za pomocą [src]!</span>", \
										 "<span class='notice'>Zaczynasz golić głowę [H]...</span>")
					if(do_after(user, 50, target = H))
						if(H_loc == H.loc)
							user.visible_message("<span class='warning'>[user] goli [H] na łyso za pomocą [src]!</span>", \
												 "<span class='notice'>Golisz [H] na łyso.</span>")
							shave(H, location)
		else
			..()
	else
		..()

/obj/item/razor/proc/new_hairstyle(mob/living/carbon/human/H, mob/user, mirror)
	var/location = user.zone_selected
	if (H == user && !mirror)
		to_chat(user, "<span class='warning'>Potrzebujesz lustra, by porządnie ułożyć sobie włosy!</span>")
		return
	if(!user.canUseTopic(src, BE_CLOSE, FALSE, NO_TK))
		return
	var/new_style = input(user, "Wybierz fryzurę", "Grooming")  as null|anything in GLOB.hair_styles_list
	if(!get_location_accessible(H, location))
		to_chat(user, "<span class='warning'>Nakrycie głowy przeszkadza!</span>")
		return
	user.visible_message("<span class='notice'>[user] próbuje zmienić fryzurę [H] za pomocą [src].</span>", "<span class='notice'>Próbujesz zmienić fryzurę [H] za pomocą [src].</span>")
	if(new_style && do_after(user, 60, target = H))
		user.visible_message("<span class='notice'>[user] zmienia fryzurę [H] za pomocą [src].</span>", "<span class='notice'>Zmieniasz fryzurę [H] za pomocą [src].</span>")
		H.hair_style = new_style
		H.update_hair()

/obj/item/razor/proc/new_facial_hairstyle(mob/living/carbon/human/H, mob/user, var/mirror)
	var/location = user.zone_selected
	if(H == user && !mirror)
		to_chat(user, "<span class='warning'>Potrzebujesz lustra, by porządnie ułożyć sobie zarost!</span>")
		return
	if(!user.canUseTopic(src, BE_CLOSE, FALSE, NO_TK))
		return
	var/new_style = input(user, "Wybierz styl zarostu", "Grooming")  as null|anything in GLOB.facial_hair_styles_list
	if(!get_location_accessible(H, location))
		to_chat(user, "<span class='warning'>Maska przeszkadza!</span>")
		return
	user.visible_message("<span class='notice'>[user] próbuje zmienić styl zarostu [H] za pomocą [src].</span>", "<span class='notice'>Próbujesz zmienić styl zarostu [H] za pomocą [src].</span>")
	if(new_style && do_after(user, 60, target = H))
		user.visible_message("<span class='notice'>[user] zmienia styl zarostu [H] za pomocą [src].</span>", "<span class='notice'>Zmieniasz styl zarostu [H] za pomocą [src].</span>")
		H.facial_hair_style = new_style
		H.update_hair()

/obj/item/razor/straightrazor
	name = "straight razor"
	icon_state = "straightrazor"
	desc = "An incredibly sharp razor used to shave chins, make surgical incisions, and slit the throats of unpaying customers"
	flags_1 = CONDUCT_1
	force = 3
	w_class = WEIGHT_CLASS_TINY
	throwforce = 5
	throw_speed = 3
	throw_range = 6
	hitsound = 'sound/weapons/genhit.ogg'
	attack_verb = list("przytyka", "szturcha")
	extended = 0
	var/extended_force = 10
	var/extended_throwforce = 7
	var/extended_icon_state = "straightrazor_open"

/obj/item/razor/straightrazor/suicide_act(mob/user)
	user.visible_message("<span class='suicide'>[user] podrzyna sobie gardło [src]! Wygląda na to, że próbuje popełnić samobójstwo!</span>")
	return (BRUTELOSS)

/obj/item/razor/attack(mob/M, mob/user)
	. = ..()
	if(ishuman(M) && extended == 1 && (user.a_intent == INTENT_HARM))
		var/mob/living/carbon/human/H = M
		var/def_check = H.getarmor("melee")
		H.bleed_rate += ((force * 10) - def_check)/30 //sharp blade causes a shitload of blood loss if on harm intent
		if(H.bleed_rate >= 10)
			to_chat(M, "<span class='userdanger'>Szybko tracisz krew!</span>")

/obj/item/razor/straightrazor/attack_self(mob/user)
	extended = !extended
	playsound(src.loc, 'sound/weapons/batonextend.ogg', 50, 1)
	if(extended)
		force = extended_force
		w_class = WEIGHT_CLASS_SMALL //if it becomes normal you can decapitate a guy with a straight razor
		throwforce = extended_throwforce
		icon_state = extended_icon_state
		attack_verb = list("ciacha", "dźga", "kroi", "rozcina", "goli", "sieka", "tnie")
		hitsound = 'sound/weapons/bladeslice.ogg'
		sharpness = IS_SHARP
		tool_behaviour = TOOL_SCALPEL
	else
		force = initial(force)
		w_class = WEIGHT_CLASS_TINY
		throwforce = initial(throwforce)
		icon_state = initial(icon_state)
		attack_verb = list("przytyka", "szturcha")
		hitsound = 'sound/weapons/genhit.ogg'
		sharpness = IS_BLUNT
		tool_behaviour = null

/obj/item/handmirror
	name = "hand mirror"
	desc = "A cheap plastic hand mirror. Useful for shaving and self-diagnoses"
	icon = 'icons/obj/items_and_weapons.dmi'
	icon_state = "handmirror"
	w_class = WEIGHT_CLASS_SMALL
	force = 2
	throwforce = 2
	throw_speed = 3
	throw_range = 6

/obj/item/handmirror/attack_self(mob/user)
	ADD_TRAIT(user, TRAIT_SELF_AWARE, "mirror_trait")
	to_chat(user, "<span class='notice'>Patrzysz w lustro</span>")
	sleep(150)
	REMOVE_TRAIT(user, TRAIT_SELF_AWARE, "mirror_trait")
