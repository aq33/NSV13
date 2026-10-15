#define MAX_DISTANCE 4 // How far crates can spawn from the server


/// Resets the cooldown state and updates icons
/obj/machinery/quantum_server/proc/cool_off()
	is_ready = TRUE
	update_appearance()
	bitrunning_announce("Raport serwera kwantowego: systemy termiczne w normie. Można konfigurować domenę.")


/// If there are hosted minds, attempts to get a list of their current virtual bodies w/ vitals
/obj/machinery/quantum_server/proc/get_avatar_data()
	var/list/hosted_avatars = list()

	for(var/datum/weakref/avatar_ref as anything in avatar_connection_refs.Copy())
		var/datum/component/avatar_connection/connection = avatar_ref.resolve()
		if(isnull(connection))
			avatar_connection_refs.Remove(avatar_ref)
			continue

		var/mob/living/creature = connection.parent
		var/mob/living/pilot = connection.old_body_ref?.resolve()

		hosted_avatars += list(list(
			"health" = creature.health,
			"name" = creature.name,
			"pilot" = "[pilot]",
			"brute" = creature.getBruteLoss(),
			"burn" = creature.getFireLoss(),
			"tox" = creature.getToxLoss(),
			"oxy" = creature.getOxyLoss(),
		))

	return hosted_avatars


/// I grab the atom here so I can signal it / manipulate spawners etc
/obj/machinery/quantum_server/proc/get_avatar_destination()
	// Branch A: Custom spawns
	if(length(generated_domain.custom_spawns))
		var/atom/valid_spawner

		while(isnull(valid_spawner) && length(generated_domain.custom_spawns))
			var/atom/chosen = pick(generated_domain.custom_spawns)
			if(QDELETED(chosen))
				generated_domain.custom_spawns -= chosen
				continue

			valid_spawner = chosen

		if(valid_spawner)
			return valid_spawner

	// Branch B: Hololadders
	if(!length(exit_turfs))
		return

	if(retries_spent >= length(exit_turfs))
		return

	var/turf/exit_tile
	for(var/turf/dest_turf in exit_turfs)
		if(!locate(/obj/structure/hololadder) in dest_turf)
			exit_tile = dest_turf
			break

	if(isnull(exit_tile))
		return

	var/obj/structure/hololadder/wayout = new(exit_tile, src)
	if(isnull(wayout))
		return

	retries_spent += 1

	return wayout


/// Locates any turfs with forges on them, returns a random one
/obj/machinery/quantum_server/proc/get_random_nearby_forge()
	var/list/nearby_forges = list()

	for(var/obj/machinery/byteforge/forge in oview(MAX_DISTANCE, src))
		nearby_forges += forge

	if(!length(nearby_forges))
		return
	return pick(nearby_forges)


/// Gets a random available domain given the current points.
/obj/machinery/quantum_server/proc/get_random_domain_id()
	if(points < 1)
		return

	var/list/random_domains = list()

	for(var/datum/lazy_template/virtual_domain/available as anything in SSbitrunning.all_domains)
		if(!(available.domain_flags & DOMAIN_TEST_ONLY) && \
			available.cost <= points && \
			available.cost > BITRUNNER_COST_NONE && \
			available.cost < BITRUNNER_COST_EXTREME \
		)
			random_domains.Add(available)

	if(!length(random_domains))
		return

	var/datum/lazy_template/virtual_domain/selected = pick(random_domains)
	domain_randomized = TRUE

	return selected.key


/// Removes all blacklisted items from a mob and returns them to base state
/obj/machinery/quantum_server/proc/reset_equipment(mob/living/carbon/human/person)
	for(var/obj/item/item in person.get_equipped_items(TRUE))
		qdel(item)

	var/datum/antagonist/bitrunning_glitch/antag_datum = locate() in person.mind?.antag_datums
	if(isnull(antag_datum?.outfit_type))
		return

	person.equipOutfit(antag_datum.outfit_type)

	antag_datum.fix_agent_id()


/// Severs any connected users
/obj/machinery/quantum_server/proc/sever_connections()
	if(isnull(generated_domain) || !length(avatar_connection_refs))
		return

	SEND_SIGNAL(src, COMSIG_BITRUNNER_QSRV_SEVER)


/// Do some magic teleport sparks
/obj/machinery/quantum_server/proc/spark_at_location(obj/cache)
	playsound(cache, 'sound/magic/blink.ogg', 50, TRUE)
	do_sparks(5, FALSE, get_turf(cache))


/// Starts building a new avatar for the player.
/// Called by netpods when they don't have a current avatar.
/// This is a procedural proc which links several others together.
/obj/machinery/quantum_server/proc/start_new_connection(mob/living/carbon/human/neo, datum/outfit/netsuit)
	var/atom/entry_atom = get_avatar_destination()
	if(isnull(entry_atom))
		return

	var/mob/living/carbon/human/new_avatar = generate_avatar(get_turf(entry_atom), netsuit)
	stock_gear(new_avatar, neo, generated_domain)

	// Cleanup for domains with one time use custom spawns
	if(!length(generated_domain.custom_spawns))
		return new_avatar

	// If we're spawning from some other fuckery, no need for this
	if(istype(entry_atom, /obj/effect/mob_spawn/human/virtual_domain))
		var/obj/effect/mob_spawn/human/virtual_domain/spawner = entry_atom
		spawner.artificial_spawn(new_avatar)

	if(!generated_domain.keep_custom_spawns)
		generated_domain.custom_spawns -= entry_atom
		qdel(entry_atom)

	return new_avatar


/// Toggles broadcast on and off
/obj/machinery/quantum_server/proc/toggle_broadcast()
	if(!COOLDOWN_FINISHED(src, broadcast_toggle_cd))
		return FALSE

	broadcasting = !broadcasting

	if(generated_domain)
		// The cooldown only really matter is we're flipping TVs
		COOLDOWN_START(src, broadcast_toggle_cd, 5 SECONDS)
		// And we only flip TVs when there's a domain, because otherwise there's no cams to watch
		if(broadcasting)
			start_broadcasting_network(BITRUNNER_CAMERA_NET)
		else
			stop_broadcasting_network(BITRUNNER_CAMERA_NET)
	return TRUE


/// Returns a turf if it's not dense, else will find a neighbor.
/obj/machinery/quantum_server/proc/validate_turf(turf/chosen_turf)
	if(!is_blocked_turf(chosen_turf))
		return chosen_turf

	for(var/turf/tile in get_adjacent_open_turfs(chosen_turf))
		if(!is_blocked_turf(tile))
			return tile

/// AQUILA: tg start_broadcasting_network - dodaje sieć kamer bitrunnerów do telewizorów rozrywkowych
/proc/start_broadcasting_network(network)
	for(var/obj/machinery/computer/security/telescreen/entertainment/tv in GLOB.machines)
		tv.network |= network
		tv.notify(TRUE)

/// AQUILA: tg stop_broadcasting_network
/proc/stop_broadcasting_network(network)
	for(var/obj/machinery/computer/security/telescreen/entertainment/tv in GLOB.machines)
		if(!(network in tv.network))
			continue
		tv.network -= network
		if(length(tv.network) <= 1)
			tv.notify(FALSE)

#undef MAX_DISTANCE
