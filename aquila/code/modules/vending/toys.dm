// AQUILA - port aq33/tgstation#564: repliki ERT i chaingun na kulki w ofercie, zabawki Syndykatu w kontrabandzie
/obj/machinery/vending/donksofttoyvendor
	products = list(
		/obj/item/gun/ballistic/automatic/toy/unrestricted = 10,
		/obj/item/gun/ballistic/automatic/toy/pistol/unrestricted = 10,
		/obj/item/gun/ballistic/shotgun/toy/unrestricted = 10,
		/obj/item/toy/sword = 10,
		/obj/item/ammo_box/foambox = 20,
		/obj/item/clothing/head/ertcommanderfake = 1,
		/obj/item/clothing/head/ertsecurityfake = 1,
		/obj/item/clothing/head/ertmedicalfake = 1,
		/obj/item/clothing/head/ertengineerfake = 1,
		/obj/item/toy/foamblade = 10)
	premium = list(
		/obj/item/clothing/suit/ertcommanderfake = 1,
		/obj/item/clothing/suit/ertsecurityfake = 1,
		/obj/item/clothing/suit/ertmedicalfake = 1,
		/obj/item/clothing/suit/ertengineerfake = 1,
		/obj/item/mecha_parts/mecha_equipment/weapon/ballistic/BBchaingun = 2)
	contraband = list(
		/obj/item/toy/syndicateballoon = 10,
		/obj/item/clothing/suit/syndicatefake = 4,
		/obj/item/clothing/head/syndicatefake = 4,
		/obj/item/gun/ballistic/shotgun/toy/crossbow = 10,
		/obj/item/gun/ballistic/automatic/c20r/toy/unrestricted = 10,
		/obj/item/gun/ballistic/automatic/l6_saw/toy/unrestricted = 10,
		/obj/item/toy/katana = 10,
		/obj/item/dualsaber/toy = 5)
	default_price = 100

// AQUILA - aq33/NSV13#269: dakimakuras in the Donksoft vendor's contraband
/obj/machinery/vending/donksofttoyvendor/Initialize(mapload)
	contraband[/obj/item/dakimakura] = 5
	return ..()
