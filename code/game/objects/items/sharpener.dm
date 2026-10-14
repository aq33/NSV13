/obj/item/sharpener
	name = "whetstone"
	icon = 'icons/obj/service/kitchen.dmi'
	icon_state = "sharpener"
	desc = "A block that makes things sharp."
	force = 5
	var/used = 0
	var/increment = 4
	var/max = 30
	var/prefix = "sharpened"
	var/requires_sharpness = 1


/obj/item/sharpener/attackby(obj/item/I, mob/user, params)
	if(used)
		to_chat(user, "<span class='warning'>Osełka jest zbyt zużyta, by znów jej użyć!</span>")
		return
	if(I.force >= max || I.throwforce >= max)//no esword sharpening
		to_chat(user, "<span class='warning'>[I] jest zbyt potężny, by dalej go ostrzyć!</span>")
		return
	if(requires_sharpness && !I.is_sharp())
		to_chat(user, "<span class='warning'>Możesz ostrzyć tylko przedmioty, które już są ostre, na przykład noże!</span>")
		return
	if(istype(I, /obj/item/melee/transforming/energy))
		to_chat(user, "<span class='warning'>Raczej to nie [I] zostanie zmodyfikowany, jeśli użyjesz go na [src]!</span>")
		return

	var/signal_out = SEND_SIGNAL(I, COMSIG_ITEM_SHARPEN_ACT, increment, max)
	if(signal_out & COMPONENT_BLOCK_SHARPEN_MAXED)
		to_chat(user, "<span class='warning'>[I] jest zbyt potężny, by dalej go ostrzyć!</span>")
		return
	if(signal_out & COMPONENT_BLOCK_SHARPEN_BLOCKED)
		to_chat(user, "<span class='warning'>[I] nie da się teraz naostrzyć!</span>")
		return
	if((signal_out & COMPONENT_BLOCK_SHARPEN_ALREADY) || (I.force > initial(I.force) && !signal_out))
		to_chat(user, "<span class='warning'>[I] był już udoskonalany. Nie da się go bardziej naostrzyć!</span>")
		return
	if(!(signal_out & COMPONENT_BLOCK_SHARPEN_APPLIED))
		I.force = clamp(I.force + increment, 0, max)
	user.visible_message("<span class='notice'>[user] ostrzy [I] za pomocą [src]!</span>", "<span class='notice'>Ostrzysz [I], przez co staje się o wiele groźniejszy niż wcześniej.</span>")
	playsound(src, 'sound/items/unsheath.ogg', 25, 1)
	I.sharpness = IS_SHARP_ACCURATE
	I.bleed_force *= 1.1
	I.throwforce = clamp(I.throwforce + increment, 0, max)
	I.name = "[prefix] [I.name]"
	name = "worn out [name]"
	desc = "[desc] At least, it used to."
	used = 1
	update_icon()

/obj/item/sharpener/super
	name = "super whetstone"
	desc = "A block that will make your weapon sharper than Einstein on adderall."
	increment = 200
	max = 200
	prefix = "super-sharpened"
	requires_sharpness = 0
