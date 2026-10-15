/obj/machinery/plumbing/bottler
	name = "chemical bottler"
	desc = "Puts reagents into containers, like bottles and beakers in the tile facing the green light spot, they will exit on the red light spot if successfully filled."
	icon_state = "bottler"
	layer = ABOVE_ALL_MOB_LAYER
	reagent_flags = TRANSPARENT | DRAINABLE
	buffer = 100

	///how much do we fill
	var/wanted_amount = 10
	///where things are sent
	var/turf/goodspot = null
	///where things are taken
	var/turf/inputspot = null
	///where beakers that are already full will be sent
	var/turf/badspot = null

/obj/machinery/plumbing/bottler/Initialize(mapload, layer)
	. = ..()
	AddComponent(/datum/component/plumbing/simple_demand, layer, 3)
	update_spots(dir)

/obj/machinery/plumbing/bottler/examine(mob/user)
	. = ..()
	. += "<span class='notice'>Ekranik pokazuje, że napełnia po [wanted_amount] j. Pojemniki bierze z pola z tyłu, pełne wystawia przed siebie.</span>"

/obj/machinery/plumbing/bottler/setDir(newdir)
	. = ..()
	update_spots(newdir)

///changes the tile array
/obj/machinery/plumbing/bottler/proc/update_spots(new_dir)
	var/turf/target_turf = get_turf(src)
	if(!target_turf)
		return
	switch(new_dir)
		if(NORTH)
			goodspot = get_step(target_turf, NORTH)
			inputspot = get_step(target_turf, SOUTH)
			badspot = get_step(target_turf, EAST)
		if(SOUTH)
			goodspot = get_step(target_turf, SOUTH)
			inputspot = get_step(target_turf, NORTH)
			badspot = get_step(target_turf, WEST)
		if(WEST)
			goodspot = get_step(target_turf, WEST)
			inputspot = get_step(target_turf, EAST)
			badspot = get_step(target_turf, NORTH)
		if(EAST)
			goodspot = get_step(target_turf, EAST)
			inputspot = get_step(target_turf, WEST)
			badspot = get_step(target_turf, SOUTH)

/obj/machinery/plumbing/bottler/Moved(atom/OldLoc, Dir)
	. = ..()
	update_spots(dir)

///changing input ammount with a window
/obj/machinery/plumbing/bottler/interact(mob/user)
	. = ..()
	var/new_amount = tgui_input_number(user, "Ile napełniać?", "Ilość", wanted_amount, reagents.maximum_volume, 1)
	if(!new_amount || QDELETED(user) || QDELETED(src) || !user.canUseTopic(src, BE_CLOSE))
		return
	wanted_amount = new_amount
	to_chat(user, "<span class='notice'>[src] będzie teraz napełniać po [wanted_amount] j.</span>")

/obj/machinery/plumbing/bottler/process(delta_time)
	if(machine_stat & NOPOWER || !anchored)
		return
	if(!goodspot || !badspot || !inputspot)
		return

	///see if machine has enough to fill and has any inputspot objects to pick from
	if(reagents.total_volume < wanted_amount || !length(inputspot.contents))
		return
	use_power(active_power_usage)
	var/obj/AM = pick(inputspot.contents)///pick a reagent_container that could be used
	if(istype(AM, /obj/item/reagent_containers/glass) || istype(AM, /obj/item/reagent_containers/food/drinks))
		var/obj/item/B = AM
		///see if it would overflow else inject
		if(B.reagents && (B.reagents.total_volume + wanted_amount) <= B.reagents.maximum_volume)
			reagents.trans_to(B, wanted_amount)
			B.forceMove(goodspot)
			return
		///glass was full so we move it away
		AM.forceMove(badspot)
	else if(istype(AM, /obj/item/slime_extract)) ///slime extracts need inject
		AM.forceMove(goodspot)
		reagents.trans_to(AM, wanted_amount, method = INJECT)

/obj/machinery/plumbing/fermenter
	name = "chemical fermenter"
	desc = "Turns plants into various types of booze."
	icon_state = "fermenter"
	layer = ABOVE_ALL_MOB_LAYER
	reagent_flags = TRANSPARENT | DRAINABLE
	buffer = 400

	///input dir
	var/eat_dir = SOUTH

/obj/machinery/plumbing/fermenter/Initialize(mapload, layer)
	. = ..()
	AddComponent(/datum/component/plumbing/simple_supply, layer)
	var/static/list/loc_connections = list(
		COMSIG_ATOM_ENTERED = PROC_REF(on_entered),
	)
	AddElement(/datum/element/connect_loc, loc_connections)

/obj/machinery/plumbing/fermenter/setDir(newdir)
	. = ..()
	eat_dir = newdir

/obj/machinery/plumbing/fermenter/CanAllowThrough(atom/movable/mover, border_dir)
	. = ..()
	if(!anchored)
		return
	if(isitem(mover) && get_dir(src, mover) == eat_dir)
		return TRUE

/obj/machinery/plumbing/fermenter/attackby(obj/item/I, mob/user, params)
	if(!user.combat_mode && istype(I, /obj/item/food/grown) && anchored)
		if(user.transferItemToLoc(I, loc))
			return TRUE
	return ..()

