/obj/machinery/byteforge
	name = "byteforge"
	desc = "Maszyna współpracująca z serwerem kwantowym. Tu zbiega się kod kwantowy i z wirtualnej otchłani materializują się odszyfrowane zasoby."
	circuit = /obj/item/circuitboard/machine/byteforge
	icon = 'aquila/icons/obj/machines/bitrunning.dmi'
	icon_state = "byteforge"
	base_icon_state = "byteforge"
	density = FALSE
	use_power = IDLE_POWER_USE
	idle_power_usage = 50
	/// Idle particles
	var/mutable_appearance/byteforge_particles

/obj/machinery/byteforge/Initialize(mapload)
	. = ..()
	setup_particles()

/obj/machinery/byteforge/examine(mob/user)
	. = ..()
	. += span_notice("Musi stać najwyżej 4 pola od serwera kwantowego.")
	. += span_notice("Panel serwisowy można [panel_open ? "zamknąć" : "otworzyć"] <b>śrubokrętem</b>.")
	if(panel_open)
		. += span_notice("Można go rozebrać <b>łomem</b>.")

/obj/machinery/byteforge/on_set_is_operational(old_value)
	. = ..()
	setup_particles()
	SEND_SIGNAL(src, is_operational ? COMSIG_BYTEFORGE_POWER_RESTORED : COMSIG_BYTEFORGE_POWER_LOST)

/obj/machinery/byteforge/attackby(obj/item/tool, mob/living/user, params)
	if(default_deconstruction_screwdriver(user, "[base_icon_state]_panel", base_icon_state, tool))
		return TRUE
	if(default_deconstruction_crowbar(tool))
		return TRUE
	return ..()

/// Does some sparks after it's done
/obj/machinery/byteforge/proc/flash(atom/movable/thing)
	playsound(src, 'sound/magic/blink.ogg', 50, TRUE)
	do_sparks(5, TRUE, loc)
	set_light(0)

/// Forge begins to process
/obj/machinery/byteforge/proc/flicker(angry = FALSE)
	var/mutable_appearance/lighting = mutable_appearance(initial(icon), "on_overlay[angry ? "_angry" : ""]")
	flick_overlay_view(lighting, src, 1 SECONDS)

	set_light(2, 1.5, angry ? LIGHT_COLOR_RED : LIGHT_COLOR_BLUE)

/// Adds the particle overlays to the byteforge
/obj/machinery/byteforge/proc/setup_particles(angry = FALSE)
	cut_overlay(byteforge_particles)

	byteforge_particles = mutable_appearance(initial(icon), "on_particles[angry ? "_angry" : ""]", ABOVE_MOB_LAYER)

	if(is_operational)
		add_overlay(byteforge_particles)

/// Forge is done processing
/obj/machinery/byteforge/proc/spawn_cache(obj/cache)
	if(QDELETED(cache))
		return

	flash()

	cache.forceMove(loc)

/// Timed flash
/obj/machinery/byteforge/proc/start_to_spawn(obj/cache)
	flicker()

	addtimer(CALLBACK(src, PROC_REF(spawn_cache), cache), 1 SECONDS)


/obj/machinery/computer/quantum_console
	name = "konsola kwantowa"
	desc = "Nawet w dalekiej przyszłości Nanotrasen wciąż używa REST API. Smutne."
	circuit = /obj/item/circuitboard/computer/quantum_console
	icon_keyboard = "mining_key"
	icon_screen = "bitrunning"
	req_access = list(ACCESS_BIT_DEN)
	light_color = LIGHT_COLOR_GREEN
	/// The server this console is connected to.
	var/datum/weakref/server_ref

/obj/machinery/computer/quantum_console/Initialize(mapload, obj/item/circuitboard/C)
	. = ..()
	return INITIALIZE_HINT_LATELOAD

/obj/machinery/computer/quantum_console/LateInitialize()
	. = ..()
	find_server()

