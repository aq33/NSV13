/* Clown Items
 * Contains:
 *		Soap
 *		Bike Horns
 *		Air Horns
 *		Canned Laughter
 */

/*
 * Soap
 */

/obj/item/soap
	name = "soap"
	desc = "A cheap bar of soap. Doesn't smell."
	icon = 'icons/obj/items_and_weapons.dmi'
	icon_state = "soap"
	lefthand_file = 'icons/mob/inhands/equipment/custodial_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/custodial_righthand.dmi'
	w_class = WEIGHT_CLASS_TINY
	item_flags = NOBLUDGEON
	throwforce = 0
	throw_speed = 3
	throw_range = 7
	grind_results = list(/datum/reagent/lye = 10)
	var/cleanspeed = 35 //slower than mop
	force_string = "robust... przeciw zarazkom"
	var/uses = 100

/obj/item/soap/ComponentInitialize()
	. = ..()
	AddComponent(/datum/component/slippery, 80, _force_drop = TRUE) //NSV13 - re-added accidents

/obj/item/soap/examine(mob/user)
	. = ..()
	var/max_uses = initial(uses)
	var/msg = "Wygląda, jakby dopiero co wyjęto je z opakowania."
	if(uses != max_uses)
		var/percentage_left = uses / max_uses
		switch(percentage_left)
			if(0 to 0.15)
				msg = "Został tylko maleńki kawałek, nie wiadomo, czy jeszcze długo wytrzyma."
			if(0.15 to 0.30)
				msg = "Sporo się rozpuściło, ale wciąż ma w sobie trochę życia."
			if(0.30 to 0.50)
				msg = "Najlepsze lata ma za sobą, ale wciąż jest całkiem dobre."
			if(0.50 to 0.75)
				msg = "Zaczyna robić się trochę mniejsze niż kiedyś, ale jeszcze długo wytrzyma."
			else
				msg = "Było trochę używane, ale wciąż jest dość świeże."
	. += "<span class='notice'>[msg]</span>"

/obj/item/soap/nanotrasen
	desc = "A heavy duty bar of Nanotrasen brand soap. Smells of plasma."
	grind_results = list(/datum/reagent/toxin/plasma = 10, /datum/reagent/lye = 10)
	icon_state = "soapnt"
	cleanspeed = 28 //janitor gets this
	uses = 300

/obj/item/soap/homemade
	desc = "A homemade bar of soap. Smells of... well...."
	icon_state = "soapgibs"
	cleanspeed = 30 // faster to reward chemists for going to the effort

/obj/item/soap/deluxe
	desc = "A deluxe Waffle Co. brand bar of soap. Smells of high-class luxury."
	icon_state = "soapdeluxe"
	cleanspeed = 20 //captain gets one of these

/obj/item/soap/syndie
	desc = "An untrustworthy bar of soap made of strong chemical agents that dissolve blood faster."
	icon_state = "soapsyndie"
	cleanspeed = 5 //faster than mop so it is useful for traitors who want to clean crime scenes

/obj/item/soap/suicide_act(mob/user)
	user.say(";FFFFFFFFFFFFFFFFUUUUUUUDGE!!", forced="soap suicide")
	user.visible_message("<span class='suicide'>[user] podnosi [src] do ust i zaczyna je wściekle obgryzać, wytwarzając gęstą pianę! Teraz już nigdy nie dostanie wiatrówki!</span>")
	new /obj/effect/particle_effect/foam(loc)
	return (TOXLOSS)

/obj/item/soap/proc/decreaseUses(mob/user)
	uses--
	if(uses <= 0)
		to_chat(user, "<span class='warning'>[src] kruszy się na drobne kawałki!</span>")
		qdel(src)

