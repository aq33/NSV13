//A massive gear, effectively a girder for clocks.
/obj/structure/destructible/clockwork/wall_gear
	name = "massive gear"
	icon_state = "wall_gear"
	unanchored_icon = "wall_gear"
	climbable = TRUE
	max_integrity = 100
	layer = BELOW_OBJ_LAYER
	desc = "A massive brass gear. You could probably secure or unsecure it with a wrench, or just climb over it."
	break_message = "<span class='warning'>Zębatka rozpada się na odłamki stopu!</span>"
	debris = list(/obj/item/clockwork/alloy_shards/large = 1, \
	/obj/item/clockwork/alloy_shards/medium = 4, \
	/obj/item/clockwork/alloy_shards/small = 2) //slightly more debris than the default, totals 26 alloy

/obj/structure/destructible/clockwork/wall_gear/displaced
	anchored = FALSE

/obj/structure/destructible/clockwork/wall_gear/Initialize(mapload)
	. = ..()
	new /obj/effect/temp_visual/ratvar/gear(get_turf(src))

/obj/structure/destructible/clockwork/wall_gear/emp_act(severity)
	return

/obj/structure/destructible/clockwork/wall_gear/attackby(obj/item/I, mob/user, params)
	if(I.tool_behaviour == TOOL_WRENCH)
		default_unfasten_wrench(user, I, 10)
		return 1
	else if(I.tool_behaviour == TOOL_SCREWDRIVER)
		if(anchored)
			to_chat(user, "<span class='warning'>Żeby rozebrać [src], trzeba to najpierw odkręcić!</span>")
		else
			user.visible_message("<span class='warning'>[user] zaczyna rozbierać [src].</span>", "<span class='notice'>Zaczynasz rozbierać [src]...</span>")
			if(I.use_tool(src, user, 30, volume=100) && !anchored)
				to_chat(user, "<span class='notice'>Rozbierasz [src].</span>")
				deconstruct(TRUE)
		return 1
	else if(istype(I, /obj/item/stack/tile/brass))
		var/obj/item/stack/tile/brass/W = I
		if(W.get_amount() < 1)
			to_chat(user, "<span class='warning'>Potrzebujesz do tego jednego arkusza mosiądzu!</span>")
			return
		var/turf/T = get_turf(src)
		if(iswallturf(T))
			to_chat(user, "<span class='warning'>Tu już jest ściana!</span>")
			return
		if(!isfloorturf(T))
			to_chat(user, "<span class='warning'>Do budowy [anchored ? "fałszywej ":""]ściany potrzebna jest podłoga!</span>")
			return
		if(locate(/obj/structure/falsewall) in T.contents)
			to_chat(user, "<span class='warning'>Tu już jest fałszywa ściana!</span>")
			return
		to_chat(user, "<span class='notice'>Zaczynasz dodawać [W] do [src]...</span>")
		if(do_after(user, 20, target = src))
			var/brass_floor = FALSE
			if(istype(T, /turf/open/floor/clockwork)) //if the floor is already brass, costs less to make(conservation of masssssss)
				brass_floor = TRUE
			if(W.use(2 - brass_floor))
				if(anchored)
					T.PlaceOnTop(/turf/closed/wall/clockwork)
				else
					T.PlaceOnTop(/turf/open/floor/clockwork, flags = CHANGETURF_INHERIT_AIR)
					new /obj/structure/falsewall/brass(T)
				qdel(src)
			else
				to_chat(user, "<span class='warning'>Potrzebujesz więcej mosiądzu, żeby zrobić [anchored ? "fałszywą ":""]ścianę!</span>")
		return 1
	return ..()

/obj/structure/destructible/clockwork/wall_gear/deconstruct(disassembled = TRUE)
	if(!(flags_1 & NODECONSTRUCT_1) && disassembled)
		new /obj/item/stack/tile/brass(loc, 3)
	return ..()
