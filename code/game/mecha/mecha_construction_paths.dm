////////////////////////////////
///// Construction datums //////
////////////////////////////////
/datum/component/construction/mecha
	var/base_icon

	// Component typepaths.
	// most must be defined unless
	// get_steps is overriden.

	// Circuit board typepaths.
	// circuit_control and circuit_periph must be defined
	// unless get_circuit_steps is overriden.
	var/circuit_control
	var/circuit_periph
	var/circuit_weapon

	// Armor plating typepaths. both must be defined
	// unless relevant step procs are overriden. amounts
	// must be defined if using /obj/item/stack/sheet types
	var/inner_plating
	var/inner_plating_amount

	var/outer_plating
	var/outer_plating_amount

/datum/component/construction/mecha/spawn_result()
	if(!result)
		return
	// Remove default mech power cell, as we replace it with a new one.
	var/obj/mecha/M = new result(drop_location())
	QDEL_NULL(M.cell)
	QDEL_NULL(M.scanmod)
	QDEL_NULL(M.capacitor)

	var/obj/item/mecha_parts/chassis/parent_chassis = parent
	M.CheckParts(parent_chassis.contents)

	SSblackbox.record_feedback("tally", "mechas_created", 1, M.name)
	QDEL_NULL(parent)

// Default proc to generate mech steps.
// Override if the mech needs an entirely custom process (See HONK mech)
// Otherwise override specific steps as needed (Ripley, firefighter, Phazon)
/datum/component/construction/mecha/proc/get_steps()
	return get_frame_steps() + get_circuit_steps() + (circuit_weapon ? get_circuit_weapon_steps() : list()) + get_stockpart_steps() + get_inner_plating_steps() + get_outer_plating_steps()

/datum/component/construction/mecha/update_parent(step_index)
	steps = get_steps()
	..()
	// By default, each step in mech construction has a single icon_state:
	// "[base_icon][index - 1]"
	// For example, Ripley's step 1 icon_state is "ripley0".
	var/atom/parent_atom = parent
	if(!steps[index]["icon_state"] && base_icon)
		parent_atom.icon_state = "[base_icon][index - 1]"

/datum/component/construction/unordered/mecha_chassis/custom_action(obj/item/I, mob/living/user, typepath)
	. = user.transferItemToLoc(I, parent)
	if(.)
		var/atom/parent_atom = parent
		user.visible_message("[user] podłącza [I] do [parent].", "<span class='notice'>Podłączasz [I] do [parent].</span>")
		parent_atom.add_overlay(I.icon_state+"+o")
		qdel(I)

/datum/component/construction/unordered/mecha_chassis/spawn_result()
	var/atom/parent_atom = parent
	parent_atom.icon = 'icons/mecha/mech_construction.dmi'
	parent_atom.density = TRUE
	parent_atom.cut_overlays()
	..()

// Default proc for the first steps of mech construction.
/datum/component/construction/mecha/proc/get_frame_steps()
	return list(
		list(
			"key" = TOOL_WRENCH,
			"desc" = "The hydraulic systems are disconnected."
		),
		list(
			"key" = TOOL_SCREWDRIVER,
			"back_key" = TOOL_WRENCH,
			"desc" = "The hydraulic systems are connected."
		),
		list(
			"key" = /obj/item/stack/cable_coil,
			"amount" = 5,
			"back_key" = TOOL_SCREWDRIVER,
			"desc" = "The hydraulic systems are active."
		),
		list(
			"key" = TOOL_WIRECUTTER,
			"back_key" = TOOL_SCREWDRIVER,
			"desc" = "The wiring is added."
		)
	)

// Default proc for the circuit board steps of a mech.
// Second set of steps by default.
/datum/component/construction/mecha/proc/get_circuit_steps()
	return list(
		list(
			"key" = circuit_control,
			"action" = ITEM_DELETE,
			"back_key" = TOOL_SCREWDRIVER,
			"desc" = "The wiring is adjusted."
		),
		list(
			"key" = TOOL_SCREWDRIVER,
			"back_key" = TOOL_CROWBAR,
			"desc" = "Central control module is installed."
		),
		list(
			"key" = circuit_periph,
			"action" = ITEM_DELETE,
			"back_key" = TOOL_SCREWDRIVER,
			"desc" = "Central control module is secured."
		),
		list(
			"key" = TOOL_SCREWDRIVER,
			"back_key" = TOOL_CROWBAR,
			"desc" = "Peripherals control module is installed."
		)
	)

// Default proc for weapon circuitboard steps
// Used by combat mechs
/datum/component/construction/mecha/proc/get_circuit_weapon_steps()
	return list(
		list(
			"key" = circuit_weapon,
			"action" = ITEM_DELETE,
			"back_key" = TOOL_SCREWDRIVER,
			"desc" = "Peripherals control module is secured."
		),
		list(
			"key" = TOOL_SCREWDRIVER,
			"back_key" = TOOL_CROWBAR,
			"desc" = "Weapons control module is installed."
		)
	)

// Default proc for stock part installation
// Third set of steps by default
/datum/component/construction/mecha/proc/get_stockpart_steps()
	var/prevstep_text = circuit_weapon ? "Moduł sterowania uzbrojeniem jest zabezpieczony." : "Moduł sterowania peryferiami jest zabezpieczony."
	return list(
		list(
			"key" = /obj/item/stock_parts/scanning_module,
			"action" = ITEM_MOVE_INSIDE,
			"back_key" = TOOL_SCREWDRIVER,
			"desc" = prevstep_text
		),
		list(
			"key" = TOOL_SCREWDRIVER,
			"back_key" = TOOL_CROWBAR,
			"desc" = "Scanner module is installed."
		),
		list(
			"key" = /obj/item/stock_parts/capacitor,
			"action" = ITEM_MOVE_INSIDE,
			"back_key" = TOOL_SCREWDRIVER,
			"desc" = "Scanner module is secured."
		),
		list(
			"key" = TOOL_SCREWDRIVER,
			"back_key" = TOOL_CROWBAR,
			"desc" = "Capacitor is installed."
		),
		list(
			"key" = /obj/item/stock_parts/cell,
			"action" = ITEM_MOVE_INSIDE,
			"back_key" = TOOL_SCREWDRIVER,
			"desc" = "Capacitor is secured."
		),
		list(
			"key" = TOOL_SCREWDRIVER,
			"back_key" = TOOL_CROWBAR,
			"desc" = "The power cell is installed."
		)
	)

// Default proc for inner armor plating
// Fourth set of steps by default
/datum/component/construction/mecha/proc/get_inner_plating_steps()
	var/list/first_step
	if(ispath(inner_plating, /obj/item/stack/sheet))
		first_step = list(
			list(
				"key" = inner_plating,
				"amount" = inner_plating_amount,
				"back_key" = TOOL_SCREWDRIVER,
				"desc" = "The power cell is secured."
			)
		)
	else
		first_step = list(
			list(
				"key" = inner_plating,
				"action" = ITEM_DELETE,
				"back_key" = TOOL_SCREWDRIVER,
				"desc" = "The power cell is secured."
			)
		)

	return first_step + list(
		list(
			"key" = TOOL_WRENCH,
			"back_key" = TOOL_CROWBAR,
			"desc" = "Inner plating is installed."
		),
		list(
			"key" = TOOL_WELDER,
			"back_key" = TOOL_WRENCH,
			"desc" = "Inner Plating is wrenched."
		)
	)

// Default proc for outer armor plating
// Fifth set of steps by default
/datum/component/construction/mecha/proc/get_outer_plating_steps()
	var/list/first_step
	if(ispath(outer_plating, /obj/item/stack/sheet))
		first_step = list(
			list(
				"key" = outer_plating,
				"amount" = outer_plating_amount,
				"back_key" = TOOL_WELDER,
				"desc" = "Inner plating is welded."
			)
		)
	else
		first_step = list(
			list(
				"key" = outer_plating,
				"action" = ITEM_DELETE,
				"back_key" = TOOL_WELDER,
				"desc" = "Inner plating is welded."
			)
		)

	return first_step + list(
		list(
			"key" = TOOL_WRENCH,
			"back_key" = TOOL_CROWBAR,
			"desc" = "External armor is installed."
		),
		list(
			"key" = TOOL_WELDER,
			"back_key" = TOOL_WRENCH,
			"desc" = "External armor is wrenched."
		)
	)


/datum/component/construction/unordered/mecha_chassis/ripley
	result = /datum/component/construction/mecha/ripley
	steps = list(
		/obj/item/mecha_parts/part/ripley_torso,
		/obj/item/mecha_parts/part/ripley_left_arm,
		/obj/item/mecha_parts/part/ripley_right_arm,
		/obj/item/mecha_parts/part/ripley_left_leg,
		/obj/item/mecha_parts/part/ripley_right_leg
	)

