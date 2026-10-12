
/obj/proc/is_modular_computer()
	return

/obj/proc/get_modular_computer_part(part_type)
	return null

/obj/item/modular_computer/is_modular_computer()
	return TRUE

/obj/item/modular_computer/get_modular_computer_part(part_type)
	if(!part_type)
		stack_trace("get_modular_computer_part() called without a valid part_type")
		return null
	return all_components[part_type]


/obj/machinery/modular_computer/is_modular_computer()
	return TRUE

/obj/machinery/modular_computer/get_modular_computer_part(part_type)
	if(!part_type)
		stack_trace("get_modular_computer_part() called without a valid part_type")
		return null
	return cpu?.all_components[part_type]


/obj/proc/get_modular_computer_parts_examine(mob/user)
	. = list()
	if(!is_modular_computer())
		return

	var/user_is_adjacent = Adjacent(user) //don't reveal full details unless they're close enough to see it on the screen anyway.

	var/obj/item/computer_hardware/ai_slot/ai_slot = get_modular_computer_part(MC_AI)
	if(ai_slot)
		if(ai_slot.stored_card)
			if(user_is_adjacent)
				. += "Ma gniazdo na intelliCard, w którym znajduje się: [ai_slot.stored_card.name]"
			else
				. += "Ma gniazdo na intelliCard, które wydaje się zajęte."
			. += "<span class='info'>Alt-klik, by wysunąć intelliCard.</span>"
		else
			. += "Ma gniazdo na intelliCard."

	var/obj/item/computer_hardware/card_slot/card_slot = get_modular_computer_part(MC_CARD)
	var/obj/item/computer_hardware/card_slot/card_slot2 = get_modular_computer_part(MC_CARD2)
	var/multiple_slots = istype(card_slot) && istype(card_slot2)
	if(card_slot)
		if(card_slot?.stored_card || card_slot2?.stored_card)
			var/obj/item/card/id/first_ID = card_slot?.stored_card
			var/obj/item/card/id/second_ID = card_slot2?.stored_card
			var/multiple_cards = istype(first_ID) && istype(second_ID)
			if(user_is_adjacent)
				. += "Ma [multiple_slots ? "dwa gniazda" : "gniazdo"] na karty identyfikacyjne[multiple_cards ? ", w których są [first_ID] i [second_ID]" : ", w jednym z nich jest [first_ID ? first_ID : second_ID]"]."
			else
				. += "Ma [multiple_slots ? "dwa gniazda" : "gniazdo"] na karty identyfikacyjne, [multiple_cards ? "oba wydają się zajęte" : "jedno z nich wydaje się zajęte"]."
			. += "<span class='info'>Alt-klik na [src], by wysunąć [multiple_cards ? "karty identyfikacyjne":"kartę identyfikacyjną"].</span>"
		else
			. += "Ma [multiple_slots ? "dwa gniazda" : "gniazdo"] na karty identyfikacyjne."

	var/obj/item/computer_hardware/printer/printer_slot = get_modular_computer_part(MC_PRINT)
	if(printer_slot)
		. += "Ma zamontowaną drukarkę."
		if(user_is_adjacent)
			. += "Poziom papieru w drukarce: [printer_slot.stored_paper]/[printer_slot.max_paper].</span>"
