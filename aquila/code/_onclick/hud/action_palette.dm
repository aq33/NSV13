// Paleta przycisków akcji w stylu BeeStation, na naszym systemie akcji.
// Pierwszy rząd mieści ACTION_PALETTE_ROW przycisków, reszta chowa się do palety (pasek pod rzędem),
// którą kliknięciem rozwija się i zwija. Zastępuje dawny przycisk "Hide Buttons" (ten sam obiekt HUD-u).

#define ACTION_PALETTE_ROW 10
#define ui_action_palette "WEST+0:23,NORTH-1:5"

/datum/hud
	/// Czy paleta z nadmiarowymi przyciskami akcji jest rozwinięta
	var/action_palette_expanded = FALSE

/atom/movable/screen/movable/action_button/hide_toggle
	name = "Paleta przycisków"
	desc = "<b>Kliknij</b>, aby pokazać lub schować przyciski, które nie mieszczą się w rzędzie.<br><b>Przeciągnij</b> przycisk, aby go przenieść, <b>Shift-klik</b> wraca go na miejsce, <b>Ctrl-klik</b> go blokuje.<br><b>Alt-klik</b> tutaj przywraca wszystkie przyciski na miejsca."
	mouse_over_pointer = MOUSE_HAND_POINTER

/// Grafika palety pasująca do stylu HUD-u (z BeeStation), domyślnie zwykła
/atom/movable/screen/movable/action_button/hide_toggle/InitialiseIcon(datum/hud/owner_hud)
	icon = 'aquila/icons/hud/64x16_actions.dmi'
	var/style_file = "[owner_hud.ui_style]"
	var/style_name = copytext(style_file, findlasttext(style_file, "/") + 1, findlasttext(style_file, ".dmi"))
	var/static/list/palette_states
	if(!palette_states)
		palette_states = icon_states(icon)
	icon_state = ("[style_name]_palette" in palette_states) ? "[style_name]_palette" : "screen_gen_palette"
	update_icon()

/atom/movable/screen/movable/action_button/hide_toggle/update_icon()
	cut_overlays()
	color = hud?.action_palette_expanded ? list(1.2,0,0, 0,1.2,0, 0,0,1.2) : null

/atom/movable/screen/movable/action_button/hide_toggle/Click(location, control, params)
	var/list/modifiers = params2list(params)
	// Shift, Ctrl i Alt zostają jak w starym przycisku (reset, blokada, reset wszystkich)
	if(modifiers["shift"] || modifiers["ctrl"] || modifiers["alt"])
		return ..()
	if(!can_use(usr) || !usr.hud_used)
		return
	usr.hud_used.action_palette_expanded = !usr.hud_used.action_palette_expanded
	hud = usr.hud_used
	update_icon()
	usr.update_action_buttons()
	return TRUE

/// Pozycja przycisku numer index w rozwiniętej palecie (rzędy pod paskiem palety)
/datum/hud/proc/palette_button_coords(index)
	var/row = round((index - 1) / ACTION_PALETTE_ROW) + 1
	var/col = ((index - 1) % ACTION_PALETTE_ROW) + 1
	return "WEST+[col - 1]:[4 + 2 * col],NORTH-[1 + row]:0"

/mob/update_action_buttons(reload_screen)
	if(!hud_used || !client)
		return
	if(hud_used.hud_shown != HUD_STYLE_STANDARD)
		return

	var/expanded = hud_used.action_palette_expanded
	var/button_number = 0
	var/overflow_number = 0
	for(var/datum/action/action as anything in actions)
		action.UpdateButtonIcon()
		var/atom/movable/screen/movable/action_button/button = action.button
		if(button.moved)
			button.screen_loc = button.moved
		else if(!button.ordered)
			button.screen_loc = hud_used.ButtonNumberToScreenCoords(button_number)
		else
			button_number++
			if(button_number <= ACTION_PALETTE_ROW)
				button.screen_loc = hud_used.ButtonNumberToScreenCoords(button_number)
			else
				overflow_number++
				button.screen_loc = expanded ? hud_used.palette_button_coords(overflow_number) : null
		if(reload_screen)
			client.screen += button

	var/atom/movable/screen/movable/action_button/hide_toggle/palette = hud_used.hide_actions_toggle
	if(!button_number)
		palette.screen_loc = null
		return
	palette.screen_loc = palette.moved || ui_action_palette
	if(reload_screen)
		client.screen += palette

#undef ui_action_palette
#undef ACTION_PALETTE_ROW