/obj/machinery/computer/quantum_console/examine(mob/user)
	. = ..()
	if(!server_ref?.resolve())
		. += span_warning("Postaw serwer kwantowy na którymkolwiek polu obok tej konsoli.")

/obj/machinery/computer/quantum_console/ui_interact(mob/user, datum/tgui/ui)
	if(!is_operational)
		return

	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "QuantumConsole")
		ui.open()

/obj/machinery/computer/quantum_console/ui_data()
	var/list/data = list()

	var/obj/machinery/quantum_server/server = find_server()
	if(isnull(server))
		data["connected"] = FALSE
		return data

	data["connected"] = TRUE
	data["generated_domain"] = server.generated_domain?.key
	data["occupants"] = length(server.avatar_connection_refs)
	data["points"] = server.points
	data["randomized"] = server.domain_randomized
	data["ready"] = server.is_ready && server.is_operational
	data["scanner_tier"] = server.scanner_tier
	data["retries_left"] = length(server.exit_turfs) - server.retries_spent
	data["broadcasting"] = server.broadcasting
	data["broadcasting_on_cd"] = !COOLDOWN_FINISHED(server, broadcast_toggle_cd)

	return data

/obj/machinery/computer/quantum_console/ui_static_data(mob/user)
	var/list/data = list()

	var/obj/machinery/quantum_server/server = find_server()
	if(isnull(server))
		return data

	data["available_domains"] = SSbitrunning.get_available_domains(server.scanner_tier, server.points)
	data["avatars"] = server.get_avatar_data()

	return data

/obj/machinery/computer/quantum_console/ui_act(action, list/params)
	. = ..()
	if(.)
		return TRUE

	if(!allowed(usr))
		to_chat(usr, span_warning("Odmowa dostępu."))
		return TRUE

	var/obj/machinery/quantum_server/server = find_server()
	if(isnull(server))
		return FALSE

	switch(action)
		if("random_domain")
			INVOKE_ASYNC(server, TYPE_PROC_REF(/obj/machinery/quantum_server, cold_boot_map), server.get_random_domain_id(), TRUE)
			return TRUE
		if("refresh")
			update_static_data(usr)
			return TRUE
		if("set_domain")
			INVOKE_ASYNC(server, TYPE_PROC_REF(/obj/machinery/quantum_server, cold_boot_map), params["id"], FALSE)
			return TRUE
		if("stop_domain")
			INVOKE_ASYNC(server, TYPE_PROC_REF(/obj/machinery/quantum_server, begin_shutdown), usr)
			return TRUE
		if("broadcast")
			server.toggle_broadcast()
			return TRUE

	return FALSE

/// Attempts to find a quantum server.
/obj/machinery/computer/quantum_console/proc/find_server()
	var/obj/machinery/quantum_server/server = server_ref?.resolve()
	if(server)
		return server

	for(var/direction in GLOB.cardinals)
		var/obj/machinery/quantum_server/nearby_server = locate(/obj/machinery/quantum_server) in get_step(src, direction)
		if(nearby_server)
			server_ref = WEAKREF(nearby_server)
			return nearby_server


/obj/structure/hololadder
	name = "hololadder"
	desc = "Abstrakcyjne wyobrażenie sposobu na odłączenie się od domeny wirtualnej."
	anchored = TRUE
	icon = 'icons/obj/structures.dmi'
	icon_state = "ladder11"
	/// Time req to disconnect properly
	var/travel_time = 3 SECONDS
	/// Uses this to teleport observers back to the origin server
	var/datum/weakref/server_ref

/obj/structure/hololadder/Initialize(mapload, obj/machinery/quantum_server/origin)
	. = ..()
	RegisterSignal(loc, COMSIG_ATOM_ENTERED, PROC_REF(on_enter))
	server_ref = WEAKREF(origin)

/obj/structure/hololadder/Destroy()
	if(loc)
		UnregisterSignal(loc, COMSIG_ATOM_ENTERED)
	return ..()

