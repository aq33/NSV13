//Mech zrobiony ze smieci. Inspirowany locker mechem z Yogstation oraz Hippiestation. Autor pieknych spritow: Toddout (pipi popo #6667 na dc)
//Port z aq33/tgstation#480 (B4CKU)
/obj/mecha/working/lockermech
	desc = "A locker with stolen wires, struts, electronics and airlock servos crudely assembled into something that resembles the functions of a exosuit."
	name = "\improper GR-3YT1.DE Locker Exosuit"
	icon = 'aquila/icons/mecha/lockermech.dmi'
	icon_state = "lockermech"
	step_in = 4 //Predkosc Ripleya
	max_integrity = 100 //Zrobiony ze zlomu
	deflect_chance = 0
	lights_power = 5
	armor = list("melee" = 20, "bullet" = 10, "laser" = 10, "energy" = 0, "bomb" = 10, "bio" = 0, "rad" = 0, "fire" = 70, "acid" = 60, "stamina" = 0)
	max_equip = 2
	wreckage = null //Mech doslownie ledwo sie trzyma, po zniszczeniu rozpada sie na kawalki
	internals_req_access = null //Smieciowa elektronika nie posiada zabezpieczeń
	enter_delay = 60 //Zrobiony ze zlomu, nie posiada wygodnego wejscia/wyjscia
	exit_delay = 30 //Wchodzi/wychodzi sie z niego 50% dluzej
	stepsound = 'aquila/sound/mecha/scrapstep.ogg'
	//W NSV13 cargo jest zdefiniowane tylko na Ripleyu, wiec szafka ma wlasne
	var/list/cargo = new
	var/cargo_capacity = 5 //Szafka jest malo pojemna

//Kod ukradziony z Ripleya. Odpowiada za obsluge cargo i clampow
/obj/mecha/working/lockermech/Destroy()
	for(var/atom/movable/A in cargo)
		A.forceMove(drop_location())
		step_rand(A)
	cargo.Cut()
	return ..()

/obj/mecha/working/lockermech/Exit(atom/movable/O)
	if(O in cargo)
		return 0
	return ..()

/obj/mecha/working/lockermech/Topic(href, href_list)
	..()
	if(href_list["drop_from_cargo"])
		var/obj/O = locate(href_list["drop_from_cargo"]) in cargo
		if(O)
			occupant_message("<span class='notice'>You unload [O].</span>")
			O.forceMove(drop_location())
			cargo -= O
			log_message("Unloaded [O]. Cargo compartment capacity: [cargo_capacity - src.cargo.len]", LOG_MECHA)
	return

/obj/mecha/working/lockermech/contents_explosion(severity, target)
	for(var/X in cargo)
		var/obj/O = X
		if(prob(30/severity))
			cargo -= O
			O.forceMove(drop_location())
	. = ..()

/obj/mecha/working/lockermech/get_stats_part()
	var/output = ..()
	output += "<b>Cargo Compartment Contents:</b><div style=\"margin-left: 15px;\">"
	if(cargo.len)
		for(var/obj/O in cargo)
			output += "<a href='?src=[REF(src)];drop_from_cargo=[REF(O)]'>Unload</a> : [O]<br>"
	else
		output += "Nothing"
	output += "</div>"
	return output

/obj/mecha/working/lockermech/relay_container_resist(mob/living/user, obj/O)
	to_chat(user, "<span class='notice'>You lean on the back of [O] and start pushing so it falls out of [src].</span>")
	if(do_after(user, 300, target = O))
		if(!user || user.stat != CONSCIOUS || user.loc != src || O.loc != src )
			return
		to_chat(user, "<span class='notice'>You successfully pushed [O] out of [src]!</span>")
		O.forceMove(drop_location())
		cargo -= O
	else
		if(user.loc == src) //so we don't get the message if we resisted multiple times and succeeded.
			to_chat(user, "<span class='warning'>You fail to push [O] out of [src]!</span>")
//Nie spodziewalem sie ze to zadziala -b4cku

//Narzedzia szafkomecha
//-smieciowe wiertło
//-smieciowy podnosnik
//-smieciowa laserowa bron
//can_attach nie wola ..(), bo rodzice wymagaja Ripleya/mecha bojowego - sprawdzamy tylko limit slotow
/obj/item/mecha_parts/mecha_equipment/drill/makeshift
	name = "makeshift exosuit drill"
	desc = "Cobbled together from likely stolen parts, this drill is nowhere near as effective as the real deal."
	icon = 'aquila/icons/mecha/mecha_equipment.dmi'
	icon_state = "scrap_drill"
	equip_cooldown = 45 //W chuj powolne
	force = 10 //I stosunkowo slabe
	toolspeed = 1.2 //Oraz mniej precyzyjne
	drill_delay = 15

