// AQUILA - co gremliny robią z konkretnymi maszynami (port z HippieStation)
// Procs that can sleep (doors opening, gibbers, buttons) are called async, this runs from mob AI

/// What happens when a gremlin (or another NPC) messes with this. Return NPC_TAMPER_ACT_FORGET if there's nothing to do
/obj/proc/npc_tamper_act(mob/living/L)
	return NPC_TAMPER_ACT_FORGET

/// Cut/mend or pulse a random wire
/datum/wires/proc/npc_tamper(mob/living/L)
	if(!length(wires))
		return
	var/wire_to_screw = pick(wires)
	if(is_cut(wire_to_screw) || prob(50)) //A cut wire always gets mended, otherwise 50% to cut it and 50% to pulse it
		INVOKE_ASYNC(src, PROC_REF(cut), wire_to_screw)
	else
		INVOKE_ASYNC(src, PROC_REF(pulse), wire_to_screw, L)

/// Presses the machine like a hand click would, then lets go of it so the NPC does not stay registered as its user
/obj/machinery/proc/npc_attack_hand(mob/living/L)
	attack_hand(L)
	if(QDELETED(L))
		return
	if(L.machine == src)
		L.unset_machine()
	//mob.machine can get cleared without unregistering, so drop the signal ourselves or the next press warns about overriding it
	L.UnregisterSignal(src, COMSIG_PARENT_QDELETING)

// Atmospherics

/obj/machinery/atmospherics/components/binary/passive_gate/npc_tamper_act(mob/living/L)
	if(prob(50)) //Turn on/off
		on = !on
		investigate_log("was turned [on ? "on" : "off"] by [key_name(L)]", INVESTIGATE_ATMOS)
	else //Change pressure
		target_pressure = rand(0, MAX_OUTPUT_PRESSURE)
		investigate_log("was set to [target_pressure] kPa by [key_name(L)]", INVESTIGATE_ATMOS)
	update_icon()

/obj/machinery/atmospherics/components/binary/pump/npc_tamper_act(mob/living/L)
	if(prob(50))
		on = !on
		investigate_log("was turned [on ? "on" : "off"] by [key_name(L)]", INVESTIGATE_ATMOS)
	else
		target_pressure = rand(0, MAX_OUTPUT_PRESSURE)
		investigate_log("was set to [target_pressure] kPa by [key_name(L)]", INVESTIGATE_ATMOS)
	update_icon()

/obj/machinery/atmospherics/components/binary/volume_pump/npc_tamper_act(mob/living/L)
	if(prob(50))
		on = !on
		investigate_log("was turned [on ? "on" : "off"] by [key_name(L)]", INVESTIGATE_ATMOS)
	else
		transfer_rate = rand(0, MAX_TRANSFER_RATE)
		investigate_log("was set to [transfer_rate] L/s by [key_name(L)]", INVESTIGATE_ATMOS)
	update_icon()

/obj/machinery/atmospherics/components/binary/valve/npc_tamper_act(mob/living/L)
	interact(L)

/obj/machinery/space_heater/npc_tamper_act(mob/living/L)
	if(prob(50))
		setMode = pick(list("auto", "heat", "cool") - setMode)
	else
		on = !on
		mode = "standby"
		if(on)
			SSair.start_processing_machine(src)
		else
			SSair.stop_processing_machine(src)
	update_icon()

/obj/machinery/airalarm/npc_tamper_act(mob/living/L)
	if(panel_open)
		wires.npc_tamper(L)
	else
		panel_open = TRUE
		update_icon()

/obj/machinery/atmospherics/components/unary/cryo_cell/npc_tamper_act(mob/living/L)
	if(prob(50))
		if(beaker)
			beaker.forceMove(drop_location())
			beaker = null
	else if(state_open)
		close_machine()
	else if(occupant)
		open_machine()

// Engineering

/obj/machinery/power/apc/npc_tamper_act(mob/living/L)
	if(!panel_open)
		panel_open = TRUE
		update_appearance()
	wires?.npc_tamper(L)

/obj/machinery/power/smes/npc_tamper_act(mob/living/L)
	if(prob(50)) //mess with input
		input_level = rand(0, input_level_max)
	else //mess with output
		output_level = rand(0, output_level_max)
	log_smes(L)
	update_icon()

/obj/machinery/power/rad_collector/npc_tamper_act(mob/living/L)
	interact(L)

/obj/machinery/power/emitter/npc_tamper_act(mob/living/L)
	interact(L)

/obj/machinery/particle_accelerator/control_box/npc_tamper_act(mob/living/L)
	wires?.npc_tamper(L)

// Doors and general machinery

/obj/machinery/door/airlock/npc_tamper_act(mob/living/L)
	//Open the firelocks as well, otherwise they block the way for our gremlin which isn't fun
	for(var/obj/machinery/door/firedoor/F in get_turf(src))
		if(F.density)
			F.npc_tamper_act(L)

	if(prob(40)) //40% - mess with wires
		if(!panel_open)
			panel_open = TRUE
			update_icon()
		wires?.npc_tamper(L)
	else //60% - just open it
		INVOKE_ASYNC(src, PROC_REF(open))

