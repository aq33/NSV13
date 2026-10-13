/obj/structure/toilet
	name = "toilet"
	desc = "The HT-451, a torque rotation-based, waste disposal unit for small matter. This one seems remarkably clean."
	icon = 'icons/obj/watercloset.dmi'
	icon_state = "toilet00"
	density = FALSE
	anchored = TRUE
	var/open = FALSE			//if the lid is up
	var/cistern = 0			//if the cistern bit is open
	var/w_items = 0			//the combined w_class of all the items in the cistern
	var/mob/living/swirlie = null	//the mob being given a swirlie


/obj/structure/toilet/Initialize(mapload)
	. = ..()
	open = round(rand(0, 1))
	update_icon()


/obj/structure/toilet/attack_hand(mob/living/user)
	. = ..()
	if(.)
		return
	// AQ EDIT START - click to shit
	if(!user.combat_mode)
		if(user.defecation < DEFECATION_VERY)
			to_chat(user, "<span class='notice'>Nie potrzebujesz skorzystać z ubikacji.</span>")
			return
		else if(do_after(usr, 3 SECONDS, target = src))
			shit(user)// AQ EDIT END
	else if(swirlie)
		user.changeNext_move(CLICK_CD_MELEE)
		playsound(src.loc, "swing_hit", 25, 1)
		swirlie.visible_message("<span class='danger'>[user] zatrzaskuje deskę klozetową na głowie [swirlie]!</span>", "<span class='userdanger'>[user] zatrzaskuje ci deskę klozetową na głowie!</span>", "<span class='italics'>Słyszysz dudnienie porcelany.</span>")
		swirlie.adjustBruteLoss(5)

	else if(user.pulling && isliving(user.pulling))
		user.changeNext_move(CLICK_CD_MELEE)
		var/mob/living/GM = user.pulling
		if(user.grab_state >= GRAB_AGGRESSIVE)
			if(GM.loc != get_turf(src))
				to_chat(user, "<span class='warning'>[GM] musi być na [src]!</span>")
				return
			if(!swirlie)
				if(open)
					GM.visible_message("<span class='danger'>[user] zaczyna robić [GM] kibelkowy prysznic!</span>", "<span class='userdanger'>[user] zaczyna robić ci kibelkowy prysznic...</span>")
					swirlie = GM
					if(do_after(user, 30, 0, target = src))
						GM.visible_message("<span class='danger'>[user] gives [GM] a swirlie!</span>", "<span class='userdanger'>[user] robi ci kibelkowy prysznic!</span>", "<span class='italics'>Słyszysz spuszczanie wody w toalecie.</span>")
						if(iscarbon(GM))
							var/mob/living/carbon/C = GM
							if(!C.internal)
								C.adjustOxyLoss(5)
						else
							GM.adjustOxyLoss(5)
					swirlie = null
				else
					playsound(src.loc, 'sound/effects/bang.ogg', 25, 1)
					GM.visible_message("<span class='danger'>[user] wali [GM.name] o [src]!</span>", "<span class='userdanger'>[user] wali tobą o [src]!</span>")
					GM.adjustBruteLoss(5)
		else
			to_chat(user, "<span class='warning'>Potrzebujesz mocniejszego chwytu!</span>")

	else if(cistern && !open && user.CanReach(src))
		if(!contents.len)
			to_chat(user, "<span class='notice'>Spłuczka jest pusta.</span>")
		else
			var/obj/item/I = pick(contents)
			if(ishuman(user))
				user.put_in_hands(I)
			else
				I.forceMove(drop_location())
			to_chat(user, "<span class='notice'>Znajdujesz w spłuczce [I].</span>")
			w_items -= I.w_class
	else
		open = !open
		update_icon()


/obj/structure/toilet/update_icon()
	icon_state = "toilet[open][cistern]"


