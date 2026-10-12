GLOBAL_LIST_EMPTY(critical_muni_items)

/obj/item/pinpointer/munitions
	name = "munitions pinpointer"
	desc = "A device designed to track critical munitions objects."
	icon_state = "pinpointer_muni"
	icon = 'nsv13/icons/obj/device.dmi'
	resistance_flags = NONE

//Some crew pinpointer copypasta because I only need part of their functions.

/obj/item/pinpointer/munitions/examine(mob/user)
	. = ..()
	if(!active || !target)
		return
	. += "Obecnie śledzi: <b>[target]</b>."

/obj/item/pinpointer/munitions/attack_self(mob/living/user)
	if(active)
		toggle_on()
		user.visible_message("<span class='notice'>[user] wyłącza swój pinpointer.</span>", "<span class='notice'>Wyłączasz swój pinpointer.</span>")
		return

	var/list/found_items = list()
	var/obj/structure/overmap/current_overmap = get_overmap()
	for(var/obj/critical_item in GLOB.critical_muni_items) //something can occasionally introduce nulls into this list and I can't reproduce it, so back to safe casting we go :(
		if(critical_item.get_overmap() != current_overmap)
			continue
		if(isnull(critical_item.loc))
			continue
		var/prefix = ""
		if(istype(critical_item, /obj/item/circuitboard))
			var/obj/item/circuitboard/critical_circuit = critical_item
			if(istype(critical_circuit.loc, critical_circuit.build_path))
				prefix = "\[NRM\]"
			else
				prefix = "\[LSE\]"
		else
			prefix = "\[OTR\]"
		var/effective_basename = "[prefix] [critical_item]"
		var/final_name = effective_basename
		var/number_bonus = 1
		while(TRUE)
			if(!found_items[final_name])
				found_items[final_name] = critical_item
				break
			else
				final_name = "[effective_basename] ([number_bonus])"
				number_bonus++

	if(!length(found_items))
		user.visible_message("<span class='notice'>Pinpointer [user] nie wykrywa sygnału.</span>", "<span class='notice'>Twój pinpointer nie wykrywa sygnału.</span>")
		return

	var/A = input(user, "Nadajnik do śledzenia", "Pinpoint") in sortList(found_items)
	if(!A || QDELETED(src) || !user || !user.is_holding(src) || user.incapacitated())
		return

	target = found_items[A]
	toggle_on()
	user.visible_message("<span class='notice'>[user] włącza swój pinpointer.</span>", "<span class='notice'>Włączasz swój pinpointer.</span>")

/obj/item/pinpointer/munitions/scan_for_target()
	if(target)
		if(QDELETED(target) || (get_overmap() != target.get_overmap()))
			target = null

	if(!target) //target can be set to null from above code, or elsewhere
		active = FALSE

/obj/item/pinpointer/munitions/not_puce
	desc = "A device designed to track critical munitions objects. Wait.. Is this..?"
	icon_state = "pinpointer_not_puce"
