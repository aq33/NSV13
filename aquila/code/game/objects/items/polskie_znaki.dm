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
/obj/item/wallframe/kszysz
	icon = 'aquila/icons/obj/kszysz.dmi'
	resistance_flags = FLAMMABLE
	force = 0
	result_path = /obj/machinery/kszysz
	pixel_shift = -28

/obj/item/wallframe/kszysz/kszysz_drewniany
	name = "drewniany krzyż"
	desc = "Panie, zmiłuj się nad nami"
	icon_state = "kszysz_drewn"

/obj/machinery/kszysz
	name = "drewniany krzyż"
	desc = "Panie, zmiłuj się nad nami"
	icon = 'aquila/icons/obj/kszysz.dmi'
	icon_state = "kszysz_drewn"
	density = FALSE
	var/kszysz = 0
	var/obj/item/wallframe/godlo/godlo_drewniane/g = new /obj/item/wallframe/godlo/godlo_drewniane
	var/obj/item/wallframe/godlo/godlo_czarne/h = new /obj/item/wallframe/godlo/godlo_czarne

/obj/machinery/kszysz/attack_hand(mob/living/user)
	.=..()
	qdel(src)
	switch(kszysz)
		if(0)
			user.put_in_hands(g)
		if(1)
			user.put_in_hands(h)

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
	result_path = /obj/machinery/kszysz/zloty

/datum/crafting_recipe/kszysz_zloty
	name = "złoty krzyż"
	result = /obj/item/wallframe/kszysz/kszysz_zloty
	time = 10
	reqs = list(/obj/item/stack/sheet/mineral/gold = 1,
				/obj/item/stack/sheet/mineral/wood = 2)
	category = CAT_MISC

/obj/machinery/kszysz/zloty
	name = "złoty krzyż"
	desc = "Panie, zmiłuj się nad nami - ale ze stylem."
	icon_state = "kszysz_zloty"
	kszysz = 1

/////////////////
//Godła
//////////////////
/obj/item/wallframe/godlo
	icon = 'aquila/icons/obj/godla.dmi'
	resistance_flags = FLAMMABLE
	force = 0
	result_path = /obj/machinery/godlo
	pixel_shift = -28

/obj/machinery/godlo
	name = "godło w drewnianej ramie"
	desc = "Wizerunek orła białego ze złotą koroną na głowie zwróconej w prawo, z rozwiniętymi skrzydłami, z dziobem i szponami złotymi, umieszczony w czerwonym polu tarczy."
	icon = 'aquila/icons/obj/godla.dmi'
	icon_state = "godlo_drewno"
	density = FALSE
	var/godlo = 0
	var/obj/item/wallframe/godlo/godlo_drewniane/g = new /obj/item/wallframe/godlo/godlo_drewniane
	var/obj/item/wallframe/godlo/godlo_czarne/h = new /obj/item/wallframe/godlo/godlo_czarne

/obj/machinery/godlo/attack_hand(mob/living/user)
	.=..()
	qdel(src)
	switch(godlo)
		if(0)
			user.put_in_hands(g)
		if(1)
			user.put_in_hands(h)

/obj/item/wallframe/godlo/godlo_drewniane
	name = "godło w drewnianej ramie"
	desc = "Wizerunek orła białego ze złotą koroną na głowie zwróconej w prawo, z rozwiniętymi skrzydłami, z dziobem i szponami złotymi, umieszczony w czerwonym polu tarczy."
	icon_state = "godlo_drewno"

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
	result_path = /obj/machinery/godlo/czarne

/obj/machinery/godlo/czarne
	name = "godło w czarnej ramie"
	desc = "Wizerunek orła białego ze złotą koroną na głowie zwróconej w prawo, z rozwiniętymi skrzydłami, z dziobem i szponami złotymi, umieszczony w czerwonym polu tarczy."
	icon_state = "godlo_czarne"
	godlo = 1

/datum/crafting_recipe/godlo_czarne
	name = "godło w czarnej ramie"
	result = /obj/item/wallframe/godlo/godlo_czarne
	time = 20
	reqs = list(/obj/item/stack/sheet/mineral/wood = 4,
				/obj/item/clothing/under/color/red = 1,
				/obj/item/clothing/under/color/white = 1)
	category = CAT_MISC