/obj/structure/toilet/attackby(obj/item/I, mob/living/user, params)
	if(I.tool_behaviour == TOOL_CROWBAR)
		to_chat(user, "<span class='notice'>Zaczynasz [cistern ? "zakładać pokrywę spłuczki" : "zdejmować pokrywę spłuczki"]...</span>")
		playsound(loc, 'sound/effects/stonedoor_openclose.ogg', 50, 1)
		if(I.use_tool(src, user, 30))
			user.visible_message("[user] [cistern ? "replaces the lid on the cistern" : "lifts the lid off the cistern"]!", "<span class='notice'>You [cistern ? "replace the lid on the cistern" : "lift the lid off the cistern"]!</span>", "<span class='italics'>Słyszysz zgrzyt porcelany.</span>")
			cistern = !cistern
			update_icon()

	else if(cistern && !user.combat_mode)
		if(I.w_class > WEIGHT_CLASS_NORMAL)
			to_chat(user, "<span class='warning'>[I] się nie mieści!</span>")
			return
		if(w_items + I.w_class > WEIGHT_CLASS_HUGE)
			to_chat(user, "<span class='warning'>Spłuczka jest pełna!</span>")
			return
		if(!user.transferItemToLoc(I, src))
			to_chat(user, "<span class='warning'>[I] przykleił się do twojej ręki, nie możesz go włożyć do spłuczki!</span>")
			return
		w_items += I.w_class
		to_chat(user, "<span class='notice'>Ostrożnie wkładasz [I] do spłuczki.</span>")

	else if(istype(I, /obj/item/reagent_containers) && !user.combat_mode)
		if (!open)
			return
		var/obj/item/reagent_containers/RG = I
		RG.reagents.add_reagent(/datum/reagent/water, min(RG.volume - RG.reagents.total_volume, RG.amount_per_transfer_from_this))
		to_chat(user, "<span class='notice'>Napełniasz [RG] z [src]. Obrzydliwe.</span>")
	else
		return ..()

/obj/structure/toilet/secret
	var/secret_type = null

/obj/structure/toilet/secret/Initialize(mapload)
	. = ..()
	if (secret_type)
		new secret_type(src)

/obj/structure/urinal
	name = "urinal"
	desc = "The HU-452, an experimental urinal. Comes complete with experimental urinal cake."
	icon = 'icons/obj/watercloset.dmi'
	icon_state = "urinal"
	density = FALSE
	anchored = TRUE
	var/exposed = 0 // can you currently put an item inside
	var/obj/item/hiddenitem = null // what's in the urinal

/obj/structure/urinal/Initialize(mapload)
	. = ..()
	hiddenitem = new /obj/item/food/urinalcake

/obj/structure/urinal/attack_hand(mob/living/user)
	. = ..()
	if(.)
		return
	if(user.pulling && isliving(user.pulling))
		var/mob/living/GM = user.pulling
		if(user.grab_state >= GRAB_AGGRESSIVE)
			if(GM.loc != get_turf(src))
				to_chat(user, "<span class='notice'>[GM.name] musi być na [src].</span>")
				return
			user.changeNext_move(CLICK_CD_MELEE)
			user.visible_message("<span class='danger'>[user] wali [GM] o [src]!</span>", "<span class='danger'>Walisz [GM] o [src]!</span>")
			GM.adjustBruteLoss(8)
		else
			to_chat(user, "<span class='warning'>Potrzebujesz mocniejszego chwytu!</span>")

	else if(exposed)
		if(!hiddenitem)
			to_chat(user, "<span class='notice'>W uchwycie odpływu nic nie ma.</span>")
		else
			if(ishuman(user))
				user.put_in_hands(hiddenitem)
			else
				hiddenitem.forceMove(get_turf(src))
			to_chat(user, "<span class='notice'>Wyławiasz [hiddenitem] z obudowy odpływu.</span>")
			hiddenitem = null
	else
		..()

/obj/structure/urinal/attackby(obj/item/I, mob/living/user, params)
	if(exposed)
		if (hiddenitem)
			to_chat(user, "<span class='warning'>W obudowie odpływu już coś jest.</span>")
			return
		if(I.w_class > 1)
			to_chat(user, "<span class='warning'>[I] jest za duży na obudowę odpływu.</span>")
			return
		if(!user.transferItemToLoc(I, src))
			to_chat(user, "<span class='warning'>[I] przykleił się do twojej ręki, nie możesz go włożyć do obudowy odpływu!</span>")
			return
		hiddenitem = I
		to_chat(user, "<span class='notice'>Wkładasz [I] do obudowy odpływu.</span>")
	else
		return ..()

