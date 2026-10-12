// Przyciski akcji strzelca działa Gaussa (po lewej, na pasku akcji) zamiast werbu „Access gun camera”:
// „Kamera działa” włącza i wyłącza widok na mapę kosmosu bez wychodzenia z działa, „Wyjdź z działa” opuszcza kabinę.

/obj/machinery/ship_weapon/gauss_gun
	/// Przyciski strzelca, tworzone przy pierwszym strzelcu
	var/list/datum/action/gunner_actions

/obj/machinery/ship_weapon/gauss_gun/set_gunner(mob/user)
	. = ..()
	grant_gunner_actions(user)

/obj/machinery/ship_weapon/gauss_gun/remove_gunner()
	if(gunner)
		remove_gunner_actions(gunner)
	return ..()

/obj/machinery/ship_weapon/gauss_gun/Destroy()
	. = ..()
	QDEL_LIST(gunner_actions)

/obj/machinery/ship_weapon/gauss_gun/proc/grant_gunner_actions(mob/user)
	if(!length(gunner_actions))
		gunner_actions = list(new /datum/action/gauss_gunner/camera(src), new /datum/action/gauss_gunner/exit(src))
	for(var/datum/action/action as anything in gunner_actions)
		action.Grant(user)

/obj/machinery/ship_weapon/gauss_gun/proc/remove_gunner_actions(mob/user)
	for(var/datum/action/action as anything in gunner_actions)
		action.Remove(user)

/// Włącza albo wyłącza widok z kamery działa. Wyłączenie nie wyrzuca z działa
/obj/machinery/ship_weapon/gauss_gun/proc/toggle_camera(mob/user)
	if(user != gunner || user.incapacitated())
		return
	var/datum/component/overmap_gunning/gunning = user.GetComponent(/datum/component/overmap_gunning)
	if(!gunning)
		show_view(user)
		return
	var/obj/structure/overmap/ship = get_overmap()
	if(ship)
		// Najpierw z listy strzelców, inaczej stop_piloting() wyrzuciłoby gracza z działa
		LAZYREMOVE(ship.gauss_gunners, user)
		ship.stop_piloting(user)
	STOP_PROCESSING(SSfastprocess, gunning)
	qdel(gunning)
	to_chat(user, "<span class='notice'>Wyłączasz kamerę działa. Wciąż siedzisz w kabinie.</span>")

/datum/action/gauss_gunner
	icon_icon = 'icons/mob/actions/actions_mecha.dmi'
	check_flags = AB_CHECK_CONSCIOUS
	/// Działo, do którego należy przycisk
	var/datum/weakref/gun_ref

/datum/action/gauss_gunner/New(obj/machinery/ship_weapon/gauss_gun/gun)
	. = ..(gun)
	gun_ref = WEAKREF(gun)

/// Działo, jeśli właściciel przycisku nadal w nim siedzi
/datum/action/gauss_gunner/proc/get_gun()
	RETURN_TYPE(/obj/machinery/ship_weapon/gauss_gun)
	var/obj/machinery/ship_weapon/gauss_gun/gun = gun_ref?.resolve()
	if(!gun || gun.gunner != owner)
		return null
	return gun

/datum/action/gauss_gunner/camera
	name = "Kamera działa"
	desc = "Włącz albo wyłącz widok z kamery działa. Na mapie kosmosu kliknięcie celu oddaje strzał."
	button_icon_state = "mech_zoom_on"

/datum/action/gauss_gunner/camera/Trigger()
	. = ..()
	if(!.)
		return
	get_gun()?.toggle_camera(owner)

/datum/action/gauss_gunner/exit
	name = "Wyjdź z działa"
	desc = "Opuść kabinę działa. Krzesło zjedzie na dół."
	button_icon_state = "mech_eject"

/datum/action/gauss_gunner/exit/Trigger()
	. = ..()
	if(!.)
		return
	get_gun()?.remove_gunner()
