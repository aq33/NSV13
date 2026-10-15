/// Plumbing constructor (RPLD) ported from tg, with a radial menu instead of the tgui one.
/obj/item/construction/plumbing
	name = "Plumbing Constructor"
	desc = "An expertly modified RCD outfitted to construct plumbing machinery."
	icon_state = "plumberer2"
	icon = 'icons/obj/tools.dmi'
	slot_flags = ITEM_SLOT_BELT

	matter = 200
	max_matter = 200

	///type of the plumbing machine
	var/obj/machinery/blueprint = null
	///Current selected layer
	var/current_layer = DUCT_LAYER_DEFAULT
	///Current selected color name, for ducts
	var/current_color = DUCT_COLOR_OMNI
	/// category => list(machine type => matter cost)
	var/list/design_types = list(
		"Synthesizers" = list(
			/obj/machinery/plumbing/synthesizer = 15,
			/obj/machinery/plumbing/reaction_chamber = 15,
			/obj/machinery/plumbing/grinder_chemical = 30,
			/obj/machinery/plumbing/fermenter = 30,
			/obj/machinery/plumbing/disposer = 10,
		),
		"Distributors" = list(
			/obj/machinery/duct = 1,
			/obj/machinery/plumbing/layer_manifold = 5,
			/obj/machinery/plumbing/input = 5,
			/obj/machinery/plumbing/filter = 5,
			/obj/machinery/plumbing/splitter = 5,
			/obj/machinery/plumbing/sender = 20,
			/obj/machinery/plumbing/output = 5,
		),
		"Storage" = list(
			/obj/machinery/plumbing/tank = 20,
			/obj/machinery/plumbing/acclimator = 10,
			/obj/machinery/plumbing/buffer = 10,
			/obj/machinery/plumbing/bottler = 50,
			/obj/machinery/plumbing/pill_press = 20,
			/obj/machinery/plumbing/patch_dispenser = 20,
			/obj/machinery/plumbing/bottle_dispenser = 20,
		),
	)

/obj/item/construction/plumbing/Initialize(mapload)
	. = ..()
	blueprint = /obj/machinery/duct

/obj/item/construction/plumbing/examine(mob/user)
	. = ..()
	. += "<span class='notice'>Schemat: <b>[initial(blueprint.name)]</b>. Warstwa: [GLOB.plumbing_layer_names["[current_layer]"]], kolor rur: [current_color].</span>"
	. += "<span class='notice'>Użyj w dłoni, żeby wybrać maszynę. <b>Alt-klik</b> zmienia warstwę i kolor rur.</span>"
	. += "<span class='notice'><b>Prawy klik</b> na rurze kopiuje jej kolor i warstwę. Klik na odkręconej maszynie lub rurze ją rozbiera.</span>"

/// Cost of the given design, null when we can't build it
/obj/item/construction/plumbing/proc/get_cost(design)
	for(var/category in design_types)
		var/cost = design_types[category][design]
		if(cost)
			return cost

/obj/item/construction/plumbing/attack_self(mob/user)
	..()
	var/list/choices = list()
	var/list/name_to_type = list()
	for(var/category in design_types)
		for(var/obj/machinery/design as anything in design_types[category])
			var/label = "[initial(design.name)] ([design_types[category][design]])"
			var/image/preview = image(icon = initial(design.icon), icon_state = initial(design.icon_state))
			if(ispath(design, /obj/machinery/duct))
				preview.icon_state = "nduct_n_s"
			choices[label] = preview
			name_to_type[label] = design

	var/choice = show_radial_menu(user, src, choices, custom_check = CALLBACK(src, PROC_REF(check_menu), user), require_near = TRUE, tooltips = TRUE)
	if(!choice || !check_menu(user))
		return

	blueprint = name_to_type[choice]
	playsound(src, 'sound/effects/pop.ogg', 50, FALSE)
	to_chat(user, "<span class='notice'>Wybierasz schemat „[initial(blueprint.name)]”.</span>")

/obj/item/construction/plumbing/AltClick(mob/user)
	if(!user.canUseTopic(src, BE_CLOSE, FALSE, NO_TK))
		return
	var/new_layer = tgui_input_list(user, "Wybierz warstwę", "Warstwa", GLOB.plumbing_layers, GLOB.plumbing_layer_names["[current_layer]"])
	if(new_layer && user.is_holding(src))
		current_layer = GLOB.plumbing_layers[new_layer]
	var/new_color = tgui_input_list(user, "Wybierz kolor rur", "Kolor", get_duct_colors(), current_color)
	if(new_color && user.is_holding(src))
		current_color = new_color
	to_chat(user, "<span class='notice'>Warstwa: [GLOB.plumbing_layer_names["[current_layer]"]], kolor rur: [current_color].</span>")

