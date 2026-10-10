// CARDS AGAINST SPESS
// This is a parody of Cards Against Humanity (https://en.wikipedia.org/wiki/Cards_Against_Humanity)
// which is licensed under CC BY-NC-SA 2.0, the full text of which can be found at the following URL:
// https://creativecommons.org/licenses/by-nc-sa/2.0/legalcode
// Original code by Zuhayr, Polaris Station, ported with modifications
/datum/playingcard
	var/name = "playing card"
	var/card_icon = "card_back"
	var/suit
	var/number

/obj/item/toy/cards/deck/cas
	name = "\improper CAS deck (white)"
	desc = "A deck for the game Cards Against Spess, still popular after all these centuries. Warning: may include traces of broken fourth wall. This is the white deck."
	icon = 'icons/obj/toy.dmi'
	icon_state = "deck_caswhite_full"
	deckstyle = "caswhite"
	var/card_face = "cas_white"
	var/blanks = 25
	var/decksize = 150
	var/card_text_file = "strings/cas_white.txt"
	var/list/allcards = list()

/obj/item/toy/cards/deck/cas/black
	name = "\improper CAS deck (black)"
	desc = "A deck for the game Cards Against Spess, still popular after all these centuries. Warning: may include traces of broken fourth wall. This is the black deck."
	icon_state = "deck_casblack_full"
	deckstyle = "casblack"
	card_face = "cas_black"
	blanks = 0
	decksize = 50
	card_text_file = "strings/cas_black.txt"

/obj/item/toy/cards/deck/cas/populate_deck()
	var/static/list/cards_against_space = list("cas_white" = world.file2list("strings/cas_white.txt"),"cas_black" = world.file2list("strings/cas_black.txt"))
	allcards = cards_against_space[card_face]
	var/list/possiblecards = allcards.Copy()
	if(possiblecards.len < decksize) // sanity check
		decksize = (possiblecards.len - 1)
	var/list/randomcards = list()
	for(var/x in 1 to decksize)
		randomcards += pick_n_take(possiblecards)
	for(var/x in 1 to randomcards.len)
		var/cardtext = randomcards[x]
		var/datum/playingcard/P
		P = new()
		P.name = "[cardtext]"
		P.card_icon = "[src.card_face]"
		cards += P
	if(!blanks)
		return
	for(var/x in 1 to blanks)
		var/datum/playingcard/P
		P = new()
		P.name = "Blank Card"
		P.card_icon = "cas_white"
		cards += P
	shuffle_inplace(cards) // distribute blank cards throughout deck

/obj/item/toy/cards/deck/cas/draw_card(mob/user)
	if(isliving(user))
		var/mob/living/L = user
		if(!(L.mobility_flags & MOBILITY_PICKUP))
			return
	if(cards.len == 0)
		to_chat(user, "<span class='warning'>Nie ma już kart do dobrania!</span>")
		return
	var/obj/item/toy/cards/singlecard/cas/H = new/obj/item/toy/cards/singlecard/cas(user.loc)
	var/datum/playingcard/choice = cards[1]
	if (choice.name == "Blank Card")
		H.blank = 1
	H.name = choice.name
	H.buffertext = choice.name
	H.icon_state = choice.card_icon
	H.card_face = choice.card_icon
	H.parentdeck = src
	src.cards -= choice
	user.put_in_hands(H)
	user.visible_message("[user] dobiera kartę z talii.", "<span class='notice'>Dobierasz kartę z talii.</span>")
	update_icon()

/obj/item/toy/cards/deck/cas/attackby(obj/item/I, mob/living/user, params)
	if(istype(I, /obj/item/toy/cards/singlecard/cas))
		var/obj/item/toy/cards/singlecard/cas/SC = I
		if(!user.temporarilyRemoveItemFromInventory(SC))
			to_chat(user, "<span class='warning'>Karta przykleiła ci się do ręki, nie możesz dodać jej do talii!</span>")
			return
		var/datum/playingcard/RC // replace null datum for the re-added card
		RC = new()
		RC.name = "[SC.name]"
		RC.card_icon = SC.card_face
		cards += RC
		user.visible_message("[user] dokłada kartę na spód talii.","<span class='notice'>Dokładasz kartę na spód talii.</span>")
		qdel(SC)
	update_icon()

/obj/item/toy/cards/deck/cas/update_icon()
	if(cards.len < 26)
		icon_state = "deck_[deckstyle]_low"

/obj/item/toy/cards/singlecard/cas
	name = "CAS card"
	desc = "A CAS card."
	icon_state = "cas_white"
	flipped = 0
	var/card_face = "cas_white"
	var/blank = 0
	var/buffertext = "Zabawny kawałek tekstu."

/obj/item/toy/cards/singlecard/cas/examine(mob/user)
	. = ..()
	if (flipped)
		. += "<span class='notice'>Karta leży rewersem do góry.</span>"
	else if (blank)
		. += "<span class='notice'>Karta jest pusta. Napisz coś na niej długopisem.</span>"
	else
		. += "<span class='notice'>Na karcie jest napisane: [name]</span>"
	. += "<span class='notice'>Alt-klik, by ją odwrócić.</span>"

/obj/item/toy/cards/singlecard/cas/Flip()
	set name = "Flip Card"
	set category = "Object"
	set src in range(1)
	if(!ishuman(usr) || !usr.canUseTopic(src, BE_CLOSE))
		return
	if(!flipped)
		name = "CAS card"
	else if(flipped)
		name = buffertext
	flipped = !flipped
	update_icon()

/obj/item/toy/cards/singlecard/cas/AltClick(mob/living/user)
	if(!ishuman(user) || !user.canUseTopic(src, BE_CLOSE))
		return
	Flip()

/obj/item/toy/cards/singlecard/cas/update_icon()
	if(flipped)
		icon_state = "[card_face]_flipped"
	else
		icon_state = "[card_face]"

/obj/item/toy/cards/singlecard/cas/attackby(obj/item/I, mob/living/user, params)
	if(istype(I, /obj/item/pen))
		if(!user.is_literate())
			to_chat(user, "<span class='notice'>Gryzmolisz nieczytelnie na [src]!</span>")
			return
		if(!blank)
			to_chat(user, "Nie możesz pisać na tej karcie.")
			return
		var/cardtext = stripped_input(user, "Co chcesz napisać na karcie?", "Pisanie na karcie", "", 50)
		if(!cardtext || !user.canUseTopic(src, BE_CLOSE))
			return
		name = cardtext
		buffertext = cardtext
		blank = 0