/datum/component/construction/mecha/ripley
	result = /obj/mecha/working/ripley
	base_icon = "ripley"

	circuit_control = /obj/item/circuitboard/mecha/ripley/main
	circuit_periph = /obj/item/circuitboard/mecha/ripley/peripherals

	inner_plating=/obj/item/stack/sheet/iron
	inner_plating_amount = 5

	outer_plating=/obj/item/stack/rods
	outer_plating_amount = 10

/datum/component/construction/mecha/ripley/get_outer_plating_steps()
	return list(
		list(
			"key" = /obj/item/stack/rods,
			"amount" = 10,
			"back_key" = TOOL_WELDER,
			"desc" = "Outer Plating is welded."
		),
		list(
			"key" = TOOL_WELDER,
			"back_key" = TOOL_WIRECUTTER,
			"desc" = "Cockpit wire screen is installed."
		),
	)

/datum/component/construction/mecha/ripley/custom_action(obj/item/I, mob/living/user, diff)
	if(!..())
		return FALSE

	switch(index)
		if(1)
			user.visible_message("[user] podłącza układ hydrauliczny [parent]", "<span class='notice'>Podłączasz układ hydrauliczny [parent].</span>")
		if(2)
			if(diff==FORWARD)
				user.visible_message("[user] uruchamia układ hydrauliczny [parent].", "<span class='notice'>Uruchamiasz układ hydrauliczny [parent].</span>")
			else
				user.visible_message("[user] odłącza układ hydrauliczny [parent]", "<span class='notice'>Odłączasz układ hydrauliczny [parent].</span>")
		if(3)
			if(diff==FORWARD)
				user.visible_message("[user] dodaje okablowanie do [parent].", "<span class='notice'>Dodajesz okablowanie do [parent].</span>")
			else
				user.visible_message("[user] wyłącza układ hydrauliczny [parent].", "<span class='notice'>Wyłączasz układ hydrauliczny [parent].</span>")
		if(4)
			if(diff==FORWARD)
				user.visible_message("[user] poprawia okablowanie [parent].", "<span class='notice'>Poprawiasz okablowanie [parent].</span>")
			else
				user.visible_message("[user] usuwa okablowanie z [parent].", "<span class='notice'>Usuwasz okablowanie z [parent].</span>")
		if(5)
			if(diff==FORWARD)
				user.visible_message("[user] montuje [I] w [parent].", "<span class='notice'>Montujesz [I] w [parent].</span>")
			else
				user.visible_message("[user] odłącza okablowanie [parent].", "<span class='notice'>Odłączasz okablowanie [parent].</span>")
		if(6)
			if(diff==FORWARD)
				user.visible_message("[user] zabezpiecza płytę główną.", "<span class='notice'>Zabezpieczasz płytę główną.</span>")
			else
				user.visible_message("[user] wyjmuje centralny moduł sterowania z [parent].", "<span class='notice'>Wyjmujesz płytę główną centralnego komputera z [parent].</span>")
		if(7)
			if(diff==FORWARD)
				user.visible_message("[user] montuje [I] w [parent].", "<span class='notice'>Montujesz [I] w [parent].</span>")
			else
				user.visible_message("[user] odkręca płytę główną.", "<span class='notice'>Odkręcasz płytę główną.</span>")
		if(8)
			if(diff==FORWARD)
				user.visible_message("[user] zabezpiecza moduł sterowania peryferiami.", "<span class='notice'>Zabezpieczasz moduł sterowania peryferiami.</span>")
			else
				user.visible_message("[user] wyjmuje moduł sterowania peryferiami z [parent].", "<span class='notice'>Wyjmujesz moduł sterowania peryferiami z [parent].</span>")
		if(9)
			if(diff==FORWARD)
				user.visible_message("[user] montuje [I] w [parent].", "<span class='notice'>Montujesz [I] w [parent].</span>")
			else
				user.visible_message("[user] odkręca moduł sterowania peryferiami.", "<span class='notice'>Odkręcasz moduł sterowania peryferiami.</span>")
		if(10)
			if(diff==FORWARD)
				user.visible_message("[user] zabezpiecza moduł skanera.", "<span class='notice'>Zabezpieczasz moduł skanera.</span>")
			else
				user.visible_message("[user] wyjmuje moduł skanera z [parent].", "<span class='notice'>Wyjmujesz moduł skanera z [parent].</span>")
		if(11)
			if(diff==FORWARD)
				user.visible_message("[user] montuje [I] w [parent].", "<span class='notice'>Montujesz [I] w [parent].</span>")
			else
				user.visible_message("[user] odkręca moduł skanera.", "<span class='notice'>Odkręcasz moduł skanera.</span>")
		if(12)
			if(diff==FORWARD)
				user.visible_message("[user] secures [I].", "<span class='notice'>Zabezpieczasz [I].</span>")
			else
				user.visible_message("[user] wyjmuje kondensator z [parent].", "<span class='notice'>Wyjmujesz kondensator z [parent].</span>")
		if(13)
			if(diff==FORWARD)
				user.visible_message("[user] installs [I].", "<span class='notice'>Montujesz [I].</span>")
			else
				user.visible_message("[user] odbezpiecza kondensator w [parent].", "<span class='notice'>Odbezpieczasz kondensator w [parent].</span>")
		if(14)
			if(diff==FORWARD)
				user.visible_message("[user] zabezpiecza ogniwo zasilania.", "<span class='notice'>Zabezpieczasz ogniwo zasilania.</span>")
			else
				user.visible_message("[user] wyważa ogniwo zasilania z [parent].", "<span class='notice'>Wyważasz ogniwo zasilania z [parent].</span>")
		if(15)
			if(diff==FORWARD)
				user.visible_message("[user] montuje wewnętrzną warstwę pancerza w [parent].", "<span class='notice'>Montujesz wewnętrzną warstwę pancerza w [parent].</span>")
			else
				user.visible_message("[user] odkręca ogniwo zasilania.", "<span class='notice'>Odkręcasz ogniwo zasilania.</span>")
		if(16)
			if(diff==FORWARD)
				user.visible_message("[user] zabezpiecza wewnętrzną warstwę pancerza.", "<span class='notice'>Zabezpieczasz wewnętrzną warstwę pancerza.</span>")
			else
				user.visible_message("[user] wyważa wewnętrzną warstwę pancerza z [parent].", "<span class='notice'>Wyważasz wewnętrzną warstwę pancerza z [parent].</span>")
		if(17)
			if(diff==FORWARD)
				user.visible_message("[user] przyspawuje wewnętrzną warstwę pancerza do [parent].", "<span class='notice'>Przyspawujesz wewnętrzną warstwę pancerza do [parent].</span>")
			else
				user.visible_message("[user] odkręca wewnętrzną warstwę pancerza.", "<span class='notice'>Odkręcasz wewnętrzną warstwę pancerza.</span>")
		if(18)
			if(diff==FORWARD)
				user.visible_message("[user] montuje zewnętrzną wzmocnioną warstwę pancerza w [parent].", "<span class='notice'>Montujesz zewnętrzną wzmocnioną warstwę pancerza w [parent].</span>")
			else
				user.visible_message("[user] odcina wewnętrzną warstwę pancerza od [parent].", "<span class='notice'>Odcinasz wewnętrzną warstwę pancerza od [parent].</span>")
		if(19)
			if(diff==FORWARD)
				user.visible_message("[user] zabezpiecza zewnętrzną warstwę pancerza.", "<span class='notice'>Zabezpieczasz zewnętrzną wzmocnioną warstwę pancerza.</span>")
			else
				user.visible_message("[user] wyważa zewnętrzną warstwę pancerza z [parent].", "<span class='notice'>Wyważasz zewnętrzną warstwę pancerza z [parent].</span>")
		if(20)
			if(diff==FORWARD)
				user.visible_message("[user] przyspawuje zewnętrzną warstwę pancerza do [parent].", "<span class='notice'>Przyspawujesz zewnętrzną warstwę pancerza do [parent].</span>")
			else
				user.visible_message("[user] odkręca zewnętrzną warstwę pancerza.", "<span class='notice'>Odkręcasz zewnętrzną warstwę pancerza.</span>")
	return TRUE

/datum/component/construction/unordered/mecha_chassis/gygax
	result = /datum/component/construction/mecha/gygax
	steps = list(
		/obj/item/mecha_parts/part/gygax_torso,
		/obj/item/mecha_parts/part/gygax_left_arm,
		/obj/item/mecha_parts/part/gygax_right_arm,
		/obj/item/mecha_parts/part/gygax_left_leg,
		/obj/item/mecha_parts/part/gygax_right_leg,
		/obj/item/mecha_parts/part/gygax_head
	)

