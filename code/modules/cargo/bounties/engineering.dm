/datum/bounty/item/engineering/gas
	name = "Full Tank of Pluoxium"
	description = "Dział B+R Centrali bada wyjątkowo kompaktowe butle z powietrzem. Wyślijcie butlę pełną pluoksium, a otrzymacie rekompensatę."
	reward = 7500
	wanted_types = list(/obj/item/tank)
	var/moles_required = 20 // A full tank is 28 moles, but CentCom ignores that fact.
	var/gas_type = GAS_PLUOXIUM

/datum/bounty/item/engineering/gas/applies_to(obj/O)
	if(!..())
		return FALSE
	var/obj/item/tank/T = O
	return T.air_contents.get_moles(gas_type) >= moles_required

/datum/bounty/item/engineering/gas/nitryl_tank
	name = "Full Tank of Nitryl"
	description = "Nieludzki personel Stacji 88 zgłoszono na ochotnika do testów środków dopingujących. Wyślijcie im butlę pełną nitrylu, by mogli zacząć."
	gas_type = GAS_NITRYL

/datum/bounty/item/engineering/gas/tritium_tank
	name = "Full Tank of Tritium"
	description = "Stacja 49 chce rozkręcić swój program badawczy. Wyślijcie im butlę pełną trytu."
	gas_type = GAS_TRITIUM

/datum/bounty/item/engineering/energy_ball
	name = "Contained Tesla Ball"
	description = "Stację 24 zalewają hordy rozwścieczonych ludzi-ćm. Proszą o najlepszą packę na owady."
	reward = 75000 //requires 14k credits of purchases, not to mention cooperation with engineering/heads of staff to set up inside the cramped shuttle
	wanted_types = list(/obj/anomaly/energy_ball)
