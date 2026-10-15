/obj/machinery/duct
	name = "fluid duct"
	desc = "A pipe for moving reagents between plumbing machines."
	icon = 'aquila/icons/obj/plumbing/fluid_ducts.dmi'
	icon_state = "nduct"
	layer = PLUMBING_PIPE_VISIBILE_LAYER
	level = 1
	use_power = NO_POWER_USE
	idle_power_usage = 0
	active_power_usage = 0
	processing_flags = START_PROCESSING_MANUALLY
	anchored = TRUE

	///our ductnet, wich tracks what we're connected to
	var/datum/ductnet/net
	///the color name of our duct, see get_duct_colors()
	var/duct_color = DUCT_COLOR_OMNI
	///the layer of the duct
	var/duct_layer = DUCT_LAYER_DEFAULT
	///track machines we're connected to.
	var/list/atom/movable/neighbours

/obj/machinery/duct/Initialize(mapload, color_of_duct, layer_of_duct)
	if(GLOB.plumbing_layer_names["[layer_of_duct]"])
		duct_layer = layer_of_duct
	if(color_of_duct in get_duct_colors())
		duct_color = color_of_duct

	. = ..()

	var/color_value = duct_color_value(duct_color)
	if(color_value)
		add_atom_colour(color_value, FIXED_COLOUR_PRIORITY)

	var/offset = duct_layer_offset(duct_layer)
	pixel_x = offset
	pixel_y = offset
	layer = initial(layer) + duct_layer * 0.0003

	var/turf/our_turf = loc
	if(isturf(our_turf))
		hide(our_turf.intact)

	return INITIALIZE_HINT_LATELOAD

/obj/machinery/duct/LateInitialize()
	. = ..()

	//can be initialized already during map init by its neighbours
	if(!net)
		net = new (src)

	LAZYINITLIST(neighbours)
	for(var/direction in GLOB.cardinals)
		//we have already connected. happens in circular connections
		var/connected = FALSE
		for(var/atom/movable/neighbour as anything in neighbours)
			if(direction & neighbours[neighbour])
				connected = TRUE
				break
		if(connected)
			continue

		for(var/atom/movable/plumbable in get_step(src, direction))
			var/opposite_dir = REVERSE_DIR(direction)

			if(istype(plumbable, /obj/machinery/duct))
				var/obj/machinery/duct/other = plumbable
				if(QDELETED(other))
					continue

				//must be same duct color
				if((duct_color != other.duct_color) && !(duct_color == DUCT_COLOR_OMNI || other.duct_color == DUCT_COLOR_OMNI))
					continue
				//must be same duct layer
				if(!(duct_layer & other.duct_layer))
					continue

				//connect ductnets
				if(!other.net) //will be null only for map loaded ducts
					net.ducts += other
					other.net = net
				else if(net != other.net) //merge the nets
					merge_net(other.net)

				//connecting us to duct
				neighbours[other] = direction
				//connecting duct to us
				LAZYADDASSOC(other.neighbours, src, opposite_dir)
				other.update_appearance(UPDATE_ICON)

				continue

			for(var/datum/component/plumbing/plumbing in plumbable.GetComponents(/datum/component/plumbing))
				//not anchored
				if(!plumbing.active())
					continue

				//not on the same layer
				if(!(duct_layer & plumbing.ducting_layer))
					continue

				//does the duct backend connect to either supplier or demander
				if(!(opposite_dir & (plumbing.supply_connects | plumbing.demand_connects)))
					continue

				//connect duct to plumber
				if(!net.add_plumber(plumbing, opposite_dir))
					continue

				//assign neighbour
				neighbours[plumbing.parent] = direction

	update_appearance(UPDATE_ICON)

