/obj/machinery/portable_atmospherics/canister/ui_act(action, params)
	var/was_open = valve_open
	. = ..()
	if(valve_open != was_open)
		playsound(src, 'aquila/sound/effects/valve_opening.ogg', 50)

/// Dragging a canister scrapes the floor
/obj/machinery/portable_atmospherics/canister/Moved(atom/OldLoc, Dir, Forced)
	. = ..()
	if(!Forced && isturf(loc) && has_gravity())
		playsound(src, 'aquila/sound/effects/canister_drag.ogg', 40, TRUE, -3)
