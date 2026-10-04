/// Response team request sent from the communications console (aquila/code/game/machinery/computer/communications.dm)
/proc/ert_request(text, mob/sender)
	var/msg = copytext_char(sanitize(text), 1, MAX_MESSAGE_LEN)
	GLOB.requests.ert_request(sender.client, msg)
	msg = "<span class='adminnotice'><b><font color=orange>RESPONSE TEAM REQUEST:</font>[ADMIN_FULLMONTY(sender)] [ADMIN_CENTCOM_REPLY(sender)]:</b> [msg]</span>"
	to_chat(GLOB.admins, msg)
	for(var/obj/machinery/computer/communications/console in GLOB.machines)
		console.override_cooldown()
