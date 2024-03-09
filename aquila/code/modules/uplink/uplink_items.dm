/datum/uplink_item
	var/surplus_nullcrates

/datum/uplink_item/New()
	. = ..()
	if(isnull(surplus_nullcrates))
		surplus_nullcrates = surplus

/datum/uplink_item/dangerous/guardian
	surplus_nullcrates = 0

/datum/uplink_item/stealthy_weapons/martialarts
	surplus_nullcrates = 0

/datum/uplink_item/device_tools/fakenucleardisk
	surplus_nullcrates = 0

/datum/uplink_item/bundles_TC/contract_kit
	purchasable_from = ~UPLINK_INFILTRATORS

/datum/uplink_item/bundles_TC/bundle_A
	purchasable_from = ~UPLINK_INFILTRATORS

/datum/uplink_item/bundles_TC/bundle_B
	purchasable_from = ~UPLINK_INFILTRATORS

/datum/uplink_item/bundles_TC/surplus
	purchasable_from = ~UPLINK_INFILTRATORS

/datum/uplink_item/dangerous/sword
	purchasable_from = ~UPLINK_INFILTRATORS

/datum/uplink_item/dangerous/bostaff
	purchasable_from = ~UPLINK_INFILTRATORS

/datum/uplink_item/dangerous/flamethrower
	purchasable_from = ~UPLINK_INFILTRATORS// Tu normalnie yoglodyci wypierdalają FOTNS (te z jojo) ale miotacz ognia zostawiają????

/datum/uplink_item/dangerous/guardian
	purchasable_from = ~UPLINK_INFILTRATORS

/datum/uplink_item/dangerous/doublesword
	purchasable_from = ~UPLINK_INFILTRATORS

/datum/uplink_item/dangerous/sword
	purchasable_from = ~UPLINK_INFILTRATORS

/datum/uplink_item/dangerous/rapid
	purchasable_from = ~UPLINK_INFILTRATORS

/datum/uplink_item/ammo/pistolfire
	purchasable_from = ~UPLINK_INFILTRATORS

/datum/uplink_item/explosives
	purchasable_from = ~UPLINK_INFILTRATORS

/datum/uplink_item/explosives/emp
	purchasable_from = ~UPLINK_INFILTRATORS
/datum/uplink_item/explosives/doorCharge
	purchasable_from = ~UPLINK_INFILTRATORS

/datum/uplink_item/explosives/virus_grenade
	purchasable_from = ~UPLINK_INFILTRATORS

/datum/uplink_item/explosives/bigducky
	purchasable_from = ~UPLINK_INFILTRATORS

/datum/uplink_item/device_tools/powersink
	purchasable_from = ~UPLINK_INFILTRATORS

/datum/uplink_item/device_tools/suspiciousphone
	purchasable_from = ~UPLINK_INFILTRATORS

/ Events
/datum/uplink_item/services
	category = "Services"
	surplus = 0
	restricted = TRUE
	purchasable_from = UPLINK_INFILTRATORS

/datum/uplink_item/services/manifest_spoof
	name = "Crew Manifest Spoof"
	desc = "A button capable of adding a single person to the crew manifest."
	item = /obj/item/service/manifest
	cost = 15 //Maybe this is too cheap??
	purchasable_from = UPLINK_INFILTRATORS

/datum/uplink_item/services/fake_ion
	name = "Fake Ion Storm"
	desc = "Fakes an ion storm announcment. A good distraction, especially if the AI is weird anyway."
	item = /obj/item/service/ion
	cost = 7
	purchasable_from = UPLINK_INFILTRATORS

/datum/uplink_item/services/fake_meteor
	name = "Fake Meteor Announcement"
	desc = "Fakes an meteor announcment. A good way to get any C4 on the station exterior, or really any small explosion, brushed off as a meteor hit."
	item = /obj/item/service/meteor
	cost = 7
	purchasable_from = UPLINK_INFILTRATORS

/datum/uplink_item/services/fake_rod
	name = "Fake Immovable Rod"
	desc = "Fakes an immovable rod announcement. Good for a short-lasting distraction."
	item = /obj/item/service/rodgod
	cost = 6 //less likely to be believed
	purchasable_from = UPLINK_INFILTRATORS

//Infiltrator shit
/datum/uplink_item/infiltration
	category = "Infiltration Gear"
	purchasable_from = UPLINK_INFILTRATORS
	surplus = 0

/datum/uplink_item/infiltration/extra_stealthsuit
	name = "Extra Chameleon Hardsuit"
	desc = "An infiltration hardsuit, capable of changing it's appearance instantly."
	item = /obj/item/clothing/suit/space/hardsuit/infiltration
	cost = 10
	purchasable_from = UPLINK_INFILTRATORS
