// Spy-only bounty rewards (port of tgstation code/modules/uplink/uplink_items/spy_unique.dm), only the items we have

/// Uplink items that unlock as spy rewards once this one has been given out, e.g. ammo for a gun
/datum/uplink_item/var/list/relevant_child_items

// This is solely for uplink items that the spy can randomly obtain via bounties.
/datum/uplink_item/spy_unique
	category = "Spy Unique"
	cant_discount = TRUE
	surplus = 0
	purchasable_from = UPLINK_SPY
	purchase_log_vis = FALSE
	// Cost doesn't really matter since it's free, but it determines which loot pool it falls into.
	// By default, these fall into easy-medium spy bounty loot pool
	cost = SPY_LOWER_COST_THRESHOLD

/datum/uplink_item/spy_unique/megaphone
	name = "Megafon"
	desc = "Megafon. Jest głośny."
	item = /obj/item/megaphone
	cost = 1

/datum/uplink_item/spy_unique/combat_gloves
	name = "Rękawice bojowe"
	desc = "Para rękawic bojowych. Są izolowane!"
	item = /obj/item/clothing/gloves/combat
	cost = 1

/datum/uplink_item/spy_unique/krav_maga
	name = "Rękawice bojowe plus"
	desc = "Para rękawic bojowych plus. Są izolowane I pozwalają walczyć w stylu Krav Maga!"
	item = /obj/item/clothing/gloves/krav_maga/combatglovesplus

/datum/uplink_item/spy_unique/kudzu
	name = "Kudzu"
	desc = "Paczka nasion kudzu. Posadź i zapomnij, świetnie odwraca uwagę."
	item = /obj/item/seeds/kudzu

/datum/uplink_item/spy_unique/big_knife
	name = "Nóż bojowy"
	desc = "Duży nóż. Jest ostry."
	item = /obj/item/kitchen/knife/combat

/datum/uplink_item/spy_unique/switchblade
	name = "Nóż sprężynowy"
	desc = "Nóż sprężynowy. Przełącza się między nieostrym a ostrym."
	item = /obj/item/switchblade

/datum/uplink_item/spy_unique/rifle_prime
	name = "Karabin powtarzalny"
	desc = "Karabin z zamkiem czterotaktowym. Nie zatnie się."
	item = /obj/item/gun/ballistic/rifle/boltaction
	cost = SPY_UPPER_COST_THRESHOLD
	relevant_child_items = list(
		/datum/uplink_item/spy_unique/rifle_ammo,
	)

/datum/uplink_item/spy_unique/rifle_ammo
	name = "Łódka nabojów do karabinu"
	desc = "Łódka do szybkiego ładowania karabinu powtarzalnego. Pięć naboi."
	item = /obj/item/ammo_box/a762
	cost = 1

/datum/uplink_item/spy_unique/cycler_shotgun
	name = "Strzelba dwulufowa z cyklerem"
	desc = "Strzelba, która przełącza się między dwoma magazynkami rurowymi."
	item = /obj/item/gun/ballistic/shotgun/automatic/dual_tube
	cost = SPY_UPPER_COST_THRESHOLD
	relevant_child_items = list(
		/datum/uplink_item/spy_unique/shotgun_ammo,
		/datum/uplink_item/spy_unique/shotgun_ammo/breacher_slug,
	)

/datum/uplink_item/spy_unique/bulldog_shotgun
	name = "Strzelba Bulldog"
	desc = "Strzelba Bulldog. Strzela buldogami."
	item = /obj/item/gun/ballistic/shotgun/bulldog/unrestricted
	cost = SPY_UPPER_COST_THRESHOLD
	relevant_child_items = list(
		/datum/uplink_item/spy_unique/shotgun_ammo,
		/datum/uplink_item/spy_unique/shotgun_ammo/breacher_slug,
	)

/datum/uplink_item/spy_unique/makarov_pistol
	name = "Pistolet Makarowa"
	desc = "Pistolet Makarowa. Niezawodny i solidny."
	item = /obj/item/gun/ballistic/automatic/pistol
	cost = SPY_LOWER_COST_THRESHOLD
	relevant_child_items = list(
		/datum/uplink_item/ammo/pistol,
		/datum/uplink_item/ammo/pistolap,
		/datum/uplink_item/ammo/pistolhp,
		/datum/uplink_item/ammo/pistolfire,
	)

/datum/uplink_item/spy_unique/rocket_launcher
	name = "Wyrzutnia rakiet"
	desc = "Wyrzutnia rakiet. Nie polecam z nią skakać."
	item = /obj/item/gun/ballistic/rocketlauncher
	cost = SPY_UPPER_COST_THRESHOLD - 1 // It's a meme item

/datum/uplink_item/spy_unique/shotgun_ammo
	name = "Pudełko śrutu"
	desc = "Pudełko nabojów śrutowych do strzelby. Kiedy nie chcesz chybić."
	item = /obj/item/storage/box/lethalshot
	cost = 1

/datum/uplink_item/spy_unique/shotgun_ammo/breacher_slug
	name = "Pudełko pocisków wyważających"
	desc = "Pudełko pocisków wyważających do strzelby. Na dobre pierwsze wrażenie."
	item = /obj/item/storage/box/breacherslug

/datum/uplink_item/spy_unique/stealth_belt
	name = "Pas maskujący"
	desc = "Pas maskujący, z którym przemkniesz za linie wroga."
	item = /obj/item/shadowcloak
	cost = SPY_UPPER_COST_THRESHOLD

/datum/uplink_item/spy_unique/katana
	name = "Katana"
	desc = "Naprawdę ostra katana. Wspominałem, że jest ostra?"
	item = /obj/item/katana
	cost = SPY_UPPER_COST_THRESHOLD

/datum/uplink_item/spy_unique/antistun
	name = "Autochirurg z implantem CNS Rebooter"
	desc = "Jednorazowy autochirurg z implantem, który szybciej stawia cię na nogi po ogłuszeniu."
	item = /obj/item/autosurgeon/syndicate/anti_stun

/datum/uplink_item/spy_unique/reviver
	name = "Autochirurg z implantem reanimującym"
	desc = "Jednorazowy autochirurg z implantem, który leczy cię i próbuje ocucić, gdy stracisz przytomność."
	item = /obj/item/autosurgeon/syndicate/reviver

/datum/uplink_item/spy_unique/thermals
	name = "Autochirurg z oczami termowizyjnymi"
	desc = "Jednorazowy autochirurg z cybernetycznymi oczami, które widzą ciepło przez ściany."
	item = /obj/item/autosurgeon/syndicate/thermal_eyes