/datum/component/construction/mecha/gygax
	result = /obj/mecha/combat/gygax
	base_icon = "gygax"

	circuit_control = /obj/item/circuitboard/mecha/gygax/main
	circuit_periph = /obj/item/circuitboard/mecha/gygax/peripherals
	circuit_weapon = /obj/item/circuitboard/mecha/gygax/targeting

	inner_plating = /obj/item/stack/sheet/iron
	inner_plating_amount = 5

	outer_plating=/obj/item/mecha_parts/part/gygax_armor
	outer_plating_amount=1

/datum/component/construction/mecha/gygax/action(datum/source, atom/used_atom, mob/user)
	return INVOKE_ASYNC(src, PROC_REF(check_step), used_atom,user)

/datum/component/construction/mecha/gygax/custom_action(obj/item/I, mob/living/user, diff)
	if(!..())
		return FALSE

	switch(index)
		if(1)
			user.visible_message("[user] podłącza układ hydrauliczny [parent]", "<span class='notice'>Podłączasz układ hydrauliczny [parent].</span>")
		if(2)
			if(diff==FORWARD)
				user.visible_message("[user] uruchamia układ hydrauliczny [parent].", "<span class='notice'>Uruchamiasz układ hydrauliczny [parent].</span>")
			else
				user.visible_message("[user] odłącza układ hydrauliczny [parent]", "<span class='notice'>Odłączasz układ hydrauliczny [parent].</span>")
		if(3)
			if(diff==FORWARD)
				user.visible_message("[user] dodaje okablowanie do [parent].", "<span class='notice'>Dodajesz okablowanie do [parent].</span>")
			else
				user.visible_message("[user] wyłącza układ hydrauliczny [parent].", "<span class='notice'>Wyłączasz układ hydrauliczny [parent].</span>")
		if(4)
			if(diff==FORWARD)
				user.visible_message("[user] poprawia okablowanie [parent].", "<span class='notice'>Poprawiasz okablowanie [parent].</span>")
			else
				user.visible_message("[user] usuwa okablowanie z [parent].", "<span class='notice'>Usuwasz okablowanie z [parent].</span>")
		if(5)
			if(diff==FORWARD)
				user.visible_message("[user] montuje [I] w [parent].", "<span class='notice'>Montujesz [I] w [parent].</span>")
			else
				user.visible_message("[user] odłącza okablowanie [parent].", "<span class='notice'>Odłączasz okablowanie [parent].</span>")
		if(6)
			if(diff==FORWARD)
				user.visible_message("[user] zabezpiecza płytę główną.", "<span class='notice'>Zabezpieczasz płytę główną.</span>")
			else
				user.visible_message("[user] wyjmuje centralny moduł sterowania z [parent].", "<span class='notice'>Wyjmujesz płytę główną centralnego komputera z [parent].</span>")
		if(7)
			if(diff==FORWARD)
				user.visible_message("[user] montuje [I] w [parent].", "<span class='notice'>Montujesz [I] w [parent].</span>")
			else
				user.visible_message("[user] odkręca płytę główną.", "<span class='notice'>Odkręcasz płytę główną.</span>")
		if(8)
			if(diff==FORWARD)
				user.visible_message("[user] zabezpiecza moduł sterowania peryferiami.", "<span class='notice'>Zabezpieczasz moduł sterowania peryferiami.</span>")
			else
				user.visible_message("[user] wyjmuje moduł sterowania peryferiami z [parent].", "<span class='notice'>Wyjmujesz moduł sterowania peryferiami z [parent].</span>")
		if(9)
			if(diff==FORWARD)
				user.visible_message("[user] montuje [I] w [parent].", "<span class='notice'>Montujesz [I] w [parent].</span>")
			else
				user.visible_message("[user] odkręca moduł sterowania peryferiami.", "<span class='notice'>Odkręcasz moduł sterowania peryferiami.</span>")
		if(10)
			if(diff==FORWARD)
				user.visible_message("[user] zabezpiecza moduł sterowania uzbrojeniem.", "<span class='notice'>Zabezpieczasz moduł sterowania uzbrojeniem.</span>")
			else
				user.visible_message("[user] wyjmuje moduł sterowania uzbrojeniem z [parent].", "<span class='notice'>Wyjmujesz moduł sterowania uzbrojeniem z [parent].</span>")
		if(11)
			if(diff==FORWARD)
				user.visible_message("[user] montuje [I] w [parent].", "<span class='notice'>Montujesz [I] w [parent].</span>")
			else
				user.visible_message("[user] odkręca moduł sterowania uzbrojeniem.", "<span class='notice'>Odkręcasz moduł sterowania uzbrojeniem.</span>")
		if(12)
			if(diff==FORWARD)
				user.visible_message("[user] zabezpiecza moduł skanera.", "<span class='notice'>Zabezpieczasz moduł skanera.</span>")
			else
				user.visible_message("[user] wyjmuje moduł skanera z [parent].", "<span class='notice'>Wyjmujesz moduł skanera z [parent].</span>")
		if(13)
			if(diff==FORWARD)
				user.visible_message("[user] montuje [I] w [parent].", "<span class='notice'>Montujesz [I] w [parent].</span>")
			else
				user.visible_message("[user] odkręca moduł skanera.", "<span class='notice'>Odkręcasz moduł skanera.</span>")
		if(14)
			if(diff==FORWARD)
				user.visible_message("[user] zabezpiecza kondensator.", "<span class='notice'>Zabezpieczasz kondensator.</span>")
			else
				user.visible_message("[user] wyjmuje kondensator z [parent].", "<span class='notice'>Wyjmujesz kondensator z [parent].</span>")
		if(15)
			if(diff==FORWARD)
				user.visible_message("[user] montuje [I] w [parent].", "<span class='notice'>Montujesz [I] w [parent].</span>")
			else
				user.visible_message("[user] odkręca kondensator.", "<span class='notice'>Odkręcasz kondensator.</span>")
		if(16)
			if(diff==FORWARD)
				user.visible_message("[user] zabezpiecza ogniwo zasilania.", "<span class='notice'>Zabezpieczasz ogniwo zasilania.</span>")
			else
				user.visible_message("[user] wyważa ogniwo zasilania z [parent].", "<span class='notice'>Wyważasz ogniwo zasilania z [parent].</span>")
		if(17)
			if(diff==FORWARD)
				user.visible_message("[user] montuje wewnętrzną warstwę pancerza w [parent].", "<span class='notice'>Montujesz wewnętrzną warstwę pancerza w [parent].</span>")
			else
				user.visible_message("[user] odkręca ogniwo zasilania.", "<span class='notice'>Odkręcasz ogniwo zasilania.</span>")
		if(18)
			if(diff==FORWARD)
				user.visible_message("[user] zabezpiecza wewnętrzną warstwę pancerza.", "<span class='notice'>Zabezpieczasz wewnętrzną warstwę pancerza.</span>")
			else
				user.visible_message("[user] wyważa wewnętrzną warstwę pancerza z [parent].", "<span class='notice'>Wyważasz wewnętrzną warstwę pancerza z [parent].</span>")
		if(19)
			if(diff==FORWARD)
				user.visible_message("[user] przyspawuje wewnętrzną warstwę pancerza do [parent].", "<span class='notice'>Przyspawujesz wewnętrzną warstwę pancerza do [parent].</span>")
			else
				user.visible_message("[user] odkręca wewnętrzną warstwę pancerza.", "<span class='notice'>Odkręcasz wewnętrzną warstwę pancerza.</span>")
		if(20)
			if(diff==FORWARD)
				user.visible_message("[user] montuje [I] w [parent].", "<span class='notice'>Montujesz [I] w [parent].</span>")
			else
				user.visible_message("[user] odcina wewnętrzną warstwę pancerza od [parent].", "<span class='notice'>Odcinasz wewnętrzną warstwę pancerza od [parent].</span>")
		if(21)
			if(diff==FORWARD)
				user.visible_message("[user] zabezpiecza płyty pancerza Gygaxa.", "<span class='notice'>Zabezpieczasz płyty pancerza Gygaxa.</span>")
			else
				user.visible_message("[user] wyważa płyty pancerza Gygaxa z [parent].", "<span class='notice'>Wyważasz płyty pancerza Gygaxa z [parent].</span>")
		if(22)
			if(diff==FORWARD)
				user.visible_message("[user] przyspawuje płyty pancerza Gygaxa do [parent].", "<span class='notice'>Przyspawujesz płyty pancerza Gygaxa do [parent].</span>")
			else
				user.visible_message("[user] odkręca płyty pancerza Gygaxa.", "<span class='notice'>Odkręcasz płyty pancerza Gygaxa.</span>")
	return TRUE

