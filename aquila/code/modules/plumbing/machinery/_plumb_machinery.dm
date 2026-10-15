/**Basic plumbing object.
* It doesn't really hold anything special, YET.
* Objects that are plumbing but not a subtype are as of writing the reagent_dispenser tank and the water fixtures
* Also please note that the plumbing component is toggled on and off by the component using a signal from set_anchored, so dont worry about it
*/
/obj/machinery/plumbing
	name = "pipe thing"
	icon = 'aquila/icons/obj/plumbing/plumbers.dmi'
	icon_state = "pump"
	density = TRUE
	processing_flags = START_PROCESSING_MANUALLY
	use_power = ACTIVE_POWER_USE
	idle_power_usage = 10
	active_power_usage = 45
	resistance_flags = FIRE_PROOF | UNACIDABLE | ACID_PROOF
	///Plumbing machinery is always gonna need reagents, so we might aswell put it here
	var/buffer = 50
	///Flags for reagents, like INJECTABLE, TRANSPARENT bla bla everything thats in DEFINES/reagents.dm
	var/reagent_flags = TRANSPARENT | NO_REACT

/obj/machinery/plumbing/Initialize(mapload, layer)
	. = ..()
	anchored = !!mapload
	create_reagents(buffer, reagent_flags)
	AddComponent(/datum/component/simple_rotation)
	if(mapload)
		begin_processing()

/obj/machinery/plumbing/examine(mob/user)
	. = ..()
	if(isobserver(user) || !in_range(src, user))
		return

	. += "<span class='notice'>Wyświetlacz pojemności pokazuje: <b>[reagents.maximum_volume] j.</b> Zawiera:</span>"
	if(reagents.total_volume)
		for(var/datum/reagent/reg as anything in reagents.reagent_list)
			. += "<span class='notice'>[round(reg.volume, 0.01)] j. [reg.name]</span>"
	else
		. += "<span class='notice'>Nic.</span>"

	if(anchored)
		. += "<span class='notice'>Jest <b>przykręcony</b> do podłogi.</span>"
	else
		. += "<span class='warning'>Trzeba go <b>przykręcić</b> kluczem, żeby zaczął działać.</span>"
		. += "<span class='notice'>Można go rozciąć <b>spawarką</b>.</span>"

	. += "<span class='notice'>Zawartość można wylać <b>przepychaczką</b>.</span>"

/obj/machinery/plumbing/wrench_act(mob/living/user, obj/item/tool)
	if(user.combat_mode)
		return FALSE

	. = TRUE
	if(default_unfasten_wrench(user, tool) == SUCCESSFUL_UNFASTEN)
		if(anchored)
			begin_processing()
		else
			end_processing()
		update_appearance()

/obj/machinery/plumbing/welder_act(mob/living/user, obj/item/I)
	if(user.combat_mode)
		return FALSE

	. = TRUE
	if(anchored)
		balloon_alert(user, "najpierw odkręć!")
		return

	if(I.tool_start_check(user, amount = 1))
		to_chat(user, "<span class='notice'>Zaczynasz rozcinać [src].</span>")
		if(I.use_tool(src, user, 1.5 SECONDS, volume = 50))
			deconstruct(TRUE)
			to_chat(user, "<span class='notice'>Rozcinasz [src].</span>")

/obj/machinery/plumbing/deconstruct(disassembled = TRUE)
	if(!(flags_1 & NODECONSTRUCT_1))
		new /obj/item/stack/sheet/iron(drop_location(), 1)
	return ..()

/obj/machinery/plumbing/plunger_act(obj/item/plunger/attacking_plunger, mob/living/user, reinforced)
	user.balloon_alert_to_viewers("zajadle przepycha...")
	if(!do_after(user, 3 SECONDS, target = src))
		return TRUE
	user.balloon_alert_to_viewers("przepchane")
	reagents.reaction(get_turf(src), TOUCH) //splash on the floor
	reagents.clear_reagents()
	return TRUE

///We can empty beakers in here and everything
/obj/machinery/plumbing/input
	name = "input gate"
	desc = "Can be manually filled with reagents from containers."
	icon_state = "pipe_input"
	density = FALSE
	reagent_flags = TRANSPARENT | NO_REACT | REFILLABLE

/obj/machinery/plumbing/input/Initialize(mapload, layer)
	. = ..()
	AddComponent(/datum/component/plumbing/simple_supply, layer)

///We can fill beakers in here and everything. we dont inheret from input because it has nothing that we need
/obj/machinery/plumbing/output
	name = "output gate"
	desc = "A manual output for plumbing systems, for taking reagents directly into containers."
	icon_state = "pipe_output"
	density = FALSE
	reagent_flags = TRANSPARENT | DRAINABLE

/obj/machinery/plumbing/output/Initialize(mapload, layer)
	. = ..()
	AddComponent(/datum/component/plumbing/simple_demand, layer, 5)

///For pouring reagents from ducts directly into cups
/obj/machinery/plumbing/output/tap
	name = "drinking tap"
	desc = "A manual output for plumbing systems, for taking drinks directly into glasses."
	icon_state = "tap_output"

///For storing large volume of reagents
/obj/machinery/plumbing/tank
	name = "chemical tank"
	desc = "A massive chemical holding tank."
	icon_state = "tank"
	buffer = 400

/obj/machinery/plumbing/tank/Initialize(mapload, layer)
	. = ..()
	AddComponent(/datum/component/plumbing/tank, layer)

///Layer manifold machine that connects a bunch of layers
/obj/machinery/plumbing/layer_manifold
	name = "layer manifold"
	desc = "A plumbing manifold for layers."
	icon_state = "manifold"
	density = FALSE

/obj/machinery/plumbing/layer_manifold/Initialize(mapload, layer)
	. = ..()

	AddComponent(/datum/component/plumbing/manifold, FIRST_DUCT_LAYER)
	AddComponent(/datum/component/plumbing/manifold, SECOND_DUCT_LAYER)
	AddComponent(/datum/component/plumbing/manifold, THIRD_DUCT_LAYER)
	AddComponent(/datum/component/plumbing/manifold, FOURTH_DUCT_LAYER)
	AddComponent(/datum/component/plumbing/manifold, FIFTH_DUCT_LAYER)
