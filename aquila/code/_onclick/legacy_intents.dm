// Port BeeStation/BeeStation-Hornet#11899 (combat mode): stary tryb intencji jako preferencja gracza.
//
// Domyślnie gra używa combat mode z Bee: przełącznik walki zamiast intencji help/harm, prawy przycisk to akcja
// dodatkowa (np. odepchnięcie), Ctrl+klik to chwyt, a menu kontekstowe jest pod Shift+prawym przyciskiem.
// Gracz z włączoną preferencją CHAT_LEGACY_INTENTS dostaje stare sterowanie, ale pod spodem działa ten sam kod:
// - harm = combat mode włączony, help/disarm/grab = wyłączony,
// - disarm: lewy klik działa jak prawy klik w combat mode (odepchnięcie, pobranie strzykawką itd.),
// - grab: lewy klik pustą ręką na mobie działa jak Ctrl+klik (chwyt),
// - prawy przycisk otwiera menu kontekstowe jak dawniej, a w HUD jest stary wybór czterech intencji.

/// Does this mob's player use the legacy intent controls?
/mob/proc/uses_legacy_intents()
	return !!(client?.prefs && (client.prefs.chat_toggles & CHAT_LEGACY_INTENTS))

/**
 * Turns a legacy intent click into the combat mode click it stands for.
 *
 * Changes `modifiers` in place. Returns TRUE if they were changed, so the caller can rebuild the params string.
 */
/mob/proc/translate_legacy_intent_click(atom/target, list/modifiers)
	return FALSE

/mob/living/translate_legacy_intent_click(atom/target, list/modifiers)
	if(!uses_legacy_intents())
		return FALSE
	if(LAZYACCESS(modifiers, SHIFT_CLICK) || LAZYACCESS(modifiers, CTRL_CLICK) || LAZYACCESS(modifiers, ALT_CLICK) || LAZYACCESS(modifiers, MIDDLE_CLICK) || LAZYACCESS(modifiers, RIGHT_CLICK))
		return FALSE
	switch(a_intent)
		if(INTENT_DISARM)
			modifiers -= LEFT_CLICK
			modifiers[RIGHT_CLICK] = "1"
			modifiers["button"] = RIGHT_CLICK
			return TRUE
		if(INTENT_GRAB)
			if(!isliving(target) || target == src || get_active_held_item())
				return FALSE
			modifiers[CTRL_CLICK] = "1"
			return TRUE
	return FALSE

/// Keeps a_intent in line with combat mode, so the legacy HUD and leftover intent checks see the right value.
/mob/proc/sync_intent_with_combat_mode()
	if(uses_legacy_intents())
		if(combat_mode)
			a_intent = INTENT_HARM
		else if(a_intent == INTENT_HARM)
			a_intent = INTENT_HELP
	else
		a_intent = combat_mode ? INTENT_HARM : INTENT_HELP
	var/atom/movable/screen/act_intent/selector = hud_used?.action_intent
	if(istype(selector))
		selector.icon_state = "[a_intent]"

/**
 * Called at the start of the a-intent verb (number keys, Home/Insert, the legacy HUD selector).
 *
 * With combat mode controls the verb only switches combat mode: help turns it off, harm turns it on,
 * the cycling hotkeys toggle it, disarm and grab do nothing. Returns TRUE if the verb should stop here.
 */
/mob/proc/combat_mode_intent_change(input)
	if(uses_legacy_intents())
		return FALSE
	return TRUE

/mob/living/combat_mode_intent_change(input)
	if(uses_legacy_intents())
		return FALSE
	switch(input)
		if(INTENT_HELP)
			set_combat_mode(FALSE, silent = FALSE)
		if(INTENT_HARM)
			set_combat_mode(TRUE, silent = FALSE)
		if(INTENT_HOTKEY_LEFT, INTENT_HOTKEY_RIGHT)
			set_combat_mode(!combat_mode, silent = FALSE)
	return TRUE

/// In the legacy mode the chosen intent drives combat mode (harm = combat mode on).
/mob/proc/legacy_intent_changed()
	return

/mob/living/legacy_intent_changed()
	if(!uses_legacy_intents())
		return
	set_combat_mode(a_intent == INTENT_HARM)

/// Non-living mobs only keep the flag, the full version with HUD and sounds is on /mob/living.
/mob/proc/set_combat_mode(new_mode, silent = TRUE)
	combat_mode = new_mode

