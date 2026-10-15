/obj/machinery/plumbing/buffer
	name = "automatic buffer"
	desc = "A chemical holding tank that waits for neighbouring automatic buffers to complete before allowing a withdrawal. Connect/reset by screwdrivering"
	icon_state = "buffer"
	buffer = 200

	///List of all buffers we are connected to
	var/list/obj/machinery/plumbing/buffer/connections
	///Volume of reagents at which which this buffer is ready to send
	var/activation_volume = 100
	///The state of this machine see defines
	var/mode = AB_UNREADY

/obj/machinery/plumbing/buffer/Initialize(mapload, layer)
	. = ..()
	AddComponent(/datum/component/plumbing/buffer, layer)

///Removes this buffer from the list of connected buffers
/obj/machinery/plumbing/buffer/proc/disconnect()
	if(!connections)
		return

	connections -= src
	for(var/obj/machinery/plumbing/buffer/node as anything in connections)
		node.on_reagent_change()
	connections = null

/obj/machinery/plumbing/buffer/Destroy(force)
	disconnect()
	return ..()

/obj/machinery/plumbing/buffer/examine(mob/user)
	. = ..()
	. += "<span class='notice'>Uruchamia się po zebraniu [activation_volume] j. odczynników.</span>"
	switch(mode)
		if(AB_UNREADY)
			. += "<span class='notice'>Napełnia się.</span>"
		if(AB_IDLE)
			. += "<span class='notice'>Czeka na pozostałe bufory.</span>"
		if(AB_READY)
			. += "<span class='notice'>Wypuszcza odczynniki.</span>"
	. += "<span class='notice'>Próg zmienisz <b>ręką</b>, a połączenia z sąsiednimi buforami <b>śrubokrętem</b>.</span>"

/obj/machinery/plumbing/buffer/update_icon_state()
	. = ..()
	icon_state = initial(icon_state)
	if(!anchored || machine_stat & NOPOWER)
		return

	switch(mode)
		if(AB_UNREADY)
			icon_state += "_red"
		if(AB_IDLE)
			icon_state += "_yellow"
		if(AB_READY)
			icon_state += "_green"

/obj/machinery/plumbing/buffer/on_reagent_change(changetype)
	. = ..()
	if(mode == AB_UNREADY)
		if(reagents.total_volume >= activation_volume)
			mode = AB_IDLE
			update_appearance(UPDATE_ICON_STATE)

	if(mode == AB_IDLE)
		for(var/obj/machinery/plumbing/buffer/node as anything in connections)
			if(node.mode == AB_UNREADY)
				return

		if(!connections)
			mode = AB_READY
			update_appearance(UPDATE_ICON_STATE)
		for(var/obj/machinery/plumbing/buffer/node as anything in connections)
			node.mode = AB_READY
			node.update_appearance(UPDATE_ICON_STATE)

	if(mode == AB_READY)
		if(!connections)
			if(!reagents.total_volume)
				mode = AB_UNREADY
				update_appearance(UPDATE_ICON_STATE)
			return

		for(var/obj/machinery/plumbing/buffer/node as anything in connections)
			if(node.reagents.total_volume)
				return

		for(var/obj/machinery/plumbing/buffer/node as anything in connections)
			node.mode = AB_UNREADY
			node.update_appearance(UPDATE_ICON_STATE)

/obj/machinery/plumbing/buffer/screwdriver_act(mob/living/user, obj/item/tool)
	. = TRUE

	//clear existing connections and ourself to it for other machines
	disconnect()
	var/list/obj/machinery/plumbing/buffer/new_connections = list()

	//Discover new connections
	var/list/obj/machinery/plumbing/buffer/queue = list(src)
	var/list/obj/machinery/plumbing/buffer/visited = list()
	while(queue.len)
		var/obj/machinery/plumbing/buffer/node = queue[1]
		queue.Cut(1, 2)
		if(visited[node])
			continue
		visited[node] = TRUE
		node.disconnect()
		node.connections = new_connections
		new_connections += node

		for(var/direction in GLOB.cardinals)
			for(var/obj/machinery/plumbing/buffer/sub_node in get_step(node, direction))
				if(!sub_node.anchored || visited[sub_node])
					continue
				queue += sub_node

	//Ping the alert to the player
	for(var/obj/machinery/plumbing/buffer/node as anything in new_connections)
		node.mode = AB_UNREADY
		flick_overlay_view(image(node.icon, node, "buffer_alert"), node, 2 SECONDS)
		node.on_reagent_change()
		node.update_appearance(UPDATE_ICON_STATE)
	balloon_alert(user, "połączono bufory: [length(new_connections)]")

