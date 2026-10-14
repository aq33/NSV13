/**
 * Nietypowe zamówienia, np. ubranie dla ćmy, bez dopisywania wyjątków w kodzie lokali i klientów.
 */
/datum/custom_order

/datum/custom_order/New(datum/venue/our_venue)
	return ..()

/**
 * Co trafia na tablicę robota jako jego zamówienie.
 * Zwykle sam datum, ale np. ubranie ćmy zwraca zwykły typ przedmiotu.
 */
/datum/custom_order/proc/dispense_order()
	return src

///Czy podany przedmiot pasuje do zamówienia. Ma znaczenie tylko, gdy dispense_order zwróciło src
/datum/custom_order/proc/is_correct_order(obj/item/object_used)
	return FALSE

///Dymek nad robotem
/datum/custom_order/proc/get_order_appearance(datum/venue/our_venue)
	return image(icon = 'aquila/icons/obj/restaurant/restaurant_portal.dmi', icon_state = "thought_bubble")

///Nazwa zamówienia
/datum/custom_order/proc/get_order_name(datum/venue/our_venue)
	return "coś nietypowego"

///Co robot mówi, gdy zamawia
/datum/custom_order/proc/get_order_line(datum/venue/our_venue)
	return "Poproszę: [get_order_name(our_venue)]."

///Ćma zamawia ubranie, które ma na sobie osoba otwierająca lokal
/datum/custom_order/moth_clothing
	///Typ ubrania, które chce dostać ćma
	var/wanted_clothing_type

/datum/custom_order/moth_clothing/New(datum/venue/our_venue)
	. = ..()
	var/mob/living/carbon/buffet = our_venue.opened_by?.resolve()
	var/list/orderable = list()
	if(istype(buffet))
		if(!QDELETED(buffet.head))
			orderable[buffet.head.type] = 5
		if(!QDELETED(buffet.gloves))
			orderable[buffet.gloves.type] = 5
		if(!QDELETED(buffet.shoes))
			orderable[buffet.shoes.type] = 1
	if(!length(orderable))
		orderable = list(
			/obj/item/clothing/head/chefhat = 3,
			/obj/item/clothing/shoes/sneakers/black = 3,
			/obj/item/clothing/gloves/color/black = 1,
		)
	wanted_clothing_type = pickweight(orderable)

/datum/custom_order/moth_clothing/get_order_appearance(datum/venue/our_venue)
	return our_venue.get_food_appearance(wanted_clothing_type)

/datum/custom_order/moth_clothing/get_order_name(datum/venue/our_venue)
	return our_venue.get_order_name(wanted_clothing_type)

/datum/custom_order/moth_clothing/dispense_order()
	. = wanted_clothing_type
	qdel(src) // Datum nie jest już potrzebny, na tablicy zostaje sam typ ubrania
