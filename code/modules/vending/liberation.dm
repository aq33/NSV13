/obj/machinery/vending/liberationstation
	name = "\improper Liberation Station"
	desc = "An overwhelming amount of <b>ancient patriotism</b> washes over you just by looking at the machine."
	icon_state = "liberationstation"
	product_slogans = "Liberation Station: twój sklep z wszystkim, co dotyczy drugiej poprawki!;Bądź dziś patriotą, kup broń!;Jakościowa broń w niskich cenach!;Lepiej martwy niż czerwony!"
	product_ads = "Płyń jak astronauta, kąsaj jak kula!;Wyraź dziś swoją drugą poprawkę!;Broń nie zabija ludzi, ale ty możesz!;Komu potrzebna odpowiedzialność, gdy ma się broń?"
	vend_reply = "Zapamiętaj nazwę: Liberation Station!"
	light_color = LIGHT_COLOR_RED
	products = list(/obj/item/food/burger/plain = 5, //O say can you see, by the dawn's early light
					/obj/item/food/burger/baseball = 3, //What so proudly we hailed at the twilight's last gleaming
					/obj/item/food/fries = 5, //Whose broad stripes and bright stars through the perilous fight
					/obj/item/reagent_containers/food/drinks/beer/light = 10, //O'er the ramparts we watched, were so gallantly streaming?
					/obj/item/gun/ballistic/automatic/pistol/deagle/gold = 2,
		            /obj/item/gun/ballistic/automatic/pistol/deagle/camo = 2,
					/obj/item/gun/ballistic/automatic/pistol/m1911 = 2,
					/obj/item/gun/ballistic/automatic/proto/unrestricted = 2,
					/obj/item/gun/ballistic/shotgun/automatic/combat = 2,
					/obj/item/gun/ballistic/automatic/gyropistol = 1,
					/obj/item/gun/ballistic/shotgun = 2,
					/obj/item/gun/ballistic/automatic/ar = 2)
	premium = list(/obj/item/ammo_box/magazine/smgm9mm = 2,
		           /obj/item/ammo_box/magazine/m50 = 4,
		           /obj/item/ammo_box/magazine/m45 = 2,
		           /obj/item/ammo_box/magazine/m75 = 2,
				   /obj/item/food/cheesyfries = 5,
				   /obj/item/food/burger/baconburger = 5) //Premium burgers for the premium section
	contraband = list(/obj/item/clothing/under/misc/patriotsuit = 3,
		              /obj/item/bedsheet/patriot = 5,
					  /obj/item/food/burger/superbite = 3) //U S A
	armor = list("melee" = 100, "bullet" = 100, "laser" = 100, "energy" = 100, "bomb" = 0, "bio" = 0, "rad" = 0, "fire" = 100, "acid" = 50, "stamina" = 0, "bleed" = 0)
	resistance_flags = FIRE_PROOF
	default_price = 300
	extra_price = 500
	payment_department = ACCOUNT_SEC
