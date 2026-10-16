/obj/item/implant/explosive
	name = "microbomb implant"
	desc = "And boom goes the weasel."
	icon_state = "explosive"
	actions_types = list(/datum/action/item_action/explosive_implant)
	// Explosive implant action is always available.
	var/weak = 2
	var/medium = 0.8
	var/heavy = 0.4
	var/delay = 7
	var/popup = FALSE // is the DOUWANNABLOWUP window open?
	var/active = FALSE

/obj/item/implant/explosive/on_mob_death(mob/living/L, gibbed)
	activate("death")

/obj/item/implant/explosive/get_data()
	var/dat = {"<b>Specyfikacja implantu:</b><BR><b>Nazwa:</b> Implant zarządzania pracownikami Robust Corp RX-78<BR><b>Żywotność:</b> aktywuje się po śmierci.<BR><b>Ważne uwagi:</b> wybucha<BR><HR><b>Szczegóły implantu:</b><BR><b>Działanie:</b> zawiera kompaktowy ładunek wybuchowy detonowany elektrycznie po otrzymaniu specjalnie zakodowanego sygnału lub po śmierci nosiciela.<BR><b>Cechy specjalne:</b> wybucha<BR>
				"}
	return dat

/obj/item/implant/explosive/activate(cause)
	. = ..()
	if(!cause || !imp_in || active)
		return FALSE
	if(cause == "action_button" && !popup)
		popup = TRUE
		var/response = alert(imp_in, "Na pewno chcesz aktywować [name]? Wybuchniesz!", "[name] Confirmation", "Yes", "No")
		popup = FALSE
		if(response != "Yes")
			return FALSE
	heavy = round(heavy)
	medium = round(medium)
	weak = round(weak)
	to_chat(imp_in, "<span class='notice'>Aktywujesz [name].</span>")
	active = TRUE
	var/turf/boomturf = get_turf(imp_in)
	message_admins("[ADMIN_LOOKUPFLW(imp_in)] has activated their [name] at [ADMIN_VERBOSEJMP(boomturf)], with cause of [cause].")
//If the delay is short, just blow up already jeez
	if(delay <= 7)
		explosion(src,heavy,medium,weak,weak, flame_range = weak)
		if(imp_in)
			imp_in.gib(1)
		qdel(src)
		return TRUE
	timed_explosion()

/obj/item/implant/explosive/implant(mob/living/target, mob/user, silent = FALSE, force = FALSE)
	for(var/X in target.implants)
		if(istype(X, type) && (istype(src, /obj/item/implant/explosive/engineering) || !istype(X, /obj/item/implant/explosive/engineering))) // AQ EDIT: mikrobomba nie wtapia się w implant karny CE
			var/obj/item/implant/explosive/imp_e = X
			imp_e.heavy += heavy
			imp_e.medium += medium
			imp_e.weak += weak
			imp_e.delay += delay
			qdel(src)
			return 1

	return ..()

/obj/item/implant/explosive/proc/timed_explosion()
	imp_in.visible_message("<span class='warning'>[imp_in] zaczyna złowieszczo pikać!</span>")
	playsound(loc, 'sound/items/timer.ogg', 30, 0)
	sleep(delay*0.25)
	if(imp_in && !imp_in.stat)
		imp_in.visible_message("<span class='warning'>[imp_in] zgina się wpół z bólu!</span>")
		imp_in.Paralyze(140)
	playsound(loc, 'sound/items/timer.ogg', 30, 0)
	sleep(delay*0.25)
	playsound(loc, 'sound/items/timer.ogg', 30, 0)
	sleep(delay*0.25)
	playsound(loc, 'sound/items/timer.ogg', 30, 0)
	sleep(delay*0.25)
	explosion(src,heavy,medium,weak,weak, flame_range = weak)
	if(imp_in)
		imp_in.gib(1)
	qdel(src)

/obj/item/implant/explosive/macro
	name = "macrobomb implant"
	desc = "And boom goes the weasel. And everything else nearby."
	icon_state = "explosive"
	weak = 16
	medium = 8
	heavy = 4
	delay = 70

/obj/item/implant/explosive/macro/implant(mob/living/target, mob/user, silent = FALSE, force = FALSE)
	for(var/X in target.implants)
		if(istype(X, type))
			return 0

	for(var/Y in target.implants)
		if(istype(Y, /obj/item/implant/explosive))
			var/obj/item/implant/explosive/imp_e = Y
			heavy += imp_e.heavy
			medium += imp_e.medium
			weak += imp_e.weak
			delay += imp_e.delay
			qdel(imp_e)
			break

	return ..()


/obj/item/implanter/explosive
	name = "implanter (microbomb)"
	imp_type = /obj/item/implant/explosive

/obj/item/implantcase/explosive
	name = "implant case - 'Explosive'"
	desc = "A glass case containing an explosive implant."
	imp_type = /obj/item/implant/explosive

/obj/item/implanter/explosive_macro
	name = "implanter (macrobomb)"
	imp_type = /obj/item/implant/explosive/macro
