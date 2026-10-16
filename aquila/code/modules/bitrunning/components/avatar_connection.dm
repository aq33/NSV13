/**
 * Essentially temporary body with a twist - the virtual domain variant uses damage connections,
 * listens for vdom relevant signals.
 */
/datum/component/avatar_connection
	/// The person in the netpod
	var/datum/weakref/old_body_ref
	/// The mind of the person in the netpod
	var/datum/weakref/old_mind_ref
	/// Rola z przydziału przed wejściem; awatar dostaje „Awatar Bitowy”, więc po powrocie ją oddajemy
	var/old_assigned_role
	/// The server connected to the netpod
	var/datum/weakref/server_ref
	/// The netpod the avatar is in
	var/datum/weakref/netpod_ref
	/// If we've taken any damage, is set to FALSE - for tracking nohit bonus
	var/nohit = TRUE

/datum/component/avatar_connection/Initialize(
	datum/mind/old_mind,
	mob/living/old_body,
	obj/machinery/quantum_server/server,
	obj/machinery/netpod/pod,
	help_text,
	copy_body,
	)

	if(!isliving(parent) || !isliving(old_body) || !old_mind || !server.is_operational || !pod.is_operational)
		return COMPONENT_INCOMPATIBLE

	var/mob/living/avatar = parent

	netpod_ref = WEAKREF(pod)
	old_body_ref = WEAKREF(old_body)
	old_mind_ref = WEAKREF(old_mind)
	old_assigned_role = old_mind.assigned_role
	pod.avatar_ref = WEAKREF(avatar)
	server_ref = WEAKREF(server)
	server.avatar_connection_refs.Add(WEAKREF(src))

	old_mind.transfer_to(avatar, TRUE)
	ADD_TRAIT(avatar, TRAIT_NO_MINDSWAP, REF(src)) // do not remove this one
	ADD_TRAIT(old_body, TRAIT_MIND_TEMPORARILY_GONE, REF(src))

	/**
	 * Things that will disconnect forcefully:
	 * - Server shutdown / broken
	 * - Netpod power loss / broken
	 * - Pilot dies/ is moved / falls unconscious
	 */
	RegisterSignal(old_body, list(COMSIG_MOB_DEATH, COMSIG_MOVABLE_MOVED, COMSIG_LIVING_STATUS_UNCONSCIOUS), PROC_REF(on_sever_connection))
	RegisterSignal(pod, COMSIG_BITRUNNER_CROWBAR_ALERT, PROC_REF(on_netpod_crowbar))
	RegisterSignal(pod, COMSIG_BITRUNNER_NETPOD_INTEGRITY, PROC_REF(on_netpod_damaged))
	RegisterSignal(pod, COMSIG_BITRUNNER_NETPOD_SEVER, PROC_REF(on_sever_connection))
	RegisterSignal(server, COMSIG_BITRUNNER_DOMAIN_COMPLETE, PROC_REF(on_domain_completed))
	RegisterSignal(server, COMSIG_BITRUNNER_QSRV_SEVER, PROC_REF(on_sever_connection))
	RegisterSignal(server, COMSIG_BITRUNNER_SHUTDOWN_ALERT, PROC_REF(on_shutting_down))
	RegisterSignal(server, COMSIG_BITRUNNER_THREAT_CREATED, PROC_REF(on_threat_created))
	RegisterSignal(server, COMSIG_BITRUNNER_STATION_SPAWN, PROC_REF(on_station_spawn))
#ifndef UNIT_TESTS
	RegisterSignal(old_mind, COMSIG_MIND_TRANSFER_TO, PROC_REF(on_mind_transfer))
#endif

	if(!locate(/datum/action/avatar_domain_info) in avatar.actions)
		var/datum/avatar_help_text/help_datum = new(help_text)
		var/datum/action/avatar_domain_info/action = new(help_datum)
		action.Grant(avatar)

	var/alias = avatar.client?.prefs?.active_character?.custom_names["hacker_alias"]
	if(!alias)
		alias = pick(GLOB.hacker_aliases)

	if(alias && avatar.real_name != alias)
		avatar.fully_replace_character_name(avatar.real_name, alias)
		if(ishuman(avatar) && ishuman(old_body) && copy_body)
			var/mob/living/carbon/human/human_avatar = avatar
			var/mob/living/carbon/human/human_old_body = old_body
			human_old_body.dna.transfer_identity(human_avatar, transfer_SE = FALSE)
			human_avatar.real_name = alias
			human_avatar.name = alias
			human_avatar.updateappearance(mutcolor_update = TRUE)

	update_avatar_id()
	avatar.mind.assigned_role = "Awatar Bitowy"

	avatar.playsound_local(avatar, 'sound/magic/blink.ogg', 25, TRUE)
	avatar.overlay_fullscreen("bitrunning_static", /atom/movable/screen/fullscreen/flash/static)
	addtimer(CALLBACK(avatar, TYPE_PROC_REF(/mob, clear_fullscreen), "bitrunning_static", 1 SECONDS), 2 SECONDS)
	avatar.blind_eyes(1) // I'm in


