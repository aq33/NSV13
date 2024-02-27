
/datum/export/large/battery
	cost = 100
	unit_name = "bateria"
	message = "Podatki nie uwzględnione."
	export_types = list(/obj/machinery/power/battery)

/datum/export/large/battery/get_cost(obj/O)
	var/obj/machinery/power/battery/B = O
	var/worth = B.charge
	return worth

/datum/export/large/am_control_unit
	cost = 4000
	unit_name = "antimatter control unit"
	export_types = list(/obj/machinery/power/am_control_unit)

/datum/export/large/am_shielding_container
	cost = 150
	unit_name = "packaged antimatter reactor section"
	export_types = list(/obj/item/am_shielding_container)

