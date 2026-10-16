/// Adds threats to the list and notifies players
/obj/machinery/quantum_server/proc/add_threats(mob/living/threat)
	spawned_threat_refs.Add(WEAKREF(threat))
	SEND_SIGNAL(src, COMSIG_BITRUNNER_THREAT_CREATED)
	threat.AddComponent(/datum/component/virtual_entity, src)


/// Choses which antagonist role is spawned based on threat
/obj/machinery/quantum_server/proc/get_antagonist_role()
	var/list/available = list()

	for(var/datum/antagonist/bitrunning_glitch/subtype as anything in subtypesof(/datum/antagonist/bitrunning_glitch))
		if(threat >= initial(subtype.threat))
			available += subtype

	var/datum/antagonist/bitrunning_glitch/chosen = pick(available)

	threat -= initial(chosen.threat) * 0.5

	return chosen


/// Selects a target to mutate. Gives two attempts, then crashes if it fails.
/obj/machinery/quantum_server/proc/get_mutation_target()
	var/datum/weakref/target_ref = pick(mutation_candidate_refs)
	var/mob/living/resolved = target_ref.resolve()

	if(resolved)
		return resolved

	mutation_candidate_refs.Remove(target_ref)
	if(!length(mutation_candidate_refs))
		return

	target_ref = pick(mutation_candidate_refs)
	resolved = target_ref.resolve()
	return resolved


/// Finds any mobs with minds in the zones and gives them the bad news
/obj/machinery/quantum_server/proc/notify_spawned_threats()
	for(var/datum/weakref/baddie_ref as anything in spawned_threat_refs)
		var/mob/living/baddie = baddie_ref.resolve()
		if(isnull(baddie?.mind) || baddie.stat >= UNCONSCIOUS)
			continue

		var/atom/movable/screen/alert/bitrunning/alert = baddie.throw_alert(
			ALERT_BITRUNNER_RESET,
			/atom/movable/screen/alert/bitrunning,
			new_master = src,
		)
		if(alert)
			alert.name = "Kolejka usuwania"
			alert.desc = "Serwer się resetuje. Czeka cię niebyt."

		to_chat(baddie, span_userdanger("Zostałeś oznaczony do usunięcia! Dziękujemy za służbę."))


/// Removes a specific threat - used when station spawning
/obj/machinery/quantum_server/proc/remove_threat(mob/living/threat)
	spawned_threat_refs.Remove(WEAKREF(threat))


/// Selects the role and waits for a ghost orbiter
/obj/machinery/quantum_server/proc/setup_glitch(datum/antagonist/bitrunning_glitch/forced_role)
	if(!validate_mutation_candidates())
		return

	var/mob/living/mutation_target = get_mutation_target()
	if(isnull(mutation_target))
		stack_trace("vdom: After two attempts, no valid mutation target was found.")
		return

	var/atom/thing = mutation_target
	thing.create_digital_aura()

	var/datum/antagonist/bitrunning_glitch/chosen_role = forced_role || get_antagonist_role()
	var/role_name = initial(chosen_role.name)

	var/datum/poll_config/config = new()
	config.question = "W domenie wirtualnej pojawia się tymczasowy antagonista. Po zakończeniu wrócisz do poprzedniego ciała."
	config.check_jobban = ROLE_GLITCH
	config.poll_time = 20 SECONDS
	config.ignore_category = POLL_IGNORE_GLITCH
	config.alert_pic = mutation_target
	config.jump_target = mutation_target
	config.role_name_text = "Usterka: [role_name]"
	var/mob/chosen_one = SSpolling.poll_ghosts_for_target(config, mutation_target)
	spawn_glitch(chosen_role, mutation_target, chosen_one)
	return mutation_target


/// Orbit poll has concluded - spawn the antag
/obj/machinery/quantum_server/proc/spawn_glitch(datum/antagonist/bitrunning_glitch/chosen_role, mob/living/mutation_target, mob/dead/observer/ghost)
	if(QDELETED(mutation_target))
		return

	if(QDELETED(src) || isnull(ghost) || isnull(ghost.client) || isnull(generated_domain) || !is_ready || !is_operational)
		var/atom/thing = mutation_target
		thing.remove_digital_aura()
		return

	var/role_name = initial(chosen_role.name)

	var/mob/living/new_mob
	switch(role_name)
		if(ROLE_NETGUARDIAN)
			new_mob = new /mob/living/simple_animal/hostile/netguardian(mutation_target.loc)
		else // any other humanoid mob
			new_mob = new /mob/living/carbon/human(mutation_target.loc)

	mutation_target.gib()

	var/datum/mind/ghost_mind = ghost.mind
	new_mob.key = ghost.key

	if(ghost_mind)
		new_mob.AddComponent(/datum/component/temporary_body, ghost_mind, ghost_mind.current, TRUE)

	var/datum/mind/antag_mind = new_mob.mind
	antag_mind.add_antag_datum(chosen_role)
	antag_mind.assigned_role = ROLE_GLITCH

	playsound(new_mob, 'sound/magic/ethereal_exit.ogg', 50, TRUE)
	message_admins("[ADMIN_LOOKUPFLW(new_mob)] został wirtualnym antagonistą (glitch bitrunningu).")
	log_game("[key_name(new_mob)] was spawned as a virtual antagonist by an event.")

	add_threats(new_mob)


