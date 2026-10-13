// AQUILA - port BeeStation/BeeStation-Hornet#11415

/datum/outfit/centcom_intern/unarmed
	name = "CentCom Intern (Unarmed)"
	belt = null
	l_hand = null
	l_pocket = null
	r_pocket = null

/datum/outfit/centcom_intern/leader/unarmed // lider zachowuje pałkę i kamizelkę
	name = "CentCom Head Intern (Unarmed)"
	suit_store = null
	l_pocket = null
	r_pocket = null

/// Karta łowców nagród wynajętych przez CentCom
/obj/item/card/id/silver/spacepol/bounty/ert
	registered_name = "Bounty Hunter"
	assignment = "Bounty Hunter"
	icon_state = "ert"

/obj/item/card/id/silver/spacepol/bounty/ert/Initialize(mapload)
	. = ..()
	access = list(ACCESS_CENT_GENERAL)

/datum/outfit/bountyarmor/ert
	name = "Bounty Hunter - Armored (ERT)"
	id = /obj/item/card/id/silver/spacepol/bounty/ert

/datum/outfit/bountyhook/ert
	name = "Bounty Hunter - Hook (ERT)"
	id = /obj/item/card/id/silver/spacepol/bounty/ert

/datum/outfit/bountysynth/ert
	name = "Bounty Hunter - Synth (ERT)"
	id = /obj/item/card/id/silver/spacepol/bounty/ert
