/obj/item/stack/medical
	name = "medical pack"
	singular_name = "medical pack"
	icon = 'icons/obj/stack_objects.dmi'
	amount = 6
	max_amount = 6
	w_class = WEIGHT_CLASS_TINY
	full_w_class = WEIGHT_CLASS_TINY
	throw_speed = 3
	resistance_flags = FLAMMABLE
	max_integrity = 40
	novariants = FALSE
	///How much brute does it heal?
	var/heal_brute = 0
	///How much burn does it heal?
	var/heal_burn = 0
	///How much bleeding rate does it suppress?
	var/stop_bleeding = 0
	///How long does it take to apply on yourself?
	var/self_delay = 2 SECONDS

/obj/item/stack/medical/attack(mob/living/M, mob/user)
	if(!M || !user || (isliving(M) && !M.can_inject(user, TRUE))) //If no mob, user and if we can't inject the mob just return
		return

	if(M.stat == DEAD && !stop_bleeding)
		to_chat(user, "<span class='danger'>[M] nie żyje, nie możesz mu pomóc!</span>")
		return

	if(!iscarbon(M) && !isanimal(M))
		to_chat(user, "<span class='danger'>Nie wiesz, jak użyć [src] na [M]!</span>")
		return

	if(isanimal(M))
		var/mob/living/simple_animal/critter = M
		if(!(critter.healable) || stop_bleeding)
			to_chat(user, "<span class='notice'>Nie możesz użyć [src] na [M]!</span>")
			return
		if(critter.health == critter.maxHealth)
			to_chat(user, "<span class='notice'>[M] jest w pełni zdrowy.</span>")
			return
		if(heal_brute < DAMAGE_PRECISION)
			to_chat(user, "<span class='notice'>[src] w ogóle nie pomoże [M].</span>")
			return
		M.heal_bodypart_damage((heal_brute * 0.5), (heal_burn * 0.5)) //half as effective on animals, since it's not made for them
		user.visible_message("<span class='green'>[user] nakłada [src] na [M].</span>", "<span class='green'>Nakładasz [src] na [M].</span>")
		use(1)
		return

	var/obj/item/bodypart/affecting
	var/mob/living/carbon/C = M
	affecting = C.get_bodypart(check_zone(user.zone_selected))

	if(M in user.do_afters) //One at a time, please.
		return

	if(!affecting) //Missing limb?
		to_chat(user, "<span class='warning'>[C] nie ma tej części ciała: [strefa_pl(user.zone_selected)]!</span>")
		return

	if(stop_bleeding)
		if(!C.is_bleeding())
			if(C.is_bandaged()) //so you can't stack bleed suppression
				to_chat(user, "<span class='warning'>Krwawienie [C] jest już opatrzone!</span>")
			else
				to_chat(user, "<span class='warning'>[C] nie krwawi!</span>")
			return
		C.suppress_bloodloss(stop_bleeding)
		if(C.is_bleeding())
			C.balloon_alert(user, "krwawienie zmniejszone do [C.get_bleed_rate_string()]")
		else
			C.balloon_alert(user, "krwawienie zatamowane!")

	if(!IS_ORGANIC_LIMB(affecting))
		to_chat(user, "<span class='warning'>Lekarstwo nie zadziała na robotyczną kończynę!</span>")
		return

	if(!(affecting.brute_dam || affecting.burn_dam))
		to_chat(user, "<span class='warning'>[M]'s [parse_zone(user.zone_selected)] isn't hurt!</span>")
		return

	if((affecting.brute_dam && !affecting.burn_dam && !heal_brute) || (affecting.burn_dam && !affecting.brute_dam && !heal_burn)) //suffer
		to_chat(user, "<span class='warning'>Ten rodzaj lekarstwa nie nadaje się do tego rodzaju rany.</span>")
		return

	if(C == user)
		user.visible_message("<span class='notice'>[user] zaczyna nakładać na siebie [src]...</span>", "<span class='notice'>Zaczynasz nakładać na siebie [src]...</span>")
		if(!do_mob(user, M, self_delay))
			return

	user.visible_message("<span class='green'>[user] nakłada [src] na [M].</span>", "<span class='green'>Nakładasz [src] na [M].</span>")
	if(heal_brute) //AQUILA EDIT
		playsound(user.loc, 'aquila/sound/effects/suture.ogg', 100, 1) //AQUILA EDIT
	if(affecting.heal_damage(heal_brute, heal_burn) || stop_bleeding)
		C.update_damage_overlays()
		use(1)

