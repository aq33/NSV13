//Scanner item for the prisoners to redeem sentence time for their work in the workshop

/obj/item/prison_scanner
	name = "prison export scanner"
	desc = "A device used to check objects made in the workshop, to have them cashed out for sentence reductions."
	icon = 'icons/obj/device.dmi'
	icon_state = "export_scanner"
	item_state = "radio"
	lefthand_file = 'icons/mob/inhands/misc/devices_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/misc/devices_righthand.dmi'
	item_flags = NOBLUDGEON
	w_class = WEIGHT_CLASS_SMALL
	siemens_coefficient = 1
	var/obj/item/prison_scanner/linked_id = null //Which prisoner ID is linked to this scanner
	var/list/redeemable = list() //Items ready to be redeemed

/obj/item/prison_scanner/examine(mob/user)
	. = ..()
	if(linked_id)
		. += "<span class='notice'>[src] jest obecnie połączony z kartą ID [linked_id]</span>."
	if(!linked_id)
		. += "<span class='notice'>[src] jest obecnie niepołączony</span>."

/obj/item/prison_scanner/attackby(obj/item/I, mob/living/user, params)
	if(istype(I, /obj/item/card/id/prisoner))
		var/obj/item/card/id/prisoner/C = I
		if(!linked_id)
			linked_id = C.registered_name
			to_chat(user, "<span class='notice'>Skaner połączony z [C.registered_name]!</span>")
		if(linked_id != C.registered_name)
			to_chat(user, "<span class='warning'>Skaner jest już połączony z ID [linked_id]!</span>")
		else if(length(redeemable))
			C.served_time += (15 * redeemable.len)
			redeemable.Cut()
			if(C.served_time >= C.sentence)
				to_chat(user, "<span class='notice>Już odbyłeś karę, nie można odjąć czasu z nieistniejącego wyroku!</span>")
			else
				to_chat(user, "<span class='notice'>Przedmioty wymienione! Pozostało ci do odbycia: [DisplayTimeText((C.sentence - C.served_time)*10, 1)]!</span>")
			linked_id = null
		else
			to_chat(user, "<span class='warning'> Brak przedmiotów do wymiany!</span>")
	else
		. = ..()

/obj/item/prison_scanner/afterattack(obj/O, mob/user, proximity)
	. = ..()
	if(!linked_id)
		to_chat(user, "<span class='warning'>Brak połączonego konta!</span>")
	else if(!istype(O, /obj/item/food/donut) && !istype(O, /obj/item/toy/plush))
		to_chat(user, "<span class='warning'>Nieprawidłowy przedmiot! Skanuj tylko pączki lub pluszaki zrobione w warsztacie!</span>")
	else
		if(O.obj_flags & SCANNED)
			to_chat(user, "<span class='warning'>[O.name] został już zeskanowany!</span>")
		else
			redeemable += O
			O.obj_flags |= SCANNED
			to_chat(user, "<span class='notice'>[O.name] zeskanowano! Przeciągnij kartę ID przez skaner, gdy zechcesz wymienić zarobiony czas.</span>")
