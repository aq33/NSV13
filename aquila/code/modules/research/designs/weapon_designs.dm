/*********************************\
|*********** LASER GUNS **********|
\*********************************/
/datum/design/oldlasergun
	name = "Prototype Laser Gun"
	desc = "First generation laser, high powered laser pointer."
	id = "firstgenlasergun"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 15000, /datum/material/glass = 10000, /datum/material/silver = 10000, /datum/material/copper = 10000)
	category = list("Weapons")
	departmental_flags = DEPARTMENTAL_FLAG_SECURITY
	build_path = /obj/item/gun/energy/laser/retro/old/research

/datum/design/lasergun
	name = "Laser Gun"
	desc = "Standardized high powered laser pointer."
	id = "lasergun"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 10000, /datum/material/glass = 10000, /datum/material/silver = 5000, /datum/material/copper = 5000)
	category = list("Weapons")
	departmental_flags = DEPARTMENTAL_FLAG_SECURITY
	build_path = /obj/item/gun/energy/laser/research

/datum/design/lasercannon
	name = "Laser Cannon"
	desc = "Third generation laser gun, not only it focuses and refracts light, beam also gains kinetic energy with travel time!"
	id = "lasercannon"
	build_type = PROTOLATHE
	materials = list(/datum/material/titanium = 10000, /datum/material/glass = 10000, /datum/material/silver = 10000, /datum/material/gold = 5000)
	category = list("Weapons")
	departmental_flags = DEPARTMENTAL_FLAG_SECURITY
	build_path = /obj/item/gun/energy/lasercannon/research

/*********************************\
|*********** ENERGY GUNS **********|
\*********************************/
//egun taki drogi by nie zastąpił normalnej broni oraz nie dał tak łatwo dostępu do tasera
/datum/design/oldenergygun
	name = "Prototype Energy Gun"
	desc = "First attempt at creating hybrid weapon."
	id = "firstgenegun"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 20000, /datum/material/glass = 15000, /datum/material/silver = 10000, /datum/material/gold = 5000)
	category = list("Weapons")
	departmental_flags = DEPARTMENTAL_FLAG_SECURITY
	build_path = /obj/item/gun/energy/e_gun/old/research

/datum/design/energygun
	name = "Energy Gun"
	desc = "Standardized pattern that uses lower frequency for stun mode that is more power efficient."
	id = "energy_gun"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 10000, /datum/material/glass = 10000, /datum/material/silver = 5000, /datum/material/gold = 5000)
	category = list("Weapons")
	departmental_flags = DEPARTMENTAL_FLAG_SECURITY
	build_path = /obj/item/gun/energy/e_gun/research

/datum/design/tacticalegun
	name = "Tactical Energy Gun"
	desc = "Military grade beam weapon designed for tactical operations."
	id = "tacticalegun"
	build_type = PROTOLATHE
	materials = list(/datum/material/titanium = 5000, /datum/material/glass = 10000, /datum/material/silver = 5000, /datum/material/gold = 5000)
	category = list("Weapons")
	departmental_flags = DEPARTMENTAL_FLAG_SECURITY
	build_path = /obj/item/gun/energy/e_gun/stun/research

/*********************************\
|*********** PULSE GUNS ***********|
\*********************************/
//i tak nie jest używany oprócz DS raz na nigdy, też nie będzie taki tani by nie było za dobrze
/datum/design/pulsegun
	name = "Pulse Weapon"
	desc = "Ultimate energy weapon, designed to kill, destroy and disable."
	id = "pulsegun"
	build_type = PROTOLATHE
	materials = list(/datum/material/titanium = 20000, /datum/material/diamond = 10000, /datum/material/silver = 10000, /datum/material/plasma = 10000)
	category = list("Weapons")
	departmental_flags = DEPARTMENTAL_FLAG_SECURITY
	build_path = /obj/item/gun/energy/pulse/research

/*********************************\
|*********** STUN GUNS ***********|
\*********************************/
/datum/design/disabler
	name = "Disabler"
	desc = "A self-defense weapon that exhausts organic targets, weakening them until they collapse."
	id = "disabler"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 10000, /datum/material/glass = 10000, /datum/material/silver = 5000)
	category = list("Weapons")
	departmental_flags = DEPARTMENTAL_FLAG_SECURITY
	build_path = /obj/item/gun/energy/disabler