/datum/component/construction/unordered/mecha_chassis/firefighter
	result = /datum/component/construction/mecha/firefighter
	steps = list(
		/obj/item/mecha_parts/part/ripley_torso,
		/obj/item/mecha_parts/part/ripley_left_arm,
		/obj/item/mecha_parts/part/ripley_right_arm,
		/obj/item/mecha_parts/part/ripley_left_leg,
		/obj/item/mecha_parts/part/ripley_right_leg,
		/obj/item/clothing/suit/fire
	)

/datum/component/construction/mecha/firefighter
	result = /obj/mecha/working/ripley/firefighter
	base_icon = "fireripley"

	circuit_control = /obj/item/circuitboard/mecha/ripley/main
	circuit_periph = /obj/item/circuitboard/mecha/ripley/peripherals

	inner_plating = /obj/item/stack/sheet/plasteel
	inner_plating_amount = 5

/datum/component/construction/mecha/firefighter/get_outer_plating_steps()
	return list(
		list(
			"key" = /obj/item/stack/sheet/plasteel,
			"amount" = 5,
			"back_key" = TOOL_WELDER,
			"desc" = "Internal armor is welded."
		),
		list(
			"key" = /obj/item/stack/sheet/plasteel,
			"amount" = 5,
			"back_key" = TOOL_CROWBAR,
			"desc" = "External armor is being installed."
		),
		list(
			"key" = TOOL_WRENCH,
			"back_key" = TOOL_CROWBAR,
			"desc" = "External armor is installed."
		),
		list(
			"key" = TOOL_WELDER,
			"back_key" = TOOL_WRENCH,
			"desc" = "External armor is wrenched."
		),
	)

/datum/component/construction/mecha/firefighter/custom_action(obj/item/I, mob/living/user, diff)
	if(!..())
		return FALSE

	//TODO: better messages.
	switch(index)
		if(1)
			user.visible_message("[user] podłącza układ hydrauliczny [parent]", "<span class='notice'>Podłączasz układ hydrauliczny [parent].</span>")
		if(2)
			if(diff==FORWARD)
				user.visible_message("[user] uruchamia układ hydrauliczny [parent].", "<span class='notice'>Uruchamiasz układ hydrauliczny [parent].</span>")
			else
				user.visible_message("[user] odłącza układ hydrauliczny [parent]", "<span class='notice'>Odłączasz układ hydrauliczny [parent].</span>")
		if(3)
			if(diff==FORWARD)
				user.visible_message("[user] dodaje okablowanie do [parent].", "<span class='notice'>Dodajesz okablowanie do [parent].</span>")
			else
				user.visible_message("[user] wyłącza układ hydrauliczny [parent].", "<span class='notice'>Wyłączasz układ hydrauliczny [parent].</span>")
		if(4)
			if(diff==FORWARD)
				user.visible_message("[user] poprawia okablowanie [parent].", "<span class='notice'>Poprawiasz okablowanie [parent].</span>")
			else
				user.visible_message("[user] usuwa okablowanie z [parent].", "<span class='notice'>Usuwasz okablowanie z [parent].</span>")
		if(5)
			if(diff==FORWARD)
				user.visible_message("[user] montuje [I] w [parent].", "<span class='notice'>Montujesz [I] w [parent].</span>")
			else
				user.visible_message("[user] odłącza okablowanie [parent].", "<span class='notice'>Odłączasz okablowanie [parent].</span>")
		if(6)
			if(diff==FORWARD)
				user.visible_message("[user] zabezpiecza płytę główną.", "<span class='notice'>Zabezpieczasz płytę główną.</span>")
			else
				user.visible_message("[user] wyjmuje centralny moduł sterowania z [parent].", "<span class='notice'>Wyjmujesz płytę główną centralnego komputera z [parent].</span>")
		if(7)
			if(diff==FORWARD)
				user.visible_message("[user] montuje [I] w [parent].", "<span class='notice'>Montujesz [I] w [parent].</span>")
			else
				user.visible_message("[user] odkręca płytę główną.", "<span class='notice'>Odkręcasz płytę główną.</span>")
		if(8)
			if(diff==FORWARD)
				user.visible_message("[user] zabezpiecza moduł sterowania peryferiami.", "<span class='notice'>Zabezpieczasz moduł sterowania peryferiami.</span>")
			else
				user.visible_message("[user] wyjmuje moduł sterowania peryferiami z [parent].", "<span class='notice'>Wyjmujesz moduł sterowania peryferiami z [parent].</span>")
		if(9)
			if(diff==FORWARD)
				user.visible_message("[user] montuje [I] w [parent].", "<span class='notice'>Montujesz [I] w [parent].</span>")
			else
				user.visible_message("[user] odkręca moduł sterowania peryferiami.", "<span class='notice'>Odkręcasz moduł sterowania peryferiami.</span>")
		if(10)
			if(diff==FORWARD)
				user.visible_message("[user] zabezpiecza moduł skanera.", "<span class='notice'>Zabezpieczasz moduł skanera.</span>")
			else
				user.visible_message("[user] wyjmuje moduł skanera z [parent].", "<span class='notice'>Wyjmujesz moduł skanera z [parent].</span>")
		if(11)
			if(diff==FORWARD)
				user.visible_message("[user] montuje [I] w [parent].", "<span class='notice'>Montujesz [I] w [parent].</span>")
			else
				user.visible_message("[user] odkręca moduł skanera.", "<span class='notice'>Odkręcasz moduł skanera.</span>")
		if(12)
			if(diff==FORWARD)
				user.visible_message("[user] zabezpiecza kondensator.", "<span class='notice'>Zabezpieczasz kondensator.</span>")
			else
				user.visible_message("[user] wyjmuje kondensator z [parent].", "<span class='notice'>Wyjmujesz kondensator z [parent].</span>")
		if(13)
			if(diff==FORWARD)
				user.visible_message("[user] montuje [I] w [parent].", "<span class='notice'>Montujesz [I] w [parent].</span>")
			else
				user.visible_message("[user] odkręca kondensator.", "<span class='notice'>Odkręcasz kondensator.</span>")
		if(14)
			if(diff==FORWARD)
				user.visible_message("[user] zabezpiecza ogniwo zasilania.", "<span class='notice'>Zabezpieczasz ogniwo zasilania.</span>")
			else
				user.visible_message("[user] wyważa ogniwo zasilania z [parent].", "<span class='notice'>Wyważasz ogniwo zasilania z [parent].</span>")
		if(15)
			if(diff==FORWARD)
				user.visible_message("[user] montuje wewnętrzną warstwę pancerza w [parent].", "<span class='notice'>Montujesz wewnętrzną warstwę pancerza w [parent].</span>")
			else
				user.visible_message("[user] odkręca ogniwo zasilania.", "<span class='notice'>Odkręcasz ogniwo zasilania.</span>")
		if(16)
			if(diff==FORWARD)
				user.visible_message("[user] zabezpiecza wewnętrzną warstwę pancerza.", "<span class='notice'>Zabezpieczasz wewnętrzną warstwę pancerza.</span>")
			else
				user.visible_message("[user] wyważa wewnętrzną warstwę pancerza z [parent].", "<span class='notice'>Wyważasz wewnętrzną warstwę pancerza z [parent].</span>")
		if(17)
			if(diff==FORWARD)
				user.visible_message("[user] przyspawuje wewnętrzną warstwę pancerza do [parent].", "<span class='notice'>Przyspawujesz wewnętrzną warstwę pancerza do [parent].</span>")
			else
				user.visible_message("[user] odkręca wewnętrzną warstwę pancerza.", "<span class='notice'>Odkręcasz wewnętrzną warstwę pancerza.</span>")
		if(18)
			if(diff==FORWARD)
				user.visible_message("[user] zaczyna montować zewnętrzną warstwę pancerza w [parent].", "<span class='notice'>Montujesz zewnętrzną warstwę pancerza w [parent].</span>")
			else
				user.visible_message("[user] odcina wewnętrzną warstwę pancerza od [parent].", "<span class='notice'>Odcinasz wewnętrzną warstwę pancerza od [parent].</span>")
		if(19)
			if(diff==FORWARD)
				user.visible_message("[user] montuje zewnętrzną wzmocnioną warstwę pancerza w [parent].", "<span class='notice'>Montujesz zewnętrzną wzmocnioną warstwę pancerza w [parent].</span>")
			else
				user.visible_message("[user] zdejmuje zewnętrzny pancerz z [parent].", "<span class='notice'>Zdejmujesz zewnętrzny pancerz z [parent].</span>")
		if(20)
			if(diff==FORWARD)
				user.visible_message("[user] zabezpiecza zewnętrzną warstwę pancerza.", "<span class='notice'>Zabezpieczasz zewnętrzną wzmocnioną warstwę pancerza.</span>")
			else
				user.visible_message("[user] wyważa zewnętrzną warstwę pancerza z [parent].", "<span class='notice'>Wyważasz zewnętrzną warstwę pancerza z [parent].</span>")
		if(21)
			if(diff==FORWARD)
				user.visible_message("[user] przyspawuje zewnętrzną warstwę pancerza do [parent].", "<span class='notice'>Przyspawujesz zewnętrzną warstwę pancerza do [parent].</span>")
			else
				user.visible_message("[user] odkręca zewnętrzną warstwę pancerza.", "<span class='notice'>Odkręcasz zewnętrzną warstwę pancerza.</span>")
	return TRUE

