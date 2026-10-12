/obj/item/computer_hardware/ai_slot
	name = "intelliCard interface slot"
	desc = "A module allowing this computer to interface with most common intelliCard modules. Necessary for some programs to run properly."
	power_usage = 100 //W
	icon_state = "card_mini"
	w_class = WEIGHT_CLASS_SMALL
	device_type = MC_AI
	expansion_hw = TRUE

	var/obj/item/aicard/stored_card
	var/locked = FALSE

/obj/item/computer_hardware/ai_slot/handle_atom_del(atom/A)
	if(A == stored_card)
		try_eject(forced = TRUE)
	. = ..()

/obj/item/computer_hardware/ai_slot/examine(mob/user)
	. = ..()
	if(stored_card)
		. += "Wygląda na to, że załadowano intelliCard. Przycisk ręcznego wysuwania chroni mały otwór. Śrubokręt prawdopodobnie by go wcisnął."

/obj/item/computer_hardware/ai_slot/try_insert(obj/item/I, mob/living/user = null)
	if(!holder)
		return FALSE

	if(!istype(I, /obj/item/aicard))
		return FALSE

	if(stored_card)
		to_chat(user, "<span class='warning'>Próbujesz włożyć [I] do [src], ale gniazdo jest zajęte.</span>")
		return FALSE
	if(user && !user.transferItemToLoc(I, src))
		return FALSE

	stored_card = I
	to_chat(user, "<span class='notice'>Wkładasz [I] do [src].</span>")

	return TRUE


/obj/item/computer_hardware/ai_slot/try_eject(mob/living/user = null, forced = FALSE)
	if(!stored_card)
		to_chat(user, "<span class='warning'>W [src] nie ma karty.</span>")
		return FALSE

	if(locked && !forced)
		to_chat(user, "<span class='warning'>Zabezpieczenia nie pozwalają wyjąć karty, dopóki rekonstrukcja się nie zakończy...</span>")
		return FALSE

	if(stored_card)
		to_chat(user, "<span class='notice'>Wysuwasz [stored_card] z [src].</span>")
		locked = FALSE
		if(user && in_range(src, user))
			user.put_in_hands(stored_card)
		else
			stored_card.forceMove(drop_location())
		stored_card = null
		return TRUE
	return FALSE

/obj/item/computer_hardware/ai_slot/attackby(obj/item/I, mob/living/user)
	if(..())
		return
	if(I.tool_behaviour == TOOL_SCREWDRIVER)
		to_chat(user, "<span class='notice'>Wciskasz przycisk ręcznego wysuwania za pomocą [I].</span>")
		try_eject(user, TRUE)
		return
