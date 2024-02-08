
/obj/item/gun/ballistic/tazer
	name = "X24 Tazer"
	desc = "A stunning weapon developed by Czanek Corp. It can deliver an extremely powerful electric shock via a specialised electrode, though the electrodes must be manually replaced after each shot. <b>It has an effective range of 2 meters</b>"
	icon = 'nsv13/icons/obj/guns/projectile.dmi'
	icon_state = "taser"
	mag_type = /obj/item/ammo_box/magazine/tazer_cartridge
	can_suppress = FALSE
	w_class = 2
	fire_delay = 2 SECONDS
	can_bayonet = FALSE
	mag_display = TRUE
	mag_display_ammo = FALSE
	bolt_type = BOLT_TYPE_LOCKING
	slot_flags = ITEM_SLOT_BELT
	fire_sound = 'sound/weapons/zapbang.ogg'
	recoil = 2 //BZZZZTTTTTTT
	can_flashlight = TRUE
	flight_x_offset = 15
	flight_y_offset = 12

/obj/item/gun/ballistic/automatic/pistol/glock
	name = "Walther P99-C"
	desc = "Niewielki pistolet samopowtarzalny kalibru 9mm, wariant cywilny przeznaczony do ochrony osobistej."
	icon = 'nsv13/icons/obj/guns/projectile.dmi'
	icon_state = "crewglock"
	lefthand_file = 'nsv13/icons/mob/inhands/weapons/guns_lefthand.dmi'
	righthand_file = 'nsv13/icons/mob/inhands/weapons/guns_righthand.dmi'
	item_state = "glock"
	fire_sound = 'nsv13/sound/weapons/glock.ogg'
	w_class = WEIGHT_CLASS_NORMAL
	mag_type = /obj/item/ammo_box/magazine/glock
	can_suppress = TRUE
	automatic = FALSE
	can_flashlight = TRUE
	flight_x_offset = 15
	flight_y_offset = 12
	fire_rate = 2

/obj/item/gun/ballistic/automatic/pistol/glock/security
	name = "Walther P99"
	desc = "Niewielki pistolet samopowtarzalny kalibru 9mm, wariant zaprojektowany dla służb mundurowych. Posiada możliwość wystrzału serii trzech pocisków."
	icon = 'nsv13/icons/obj/guns/projectile.dmi'
	icon_state = "secglock"
	item_state = "glock"
	fire_sound = 'nsv13/sound/weapons/glock.ogg'
	w_class = WEIGHT_CLASS_NORMAL
	mag_type = /obj/item/ammo_box/magazine/glock
	can_suppress = TRUE
	burst_size = 3
	fire_delay = 2
	actions_types = list(/datum/action/item_action/toggle_firemode)
	automatic = FALSE
	can_flashlight = TRUE
	flight_x_offset = 15
	flight_y_offset = 12
	fire_rate = 2

/obj/item/gun/ballistic/automatic/pistol/glock/makarov
	name = "Makarov NT"
	desc = "An older handgun used by NT security forces, produced by H&KC but slowly being phased out by the Glock-13. One of the designers of the weapon went on record saying: 'There are no brakes on this commie fucktrain.'"
	icon_state = "makarov"

/obj/item/gun/ballistic/automatic/pistol/glock/makarov/lethal //Starts with lethal bullets loaded
	mag_type = /obj/item/ammo_box/magazine/glock/lethal

/obj/item/gun/ballistic/automatic/pistol/m1911/m9le
	name = "\improper M9LE"
	desc = "A military surplus pistol no longer in service, but boasting a higher muzzle velocity than other handguns. It's a reliable damage dealer despite its age."
	icon = 'nsv13/icons/obj/guns/projectile.dmi'
	icon_state = "m9"
	item_state = "glock"
	fire_sound = 'nsv13/sound/weapons/glock.ogg'
	w_class = WEIGHT_CLASS_NORMAL
	mag_type = /obj/item/ammo_box/magazine/m45
	can_suppress = FALSE

/obj/item/ammo_box/c45/m45 // .45 ammobox intended for m1911
	max_ammo = 24

/datum/design/gulagpack
	name = "Gulagpack"
	id = "gulagpack"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron=10000, /datum/material/glass=2500)
	build_path = /obj/item/storage/backpack/gulagpack
	departmental_flags = DEPARTMENTAL_FLAG_SECURITY
	category = list("Equipment")