/datum/component/construction/unordered/mecha_chassis/honker
	result = /datum/component/construction/mecha/honker
	steps = list(
		/obj/item/mecha_parts/part/honker_torso,
		/obj/item/mecha_parts/part/honker_left_arm,
		/obj/item/mecha_parts/part/honker_right_arm,
		/obj/item/mecha_parts/part/honker_left_leg,
		/obj/item/mecha_parts/part/honker_right_leg,
		/obj/item/mecha_parts/part/honker_head
	)

/datum/component/construction/mecha/honker
	result = /obj/mecha/combat/honker
	steps = list(
		list(
			"key" = /obj/item/bikehorn
		),
		list(
			"key" = /obj/item/circuitboard/mecha/honker/main,
			"action" = ITEM_DELETE
		),
		list(
			"key" = /obj/item/bikehorn
		),
		list(
			"key" = /obj/item/circuitboard/mecha/honker/peripherals,
			"action" = ITEM_DELETE
		),
		list(
			"key" = /obj/item/bikehorn
		),
		list(
			"key" = /obj/item/circuitboard/mecha/honker/targeting,
			"action" = ITEM_DELETE
		),
		list(
			"key" = /obj/item/bikehorn
		),
		list(
			"key" = /obj/item/stock_parts/scanning_module,
			"action" = ITEM_MOVE_INSIDE
		),
		list(
			"key" = /obj/item/bikehorn
		),
		list(
			"key" = /obj/item/stock_parts/capacitor,
			"action" = ITEM_MOVE_INSIDE
		),
		list(
			"key" = /obj/item/bikehorn
		),
		list(
			"key" = /obj/item/stock_parts/cell,
			"action" = ITEM_MOVE_INSIDE
		),
		list(
			"key" = /obj/item/bikehorn
		),
		list(
			"key" = /obj/item/clothing/mask/gas/clown_hat,
			"action" = ITEM_DELETE
		),
		list(
			"key" = /obj/item/bikehorn
		),
		list(
			"key" = /obj/item/clothing/shoes/clown_shoes,
			"action" = ITEM_DELETE
		),
		list(
			"key" = /obj/item/bikehorn
		),
	)

/datum/component/construction/mecha/honker/get_steps()
	return steps

// HONK doesn't have any construction step icons, so we just set an icon once.
/datum/component/construction/mecha/honker/update_parent(step_index)
	if(step_index == 1)
		var/atom/parent_atom = parent
		parent_atom.icon = 'icons/mecha/mech_construct.dmi'
		parent_atom.icon_state = "honker_chassis"
	..()

/datum/component/construction/mecha/honker/custom_action(obj/item/I, mob/living/user, diff)
	if(!..())
		return FALSE

	if(istype(I, /obj/item/bikehorn))
		playsound(parent, 'sound/items/bikehorn.ogg', 50, 1)
		user.visible_message("HONK!")

	//TODO: better messages.
	switch(index)
		if(2)
			user.visible_message("[user] montuje [I] w [parent].", "<span class='notice'>Montujesz [I] w [parent].</span>")
		if(4)
			user.visible_message("[user] montuje [I] w [parent].", "<span class='notice'>Montujesz [I] w [parent].</span>")
		if(6)
			user.visible_message("[user] montuje [I] w [parent].", "<span class='notice'>Montujesz [I] w [parent].</span>")
		if(8)
			user.visible_message("[user] montuje [I] w [parent].", "<span class='notice'>Montujesz [I] w [parent].</span>")
		if(10)
			user.visible_message("[user] montuje [I] w [parent].", "<span class='notice'>Montujesz [I] w [parent].</span>")
		if(12)
			user.visible_message("[user] montuje [I] w [parent].", "<span class='notice'>Montujesz [I] w [parent].</span>")
		if(14)
			user.visible_message("[user] kładzie [I] na [parent].", "<span class='notice'>Kładziesz [I] na [parent].</span>")
		if(16)
			user.visible_message("[user] kładzie [I] na [parent].", "<span class='notice'>Kładziesz [I] na [parent].</span>")
	return TRUE

/datum/component/construction/unordered/mecha_chassis/durand
	result = /datum/component/construction/mecha/durand
	steps = list(
		/obj/item/mecha_parts/part/durand_torso,
		/obj/item/mecha_parts/part/durand_left_arm,
		/obj/item/mecha_parts/part/durand_right_arm,
		/obj/item/mecha_parts/part/durand_left_leg,
		/obj/item/mecha_parts/part/durand_right_leg,
		/obj/item/mecha_parts/part/durand_head
	)

/datum/component/construction/mecha/durand
	result = /obj/mecha/combat/durand
	base_icon = "durand"

	circuit_control = /obj/item/circuitboard/mecha/durand/main
	circuit_periph = /obj/item/circuitboard/mecha/durand/peripherals
	circuit_weapon = /obj/item/circuitboard/mecha/durand/targeting

	inner_plating = /obj/item/stack/sheet/iron
	inner_plating_amount = 5

	outer_plating = /obj/item/mecha_parts/part/durand_armor
	outer_plating_amount = 1

