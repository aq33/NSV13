/obj/item/clothing/suit/hooded/aquila/ghostcostume
	name = "spooky ghost costume"
	desc = "Spooky ghost costume costume."
	icon_state = "ghostcostume"
	hoodtype = /obj/item/clothing/head/hooded/aquila/huge/ghostcosstumehood
	flags_inv = HIDEJUMPSUIT

/obj/item/clothing/suit/hooded/aquila/ghostcostume/Initialize(mapload)
	. = ..()
	allowed = GLOB.civilian_storage_allowed

// Kosmobagiety - kurtka Komendanta, te same statystyki co kurtka peacekeepera
/obj/item/clothing/suit/ship/peacekeeper/jacket/police
	name = "head of security's jacket"
	desc = "A navy police jacket with the insignia of the Head of Security. Despite its heavy armour, it's still extremely comfortable to wear."
	icon = 'icons/obj/clothing/suits.dmi'
	worn_icon = 'icons/mob/clothing/suit.dmi'
	icon_state = "hosbluejacket"
	item_state = "hostrench"
