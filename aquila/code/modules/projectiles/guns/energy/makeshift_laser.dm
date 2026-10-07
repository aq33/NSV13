//Improwizowany karabin laserowy z aq33/tgstation, potrzebny do przepisu na laser locker mecha (aq33/tgstation#480)
/obj/item/gun/energy/laser/makeshiftlasrifle
	name = "makeshift laser rifle"
	desc = "A makeshift rifle that shoots lasers. Lacks factory precision, so the damage may be inconsistent."
	icon = 'aquila/icons/obj/items/makeshift_laser.dmi'
	icon_state = "makeshiftlas"
	item_state = "makeshiftlas"
	lefthand_file = 'aquila/icons/mob/inhands/weapons/makeshift_laser_lefthand.dmi'
	righthand_file = 'aquila/icons/mob/inhands/weapons/makeshift_laser_righthand.dmi'
	w_class = WEIGHT_CLASS_NORMAL
	ammo_type = list(/obj/item/ammo_casing/energy/laser/makeshiftlasrifle)
	can_charge = TRUE
	charge_sections = 1
	ammo_x_offset = 2
	shaded_charge = FALSE

/obj/item/ammo_casing/energy/laser/makeshiftlasrifle
	projectile_type = /obj/item/projectile/beam/laser/makeshiftlasrifle
	e_cost = 2500

/obj/item/projectile/beam/laser/makeshiftlasrifle
	damage = 15 //w Initialize() losowo dodajemy 10 dmg, wiec bron srednio zadaje 20 dmg

/obj/item/projectile/beam/laser/makeshiftlasrifle/Initialize(mapload)
	. = ..()
	if(rand(1,2)==1)
		damage += 10

/datum/crafting_recipe/makeshiftlasrifle
	name = "Improvised Laser Rifle"
	result = /obj/item/gun/energy/laser/makeshiftlasrifle
	reqs = list(/obj/item/stack/cable_coil = 15,
				/obj/item/weaponcrafting/stock = 1,
				/obj/item/pipe = 1,
				/obj/item/stock_parts/micro_laser = 1,
				/obj/item/stock_parts/cell = 1)
	tools = list(TOOL_SCREWDRIVER)
	time = 120
	category = CAT_WEAPONRY
	subcategory = CAT_WEAPON
