#define DISCONNECTED 0
#define CLAMPED_OFF 1
#define OPERATING 2

GLOBAL_VAR_INIT(powersink_transmitted, 0)

// Called by /obj/item/powersink/process() (core) after every drain tick while attached to a powernet.
// If the powernet could not supply the full drain_rate, drains the cells of APCs on the powernet instead.
/obj/item/powersink/proc/on_drain(drained)
	var/datum/powernet/PN = attached.powernet
	if(drained < drain_rate)
		for(var/obj/machinery/power/terminal/T in PN.nodes)
			if(istype(T.master, /obj/machinery/power/apc))
				var/obj/machinery/power/apc/A = T.master
				if(A.operating && A.cell)
					A.cell.charge = max(0, A.cell.charge - 50)
					power_drained += 50
					if(A.charging == 2) // If the cell was full
						A.charging = 1 // It's no longer full



/obj/item/powersink/infiltrator
	var/target
	var/target_reached = FALSE
	var/obj/item/radio/alert_radio

/obj/item/powersink/infiltrator/Initialize()
	. = ..()
	alert_radio = new(src)
	alert_radio.make_syndie()
	alert_radio.listening = FALSE
	alert_radio.canhear_range = 0

/obj/item/powersink/infiltrator/on_drain(drained)
	GLOB.powersink_transmitted += drained
	if(target && GLOB.powersink_transmitted >= target && !target_reached)
		alert_radio.talk_into(src, "Power objective reached.", RADIO_CHANNEL_SYNDICATE)
		visible_message("<span class='notice'>[src] beeps.</span>")
		playsound(src, 'sound/machines/ping.ogg', 50, 1)
		target_reached = TRUE
		set_mode(CLAMPED_OFF)
	return ..()


#undef DISCONNECTED
#undef CLAMPED_OFF
#undef OPERATING
