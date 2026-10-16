/obj/machinery/netpod/Exited(atom/movable/gone, direction)
	. = ..()
	if(!state_open && gone == occupant)
		container_resist(gone)


/obj/machinery/netpod/relaymove(mob/living/user, direction)
	if(!state_open)
		container_resist(user)


/obj/machinery/netpod/container_resist(mob/living/user)
	if(state_open)
		return
	if(exiling)
		to_chat(user, span_warning("Kapsuła jest zablokowana! Nie możesz się wydostać!"))
		return
	user.visible_message(span_notice("[occupant] wychodzi z [src]!"),
		span_notice("Wychodzisz z [src]!"),
		span_notice("Z sykiem otwiera się jakaś maszyna."))
	open_machine()


/obj/machinery/netpod/open_machine(drop = TRUE)
	playsound(src, 'sound/machines/click.ogg', 60, TRUE, frequency = 65000)
	flick("[base_icon_state]_opening", src)
	SEND_SIGNAL(src, COMSIG_BITRUNNER_NETPOD_OPENED)
	use_power = IDLE_POWER_USE
	return ..()


/obj/machinery/netpod/close_machine(mob/user)
	if(!state_open || panel_open || !is_operational || !iscarbon(user))
		return

	playsound(src, 'sound/machines/click.ogg', 60, TRUE, frequency = 65000)
	flick("[base_icon_state]_closing", src)
	..()

	INVOKE_ASYNC(src, PROC_REF(enter_matrix))


/// Prying the netpod open. Returns TRUE if handled.
/obj/machinery/netpod/proc/pry_open(mob/living/user, obj/item/crowbar)
	if(!iscarbon(occupant))
		if(!state_open)
			if(panel_open)
				return default_deconstruction_crowbar(crowbar)
			open_machine()
		else
			shut_pod()

		return TRUE

	user.visible_message(
		span_danger("[user] zaczyna podważać [src]!"),
		span_notice("Zaczynasz podważać [src]."),
		span_notice("Słyszysz głośne podważanie metalu.")
	)
	playsound(src, 'sound/machines/airlock_alien_prying.ogg', 100, TRUE)

	SEND_SIGNAL(src, COMSIG_BITRUNNER_CROWBAR_ALERT, user)

	if(crowbar.use_tool(src, user, 15 SECONDS, volume = 50))
		if(!state_open)
			sever_connection()
			open_machine()

	return TRUE


/// Closes the machine without shoving in an occupant
/obj/machinery/netpod/proc/shut_pod()
	state_open = FALSE
	playsound(src, 'sound/machines/click.ogg', 60, TRUE, frequency = 65000)
	flick("[base_icon_state]_closing", src)
	density = TRUE

	update_appearance()


/obj/machinery/netpod/attackby(obj/item/tool, mob/living/user, params)
	if(tool.tool_behaviour == TOOL_CROWBAR)
		if(user.a_intent == INTENT_HARM && occupant)
			return ..()
		pry_open(user, tool)
		return TRUE

	if(tool.tool_behaviour == TOOL_SCREWDRIVER)
		if(occupant)
			balloon_alert(user, "w użyciu!")
			return TRUE

		if(state_open)
			balloon_alert(user, "najpierw zamknij!")
			return TRUE

		if(default_deconstruction_screwdriver(user, "[base_icon_state]_panel", "[base_icon_state]_closed", tool))
			return TRUE

	return ..()


/// Machine has been broken - handles signals and reverting sprites
/obj/machinery/netpod/proc/on_broken(datum/source)
	SIGNAL_HANDLER

	sever_connection()


/obj/machinery/netpod/on_set_is_operational(old_value)
	. = ..()
	if(is_operational)
		return
	// Power loss / breakage
	if(state_open)
		return

	if(isnull(occupant) || !connected)
		connected = FALSE
		open_machine()
		return

	sever_connection()


/// Checks the integrity, alerts occupants
/obj/machinery/netpod/take_damage(damage_amount, damage_type, damage_flag, sound_effect, attack_dir, armour_penetration)
	. = ..()
	if(isnull(occupant) || !connected || QDELETED(src))
		return

	if((obj_integrity / max_integrity) * 100 > 50)
		return

	SEND_SIGNAL(src, COMSIG_BITRUNNER_NETPOD_INTEGRITY)


/// Puts points on the current occupant's card account
/obj/machinery/netpod/proc/on_domain_complete(datum/source, atom/movable/crate, reward_points)
	SIGNAL_HANDLER

	if(isnull(occupant) || !connected)
		return

	var/mob/living/carbon/human/player = occupant
	if(!istype(player))
		return

	var/datum/bank_account/account = player.get_bank_account()
	if(isnull(account))
		return

	account.bitrunning_points += reward_points * 100


/// The domain has been fully purged, so we should double check our avatar is deleted
/obj/machinery/netpod/proc/on_domain_scrubbed(datum/source)
	SIGNAL_HANDLER

	var/mob/avatar = avatar_ref?.resolve()
	if(isnull(avatar))
		return

	avatar_ref = null
	qdel(avatar)


/// Creates a list of outfit entries for the UI.
/obj/machinery/netpod/proc/make_outfit_collection(identifier, list/outfit_list)
	var/list/collection = list(
		"name" = identifier,
		"outfits" = list()
	)

	for(var/datum/outfit/outfit as anything in outfit_list)
		var/outfit_name = initial(outfit.name)
		if(findtext(outfit_name, "(") != 0 || findtext(outfit_name, "-") != 0) // No special variants please
			continue

		collection["outfits"] += list(list("path" = "[outfit]", "name" = outfit_name))

	return list(collection)


/// Resolves a path to an outfit.
/obj/machinery/netpod/proc/resolve_outfit(text)
	var/path = text2path(text)
	if(!ispath(path, /datum/outfit))
		return

	for(var/list/wardrobe as anything in cached_outfits)
		for(var/list/outfit as anything in wardrobe["outfits"])
			if("[path]" == outfit["path"])
				return path

	message_admins("[key_name_admin(usr)] próbował wybrać niedostępny strój w netpodzie")
	return


/obj/machinery/netpod/ui_interact(mob/user, datum/tgui/ui)
	if(!is_operational || occupant)
		return

	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "NetpodOutfits")
		ui.set_autoupdate(FALSE)
		ui.open()


/obj/machinery/netpod/ui_data()
	var/list/data = list()

	data["netsuit"] = "[netsuit]"
	return data


/obj/machinery/netpod/ui_static_data()
	var/list/data = list()

	if(!length(cached_outfits))
		cached_outfits += make_outfit_collection("Zawody", subtypesof(/datum/outfit/job))

	data["collections"] = cached_outfits

	return data


/obj/machinery/netpod/ui_act(action, list/params)
	. = ..()
	if(.)
		return TRUE
	switch(action)
		if("select_outfit")
			var/datum/outfit/new_suit = resolve_outfit(params["outfit"])
			if(new_suit)
				netsuit = new_suit
				return TRUE

	return FALSE


/obj/machinery/netpod/ui_status(mob/user)
	return panel_open ? UI_CLOSE : ..()
