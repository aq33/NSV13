/obj/item/firing_pin
	name = "electronic firing pin"
	desc = "A small authentication device, to be inserted into a firearm receiver to allow operation. NT safety regulations require all new designs to incorporate one."
	icon = 'icons/obj/device.dmi'
	icon_state = "firing_pin"
	item_state = "pen"
	flags_1 = CONDUCT_1
	w_class = WEIGHT_CLASS_TINY
	attack_verb = list("szturcha")
	var/fail_message = "<span class='warning'>NIEPRAWIDŁOWY UŻYTKOWNIK.</span>"
	var/selfdestruct = 0 // Explode when user check is failed.
	var/force_replace = 0 // Can forcefully replace other pins.
	var/pin_removeable = 0 // Can be replaced by any pin.
	var/obj/item/gun/gun

/obj/item/firing_pin/New(newloc)
	..()
	if(istype(newloc, /obj/item/gun))
		gun = newloc

/obj/item/firing_pin/afterattack(atom/target, mob/user, proximity_flag)
	. = ..()
	if(proximity_flag)
		if(istype(target, /obj/item/gun))
			var/obj/item/gun/G = target
			if(G.no_pin_required)
				return
			if(G.pin && (force_replace || G.pin.pin_removeable))
				G.pin.forceMove(get_turf(G))
				G.pin.gun_remove(user)
				to_chat(user, "<span class ='notice'>Wyjmujesz starą iglicę z [G].</span>")

			if(!G.pin)
				if(!user.temporarilyRemoveItemFromInventory(src))
					return
				gun_insert(user, G)
				to_chat(user, "<span class ='notice'>Wkładasz [src] do [G].</span>")
			else
				to_chat(user, "<span class ='notice'>Ta broń ma już zamontowaną iglicę.</span>")

/obj/item/firing_pin/emag_act(mob/user)
	if(obj_flags & EMAGGED)
		return
	obj_flags |= EMAGGED
	to_chat(user, "<span class='notice'>Obchodzisz mechanizm uwierzytelniania.</span>")

/obj/item/firing_pin/proc/gun_insert(mob/living/user, obj/item/gun/G)
	gun = G
	forceMove(gun)
	gun.pin = src
	return

/obj/item/firing_pin/proc/gun_remove(mob/living/user)
	gun.pin = null
	gun = null
	return

/obj/item/firing_pin/proc/pin_auth(mob/living/user)
	return TRUE

/obj/item/firing_pin/proc/auth_fail(mob/living/user)
	if(user)
		user.show_message(fail_message, MSG_VISUAL)
	if(selfdestruct)
		if(user)
			user.show_message("<span class='danger'>AUTODESTRUKCJA...</span><br>", MSG_VISUAL)
			to_chat(user, "<span class='userdanger'>[gun] explodes!</span>")
		explosion(get_turf(gun), -1, 0, 2, 3)
		if(gun)
			qdel(gun)



/obj/item/firing_pin/magic
	name = "magic crystal shard"
	desc = "A small enchanted shard which allows magical weapons to fire."


// Test pin, works only near firing range.
/obj/item/firing_pin/test_range
	name = "test-range firing pin"
	desc = "This safety firing pin allows weapons to be fired within proximity to a firing range."
	fail_message = "<span class='warning'>KONTROLA STRZELNICY NIEUDANA.</span>"
	pin_removeable = TRUE

/obj/item/firing_pin/test_range/pin_auth(mob/living/user)
	if(!istype(user))
		return FALSE
	if(locate(/obj/machinery/magnetic_controller) in range(3, user))
		return TRUE
	return FALSE


// Implant pin, checks for implant
/obj/item/firing_pin/implant
	name = "implant-keyed firing pin"
	desc = "This is a security firing pin which only authorizes users who are implanted with a certain device."
	fail_message = "<span class='warning'>KONTROLA IMPLANTU NIEUDANA.</span>"
	var/obj/item/implant/req_implant = null

/obj/item/firing_pin/implant/pin_auth(mob/living/user)
	if(user)
		for(var/obj/item/implant/I in user.implants)
			if(req_implant && I.type == req_implant)
				return TRUE
	return FALSE

/obj/item/firing_pin/implant/mindshield
	name = "mindshield firing pin"
	desc = "This Security firing pin authorizes the weapon for only mindshield-implanted users."
	icon_state = "firing_pin_loyalty"
	req_implant = /obj/item/implant/mindshield

/obj/item/firing_pin/implant/pindicate
	name = "syndicate firing pin"
	icon_state = "firing_pin_pindi"
	req_implant = /obj/item/implant/weapons_auth



// Honk pin, clown's joke item.
// Can replace other pins. Replace a pin in cap's laser for extra fun!
/obj/item/firing_pin/clown
	name = "hilarious firing pin"
	desc = "Advanced clowntech that can convert any firearm into a far more useful object."
	color = "#FFFF00"
	fail_message = "<span class='warning'>HONK!</span>"
	force_replace = TRUE