/obj/machinery/plumbing/buffer/wrench_act(mob/living/user, obj/item/tool)
	. = ..()
	disconnect()
	update_appearance(UPDATE_ICON_STATE)

/obj/machinery/plumbing/buffer/ui_state(mob/user)
	return GLOB.default_state

/obj/machinery/plumbing/buffer/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "ChemAutomaticBuffer", name)
		ui.open()

/obj/machinery/plumbing/buffer/ui_data(mob/user)
	return list(
		threshold = activation_volume,
		connections = max(LAZYLEN(connections) - 1, 0)
	)

/obj/machinery/plumbing/buffer/ui_act(action, list/params)
	. = ..()
	if(.)
		return

	switch(action)
		if("set_threshold")
			var/value = text2num(params["threshold"])
			if(!value)
				return FALSE

			activation_volume = clamp(value, 1, buffer)
			on_reagent_change()
			return TRUE

		if("sync")
			for(var/obj/machinery/plumbing/buffer/node as anything in connections)
				node.activation_volume = activation_volume
				node.on_reagent_change()
			return TRUE

#define MAX_TRANSFER 9

///it splits the reagents however you want. So you can "every 60 units, 45 goes left and 15 goes straight". The side direction is EAST, you can change this in the component
/obj/machinery/plumbing/splitter
	name = "chemical splitter"
	desc = "A chemical splitter for smart chemical factorization. Waits till a set of conditions is met and then stops all input and splits the buffer evenly or other in two ducts."
	icon_state = "splitter"
	buffer = 100
	density = FALSE

	///how much we must transfer straight(SOUTH)
	var/transfer_straight = 5
	///how much we must transfer to the left(EAST)
	var/transfer_left = 5
	///how much we must transfer to the right(WEST)
	var/transfer_right = 5

/obj/machinery/plumbing/splitter/Initialize(mapload, layer)
	. = ..()
	AddComponent(/datum/component/plumbing/multidirectional/splitter, layer)

/obj/machinery/plumbing/splitter/ui_state(mob/user)
	return GLOB.default_state

/obj/machinery/plumbing/splitter/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "ChemSplitter", name)
		ui.open()

/obj/machinery/plumbing/splitter/ui_static_data(mob/user)
	return list(
		max_transfer = MAX_TRANSFER
	)

/obj/machinery/plumbing/splitter/ui_data(mob/user)
	return list(
		straight = transfer_straight,
		left = transfer_left,
		right = transfer_right,
	)

/obj/machinery/plumbing/splitter/ui_act(action, list/params)
	. = ..()
	if(.)
		return

	switch(action)
		if("set_amount")
			var/value = text2num(params["amount"])
			if(isnull(value))
				return FALSE
			value = clamp(value, 0, MAX_TRANSFER)

			switch(params["target"])
				if("straight")
					transfer_straight = value
					return TRUE

				if("left")
					transfer_left = value
					return TRUE

				if("right")
					transfer_right = value
					return TRUE

#undef MAX_TRANSFER

///chemical plumbing filter. If it's not filtered by left and right, it goes straight.
/obj/machinery/plumbing/filter
	name = "chemical filter"
	desc = "A chemical filter for filtering chemicals. The left and right outputs appear to be from the perspective of the input port."
	icon_state = "filter"
	density = FALSE

	///whitelist of chems id's that go to the left side. Empty to disable port
	var/list/left = list()
	///whitelist of chem id's that go to the right side. Empty to disable port
	var/list/right = list()

