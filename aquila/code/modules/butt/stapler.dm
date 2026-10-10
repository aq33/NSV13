// Staple gun, ported from HippieStation13 (code/modules/hippie/items/stapler.dm).
// Staples people, staples paper to walls and staples butts back on.

/obj/item/stack/staples
	name = "staples"
	singular_name = "staple"
	desc = "Staples for use with a staplegun."
	icon = 'aquila/icons/obj/staples.dmi'
	icon_state = "staples"
	item_state = "staples"
	force = 0
	throw_speed = 2
	throw_range = 7
	throwforce = 1
	w_class = WEIGHT_CLASS_TINY
	materials = list(/datum/material/iron = 100)
	max_amount = 10
	merge_type = /obj/item/stack/staples
	novariants = TRUE
	attack_verb = list("zszywa")
	embedding = list("embed_chance" = 100, "fall_chance" = 1, "ignore_throwspeed_threshold" = TRUE)

/obj/item/stack/staples/update_icon_state()
	. = ..()
	if(get_amount() <= 1)
		icon_state = "staple"
		name = "staple"
	else
		icon_state = "staples"
		name = "staples"

GLOBAL_VAR_INIT(staple_recipe_added, FALSE)

/obj/item/stack/rods/Initialize(mapload, new_amount, merge = TRUE, mob/user = null)
	if(!GLOB.staple_recipe_added)
		GLOB.rod_recipes += new /datum/stack_recipe("staple", /obj/item/stack/staples, 1, 5, 10)
		GLOB.staple_recipe_added = TRUE
	return ..()

/obj/item/staplegun
	name = "staple gun"
	desc = "Insert paper you want to staple and then use the gun on a wall/floor. CAUTION: Don't use on people."
	icon = 'aquila/icons/obj/staples.dmi'
	icon_state = "staplegun"
	force = 0
	throw_speed = 2
	throw_range = 5
	throwforce = 5
	w_class = WEIGHT_CLASS_SMALL
	attack_verb = list("zszywa")
	var/ammo = 5
	var/max_ammo = 10
	var/obj/item/paper/P
	var/obj/item/organ/butt/B

/obj/item/staplegun/Initialize(mapload)
	. = ..()
	update_icon()

/obj/item/staplegun/Destroy()
	QDEL_NULL(P)
	QDEL_NULL(B)
	return ..()

/obj/item/staplegun/examine(mob/user)
	. = ..()
	. += "Zawiera zszywek: [ammo]/[max_ammo]."
	if(P)
		. += "Jest w nim załadowany [P]."
	if(B)
		. += "Jest w nim załadowany... tyłek? Co."

/obj/item/staplegun/update_overlays()
	. = ..()
	. += "[icon_state][clamp(round(ammo / 1.5), 0, 6)]"

/obj/item/staplegun/attack(mob/living/target, mob/living/user)
	if(ammo <= 0)
		playsound(user, 'sound/weapons/empty.ogg', 100, TRUE)
		return

	if(ishuman(target))
		var/mob/living/carbon/human/H = target
		if(user.zone_selected == BODY_ZONE_PRECISE_GROIN)
			if(H.w_uniform)
				to_chat(user, "<span class='danger'>Zanim to zrobisz, musisz zdjąć [H == user ? "swój kombinezon" : "kombinezon [H]"]!</span>")
				return
			if(H.getorganslot(ORGAN_SLOT_BUTT))
				to_chat(user, "<span class='danger'>[H == user ? "Już masz" : "[H] już ma"] tyłek!</span>")
				return
			if(B)
				B.Insert(H)
				B.loose = TRUE
				user.visible_message("<span class='danger'>[user] przyszywa zszywkami [B] z powrotem do [user == H ? "swojego krocza" : "krocza [H]"]!</span>", "<span class='userdanger'>Przyszywasz zszywkami [user == H ? "swój tyłek" : "tyłek [H]"] z powrotem, ale wygląda na luźny!</span>")
				B = null
		var/obj/item/bodypart/O = H.get_bodypart(ran_zone(check_zone(user.zone_selected), 65))
		var/armor = istype(O) ? H.run_armor_check(O, "melee") : 100
		if(armor <= 40)
			if(P) //If the staplegun contains paper...
				P.embedding = list("embed_chance" = 100, "fall_chance" = 1, "ignore_throwspeed_threshold" = TRUE)
				P.updateEmbedding()
				P.forceMove(get_turf(H))
				P.tryEmbed(O, TRUE)
				P = null
			else
				var/obj/item/stack/staples/S = new(get_turf(H), 1)
				S.tryEmbed(O, TRUE)
			H.apply_damage(2, BRUTE, O, armor)
			log_combat(user, H, "stapled", src)
			user.visible_message("<span class='danger'>[user] zszywa [H] ([O.name])!</span>", "<span class='userdanger'>Zszywasz [H]!</span>")
		else
			user.visible_message("<span class='danger'>[user] próbuje zszyć [H] ([O ? O.name : "ciało"])!</span>")
	else
		return ..()

	playsound(user, 'aquila/sound/weapons/staplegun.ogg', 50, TRUE)
	ammo--
	update_icon()