/obj/item/mecha_parts/mecha_equipment/drill/makeshift/can_attach(obj/mecha/M as obj)
	return istype(M, /obj/mecha/working/lockermech) && M.equipment.len < M.max_equip

/obj/item/mecha_parts/mecha_equipment/hydraulic_clamp/makeshift
	name = "makeshift hydraulic clamp"
	desc = "Loose arrangement of cobbled together bits resembling a clamp."
	icon = 'aquila/icons/mecha/mecha_equipment.dmi'
	icon_state = "scrap_clamp"
	equip_cooldown = 25
	toolspeed = 1.2
	dam_force = 10

/obj/item/mecha_parts/mecha_equipment/hydraulic_clamp/makeshift/can_attach(obj/mecha/M as obj)
	return istype(M, /obj/mecha/working/lockermech) && M.equipment.len < M.max_equip

//Smieciowy podnosnik jest za slaby, zeby podwazac drzwi
/obj/item/mecha_parts/mecha_equipment/hydraulic_clamp/makeshift/action(atom/target)
	if(istype(target, /obj/machinery/door))
		if(chassis?.occupant)
			balloon_alert(chassis.occupant, "[src] is too weak to pry [target] open!")
		return
	return ..()

/obj/item/mecha_parts/mecha_equipment/weapon/energy/makeshift
	name = "makeshift exosuit laser rifle"
	desc = "Makeshift laser rifle attached to a makeshift exosuit equipment mount. Lacks factory precision, so the damage may be inconsistent."
	icon = 'aquila/icons/mecha/mecha_equipment.dmi'
	icon_state = "scrap_laser"
	equip_cooldown = 15
	energy_drain = 45
	projectile = /obj/item/projectile/beam/laser/makeshiftlasrifle
	fire_sound = 'sound/weapons/laser.ogg'
	harmful = TRUE

/obj/item/mecha_parts/mecha_equipment/weapon/energy/makeshift/can_attach(obj/mecha/M as obj)
	return istype(M, /obj/mecha/working/lockermech) && M.equipment.len < M.max_equip

//Przepisy
/datum/crafting_recipe/lockermech //bruh
	name = "GR-3YT1.DE Locker Mech"
	result = /obj/mecha/working/lockermech
	tools = list(TOOL_WELDER, TOOL_WRENCH, TOOL_WIRECUTTER)
	reqs = list(/obj/item/stack/cable_coil = 15,
				/obj/item/stack/sheet/iron = 10,
				/obj/item/flashlight = 1,
				/obj/item/extinguisher = 1,
				/obj/item/storage/toolbox = 1,
				/obj/item/electronics/airlock = 1,
				/obj/item/stack/package_wrap = 10)
	time = 200
	category = CAT_ROBOT

/datum/crafting_recipe/lockermechdrill
	name = "Makeshift Exosuit Drill"
	result = /obj/item/mecha_parts/mecha_equipment/drill/makeshift
	tools = list(TOOL_WIRECUTTER)
	reqs = list(/obj/item/stack/cable_coil = 5,
				/obj/item/storage/toolbox = 1,
				/obj/item/screwdriver = 1)
	time = 50
	category = CAT_ROBOT

/datum/crafting_recipe/lockermechclamp
	name = "Makeshift Exosuit Hydraulic Clamp"
	result = /obj/item/mecha_parts/mecha_equipment/hydraulic_clamp/makeshift
	tools = list(TOOL_WIRECUTTER)
	reqs = list(/obj/item/stack/cable_coil = 5,
				/obj/item/stack/sheet/iron = 2,
				/obj/item/chair = 1)
	time = 50
	category = CAT_ROBOT

/datum/crafting_recipe/lockermechlaserrifle
	name = "Makeshift Exosuit Laser Rifle"
	result = /obj/item/mecha_parts/mecha_equipment/weapon/energy/makeshift
	tools = list(TOOL_WIRECUTTER)
	reqs = list(/obj/item/stack/cable_coil = 5,
				/obj/item/stack/package_wrap = 5,
				/obj/item/gun/energy/laser/makeshiftlasrifle = 1)
	time = 50
	category = CAT_ROBOT