/obj/item/stack/medical/bruise_pack
	name = "bruise pack"
	singular_name = "bruise pack"
	desc = "A therapeutic gel pack and bandages designed to treat blunt-force trauma."
	icon_state = "brutepack"
	lefthand_file = 'icons/mob/inhands/equipment/medical_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/medical_righthand.dmi'
	heal_brute = 40
	grind_results = list(/datum/reagent/medicine/styptic_powder = 40)

/obj/item/stack/medical/bruise_pack/one
	amount = 1

/obj/item/stack/medical/bruise_pack/suicide_act(mob/user)
	user.visible_message("<span class='suicide'>[user] okłada się [src]! Wygląda na to, że próbuje popełnić samobójstwo!</span>")
	return (BRUTELOSS)

/obj/item/stack/medical/ointment
	name = "ointment"
	desc = "Used to treat those nasty burn wounds."
	icon_state = "ointment"
	lefthand_file = 'icons/mob/inhands/equipment/medical_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/medical_righthand.dmi'
	heal_burn = 40
	grind_results = list(/datum/reagent/medicine/silver_sulfadiazine = 40)

/obj/item/stack/medical/ointment/one
	amount = 1

/obj/item/stack/medical/ointment/suicide_act(mob/living/user)
	user.visible_message("<span class='suicide'>[user] wyciska sobie [src] do ust! Czy nie wie, że to jest toksyczne?</span>")
	return TOXLOSS

/obj/item/stack/medical/gauze
	name = "medical gauze"
	desc = "A roll of elastic cloth that is extremely effective at stopping bleeding, heals minor bruising."
	icon_state = "gauze"
	stop_bleeding = BLEED_CRITICAL
	heal_brute = 5 //Reminder that you can not stack healing thus you wait out the 1800 timer.
	max_amount = 12

/obj/item/stack/medical/gauze/attackby(obj/item/I, mob/user, params)
	if(I.tool_behaviour == TOOL_WIRECUTTER || I.is_sharp())
		if(get_amount() < 2)
			to_chat(user, "<span class='warning'>Potrzebujesz co najmniej dwóch gaz, by to zrobić!</span>")
			return
		new /obj/item/stack/sheet/cotton/cloth(user.drop_location())
		user.visible_message("[user] tnie [src] na kawałki materiału za pomocą [I].", \
					"<span class='notice'>Tniesz [src] na kawałki materiału za pomocą [I].</span>", \
					"<span class='italics'>Słyszysz cięcie.</span>")
		use(2)
	else
		return ..()

/obj/item/stack/medical/gauze/suicide_act(mob/living/user)
	user.visible_message("<span class='suicide'>[user] zaczyna zaciskać [src] na swojej szyi! Wygląda na to, że zapomniał, jak używać środków medycznych!</span>")
	return OXYLOSS

/obj/item/stack/medical/gauze/improvised
	name = "improvised gauze"
	singular_name = "improvised gauze"
	desc = "A roll of cloth roughly cut from something that can stop bleeding, but does not heal wounds."
	stop_bleeding = BLEED_SURFACE
	heal_brute = 0

/obj/item/stack/medical/gauze/adv
	name = "sterilized medical gauze"
	desc = "A roll of elastic sterilized cloth that is extremely effective at stopping bleeding, heals minor wounds and cleans them."
	singular_name = "sterilized medical gauze"
	self_delay = 0.5 SECONDS

/obj/item/stack/medical/gauze/adv/one
	amount = 1

/obj/item/stack/medical/gauze/cyborg
	materials = list()
	is_cyborg = TRUE
	cost = 250
