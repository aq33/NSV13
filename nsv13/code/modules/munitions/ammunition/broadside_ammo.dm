/obj/item/ship_weapon/ammunition/broadside_shell
	name = "\improper SNBC Type 1 Shell"
	desc = "A large packed shell, complete with powder and projectile, ready to be loaded and fired."
	icon_state = "broadside"
	lefthand_file = 'nsv13/icons/mob/inhands/weapons/bombs_lefthand.dmi'
	righthand_file = 'nsv13/icons/mob/inhands/weapons/bombs_righthand.dmi'
	icon = 'nsv13/icons/obj/munitions.dmi'
	w_class = WEIGHT_CLASS_BULKY
	projectile_type = /obj/item/projectile/bullet/broadside

/obj/item/ship_weapon/ammunition/broadside_shell/plasma
	name = "\improper SNBC Type P Shell"
	desc = "A large packed shell, complete with plasma and projectile, ready to be loaded and fired."
	icon_state = "broadside_plasma"
	lefthand_file = 'nsv13/icons/mob/inhands/weapons/bombs_lefthand.dmi'
	righthand_file = 'nsv13/icons/mob/inhands/weapons/bombs_righthand.dmi'
	icon = 'nsv13/icons/obj/munitions.dmi'
	w_class = WEIGHT_CLASS_BULKY
	projectile_type = /obj/item/projectile/bullet/broadside/plasma

/obj/item/ship_weapon/ammunition/broadside_shell/uranium
	name = "\improper SNBC Type N Shell"
	desc = "A large packed shell, complete with depleted uranium payload, ready to be loaded and fired."
	icon_state = "broadside_uranium"
	lefthand_file = 'nsv13/icons/mob/inhands/weapons/bombs_lefthand.dmi'
	righthand_file = 'nsv13/icons/mob/inhands/weapons/bombs_righthand.dmi'
	icon = 'nsv13/icons/obj/munitions.dmi'
	w_class = WEIGHT_CLASS_BULKY
	projectile_type = /obj/item/projectile/bullet/broadside/uranium

/obj/item/ship_weapon/ammunition/broadside_shell/can_be_pulled(mob/user)
	return TRUE

/obj/item/circuitboard/machine/broadside_shell_packer
	name = "circuit board (Broadside Shell Packer)"
	desc = "Pack the shells and get that ice cream ration pack from the kitchen!"
	icon_state = "generic"
	build_path = /obj/machinery/broadside_shell_packer
	req_components = list(
		/obj/item/stock_parts/manipulator = 2,
		/obj/item/stock_parts/matter_bin = 2,
	)

/obj/machinery/broadside_shell_packer
	name = "\improper Broadside Shell Packer Bench"
	desc = "An automated table that packs broadside shell casings, just add components!"
	icon = 'nsv13/icons/obj/munitions/packing_bench.dmi'
	icon_state = "packing_bench"
	density = TRUE
	anchored = TRUE
	circuit = /obj/item/circuitboard/machine/broadside_shell_packer
	bound_width = 64
	var/casing_amount = 0
	var/load_amount = 0
	var/bag_amount = 0
	var/max_bags = 1
	var/amount_to_pack = 5
	var/obj/item/powder_bag/plasma/plasma = FALSE
	var/obj/item/powder_bag/gunpowder = FALSE
	var/obj/item/ship_weapon/parts/broadside_load/uranium = FALSE
	var/static/list/whitelist = typecacheof(list(
		/obj/item/ship_weapon/parts/broadside_casing,
		/obj/item/ship_weapon/parts/broadside_load,
		/obj/item/powder_bag))

/obj/machinery/broadside_shell_packer/examine(mob/user)
	. = ..()
	. += "Ma łusek: [casing_amount], ładunków: [load_amount], worków: [bag_amount]."
	. += "Pakowarka potrzebuje [amount_to_pack] łusek, [amount_to_pack] ładunków i [max_bags] worka prochu, by spakować [amount_to_pack] pocisków burtowych."

/obj/machinery/broadside_shell_packer/attackby(obj/item/I, mob/living/user, params)
	if(default_deconstruction_screwdriver(user, "[initial(icon_state)]", initial(icon_state), I))
		return TRUE
	if(default_deconstruction_crowbar(I))
		return TRUE
	if(whitelist[I.type])
		load(I, user)
		return TRUE
	else
		return ..()

/obj/machinery/broadside_shell_packer/attack_hand(mob/living/user)
	. = ..()
	ui_interact(user)

/obj/machinery/broadside_shell_packer/proc/pack(mob/user)
	if(casing_amount == amount_to_pack && load_amount == amount_to_pack && bag_amount == max_bags)
		icon_state = "packing_bench_loading"
		cut_overlays()
		to_chat(user, "<span class='notice'>Stół zaczyna napełniać łuski!</span>")
		play_click_sound("switch")
		playsound(user, 'nsv13/sound/effects/ship/mac_load.ogg', 20)
		sleep(0.5 SECONDS)
		for(var/i in 1 to amount_to_pack)
			if(plasma)
				if(uranium)
					new /obj/item/ship_weapon/ammunition/broadside_shell/uranium(get_turf(src))
				else
					new /obj/item/ship_weapon/ammunition/broadside_shell/plasma(get_turf(src))
			else if(gunpowder)
				new /obj/item/ship_weapon/ammunition/broadside_shell(get_turf(src))
		reset()
		return TRUE
	else
		return FALSE