/datum/component/construction/mecha/durand/custom_action(obj/item/I, mob/living/user, diff)
	if(!..())
		return FALSE

	//TODO: better messages.
	switch(index)
		if(1)
			user.visible_message("[user] podłącza układ hydrauliczny [parent]", "<span class='notice'>Podłączasz układ hydrauliczny [parent].</span>")
		if(2)
			if(diff==FORWARD)
				user.visible_message("[user] uruchamia układ hydrauliczny [parent].", "<span class='notice'>Uruchamiasz układ hydrauliczny [parent].</span>")
			else
				user.visible_message("[user] odłącza układ hydrauliczny [parent]", "<span class='notice'>Odłączasz układ hydrauliczny [parent].</span>")
		if(3)
			if(diff==FORWARD)
				user.visible_message("[user] dodaje okablowanie do [parent].", "<span class='notice'>Dodajesz okablowanie do [parent].</span>")
			else
				user.visible_message("[user] wyłącza układ hydrauliczny [parent].", "<span class='notice'>Wyłączasz układ hydrauliczny [parent].</span>")
		if(4)
			if(diff==FORWARD)
				user.visible_message("[user] poprawia okablowanie [parent].", "<span class='notice'>Poprawiasz okablowanie [parent].</span>")
			else
				user.visible_message("[user] usuwa okablowanie z [parent].", "<span class='notice'>Usuwasz okablowanie z [parent].</span>")
		if(5)
			if(diff==FORWARD)
				user.visible_message("[user] montuje [I] w [parent].", "<span class='notice'>Montujesz [I] w [parent].</span>")
			else
				user.visible_message("[user] odłącza okablowanie [parent].", "<span class='notice'>Odłączasz okablowanie [parent].</span>")
		if(6)
			if(diff==FORWARD)
				user.visible_message("[user] zabezpiecza płytę główną.", "<span class='notice'>Zabezpieczasz płytę główną.</span>")
			else
				user.visible_message("[user] wyjmuje centralny moduł sterowania z [parent].", "<span class='notice'>Wyjmujesz płytę główną centralnego komputera z [parent].</span>")
		if(7)
			if(diff==FORWARD)
				user.visible_message("[user] montuje [I] w [parent].", "<span class='notice'>Montujesz [I] w [parent].</span>")
			else
				user.visible_message("[user] odkręca płytę główną.", "<span class='notice'>Odkręcasz płytę główną.</span>")
		if(8)
			if(diff==FORWARD)
				user.visible_message("[user] zabezpiecza moduł sterowania peryferiami.", "<span class='notice'>Zabezpieczasz moduł sterowania peryferiami.</span>")
			else
				user.visible_message("[user] wyjmuje moduł sterowania peryferiami z [parent].", "<span class='notice'>Wyjmujesz moduł sterowania peryferiami z [parent].</span>")
		if(9)
			if(diff==FORWARD)
				user.visible_message("[user] montuje [I] w [parent].", "<span class='notice'>Montujesz [I] w [parent].</span>")
			else
				user.visible_message("[user] odkręca moduł sterowania peryferiami.", "<span class='notice'>Odkręcasz moduł sterowania peryferiami.</span>")
		if(10)
			if(diff==FORWARD)
				user.visible_message("[user] zabezpiecza moduł sterowania uzbrojeniem.", "<span class='notice'>Zabezpieczasz moduł sterowania uzbrojeniem.</span>")
			else
				user.visible_message("[user] wyjmuje moduł sterowania uzbrojeniem z [parent].", "<span class='notice'>Wyjmujesz moduł sterowania uzbrojeniem z [parent].</span>")
		if(11)
			if(diff==FORWARD)
				user.visible_message("[user] montuje [I] w [parent].", "<span class='notice'>Montujesz [I] w [parent].</span>")
			else
				user.visible_message("[user] odkręca moduł sterowania uzbrojeniem.", "<span class='notice'>Odkręcasz moduł sterowania uzbrojeniem.</span>")
		if(12)
			if(diff==FORWARD)
				user.visible_message("[user] zabezpiecza moduł skanera.", "<span class='notice'>Zabezpieczasz moduł skanera.</span>")
			else
				user.visible_message("[user] wyjmuje moduł skanera z [parent].", "<span class='notice'>Wyjmujesz moduł skanera z [parent].</span>")
		if(13)
			if(diff==FORWARD)
				user.visible_message("[user] montuje [I] w [parent].", "<span class='notice'>Montujesz [I] w [parent].</span>")
			else
				user.visible_message("[user] odkręca moduł skanera.", "<span class='notice'>Odkręcasz moduł skanera.</span>")
		if(14)
			if(diff==FORWARD)
				user.visible_message("[user] zabezpiecza kondensator.", "<span class='notice'>Zabezpieczasz kondensator.</span>")
			else
				user.visible_message("[user] wyjmuje kondensator z [parent].", "<span class='notice'>Wyjmujesz kondensator z [parent].</span>")
		if(15)
			if(diff==FORWARD)
				user.visible_message("[user] montuje [I] w [parent].", "<span class='notice'>Montujesz [I] w [parent].</span>")
			else
				user.visible_message("[user] odkręca kondensator.", "<span class='notice'>Odkręcasz kondensator.</span>")
		if(16)
			if(diff==FORWARD)
				user.visible_message("[user] zabezpiecza ogniwo zasilania.", "<span class='notice'>Zabezpieczasz ogniwo zasilania.</span>")
			else
				user.visible_message("[user] wyważa ogniwo zasilania z [parent].", "<span class='notice'>Wyważasz ogniwo zasilania z [parent].</span>")
		if(17)
			if(diff==FORWARD)
				user.visible_message("[user] montuje wewnętrzną warstwę pancerza w [parent].", "<span class='notice'>Montujesz wewnętrzną warstwę pancerza w [parent].</span>")
			else
				user.visible_message("[user] odkręca ogniwo zasilania.", "<span class='notice'>Odkręcasz ogniwo zasilania.</span>")
		if(18)
			if(diff==FORWARD)
				user.visible_message("[user] zabezpiecza wewnętrzną warstwę pancerza.", "<span class='notice'>Zabezpieczasz wewnętrzną warstwę pancerza.</span>")
			else
				user.visible_message("[user] wyważa wewnętrzną warstwę pancerza z [parent].", "<span class='notice'>Wyważasz wewnętrzną warstwę pancerza z [parent].</span>")
		if(19)
			if(diff==FORWARD)
				user.visible_message("[user] przyspawuje wewnętrzną warstwę pancerza do [parent].", "<span class='notice'>Przyspawujesz wewnętrzną warstwę pancerza do [parent].</span>")
			else
				user.visible_message("[user] odkręca wewnętrzną warstwę pancerza.", "<span class='notice'>Odkręcasz wewnętrzną warstwę pancerza.</span>")
		if(20)
			if(diff==FORWARD)
				user.visible_message("[user] montuje [I] w [parent].", "<span class='notice'>Montujesz [I] w [parent].</span>")
			else
				user.visible_message("[user] odcina wewnętrzną warstwę pancerza od [parent].", "<span class='notice'>Odcinasz wewnętrzną warstwę pancerza od [parent].</span>")
		if(21)
			if(diff==FORWARD)
				user.visible_message("[user] zabezpiecza płyty pancerza Duranda.", "<span class='notice'>Zabezpieczasz płyty pancerza Duranda.</span>")
			else
				user.visible_message("[user] wyważa płyty pancerza Duranda z [parent].", "<span class='notice'>Wyważasz płyty pancerza Duranda z [parent].</span>")
		if(22)
			if(diff==FORWARD)
				user.visible_message("[user] przyspawuje płyty pancerza Duranda do [parent].", "<span class='notice'>Przyspawujesz płyty pancerza Duranda do [parent].</span>")
			else
				user.visible_message("[user] odkręca płyty pancerza Duranda.", "<span class='notice'>Odkręcasz płyty pancerza Duranda.</span>")
	return TRUE

//PHAZON

/datum/component/construction/unordered/mecha_chassis/phazon
	result = /datum/component/construction/mecha/phazon
	steps = list(
		/obj/item/mecha_parts/part/phazon_torso,
		/obj/item/mecha_parts/part/phazon_left_arm,
		/obj/item/mecha_parts/part/phazon_right_arm,
		/obj/item/mecha_parts/part/phazon_left_leg,
		/obj/item/mecha_parts/part/phazon_right_leg,
		/obj/item/mecha_parts/part/phazon_head
	)

/datum/component/construction/mecha/phazon
	result = /obj/mecha/combat/phazon
	base_icon = "phazon"

	circuit_control = /obj/item/circuitboard/mecha/phazon/main
	circuit_periph = /obj/item/circuitboard/mecha/phazon/peripherals
	circuit_weapon = /obj/item/circuitboard/mecha/phazon/targeting

	inner_plating = /obj/item/stack/sheet/plasteel
	inner_plating_amount = 5

	outer_plating = /obj/item/mecha_parts/part/phazon_armor
	outer_plating_amount = 1

/datum/component/construction/mecha/phazon/get_stockpart_steps()
	return list(
		list(
			"key" = /obj/item/stock_parts/scanning_module,
			"action" = ITEM_MOVE_INSIDE,
			"back_key" = TOOL_SCREWDRIVER,
			"desc" = "Weapon control module is secured."
		),
		list(
			"key" = TOOL_SCREWDRIVER,
			"back_key" = TOOL_CROWBAR,
			"desc" = "Scanner module is installed."
		),
		list(
			"key" = /obj/item/stock_parts/capacitor,
			"action" = ITEM_MOVE_INSIDE,
			"back_key" = TOOL_SCREWDRIVER,
			"desc" = "Scanner module is secured."
		),
		list(
			"key" = TOOL_SCREWDRIVER,
			"back_key" = TOOL_CROWBAR,
			"desc" = "Capacitor is installed."
		),
		list(
			"key" = /obj/item/stack/ore/bluespace_crystal,
			"amount" = 1,
			"back_key" = TOOL_SCREWDRIVER,
			"desc" = "Capacitor is secured."
		),
		list(
			"key" = /obj/item/stack/cable_coil,
			"amount" = 5,
			"back_key" = TOOL_CROWBAR,
			"desc" = "The bluespace crystal is installed."
		),
		list(
			"key" = TOOL_SCREWDRIVER,
			"back_key" = TOOL_WIRECUTTER,
			"desc" = "The bluespace crystal is connected."
		),
		list(
			"key" = /obj/item/stock_parts/cell,
			"action" = ITEM_MOVE_INSIDE,
			"back_key" = TOOL_SCREWDRIVER,
			"desc" = "The bluespace crystal is engaged."
		),
		list(
			"key" = TOOL_SCREWDRIVER,
			"back_key" = TOOL_CROWBAR,
			"desc" = "The power cell is installed.",
			"icon_state" = "phazon17"
			// This is the point where a step icon is skipped, so "icon_state" had to be set manually starting from here.
		)
	)

/datum/component/construction/mecha/phazon/get_outer_plating_steps()
	return list(
		list(
			"key" = outer_plating,
			"amount" = 1,
			"action" = ITEM_DELETE,
			"back_key" = TOOL_WELDER,
			"desc" = "Internal armor is welded."
		),
		list(
			"key" = TOOL_WRENCH,
			"back_key" = TOOL_CROWBAR,
			"desc" = "External armor is installed."
		),
		list(
			"key" = TOOL_WELDER,
			"back_key" = TOOL_WRENCH,
			"desc" = "External armor is wrenched."
		),
		list(
			"key" = /obj/item/assembly/signaler/anomaly,
			"action" = ITEM_DELETE,
			"back_key" = TOOL_WELDER,
			"desc" = "Anomaly core socket is open.",
			"icon_state" = "phazon24"
		)
	)

