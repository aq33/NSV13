// Custom landing spot for shuttle consoles that fly without supercruise (custom built shuttles, the traitor bluespace pod).
// The console's menu link and Topic() hook are AQ EDIT lines in nsv13/code/modules/shuttle/computer.dm.

/obj/machinery/computer/shuttle_flight
	/// Can this console pick a custom landing spot with the docking eye (custom built shuttles, the traitor bluespace pod)
	var/allow_custom_landing = FALSE

/obj/machinery/computer/shuttle_flight/custom_shuttle
	allow_custom_landing = TRUE

/obj/machinery/computer/shuttle_flight/proc/designate_landing(mob/living/user)
	if(!isliving(user))
		return
	var/obj/docking_port/mobile/M = SSshuttle.getShuttle(shuttleId)
	if(!M)
		say("Unable to locate linked shuttle.")
		return
	if(M.mode == SHUTTLE_RECHARGING)
		to_chat(user, "<span class='warning'>Shuttle engines are not ready for use.</span>")
		return
	if(M.mode != SHUTTLE_IDLE)
		to_chat(user, "<span class='warning'>Shuttle already in transit.</span>")
		return
	if(!M.canMove())
		say("Warning: The shuttle's movement is being inhibited.")
		return
	if(current_user)
		to_chat(user, "<span class='warning'>Somebody is already docking the shuttle.</span>")
		return
	if(!can_designate_landing(user))
		return
	if(!shuttlePortId || findtext(shuttlePortId, "unlinked_shuttle_console_"))
		shuttlePortId = "[shuttleId]_custom"
	view_range = max(M.width, M.height, M.dwidth, M.dheight) * 0.5 - 4
	give_eye_control(user)

/// Extra checks before the docking eye is handed out, return FALSE to block
/obj/machinery/computer/shuttle_flight/proc/can_designate_landing(mob/living/user)
	return TRUE

/obj/machinery/computer/shuttle_flight/custom_shuttle/can_designate_landing(mob/living/user)
	calculateStats()
	if(calculated_acceleration < CUSTOM_SHUTTLE_MIN_THRUST_TO_WEIGHT)
		say("Insufficient engine power. Check the engines, heaters and plasma supply.")
		return FALSE
	return TRUE
