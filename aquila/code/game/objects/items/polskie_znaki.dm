// AQUILA - polskie sztandary, krzyże i godła (aq33/NSV13#304, sprite: Reprimann)

////////////////////
//Sztandar
///////////////////
/obj/item/banner/polski_sztandar
	name = "polski sztandar"
	desc = "Za ojczyznę!"
	icon = 'aquila/icons/obj/banners.dmi'
	icon_state = "aq_banner_polska"
	item_state = "aq_banner_polska"
	lefthand_file = 'aquila/icons/mob/inhands/equipment/banners_lefthand.dmi'
	righthand_file = 'aquila/icons/mob/inhands/equipment/banners_righthand.dmi'
	warcry = "ZA OJCZYZNĘ!"

/obj/item/banner/polski_sztandar/mundane
	inspiration_available = FALSE

/datum/crafting_recipe/polski_sztandar
	name = "polski sztandar"
	result = /obj/item/banner/polski_sztandar/mundane
	time = 40
	reqs = list(/obj/item/stack/rods = 2,
				/obj/item/clothing/under/color/red = 1,
				/obj/item/clothing/under/color/white = 1)
	category = CAT_MISC

/////////////////
//Wieszane na ścianie
//////////////////
/// Ozdoba wisząca na ścianie, zdejmowana ręką z powrotem jako przedmiot
/obj/structure/aquila_wall_decor
	icon = 'aquila/icons/obj/kszysz.dmi'
	anchored = TRUE
	density = FALSE
	layer = SIGN_LAYER
	max_integrity = 100
	resistance_flags = FLAMMABLE
	/// Przedmiot (wallframe) oddawany po zdjęciu ze ściany
	var/obj/item/wallframe/item_path

/obj/structure/aquila_wall_decor/examine(mob/user)
	. = ..()
	if(item_path)
		. += "<span class='notice'>Możesz zdjąć [src] ze ściany ręką.</span>"

/obj/structure/aquila_wall_decor/attack_hand(mob/living/user)
	. = ..()
	if(. || !item_path)
		return
	var/obj/item/wallframe/frame = new item_path(drop_location())
	transfer_fingerprints_to(frame)
	to_chat(user, "<span class='notice'>Zdejmujesz [src] ze ściany.</span>")
	user.put_in_hands(frame)
	qdel(src)
	return TRUE

/////////////////
//Krzyże
//////////////////
/obj/item/wallframe/kszysz
	icon = 'aquila/icons/obj/kszysz.dmi'
	materials = null // drewno, nie metal - bez tego dziedziczy 2 arkusze żelaza z wallframe
	flags_1 = NONE
	resistance_flags = FLAMMABLE
	force = 0
	result_path = /obj/structure/aquila_wall_decor/kszysz
	pixel_shift = -28

/obj/item/wallframe/kszysz/kszysz_drewniany
	name = "drewniany krzyż"
	desc = "Panie, zmiłuj się nad nami"
	icon_state = "kszysz_drewn"

/obj/structure/aquila_wall_decor/kszysz
	name = "drewniany krzyż"
	desc = "Panie, zmiłuj się nad nami"
	icon = 'aquila/icons/obj/kszysz.dmi'
	icon_state = "kszysz_drewn"
	item_path = /obj/item/wallframe/kszysz/kszysz_drewniany

/datum/crafting_recipe/kszysz_drewniany
	name = "drewniany krzyż"
	result = /obj/item/wallframe/kszysz/kszysz_drewniany
	time = 5
	reqs = list(/obj/item/stack/sheet/mineral/wood = 2)
	category = CAT_MISC

/obj/item/wallframe/kszysz/kszysz_zloty
	name = "złoty krzyż"
	desc = "Panie, zmiłuj się nad nami - ale ze stylem."
	icon_state = "kszysz_zloty"
	materials = list(/datum/material/gold = MINERAL_MATERIAL_AMOUNT)
	result_path = /obj/structure/aquila_wall_decor/kszysz/zloty

/obj/structure/aquila_wall_decor/kszysz/zloty
	name = "złoty krzyż"
	desc = "Panie, zmiłuj się nad nami - ale ze stylem."
	icon_state = "kszysz_zloty"
	item_path = /obj/item/wallframe/kszysz/kszysz_zloty

/datum/crafting_recipe/kszysz_zloty
	name = "złoty krzyż"
	result = /obj/item/wallframe/kszysz/kszysz_zloty
	time = 10
	reqs = list(/obj/item/stack/sheet/mineral/gold = 1,
				/obj/item/stack/sheet/mineral/wood = 2)
	category = CAT_MISC

/////////////////
//Godła
//////////////////
/obj/item/wallframe/godlo
	icon = 'aquila/icons/obj/godla.dmi'
	materials = null // drewno, nie metal - bez tego dziedziczy 2 arkusze żelaza z wallframe
	flags_1 = NONE
	resistance_flags = FLAMMABLE
	force = 0
	result_path = /obj/structure/aquila_wall_decor/godlo
	pixel_shift = -28

/obj/item/wallframe/godlo/godlo_drewniane
	name = "godło w drewnianej ramie"
	desc = "Wizerunek orła białego ze złotą koroną na głowie zwróconej w prawo, z rozwiniętymi skrzydłami, z dziobem i szponami złotymi, umieszczony w czerwonym polu tarczy."
	icon_state = "godlo_drewno"

/obj/structure/aquila_wall_decor/godlo
	name = "godło w drewnianej ramie"
	desc = "Wizerunek orła białego ze złotą koroną na głowie zwróconej w prawo, z rozwiniętymi skrzydłami, z dziobem i szponami złotymi, umieszczony w czerwonym polu tarczy."
	icon = 'aquila/icons/obj/godla.dmi'
	icon_state = "godlo_drewno"
	item_path = /obj/item/wallframe/godlo/godlo_drewniane

/datum/crafting_recipe/godlo_drewniane
	name = "godło w drewnianej ramie"
	result = /obj/item/wallframe/godlo/godlo_drewniane
	time = 20
	reqs = list(/obj/item/stack/sheet/mineral/wood = 4,
				/obj/item/clothing/under/color/red = 1,
				/obj/item/clothing/under/color/white = 1)
	category = CAT_MISC

/obj/item/wallframe/godlo/godlo_czarne
	name = "godło w czarnej ramie"
	desc = "Wizerunek orła białego ze złotą koroną na głowie zwróconej w prawo, z rozwiniętymi skrzydłami, z dziobem i szponami złotymi, umieszczony w czerwonym polu tarczy."
	icon_state = "godlo_czarne"
	result_path = /obj/structure/aquila_wall_decor/godlo/czarne

/obj/structure/aquila_wall_decor/godlo/czarne
	name = "godło w czarnej ramie"
	icon_state = "godlo_czarne"
	item_path = /obj/item/wallframe/godlo/godlo_czarne

/datum/crafting_recipe/godlo_czarne
	name = "godło w czarnej ramie"
	result = /obj/item/wallframe/godlo/godlo_czarne
	time = 20
	reqs = list(/obj/item/stack/sheet/mineral/wood = 4,
				/obj/item/clothing/under/color/red = 1,
				/obj/item/clothing/under/color/white = 1)
	category = CAT_MISC