/obj/structure/hololadder/examine(mob/user)
	. = ..()

	if(isnull(server_ref?.resolve()))
		. += span_infoplain("Nie jest do niczego podłączona.")
		return

	if(isobserver(user))
		. += span_notice("Kliknij, żeby zobaczyć serwer, do którego prowadzi ta drabina.")
		return

	. += span_infoplain("Jest podłączona do serwera. Kliknij ją albo na nią wejdź, żeby się rozłączyć.")

/obj/structure/hololadder/attack_hand(mob/user)
	. = ..()
	if(.)
		return

	if(!in_range(src, user))
		return

	INVOKE_ASYNC(src, PROC_REF(disconnect), user)
	return TRUE

/obj/structure/hololadder/attack_ghost(mob/dead/observer/ghostie)
	var/atom/our_server = server_ref?.resolve()
	if(isnull(our_server))
		return ..()

	ghostie.abstract_move(get_turf(our_server))
	return TRUE

/// If there's a pilot ref- send the disconnect signal
/obj/structure/hololadder/proc/disconnect(mob/user)
	if(isnull(user.mind))
		return

	var/obj/machinery/quantum_server/our_server = server_ref?.resolve()
	if(our_server && !our_server.domain_complete)
		for(var/datum/weakref/ghostrole_weakref as anything in our_server.spawned_threat_refs)
			var/mob/living/ghostrole = ghostrole_weakref.resolve()
			if(ghostrole?.stat == CONSCIOUS && ghostrole.client && ghostrole.mind?.has_antag_datum(/datum/antagonist/bitrunning_glitch, TRUE))
				to_chat(user, span_danger("Istota w symulacji blokuje twój odwrót. Musisz ukończyć misję albo usunąć przeszkodę, zanim bezpieczne wyjście będzie możliwe."))
				return

	if(!HAS_TRAIT(user, TRAIT_TEMPORARY_BODY))
		balloon_alert(user, "nie wykryto połączenia")
		return

	balloon_alert(user, "rozłączanie...")
	if(do_after(user, travel_time, target = src))
		SEND_SIGNAL(user, COMSIG_BITRUNNER_LADDER_SEVER)

/// Helper for times when you dont have hands (gondola??)
/obj/structure/hololadder/proc/on_enter(datum/source, atom/movable/arrived, atom/old_loc)
	SIGNAL_HANDLER

	if(!isliving(arrived))
		return

	var/mob/living/user = arrived
	if(isnull(user.mind))
		return

	INVOKE_ASYNC(src, PROC_REF(disconnect), user)


/obj/item/bitrunning_host_monitor
	name = "monitor hosta"
	desc = "Skomplikowane urządzenie, które analizuje stan połączenia między hostem a awatarem."
	custom_materials = list(/datum/material/iron = 200)
	icon = 'aquila/icons/obj/bitrunning_items.dmi'
	icon_state = "host_monitor"
	item_state = "electronic"
	item_flags = NOBLUDGEON
	lefthand_file = 'icons/mob/inhands/misc/devices_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/misc/devices_righthand.dmi'
	slot_flags = ITEM_SLOT_BELT
	throw_range = 7
	throw_speed = 3
	throwforce = 3
	w_class = WEIGHT_CLASS_TINY

/obj/item/bitrunning_host_monitor/attack_self(mob/user)
	. = ..()

	var/datum/component/avatar_connection/connection = user.GetComponent(/datum/component/avatar_connection)
	if(isnull(connection))
		balloon_alert(user, "nie rozpoznano danych")
		return

	var/mob/living/pilot = connection.old_body_ref?.resolve()
	if(isnull(pilot))
		balloon_alert(user, "nie rozpoznano hosta")
		return

	to_chat(user, span_notice("Obecny stan zdrowia hosta: [round(pilot.health / pilot.maxHealth * 100)]%"))


/obj/item/bitrunning_debug
	name = "bitrunning debug item"
	desc = "Dodaje punkty i skraca stygnięcie, do debugowania."
	icon = 'icons/obj/module.dmi'
	icon_state = "datadisk0"