/// Applies the player's control scheme: right click menu, HUD selector and intent.
/client/proc/update_combat_controls()
	if(!mob)
		return
	set_right_click_menu_mode(mob.shift_to_open_context_menu)
	mob.sync_intent_with_combat_mode()
	mob.hud_used?.refresh_intent_selector()

/// In the legacy mode right click always opens the context menu, like it used to.
/client/set_right_click_menu_mode(shift_only)
	if(mob?.uses_legacy_intents())
		shift_only = FALSE
	return ..(shift_only)

/// Shift held down opens the context menu on right click (the skin macros get erased by set_macros()).
/client/proc/update_shift_context_menu(shift_down)
	if(!mob?.shift_to_open_context_menu || mob.uses_legacy_intents())
		return
	winset(src, "mapwindow.map", "right-click=[shift_down ? "false" : "true"]")

/mob/Login()
	. = ..()
	client?.update_combat_controls()

/mob/create_mob_hud()
	. = ..()
	hud_used?.refresh_intent_selector()

/// Swaps the combat mode toggle and the old intent selector in the HUD, depending on the player's preference.
/datum/hud/proc/refresh_intent_selector()
	if(!action_intent || !mymob)
		return
	var/legacy = mymob.uses_legacy_intents()
	if(legacy == istype(action_intent, /atom/movable/screen/act_intent))
		action_intent.update_icon()
		return
	var/atom/movable/screen/old_selector = action_intent
	var/atom/movable/screen/new_selector = legacy ? create_legacy_intent_selector() : create_combat_mode_selector()
	static_inventory -= old_selector
	mymob.client?.screen -= old_selector
	action_intent = new_selector
	static_inventory += new_selector
	if(hud_shown || hud_version == HUD_STYLE_REDUCED)
		mymob.client?.screen += new_selector
	if(hud_version == HUD_STYLE_REDUCED)
		new_selector.screen_loc = ui_acti_alt
	qdel(old_selector)

/datum/hud/proc/create_legacy_intent_selector()
	var/atom/movable/screen/act_intent/selector
	if(iscyborg(mymob))
		selector = new /atom/movable/screen/act_intent/robot()
	else if(isalien(mymob))
		selector = new /atom/movable/screen/act_intent/alien()
	else if(length(mymob.possible_a_intents) == 4)
		selector = new /atom/movable/screen/act_intent/segmented()
	else
		selector = new /atom/movable/screen/act_intent()
		selector.icon = ui_style
	selector.icon_state = "[mymob.a_intent]"
	selector.hud = src
	return selector

/datum/hud/proc/create_combat_mode_selector()
	var/atom/movable/screen/combattoggle/selector
	if(iscyborg(mymob))
		selector = new /atom/movable/screen/combattoggle/robot()
	else
		selector = new /atom/movable/screen/combattoggle/flashy()
	selector.hud = src
	selector.icon = ui_style
	selector.screen_loc = ui_combat_toggle
	selector.update_icon()
	return selector

// Stary wybór intencji (przed portem trzymany w code/_onclick/hud/screen_objects.dm)
/atom/movable/screen/act_intent
	name = "intent"
	icon_state = "help"
	screen_loc = ui_acti
	mouse_over_pointer = MOUSE_HAND_POINTER

/atom/movable/screen/act_intent/Click(location, control, params)
	usr.a_intent_change(INTENT_HOTKEY_RIGHT)

/atom/movable/screen/act_intent/segmented/Click(location, control, params)
	if(usr.client.prefs.toggles & PREFTOGGLE_INTENT_STYLE)
		var/_x = text2num(params2list(params)["icon-x"])
		var/_y = text2num(params2list(params)["icon-y"])

		if(_x<=16 && _y<=16)
			usr.a_intent_change(INTENT_HARM)

		else if(_x<=16 && _y>=17)
			usr.a_intent_change(INTENT_HELP)

		else if(_x>=17 && _y<=16)
			usr.a_intent_change(INTENT_GRAB)

		else if(_x>=17 && _y>=17)
			usr.a_intent_change(INTENT_DISARM)
	else
		return ..()

/atom/movable/screen/act_intent/alien
	icon = 'icons/mob/screen_alien.dmi'
	screen_loc = ui_movi

/atom/movable/screen/act_intent/robot
	icon = 'icons/mob/screen_cyborg.dmi'
	screen_loc = ui_borg_intents

/atom/movable/screen/combattoggle
	mouse_over_pointer = MOUSE_HAND_POINTER
