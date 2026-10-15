/**
 * The base object for the quantum server
 */
/obj/machinery/quantum_server
	name = "serwer kwantowy"
	desc = "Masywna maszyna obliczeniowa, która tworzy domeny wirtualne."
	circuit = /obj/item/circuitboard/machine/quantum_server
	density = TRUE
	icon = 'aquila/icons/obj/machines/bitrunning.dmi'
	base_icon_state = "qserver"
	icon_state = "qserver"
	use_power = IDLE_POWER_USE
	idle_power_usage = 500
	active_power_usage = 5000
	/// Affects server cooldown efficiency
	var/capacitor_coefficient = 1
	/// The loaded map template, map_template/virtual_domain
	var/datum/lazy_template/virtual_domain/generated_domain
	/// If the current domain was a random selection
	var/domain_randomized = FALSE
	/// Whether the domain is finished, so the bitrunners can leave despite glitches
	var/domain_complete = FALSE
	/// Prevents multiple user actions. Handled by loading domains and cooldowns
	var/is_ready = TRUE
	/// Chance multipled by threat to spawn a glitch
	var/glitch_chance = 0.2
	/// Current plugged in users
	var/list/datum/weakref/avatar_connection_refs = list()
	/// Cached list of mutable mobs in zone for cybercops
	var/list/datum/weakref/mutation_candidate_refs = list()
	/// Any ghosts that have spawned in
	var/list/datum/weakref/spawned_threat_refs = list()
	/// Scales loot with extra players
	var/multiplayer_bonus = 1.1
	/// Extra bonus for every player that nohits the run
	var/nohit_bonus = 0.8
	/// The amount of points in the system, used to purchase maps
	var/points = 0
	/// Keeps track of the number of times someone has built a hololadder
	var/retries_spent = 0
	/// Changes how much info is available on the domain
	var/scanner_tier = 1
	/// Length of time it takes for the server to cool down after resetting. Here to give runners downtime so their faces don't get stuck like that
	var/server_cooldown_time = 2 MINUTES
	/// Applies bonuses to rewards etc
	var/servo_bonus = 0
	/// Determines the glitches available to spawn, builds with completion
	var/threat = 0
	/// Maximum rate at which a glitch can spawn
	var/threat_prob_max = 15
	/// The turfs we can place a hololadder on.
	var/list/turf/exit_turfs = list()
	/// Determines if we broadcast to entertainment monitors or not
	var/broadcasting = FALSE
	/// Cooldown between being able to toggle broadcasting
	COOLDOWN_DECLARE(broadcast_toggle_cd)
	/// Cooldown for how often you're allowed to harass deadchat for PVP domains
	COOLDOWN_DECLARE(polling_cooldown)

/obj/machinery/quantum_server/Initialize(mapload)
	. = ..()
	RegisterSignal(src, COMSIG_MACHINERY_BROKEN, PROC_REF(on_broken))
	RegisterSignal(src, COMSIG_PARENT_QDELETING, PROC_REF(on_delete))

/obj/machinery/quantum_server/Destroy(force)
	mutation_candidate_refs.Cut()
	avatar_connection_refs.Cut()
	spawned_threat_refs.Cut()
	exit_turfs.Cut()
	QDEL_NULL(generated_domain)
	return ..()

/obj/machinery/quantum_server/on_set_is_operational(old_value)
	. = ..()
	if(!is_operational)
		sever_connections()
	update_appearance()