/obj/item/gun/ballistic/automatic/pistol/glock/command
	name = "Kolekcjonerski Walther P99"
	desc = "Ekskluzywny wariant popularnego pistoletu samopowtarzalnego, spersonalizowany do każdego Oficera który go posiada"
	icon_state = "commandglock"

/obj/item/gun/ballistic/automatic/pistol/glock/security/hos
	name = "Winona"
	desc = "Niewielki pistolet samopowtarzalny kalibru 9mm, ten model został wykonany na zlecenie Komendanta Żandarmerii. Usprawniona konstrukcja broni pozwala na strzelanie z jednej ręki zachowując perfekcyjną precyzję!."
	icon_state = "commandglock"
	full_auto = TRUE
	requires_wielding = FALSE //While the HoS's upgraded energy gun gets a ion setting, Winona gets to fire with one hand without decreased accuracy.
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | ACID_PROOF
	investigate_flags = ADMIN_INVESTIGATE_TARGET

/datum/design/lethal9mm
	name = "Pojemnik z amunicją 9mm"
	id = "glock_lethalammo"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 30000)
	build_path = /obj/item/ammo_box/c9mm
	category = list("Ammo")
	departmental_flags = DEPARTMENTAL_FLAG_SECURITY

/datum/design/lethalglockmag
	name = "Magazynek P99"
	id = "glock_lethalmag"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 16500)
	build_path = /obj/item/ammo_box/magazine/glock/lethal
	category = list("Ammo")
	departmental_flags = DEPARTMENTAL_FLAG_SECURITY

/datum/design/rubbershot
	name = "Gumowy pocisk kalibru 9mm"
	id = "glock_ammo"
	build_type = AUTOLATHE
	materials = list(/datum/material/iron = 500)
	build_path = /obj/item/ammo_casing/c9mm/rubber
	category = list("initial", "Security")

/datum/design/rubber9mm
	name = "Pojemnik z gumową amunicją 9mm"
	id = "glock_rubberammo"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 25000)
	build_path = /obj/item/ammo_box/c9mm/rubber
	category = list("Ammo")
	departmental_flags = DEPARTMENTAL_FLAG_SECURITY

/datum/design/glockmag
	name = "Magazynek P99 na gumową amunicję"
	id = "glock_rubbermag"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 14000)
	build_path = /obj/item/ammo_box/magazine/glock
	category = list("Ammo")
	departmental_flags = DEPARTMENTAL_FLAG_SECURITY

/datum/design/ap9mm
	name = "Pojemnik z amunicją przeciwpancerną 9mm"
	id = "glock_apammo"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 25000, /datum/material/titanium = 4000, /datum/material/silver = 1000)
	build_path = /obj/item/ammo_box/c9mm/ap
	category = list("Ammo")
	departmental_flags = DEPARTMENTAL_FLAG_SECURITY

/datum/design/apglockmag
	name = "Magazynek P99 na amunicję przeciwpancerną"
	id = "glock_apmag"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 14000, /datum/material/titanium = 150, /datum/material/silver = 150)
	build_path = /obj/item/ammo_box/magazine/glock/ap
	category = list("Ammo")
	departmental_flags = DEPARTMENTAL_FLAG_SECURITY

/datum/design/inc9mm
	name = "Pojemnik z amunicją zapalającą 9mm"
	id = "glock_incammo"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 25000, /datum/material/plasma = 4000, /datum/material/glass = 500, /datum/material/gold = 500)
	build_path = /obj/item/ammo_box/c9mm/inc
	category = list("Ammo")
	departmental_flags = DEPARTMENTAL_FLAG_SECURITY

/datum/design/incglockmag
	name = "Magazynek P99 na amunicję zapalającą"
	id = "glock_incmag"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 14000, /datum/material/plasma = 150, /datum/material/glass = 50, /datum/material/gold = 50)
	build_path = /obj/item/ammo_box/magazine/glock/inc
	category = list("Ammo")
	departmental_flags = DEPARTMENTAL_FLAG_SECURITY

