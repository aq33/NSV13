/////////////////
//Krzyże
//////////////////
/obj/structure/sign/kszysz
	icon = 'aquila/icons/obj/kszysz.dmi'
	layer = ABOVE_WINDOW_LAYER

/turf/closed/wall/proc/place_kszysz(obj/item/wallframe/kszysz/P, mob/user)
	to_chat(user, "<span class='notice'>Wieszasz krzyż na ścianie... Akcja godna roku 1997.</span>")
	var/obj/structure/sign/kszysz/D = P.kszysz_structure

/obj/structure/sign/kszysz/kszysz_drewniany
	name = "drewniany krzyż"
	desc = "Panie, zmiłuj się nad nami"
	icon_state = "kszysz_drewn"

/obj/structure/sign/kszysz/kszysz_zloty
	name = "złoty krzyż"
	desc = "Panie, zmiłuj się nad nami - ale ze stylem."
	icon_state = "kszysz_zloty"

/////////////////
//Godła
//////////////////
/obj/structure/sign/godlo
	icon = 'aquila/icons/obj/godla.dmi'
	layer = ABOVE_WINDOW_LAYER

/turf/closed/wall/proc/place_godlo(obj/item/wallframe/godlo/P, mob/user)
	to_chat(user, "<span class='notice'>Wieszasz godło na ścianie.</span>")
	var/obj/structure/sign/godlo/D = P.godlo_structure

/obj/structure/sign/godlo/godlo_drewniane
	name = "godło w drewnianej ramie"
	desc = "Wizerunek orła białego ze złotą koroną na głowie zwróconej w prawo, z rozwiniętymi skrzydłami, z dziobem i szponami złotymi, umieszczony w czerwonym polu tarczy."
	icon_state = "godlo_drewno"

/obj/structure/sign/godlo/godlo_czarne
	name = "godło w czarnej ramie"
	desc = "Wizerunek orła białego ze złotą koroną na głowie zwróconej w prawo, z rozwiniętymi skrzydłami, z dziobem i szponami złotymi, umieszczony w czerwonym polu tarczy."
	icon_state = "godlo_czarne"