/obj/machinery/quantum_server/examine(mob/user)
	. = ..()

	. += span_infoplain("Potrafi zużywać dużo prądu. Zadbaj o odpowiednie zasilanie.")

	. += span_notice("Panel serwisowy można [panel_open ? "zamknąć" : "otworzyć"] <b>śrubokrętem</b>.")
	if(panel_open)
		. += span_notice("Można go rozebrać <b>łomem</b>.")

	var/upgraded = FALSE
	if(capacitor_coefficient < 1)
		. += span_infoplain("- Pojemność chłodzenia skraca czas stygnięcia o [(1 - capacitor_coefficient) * 100]%.")
		upgraded = TRUE

	if(servo_bonus > 0.2)
		. += span_infoplain("- Manipulatory zwiększają nagrody o [servo_bonus]x.")
		. += span_infoplain("- Obrażenia przy niebezpiecznym rozłączeniu zmniejszone o [servo_bonus * 100]%.")
		upgraded = TRUE

	if(!upgraded)
		. += span_notice("Wydajność jest słaba. Lepsze części dadzą więcej informacji o domenach, krótsze stygnięcie i większe nagrody.")

	if(!is_ready)
		. += span_notice("Właśnie stygnie. Daj mu chwilę.")

	if(isobserver(user) && (obj_flags & EMAGGED))
		. += span_notice("Migają złowrogie czerwone lampki. Ktoś przy nim majstrował.")


/obj/machinery/quantum_server/emag_act(mob/user, obj/item/card/emag/emag_card)
	if(obj_flags & EMAGGED)
		return

	obj_flags |= EMAGGED
	glitch_chance *= 2
	threat_prob_max *= 2

	add_overlay(mutable_appearance(icon, "emag_overlay"))
	balloon_alert(user, "system złamany...")
	playsound(src, "sparks", 35, TRUE)
	SEND_SIGNAL(src, COMSIG_ATOM_EMAG_ACT, user)
	return TRUE


/obj/machinery/quantum_server/update_appearance(updates)
	if(isnull(generated_domain) || !is_operational)
		set_light(0)
	else
		set_light(2, 1.5, is_ready ? LIGHT_COLOR_BLUE : LIGHT_COLOR_FIRE)
	return ..()

/obj/machinery/quantum_server/update_icon_state()
	if(isnull(generated_domain) || !is_operational)
		icon_state = base_icon_state
		return ..()
	if(panel_open)
		icon_state = "[base_icon_state]_panel"
		return ..()

	icon_state = "[base_icon_state]_[is_ready ? "on" : "off"]"
	return ..()


/obj/machinery/quantum_server/attackby(obj/item/tool, mob/living/user, params)
	if(istype(tool, /obj/item/bitrunning_debug))
		balloon_alert(user, "*głos hakera* jestem w środku")
		obj_flags |= EMAGGED
		glitch_chance = 0.5
		capacitor_coefficient = 0.1
		points = 100
		return TRUE

	if(tool.tool_behaviour == TOOL_CROWBAR)
		if(!is_ready)
			balloon_alert(user, "jest rozgrzany do czerwoności!")
			return TRUE
		if(length(avatar_connection_refs))
			balloon_alert(user, "wszyscy klienci muszą się rozłączyć!")
			return TRUE
		if(default_deconstruction_crowbar(tool))
			return TRUE

	if(tool.tool_behaviour == TOOL_SCREWDRIVER)
		if(!is_ready)
			balloon_alert(user, "jest rozgrzany do czerwoności!")
			return TRUE
		if(default_deconstruction_screwdriver(user, "[base_icon_state]_panel", base_icon_state, tool))
			return TRUE

	return ..()

/obj/machinery/quantum_server/RefreshParts()
	var/capacitor_rating = 1.15
	for(var/obj/item/stock_parts/capacitor/cap in component_parts)
		capacitor_rating -= cap.rating * 0.15
		break

	capacitor_coefficient = max(capacitor_rating, 0.1)

	for(var/obj/item/stock_parts/scanning_module/scanner in component_parts)
		scanner_tier = scanner.rating
		break

	var/servo_rating = 0
	for(var/obj/item/stock_parts/manipulator/servo in component_parts)
		servo_rating += servo.rating * 0.1

	servo_bonus = servo_rating
	SEND_SIGNAL(src, COMSIG_QSERVER_PARTS_REFRESHED)

/// Wysyła komunikat przez system ogłoszeń na kanał zaopatrzenia
/proc/bitrunning_announce(message, channel = RADIO_CHANNEL_SUPPLY)
	for(var/obj/machinery/announcement_system/announcer as anything in GLOB.announcement_systems)
		if(!announcer.is_operational)
			continue
		announcer.radio.talk_into(announcer, message, channel)
		return TRUE
	return FALSE