/obj/item/firing_pin/clown/pin_auth(mob/living/user)
	playsound(src, 'sound/items/bikehorn.ogg', 50, 1)
	return FALSE

// Ultra-honk pin, clown's deadly joke item.
// A gun with ultra-honk pin is useful for clown and useless for everyone else.
/obj/item/firing_pin/clown/ultra/pin_auth(mob/living/user)
	playsound(src.loc, 'sound/items/bikehorn.ogg', 50, 1)
	if(user && (!(HAS_TRAIT(user, TRAIT_CLUMSY)) && !(user.mind && user.mind.assigned_role == JOB_NAME_CLOWN)))
		return FALSE
	return TRUE

/obj/item/firing_pin/clown/ultra/gun_insert(mob/living/user, obj/item/gun/G)
	..()
	G.clumsy_check = FALSE

/obj/item/firing_pin/clown/ultra/gun_remove(mob/living/user)
	gun.clumsy_check = initial(gun.clumsy_check)
	..()

// Now two times deadlier!
/obj/item/firing_pin/clown/ultra/selfdestruct
	desc = "Advanced clowntech that can convert any firearm into a far more useful object. It has a small nitrobananium charge on it."
	selfdestruct = TRUE


// DNA-keyed pin.
// When you want to keep your toys for yourself.
/obj/item/firing_pin/dna
	name = "DNA-keyed firing pin"
	desc = "This is a DNA-locked firing pin which only authorizes one user. Attempt to fire once to DNA-link."
	icon_state = "firing_pin_dna"
	fail_message = "<span class='warning'>KONTROLA DNA NIEUDANA.</span>"
	var/unique_enzymes = null

/obj/item/firing_pin/dna/afterattack(atom/target, mob/user, proximity_flag)
	. = ..()
	if(proximity_flag && iscarbon(target))
		var/mob/living/carbon/M = target
		if(M.dna && M.dna.unique_enzymes)
			unique_enzymes = M.dna.unique_enzymes
			to_chat(user, "<span class='notice'>BLOKADA DNA USTAWIONA.</span>")

/obj/item/firing_pin/dna/pin_auth(mob/living/carbon/user)
	if(user && user.dna && user.dna.unique_enzymes)
		if(user.dna.unique_enzymes == unique_enzymes)
			return TRUE
	return FALSE

/obj/item/firing_pin/dna/auth_fail(mob/living/carbon/user)
	if(!unique_enzymes)
		if(user?.dna?.unique_enzymes)
			unique_enzymes = user.dna.unique_enzymes
			to_chat(user, "<span class='notice'>BLOKADA DNA USTAWIONA.</span>")
	else
		..()

/obj/item/firing_pin/dna/dredd
	desc = "This is a DNA-locked firing pin which only authorizes one user. Attempt to fire once to DNA-link. It has a small explosive charge on it."
	selfdestruct = TRUE

// Paywall pin, brought to you by ARMA 3 DLC.
// Checks if the user has a valid bank account on an ID and if so attempts to extract a one-time payment to authorize use of the gun. Otherwise fails to shoot.
/obj/item/firing_pin/paywall
	name = "paywall firing pin"
	desc = "A firing pin with a built-in configurable paywall."
	color = "#FFD700"
	fail_message = ""
	var/list/gun_owners = list() //list of people who've accepted the license prompt. If this is the multi-payment pin, then this means they accepted the waiver that each shot will cost them money
	var/payment_amount //how much gets paid out to license yourself to the gun
	var/obj/item/card/id/pin_owner
	var/multi_payment = FALSE //if true, user has to pay everytime they fire the gun
	var/owned = FALSE
	var/active_prompt = FALSE //purchase prompt to prevent spamming it

/obj/item/firing_pin/paywall/attack_self(mob/user)
	multi_payment = !multi_payment
	to_chat(user, "<span class='notice'>Ustawiasz iglicę na [( multi_payment ) ? "płatność za każdy strzał" : "jednorazową opłatę licencyjną"].</span>")

/obj/item/firing_pin/paywall/examine(mob/user)
	. = ..()
	if(pin_owner)
		. += "<span class='notice'>Ta iglica jest obecnie upoważniona do wpłat na konto [pin_owner.registered_name].</span>"

/obj/item/firing_pin/paywall/gun_insert(mob/living/user, obj/item/gun/G)
	if(!pin_owner)
		to_chat(user, "<span class='warning'>BŁĄD: przed zamontowaniem iglicy przeciągnij ważną kartę identyfikacyjną!</span>")
		return
	gun = G
	forceMove(gun)
	gun.pin = src
	if(multi_payment)
		gun.desc += "<span class='notice'> Koszt jednego strzału z [gun.name]: [payment_amount] kr.</span>"
		return
	gun.desc += "<span class='notice'> Koszt licencji na [gun.name]: [payment_amount] kr.</span>"
	return


