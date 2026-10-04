// AQUILA - strój Kapitana Bomby (aq33/NSV13#304) w szafce kapitana. Blaster zostaje tylko dla adminów.
/obj/structure/closet/secure_closet/captains
	// +3 na strój, inaczej po otwarciu i zamknięciu jedna rzecz zostawałaby poza zamkniętą szafką
	storage_capacity = 33

/obj/structure/closet/secure_closet/captains/PopulateContents()
	..()
	new /obj/item/clothing/head/helmet/space/kapitanbomba(src)
	new /obj/item/clothing/suit/kapitanbomba(src)
	new /obj/item/clothing/shoes/aquila/kapitanbomba(src)