///pretty much rcd_create, but named differently to make myself feel less bad for copypasting from a sibling-type
/obj/item/construction/plumbing/proc/create_machine(turf/destination, mob/user)
	if(!blueprint || !isopenturf(destination) || isspaceturf(destination))
		return FALSE

	var/cost = get_cost(blueprint)
	if(!cost)
		return FALSE

	if(!checkResource(cost, user) || !canPlace(destination, user))
		return FALSE
	if(!do_after(user, cost, target = destination))
		return FALSE
	if(!checkResource(cost, user) || !canPlace(destination, user))
		return FALSE

	useResource(cost, user)
	activate()
	playsound(loc, 'sound/machines/click.ogg', 50, TRUE)
	if(ispath(blueprint, /obj/machinery/duct))
		new blueprint(destination, current_color, current_layer)
	else
		new blueprint(destination, current_layer)
	return TRUE

/obj/item/construction/plumbing/proc/canPlace(turf/destination, mob/user)
	if(!isopenturf(destination))
		return FALSE
	var/datum/overlap = ducting_layer_check(destination, ispath(blueprint, /obj/machinery/duct) ? current_layer : -current_layer)
	if(!isnull(overlap))
		if(user)
			destination.balloon_alert(user, "na tym polu jest już [istype(overlap, /obj/machinery/duct) ? "rura" : "maszyna"]!")
		return FALSE
	if(ispath(blueprint, /obj/machinery/duct))
		return TRUE
	for(var/obj/thing in destination.contents)
		if(thing.density) //let's not built ontop of dense stuff, like big machines and other obstacles, it kills my immershion
			if(user)
				destination.balloon_alert(user, "coś blokuje to pole!")
			return FALSE
	return TRUE

/obj/item/construction/plumbing/afterattack(atom/target, mob/user, proximity)
	. = ..()
	if(!prox_check(proximity))
		return
	if(istype(target, /obj/machinery/plumbing) || istype(target, /obj/machinery/duct))
		var/obj/machinery/machine = target
		if(istype(machine, /obj/machinery/plumbing) && machine.anchored)
			to_chat(user, "<span class='warning'>Najpierw odkręć [machine.name]!</span>")
			return
		if(do_after(user, 2 SECONDS, target = machine))
			machine.deconstruct() //Let's not substract matter
			playsound(get_turf(src), 'sound/machines/click.ogg', 50, TRUE) //this is just such a great sound effect
		return
	create_machine(get_turf(target), user)

/obj/item/construction/plumbing/afterattack_secondary(atom/target, mob/user, proximity_flag, click_parameters)
	if(!istype(target, /obj/machinery/duct))
		return ..()
	var/obj/machinery/duct/duct = target
	current_color = duct.duct_color
	current_layer = duct.duct_layer
	blueprint = /obj/machinery/duct
	balloon_alert(user, "skopiowano kolor i warstwę")
	return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN

/obj/item/construction/plumbing/service
	name = "service plumbing constructor"
	desc = "A type of plumbing constructor designed to rapidly deploy the machines needed to make a brewery."
	icon_state = "plumberer_service"
	design_types = list(
		"Synthesizers" = list(
			/obj/machinery/plumbing/synthesizer/soda = 15,
			/obj/machinery/plumbing/synthesizer/beer = 15,
			/obj/machinery/plumbing/reaction_chamber = 15,
			/obj/machinery/plumbing/buffer = 10,
			/obj/machinery/plumbing/fermenter = 30,
			/obj/machinery/plumbing/grinder_chemical = 30,
			/obj/machinery/plumbing/disposer = 10,
		),
		"Distributors" = list(
			/obj/machinery/duct = 1,
			/obj/machinery/plumbing/layer_manifold = 5,
			/obj/machinery/plumbing/input = 5,
			/obj/machinery/plumbing/filter = 5,
			/obj/machinery/plumbing/splitter = 5,
			/obj/machinery/plumbing/output/tap = 5,
			/obj/machinery/plumbing/sender = 20,
		),
		"Storage" = list(
			/obj/machinery/plumbing/bottler = 50,
			/obj/machinery/plumbing/tank = 20,
			/obj/machinery/plumbing/acclimator = 10,
		),
	)