/obj/structure/urinal/screwdriver_act(mob/living/user, obj/item/I)
	if(..())
		return TRUE
	to_chat(user, "<span class='notice'>Zaczynasz [exposed ? "przykręcać z powrotem zatyczkę" : "odkręcać zatyczkę osłony odpływu"]...</span>")
	playsound(loc, 'sound/effects/stonedoor_openclose.ogg', 50, 1)
	if(I.use_tool(src, user, 20))
		user.visible_message("[user] [exposed ? "screws the cap back into place" : "unscrew the cap to the drain protector"]!",
			"<span class='notice'>You [exposed ? "screw the cap back into place" : "unscrew the cap on the drain"]!</span>",
			"<span class='italics'>Słyszysz metal i mlaskanie.</span>")
		exposed = !exposed
	return TRUE


/obj/item/food/urinalcake
	name = "urinal cake"
	desc = "The noble urinal cake, protecting the station's pipes from the station's pee. Do not eat."
	icon = 'icons/obj/items_and_weapons.dmi'
	icon_state = "urinalcake"
	w_class = WEIGHT_CLASS_TINY
	food_reagents = list(/datum/reagent/chlorine = 3, /datum/reagent/ammonia = 1)
	foodtypes = TOXIC | GROSS

/obj/item/food/urinalcake/attack_self(mob/living/user)
	user.visible_message("<span class='notice'>[user] squishes [src]!</span>", "<span class='notice'>Rozgniatasz [src].</span>", "<i>Słyszysz mlaśnięcie.</i>")
	icon_state = "urinalcake_squish"
	addtimer(VARSET_CALLBACK(src, icon_state, "urinalcake"), 8)

/obj/item/bikehorn/rubberducky
	name = "rubber ducky"
	desc = "Rubber ducky you're so fine, you make bathtime lots of fuuun. Rubber ducky I'm awfully fooooond of yooooouuuu~"	//thanks doohl
	icon = 'icons/obj/watercloset.dmi'
	icon_state = "rubberducky"
	item_state = "rubberducky"


/obj/structure/sink
	name = "sink"
	icon = 'icons/obj/watercloset.dmi'
	icon_state = "sink"
	desc = "A sink used for washing one's hands and face."
	anchored = TRUE
	var/busy = FALSE 	//Something's being washed at the moment
	var/dispensedreagent = /datum/reagent/water // for whenever plumbing happens


/obj/structure/sinkframe
	name = "sink frame"
	icon = 'icons/obj/watercloset.dmi'
	icon_state = "sink_frame"
	desc = "A sink frame, that needs 2 plastic sheets to finish construction."
	anchored = FALSE

/obj/structure/sinkframe/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/simple_rotation)

/obj/structure/sinkframe/attackby(obj/item/I, mob/living/user, params)
	if(istype(I, /obj/item/stack/sheet/plastic))
		balloon_alert(user, "Zaczynasz budować umywalkę...")
		if(do_after(user, 4 SECONDS, target = src))
			I.use(1)
			balloon_alert(user, "Tworzysz umywalkę.")
			var/obj/structure/sink/new_sink = new /obj/structure/sink(loc)
			new_sink.setDir(dir)
			qdel(src)
			return
	return ..()

/obj/structure/sinkframe/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/simple_rotation)