/// Oh boy - transports the antag station side
/obj/machinery/quantum_server/proc/station_spawn(mob/living/antag, obj/machinery/byteforge/chosen_forge, turf/goal_turf)
	antag.balloon_alert(antag, "skanowanie...")
	chosen_forge.setup_particles(angry = TRUE)
	bitrunning_announce("ALARM SERWERA KWANTOWEGO: Wykryto naruszenie bezpieczeństwa. Trwa nieautoryzowana sekwencja wejścia...")
	SEND_SIGNAL(src, COMSIG_BITRUNNER_STATION_SPAWN)

	var/timeout = 2 SECONDS
	if(!ishuman(antag))
		bitrunning_announce("ALARM SERWERA KWANTOWEGO: Protokoły fabrykacji uległy awarii. Ewakuujcie obszar.")
		timeout = 10 SECONDS

	var/bitrunners_alive = 0
	var/island_brawl_exception = istype(generated_domain, /datum/lazy_template/virtual_domain/island_brawl)
	for(var/datum/weakref/bitrunner_ref as anything in avatar_connection_refs)
		var/datum/component/avatar_connection/connection = bitrunner_ref.resolve()
		var/mob/living/bitrunner = connection?.parent
		if(!bitrunner)
			continue
		if(bitrunner.stat >= SOFT_CRIT || !bitrunner.client)
			continue
		if(island_brawl_exception)
			timeout *= max(5 - generated_domain.main_crate_points, 1)
			continue
		bitrunners_alive++
		timeout *= 5
	if(bitrunners_alive)
		to_chat(antag, span_warning("W twojej domenie wciąż grasuje [bitrunners_alive] przestępców. Dopóki się nimi nie zajmiesz, wyjście będzie trudniejsze."))

	timeout -= 0.5 SECONDS

	if(!do_after(antag, 0.5 SECONDS, target = goal_turf) || QDELETED(antag) || antag.loc != goal_turf || QDELETED(chosen_forge) || QDELETED(src))
		return
	if(!do_after(antag, timeout, target = goal_turf) || QDELETED(chosen_forge) || QDELETED(antag) || QDELETED(src) || !is_ready || !is_operational)
		chosen_forge.setup_particles()
		return

	var/datum/component/glitch/effect = antag.AddComponent(/datum/component/glitch, src, chosen_forge)

	chosen_forge.flicker(angry = TRUE)
	if(!do_after(antag, 1 SECONDS, target = goal_turf))
		chosen_forge.setup_particles()
		qdel(effect)
		return

	chosen_forge.flash()

	if(ishuman(antag))
		reset_equipment(antag)
	else
		bitrunning_announce("KRYTYCZNY ALARM SERWERA KWANTOWEGO: Uruchomiono niezarejestrowaną jednostkę mechaniczną.")

	var/datum/antagonist/bitrunning_glitch/antag_datum = antag.mind?.has_antag_datum(/datum/antagonist/bitrunning_glitch)
	if(istype(antag_datum))
		antag_datum.show_in_roundend = TRUE

	var/datum/component/temp_body = antag.GetComponent(/datum/component/temporary_body)
	if(temp_body)
		qdel(temp_body)

	do_teleport(antag, get_turf(chosen_forge), forced = TRUE, asoundin = 'sound/magic/ethereal_enter.ogg', asoundout = 'sound/magic/ethereal_exit.ogg', channel = TELEPORT_CHANNEL_QUANTUM)

/// Removes any invalid candidates from the list
/obj/machinery/quantum_server/proc/validate_mutation_candidates()
	for(var/datum/weakref/creature_ref as anything in mutation_candidate_refs.Copy())
		var/mob/living/creature = creature_ref?.resolve()
		if(isnull(creature) || creature.mind || creature.stat == DEAD)
			mutation_candidate_refs.Remove(creature_ref)

	if(!length(mutation_candidate_refs))
		return FALSE

	shuffle_inplace(mutation_candidate_refs)

	return TRUE
