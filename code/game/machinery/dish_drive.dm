/obj/machinery/dish_drive
	name = "dish drive"
	desc = "A culinary marvel that uses matter-to-energy conversion to store dishes and shards. Convenient! \
	Additional features include a vacuum function to suck in nearby dishes, and an automatic transfer beam that empties its contents into nearby disposal bins every now and then. \
	Or you can just drop your plates on the floor, like civilized folk."
	icon = 'goon/icons/obj/kitchen.dmi'
	icon_state = "synthesizer"
	idle_power_usage = 8 //5 with default parts
	active_power_usage = 13 //10 with default parts
	density = FALSE
	circuit = /obj/item/circuitboard/machine/dish_drive
	pass_flags = PASSTABLE
	var/static/list/collectable_items = list(
		/obj/item/trash/waffles,
		/obj/item/trash/tray,
		/obj/item/reagent_containers/glass/bowl,
		/obj/item/reagent_containers/food/drinks/drinkingglass,
		/obj/item/kitchen/fork,
		/obj/item/shard,
		/obj/item/broken_bottle
	)

	var/static/list/disposable_items = list(
		/obj/item/trash/waffles,
		/obj/item/trash/tray,
		/obj/item/shard,
		/obj/item/broken_bottle)
	var/time_since_dishes = 0
	var/suction_enabled = TRUE
	var/transmit_enabled = TRUE

/obj/machinery/dish_drive/Initialize(mapload)
	. = ..()
	RefreshParts()

/obj/machinery/dish_drive/examine(mob/user)
	. = ..()
	if(user.Adjacent(src))
		. += "<span class='notice'>Alt-kliknij, by przesłać jego zawartość do pobliskich koszy zsypowych.</span>"

/obj/machinery/dish_drive/attack_hand(mob/living/user)
	if(!contents.len)
		to_chat(user, "<span class='warning'>W [src] nic nie ma!</span>")
		return
	var/obj/item/I = contents[contents.len] //the most recently-added item
	user.put_in_hands(I)
	to_chat(user, "<span class='notice'>Wyjmujesz [I] z [src].</span>")
	playsound(src, 'sound/items/pshoom.ogg', 50, TRUE)
	flick("synthesizer_beam", src)

/obj/machinery/dish_drive/attackby(obj/item/I, mob/living/user, params)
	if(is_type_in_list(I, collectable_items) && user.a_intent != INTENT_HARM)
		if(!user.transferItemToLoc(I, src))
			return
		to_chat(user, "<span class='notice'>Wkładasz [I] do [src], a zostaje zamieniony w energię!</span>")
		playsound(src, 'sound/items/pshoom.ogg', 50, TRUE)
		flick("synthesizer_beam", src)
		return
	else if(default_deconstruction_screwdriver(user, "[initial(icon_state)]-o", initial(icon_state), I))
		return
	else if(default_unfasten_wrench(user, I))
		return
	else if(default_deconstruction_crowbar(I, FALSE))
		return
	..()

/obj/machinery/dish_drive/RefreshParts()
	idle_power_usage = initial(idle_power_usage)
	active_power_usage = initial(active_power_usage)
	use_power = initial(use_power)
	var/total_rating = 0
	for(var/obj/item/stock_parts/S in component_parts)
		total_rating += S.rating
	if(total_rating >= 9)
		active_power_usage = 0
		use_power = NO_POWER_USE
	else
		idle_power_usage = max(0, idle_power_usage - total_rating)
		active_power_usage = max(0, active_power_usage - total_rating)
	var/obj/item/circuitboard/machine/dish_drive/board = locate() in component_parts
	if(board)
		suction_enabled = board.suction
		transmit_enabled = board.transmit

/obj/machinery/dish_drive/process()
	if(time_since_dishes <= world.time && transmit_enabled)
		do_the_dishes()
	if(!suction_enabled)
		return
	for(var/obj/item/I in view(4, src))
		if(is_type_in_list(I, collectable_items) && I.loc != src && (!I.reagents || !I.reagents.total_volume))
			if(I.Adjacent(src))
				visible_message("<span class='notice'>[src] zasysa promieniem [I]!</span>")
				I.forceMove(src)
				playsound(src, 'sound/items/pshoom.ogg', 50, TRUE)
				flick("synthesizer_beam", src)
			else
				step_towards(I, src)

/obj/machinery/dish_drive/attack_ai(mob/living/user)
	if(machine_stat)
		return
	to_chat(user, "<span class='notice'>Wysyłasz sygnał transmisji do zsypu do [src].</span>")
	do_the_dishes(TRUE)

/obj/machinery/dish_drive/AltClick(mob/living/user)
	if(user.canUseTopic(src, !issilicon(user)))
		do_the_dishes(TRUE)

/obj/machinery/dish_drive/proc/do_the_dishes(manual)
	if(!contents.len)
		return
	var/obj/machinery/disposal/bin/bin = locate() in view(7, src)
	if(!bin)
		if(manual)
			visible_message("<span class='warning'>[src] brzęczy. W zasięgu nie ma koszy zsypowych!</span>")
			playsound(src, 'sound/machines/buzz-sigh.ogg', 50, TRUE)
		return
	var/disposed = 0
	for(var/obj/item/I in contents)
		if(is_type_in_list(I, disposable_items))
			I.forceMove(bin)
			use_power(active_power_usage)
			disposed++
	if (disposed)
		visible_message("<span class='notice'>[src] [pick("szumi", "bucha", "furczy", "syczy")] i przesyła przechowane przedmioty ([disposed]) do pobliskiego [bin.name].</span>")
		playsound(src, 'sound/items/pshoom.ogg', 50, TRUE)
		playsound(bin, 'sound/items/pshoom.ogg', 50, TRUE)
		Beam(bin, icon_state = "rped_upgrade", time = 5)
		bin.update_icon()
		flick("synthesizer_beam", src)
	time_since_dishes = world.time + 600