/obj/machinery/broadside_shell_packer/proc/load(atom/movable/A, mob/user)
	if(istype(A, /obj/item/ship_weapon/parts/broadside_casing))
		if(casing_amount < amount_to_pack)
			casing_amount++
			to_chat(user, "<span class='notice'>Dodajesz [A] na stół.</span>")
			A.forceMove(src)
			qdel(A)
			playsound(user, 'sound/items/screwdriver2.ogg', 30)
			add_overlay("casing-[casing_amount]")
			return TRUE

		if(casing_amount == amount_to_pack)
			to_chat(user, "<span class='warning'>Stół jest już pełen łusek!</span>")
			return FALSE

	if(istype(A, /obj/item/ship_weapon/parts/broadside_load))
		if(load_amount < amount_to_pack)
			if(!load_amount)
				if(istype(A, /obj/item/ship_weapon/parts/broadside_load/uranium))
					uranium = TRUE
				else
					uranium = FALSE
			if(uranium)
				if(!istype(A, /obj/item/ship_weapon/parts/broadside_load/uranium))
					to_chat(user, "<span class='warning'>Pakowarka obsługuje naraz tylko jeden rodzaj pocisków!</span>")
					return FALSE
				if(gunpowder)
					to_chat(user, "<span class='warning'>Z ładunkami uranowymi zgodny jest tylko proch plazmowy!</span>")
					return FALSE
			load_amount++
			to_chat(user, "<span class='notice'>Dodajesz [A] na stół.</span>")
			A.forceMove(src)
			qdel(A)
			playsound(user, 'sound/items/screwdriver2.ogg', 30)
			add_overlay("load-[load_amount]")
			return TRUE
		if(load_amount == amount_to_pack)
			to_chat(user, "<span class='warning'>Stół jest już pełen ładunków!</span>")
			return FALSE

	if(istype(A, /obj/item/powder_bag))
		if(bag_amount < max_bags)
			if(istype(A, /obj/item/powder_bag/plasma))
				plasma = TRUE
				to_chat(user, "<span class='notice'>Dodajesz [A] na stół.</span>")
			else if(istype(A, /obj/item/powder_bag))
				if(uranium)
					to_chat(user, "<span class='warning'>Z ładunkami uranowymi zgodny jest tylko proch plazmowy!.</span>")
					return FALSE
				gunpowder = TRUE
				to_chat(user, "<span class='notice'>Dodajesz [A] na stół.</span>")
			A.forceMove(src)
			bag_amount++
			playsound(user, 'nsv13/sound/effects/ship/mac_load.ogg', 20)
			qdel(A)
			add_overlay("powder-1")
			return TRUE

		if(bag_amount == max_bags)
			to_chat(user, "<span class='warning'>Na stole jest już worek!</span>")
			return FALSE

/obj/machinery/broadside_shell_packer/MouseDrop_T(obj/structure/A, mob/user)
	if(!isliving(user))
		return
	if(istype(A, /obj/structure/closet))
		if(!LAZYFIND(A.contents, /obj/item/ship_weapon/parts/broadside_casing) && !LAZYFIND(A.contents, /obj/item/ship_weapon/parts/broadside_load) && !LAZYFIND(A.contents, /obj/item/powder_bag))
			to_chat(user, "<span class='warning'>W [A] nie ma niczego, co można by załadować do [src]...</span>")
			return FALSE
		to_chat(user, "<span class='notice'>Zaczynasz ładować do [src] zawartość [A]...</span>")
		if(do_after(user, 10 SECONDS , target = src))
			for(var/obj/item/ship_weapon/parts/broadside_casing/BC in A)
				if(load(BC, user))
					continue
				else
					break
			for(var/obj/item/ship_weapon/parts/broadside_load/BL in A)
				if(load(BL, user))
					continue
				else
					break
			for(var/obj/item/powder_bag/PB in A)
				if(load(PB, user))
					continue
				else
					break

/obj/machinery/broadside_shell_packer/proc/reset()
	casing_amount = 0
	load_amount = 0
	bag_amount = 0
	plasma = FALSE
	gunpowder = FALSE
	uranium = FALSE
	icon_state = "packing_bench"
	update_icon()
	return

/obj/machinery/broadside_shell_packer/AltClick(mob/user)
	if(..())
		return

	if(!pack(user))
		if(casing_amount < amount_to_pack)
			to_chat(user, "<span class='warning'>Na stole brakuje łusek: [amount_to_pack - casing_amount]!</span>")
		if(load_amount < amount_to_pack)
			to_chat(user, "<span class='warning'>Na stole brakuje ładunków: [amount_to_pack - load_amount]!</span>")
		if(bag_amount < max_bags)
			to_chat(user, "<span class='warning'>Na stole brakuje worka!</span>")

	return

/obj/machinery/broadside_shell_packer/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "BroadSideShellPacker", name)
		ui.open()
		ui.set_autoupdate(TRUE) // packa pan pan packa!

/obj/machinery/broadside_shell_packer/ui_data(mob/user)
	var/list/data = list()

	data["casing_amount"] = casing_amount
	data["load_amount"] = load_amount
	data["bag_amount"] = bag_amount
	data["amount_to_pack"] = amount_to_pack
	data["plasma"] = plasma
	data["gunpowder"] = gunpowder

	if(casing_amount == amount_to_pack && load_amount == amount_to_pack && bag_amount == max_bags)
		data["full"] = TRUE
	else
		data["full"] = FALSE

	return data

/obj/machinery/broadside_shell_packer/ui_act(action, params)
	if(..())
		return

	switch(action)
		if("pack")
			pack(usr)
			return

		if("eject_plasma")
			if(plasma)
				new /obj/item/powder_bag/plasma(get_turf(src))
				plasma = FALSE
				bag_amount--
				cut_overlay("powder-1")

		if("eject_gunpowder")
			if(gunpowder)
				new /obj/item/powder_bag(get_turf(src))
				gunpowder = FALSE
				bag_amount--
				cut_overlay("powder-1")
