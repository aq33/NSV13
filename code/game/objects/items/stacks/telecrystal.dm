/obj/item/stack/telecrystal
	name = "telecrystal"
	desc = "It seems to be pulsing with suspiciously enticing energies."
	singular_name = "telecrystal"
	icon = 'icons/obj/telescience.dmi'
	icon_state = "telecrystal"
	w_class = WEIGHT_CLASS_TINY
	max_amount = 50
	item_flags = NOBLUDGEON
	merge_type = /obj/item/stack/telecrystal

/obj/item/stack/telecrystal/attack(mob/target, mob/user)
	if(target == user) //You can't go around smacking people with crystals to find out if they have an uplink or not.
		for(var/obj/item/implant/uplink/I in target)
			if(I?.imp_in)
				var/datum/component/uplink/hidden_uplink = I.GetComponent(/datum/component/uplink)
				if(hidden_uplink)
					hidden_uplink.telecrystals += amount
					use(amount)
					to_chat(user, "<span class='notice'>Przyciskasz [src] do siebie i ładujesz swój ukryty uplink.</span>")
	else
		return ..()

/obj/item/stack/telecrystal/afterattack(obj/item/I, mob/user, proximity)
	. = ..()
	if(istype(I, /obj/item/computer_hardware/hard_drive/role/virus/frame))
		var/obj/item/computer_hardware/hard_drive/role/virus/frame/cart = I
		if(!cart.charges)
			to_chat(user, "<span class='notice'>[cart] nie ma ładunków i odrzuca [src].</span>")
			return
		cart.telecrystals += amount
		use(amount)
		to_chat(user, "<span class='notice'>Wsuwasz [src] do [cart]. Przy następnym użyciu da też telekryształy.</span>")

/obj/item/stack/telecrystal/five
	amount = 5

/obj/item/stack/telecrystal/twenty
	amount = 20
