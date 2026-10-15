// AQUILA - port aq33/tgstation#564: kulki ASG zamiast strzałek Donksoft
/obj/item/ammo_box/update_icon()
	..()
	if(multiple_sprites == 3) //sprite for 4 stages of 'fullness' and when empty
		icon_state = "[initial(icon_state)]-[round(stored_ammo.len / max_ammo * 4)]"
