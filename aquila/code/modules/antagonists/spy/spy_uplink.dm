// Spy uplink (port of tgstation code/modules/antagonists/spy/spy_uplink.dm)

/**
 * ## Spy uplink
 *
 * Applied to items similar to traitor uplinks.
 *
 * Used for spies to complete bounties.
 */
/datum/component/spy_uplink
	/// Weakref to the spy antag datum which owns this uplink
	var/datum/weakref/spy_ref
	/// The handler which manages all bounties across all spies.
	var/static/datum/spy_bounty_handler/handler
	/// Whether the parent PDA could be detonated before we were added, restored on removal
	var/was_detonatable
	/// Whether a scan is in progress, so only one theft runs at a time
	var/scanning = FALSE

/datum/component/spy_uplink/Initialize(datum/antagonist/spy/spy)
	if(!isitem(parent))
		return COMPONENT_INCOMPATIBLE

	spy_ref = WEAKREF(spy)

	if(isnull(handler))
		handler = new()

/datum/component/spy_uplink/RegisterWithParent()
	RegisterSignal(parent, COMSIG_PARENT_EXAMINE, PROC_REF(on_examine))
	RegisterSignal(parent, COMSIG_ITEM_ATTACK_SELF, PROC_REF(on_attack_self))
	RegisterSignal(parent, COMSIG_ITEM_PRE_ATTACK_SECONDARY, PROC_REF(on_pre_attack_secondary))
	// Spy PDAs can't be blown up by PDA bombs, like in tg
	if(istype(parent, /obj/item/modular_computer/tablet))
		var/obj/item/modular_computer/tablet/tablet = parent
		was_detonatable = tablet.detonatable
		tablet.detonatable = FALSE

/datum/component/spy_uplink/UnregisterFromParent()
	UnregisterSignal(parent, list(
		COMSIG_PARENT_EXAMINE,
		COMSIG_ITEM_ATTACK_SELF,
		COMSIG_ITEM_PRE_ATTACK_SECONDARY,
	))
	if(istype(parent, /obj/item/modular_computer/tablet))
		var/obj/item/modular_computer/tablet/tablet = parent
		tablet.detonatable = was_detonatable

/// Checks that the passed mob is the owner of this uplink.
/datum/component/spy_uplink/proc/is_our_spy(mob/whoever)
	var/datum/antagonist/spy/spy_datum = spy_ref?.resolve()
	return spy_datum?.owner.current == whoever

/datum/component/spy_uplink/proc/on_examine(obj/item/source, mob/user, list/examine_list)
	SIGNAL_HANDLER

	if(!is_our_spy(user))
		return
	examine_list += "<span class='notice'>Rozpoznajesz w tym swój <i>uplink szpiega</i>.</span>"
	examine_list += "<span class='notice'>- <b>Użyj w ręce</b>, żeby zobaczyć listę zleceń.</span>"
	examine_list += "<span class='notice'>- Kliknij nim <b>prawym przyciskiem</b> na cel zlecenia, żeby go ukraść.</span>"

/datum/component/spy_uplink/proc/on_attack_self(obj/item/source, mob/user)
	SIGNAL_HANDLER

	if(IS_SPY(user))
		INVOKE_ASYNC(src, TYPE_PROC_REF(/datum, ui_interact), user)

/datum/component/spy_uplink/proc/on_pre_attack_secondary(obj/item/source, atom/target, mob/living/user, params)
	SIGNAL_HANDLER

	if(!ismovable(target))
		return NONE
	if(!IS_SPY(user))
		return NONE
	if(!try_steal(target, user))
		return NONE
	return COMPONENT_SECONDARY_CANCEL_ATTACK_CHAIN

/// Checks if the passed atom is something that can be stolen according to one of the active bounties.
/// If so, starts the stealing process.
/datum/component/spy_uplink/proc/try_steal(atom/movable/stealing, mob/living/spy)
	for(var/datum/spy_bounty/bounty as anything in handler.get_all_bounties())
		if(!bounty.can_claim(spy))
			continue
		if(!bounty.is_stealable(stealing))
			continue
		if(bounty.claimed)
			stealing.balloon_alert(spy, "zlecenie już wykonane!")
			return TRUE
		if(scanning)
			spy.balloon_alert(spy, "już skanujesz!") // Only shown if they're trying to scan two valid targets
			return TRUE
		SEND_SIGNAL(stealing, COMSIG_MOVABLE_SPY_STEALING, spy, bounty)
		INVOKE_ASYNC(src, PROC_REF(start_stealing), stealing, spy, bounty)
		return TRUE

	return FALSE

