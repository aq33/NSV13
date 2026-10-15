/obj/item/discovery_scanner
	name = "discovery scanner"
	desc = "A scanner used by scientists to collect research data about unknown artifacts and specimins."
	icon = 'icons/obj/device.dmi'
	icon_state = "discovery"
	item_state = "discoveryscanner"
	lefthand_file = 'icons/mob/inhands/equipment/medical_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/medical_righthand.dmi'
	w_class = WEIGHT_CLASS_SMALL
	var/datum/techweb/linked_techweb

/obj/item/discovery_scanner/Initialize(mapload)
	. = ..()
	if(!linked_techweb)
		linked_techweb = SSresearch.science_tech

/obj/item/discovery_scanner/Destroy()
	linked_techweb = null	//Note: Shouldn't hard del anyway since techwebs don't get deleted, however if they do then troubles will arise and this will need to be changed.
	. = ..()

/obj/item/discovery_scanner/examine(mob/user)
	. = ..()
	. += "<span class='notice'>Kliknij lewym przyciskiem dowolnego moba lub okaz do zbadania, by go zeskanować i zdobyć punkty badań odkryć.</span>"
	. += "<span class='notice'>[src] ma nieograniczony zasięg.</span>"
	. += "<span class='notice'>Science goggles can help detect researchable items.</span>"

/obj/item/discovery_scanner/attack_obj(obj/O, mob/living/user)
	if(istype(O, /obj/machinery/computer/rdconsole))
		to_chat(user, "<span class='notice'>Łączysz [src] z [O].</span>")
		var/obj/machinery/computer/rdconsole/rdconsole = O
		linked_techweb = rdconsole.stored_research
		return
	. = ..()

/obj/item/discovery_scanner/proc/begin_scanning(mob/user, datum/component/discoverable/discoverable)
	to_chat(user, "<span class='notice'>Zaczynasz skanować [discoverable.parent]...</span>")
	if(do_after(user, 50, target=get_turf(user)))
		discoverable.discovery_scan(linked_techweb, user)