/obj/structure/sink/attack_hand(mob/living/user)
	. = ..()
	if(.)
		return
	if(!user || !istype(user))
		return
	if(!iscarbon(user))
		return
	if(!Adjacent(user))
		return

	if(busy)
		to_chat(user, "<span class='notice'>Ktoś już się tu myje.</span>")
		return
	var/selected_area = parse_zone(user.zone_selected)
	var/washing_face = 0
	if(selected_area in list(BODY_ZONE_HEAD, BODY_ZONE_PRECISE_MOUTH, BODY_ZONE_PRECISE_EYES))
		washing_face = 1
	user.visible_message("<span class='notice'>[user] zaczyna myć [washing_face ? "twarz" : "ręce"]...</span>", \
						"<span class='notice'>Zaczynasz myć [washing_face ? "twarz" : "ręce"]...</span>")
	busy = TRUE

	if(!do_after(user, 40, target = src))
		busy = FALSE
		return

	busy = FALSE

	user.visible_message("<span class='notice'>[user] myje [washing_face ? "twarz" : "ręce"] w [src].</span>", \
						"<span class='notice'>Myjesz [washing_face ? "twarz" : "ręce"] w [src].</span>")
	if(washing_face)
		if(ishuman(user))
			var/mob/living/carbon/human/H = user
			H.lip_style = null //Washes off lipstick
			H.lip_color = initial(H.lip_color)
			H.wash_cream()
			H.regenerate_icons()
			H.adjust_hygiene(10) //NSV13 - kept hygiene
		user.drowsyness = max(user.drowsyness - rand(2,3), 0) //Washing your face wakes you up if you're falling asleep
	else
		SEND_SIGNAL(user, COMSIG_COMPONENT_CLEAN_ACT, CLEAN_STRENGTH_BLOOD)
		if(ishuman(user)) //NSV13 - kept hygiene
			var/mob/living/carbon/human/dirtyboy = user
			dirtyboy.adjust_hygiene(10)

/obj/structure/sink/attackby(obj/item/O, mob/living/user, params)
	if(busy)
		to_chat(user, "<span class='warning'>Ktoś już się tu myje!</span>")
		return

	if(istype(O, /obj/item/reagent_containers))
		var/obj/item/reagent_containers/RG = O
		if(RG.is_refillable())
			if(!RG.reagents.holder_full())
				RG.reagents.add_reagent(dispensedreagent, min(RG.volume - RG.reagents.total_volume, RG.amount_per_transfer_from_this))
				to_chat(user, "<span class='notice'>Napełniasz [RG] z [src].</span>")
				return TRUE
			to_chat(user, "<span class='notice'>[RG] jest pełny.</span>")
			return FALSE

	if(istype(O, /obj/item/melee/baton))
		var/obj/item/melee/baton/B = O
		if(B.cell)
			if(B.cell.charge > 0 && B.turned_on)
				flick("baton_active", src)
				var/stunforce = B.stunforce
				user.Paralyze(stunforce)
				user.stuttering = stunforce/20
				B.deductcharge(B.hitcost)
				user.visible_message("<span class='warning'>[user] poraża się prądem, próbując umyć włączony [B.name]!</span>", \
									"<span class='userdanger'>Nierozważnie próbujesz umyć [B], gdy jest wciąż włączony.</span>")
				playsound(src, "sparks", 50, 1)
				return

	if(istype(O, /obj/item/mop))
		O.reagents.add_reagent(dispensedreagent, 5)
		to_chat(user, "<span class='notice'>Moczysz [O] w [src].</span>")
		playsound(loc, 'sound/effects/slosh.ogg', 25, 1)
		return

	if(istype(O, /obj/item/stack/medical/gauze))
		var/obj/item/stack/medical/gauze/G = O
		new /obj/item/reagent_containers/glass/rag(src.loc)
		to_chat(user, "<span class='notice'>Odrywasz pasek gazy i robisz szmatkę.</span>")
		G.use(1)
		return

	if(!istype(O))
		return
	if(O.item_flags & ABSTRACT) //Abstract items like grabs won't wash. No-drop items will though because it's still technically an item in your hand.
		return

	if(!user.combat_mode)
		to_chat(user, "<span class='notice'>Zaczynasz prać [O]...</span>")
		busy = TRUE
		if(!do_after(user, 40, target = src))
			busy = FALSE
			return 1
		busy = FALSE
		SEND_SIGNAL(O, COMSIG_COMPONENT_CLEAN_ACT, CLEAN_STRENGTH_BLOOD)
		O.acid_level = 0
		create_reagents(5)
		reagents.add_reagent(dispensedreagent, 5)
		reagents.reaction(O, TOUCH)
		user.visible_message("<span class='notice'>[user] pierze [O] w [src].</span>", \
							"<span class='notice'>Pierzesz [O] w [src].</span>")
		return 1
	else
		return ..()