/datum/component/construction/mecha/phazon/custom_action(obj/item/I, mob/living/user, diff)
	if(!..())
		return FALSE

	//TODO: better messages.
	switch(index)
		if(1)
			user.visible_message("[user] podłącza układ hydrauliczny [parent]", "<span class='notice'>Podłączasz układ hydrauliczny [parent].</span>")
		if(2)
			if(diff==FORWARD)
				user.visible_message("[user] uruchamia układ hydrauliczny [parent].", "<span class='notice'>Uruchamiasz układ hydrauliczny [parent].</span>")
			else
				user.visible_message("[user] odłącza układ hydrauliczny [parent]", "<span class='notice'>Odłączasz układ hydrauliczny [parent].</span>")
		if(3)
			if(diff==FORWARD)
				user.visible_message("[user] dodaje okablowanie do [parent].", "<span class='notice'>Dodajesz okablowanie do [parent].</span>")
			else
				user.visible_message("[user] wyłącza układ hydrauliczny [parent].", "<span class='notice'>Wyłączasz układ hydrauliczny [parent].</span>")
		if(4)
			if(diff==FORWARD)
				user.visible_message("[user] poprawia okablowanie [parent].", "<span class='notice'>Poprawiasz okablowanie [parent].</span>")
			else
				user.visible_message("[user] usuwa okablowanie z [parent].", "<span class='notice'>Usuwasz okablowanie z [parent].</span>")
		if(5)
			if(diff==FORWARD)
				user.visible_message("[user] montuje [I] w [parent].", "<span class='notice'>Montujesz [I] w [parent].</span>")
			else
				user.visible_message("[user] odłącza okablowanie [parent].", "<span class='notice'>Odłączasz okablowanie [parent].</span>")
		if(6)
			if(diff==FORWARD)
				user.visible_message("[user] zabezpiecza płytę główną.", "<span class='notice'>Zabezpieczasz płytę główną.</span>")
			else
				user.visible_message("[user] wyjmuje centralny moduł sterowania z [parent].", "<span class='notice'>Wyjmujesz płytę główną centralnego komputera z [parent].</span>")
		if(7)
			if(diff==FORWARD)
				user.visible_message("[user] montuje [I] w [parent].", "<span class='notice'>Montujesz [I] w [parent].</span>")
			else
				user.visible_message("[user] odkręca płytę główną.", "<span class='notice'>Odkręcasz płytę główną.</span>")
		if(8)
			if(diff==FORWARD)
				user.visible_message("[user] zabezpiecza moduł sterowania peryferiami.", "<span class='notice'>Zabezpieczasz moduł sterowania peryferiami.</span>")
			else
				user.visible_message("[user] wyjmuje moduł sterowania peryferiami z [parent].", "<span class='notice'>Wyjmujesz moduł sterowania peryferiami z [parent].</span>")
		if(9)
			if(diff==FORWARD)
				user.visible_message("[user] montuje [I] w [parent].", "<span class='notice'>Montujesz [I] w [parent].</span>")
			else
				user.visible_message("[user] odkręca moduł sterowania peryferiami.", "<span class='notice'>Odkręcasz moduł sterowania peryferiami.</span>")
		if(10)
			if(diff==FORWARD)
				user.visible_message("[user] zabezpiecza moduł sterowania uzbrojeniem.", "<span class='notice'>Zabezpieczasz moduł sterowania uzbrojeniem.</span>")
			else
				user.visible_message("[user] wyjmuje moduł sterowania uzbrojeniem z [parent].", "<span class='notice'>Wyjmujesz moduł sterowania uzbrojeniem z [parent].</span>")
		if(11)
			if(diff==FORWARD)
				user.visible_message("[user] montuje [I] w [parent].", "<span class='notice'>Montujesz [I] w [parent].</span>")
			else
				user.visible_message("[user] odkręca moduł sterowania uzbrojeniem.", "<span class='notice'>Odkręcasz moduł sterowania uzbrojeniem.</span>")
		if(12)
			if(diff==FORWARD)
				user.visible_message("[user] zabezpiecza moduł skanera.", "<span class='notice'>Zabezpieczasz moduł skanera.</span>")
			else
				user.visible_message("[user] wyjmuje moduł skanera z [parent].", "<span class='notice'>Wyjmujesz moduł skanera z [parent].</span>")
		if(13)
			if(diff==FORWARD)
				user.visible_message("[user] montuje [I] w [parent].", "<span class='notice'>Montujesz [I] w [parent].</span>")
			else
				user.visible_message("[user] odkręca moduł skanera.", "<span class='notice'>Odkręcasz moduł skanera.</span>")
		if(14)
			if(diff==FORWARD)
				user.visible_message("[user] zabezpiecza kondensator.", "<span class='notice'>Zabezpieczasz kondensator.</span>")
			else
				user.visible_message("[user] wyjmuje kondensator z [parent].", "<span class='notice'>Wyjmujesz kondensator z [parent].</span>")
		if(15)
			if(diff==FORWARD)
				user.visible_message("[user] installs [I].", "<span class='notice'>Montujesz [I].</span>")
			else
				user.visible_message("[user] odbezpiecza kondensator w [parent].", "<span class='notice'>Odbezpieczasz kondensator w [parent].</span>")
		if(16)
			if(diff==FORWARD)
				user.visible_message("[user] podłącza kryształ bluespace.", "<span class='notice'>Podłączasz kryształ bluespace.</span>")
			else
				user.visible_message("[user] wyjmuje kryształ bluespace z [parent].", "<span class='notice'>Wyjmujesz kryształ bluespace z [parent].</span>")
		if(17)
			if(diff==FORWARD)
				user.visible_message("[user] aktywuje kryształ bluespace.", "<span class='notice'>Aktywujesz kryształ bluespace.</span>")
			else
				user.visible_message("[user] odłącza kryształ bluespace od [parent].", "<span class='notice'>Odłączasz kryształ bluespace od [parent].</span>")
		if(18)
			if(diff==FORWARD)
				user.visible_message("[user] montuje [I] w [parent].", "<span class='notice'>Montujesz [I] w [parent].</span>")
			else
				user.visible_message("[user] dezaktywuje kryształ bluespace.", "<span class='notice'>Dezaktywujesz kryształ bluespace.</span>")
		if(19)
			if(diff==FORWARD)
				user.visible_message("[user] zabezpiecza ogniwo zasilania.", "<span class='notice'>Zabezpieczasz ogniwo zasilania.</span>")
			else
				user.visible_message("[user] wyważa ogniwo zasilania z [parent].", "<span class='notice'>Wyważasz ogniwo zasilania z [parent].</span>")
		if(20)
			if(diff==FORWARD)
				user.visible_message("[user] montuje warstwę pancerza fazowego w [parent].", "<span class='notice'>Montujesz warstwę pancerza fazowego w [parent].</span>")
			else
				user.visible_message("[user] odkręca ogniwo zasilania.", "<span class='notice'>Odkręcasz ogniwo zasilania.</span>")
		if(21)
			if(diff==FORWARD)
				user.visible_message("[user] zabezpiecza warstwę pancerza fazowego.", "<span class='notice'>Zabezpieczasz warstwę pancerza fazowego.</span>")
			else
				user.visible_message("[user] wyważa warstwę pancerza fazowego z [parent].", "<span class='notice'>Wyważasz warstwę pancerza fazowego z [parent].</span>")
		if(22)
			if(diff==FORWARD)
				user.visible_message("[user] przyspawuje warstwę pancerza fazowego do [parent].", "<span class='notice'>Przyspawujesz warstwę pancerza fazowego do [parent].</span>")
			else
				user.visible_message("[user] odkręca warstwę pancerza fazowego.", "<span class='notice'>Odkręcasz warstwę pancerza fazowego.</span>")
		if(23)
			if(diff==FORWARD)
				user.visible_message("[user] montuje [I] w [parent].", "<span class='notice'>Montujesz [I] w [parent].</span>")
			else
				user.visible_message("[user] odcina warstwę pancerza fazowego od [parent].", "<span class='notice'>Odcinasz warstwę pancerza fazowego od [parent].</span>")
		if(24)
			if(diff==FORWARD)
				user.visible_message("[user] zabezpiecza płyty pancerza Phazona.", "<span class='notice'>Zabezpieczasz płyty pancerza Phazona.</span>")
			else
				user.visible_message("[user] wyważa płyty pancerza Phazona z [parent].", "<span class='notice'>Wyważasz płyty pancerza Phazona z [parent].</span>")
		if(25)
			if(diff==FORWARD)
				user.visible_message("[user] przyspawuje płyty pancerza Phazona do [parent].", "<span class='notice'>Przyspawujesz płyty pancerza Phazona do [parent].</span>")
			else
				user.visible_message("[user] odkręca płyty pancerza Phazona.", "<span class='notice'>Odkręcasz płyty pancerza Phazona.</span>")
		if(26)
			if(diff==FORWARD)
				user.visible_message("[user] ostrożnie wkłada rdzeń anomalii do [parent] i go zabezpiecza.",
					"<span class='notice'>Powoli umieszczasz rdzeń anomalii w gnieździe i zamykasz jego komorę.</span>")
	return TRUE

