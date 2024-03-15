//////////////////////
//Krzyże
//////////////////////
#define PLACE_SPEED 37

/obj/structure/wallframe/kszysz
	icon = 'aquila/icons/obj/kszysz.dmi'
	layer = ABOVE_WINDOW_LAYER
	anchored = TRUE

/obj/structure/wallframe/kszysz/Initialize(mapload)
	. = ..()

/obj/structure/wallframe/kszysz/attackby(obj/item/I, mob/user, params)
	. = ..()
	to_chat(user, "<span class='notice'>Zdejmujesz krzyż ze ściany. Świętokradztwo! Raz powieszonego krzyża nie można już nigdy zdjąć; przygotuj się na konsekwencje.</span>")
	roll_and_drop(user.loc)

/obj/structure/wallframe/kszysz/attack_hand(mob/user)
	. = ..()
	if(.)
		return
	visible_message("[user] zdejmuje [src] ze ściany! Świętokradztwo!" )
		return

/obj/structure/wallframe/kszysz/proc/roll_and_drop(loc)
	pixel_x = 0
	pixel_y = 0
	var/obj/item/kszysz/P = new(loc, src)
	forceMove(P)
	return P

//separated to reduce code duplication. Moved here for ease of reference and to unclutter r_wall/attackby()
/turf/closed/wall/proc/place_kszysz(obj/item/kszysz/P, mob/user)
	if(!P.kszysz_structure)
		to_chat(user, "<span class='warning'>[P] has no kszysz... inside it? Inform a coder!</span>")
		return

	// Deny placing kszyszs on currently-diagonal walls, although the wall may change in the future.
	if (smooth & SMOOTH_DIAGONAL)
		for (var/O in overlays)
			var/image/I = O
			if(copytext(I.icon_state, 1, 3) == "d-") //3 == length("d-") + 1
				return

	var/stuff_on_wall = 0
	for(var/obj/O in contents) //Let's see if it already has a kszysz on it or too much stuff
		if(istype(O, /obj/structure/wallframe/kszysz))
			to_chat(user, "<span class='warning'>Ściana jest zbyt zagracona, by umieścić krzyż!</span>")
			return
		stuff_on_wall++
		if(stuff_on_wall == 3)
			to_chat(user, "<span class='warning'>Ściana jest zbyt zagracona, by umieścić krzyż!</span>")
			return

	to_chat(user, "<span class='notice'>Kładziesz krzyż na ścianie...</span>")

	var/obj/structure/wallframe/kszysz/D = P.kszysz_structure

	var/temp_loc = get_turf(user)
	flick("kszysz_being_set",D)
	D.forceMove(src)
	qdel(P)	//delete it now to cut down on sanity checks afterwards. Agouri's code supports rerolling it anyway

	if(do_after(user, PLACE_SPEED, target=src))
		if(!D || QDELETED(D))
			return

		if(iswallturf(src) && user && user.loc == temp_loc)	//Let's check if everything is still there
			to_chat(user, "<span class='notice'>You place the kszysz!</span>")
			return

	to_chat(user, "<span class='notice'>krzyż spadł!</span>")
	D.roll_and_drop(temp_loc)

// Various possible kszyszs follow

/obj/structure/wallframe/kszysz/kszysz_drewniany
	name = "drewniany krzyż"
	desc = "Panie, zmiłuj się nad nami"
	icon_state = "kszysz_drewn"

/obj/structure/wallframe/kszysz/kszysz_zloty
	name = "złoty krzyż"
	desc = "Panie, zmiłuj się nad nami - ale ze stylem."
	icon_state = "kszysz_zloty"

#undef PLACE_SPEED

///////////////////
//Godła
///////////////////
#define PLACE_SPEED 37

/obj/structure/wallframe/godlo
	icon = 'aquila/icons/obj/godla.dmi'
	layer = ABOVE_WINDOW_LAYER
	anchored = TRUE

/obj/structure/wallframe/godlo/Initialize(mapload)
	. = ..()

/obj/structure/wallframe/godlo/attackby(obj/item/I, mob/user, params)
	. = ..()
	to_chat(user, "<span class='notice'>Zdejmujesz godło ze ściany. Świętokradztwo! Raz powieszonego godła nie można już nigdy zdjąć; przygotuj się na konsekwencje.</span>")
	roll_and_drop(user.loc)

/obj/structure/wallframe/godlo/attack_hand(mob/user)
	. = ..()
	if(.)
		return
	visible_message("[user] zdejmuje [src] ze ściany! Świętokradztwo!" )
		return

/obj/structure/wallframe/godlo/proc/roll_and_drop(loc)
	pixel_x = 0
	pixel_y = 0
	var/obj/item/godlo/P = new(loc, src)
	forceMove(P)
	return P

//separated to reduce code duplication. Moved here for ease of reference and to unclutter r_wall/attackby()
/turf/closed/wall/proc/place_godlo(obj/item/godlo/P, mob/user)
	if(!P.godlo_structure)
		to_chat(user, "<span class='warning'>[P] has no godlo... inside it? Inform a coder!</span>")
		return

	// Deny placing godlos on currently-diagonal walls, although the wall may change in the future.
	if (smooth & SMOOTH_DIAGONAL)
		for (var/O in overlays)
			var/image/I = O
			if(copytext(I.icon_state, 1, 3) == "d-") //3 == length("d-") + 1
				return

	var/stuff_on_wall = 0
	for(var/obj/O in contents) //Let's see if it already has a godlo on it or too much stuff
		if(istype(O, /obj/structure/wallframe/godlo))
			to_chat(user, "<span class='warning'>Ściana jest zbyt zagracona, by umieścić godło!</span>")
			return
		stuff_on_wall++
		if(stuff_on_wall == 3)
			to_chat(user, "<span class='warning'>Ściana jest zbyt zagracona, by umieścić godło!</span>")
			return

	to_chat(user, "<span class='notice'>Kładziesz godło na ścianie...</span>")

	var/obj/structure/wallframe/godlo/D = P.godlo_structure

	var/temp_loc = get_turf(user)
	flick("godlo_being_set",D)
	D.forceMove(src)
	qdel(P)	//delete it now to cut down on sanity checks afterwards. Agouri's code supports rerolling it anyway

	if(do_after(user, PLACE_SPEED, target=src))
		if(!D || QDELETED(D))
			return

		if(iswallturf(src) && user && user.loc == temp_loc)	//Let's check if everything is still there
			to_chat(user, "<span class='notice'>You place the godlo!</span>")
			return

	to_chat(user, "<span class='notice'>godło spadł!</span>")
	D.roll_and_drop(temp_loc)

// Various possible godlos follow

/obj/structure/wallframe/godlo/godlo_drewniane
	name = "godło w drewnianej ramie"
	desc = "Wizerunek orła białego ze złotą koroną na głowie zwróconej w prawo, z rozwiniętymi skrzydłami, z dziobem i szponami złotymi, umieszczony w czerwonym polu tarczy."
	icon_state = "godlo_drewno"

/obj/structure/wallframe/godlo/godlo_czarne
	name = "godło w czarnej ramie"
	desc = "Wizerunek orła białego ze złotą koroną na głowie zwróconej w prawo, z rozwiniętymi skrzydłami, z dziobem i szponami złotymi, umieszczony w czerwonym polu tarczy."
	icon_state = "godlo_czarne"

#undef PLACE_SPEED