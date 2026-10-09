/datum/uplink_item
	var/surplus_nullcrates
	/// If TRUE, UPLINK_INFILTRATORS is stripped from purchasable_from on top of whatever core sets (keeps the core restrictions intact)
	var/exclude_infiltrators = FALSE

/datum/uplink_item/New()
	. = ..()
	if(isnull(surplus_nullcrates))
		surplus_nullcrates = surplus
	if(exclude_infiltrators)
		purchasable_from &= ~UPLINK_INFILTRATORS

/datum/uplink_item/dangerous/guardian
	surplus_nullcrates = 0

/datum/uplink_item/stealthy_weapons/martialarts
	surplus_nullcrates = 0

/datum/uplink_item/device_tools/fakenucleardisk
	surplus_nullcrates = 0

// Infiltratorzy nie dostają "murderbone" przedmiotów
/datum/uplink_item/bundles_TC/contract_kit
	exclude_infiltrators = TRUE

/datum/uplink_item/bundles_TC/bundle_A
	exclude_infiltrators = TRUE

/datum/uplink_item/bundles_TC/bundle_B
	exclude_infiltrators = TRUE

/datum/uplink_item/bundles_TC/surplus
	exclude_infiltrators = TRUE

/datum/uplink_item/dangerous/sword
	exclude_infiltrators = TRUE

/datum/uplink_item/dangerous/doublesword
	exclude_infiltrators = TRUE

/datum/uplink_item/dangerous/bostaff
	exclude_infiltrators = TRUE

/datum/uplink_item/dangerous/guardian
	exclude_infiltrators = TRUE

/datum/uplink_item/dangerous/rapid
	exclude_infiltrators = TRUE

/datum/uplink_item/dangerous/powerfist
	exclude_infiltrators = TRUE

/datum/uplink_item/ammo/pistolfire
	exclude_infiltrators = TRUE

/datum/uplink_item/stealthy_weapons/dehy_carp
	exclude_infiltrators = TRUE

/datum/uplink_item/stealthy_weapons/martialarts
	exclude_infiltrators = TRUE

/datum/uplink_item/stealthy_weapons/romerol_kit
	exclude_infiltrators = TRUE

/datum/uplink_item/explosives
	exclude_infiltrators = TRUE

/datum/uplink_item/suits/space_suit
	exclude_infiltrators = TRUE

/datum/uplink_item/suits/hardsuit
	exclude_infiltrators = TRUE

/datum/uplink_item/device_tools/failsafe
	exclude_infiltrators = TRUE

/datum/uplink_item/device_tools/hacked_module
	exclude_infiltrators = TRUE

/datum/uplink_item/device_tools/powersink
	exclude_infiltrators = TRUE

/datum/uplink_item/device_tools/suspiciousphone
	exclude_infiltrators = TRUE

// Events
/datum/uplink_item/services
	category = "Services"
	surplus = 0
	restricted = TRUE
	purchasable_from = UPLINK_INFILTRATORS

/datum/uplink_item/services/manifest_spoof
	name = "Crew Manifest Spoof"
	desc = "A button capable of adding a single person to the crew manifest."
	item = /obj/item/service/manifest
	cost = 4
	limited_stock = 1

/datum/uplink_item/services/fake_ion
	name = "Fake Ion Storm"
	desc = "Fakes an ion storm announcment. A good distraction, especially if the AI is weird anyway."
	item = /obj/item/service/ion
	cost = 7

/datum/uplink_item/services/fake_meteor
	name = "Fake Meteor Announcement"
	desc = "Fakes an meteor announcment. A good way to get any C4 on the station exterior, or really any small explosion, brushed off as a meteor hit."
	item = /obj/item/service/meteor
	cost = 7

/datum/uplink_item/services/fake_rod
	name = "Fake Immovable Rod"
	desc = "Fakes an immovable rod announcement. Good for a short-lasting distraction."
	item = /obj/item/service/rodgod
	cost = 6 //less likely to be believed

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

/datum/uplink_item/infiltration/access_kit
	name = "Access Kit"
	desc = "A secret device, reverse engineered by gear retrieved from previous Nanotrasen infiltration missions. Allows you to spoof an ID card to have the assignment and access of a single low-level job."
	item = /obj/item/access_kit/syndicate
	limited_stock = 1
	cost = 5

/datum/uplink_item/dangerous/gremlin
	name = "Gremlin Delivery Grenade"
	desc = "This grenade is filled with several gremlins. They won't hurt anyone, but they love tampering with machinery: airlocks, APCs, the engine... Water makes them multiply. Fun for RnD and engineering!"
	item = /obj/item/grenade/spawnergrenade/gremlin
	cost = 2
	surplus = 30

// AQUILA - Eldritch Horror for curators (Yogstation#13033, price from Yogstation#19619)
/datum/uplink_item/role_restricted/horror
	name = "Horror w pudełku"
	desc = "Podczas sekcji głowy martwego naukowca Nanotrasenu nasi chirurdzy znaleźli w środku niezwykle osobliwe stworzenie i zdołali bezpiecznie je wydobyć. \
	Nieudany eksperyment czy pozaziemski potwór, to stworzenie zostało wyszkolone, by pomagać temu, kto je obudzi. Jeśli nie boisz się, że wejdzie ci do głowy, może okazać się przydatnym sojusznikiem. \
	Nie bierzemy odpowiedzialności za twoje nowo nabyte szaleństwo i nie przyjmujemy zwrotów."
	item = /obj/item/horrorspawner
	cost = 14
	surplus = 0
	restricted_roles = list(JOB_NAME_CURATOR)
	player_minimum = 20