/datum/design/tazer
	name = "3mm electro-shock tazer round"
	id = "tazer_ammo"
	build_type = AUTOLATHE
	materials = list(/datum/material/iron = 800)
	build_path = /obj/item/ammo_casing/tazer
	category = list("initial", "Security")

/obj/item/ammo_box/magazine/glock/lethal
	name = "Magazynek P99"
	desc = "Załadowany ostrą amunicją kalibru 9mm, perfekcyjna do obrony pokładu okrętu podczas sytuacji abordażowej!"
	icon_state = "Glock-lethal"
	ammo_type = /obj/item/ammo_casing/c9mm
	caliber = "9mm"
	max_ammo = 15

/obj/item/ammo_box/magazine/glock
	name = "Magazynek P99 na gumową amunicję"
	desc = "Załadowany gumową amunicją kalibru 9mm, perfekcyjna do pacyfikowania Zacharego, który wysadził reaktor."
	icon_state = "Glock-nonlethal"
	ammo_type = /obj/item/ammo_casing/c9mm/rubber
	caliber = "9mm"
	max_ammo = 15

/obj/item/ammo_box/magazine/glock/ap
	name = "Magazynek P99 na amunicję przeciwpancerną"
	desc = "Załadowany amunicją przeciwpancerną kalibru 9mm, tzw. Zielonym Czubkiem. Perfekcyjna do eliminowania opancerzonego zagrożenia na pokładzie."
	icon_state = "Glock-ap"
	ammo_type = /obj/item/ammo_casing/c9mm/ap
	caliber = "9mm"
	max_ammo = 15

/obj/item/ammo_box/magazine/glock/inc
	name = "Magazynek P99 na amunicję zapalającą"
	desc = "Załadowany plazmową amunicją zapalającą kalibru 9mm, perfekcyjna do podpalania plazmoludów!"
	icon_state = "Glock-lethal"
	ammo_type = /obj/item/ammo_casing/c9mm/inc
	caliber = "9mm"
	max_ammo = 15

/obj/item/ammo_box/magazine/glock/update_icon()
    ..()
    icon_state = "[initial(icon_state)][ammo_count() ? "" : "-0"]"

/obj/item/ammo_box/c9mm/ap // for colouring
	name = "Pojemnik z amunicją przeciwpancerną 9mm"
	icon_state = "45box"
	ammo_type = /obj/item/ammo_casing/c9mm/ap
	max_ammo = 30

/obj/item/ammo_box/c9mm/inc
	name = "Pojemnik z amunicją zapalającą 9mm"
	icon_state = "10mmbox"
	ammo_type = /obj/item/ammo_casing/c9mm/inc
	max_ammo = 30

/obj/item/ammo_casing/c9mm/rubber
	name = "Łuska po gumowej kuli kalibru 9mm"
	desc = "Pojedyncza łuska po gumowej kuli kalibru 9mm."
	caliber = "9mm"
	projectile_type = /obj/item/projectile/bullet/c9mm/rubber

/obj/item/ammo_box/c9mm/rubber
	name = "Pojemnik z gumową amunicją 9mm"
	icon_state = "9mmboxrubber"
	ammo_type = /obj/item/ammo_casing/c9mm/rubber
	max_ammo = 30

/obj/item/projectile/bullet/c9mm/rubber
	name = "Pocisk 9mm"
	damage = 20
	damage_type = STAMINA
	icon = 'nsv13/icons/obj/projectiles_nsv.dmi'
	icon_state = "pdc"

/obj/item/ammo_box/magazine/tazer_cartridge
	name = "X24 Tazer cartridge"
	desc = "A cartridge which can hold a taser electrode"
	icon = 'nsv13/icons/obj/ammo.dmi'
	icon_state = "taser-1"
	ammo_type = /obj/item/ammo_casing/tazer
	caliber = "3mm"
	max_ammo = 1

/obj/item/ammo_box/magazine/tazer_cartridge/update_icon()
	..()
	icon_state = (ammo_count()) ? "taser-1" : "taser"

///Lets the officer have an ammo box filled with tazer cartridges ready to hotswap.

/obj/item/ammo_box/magazine/tazer_cartridge_storage
	name = "X24 cartridge storage rack"
	desc = "A small clip which you can slot tazer electrodes into."
	icon = 'nsv13/icons/obj/ammo.dmi'
	icon_state = "taserrack-0"
	ammo_type = /obj/item/ammo_casing/tazer
	caliber = "3mm"
	max_ammo = 5

