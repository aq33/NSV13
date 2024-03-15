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
	job_loyalties = null
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
//Krzyże
//////////////////
/obj/item/kszysz
	icon = 'aquila/icons/obj/kszysz.dmi'
	resistance_flags = FLAMMABLE
	force = 0
	var/kszysz_type
	var/obj/structure/sign/kszysz/kszysz_structure

/obj/item/kszysz/Initialize(mapload)
	. = ..()

/obj/item/kszysz/Initialize(mapload, obj/structure/sign/kszysz/new_kszysz_structure)
	. = ..()
	kszysz_structure = new_kszysz_structure
	if(!new_kszysz_structure && kszysz_type)
		kszysz_structure = new kszysz_type(src)

/obj/item/kszysz/Destroy()
	kszysz_structure = null
	. = ..()

/obj/item/kszysz/kszysz_drewniany
	name = "drewniany krzyż"
	desc = "Panie, zmiłuj się nad nami"
	icon_state = "kszysz_drewn"

/datum/crafting_recipe/kszysz_drewniany
	name = "drewniany krzyż"
	result = /obj/item/kszysz/kszysz_drewniany
	time = 5
	reqs = list(/obj/item/stack/sheet/mineral/wood = 2)
	category = CAT_MISC

/obj/item/kszysz/kszysz_zloty
	name = "złoty krzyż"
	desc = "Panie, zmiłuj się nad nami - ale ze stylem."
	icon_state = "kszysz_zloty"

/datum/crafting_recipe/kszysz_zloty
	name = "złoty krzyż"
	result = /obj/item/kszysz/kszysz_zloty
	time = 10
	reqs = list(/obj/item/stack/sheet/mineral/gold = 1,
				/obj/item/stack/sheet/mineral/wood = 2)
	category = CAT_MISC

/////////////////
//Godła
//////////////////
/obj/item/godlo	
	icon = 'aquila/icons/obj/godla.dmi'
	resistance_flags = FLAMMABLE
	force = 0
	var/godlo_type
	var/obj/structure/sign/godlo/godlo_structure

/obj/item/godlo/Initialize(mapload)
	. = ..()

/obj/item/godlo/Initialize(mapload, obj/structure/sign/godlo/new_godlo_structure)
	. = ..()
	godlo_structure = new_godlo_structure
	if(!new_godlo_structure && godlo_type)
		godlo_structure = new godlo_type(src)

/obj/item/godlo/Destroy()
	godlo_structure = null
	. = ..()

/obj/item/godlo/godlo_drewniane
	name = "godło w drewnianej ramie"
	desc = "Wizerunek orła białego ze złotą koroną na głowie zwróconej w prawo, z rozwiniętymi skrzydłami, z dziobem i szponami złotymi, umieszczony w czerwonym polu tarczy."
	icon_state = "godlo_drewno"

/datum/crafting_recipe/godlo_drewniane
	name = "godło w drewnianej ramie"
	result = /obj/item/godlo/godlo_drewniane
	time = 20
	reqs = list(/obj/item/stack/sheet/mineral/wood = 4,
				/obj/item/clothing/under/color/red = 1,
				/obj/item/clothing/under/color/white = 1)
	category = CAT_MISC

/obj/item/godlo/godlo_czarne
	name = "godło w czarnej ramie"
	desc = "Wizerunek orła białego ze złotą koroną na głowie zwróconej w prawo, z rozwiniętymi skrzydłami, z dziobem i szponami złotymi, umieszczony w czerwonym polu tarczy."
	icon_state = "godlo_czarne"

/datum/crafting_recipe/godlo_czarne
	name = "godło w czarnej ramie"
	result = /obj/item/godlo/godlo_czarne
	time = 20
	reqs = list(/obj/item/stack/sheet/mineral/wood = 4,
				/obj/item/clothing/under/color/red = 1,
				/obj/item/clothing/under/color/white = 1)
	category = CAT_MISC