/obj/machinery/plumbing/fermenter/proc/on_entered(datum/source, atom/movable/AM)
	SIGNAL_HANDLER
	ferment(AM)

/// uses fermentation proc similar to fermentation barrels
/obj/machinery/plumbing/fermenter/proc/ferment(atom/AM)
	if(machine_stat & NOPOWER || !anchored)
		return
	if(reagents.holder_full())
		return
	if(!istype(AM, /obj/item/food/grown))
		return
	var/obj/item/food/grown/G = AM
	if(G.distill_reagent)
		var/amount = G.seed.potency * 0.25
		reagents.add_reagent(G.distill_reagent, amount)
		use_power(active_power_usage * amount)
		qdel(G)

///A bluespace input pipe for plumbing
/obj/machinery/plumbing/sender
	name = "chemical beacon"
	desc = "A bluespace anchor for chemicals. Does not require power. Use a multitool linked to a Chemical Recipient on this machine to start teleporting reagents."
	icon_state = "beacon"
	density = FALSE
	use_power = NO_POWER_USE

	///whoever we teleport our chems to
	var/obj/machinery/plumbing/receiver/target = null

/obj/machinery/plumbing/sender/Initialize(mapload, layer)
	. = ..()
	AddComponent(/datum/component/plumbing/simple_demand, layer)

/obj/machinery/plumbing/sender/Destroy()
	if(target)
		lose_teleport_target()
	return ..()

/obj/machinery/plumbing/sender/multitool_act(mob/living/user, obj/item/multitool/M)
	if(!istype(M.buffer, /obj/machinery/plumbing/receiver))
		to_chat(user, "<span class='warning'>W buforze nie ma odbiornika chemikaliów.</span>")
		return TRUE

	if(target)
		lose_teleport_target()

	set_teleport_target(M.buffer)

	to_chat(user, "<span class='notice'>Łączysz [src] z [M.buffer].</span>")
	return TRUE

///Lose our previous target and make our previous target lose us. Seperate proc because I feel like I'll need this again
/obj/machinery/plumbing/sender/proc/lose_teleport_target()
	target.senders.Remove(src)
	target = null
	icon_state = initial(icon_state)

///Set a receiving plumbing object
/obj/machinery/plumbing/sender/proc/set_teleport_target(new_target)
	target = new_target
	target.senders.Add(src)
	icon_state = initial(icon_state) + "_idle"

///Transfer reagents and display a flashing icon
/obj/machinery/plumbing/sender/proc/teleport_chemicals(obj/machinery/plumbing/receiver/R, amount)
	flick(initial(icon_state) + "_flash", src)
	reagents.trans_to(R, amount)

///A bluespace output pipe for plumbing. Supports multiple recipients.
/obj/machinery/plumbing/receiver
	name = "chemical recipient"
	desc = "Receives chemicals from one or more chemical beacons. Use a multitool on this machine and then all subsequent chemical beacons. Reset by opening the \
	panel and cutting the main wire."
	icon_state = "recipient"

	buffer = 150

	///How much chemicals we can teleport per process
	var/pull_amount = 20
	///All synced up chemical beacons we can tap from
	var/list/senders = list()
	///We only grab one machine per process, so store which one is next
	var/next_index = 1

/obj/machinery/plumbing/receiver/Initialize(mapload, layer)
	. = ..()
	AddComponent(/datum/component/plumbing/simple_supply, layer)

/obj/machinery/plumbing/receiver/Destroy()
	lose_senders()
	return ..()

/obj/machinery/plumbing/receiver/multitool_act(mob/living/user, obj/item/multitool/M)
	M.buffer = src
	balloon_alert(user, "zapisano w buforze multitoola")
	return TRUE

/obj/machinery/plumbing/receiver/process(delta_time)
	if(machine_stat & NOPOWER || panel_open)
		return

	if(senders.len)
		if(senders.len < next_index)
			next_index = 1

		var/obj/machinery/plumbing/sender/S = senders[next_index]
		if(QDELETED(S))
			senders.Remove(S)
			return

		S.teleport_chemicals(src, pull_amount)

		flick(initial(icon_state) + "_flash", src)

		next_index++

		use_power(active_power_usage)

///Notify all senders to forget us
/obj/machinery/plumbing/receiver/proc/lose_senders()
	for(var/obj/machinery/plumbing/sender/S as anything in senders.Copy())
		if(QDELETED(S))
			continue
		S.lose_teleport_target()

	senders = list()

/obj/machinery/plumbing/receiver/screwdriver_act(mob/living/user, obj/item/tool)
	. = TRUE
	panel_open = !panel_open
	tool.play_tool_sound(src)
	to_chat(user, "<span class='notice'>[panel_open ? "Otwierasz" : "Zamykasz"] panel [src].</span>")
	update_appearance(UPDATE_ICON_STATE)

/obj/machinery/plumbing/receiver/wirecutter_act(mob/living/user, obj/item/I)
	if(!panel_open)
		return FALSE
	lose_senders()
	to_chat(user, "<span class='notice'>Przecinasz główny przewód [src] i zrywasz połączenia z nadajnikami.</span>")
	return TRUE

/obj/machinery/plumbing/receiver/update_icon_state()
	. = ..()
	icon_state = panel_open ? "[initial(icon_state)]_open" : initial(icon_state)