//ODYSSEUS

/datum/component/construction/unordered/mecha_chassis/odysseus
	result = /datum/component/construction/mecha/odysseus
	steps = list(
		/obj/item/mecha_parts/part/odysseus_torso,
		/obj/item/mecha_parts/part/odysseus_head,
		/obj/item/mecha_parts/part/odysseus_left_arm,
		/obj/item/mecha_parts/part/odysseus_right_arm,
		/obj/item/mecha_parts/part/odysseus_left_leg,
		/obj/item/mecha_parts/part/odysseus_right_leg
	)

/datum/component/construction/mecha/odysseus
	result = /obj/mecha/medical/odysseus
	base_icon = "odysseus"

	circuit_control = /obj/item/circuitboard/mecha/odysseus/main
	circuit_periph = /obj/item/circuitboard/mecha/odysseus/peripherals

	inner_plating = /obj/item/stack/sheet/iron
	inner_plating_amount = 5

	outer_plating = /obj/item/stack/sheet/plasteel
	outer_plating_amount = 5

/datum/component/construction/mecha/odysseus/custom_action(obj/item/I, mob/living/user, diff)
	if(!..())
		return FALSE

	//TODO: better messages.
	switch(index)
		if(1)
			user.visible_message("[user] podłącza układ hydrauliczny [parent]", "<span class='notice'>Podłączasz układ hydrauliczny [parent].</span>")
		if(2)
			if(diff==FORWARD)
				user.visible_message("[user] uruchamia układ hydrauliczny [parent].", "<span class='notice'>Uruchamiasz układ hydrauliczny [parent].</span>")
			else
				user.visible_message("[user] odłącza układ hydrauliczny [parent]", "<span class='notice'>Odłączasz układ hydrauliczny [parent].</span>")
		if(3)
			if(diff==FORWARD)
				user.visible_message("[user] dodaje okablowanie do [parent].", "<span class='notice'>Dodajesz okablowanie do [parent].</span>")
			else
				user.visible_message("[user] wyłącza układ hydrauliczny [parent].", "<span class='notice'>Wyłączasz układ hydrauliczny [parent].</span>")
		if(4)
			if(diff==FORWARD)
				user.visible_message("[user] poprawia okablowanie [parent].", "<span class='notice'>Poprawiasz okablowanie [parent].</span>")
			else
				user.visible_message("[user] usuwa okablowanie z [parent].", "<span class='notice'>Usuwasz okablowanie z [parent].</span>")
		if(5)
			if(diff==FORWARD)
				user.visible_message("[user] montuje [I] w [parent].", "<span class='notice'>Montujesz [I] w [parent].</span>")
			else
				user.visible_message("[user] odłącza okablowanie [parent].", "<span class='notice'>Odłączasz okablowanie [parent].</span>")
		if(6)
			if(diff==FORWARD)
				user.visible_message("[user] zabezpiecza płytę główną.", "<span class='notice'>Zabezpieczasz płytę główną.</span>")
			else
				user.visible_message("[user] wyjmuje centralny moduł sterowania z [parent].", "<span class='notice'>Wyjmujesz płytę główną centralnego komputera z [parent].</span>")
		if(7)
			if(diff==FORWARD)
				user.visible_message("[user] montuje [I] w [parent].", "<span class='notice'>Montujesz [I] w [parent].</span>")
			else
				user.visible_message("[user] odkręca płytę główną.", "<span class='notice'>Odkręcasz płytę główną.</span>")
		if(8)
			if(diff==FORWARD)
				user.visible_message("[user] zabezpiecza moduł sterowania peryferiami.", "<span class='notice'>Zabezpieczasz moduł sterowania peryferiami.</span>")
			else
				user.visible_message("[user] wyjmuje moduł sterowania peryferiami z [parent].", "<span class='notice'>Wyjmujesz moduł sterowania peryferiami z [parent].</span>")
		if(9)
			if(diff==FORWARD)
				user.visible_message("[user] montuje [I] w [parent].", "<span class='notice'>Montujesz [I] w [parent].</span>")
			else
				user.visible_message("[user] odkręca moduł sterowania peryferiami.", "<span class='notice'>Odkręcasz moduł sterowania peryferiami.</span>")
		if(10)
			if(diff==FORWARD)
				user.visible_message("[user] zabezpiecza moduł skanera.", "<span class='notice'>Zabezpieczasz moduł skanera.</span>")
			else
				user.visible_message("[user] wyjmuje moduł skanera z [parent].", "<span class='notice'>Wyjmujesz moduł skanera z [parent].</span>")
		if(11)
			if(diff==FORWARD)
				user.visible_message("[user] montuje [I] w [parent].", "<span class='notice'>Montujesz [I] w [parent].</span>")
			else
				user.visible_message("[user] odkręca moduł skanera.", "<span class='notice'>Odkręcasz moduł skanera.</span>")
		if(12)
			if(diff==FORWARD)
				user.visible_message("[user] zabezpiecza kondensator.", "<span class='notice'>Zabezpieczasz kondensator.</span>")
			else
				user.visible_message("[user] wyjmuje kondensator z [parent].", "<span class='notice'>Wyjmujesz kondensator z [parent].</span>")
		if(13)
			if(diff==FORWARD)
				user.visible_message("[user] montuje [I] w [parent].", "<span class='notice'>Montujesz [I] w [parent].</span>")
			else
				user.visible_message("[user] odkręca kondensator.", "<span class='notice'>Odkręcasz kondensator.</span>")
		if(14)
			if(diff==FORWARD)
				user.visible_message("[user] zabezpiecza ogniwo zasilania.", "<span class='notice'>Zabezpieczasz ogniwo zasilania.</span>")
			else
				user.visible_message("[user] wyważa ogniwo zasilania z [parent].", "<span class='notice'>Wyważasz ogniwo zasilania z [parent].</span>")
		if(15)
			if(diff==FORWARD)
				user.visible_message("[user] montuje wewnętrzną warstwę pancerza w [parent].", "<span class='notice'>Montujesz wewnętrzną warstwę pancerza w [parent].</span>")
			else
				user.visible_message("[user] odkręca ogniwo zasilania.", "<span class='notice'>Odkręcasz ogniwo zasilania.</span>")
		if(16)
			if(diff==FORWARD)
				user.visible_message("[user] zabezpiecza wewnętrzną warstwę pancerza.", "<span class='notice'>Zabezpieczasz wewnętrzną warstwę pancerza.</span>")
			else
				user.visible_message("[user] wyważa wewnętrzną warstwę pancerza z [parent].", "<span class='notice'>Wyważasz wewnętrzną warstwę pancerza z [parent].</span>")
		if(17)
			if(diff==FORWARD)
				user.visible_message("[user] przyspawuje wewnętrzną warstwę pancerza do [parent].", "<span class='notice'>Przyspawujesz wewnętrzną warstwę pancerza do [parent].</span>")
			else
				user.visible_message("[user] odkręca wewnętrzną warstwę pancerza.", "<span class='notice'>Odkręcasz wewnętrzną warstwę pancerza.</span>")
		if(18)
			if(diff==FORWARD)
				user.visible_message("[user] montuje zewnętrzną warstwę pancerza w [parent].", "<span class='notice'>Montujesz zewnętrzną wzmocnioną warstwę pancerza w [parent].</span>")
			else
				user.visible_message("[user] odcina wewnętrzną warstwę pancerza od [parent].", "<span class='notice'>Odcinasz wewnętrzną warstwę pancerza od [parent].</span>")
		if(19)
			if(diff==FORWARD)
				user.visible_message("[user] zabezpiecza zewnętrzną warstwę pancerza.", "<span class='notice'>Zabezpieczasz zewnętrzną wzmocnioną warstwę pancerza.</span>")
			else
				user.visible_message("[user] wyważa zewnętrzną warstwę pancerza z [parent].", "<span class='notice'>Wyważasz zewnętrzną warstwę pancerza z [parent].</span>")
		if(20)
			if(diff==FORWARD)
				user.visible_message("[user] przyspawuje zewnętrzną warstwę pancerza do [parent].", "<span class='notice'>Przyspawujesz zewnętrzną warstwę pancerza do [parent].</span>")
			else
				user.visible_message("[user] odkręca zewnętrzną warstwę pancerza.", "<span class='notice'>Odkręcasz zewnętrzną warstwę pancerza.</span>")
	return TRUE
