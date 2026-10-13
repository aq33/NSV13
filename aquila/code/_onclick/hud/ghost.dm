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

// screen_objects.dm też definiuje ten przycisk (stara ikona z screen_midnight), tu wraca grafika z Bee
/atom/movable/screen/ghost/pai
	icon = 'aquila/icons/hud/screen_ghost.dmi'
	icon_state = "pai"

/// Pusta ramka przycisku ducha w stylu Bee: tło z ikony pAI z rozciągniętym paskiem tła spod ramki
/proc/ghost_button_frame()
	var/static/icon/frame
	if(!frame)
		frame = icon('aquila/icons/hud/screen_ghost.dmi', "pai")
		var/icon/strip = icon(frame)
		strip.Crop(6, 1, 6, 32)
		strip.Scale(24, 32)
		frame.Blend(strip, ICON_OVERLAY, 5, 1)
	return frame

/// Przesunięcie (x, y), które ustawia widoczne piksele stanu ikony na środku kafelka 32x32
/proc/icon_center_offset(icon_file, icon_state)
	var/static/list/cache = list()
	var/key = "[icon_file]|[icon_state]"
	if(cache[key])
		return cache[key]
	var/icon/I = icon(icon_file, icon_state, SOUTH, 1)
	var/min_x = 33
	var/max_x = 0
	var/min_y = 33
	var/max_y = 0
	for(var/x in 1 to I.Width())
		for(var/y in 1 to I.Height())
			if(!I.GetPixel(x, y))
				continue
			min_x = min(min_x, x)
			max_x = max(max_x, x)
			min_y = min(min_y, y)
			max_y = max(max_y, y)
	var/list/offset = list(0, 0)
	if(max_x)
		offset = list(round((I.Width() + 1 - min_x - max_x) / 2), round((I.Height() + 1 - min_y - max_y) / 2))
	cache[key] = offset
	return offset

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
	// Nawiedzanie osobno, w lewym górnym rogu
	using = new /atom/movable/screen/ghost/haunt()
	using.hud = src
	using.screen_loc = "NORTH:-6,WEST:6"
	static_inventory += using
	language_button = locate() in static_inventory
	var/left_offset = -(length(ghost_buttons) - 1) / 2
	var/index = 0
	for(var/atom/movable/screen/ghost/button as anything in ghost_buttons)
		button.screen_loc = ui_ghost_center(left_offset + index)
		index++
	if(language_button)
		language_button.screen_loc = ui_ghost_center(left_offset + index)
		// Mała ikonka ze stylu HUD-u dostaje taką ramkę jak reszta przycisków, wyśrodkowana w niej
		var/mutable_appearance/wheel = mutable_appearance(language_button.icon, language_button.icon_state)
		var/list/center_offset = icon_center_offset(language_button.icon, language_button.icon_state)
		wheel.pixel_x = center_offset[1]
		wheel.pixel_y = center_offset[2]
		language_button.icon = ghost_button_frame()
		language_button.icon_state = null
		language_button.add_overlay(wheel)

#undef ui_ghost_center