/// Wraps the stealing process in a scanning effect.
/datum/component/spy_uplink/proc/start_stealing(atom/movable/stealing, mob/living/spy, datum/spy_bounty/bounty)
	if(!isturf(stealing.loc) && stealing.loc != spy)
		to_chat(spy, "<span class='warning'>Twój uplink mruga na czerwono: [stealing] nie da się stamtąd wydobyć.</span>")
		return FALSE

	log_combat(spy, stealing, "started stealing", parent, "(spy bounty)")
	playsound(stealing, 'sound/items/pshoom.ogg', 33, vary = TRUE, extrarange = SILENCED_SOUND_EXTRARANGE, frequency = 0.33)

	var/obj/effect/spy_scan_effect/active_scan_effect = new(stealing.loc)
	active_scan_effect.appearance = stealing.appearance
	active_scan_effect.dir = stealing.dir
	active_scan_effect.mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	active_scan_effect.color = "#3ba0ff"
	active_scan_effect.alpha = 150
	active_scan_effect.plane = stealing.plane
	active_scan_effect.layer = stealing.layer + 0.1

	var/obj/effect/spy_scan_effect/cone/active_scan_cone
	if(isturf(stealing.loc) && isturf(spy.loc)) // Cone doesn't make sense if its being held or something
		active_scan_cone = new(spy.loc)
		var/angle = round(get_angle(spy, stealing), 10)
		if(angle > 180 && angle < 360)
			active_scan_cone.pixel_x -= 16
		else if(angle < 180 && angle > 0)
			active_scan_cone.pixel_x += 16
		if(angle > 90 && angle < 270)
			active_scan_cone.pixel_y -= 16
		else if(angle < 90 || angle > 270)
			active_scan_cone.pixel_y += 16
		active_scan_cone.transform = active_scan_cone.transform.Turn(angle)
		active_scan_cone.alpha = 0
		animate(active_scan_cone, time = 0.5 SECONDS, alpha = initial(active_scan_cone.alpha))

	scanning = TRUE
	. = steal_process(stealing, spy, bounty)
	scanning = FALSE
	qdel(active_scan_effect)
	qdel(active_scan_cone)
	return .

/// Attempts to steal the passed atom in accordance with the passed bounty.
/// If successful, proceeds to complete the bounty.
/datum/component/spy_uplink/proc/steal_process(atom/movable/stealing, mob/living/spy, datum/spy_bounty/bounty)
	spy.visible_message(
		"<span class='warning'>[spy] zaczyna skanować [stealing] dziwnym urządzeniem...</span>",
		"<span class='notice'>Zaczynasz skanować [stealing] i przygotowujesz to do wydobycia.</span>",
	)

	if(!do_after(spy, bounty.theft_time, TRUE, stealing))
		return FALSE
	if(bounty.claimed)
		to_chat(spy, "<span class='warning'>Twój uplink mruga na czerwono: zlecenie na [stealing] wykonał już inny szpieg!</span>")
		return FALSE
	if(spy.is_holding(stealing) && !spy.dropItemToGround(stealing))
		to_chat(spy, "<span class='warning'>Twój uplink mruga na czerwono: [stealing] przykleiło się do twojej ręki!</span>")
		return FALSE

	var/bounty_key = bounty.get_dupe_protection_key(stealing)
	// record that we've claimed this type of bounty
	handler.all_claimed_bounty_types[bounty_key] += 1
	handler.claimed_bounties_from_last_pool[bounty_key] = TRUE
	// clear up the bounty itself
	bounty.clean_up_stolen_item(stealing, spy)
	bounty.claimed = TRUE
	// adds child items to the bounty pool, ie ammo for a newly acquired gun
	for(var/child_item_type in bounty.reward_item.relevant_child_items)
		handler.try_add_to_loot_pool(handler.get_uplink_item(child_item_type))
	// and finally, spawn the reward
	var/atom/movable/reward = handler.spawn_reward(bounty.reward_item, spy)

	to_chat(spy, "<span class='notice'>Zlecenie wykonane! Twoja nagroda: [reward].</span>")

	playsound(parent, 'aquila/sound/machines/wewewew.ogg', 50, TRUE, SHORT_RANGE_SOUND_EXTRARANGE)

	log_combat(spy, stealing, "stole", parent, "(spy bounty)")
	log_game("[key_name(spy)] completed the spy bounty [bounty.name] of difficulty [bounty.difficulty] by stealing [stealing] for \a [reward].")

	var/datum/antagonist/spy/spy_datum = spy_ref?.resolve()
	if(!isnull(spy_datum))
		spy_datum.bounties_claimed += 1
		spy_datum.all_loot += bounty.reward_item.name

	return TRUE

/datum/component/spy_uplink/ui_state(mob/user)
	return GLOB.always_state

/datum/component/spy_uplink/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "SpyUplink")
		ui.open()
		ui.set_autoupdate(TRUE)

/datum/component/spy_uplink/ui_data(mob/user)
	var/list/data = list()

	data["bounties"] = list()
	for(var/datum/spy_bounty/bounty as anything in handler.get_all_bounties())
		UNTYPED_LIST_ADD(data["bounties"], bounty.to_ui_data(user))
	data["time_left"] = timeleft(handler.refresh_timer)

	return data

/obj/effect/spy_scan_effect
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	anchored = TRUE
	layer = ABOVE_ALL_MOB_LAYER

/obj/effect/spy_scan_effect/cone
	name = "holopromień"
	icon = 'aquila/icons/effects/spy_scan.dmi'
	icon_state = "scan_beam"
	color = "#3ba0ff"
	alpha = 200
