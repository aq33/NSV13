
/datum/export/large/battery
	cost = 100
	unit_name = "bateria"
	message = "Podatki nie uwzględnione."
	export_types = list(/obj/machinery/power/battery)

/datum/export/large/battery/get_cost(obj/O)
	var/obj/machinery/power/battery/B = O
	var/worth = B.charge
	return worth

