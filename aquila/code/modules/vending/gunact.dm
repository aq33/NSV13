/obj/machinery/vending/gunact //alpha test gunact wersja 0.1
	name = "GunSzop!"
	desc = "Twój oldskulowy sklep ze wszystkim, co dotyczy samoobrony!;Bądź patriotą już dziś, kup broń!;Wysokiej jakości broń za niską cenę!"
	icon = 'aquila/icons/obj/vending.dmi'
	icon_state = "gunact"
	product_slogans = "Wyraź swoją wolność już dziś!;Broń nie zabija, ludzie tak!;Kto potrzebuje obowiązków, kiedy masz broń?"
	product_ads = "<b>Wolność kocham i rozumiem, wolności oddac nie umiem</b>"
	vend_reply = "Zapamiętaj nazwę: GunSzop!"
	light_color = LIGHT_COLOR_YELLOW

	//Piwo i amunicja do rewolwerow
	products = list(/obj/item/reagent_containers/food/drinks/beer/light = 6,
		            /obj/item/ammo_casing/n762 = 7,
		            /obj/item/ammo_casing/c38 = 6,
		            /obj/item/ammo_casing/c45 = 5)


	//Premium rewolwery i stary kapelusz
	premium = list(/obj/item/gun/ballistic/revolver/nagant = 1,
				   /obj/item/gun/ballistic/revolver/detective/special = 1,
				   /obj/item/gun/ballistic/revolver/coltsingleaction = 1,
				   /obj/item/clothing/head/oldhat = 1)

	//Kontrabanda
	contraband = list(/obj/item/clothing/under/misc/patriotsuit = 1,
		              /obj/item/bedsheet/patriot = 1,
					  /obj/item/reagent_containers/food/snacks/burger/superbite = 1)

	default_price = 25
	extra_price = 300
	payment_department = ACCOUNT_SEC
