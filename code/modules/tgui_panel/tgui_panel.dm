/**
 * Copyright (c) 2020 Aleksej Komarov
 * SPDX-License-Identifier: MIT
 */

/**
 * tgui_panel datum
 * Hosts tgchat and other nice features.
 */
/datum/tgui_panel
	var/client/client
	var/datum/tgui_window/window
	var/broken = FALSE
	var/initialized_at
	/// TRUE once the client answered a request sent after "ready", meaning the panel really works
	var/round_trip_ok = FALSE
	/// How many times we reloaded the panel on our own after a failed load
	var/auto_reloads = 0

/datum/tgui_panel/New(client/client, id)
	src.client = client
	window = new(client, id)
	window.subscribe(src, PROC_REF(on_message))

/datum/tgui_panel/Del()
	window.unsubscribe(src)
	window.close()
	return ..()

/**
 * public
 *
 * TRUE if panel is initialized and ready to receive messages.
 */
/datum/tgui_panel/proc/is_ready()
	return !broken && window.is_ready()

/**
 * public
 *
 * Initializes tgui panel.
 */
/datum/tgui_panel/proc/Initialize(force = FALSE)
	set waitfor = FALSE
	// Minimal sleep to defer initialization to after client constructor
	sleep(1)
	initialized_at = world.time
	round_trip_ok = FALSE
	if(force)
		auto_reloads = 0
	// Perform a clean initialization
	window.initialize(assets = list(
		strict_mode = TRUE,
		get_asset_datum(/datum/asset/simple/tgui_panel),
	))
	window.send_asset(get_asset_datum(/datum/asset/simple/namespaced/fontawesome))
	window.send_asset(get_asset_datum(/datum/asset/simple/namespaced/tgfont))
	window.send_asset(get_asset_datum(/datum/asset/spritesheet/chat))
	// Preload assets for /datum/tgui
	var/datum/asset/asset_tgui = get_asset_datum(/datum/asset/simple/tgui)
	var/flush_queue = asset_tgui.send(src.client)
	if(flush_queue)
		src.client.browse_queue_flush()
	// Other setup
	request_telemetry()
	// Send verbs
	set_verb_infomation(client)
	// TIMER_OVERRIDE so a reload restarts the countdown instead of stacking checks
	addtimer(CALLBACK(src, PROC_REF(on_initialize_timed_out)), 5 SECONDS, TIMER_UNIQUE|TIMER_OVERRIDE)

/**
 * private
 *
 * Called when initialization has timed out.
 */
/datum/tgui_panel/proc/on_initialize_timed_out()
	if(!client || round_trip_ok)
		return
	// Loading during server init often stalls (the server is too busy to answer the page),
	// and timers only fire once init is over, so a plain reload usually works now.
	if(auto_reloads < 2)
		auto_reloads++
		log_tgui("[client.ckey] fancy chat did not finish loading, reloading it (attempt [auto_reloads]).")
		Initialize()
		return
	SEND_TEXT(client, "<span class=\"userdanger\">Failed to load fancy chat, click <a href='?src=[REF(src)];reload_tguipanel=1'>HERE</a> to attempt to reload it.</span>")
	log_tgui("ERROR: [client?.ckey] failed to load their fancy chat after a 5 second timeout when loading.")
	SEND_TEXT(client, "<span class=\"warning\">If the problem persists after fix-chat, try restarting your game as Byond can get confused if the stylesheet it was expecting has changed. (If you have recently played on a server not using TGchat).</span>")

/**
 * private
 *
 * Callback for handling incoming tgui messages.
 */
/datum/tgui_panel/proc/on_message(type, payload)
	if(type == "ready")
		broken = FALSE
		window.send_message("update", list(
			"config" = list(
				"client" = list(
					"ckey" = client.ckey,
					"address" = client.address,
					"computer_id" = client.computer_id,
				),
				"window" = list(
					"fancy" = FALSE,
					"locked" = FALSE,
				),
			),
		))
		return TRUE
	if(type == "audio/setAdminMusicVolume")
		client.admin_music_volume = payload["volume"]
		return TRUE
	if(type == "telemetry")
		round_trip_ok = TRUE
		analyze_telemetry(payload)
		return TRUE
	if(cmptext(copytext(type, 1, 5), "stat"))
		return handle_stat_message(type, payload)

/**
 * public
 *
 * Sends a round restart notification.
 */
/datum/tgui_panel/proc/send_roundrestart()
	window.send_message("roundrestart")