/obj/item/staplegun/afterattack(atom/target, mob/user, proximity)
	. = ..()
	if(!proximity || !P || !isturf(target))
		return
	if(ammo <= 0)
		playsound(user, 'sound/weapons/empty.ogg', 100, TRUE)
		return
	playsound(target, 'aquila/sound/weapons/staplegun.ogg', 50, TRUE)
	user.visible_message("<span class='danger'>[user] przyszywa [P] do [target]!</span>")
	P.forceMove(target)
	P.anchored = TRUE //like why would you want to pull this around
	P = null
	ammo--
	update_icon()

/obj/item/staplegun/attack_self(mob/user)
	if(P)
		to_chat(user, "<span class='notice'>Wyjmujesz [P] z [src].</span>")
		user.put_in_hands(P)
		P = null
	else if(B)
		to_chat(user, "<span class='notice'>Wyjmujesz [B] z [src].</span>")
		user.put_in_hands(B)
		B = null
	else if(ammo)
		to_chat(user, "<span class='notice'>Wyjmujesz [ammo > 1 ? "zszywki" : "zszywkę"] z [src].</span>")
		new /obj/item/stack/staples(user.drop_location(), ammo)
		ammo = 0
		update_icon()

/obj/item/staplegun/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/stack/staples))
		if(ammo >= max_ammo)
			to_chat(user, "<span class='notice'>[src] jest już pełny!</span>")
			return
		var/obj/item/stack/staples/S = I
		var/amount = min(max_ammo - ammo, S.get_amount())
		if(S.use(amount))
			ammo += amount
			update_icon()
			to_chat(user, "<span class='notice'>Wkładasz zszywki ([amount]) do [src]. Zawiera teraz [ammo] zszywek.</span>")
		return
	if(istype(I, /obj/item/paper) || istype(I, /obj/item/organ/butt))
		if(P || B)
			to_chat(user, "<span class='notice'>W [src] już coś jest!</span>")
			return
		if(!user.transferItemToLoc(I, src))
			return
		if(istype(I, /obj/item/paper))
			P = I
		else
			B = I
		to_chat(user, "<span class='notice'>Wkładasz [I] do [src].</span>")
		return
	return ..()

/obj/machinery/vending/tool/Initialize(mapload)
	premium[/obj/item/staplegun] = 2
	return ..()

/obj/effect/spawner/lootdrop/maintenance/Initialize(mapload)
	if(!GLOB.maintenance_loot[/obj/item/staplegun])
		GLOB.maintenance_loot[/obj/item/staplegun] = 3
	return ..()

// Coffin nailing with the staple gun instead of welding

/obj/structure/closet/crate/coffin/update_icon()
	. = ..()
	if(welded && !opened)
		add_overlay(image('aquila/icons/obj/coffin_nailed.dmi', "nailed"))

/obj/structure/closet/crate/coffin/attackby(obj/item/W, mob/user, params)
	if(user in src)
		return
	if(!opened && !welded && istype(W, /obj/item/staplegun))
		var/obj/item/staplegun/WS = W
		if(WS.ammo < 10)
			to_chat(user, "<span class='warning'>Do zszycia [src] potrzebujesz dziesięciu zszywek w [WS]!</span>")
			return
		to_chat(user, "<span class='notice'>Zaczynasz zszywać [src]...</span>")
		playsound(src, 'aquila/sound/weapons/staplegun.ogg', 50, TRUE)
		if(!do_after(user, 4 SECONDS, target = src) || opened || welded || WS.ammo < 10)
			return
		playsound(src, 'aquila/sound/weapons/staplegun.ogg', 50, TRUE)
		welded = TRUE
		WS.ammo -= 10
		WS.update_icon()
		update_icon()
		user.visible_message("<span class='notice'>[user] zszywa [src] za pomocą [WS].</span>", "<span class='notice'>Zszywasz [src].</span>")
		return
	if(!opened && welded && W.tool_behaviour == TOOL_CROWBAR)
		to_chat(user, "<span class='notice'>Zaczynasz wyważać zszywki z [src]...</span>")
		W.play_tool_sound(src)
		if(!do_after(user, 8 SECONDS, target = src) || opened || !welded)
			return
		W.play_tool_sound(src)
		welded = FALSE
		update_icon()
		new /obj/item/stack/staples(drop_location(), 9)
		user.visible_message("<span class='notice'>[user] wyważa zszywki trzymające [src].</span>", "<span class='notice'>Wyważasz zszywki trzymające [src].</span>")
		return
	return ..()
