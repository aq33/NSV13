// Port z aq33/tgstation#479 (oryginalnie z Yogstation): bluespace pipes, czyli teleportujące się rurki.
// Wszystkie rurki o tej samej nazwie sieci dzielą jeden pipeline.

GLOBAL_LIST_EMPTY(bluespace_pipe_networks)

/obj/machinery/atmospherics/pipe/bluespace
	name = "bluespace pipe"
	desc = "Transmits gas across large distances of space. Developed using bluespace technology."
	icon = 'aquila/icons/obj/atmospherics/pipes/bluespace.dmi'
	icon_state = "map"
	pipe_state = "bluespace"
	dir = SOUTH
	initialize_directions = SOUTH
	device_type = UNARY
	can_buckle = FALSE
	paintable = FALSE
	construction_type = /obj/item/pipe/bluespace
	var/shift_underlay_only = TRUE
	var/bluespace_network_name

/obj/machinery/atmospherics/pipe/bluespace/New()
	icon_state = "pipe"
	if(bluespace_network_name) // in case someone maps one in for some reason
		add_to_bluespace_network()
	return ..()

/obj/machinery/atmospherics/pipe/bluespace/on_construction(obj_color, set_layer)
	// Rejestrujemy się przed ..(), żeby pipeline_expansion() w on_construction() złączył nas z resztą sieci
	if(bluespace_network_name)
		add_to_bluespace_network()
	return ..()

/obj/machinery/atmospherics/pipe/bluespace/Destroy()
	var/list/network = GLOB.bluespace_pipe_networks[bluespace_network_name]
	if(network)
		network -= src
	. = ..()
	for(var/obj/machinery/atmospherics/pipe/bluespace/P as anything in network)
		P.destroy_network()
		SSair.add_to_rebuild_queue(P)

/obj/machinery/atmospherics/pipe/bluespace/proc/add_to_bluespace_network()
	if(!GLOB.bluespace_pipe_networks[bluespace_network_name])
		GLOB.bluespace_pipe_networks[bluespace_network_name] = list()
	GLOB.bluespace_pipe_networks[bluespace_network_name] |= src

/obj/machinery/atmospherics/pipe/bluespace/examine(mob/user)
	. = ..()
	. += "<span class='notice'>This one is connected to the \"[html_encode(bluespace_network_name)]\" network.</span>"

/obj/machinery/atmospherics/pipe/bluespace/set_init_directions()
	initialize_directions = dir

/obj/machinery/atmospherics/pipe/bluespace/pipeline_expansion()
	. = ..()
	var/list/network = GLOB.bluespace_pipe_networks[bluespace_network_name]
	if(network)
		. = . + network - src

/obj/machinery/atmospherics/pipe/bluespace/hide(i)
	update_icon()

/obj/machinery/atmospherics/pipe/bluespace/update_icon()
	underlays.Cut()

	var/showpipe
	var/turf/T = loc
	if(level == 2 || (istype(T) && !T.intact))
		showpipe = TRUE
		plane = GAME_PLANE
	else
		showpipe = FALSE
		plane = FLOOR_PLANE

	if(!showpipe)
		return //no need to update the pipes if they aren't showing

	var/connected = 0 //Direction bitset

	for(var/i in 1 to device_type) //adds intact pieces
		if(nodes[i])
			var/obj/machinery/atmospherics/node = nodes[i]
			var/image/img = get_pipe_underlay("pipe_intact", get_dir(src, node), node.pipe_color)
			underlays += img
			connected |= img.dir

	for(var/direction in GLOB.cardinals)
		if((initialize_directions & direction) && !(connected & direction))
			underlays += get_pipe_underlay("pipe_exposed", direction)

	if(!shift_underlay_only)
		PIPING_LAYER_SHIFT(src, piping_layer)

/obj/machinery/atmospherics/pipe/bluespace/proc/get_pipe_underlay(state, dir, color = null)
	if(color)
		. = get_pipe_image('icons/obj/atmospherics/components/binary_devices.dmi', state, dir, color, piping_layer = shift_underlay_only ? piping_layer : 3)
	else
		. = get_pipe_image('icons/obj/atmospherics/components/binary_devices.dmi', state, dir, piping_layer = shift_underlay_only ? piping_layer : 3)

// Item

/obj/item/pipe
	/// Czy RPD/dyspenser może to zniszczyć
	var/disposable = TRUE

/obj/item/pipe/bluespace
	pipe_type = /obj/machinery/atmospherics/pipe/bluespace
	icon_state = "bluespace"
	disposable = FALSE
	var/bluespace_network_name = "default"

/obj/item/pipe/bluespace/Initialize(mapload, _pipe_type, _dir, obj/machinery/atmospherics/make_from)
	// Z protolathe przychodzimy bez _pipe_type, a bazowe Initialize nadpisałoby nim nasz pipe_type
	return ..(mapload, _pipe_type || pipe_type, _dir || dir, make_from)

/obj/item/pipe/bluespace/examine(mob/user)
	. = ..()
	. += "<span class='notice'>It is linked to the \"[html_encode(bluespace_network_name)]\" network.</span>"

/obj/item/pipe/bluespace/attack_self(mob/user)
	var/new_name = stripped_input(user, "Enter identifier for bluespace pipe network", "bluespace pipe", bluespace_network_name, MAX_NAME_LEN)
	if(!isnull(new_name) && user.canUseTopic(src, BE_CLOSE))
		bluespace_network_name = new_name

/obj/item/pipe/bluespace/make_from_existing(obj/machinery/atmospherics/pipe/bluespace/make_from)
	bluespace_network_name = make_from.bluespace_network_name
	return ..()

/obj/item/pipe/bluespace/build_pipe(obj/machinery/atmospherics/pipe/bluespace/A)
	A.bluespace_network_name = bluespace_network_name
	return ..()

// Ochrona przed zniszczeniem

/obj/machinery/pipedispenser/attackby(obj/item/W, mob/user, params)
	if(istype(W, /obj/item/pipe))
		var/obj/item/pipe/P = W
		if(!P.disposable)
			to_chat(user, "<span class='warning'>\The [P] is too valuable to dispose of!</span>")
			return
	return ..()

// Musi się zgadzać z DESTROY_MODE z code/game/objects/items/RPD.dm (tam jest #undef)
#define RPD_DESTROY_MODE 4

/obj/item/pipe_dispenser/pre_attack(atom/A, mob/user)
	if((mode & RPD_DESTROY_MODE) && istype(A, /obj/item/pipe))
		var/obj/item/pipe/P = A
		if(!P.disposable)
			to_chat(user, "<span class='warning'>\The [P] is too valuable to dispose of!</span>")
			return TRUE
	return ..()

#undef RPD_DESTROY_MODE

// Design

/datum/design/bluespace_pipe
	name = "Bluespace Pipe"
	desc = "A pipe that teleports gases."
	id = "bluespace_pipe"
	build_type = PROTOLATHE
	materials = list(/datum/material/gold = 1000, /datum/material/diamond = 750, /datum/material/uranium = 250, /datum/material/bluespace = 2000)
	build_path = /obj/item/pipe/bluespace
	category = list("Bluespace Designs")
	departmental_flags = DEPARTMENTAL_FLAG_SCIENCE | DEPARTMENTAL_FLAG_ENGINEERING
