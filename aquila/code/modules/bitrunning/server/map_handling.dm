#define POLLING_COOLDOWN_TIME 2 MINUTES

/// AQUILA: atomy z ostatniego ładowania domeny (zamiast przeszukiwania GLOB.landmarks_list)
/obj/machinery/quantum_server/var/list/loaded_atoms
/// AQUILA: turfy docelowe obecnej domeny (żeby odpiąć od nich sygnały przed zwolnieniem rezerwacji)
/obj/machinery/quantum_server/var/list/turf/goal_turfs = list()

/// Gives all current occupants a notification that the server is going down
/obj/machinery/quantum_server/proc/begin_shutdown(mob/user)
	if(isnull(generated_domain))
		return

	if(!length(avatar_connection_refs))
		balloon_alert_to_viewers("wyłączanie domeny...")
		playsound(src, 'sound/machines/terminal_off.ogg', 40, TRUE)
		reset()
		return

	balloon_alert_to_viewers("powiadamianie klientów...")
	playsound(src, 'sound/machines/terminal_alert.ogg', 100, TRUE)
	user.visible_message(
		span_danger("[user] zaczyna odcinać zasilanie serwera!"),
		span_notice("Zaczynasz rozłączać klientów..."),
		span_danger("Słyszysz gorączkowe stukanie w klawiaturę."),
	)

	SEND_SIGNAL(src, COMSIG_BITRUNNER_SHUTDOWN_ALERT, user)

	if(!do_after(user, 20 SECONDS, target = src))
		return

	reset()


/// Links all the loading processes together - does validation for booting a map
/obj/machinery/quantum_server/proc/cold_boot_map(map_key, was_random_selection)
	if(!is_ready)
		return FALSE

	if(isnull(map_key))
		balloon_alert_to_viewers("nie wybrano domeny!")
		return FALSE

	if(generated_domain)
		balloon_alert_to_viewers("najpierw zatrzymaj obecną domenę!")
		return FALSE

	if(length(avatar_connection_refs))
		balloon_alert_to_viewers("wszyscy klienci muszą się rozłączyć!")
		return FALSE

	is_ready = FALSE
	playsound(src, 'sound/machines/terminal_processing.ogg', 30, 2)

	/// If any one of these fail, it reverts the entire process
	if(!load_domain(map_key) || !load_map_items() || !load_mob_segments())
		balloon_alert_to_viewers("inicjalizacja nieudana!")
		scrub_vdom()
		is_ready = TRUE
		update_appearance()
		return FALSE

	loaded_atoms = null
	// bonus za losową domenę dopiero po udanym załadowaniu
	domain_randomized = !!was_random_selection

	var/selection_type
	if(was_random_selection)
		selection_type = "random selection"
	else if(generated_domain.can_view_name(scanner_tier, points))
		selection_type = "full information"
	else
		selection_type = "redacted information"
	SSblackbox.record_feedback("nested tally", "bitrunning_domain_loaded", 1, list(selection_type, map_key))

	is_ready = TRUE

	var/spawn_chance = clamp((threat * glitch_chance), 5, threat_prob_max)
	if(prob(spawn_chance))
		INVOKE_ASYNC(src, PROC_REF(setup_glitch))

	playsound(src, 'sound/machines/terminal_insert_disc.ogg', 30, TRUE)
	balloon_alert_to_viewers("domena załadowana.")
	generated_domain.start_time = world.time
	points -= generated_domain.cost
	use_power = ACTIVE_POWER_USE
	update_appearance()

	if(broadcasting)
		start_broadcasting_network(BITRUNNER_CAMERA_NET)

	if(generated_domain.announce_to_ghosts)
		notify_ghosts("Bitrunnerzy załadowali domenę, w której mogą brać udział duchy. Sprawdź menu spawnerów.", source = src, header = "Glitch w Matrixie")

	return TRUE


/// Initializes a new domain if the given key is valid and the user has enough points
/obj/machinery/quantum_server/proc/load_domain(map_key)
	var/datum/lazy_template/virtual_domain/prototype = SSbitrunning.get_domain(map_key)
	if(isnull(prototype) || !can_afford_domain(prototype))
		return FALSE

	if(prototype.mission_min_candidates && !COOLDOWN_FINISHED(src, polling_cooldown))
		say("Zaawansowane algorytmy NPC się resetują, poczekaj [DisplayTimeText(COOLDOWN_TIMELEFT(src, polling_cooldown))] albo załaduj inną domenę.")
		playsound(src, "sound/machines/buzz-[pick("sigh", "two")].ogg", 50, TRUE)
		return FALSE

	generated_domain = prototype.make_instance()

	var/list/mob/lucky_ghosts
	if(generated_domain.mission_min_candidates)
		playsound(src, 'sound/machines/chime.ogg', 50, TRUE)
		say("Ładowanie zaawansowanych NPC...")
		var/datum/poll_config/config = new()
		config.question = "Chcesz zagrać jako wirtualny [generated_domain.spawner_role] w domenie bitrunnerów?"
		config.check_jobban = ROLE_GLITCH
		config.poll_time = 15 SECONDS
		config.ignore_category = POLL_IGNORE_GLITCH
		config.role_name_text = "wirtualny [generated_domain.spawner_role]"
		config.alert_pic = src
		var/list/mob/candidates = SSpolling.poll_ghost_candidates(config)
		for(var/amount in 1 to generated_domain.mission_max_candidates)
			if(length(candidates)) // If no candidates, fails in code below anyways
				LAZYADD(lucky_ghosts, pick_n_take(candidates))

		if(length(lucky_ghosts) < generated_domain.mission_min_candidates)
			notify_ghosts("Za mało chętnych na rolę: [generated_domain.spawner_role]! Misja przerwana!")
			playsound(src, "sound/machines/buzz-[pick("sigh", "two")].ogg", 50, TRUE)
			say("Błąd! Nie udało się załadować zaawansowanych NPC. Spróbuj ponownie albo wybierz inną domenę.")
			COOLDOWN_START(src, polling_cooldown, POLLING_COOLDOWN_TIME)
			QDEL_NULL(generated_domain)
			return FALSE

		playsound(src, 'sound/machines/ping.ogg', 50, TRUE)
		say("Gotowe!")

	RegisterSignal(generated_domain, COMSIG_LAZY_TEMPLATE_LOADED, PROC_REF(on_template_loaded))
	if(!generated_domain.lazy_load())
		return FALSE
	generated_domain.load_advanced_npcs(lucky_ghosts)

	return TRUE

