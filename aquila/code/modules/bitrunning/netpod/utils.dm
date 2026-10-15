/// Puts the occupant in netpod stasis, basically short-circuiting environmental conditions
/obj/machinery/netpod/proc/add_healing(mob/living/target)
	if(target != occupant)
		return

	target.AddComponent(/datum/component/netpod_healing, src)
	target.playsound_local(src, 'sound/effects/bubbles.ogg', 20, TRUE)
	target.ExtinguishMob()
	use_power = ACTIVE_POWER_USE


/// Disconnects the occupant after a certain time so they aren't just hibernating in netpod stasis. A balance change
/obj/machinery/netpod/proc/auto_disconnect()
	if(isnull(occupant) || state_open || connected)
		return

	var/mob/player = occupant
	player.playsound_local(src, 'sound/effects/splash.ogg', 60, TRUE)
	to_chat(player, span_notice("Maszyna sama się rozłącza i zaczyna spuszczać płyn."))
	open_machine()


/// Handles occupant post-disconnection effects like damage, sounds, etc
/obj/machinery/netpod/proc/disconnect_occupant(cause_damage = FALSE)
	connected = FALSE

	var/mob/living/mob_occupant = occupant
	if(isnull(occupant) || !isliving(occupant) || mob_occupant.stat == DEAD)
		open_machine()
		return

	mob_occupant.playsound_local(src, 'sound/magic/blink.ogg', 25, TRUE)
	mob_occupant.overlay_fullscreen("bitrunning_static", /atom/movable/screen/fullscreen/flash/static)
	addtimer(CALLBACK(mob_occupant, TYPE_PROC_REF(/mob, clear_fullscreen), "bitrunning_static", 1 SECONDS), 2 SECONDS)
	mob_occupant.blind_eyes(1)
	mob_occupant.Paralyze(2 SECONDS)

	if(!is_operational)
		open_machine()
		return

	var/heal_time = 1
	if(mob_occupant.health < mob_occupant.maxHealth)
		heal_time = (mob_occupant.stat + 2) * 5
	addtimer(CALLBACK(src, PROC_REF(auto_disconnect)), heal_time SECONDS, TIMER_UNIQUE|TIMER_STOPPABLE)

	if(!cause_damage)
		return

	mob_occupant.flash_act(1, TRUE, FALSE, TRUE)
	mob_occupant.adjustOrganLoss(ORGAN_SLOT_BRAIN, disconnect_damage)
	INVOKE_ASYNC(mob_occupant, TYPE_PROC_REF(/mob, emote), "scream")
	to_chat(mob_occupant, span_danger("Zostałeś siłą odłączony od awatara! Myśli ci się plączą!"))


/**
 * ### Enter Matrix
 * Finds any current avatars from this chair - or generates a new one
 *
 * New avatars cost 1 attempt, and this will eject if there's none left
 *
 * Connects the mind to the avatar if everything is ok
 */
/obj/machinery/netpod/proc/enter_matrix()
	var/mob/living/carbon/human/neo = occupant
	if(!ishuman(neo) || neo.stat == DEAD || isnull(neo.mind))
		balloon_alert(neo, "nieprawidłowa osoba.")
		return

	// AQUILA: cyfrowe wygnanie - osoba z implantem wygnania trafia do Pętli na zawsze
	if(is_digital_exile_candidate(neo))
		INVOKE_ASYNC(src, PROC_REF(try_digital_exile), neo)
		return

	var/obj/machinery/quantum_server/server = find_server()
	if(isnull(server))
		balloon_alert(neo, "brak serwera!")
		return

	var/datum/lazy_template/virtual_domain/generated_domain = server.generated_domain
	if(isnull(generated_domain) || !server.is_ready)
		balloon_alert(neo, "nic nie załadowano!")
		return

	balloon_alert(neo, "nawiązywanie połączenia...")

	// Prevent hand interactions during loading to stop smuggling exploits into virtual domain
	ADD_TRAIT(neo, TRAIT_HANDS_BLOCKED, BITRUNNING_TRAIT)
	var/connection_successful = do_after(neo, 2 SECONDS, FALSE, src)
	REMOVE_TRAIT(neo, TRAIT_HANDS_BLOCKED, BITRUNNING_TRAIT)

	if(!connection_successful)
		open_machine()
		return

	var/mob/living/carbon/current_avatar = avatar_ref?.resolve()
	if(isnull(current_avatar) || current_avatar.stat != CONSCIOUS) // We need a viable avatar
		current_avatar = server.start_new_connection(neo, netsuit)
		if(isnull(current_avatar))
			balloon_alert(neo, "brak przepustowości!")
			return

	add_healing(occupant)

	if(!validate_entry(neo, current_avatar))
		open_machine()
		return

	current_avatar.AddComponent(/datum/component/avatar_connection, \
		neo.mind, \
		neo, \
		server, \
		src, \
		generated_domain.help_text, \
		copy_body, \
	)

	connected = TRUE


/// Finds a server and sets the server_ref
/obj/machinery/netpod/proc/find_server()
	var/obj/machinery/quantum_server/server = server_ref?.resolve()
	if(server)
		return server

	server = locate(/obj/machinery/quantum_server) in oview(4, src)
	if(isnull(server))
		return

	server_ref = WEAKREF(server)
	RegisterSignal(server, COMSIG_QSERVER_PARTS_REFRESHED, PROC_REF(on_server_upgraded))
	RegisterSignal(server, COMSIG_BITRUNNER_DOMAIN_COMPLETE, PROC_REF(on_domain_complete))
	RegisterSignal(server, COMSIG_BITRUNNER_DOMAIN_SCRUBBED, PROC_REF(on_domain_scrubbed))

	return server


/// Severs the connection with the current avatar
/obj/machinery/netpod/proc/sever_connection()
	if(isnull(occupant) || !connected)
		return

	SEND_SIGNAL(src, COMSIG_BITRUNNER_NETPOD_SEVER)


/// Checks for cases to eject/fail connecting an avatar
/obj/machinery/netpod/proc/validate_entry(mob/living/neo, mob/living/avatar)
	// Very invalid
	if(QDELETED(neo) || QDELETED(avatar) || QDELETED(src) || !is_operational)
		return FALSE

	// Invalid
	if(occupant != neo || isnull(neo.mind) || neo.stat >= UNCONSCIOUS || avatar.stat == DEAD)
		return FALSE

	return TRUE