/// Takes over every duct and plumber of another network
/obj/machinery/duct/proc/merge_net(datum/ductnet/othernet)
	//Take all its suppliers & demanders
	net.suppliers |= othernet.suppliers
	net.demanders |= othernet.demanders
	for(var/datum/component/plumbing/component as anything in othernet.suppliers + othernet.demanders)
		for(var/dirtext in component.ducts)
			if(component.ducts[dirtext] == othernet)
				component.ducts[dirtext] = net
	othernet.suppliers.Cut()
	othernet.demanders.Cut()

	//Take all its ducts
	net.ducts |= othernet.ducts
	for(var/obj/machinery/duct/duct as anything in othernet.ducts)
		duct.net = net
	othernet.ducts.Cut()

	//destory it
	qdel(othernet)

/obj/machinery/duct/hide(intact)
	if(level == 1 && isturf(loc))
		invisibility = intact ? INVISIBILITY_MAXIMUM : 0
	update_appearance(UPDATE_ICON)

/obj/machinery/duct/on_deconstruction()
	var/obj/item/stack/ducts/duct_stack = new (drop_location())
	duct_stack.duct_color = duct_color
	duct_stack.duct_layer = duct_layer
	var/color_value = duct_color_value(duct_color)
	if(color_value)
		duct_stack.add_atom_colour(color_value, FIXED_COLOUR_PRIORITY)

///Removes duct from ductnet
/obj/machinery/duct/proc/disconnect()
	if(!net)
		return
	//remove ourself from the duct
	net.ducts -= src
	if(!net.ducts.len)
		qdel(net) //destroy the pipeline. Suppliers aren't important if there aren't any ducts left
	net = null

/obj/machinery/duct/Destroy()
	//object was early deleted
	if(!net)
		return ..()

	var/list/atom/movable/visited = list()
	visited[src] = TRUE
	while(LAZYLEN(neighbours))
		var/atom/movable/neighbour = neighbours[1]
		neighbours.Cut(1, 2)

		//disconnect ourself from our neighbours
		var/obj/machinery/duct/pipe = neighbour
		if(istype(pipe))
			LAZYREMOVE(pipe.neighbours, src)
			pipe.update_appearance(UPDATE_ICON)

		//find every node that can be reached from our neighbour making sure to not revisit it again in circles
		if(visited[neighbour])
			continue
		var/datum/ductnet/newnet
		var/list/atom/movable/queue = list(neighbour)
		while(queue.len)
			var/atom/movable/node = queue[1]
			queue.Cut(1, 2)
			if(visited[node])
				continue

			//visit all neighbours of this pipe as well
			pipe = node
			if(istype(pipe))
				//assign to new pipenet
				pipe.disconnect()
				if(!newnet)
					newnet = new
				newnet.ducts += pipe
				pipe.net = newnet

				//go through its neighbours as well
				for(var/atom/movable/subnode in pipe.neighbours)
					queue += subnode

				visited[node] = TRUE
				continue

			//assign machines to new network
			for(var/datum/component/plumbing/plumbing in node.GetComponents(/datum/component/plumbing))
				//disconnect old net
				for(var/dirtext in plumbing.ducts.Copy())
					if(plumbing.ducts[dirtext] == net)
						net.remove_plumber(plumbing)
				//assign new net
				if(newnet)
					for(var/obj/machinery/duct/other_pipe as anything in newnet.ducts)
						var/dir = other_pipe.neighbours?[node]
						if(dir)
							newnet.add_plumber(plumbing, REVERSE_DIR(dir))

	disconnect()

	return ..()

/obj/machinery/duct/examine(mob/user)
	. = ..()
	. += "<span class='notice'>Kolor: [duct_color], warstwa: [GLOB.plumbing_layer_names["[duct_layer]"]].</span>"
	. += "<span class='notice'>Można ją rozkręcić <b>kluczem</b>.</span>"

/obj/machinery/duct/update_icon_state()
	var/temp_icon = initial(icon_state)

	//compute connections
	var/connects = NONE
	for(var/neighbour in neighbours)
		connects |= neighbours[neighbour]

	for(var/direction in GLOB.cardinals)
		switch(direction & connects)
			if(NORTH)
				temp_icon += "_n"
			if(SOUTH)
				temp_icon += "_s"
			if(EAST)
				temp_icon += "_e"
			if(WEST)
				temp_icon += "_w"
	icon_state = temp_icon
	return ..()

