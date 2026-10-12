/obj/item/pai_cable
	desc = "A flexible coated cable with a universal jack on one end."
	name = "data cable"
	icon = 'icons/obj/power.dmi'
	icon_state = "wire1"
	item_flags = NOBLUDGEON
	var/obj/machinery/machine

/obj/item/pai_cable/proc/plugin(obj/machinery/M, mob/living/user)
	if(!user.transferItemToLoc(src, M))
		return
	user.visible_message("[user] wkłada [src] do portu danych [M].", "<span class='notice'>Wkładasz [src] do portu danych [M].</span>", "<span class='italics'>Słyszysz satysfakcjonujące kliknięcie wtyku zatrzaskującego się na miejscu.</span>")
	machine = M