/obj/item/firing_pin/paywall/gun_remove(mob/living/user)
	gun.desc = initial(desc)
	..()

/obj/item/firing_pin/paywall/attackby(obj/item/M, mob/user, params)
	if(istype(M, /obj/item/card/id))
		var/obj/item/card/id/id = M
		if(!id.registered_account)
			to_chat(user, "<span class='warning'>BŁĄD: karta identyfikacyjna nie ma zarejestrowanego konta bankowego!</span>")
			return
		if(id != pin_owner && owned)
			to_chat(user, "<span class='warning'>BŁĄD: ta iglica została już autoryzowana!</span>")
			return
		if(id == pin_owner)
			to_chat(user, "<span class='notice'>Odłączasz kartę od iglicy.</span>")
			gun_owners -= user
			pin_owner = null
			owned = FALSE
			return
		var/transaction_amount = input(user, "Podaj prawidłową kwotę wpłaty za zakup broni", "Wpłata") as null|num
		if(transaction_amount < 1)
			to_chat(user, "<span class='warning'>BŁĄD: podano nieprawidłową kwotę.</span>")
			return
		if(!transaction_amount)
			return
		pin_owner = id
		owned = TRUE
		payment_amount = transaction_amount
		gun_owners += user
		to_chat(user, "<span class='notice'>Łączysz kartę z iglicą.</span>")

/obj/item/firing_pin/paywall/pin_auth(mob/living/user)
	if(!istype(user))//nice try commie
		return FALSE
	if(ishuman(user))
		var/datum/bank_account/credit_card_details
		var/mob/living/carbon/human/H = user
		if(H.get_bank_account())
			credit_card_details = H.get_bank_account()
		if(H in gun_owners)
			if(multi_payment && credit_card_details)
				if(credit_card_details.adjust_money(-payment_amount))
					pin_owner.registered_account.adjust_money(payment_amount)
					return TRUE
				to_chat(user, "<span class='warning'>BŁĄD: niewystarczające saldo użytkownika do przeprowadzenia transakcji!</span>")
				return FALSE
			return TRUE
		if(credit_card_details && !active_prompt)
			var/license_request = alert(usr, "Czy chcesz zapłacić [payment_amount] kr za [( multi_payment ) ? "każdy strzał z [gun.name]" : "licencję na użytkowanie [gun.name]"]?", "Zakup broni", "Yes", "No")
			active_prompt = TRUE
			if(!user.canUseTopic(src, BE_CLOSE))
				active_prompt = FALSE
				return FALSE
			switch(license_request)
				if("Yes")
					if(credit_card_details.adjust_money(-payment_amount))
						pin_owner.registered_account.adjust_money(payment_amount)
						gun_owners += H
						to_chat(user, "<span class='notice'>Licencja na broń zakupiona, bezpiecznego dnia!</span>")
						active_prompt = FALSE
						return FALSE //we return false here so you don't click initially to fire, get the prompt, accept the prompt, and THEN the gun
					to_chat(user, "<span class='warning'>BŁĄD: niewystarczające saldo użytkownika do przeprowadzenia transakcji!</span>")
					return FALSE
				if("No")
					to_chat(user, "<span class='warning'>BŁĄD: użytkownik odmówił zakupu licencji na broń!</span>")
					return FALSE
		to_chat(user, "<span class='warning'>BŁĄD: użytkownik nie ma ważnego konta bankowego, z którego można pobrać środki!</span>")
		return FALSE


// Laser tag pins
/obj/item/firing_pin/tag
	name = "laser tag firing pin"
	desc = "A recreational firing pin, used in laser tag units to ensure users have their vests on."
	fail_message = "<span class='warning'>KONTROLA STROJU NIEUDANA.</span>"
	var/obj/item/clothing/suit/suit_requirement = null
	var/tagcolor = ""

/obj/item/firing_pin/tag/pin_auth(mob/living/user)
	if(ishuman(user))
		var/mob/living/carbon/human/M = user
		if(istype(M.wear_suit, suit_requirement))
			return TRUE
	to_chat(user, "<span class='warning'>Musisz mieć na sobie pancerz do laser taga ([tagcolor])!</span>")
	return FALSE

/obj/item/firing_pin/tag/red
	name = "red laser tag firing pin"
	icon_state = "firing_pin_red"
	suit_requirement = /obj/item/clothing/suit/redtag
	tagcolor = "red"

/obj/item/firing_pin/tag/blue
	name = "blue laser tag firing pin"
	icon_state = "firing_pin_blue"
	suit_requirement = /obj/item/clothing/suit/bluetag
	tagcolor = "blue"

/obj/item/firing_pin/Destroy()
	if(gun)
		gun.pin = null
	return ..()