/datum/component/avatar_connection/Destroy(force)
	var/datum/mind/old_mind = old_mind_ref?.resolve()
	if(old_mind)
		UnregisterSignal(old_mind, COMSIG_MIND_TRANSFER_TO)
		restore_assigned_role(old_mind)
	return ..()

/// Oddaje umysłowi rolę sprzed wejścia do domeny
/datum/component/avatar_connection/proc/restore_assigned_role(datum/mind/old_mind)
	if(old_mind.assigned_role == "Awatar Bitowy")
		old_mind.assigned_role = old_assigned_role

/datum/component/avatar_connection/PostTransfer()
	var/obj/machinery/netpod/pod = netpod_ref?.resolve()
	if(isnull(pod))
		return COMPONENT_INCOMPATIBLE

	if(!isliving(parent))
		return COMPONENT_INCOMPATIBLE

	pod.avatar_ref = WEAKREF(parent)


/datum/component/avatar_connection/RegisterWithParent()
	ADD_TRAIT(parent, TRAIT_TEMPORARY_BODY, REF(src))
	/**
	 * Things that cause safe disconnection:
	 * - Click the alert
	 * - Mailed in a cache
	 * - Click / Stand on the ladder
	 */
	RegisterSignal(parent, list(COMSIG_BITRUNNER_ALERT_SEVER, COMSIG_BITRUNNER_CACHE_SEVER, COMSIG_BITRUNNER_LADDER_SEVER), PROC_REF(on_safe_disconnect))
	RegisterSignal(parent, list(COMSIG_MOB_DEATH, COMSIG_PARENT_QDELETING), PROC_REF(on_sever_connection))
	RegisterSignal(parent, COMSIG_MOB_APPLY_DAMGE, PROC_REF(on_linked_damage))


/datum/component/avatar_connection/UnregisterFromParent()
	REMOVE_TRAIT(parent, TRAIT_TEMPORARY_BODY, REF(src))
	UnregisterSignal(parent, list(
		COMSIG_BITRUNNER_ALERT_SEVER,
		COMSIG_BITRUNNER_CACHE_SEVER,
		COMSIG_BITRUNNER_LADDER_SEVER,
		COMSIG_MOB_DEATH,
		COMSIG_PARENT_QDELETING,
		COMSIG_MOB_APPLY_DAMGE,
	))


/// Updates our avatar's ID to match our avatar's name.
/datum/component/avatar_connection/proc/update_avatar_id()
	var/mob/living/avatar = parent
	var/obj/item/card/id/our_id = locate() in avatar.GetAllContents()
	if(isnull(our_id))
		return

	our_id.registered_name = avatar.real_name
	our_id.update_label()
	if(our_id.registered_account)
		our_id.registered_account.account_holder = avatar.real_name


/// Disconnects the avatar and returns the mind to the old_body.
/datum/component/avatar_connection/proc/full_avatar_disconnect(cause_damage = FALSE, datum/source)
#ifndef UNIT_TESTS
	return_to_old_body()
#endif

	var/obj/machinery/netpod/hosting_netpod = netpod_ref?.resolve()
	if(isnull(hosting_netpod) && istype(source, /obj/machinery/netpod))
		hosting_netpod = source

	hosting_netpod?.disconnect_occupant(cause_damage)

	var/obj/machinery/quantum_server/server = server_ref?.resolve()
	if(server)
		for(var/datum/weakref/ref as anything in server.avatar_connection_refs.Copy())
			if(ref.resolve() == src)
				server.avatar_connection_refs -= ref

	if(!QDELETED(src))
		qdel(src)


/// Triggers whenever the server gets a loot crate pushed to goal area
/datum/component/avatar_connection/proc/on_domain_completed(datum/source, atom/entered)
	SIGNAL_HANDLER

	var/mob/living/avatar = parent
	avatar.playsound_local(avatar, 'sound/machines/terminal_success.ogg', 50, TRUE)
	avatar.throw_alert(ALERT_BITRUNNER_COMPLETED, /atom/movable/screen/alert/bitrunning/qserver_domain_complete)


/// Transfers damage from the avatar to the old_body
/datum/component/avatar_connection/proc/on_linked_damage(datum/source, damage, damage_type, def_zone)
	SIGNAL_HANDLER

	var/mob/living/carbon/old_body = old_body_ref?.resolve()
	if(isnull(old_body) || damage_type == STAMINA || damage_type == OXY || damage <= 0)
		return

	if(damage >= (old_body.health + 100))
		INVOKE_ASYNC(src, PROC_REF(full_avatar_disconnect), TRUE)
		return

	if(damage > 30 && prob(30))
		INVOKE_ASYNC(old_body, TYPE_PROC_REF(/mob, emote), "scream")

	var/zone = def_zone
	if(isbodypart(def_zone)) // If the defined zone is a bodypart, then it is the bodypart of the domain avatar. We don't want that bodypart, we want the real body's bodypart, so we go back to zone.
		var/obj/item/bodypart/avatar_part = def_zone
		zone = avatar_part.body_zone

	old_body.apply_damage(damage, damage_type, zone)

	if(old_body.stat >= UNCONSCIOUS) // KO!
		INVOKE_ASYNC(src, PROC_REF(full_avatar_disconnect), TRUE)

	nohit = FALSE

