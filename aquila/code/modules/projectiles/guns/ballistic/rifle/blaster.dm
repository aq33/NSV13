// AQUILA - Blaster Kapitana Bomby (aq33/NSV13#304, sprite: Reprimann; nakładki pokrywy wygenerowane)
/obj/item/gun/ballistic/automatic/l6_saw/blaster
	name = "Blaster Kapitana Bomby"
	desc = "Łapy precz tępe chuje"
	icon = 'aquila/icons/obj/items/guns.dmi'
	icon_state = "blaster"
	item_state = "blaster"
	lefthand_file = 'aquila/icons/mob/inhands/kapitanbomba_lefthand.dmi'
	righthand_file = 'aquila/icons/mob/inhands/kapitanbomba_righthand.dmi'
	pin = /obj/item/firing_pin
	mag_type = /obj/item/ammo_box/magazine/peacekeeper/lethal/blaster
	// magazynek nie jest widoczny na sprite'cie blastera
	mag_display = FALSE
	mag_display_ammo = FALSE

/obj/item/ammo_box/magazine/peacekeeper/lethal/blaster
	name = "Amunicja Blastera"
	desc = "Cudem nie przejebane na wódę, ale też nie dziwota bo kto widział 6mm sprzedać za flachę"
	max_ammo = 99