/obj/machinery/plumbing/filter/Initialize(mapload, layer)
	. = ..()
	AddComponent(/datum/component/plumbing/multidirectional/filter, layer)

/obj/machinery/plumbing/filter/ui_state(mob/user)
	return GLOB.default_state

/obj/machinery/plumbing/filter/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "ChemFilter", name)
		ui.open()

/obj/machinery/plumbing/filter/ui_data(mob/user)
	. = list()

	.["left"] = list()
	for(var/datum/reagent/id as anything in left)
		.["left"] += initial(id.name)

	.["right"] = list()
	for(var/datum/reagent/id as anything in right)
		.["right"] += initial(id.name)

/obj/machinery/plumbing/filter/ui_act(action, list/params)
	. = ..()
	if(.)
		return

	switch(action)
		if("add")
			var/which = params["which"]

			var/selected_reagent = tgui_input_list(usr, "Wybierz odczynnik", "Odczynnik", GLOB.name2reagent)
			if(!selected_reagent)
				return FALSE

			var/datum/reagent/chem_id = GLOB.name2reagent[selected_reagent]
			if(!chem_id)
				return FALSE

			switch(which)
				if("left")
					left |= chem_id
					return TRUE

				if("right")
					right |= chem_id
					return TRUE

		if("remove")
			var/chem_id = get_chem_id(params["reagent"])
			if(!chem_id)
				return FALSE

			switch(params["which"])
				if("left")
					left -= chem_id
					return TRUE

				if("right")
					right -= chem_id
					return TRUE

//Maximum disposal rate
#define MAX_DISPOSAL_RATE 25

/obj/machinery/plumbing/disposer
	name = "chemical disposer"
	desc = "Breaks down chemicals and annihilates them."
	icon_state = "disposal"
	density = FALSE
	active_power_usage = 70

	///Reagents to remove per second
	var/disposal_rate = 5
	///Is this machine switched on
	var/on = TRUE

/obj/machinery/plumbing/disposer/Initialize(mapload, layer)
	. = ..()
	AddComponent(/datum/component/plumbing/simple_demand/disposer, layer)

/obj/machinery/plumbing/disposer/examine(mob/user)
	. = ..()
	. += "<span class='notice'>Niszczy [disposal_rate] j. odczynników na sekundę. Ustawisz to ręką.</span>"

/obj/machinery/plumbing/disposer/on_reagent_change(changetype)
	. = ..()
	update_appearance(UPDATE_ICON_STATE)

/obj/machinery/plumbing/disposer/update_icon_state()
	icon_state = "[initial(icon_state)][!(machine_stat & NOPOWER) && anchored && on && reagents?.total_volume ? "_working" : ""]"
	return ..()

/obj/machinery/plumbing/disposer/power_change()
	. = ..()
	update_appearance(UPDATE_ICON_STATE)

/obj/machinery/plumbing/disposer/ui_state(mob/user)
	return GLOB.default_state

/obj/machinery/plumbing/disposer/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "ChemDisposer", name)
		ui.open()

/obj/machinery/plumbing/disposer/ui_static_data(mob/user)
	return list(
		max_volume = MAX_DISPOSAL_RATE
	)

/obj/machinery/plumbing/disposer/ui_data(mob/user)
	return list(
		enabled = on,
		disposal_rate = disposal_rate
	)

/obj/machinery/plumbing/disposer/ui_act(action, list/params)
	. = ..()
	if(.)
		return

	switch(action)
		if("toggle_power")
			on = !on
			update_appearance(UPDATE_ICON_STATE)
			return TRUE

		if("change_volume")
			var/num = text2num(params["volume"])
			if(!isnum(num))
				return FALSE

			disposal_rate = round(clamp(num, 0.1, MAX_DISPOSAL_RATE), 0.01)
			return TRUE

/obj/machinery/plumbing/disposer/process(delta_time)
	if(machine_stat & NOPOWER || !reagents.total_volume || !on)
		return
	reagents.remove_all(disposal_rate * delta_time)
	use_power((disposal_rate / MAX_DISPOSAL_RATE) * active_power_usage * delta_time)

#undef MAX_DISPOSAL_RATE