/obj/structure/sink/deconstruct(disassembled = TRUE)
	new /obj/item/stack/sheet/iron (loc, 3)
	qdel(src)


/obj/structure/sink/kitchen
	name = "kitchen sink"
	icon_state = "sink_alt"


/obj/structure/sink/puddle	//splishy splashy ^_^
	name = "puddle"
	desc = "A puddle used for washing one's hands and face."
	icon_state = "puddle"
	resistance_flags = UNACIDABLE

//ATTACK HAND IGNORING PARENT RETURN VALUE
/obj/structure/sink/puddle/attack_hand(mob/M)
	icon_state = "puddle-splash"
	. = ..()
	icon_state = "puddle"

/obj/structure/sink/puddle/attackby(obj/item/O, mob/user, params)
	icon_state = "puddle-splash"
	. = ..()
	icon_state = "puddle"

/obj/structure/sink/puddle/deconstruct(disassembled = TRUE)
	qdel(src)


//Shower Curtains//
//Defines used are pre-existing in layers.dm//


/obj/structure/curtain
	name = "curtain"
	desc = "Contains less than 1% mercury."
	icon = 'icons/obj/watercloset.dmi'
	icon_state = "bathroom-open"
	var/icon_type = "bathroom"//used in making the icon state
	color = "#ACD1E9" //Default color, didn't bother hardcoding other colors, mappers can and should easily change it.
	alpha = 200 //Mappers can also just set this to 255 if they want curtains that can't be seen through
	layer = SIGN_LAYER
	anchored = TRUE
	opacity = 0
	density = FALSE
	var/open = TRUE

/obj/structure/curtain/proc/toggle()
	open = !open
	update_icon()

/obj/structure/curtain/update_icon()
	if(!open)
		icon_state = "[icon_type]-closed"
		layer = WALL_OBJ_LAYER
		density = TRUE
		open = FALSE

	else
		icon_state = "[icon_type]-open"
		layer = SIGN_LAYER
		density = FALSE
		open = TRUE

/obj/structure/curtain/attackby(obj/item/W, mob/user)
	if (istype(W, /obj/item/toy/crayon))
		color = input(user,"","Wybierz kolor",color) as color
	else
		return ..()

/obj/structure/curtain/wrench_act(mob/living/user, obj/item/I)
	default_unfasten_wrench(user, I, 50)
	return TRUE

/obj/structure/curtain/wirecutter_act(mob/living/user, obj/item/I)
	if(anchored)
		return TRUE

	user.visible_message("<span class='warning'>[user] rozcina [src].</span>",
		"<span class='notice'>Zaczynasz rozcinać [src].</span>", "Słyszysz cięcie.")
	if(I.use_tool(src, user, 50, volume=100) && !anchored)
		to_chat(user, "<span class='notice'>Rozcinasz [src].</span>")
		deconstruct()

	return TRUE


/obj/structure/curtain/attack_hand(mob/user, list/modifiers)
	. = ..()
	if(.)
		return
	playsound(loc, 'sound/effects/curtain.ogg', 50, 1)
	toggle()

/obj/structure/curtain/deconstruct(disassembled = TRUE)
	new /obj/item/stack/sheet/cotton/cloth (loc, 2)
	new /obj/item/stack/sheet/plastic (loc, 2)
	new /obj/item/stack/rods (loc, 1)
	qdel(src)

/obj/structure/curtain/play_attack_sound(damage_amount, damage_type = BRUTE, damage_flag = 0)
	switch(damage_type)
		if(BRUTE)
			if(damage_amount)
				playsound(src.loc, 'sound/weapons/slash.ogg', 80, 1)
			else
				playsound(loc, 'sound/weapons/tap.ogg', 50, 1)
		if(BURN)
			playsound(loc, 'sound/items/welder.ogg', 80, 1)

/obj/structure/curtain/bounty
	icon_type = "bounty"
	icon_state = "bounty-open"
	color = null
	alpha = 255
