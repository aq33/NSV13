/obj/machinery/paystand
	name = "unregistered pay stand"
	desc = "See title."
	icon = 'icons/obj/economy.dmi'
	icon_state = "card_scanner"
	density = TRUE
	anchored = TRUE
	var/locked = FALSE
	var/obj/item/card/id/my_card
	var/obj/item/assembly/signaler/signaler //attached signaler, let people attach signalers that get activated if the user's transaction limit is achieved.
	var/signaler_threshold = 0 //signaler threshold amount
	var/amount_deposited = 0 //keep track of the amount deposited over time so you can pay multiple times to reach the signaler threshold

/obj/machinery/paystand/attackby(obj/item/W, mob/user, params)
	if(istype(W, /obj/item/card/id))
		if(W == my_card)
			locked = !locked
			to_chat(user, "<span class='notice'>[src.locked ? "Blokujesz" : "Odblokowujesz"] śruby stoiska płatniczego.</span>")
			return
		if(!my_card)
			var/obj/item/card/id/assistant_mains_need_to_die = W
			if(assistant_mains_need_to_die.registered_account)
				var/msg = stripped_input(user, "Nazwa stoiska płatniczego:", "Nazywanie stoiska płatniczego", "Super stoisko [user]")
				if(!msg)
					return
				name = msg
				desc = "Owned by [assistant_mains_need_to_die.registered_account.account_holder], pays directly into [user.p_their()] account."
				my_card = assistant_mains_need_to_die
				to_chat(user, "Łączysz stoisko ze swoim kontem.")
				return
		var/obj/item/card/id/vbucks = W
		if(vbucks.registered_account)
			var/momsdebitcard = input(user, "Ile chcesz wpłacić?", "Wpłata") as null|num
			if(momsdebitcard < 1)
				to_chat(user, "<span class='warning'>BŁĄD: podano nieprawidłową kwotę.</span>")
				return
			if(vbucks.registered_account.adjust_money(-momsdebitcard))
				purchase(vbucks.registered_account.account_holder, momsdebitcard)
				to_chat(user, "Dziękujemy za zakup! Sprzedawca został powiadomiony.")
				return
			else
				to_chat(user, "<span class='warning'>BŁĄD: na koncie brakuje środków na tę transakcję.</span>")
				return
		else
			to_chat(user, "<span class='warning'>BŁĄD: do karty identyfikacyjnej nie przypisano konta bankowego.</span>")
			return
	if(istype(W, /obj/item/holochip))
		var/obj/item/holochip/H = W
		var/cashmoney = input(user, "Ile chcesz wpłacić?", "Wpłata") as null|num
		if(H.spend(cashmoney, FALSE))
			purchase(user, cashmoney)
			to_chat(user, "Dziękujemy za zakup! Sprzedawca został powiadomiony.")
			return
		else
			to_chat(user, "<span class='warning'>BŁĄD: brak środków na tę transakcję.</span>")
			return
	if(istype(W, /obj/item/stack/spacecash))
		to_chat(user, "Co to, lata 2000? Tutaj przyjmujemy tylko karty.")
		return
	if(istype(W, /obj/item/coin))
		to_chat(user, "Co to, XIX wiek? Tutaj przyjmujemy tylko karty.")
		return
	if(istype(W, /obj/item/assembly/signaler))
		var/obj/item/assembly/signaler/S = W
		if(S.secured)
			to_chat(user, "<span class='warning'>Aby dodać sygnalizator do stoiska płatniczego, musi być w trybie łączenia!</span>")
			return
		if(!my_card)
			to_chat(user, "<span class='warning'>BŁĄD: do tego stoiska płatniczego nie przypisano jeszcze żadnej karty identyfikacyjnej!</span>")
			return
		if(!signaler)
			var/cash_limit = input(user, "Podaj minimalną kwotę wpłaty, po której zostanie aktywowany sygnalizator.", "Próg aktywacji sygnalizatora") as null|num
			if(cash_limit < 1)
				to_chat(user, "<span class='warning'>BŁĄD: podano nieprawidłową kwotę.</span>")
				return
			if(cash_limit)
				S.forceMove(src)
				signaler = S
				signaler_threshold = cash_limit
				to_chat(user, "Mocujesz sygnalizator do stoiska płatniczego.")
				desc += " Wygląda na to, że do skanera jest przymocowany sygnalizator."
		else
			to_chat(user, "<span class='warning'>Do tego urządzenia jest już przymocowany sygnalizator!</span>")

	if(default_deconstruction_screwdriver(user, "card_scanner", "card_scanner", W))
		return

	else if(default_pry_open(W))
		return

	else if(default_unfasten_wrench(user, W))
		return

	else if(default_deconstruction_crowbar(W))
		return
	else
		return ..()

/obj/machinery/paystand/proc/purchase(buyer, price)
	my_card.registered_account.adjust_money(price)
	my_card.registered_account.bank_card_talk("[buyer] dokonał zakupu w twoim stoisku za [price] kr.")
	amount_deposited = amount_deposited + price
	if(signaler && amount_deposited >= signaler_threshold)
		signaler.activate()
		amount_deposited = 0

/obj/machinery/paystand/default_unfasten_wrench(mob/user, obj/item/I, time = 20)
	if(locked)
		to_chat(user, "<span class='warning'>Śruby kotwiące tego stoiska płatniczego są obecnie zablokowane!</span>")
		return
	. = ..()
