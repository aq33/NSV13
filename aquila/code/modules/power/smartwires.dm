// Smartwires (port BeeStation/BeeStation-Hornet#14275).
// NSV13 machines that draw power straight from the cable under them (turf.get_cable_node())
// are not /obj/machinery/power, so they need a forced power node on the cable they are mapped on.
// Without it a cable running through their tile would not count as a node and they would lose power.

WANTS_POWER_NODE(/obj/machinery/armour_plating_nanorepair_well)
WANTS_POWER_NODE(/obj/machinery/atmospherics/components/binary/drive_pylon)
WANTS_POWER_NODE(/obj/machinery/atmospherics/components/binary/stormdrive_reactor)
WANTS_POWER_NODE(/obj/machinery/atmospherics/components/trinary/defence_screen_reactor)
WANTS_POWER_NODE(/obj/machinery/atmospherics/components/trinary/nuclear_reactor)
WANTS_POWER_NODE(/obj/machinery/atmospherics/miner)
WANTS_POWER_NODE(/obj/machinery/inertial_dampener)
WANTS_POWER_NODE(/obj/machinery/railgun_charger)
WANTS_POWER_NODE(/obj/machinery/shield_generator)
WANTS_POWER_NODE(/obj/machinery/ship_weapon/energy)
WANTS_POWER_NODE(/obj/machinery/ship_weapon/hybrid_rail)

/// Hum of a cable going between decks
/datum/looping_sound/transformer
	mid_sounds = list('aquila/sound/machines/transformer.ogg' = 1)
	mid_length = 0.9 SECONDS
	volume = 100
