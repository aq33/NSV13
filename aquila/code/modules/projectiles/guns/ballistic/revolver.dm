/obj/item/gun/ballistic/revolver/coltsingleaction
	name = "Colt Single Action" //broń dostepna w automacie z rewolwerami
	desc = "Revolver uses .45 ammo."
	icon_state = "detective_peacemaker"
	mag_type = /obj/item/ammo_box/magazine/internal/cylindercsa
	fire_rate = 1.5 // szybkostrzelnosc do moderowania



/obj/item/gun/ballistic/revolver/detective/special
	name = "Special 38" //broń dostepna w automacie z rewolwerami
	desc = "A classic, if not outdated firearm. Uses .38-special rounds."
	fire_sound = 'sound/weapons/revolver38shot.ogg'
	icon_state = "detective_stainless"
	fire_rate = 2 // szybkostrzelnosc do moderowania, taka sama jak w colt detective
	mag_type = /obj/item/ammo_box/magazine/internal/cylinder/rev38