/obj/item/ammo_box/magazine/tazer_cartridge_storage/update_icon()
	..()
	icon_state = "taserrack-[ammo_count()]"

/obj/item/ammo_casing/tazer
	name =  "3mm electro-shock tazer round"
	desc = "A tazer cartridge."
	caliber = "3mm"
	icon = 'nsv13/icons/obj/ammo.dmi'
	icon_state = "tasershell"
	projectile_type = /obj/item/projectile/energy/electrode/hitscan
	materials = list(/datum/material/iron=4000)
	harmful = TRUE

/obj/item/projectile/energy/electrode/hitscan
	range = 2 //Real life tazers have an effective range of 4.5 meters.
	//damage = 75 //4 second stun by itself
	damage = 105 // AQ EDIT - should be around 5.5s
	damage_type = STAMINA
	hitscan = TRUE

/obj/item/projectile/energy/electrode/hitscan/on_hit(atom/target, blocked = FALSE)
	if(prob(10) && !blocked) //The czanek corp taser comes with a price. The price is that your victim might have a fucking heartattack.
		if(iscarbon(target))
			var/mob/living/carbon/M = target
			if(isethereal(M))
				M.reagents.add_reagent(/datum/reagent/consumable/liquidelectricity, 5) //Ethereals like electricity! And the hellish czanek corp taser has LOTS OF IT
				return ..()
			if(!M.undergoing_cardiac_arrest() && M.can_heartattack())
				M.log_message("suffered from a heartattack caused by a tazer shot", LOG_ATTACK, color="red")
				to_chat(M, "<span class='userdanger'>You feel a terrible pain in your chest, as if your heart has stopped!</span>")
				M.visible_message("<span class='userdanger'>[M] writhes around in pain, clutching at their chest!</span>")
				M.emote("scream")
				do_sparks(5, TRUE, M)
				M.shake_animation(10)
				M.set_heartattack(TRUE)
				M.reagents.add_reagent(/datum/reagent/medicine/corazone, 3) // To give the victim a final chance to shock their heart before losing consciousness
	. = ..()


//Secborg guns
/obj/item/gun/energy/printer/taser
	name = "Cyborg X25 Taser"
	desc = "A stunning weapon developed by Czanek Corp. It can deliver an extremely powerful electric shock via a specialised electrode, the electrodes are resupplied using the cyborg's internal power source. <b>It has an effective range of 2 meters</b>"
	icon = 'nsv13/icons/obj/guns/projectile.dmi'
	icon_state = "taser"
	recoil = 2 //BZZZZTTTTTTT
	ammo_type = list(/obj/item/ammo_casing/energy/taser)
	automatic = FALSE
	fire_rate = 0.2

/obj/item/ammo_casing/energy/taser
	projectile_type = /obj/item/projectile/energy/electrode/hitscan
	select_name = "electrode"
	fire_sound = 'sound/weapons/zapbang.ogg'
	firing_effect_type = /obj/effect/temp_visual/dir_setting/firing_effect
	e_cost = 600 //uses a lot more energy

/obj/item/gun/energy/printer/glock
	name = "Cyborg Glock-13BR"
	desc = "An integrated 9mm handgun for use by Nanotrasen security cyborgs. Designed to fire lethal bullets"
	icon = 'nsv13/icons/obj/guns/projectile.dmi'
	icon_state = "secborgglock"
	ammo_type = list(/obj/item/ammo_casing/energy/c9mmbullet/rubber, /obj/item/ammo_casing/energy/c9mmbullet) //Switch between lethal or rubber bullets with attack_self
	automatic = FALSE
	fire_rate = 2

/obj/item/ammo_casing/energy/c9mmbullet
	projectile_type = /obj/item/projectile/bullet/c9mm
	select_name = "9mm"
	fire_sound = 'nsv13/sound/weapons/glock.ogg'
	firing_effect_type = /obj/effect/temp_visual/dir_setting/firing_effect

/obj/item/ammo_casing/energy/c9mmbullet/rubber
	projectile_type = /obj/item/projectile/bullet/c9mm/rubber
	select_name = "9mm (Rubber)"
