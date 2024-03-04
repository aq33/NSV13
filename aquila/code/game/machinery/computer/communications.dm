/obj/machinery/computer/communications
	/// Cooldown before you can call in an ERT or wave of assistants
	COOLDOWN_DECLARE(static/reinforcement_action_cooldown)

/obj/machinery/computer/communications/proc/authenticated_as_cap_sec_or_silicon(mob/user)
	if (issilicon(user))
		return TRUE
	return (ACCESS_CAPTAIN in authorize_access) || (ACCESS_HOS in authorize_access)

/obj/machinery/computer/communications/ui_act(action, list/params)
	. = ..()
	if (.)
		return

	switch(action)
		if("requestERT")
			if (!authenticated_as_cap_sec_or_silicon(usr))
				return
			if (!COOLDOWN_FINISHED(src, reinforcement_action_cooldown))
				return
			var/reason = trim(html_encode(params["reason"]), MAX_MESSAGE_LEN)
			ert_request(reason, usr)
			to_chat(usr, "<span class='notice'>Request sent.</span>")
			usr.log_message("has requested an emergency response team from Centcom with reason \"[reason]\"", LOG_SAY)
			priority_announce("An Emergency Response Team has been requested by [usr]. Confirmation or denial of this request will be sent shortly.", "Emergency Response Team Requested", SSstation.announcer.get_rand_report_sound())
			playsound(src, 'sound/machines/terminal_prompt.ogg', 50, FALSE)
			COOLDOWN_START(src, reinforcement_action_cooldown, 15 MINUTES)
			. = TRUE