/obj/machinery/door/firedoor/npc_tamper_act(mob/living/L)
	if(!density)
		return NPC_TAMPER_ACT_NOMSG
	INVOKE_ASYNC(src, PROC_REF(open))

/obj/machinery/button/npc_tamper_act(mob/living/L)
	INVOKE_ASYNC(src, PROC_REF(npc_attack_hand), L)

/obj/machinery/light_switch/npc_tamper_act(mob/living/L)
	//interact() relies on usr, which mob AI does not have
	area.lightswitch = !area.lightswitch
	playsound(src, 'aquila/sound/effects/lightswitch.ogg', 100, TRUE)
	area.update_icon()
	for(var/obj/machinery/light_switch/switch_in_area in area)
		switch_in_area.update_icon()
	area.power_change()

/obj/machinery/firealarm/npc_tamper_act(mob/living/L)
	alarm(L)

/obj/machinery/camera/npc_tamper_act(mob/living/L)
	if(wires)
		if(!panel_open)
			panel_open = TRUE
		wires.npc_tamper(L)
	else
		toggle_cam(L, FALSE)

/obj/machinery/turretid/npc_tamper_act(mob/living/L)
	enabled = prob(50)
	lethal = prob(50)
	updateTurrets()

/obj/machinery/vending/npc_tamper_act(mob/living/L)
	if(!panel_open)
		panel_open = TRUE
		update_icon()
	wires?.npc_tamper(L)

/obj/machinery/syndicatebomb/npc_tamper_act(mob/living/L) //suicide bomber gremlins
	if(!open_panel)
		open_panel = TRUE
		update_icon()
	wires?.npc_tamper(L)

// Kitchen, medbay, service

/obj/machinery/gibber/npc_tamper_act(mob/living/L)
	INVOKE_ASYNC(src, PROC_REF(npc_attack_hand), L)

/obj/machinery/deepfryer/npc_tamper_act(mob/living/L)
	//Deepfry a random nearby item
	if(frying || !reagents.has_reagent(/datum/reagent/consumable/cooking_oil))
		return
	var/list/pickable_items = list()
	for(var/obj/item/I in range(1, L))
		if(I.anchored || (I.resistance_flags & INDESTRUCTIBLE) || is_type_in_typecache(I, deepfry_blacklisted_items) || HAS_TRAIT(I, TRAIT_NODROP) || (I.item_flags & (ABSTRACT | DROPDEL)))
			continue
		pickable_items += I
	if(!length(pickable_items))
		return

	var/obj/item/I = pick(pickable_items)
	I.forceMove(src) //shove the item in, even if it isn't food
	frying = new /obj/item/reagent_containers/food/snacks/deepfryholder(src, I)
	icon_state = "fryer_on"
	fry_loop.start()
	log_game("[key_name(L)] deep fried [I.name] ([I.type]) at [AREACOORD(src)].")

/obj/machinery/sleeper/npc_tamper_act(mob/living/L)
	if(prob(75))
		if(occupant && length(available_chems))
			inject_chem(pick(available_chems), L)
	else if(state_open)
		close_machine()
	else
		open_machine()

/obj/machinery/shower/npc_tamper_act(mob/living/L)
	interact(L)

/obj/machinery/computer/slot_machine/npc_tamper_act(mob/living/L)
	spin(L)

/obj/machinery/computer/bank_machine/npc_tamper_act(mob/living/L)
	if(siphoning)
		say("Station credit withdrawal halted.")
		end_syphon()
	else
		say("Siphon of station credits has begun!")
		siphoning = TRUE

/obj/machinery/computer/communications/npc_tamper_act(mob/living/L)
	if(!authenticated)
		if(prob(20)) //20% chance to log in
			authenticated = TRUE
			authorize_access = list()
			authorize_name = "[L.name]"
			playsound(src, 'sound/machines/terminal_on.ogg', 50, FALSE)
		return

	if(prob(50)) //Already logged in, 50% chance to log off
		authenticated = FALSE
		authorize_access = null
		authorize_name = null
		playsound(src, 'sound/machines/terminal_off.ogg', 50, FALSE)
		return

	if(!istype(L, /mob/living/simple_animal/hostile/gremlin)) //otherwise make a hilarious public message out of what the gremlin heard
		return
	var/mob/living/simple_animal/hostile/gremlin/G = L
	var/result = G.generate_markov_chain()
	if(!result)
		return
	if(prob(85))
		SScommunications.make_announcement(G, FALSE, result)
	else if(SSshuttle.emergency?.mode == SHUTTLE_IDLE)
		SSshuttle.requestEvac(G, result)
	else if(SSshuttle.emergency?.mode == SHUTTLE_CALL)
		SSshuttle.cancelEvac(G)

/obj/structure/sink/npc_tamper_act(mob/living/L)
	if(istype(L, /mob/living/simple_animal/hostile/gremlin))
		visible_message("<span class='danger'>[L] wskakuje do [src] i odkręca kran!</span>")
		var/mob/living/simple_animal/hostile/gremlin/G = L
		G.divide()
	return NPC_TAMPER_ACT_NOMSG
