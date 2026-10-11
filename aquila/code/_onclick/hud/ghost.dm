// Port BeeStation/BeeStation-Hornet#12449: przycisk „Obserwuj” na HUD-zie ducha
// i układ HUD-u ducha z obecnego Bee: grafiki Bee, przycisk Respawn, przyciski wyśrodkowane na dole ekranu, menu języków na końcu

/// Pozycja przycisku HUD-u ducha, przesunięcie od środka ekranu
#define ui_ghost_center(offset) "SOUTH:6,CENTER+[offset]"

/atom/movable/screen/ghost
	icon = 'aquila/icons/hud/screen_ghost.dmi'
	mouse_over_pointer = MOUSE_HAND_POINTER

/atom/movable/screen/ghost/spawners
	icon_state = "spawners_menu"

/atom/movable/screen/ghost/observe
	name = "Obserwuj"
	icon_state = "observe"

/atom/movable/screen/ghost/observe/Click()
	var/mob/dead/observer/G = usr
	G.observe()

/atom/movable/screen/ghost/respawn
	name = "Respawn"
	icon_state = "respawn"

/atom/movable/screen/ghost/respawn/Click()
	usr.abandon_mob()

/datum/hud/ghost/New(mob/owner)
	..()
	var/atom/movable/screen/using = new /atom/movable/screen/ghost/observe()
	using.hud = src
	static_inventory.Insert(1, using)
	if(!CONFIG_GET(flag/norespawn))
		using = new /atom/movable/screen/ghost/respawn()
		using.hud = src
		static_inventory += using

	// Przyciski ducha na środku dolnej krawędzi w kolejności z Bee, menu języków zawsze na końcu
	var/static/list/button_order = list(
		/atom/movable/screen/ghost/observe,
		/atom/movable/screen/ghost/jumptomob,
		/atom/movable/screen/ghost/orbit,
		/atom/movable/screen/ghost/reenter_corpse,
		/atom/movable/screen/ghost/respawn,
		/atom/movable/screen/ghost/teleport,
		/atom/movable/screen/ghost/pai,
		/atom/movable/screen/ghost/spawners,
	)
	var/list/ghost_buttons = list()
	var/atom/movable/screen/language_menu/language_button
	for(var/button_type in button_order)
		var/atom/movable/screen/ghost/button = locate(button_type) in static_inventory
		if(button)
			ghost_buttons += button
	for(var/atom/movable/screen/ghost/button in static_inventory)
		ghost_buttons |= button
	language_button = locate() in static_inventory
	var/left_offset = -(length(ghost_buttons) - 1) / 2
	var/index = 0
	for(var/atom/movable/screen/ghost/button as anything in ghost_buttons)
		button.screen_loc = ui_ghost_center(left_offset + index)
		index++
	language_button?.screen_loc = ui_ghost_center(left_offset + index)

#undef ui_ghost_center
