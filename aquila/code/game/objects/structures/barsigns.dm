/datum/barsign
	var/icon_file = 'icons/obj/barsigns.dmi'

/obj/structure/sign/barsign/set_sign(datum/barsign/sign)
	if(!istype(sign))
		return
	icon = sign.icon_file
	..()

/datum/barsign/podpapugami
	name = "Pod Papugami"
	icon = "podpapugami"
	icon_file = 'aquila/icons/obj/barsigns.dmi'
	desc = "Szeroko niklowany bar, gdzie nad szklaneczkami chorągiewką żółtą świeci skwar."

/datum/barsign/wadovice
	name = "Wado Vice"
	icon = "wadovice"
	icon_file = 'aquila/icons/obj/barsigns.dmi'
	desc = "Wyrusz wyścigową barką w stronę zachodzącego słońca."

/datum/barsign/alkohole
	name = "Alko Hole"
	icon = "alkohole"
	icon_file = 'aquila/icons/obj/barsigns.dmi'
	desc = "Osobliwy bar, którego trunki mogą zrodzić dziurę w pamięci."

/datum/barsign/ranczo
	name = "Baranie Ranczo"
	icon = "ranczo"
	icon_file = 'aquila/icons/obj/barsigns.dmi'
	desc = "Miejsce spotkań nagich kowbojów z dużymi i twardymi kogutami."