/obj/machinery/duct/wrench_act(mob/living/user, obj/item/wrench) //I can also be the RPD
	var/turf/our_turf = loc
	if(isturf(our_turf) && our_turf.intact)
		return FALSE
	wrench.play_tool_sound(src)

	user.visible_message( \
	"[user] rozkręca [src].", \
	"<span class='notice'>Rozkręcasz [src].</span>", \
	"<span class='italics'>Słyszysz grzechotanie klucza.</span>")

	deconstruct()
	return TRUE

/obj/item/stack/ducts
	name = "stack of duct"
	desc = "A stack of fluid ducts."
	singular_name = "duct"
	icon = 'aquila/icons/obj/plumbing/fluid_ducts.dmi'
	icon_state = "ducts"
	w_class = WEIGHT_CLASS_TINY
	novariants = FALSE
	max_amount = 50
	item_flags = NOBLUDGEON
	merge_type = /obj/item/stack/ducts
	///Color name of our duct
	var/duct_color = DUCT_COLOR_OMNI
	///Default layer of our duct
	var/duct_layer = DUCT_LAYER_DEFAULT

/obj/item/stack/ducts/examine(mob/user)
	. = ..()
	. += "<span class='notice'>Kolor: [duct_color], warstwa: [GLOB.plumbing_layer_names["[duct_layer]"]]. Użyj w dłoni, by zmienić.</span>"
	. += "<span class='notice'>Połóż na podłodze i przykręć <b>kluczem</b> albo kliknij nim na odsłoniętą podłogę, żeby postawić rurę.</span>"

/obj/item/stack/ducts/attack_self(mob/user)
	var/new_layer = tgui_input_list(user, "Wybierz warstwę", "Warstwa", GLOB.plumbing_layers, GLOB.plumbing_layer_names["[duct_layer]"])
	if(!user.is_holding(src))
		return
	if(new_layer)
		duct_layer = GLOB.plumbing_layers[new_layer]
	var/new_color = tgui_input_list(user, "Wybierz kolor", "Kolor", get_duct_colors(), duct_color)
	if(!user.is_holding(src))
		return
	if(new_color)
		duct_color = new_color
		remove_atom_colour(FIXED_COLOUR_PRIORITY)
		var/color_value = duct_color_value(duct_color)
		if(color_value)
			add_atom_colour(color_value, FIXED_COLOUR_PRIORITY)

/obj/item/stack/ducts/wrench_act(mob/living/user, obj/item/tool)
	if(check_attach_turf(loc, user))
		return TRUE
	return ..()

/obj/item/stack/ducts/afterattack(atom/target, mob/user, proximity_flag, click_parameters)
	. = ..()
	if(!proximity_flag)
		return
	// Turn into a duct stack and then merge to the in-hand stack.
	if(istype(target, /obj/machinery/duct))
		if(amount >= max_amount)
			balloon_alert(user, "stos pełny!")
			return
		var/obj/machinery/duct/pipe = target
		var/turf/pipe_turf = pipe.loc
		if(isturf(pipe_turf) && pipe_turf.intact)
			return
		qdel(pipe)
		add(1)
		return
	check_attach_turf(target, user)

/obj/item/stack/ducts/proc/check_attach_turf(turf/open/open_turf, mob/user)
	if(!isopenturf(open_turf) || isspaceturf(open_turf))
		return FALSE
	if(open_turf.intact)
		if(user)
			open_turf.balloon_alert(user, "zdejmij najpierw płytkę!")
		return FALSE
	var/datum/overlap = ducting_layer_check(open_turf, duct_layer)
	if(!isnull(overlap))
		if(user)
			open_turf.balloon_alert(user, "na tym polu jest już [istype(overlap, /obj/machinery/duct) ? "rura" : "maszyna"]!")
		return FALSE

	new /obj/machinery/duct(open_turf, duct_color, duct_layer)
	playsound(open_turf, 'sound/machines/click.ogg', 50, TRUE)
	use(1)
	return TRUE

/obj/item/stack/ducts/fifty
	amount = 50
