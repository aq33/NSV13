/obj/structure/plasticflaps
	name = "airtight plastic flaps"
	desc = "Heavy duty, airtight, plastic flaps. Definitely can't get past those. No way."
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "plasticflaps"
	armor = list("melee" = 100, "bullet" = 80, "laser" = 80, "energy" = 100, "bomb" = 50, "bio" = 100, "rad" = 100, "fire" = 50, "acid" = 50, "stamina" = 0)
	density = FALSE
	anchored = TRUE
	layer = BELOW_OBJ_LAYER
	CanAtmosPass = ATMOS_PASS_NO

/obj/structure/plasticflaps/opaque
	opacity = TRUE

/obj/structure/plasticflaps/Initialize(mapload)
	. = ..()
	alpha = 0
	SSvis_overlays.add_vis_overlay(src, icon, icon_state, ABOVE_MOB_LAYER, plane, dir, add_appearance_flags = RESET_ALPHA) //you see mobs under it, but you hit them like they are above it

/obj/structure/plasticflaps/examine(mob/user)
	. = ..()
	if(anchored)
		. += "<span class='notice'>[src] są <b>przykręcone</b> do podłogi.</span>"
	else
		. += "<span class='notice'>[src] nie są już <i>przykręcone</i> do podłogi, a klapy można <b>rozciąć</b>.</span>"

/obj/structure/plasticflaps/screwdriver_act(mob/living/user, obj/item/W)
	if(..())
		return TRUE
	add_fingerprint(user)
	var/action = anchored ? "odkręca [src] od" : "przykręca [src] do"
	var/uraction = anchored ? "odkręcać [src] od " : "przykręcać [src] do"
	user.visible_message("<span class='warning'>[user] [action] podłogi.</span>", "<span class='notice'>Zaczynasz [uraction] podłogi...</span>", "Słyszysz szelest.")
	if(W.use_tool(src, user, 100, volume=100, extra_checks = CALLBACK(src, PROC_REF(check_anchored_state), anchored)))
		setAnchored(!anchored)
		to_chat(user, "<span class='notice'> [anchored ? "Odkręcasz [src] od" : "Przykręcasz [src] do"] podłogi.</span>")
		return TRUE
	else
		return TRUE

/obj/structure/plasticflaps/wirecutter_act(mob/living/user, obj/item/W)
	if(!anchored)
		user.visible_message("<span class='warning'>[user] rozcina [src].</span>", "<span class='notice'>Zaczynasz rozcinać [src].</span>", "Słyszysz cięcie.")
		if(W.use_tool(src, user, 50, volume=100))
			if(anchored)
				return TRUE
			to_chat(user, "<span class='notice'>Rozcinasz [src].</span>")
			new /obj/item/stack/sheet/plastic/five(loc, null, TRUE, user)
			qdel(src)
			return TRUE
		else
			return TRUE

/obj/structure/plasticflaps/proc/check_anchored_state(check_anchored)
	if(anchored != check_anchored)
		return FALSE
	return TRUE

/obj/structure/plasticflaps/CanAStarPass(obj/item/card/id/ID, to_dir, atom/movable/caller)
	if(isliving(caller))
		if(isbot(caller))
			return TRUE

		var/mob/living/living_caller = caller
		if(!living_caller.ventcrawler && living_caller.mob_size != MOB_SIZE_TINY)
			return FALSE

	if(caller?.pulling)
		return CanAStarPass(ID, to_dir, caller.pulling)
	return TRUE //diseases, stings, etc can pass

/obj/structure/plasticflaps/CanAllowThrough(atom/movable/A, turf/T)
	. = ..()

	if(istype(A) && (A.pass_flags & PASSGLASS))
		return prob(60)

	var/obj/structure/bed/B = A
	if(istype(A, /obj/structure/bed) && (B.has_buckled_mobs() || B.density))//if it's a bed/chair and is dense or someone is buckled, it will not pass
		return FALSE

	if(istype(A, /obj/structure/closet/cardboard))
		var/obj/structure/closet/cardboard/C = A
		if(C.move_delay)
			return FALSE

	if(ismecha(A))
		return FALSE

	else if(isliving(A)) // You Shall Not Pass!
		var/mob/living/M = A
		if(isbot(A)) //Bots understand the secrets
			return TRUE
		if(M.buckled && istype(M.buckled, /mob/living/simple_animal/bot/mulebot)) // mulebot passenger gets a free pass.
			return TRUE
		if((M.mobility_flags & MOBILITY_STAND) && !M.ventcrawler && M.mob_size != MOB_SIZE_TINY)	//If your not laying down, or a ventcrawler or a small creature, no pass.
			return FALSE

/obj/structure/plasticflaps/deconstruct(disassembled = TRUE)
	if(!(flags_1 & NODECONSTRUCT_1))
		new /obj/item/stack/sheet/plastic/five(loc)
	qdel(src)

/obj/structure/plasticflaps/Initialize(mapload)
	. = ..()
	air_update_turf()

/obj/structure/plasticflaps/Destroy()
	var/atom/oldloc = loc
	. = ..()
	if (oldloc)
		oldloc.air_update_turf()
