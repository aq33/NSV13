/obj/item/gun/energy/laser/retro/old/research
	desc = "An older model of the basic lasergun, no longer used by Nanotrasen's private security or military forces."
	dual_wield_spread = 60
	can_flashlight = TRUE
	w_class = WEIGHT_CLASS_BULKY
	flight_x_offset = 15
	flight_y_offset = 10
	pin = null

/obj/item/gun/energy/laser/research
	dual_wield_spread = 60
	can_flashlight = TRUE
	w_class = WEIGHT_CLASS_BULKY
	flight_x_offset = 15
	flight_y_offset = 10
	pin = null

/obj/item/gun/energy/lasercannon/research
	can_flashlight = TRUE
	flight_x_offset = 15
	flight_y_offset = 10

// Hitscan lasers fire slower (powolne wystrzały ze względu na hitscan)
/obj/item/gun/energy/laser
	fire_rate = 1

/obj/item/gun/energy/laser/captain
	charge_delay = 12 // 8 -> 12
	fire_rate = 0.7 // nieskończona moc w skończonej formie

/obj/item/gun/energy/lasercannon
	fire_rate = 1

/obj/item/gun/energy/xray
	fire_rate = 0.8 // ditto + ignorowanie ściań i 20 strzałów