/// Czy serwer stać na domenę (wygnańcy grają za darmo)
/obj/machinery/quantum_server/proc/can_afford_domain(datum/lazy_template/virtual_domain/domain)
	return points >= domain.cost

/// Loads in necessary map items like hololadder spawns, caches, etc
/obj/machinery/quantum_server/proc/load_map_items()
	var/list/turf/cache_turfs = list()
	var/list/turf/curiosity_turfs = list()

	for(var/obj/effect/thing in loaded_atoms)
		if(QDELETED(thing))
			continue
		if(istype(thing, /obj/effect/landmark/bitrunning/hololadder_spawn))
			exit_turfs += get_turf(thing)
			qdel(thing)
			continue

		if(istype(thing, /obj/effect/landmark/bitrunning/cache_goal_turf))
			var/turf/tile = get_turf(thing)
			goal_turfs += tile
			RegisterSignal(tile, COMSIG_ATOM_ENTERED, PROC_REF(on_goal_turf_entered))
			RegisterSignal(tile, COMSIG_PARENT_EXAMINE, PROC_REF(on_goal_turf_examined))
			qdel(thing)
			continue

		if(istype(thing, /obj/effect/landmark/bitrunning/cache_spawn))
			cache_turfs += get_turf(thing)
			qdel(thing)
			continue

		if(istype(thing, /obj/effect/mob_spawn/human/virtual_domain))
			LAZYADD(generated_domain.ghost_spawners, thing)
			continue

		if(istype(thing, /obj/effect/landmark/bitrunning/curiosity_spawn))
			curiosity_turfs += get_turf(thing)
			qdel(thing)
			continue

		if(istype(thing, /obj/effect/landmark/bitrunning/loot_signal))
			generated_domain.main_crate_loc = thing.loc
			qdel(thing)
			continue

		if(istype(thing, /obj/effect/landmark/bitrunning/permanent_exit))
			var/turf/tile = get_turf(thing)
			exit_turfs += tile
			qdel(thing)

			new /obj/structure/hololadder(tile, src)

	if(!length(exit_turfs))
		stack_trace("Failed to find exit turfs on generated domain [generated_domain.key].")
		return FALSE
	if(!length(goal_turfs))
		stack_trace("Failed to find send turfs on generated domain [generated_domain.key].")
		return FALSE
	if(!attempt_spawn_cache(cache_turfs))
		return FALSE

	while(length(curiosity_turfs))
		var/turf/picked_turf = attempt_spawn_curiosity(curiosity_turfs)
		if(!picked_turf)
			break
		generated_domain.secondary_loot_generated += 1
		curiosity_turfs -= picked_turf

	return TRUE


/// Stops the current virtual domain and disconnects all users
/obj/machinery/quantum_server/proc/reset(fast = FALSE)
	is_ready = FALSE
	domain_complete = FALSE

	sever_connections()

	if(!fast)
		notify_spawned_threats()
		addtimer(CALLBACK(src, PROC_REF(scrub_vdom)), 15 SECONDS, TIMER_UNIQUE|TIMER_STOPPABLE)
	else
		scrub_vdom() // used in unit testing, no need to wait for callbacks

	addtimer(CALLBACK(src, PROC_REF(cool_off)), ROUND_UP(server_cooldown_time * capacitor_coefficient), TIMER_UNIQUE|TIMER_STOPPABLE)
	update_appearance()

	use_power = IDLE_POWER_USE
	domain_randomized = FALSE
	retries_spent = 0

	stop_broadcasting_network(BITRUNNER_CAMERA_NET)


/// Tries to clean up everything in the domain
/obj/machinery/quantum_server/proc/scrub_vdom()
	sever_connections() /// just in case someone's connected
	SEND_SIGNAL(src, COMSIG_BITRUNNER_DOMAIN_SCRUBBED) // avatar cleanup just in case

	var/list/creatures = spawned_threat_refs + mutation_candidate_refs
	for(var/datum/weakref/creature_ref as anything in creatures)
		var/mob/living/creature = creature_ref?.resolve()
		if(isnull(creature))
			continue

		qdel(creature)

	for(var/turf/goal as anything in goal_turfs)
		UnregisterSignal(goal, list(COMSIG_ATOM_ENTERED, COMSIG_PARENT_EXAMINE))
	goal_turfs = list()

	if(generated_domain)
		UnregisterSignal(generated_domain, COMSIG_LAZY_TEMPLATE_LOADED)
		// Destroy() zwalnia rezerwację razem z całą zawartością
		QDEL_NULL(generated_domain)

	avatar_connection_refs.Cut()
	exit_turfs = list()
	mutation_candidate_refs.Cut()
	spawned_threat_refs.Cut()
	loaded_atoms = null
	update_appearance()

#undef POLLING_COOLDOWN_TIME