/// Handles minds being swapped around in subsequent avatars
/datum/component/avatar_connection/proc/on_mind_transfer(datum/source, mob/old_mob, mob/new_mob)
	SIGNAL_HANDLER

	if(!isliving(new_mob) || new_mob == parent)
		return

	var/datum/action/avatar_domain_info/action = locate() in old_mob.actions
	if(action)
		action.Grant(new_mob)

	new_mob.TakeComponent(src)


/// Triggers when someone starts prying open our netpod
/datum/component/avatar_connection/proc/on_netpod_crowbar(datum/source, mob/living/intruder)
	SIGNAL_HANDLER

	var/mob/living/avatar = parent
	avatar.playsound_local(avatar, 'sound/machines/terminal_alert.ogg', 50, TRUE)
	var/atom/movable/screen/alert/bitrunning/alert = avatar.throw_alert(ALERT_BITRUNNER_CROWBAR, /atom/movable/screen/alert/bitrunning, new_master = intruder)
	if(alert)
		alert.name = "Netpod naruszony"
		alert.desc = "Ktoś podważa netpod. Znajdź wyjście."


/// Triggers when the netpod is taking damage and is under 50%
/datum/component/avatar_connection/proc/on_netpod_damaged(datum/source)
	SIGNAL_HANDLER

	var/mob/living/avatar = parent
	var/atom/movable/screen/alert/bitrunning/alert = avatar.throw_alert(ALERT_BITRUNNER_INTEGRITY, /atom/movable/screen/alert/bitrunning, new_master = source)
	if(alert)
		alert.name = "Integralność zagrożona"
		alert.desc = "Netpod jest uszkodzony. Znajdź wyjście."


/// Triggers when a safe disconnect is called
/datum/component/avatar_connection/proc/on_safe_disconnect(datum/source)
	SIGNAL_HANDLER

	INVOKE_ASYNC(src, PROC_REF(full_avatar_disconnect))


/// Received message to sever connection
/datum/component/avatar_connection/proc/on_sever_connection(datum/source)
	SIGNAL_HANDLER

	INVOKE_ASYNC(src, PROC_REF(full_avatar_disconnect), TRUE, source)


/// Triggers when the server is shutting down
/datum/component/avatar_connection/proc/on_shutting_down(datum/source, mob/living/hackerman)
	SIGNAL_HANDLER

	var/mob/living/avatar = parent
	avatar.playsound_local(avatar, 'sound/machines/terminal_alert.ogg', 50, TRUE)
	var/atom/movable/screen/alert/bitrunning/alert = avatar.throw_alert(ALERT_BITRUNNER_SHUTDOWN, /atom/movable/screen/alert/bitrunning, new_master = hackerman)
	if(alert)
		alert.name = "Restart domeny"
		alert.desc = "Domena się restartuje. Znajdź wyjście."


/// Triggers whenever an antag steps onto an exit turf and the server is emagged
/datum/component/avatar_connection/proc/on_station_spawn(datum/source)
	SIGNAL_HANDLER

	var/mob/living/avatar = parent
	avatar.playsound_local(avatar, 'sound/machines/terminal_alert.ogg', 50, TRUE)
	var/atom/movable/screen/alert/bitrunning/alert = avatar.throw_alert(ALERT_BITRUNNER_BREACH, /atom/movable/screen/alert/bitrunning, new_master = source)
	if(alert)
		alert.name = "Naruszenie bezpieczeństwa"
		alert.desc = "Wrogi byt przebija się do kryjówki. Znajdź wyjście."


/// Server has spawned a ghost role threat
/datum/component/avatar_connection/proc/on_threat_created(datum/source)
	SIGNAL_HANDLER

	var/mob/living/avatar = parent
	var/atom/movable/screen/alert/bitrunning/alert = avatar.throw_alert(ALERT_BITRUNNER_THREAT, /atom/movable/screen/alert/bitrunning, new_master = source)
	if(alert)
		alert.name = "Wykryto zagrożenie"
		alert.desc = "Anomalie w strumieniu danych."


/// Returns the mind to the old body
/datum/component/avatar_connection/proc/return_to_old_body()
	var/datum/mind/old_mind = old_mind_ref?.resolve()
	var/mob/living/old_body = old_body_ref?.resolve()
	var/mob/living/avatar = parent

	if(old_body)
		REMOVE_TRAIT(old_body, TRAIT_MIND_TEMPORARILY_GONE, REF(src))

	if(old_mind)
		UnregisterSignal(old_mind, COMSIG_MIND_TRANSFER_TO)

	if(isnull(old_mind) || isnull(old_body))
		return

	if(old_mind.current != avatar)
		return

	var/datum/action/avatar_domain_info/action = locate() in avatar.actions
	action?.Remove(avatar)

	old_mind.transfer_to(old_body, TRUE)
	restore_assigned_role(old_mind)
	avatar.ghostize(FALSE)
