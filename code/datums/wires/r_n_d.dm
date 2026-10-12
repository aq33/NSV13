/datum/wires/rnd
	holder_type = /obj/machinery/rnd
	randomize = TRUE

/datum/wires/rnd/New(atom/holder)
	wires = list(
		WIRE_HACK, WIRE_DISABLE,
		WIRE_SHOCK
	)
	add_duds(5)
	..()

/datum/wires/rnd/interactable(mob/user)
	var/obj/machinery/rnd/R = holder
	if(R.panel_open)
		return TRUE

/datum/wires/rnd/get_status()
	var/obj/machinery/rnd/R = holder
	var/list/status = list()
	status += "Czerwona lampka [R.disabled ? "jest zgaszona" : "świeci się"]."
	status += "Niebieska lampka [R.hacked ? "jest zgaszona" : "świeci się"]."
	return status

/datum/wires/rnd/on_pulse(wire)
	set waitfor = FALSE
	var/obj/machinery/rnd/R = holder
	switch(wire)
		if(WIRE_HACK)
			R.hacked = !R.hacked
		if(WIRE_DISABLE)
			R.disabled = !R.disabled
	ui_update()
/datum/wires/rnd/on_cut(wire, mend)
	var/obj/machinery/rnd/R = holder
	switch(wire)
		if(WIRE_HACK)
			R.hacked = !mend
		if(WIRE_DISABLE)
			R.disabled = !mend
	ui_update()