/obj/item/soap/afterattack(atom/target, mob/user, proximity)
	. = ..()
	if(!proximity || !check_allowed_items(target))
		return
	//I couldn't feasibly  fix the overlay bugs caused by cleaning items we are wearing.
	//So this is a workaround. This also makes more sense from an IC standpoint. ~Carn
	if(user.client && ((target in user.client.screen) && !user.is_holding(target)))
		to_chat(user, "<span class='warning'>Musisz zdjąć [target.name], zanim to wyczyścisz!</span>")
	else if(istype(target, /obj/effect/decal/cleanable))
		user.visible_message("[user] zaczyna szorować [target.name] za pomocą [src].", "<span class='warning'>Zaczynasz szorować [target.name] za pomocą [src]...</span>")
		if(do_after(user, src.cleanspeed, target = target))
			to_chat(user, "<span class='notice'>Szorujesz [target.name].</span>")
			qdel(target)
			decreaseUses(user)

	else if(ishuman(target) && user.zone_selected == BODY_ZONE_PRECISE_MOUTH)
		var/mob/living/carbon/human/H = user
		// NSV13 - kept hygiene effects
		if(user.zone_selected == "mouth")
			user.visible_message("<span class='warning'>\t[user] myje [target] usta [src.name]!</span>", "<span class='notice'>Myjesz [target] usta [src.name]!</span>") //washes mouth out with soap sounds better than 'the soap' here
			H.lip_style = null //removes lipstick
			H.adjust_hygiene(5) //it kinda works i guess
		else
			user.visible_message("<span class='warning'>\t[user] myje [target] za pomocą [src.name]!</span>", "<span class='notice'>Myjesz [target] za pomocą [src.name]!</span>")
			H.adjust_hygiene(20)
		H.update_body()
		decreaseUses(user)
		return
	else if(istype(target, /obj/structure/window))
		user.visible_message("[user] zaczyna czyścić [target.name] za pomocą [src]...", "<span class='notice'>Zaczynasz czyścić [target.name] za pomocą [src]...</span>")
		if(do_after(user, src.cleanspeed, target = target))
			to_chat(user, "<span class='notice'>Czyścisz [target.name].</span>")
			target.remove_atom_colour(WASHABLE_COLOUR_PRIORITY)
			target.set_opacity(initial(target.opacity))
			decreaseUses(user)
	else
		user.visible_message("[user] zaczyna czyścić [target.name] za pomocą [src]...", "<span class='notice'>Zaczynasz czyścić [target.name] za pomocą [src]...</span>")
		if(do_after(user, src.cleanspeed, target = target))
			to_chat(user, "<span class='notice'>Czyścisz [target.name].</span>")
			if(isclothing(target) && HAS_TRAIT(target, TRAIT_SPRAYPAINTED))
				var/obj/item/clothing/C = target
				var/mob/living/carbon/human/H = user
				C.flash_protect -= 1
				C.tint -= 2
				H.update_tint()
				REMOVE_TRAIT(target, TRAIT_SPRAYPAINTED, CRAYON_TRAIT)
			for(var/obj/effect/decal/cleanable/C in target)
				qdel(C)
			target.remove_atom_colour(WASHABLE_COLOUR_PRIORITY)
			SEND_SIGNAL(target, COMSIG_COMPONENT_CLEAN_ACT, CLEAN_MEDIUM)
			target.wash_cream()
			decreaseUses(user)
	return


/*
 * Bike Horns
 */

/obj/item/bikehorn
	name = "bike horn"
	desc = "A horn off of a bicycle."
	icon = 'icons/obj/items_and_weapons.dmi'
	icon_state = "bike_horn"
	item_state = "bike_horn"
	lefthand_file = 'icons/mob/inhands/equipment/horns_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/horns_righthand.dmi'
	throwforce = 0
	hitsound = null //To prevent tap.ogg playing, as the item lacks of force
	w_class = WEIGHT_CLASS_TINY
	slot_flags = ITEM_SLOT_BACK|ITEM_SLOT_BELT
	throw_speed = 3
	throw_range = 7
	attack_verb = list("HONKUJE")
	///sound file given to the squeaky component we make in Initialize() so sub-types can specify their own sound
	var/sound_file = 'sound/items/bikehorn.ogg'

/obj/item/bikehorn/Initialize(mapload)
	. = ..()
	var/list/sound_list = list()
	sound_list[sound_file] = 1
	//LoadComponent so child types dont stack squeak components
	LoadComponent(/datum/component/squeak, sound_list, 50)

/obj/item/bikehorn/attack(mob/living/carbon/M, mob/living/carbon/user)
	SEND_SIGNAL(M, COMSIG_ADD_MOOD_EVENT, "honk", /datum/mood_event/honk)
	return ..()

/obj/item/bikehorn/suicide_act(mob/user)
	user.visible_message("<span class='suicide'>[user] uroczyście przykłada [src] do skroni! Wygląda na to, że próbuje popełnić samobójstwo!</span>")
	playsound(src, 'sound/items/bikehorn.ogg', 50, TRUE)
	return (BRUTELOSS)

//air horn
/obj/item/bikehorn/airhorn
	name = "air horn"
	desc = "Damn son, where'd you find this?"
	icon_state = "air_horn"
	sound_file = 'sound/items/airhorn2.ogg'

//golden bikehorn
/obj/item/bikehorn/golden
	name = "golden bike horn"
	desc = "Golden? Clearly, it's made with bananium! Honk!"
	icon_state = "gold_horn"
	item_state = "gold_horn"
	var/flip_cooldown = 0

/obj/item/bikehorn/golden/attack()
	if(flip_cooldown < world.time)
		flip_mobs()
	return ..()

/obj/item/bikehorn/golden/attack_self(mob/user)
	if(flip_cooldown < world.time)
		flip_mobs()
	..()

/obj/item/bikehorn/golden/proc/flip_mobs(mob/living/carbon/M, mob/user)
	for(M in ohearers(7, get_turf(src)))
		if(ishuman(M) && M.can_hear())
			var/mob/living/carbon/human/H = M
			if(istype(H.ears, /obj/item/clothing/ears/earmuffs))
				continue
		M.emote("flip")
	flip_cooldown = world.time + 7

//canned laughter
/obj/item/reagent_containers/food/drinks/soda_cans/canned_laughter
	name = "Canned Laughter"
	desc = "Just looking at this makes you want to giggle."
	icon_state = "laughter"
	list_reagents = list(/datum/reagent/consumable/laughter = 50)
