// Port BeeStation #8776: ustawienia gry (strona Game Preferences), czytane z naszych bitów toggles i zmiennych /datum/preferences


/datum/preference/toggle/player
	abstract_type = /datum/preference/toggle/player
	category = PREFERENCE_CATEGORY_GAME_PREFERENCES
	/// Tylko dla adminów
	var/admin_only = FALSE
	/// Tylko dla członków BYOND
	var/member_only = FALSE

/datum/preference/toggle/player/is_accessible(datum/preferences/prefs)
	if(admin_only && !prefs.parent?.holder)
		return FALSE
	if(member_only && !prefs.unlock_content)
		return FALSE
	return ..()

// Dźwięk

/datum/preference/toggle/player/sound_lobby
	db_key = "sound_lobby"
	toggle_var = "toggles"
	toggle_bit = PREFTOGGLE_SOUND_LOBBY

/datum/preference/toggle/player/sound_lobby/on_changed(datum/preferences/prefs, client/C, old_value, new_value)
	if(!C)
		return
	if(new_value && isnewplayer(C.mob))
		C.playtitlemusic()
	else
		C.mob?.stop_sound_channel(CHANNEL_LOBBYMUSIC)

/datum/preference/toggle/player/sound_midi
	db_key = "sound_midi"
	toggle_var = "toggles"
	toggle_bit = PREFTOGGLE_SOUND_MIDI

/datum/preference/toggle/player/sound_midi/on_changed(datum/preferences/prefs, client/C, old_value, new_value)
	if(C && !new_value)
		C.mob?.stop_sound_channel(CHANNEL_ADMIN)
		C.tgui_panel?.stop_music()

/datum/preference/toggle/player/sound_instruments
	db_key = "sound_instruments"
	toggle_var = "toggles"
	toggle_bit = PREFTOGGLE_SOUND_INSTRUMENTS

/datum/preference/toggle/player/sound_ambience
	db_key = "sound_ambience"
	toggle_var = "toggles"
	toggle_bit = PREFTOGGLE_SOUND_AMBIENCE

/datum/preference/toggle/player/sound_ambience/on_changed(datum/preferences/prefs, client/C, old_value, new_value)
	if(!C)
		return
	if(!new_value)
		C.mob?.stop_sound_channel(CHANNEL_AMBIENT_EFFECTS)
		C.mob?.stop_sound_channel(CHANNEL_AMBIENT_MUSIC)
		C.mob?.stop_sound_channel(CHANNEL_BUZZ)
		C.buzz_playing = FALSE
	C.update_ambience_pref()

/datum/preference/toggle/player/sound_ship_ambience
	db_key = "sound_ship_ambience"
	toggle_var = "toggles"
	toggle_bit = PREFTOGGLE_SOUND_SHIP_AMBIENCE

/datum/preference/toggle/player/sound_ship_ambience/on_changed(datum/preferences/prefs, client/C, old_value, new_value)
	if(C && !new_value)
		C.mob?.stop_sound_channel(CHANNEL_BUZZ)
		C.buzz_playing = FALSE

/datum/preference/toggle/player/sound_announcements
	db_key = "sound_announcements"
	toggle_var = "toggles"
	toggle_bit = PREFTOGGLE_SOUND_ANNOUNCEMENTS

/datum/preference/toggle/player/sound_radio_noise
	db_key = "sound_radio_noise"
	toggle_var = "toggles2"
	toggle_bit = PREFTOGGLE_2_RADIO_SOUND

/datum/preference/numeric/tesla_volume
	db_key = "tesla_volume"
	category = PREFERENCE_CATEGORY_GAME_PREFERENCES
	player_var = "tesla_volume"
	minimum = 0
	maximum = 100
	step = 5

/datum/preference/toggle/player/death_rattle
	db_key = "death_rattle"
	toggle_var = "toggles"
	toggle_bit = PREFTOGGLE_DISABLE_DEATHRATTLE
	toggle_inverted = TRUE

/datum/preference/toggle/player/arrivals_rattle
	db_key = "arrivals_rattle"
	toggle_var = "toggles"
	toggle_bit = PREFTOGGLE_DISABLE_ARRIVALRATTLE
	toggle_inverted = TRUE

// Czat

/datum/preference/toggle/player/chat_ooc
	db_key = "chat_ooc"
	toggle_var = "chat_toggles"
	toggle_bit = CHAT_OOC

/datum/preference/toggle/player/chat_looc
	db_key = "chat_looc"
	toggle_var = "chat_toggles"
	toggle_bit = CHAT_LOOC

/datum/preference/toggle/player/chat_bankcard
	db_key = "chat_bankcard"
	toggle_var = "chat_toggles"
	toggle_bit = CHAT_BANKCARD

/datum/preference/toggle/player/chat_pullr
	db_key = "chat_pullr"
	toggle_var = "chat_toggles"
	toggle_bit = CHAT_PULLR

/datum/preference/toggle/player/chat_on_map
	db_key = "chat_on_map"
	toggle_var = "toggles"
	toggle_bit = PREFTOGGLE_RUNECHAT_GLOBAL

/datum/preference/toggle/player/see_chat_non_mob
	db_key = "see_chat_non_mob"
	toggle_var = "toggles"
	toggle_bit = PREFTOGGLE_RUNECHAT_NONMOBS

/datum/preference/toggle/player/see_rc_emotes
	db_key = "see_rc_emotes"
	toggle_var = "toggles"
	toggle_bit = PREFTOGGLE_RUNECHAT_EMOTES

/datum/preference/toggle/player/enable_runechat_looc
	db_key = "enable_runechat_looc"
	toggle_var = "chat_toggles"
	toggle_bit = CHAT_DISABLE_LOOC_RUNECHAT
	toggle_inverted = TRUE

/datum/preference/choiced/show_balloon_alerts
	db_key = "show_balloon_alerts"
	category = PREFERENCE_CATEGORY_GAME_PREFERENCES
	player_var = "see_balloon_alerts"

/datum/preference/choiced/show_balloon_alerts/init_possible_values()
	return list(BALLOON_ALERT_ALWAYS, BALLOON_ALERT_WITH_CHAT, BALLOON_ALERT_NEVER)

/datum/preference/color/ooc_color
	db_key = "ooccolor"
	category = PREFERENCE_CATEGORY_GAME_PREFERENCES
	player_var = "ooccolor"
	color_with_crunch = TRUE

/datum/preference/color/ooc_color/serialize(value)
	return ..(value || GLOB.normal_ooc_colour)

/datum/preference/color/ooc_color/is_accessible(datum/preferences/prefs)
	return ..() && (prefs.unlock_content || prefs.parent?.holder)

/datum/preference/toggle/player/member_public
	db_key = "member_public"
	toggle_var = "toggles"
	toggle_bit = PREFTOGGLE_MEMBER_PUBLIC
	member_only = TRUE

// Duchy

/datum/preference/toggle/player/chat_ghostears
	db_key = "chat_ghostears"
	toggle_var = "chat_toggles"
	toggle_bit = CHAT_GHOSTEARS

/datum/preference/toggle/player/chat_ghostsight
	db_key = "chat_ghostsight"
	toggle_var = "chat_toggles"
	toggle_bit = CHAT_GHOSTSIGHT

/datum/preference/toggle/player/chat_ghostwhisper
	db_key = "chat_ghostwhisper"
	toggle_var = "chat_toggles"
	toggle_bit = CHAT_GHOSTWHISPER

/datum/preference/toggle/player/chat_ghostradio
	db_key = "chat_ghostradio"
	toggle_var = "chat_toggles"
	toggle_bit = CHAT_GHOSTRADIO

/datum/preference/toggle/player/chat_ghostpda
	db_key = "chat_ghostpda"
	toggle_var = "chat_toggles"
	toggle_bit = CHAT_GHOSTPDA

/datum/preference/toggle/player/chat_ghostlaws
	db_key = "chat_ghostlaws"
	toggle_var = "chat_toggles"
	toggle_bit = CHAT_GHOSTLAWS

/datum/preference/toggle/player/ghost_hud
	db_key = "ghost_hud"
	toggle_var = "toggles2"
	toggle_bit = PREFTOGGLE_2_GHOST_HUD

/datum/preference/toggle/player/ghost_hud/on_changed(datum/preferences/prefs, client/C, old_value, new_value)
	if(isobserver(C?.mob))
		C.mob.hud_used?.show_hud()

/datum/preference/toggle/player/inquisitive_ghost
	db_key = "inquisitive_ghost"
	toggle_var = "toggles2"
	toggle_bit = PREFTOGGLE_2_GHOST_INQUISITIVENESS

/// Ustawienia duchów zapisane jako liczby, w oknie jako nazwy
/datum/preference/choiced/ghost_named
	abstract_type = /datum/preference/choiced/ghost_named
	category = PREFERENCE_CATEGORY_GAME_PREFERENCES
	/// Nazwa -> wartość
	var/list/named_values

/datum/preference/choiced/ghost_named/init_possible_values()
	var/list/names = list()
	for(var/name in named_values)
		names += name
	return names

/datum/preference/choiced/ghost_named/read_value(datum/preferences/prefs)
	var/value = prefs.vars[player_var]
	for(var/name in named_values)
		if(named_values[name] == value)
			return name
	return named_values[1]

/datum/preference/choiced/ghost_named/write_value(datum/preferences/prefs, value)
	prefs.vars[player_var] = named_values[value]

/datum/preference/choiced/ghost_named/accessories
	db_key = "ghost_accs"
	player_var = "ghost_accs"
	named_values = list(
		GHOST_ACCS_FULL_NAME = GHOST_ACCS_FULL,
		GHOST_ACCS_DIR_NAME = GHOST_ACCS_DIR,
		GHOST_ACCS_NONE_NAME = GHOST_ACCS_NONE,
	)

/datum/preference/choiced/ghost_named/others
	db_key = "ghost_others"
	player_var = "ghost_others"
	named_values = list(
		GHOST_OTHERS_THEIR_SETTING_NAME = GHOST_OTHERS_THEIR_SETTING,
		GHOST_OTHERS_DEFAULT_SPRITE_NAME = GHOST_OTHERS_DEFAULT_SPRITE,
		GHOST_OTHERS_SIMPLE_NAME = GHOST_OTHERS_SIMPLE,
	)

/datum/preference/choiced/ghost_form
	db_key = "ghost_form"
	category = PREFERENCE_CATEGORY_GAME_PREFERENCES
	player_var = "ghost_form"
	should_generate_icons = TRUE

/datum/preference/choiced/ghost_form/init_possible_values()
	return GLOB.ghost_forms.Copy()

/datum/preference/choiced/ghost_form/icon_for(value)
	return icon('icons/mob/mob.dmi', value)

/datum/preference/choiced/ghost_form/get_display_names()
	var/list/names = list()
	for(var/form in get_choices())
		names[form] = capitalize(replacetext(form, "_", " "))
	return names

/datum/preference/choiced/ghost_form/is_valid(value, datum/preferences/prefs)
	return ..() && prefs.unlock_content

/datum/preference/choiced/ghost_orbit
	db_key = "ghost_orbit"
	category = PREFERENCE_CATEGORY_GAME_PREFERENCES
	player_var = "ghost_orbit"

/datum/preference/choiced/ghost_orbit/init_possible_values()
	return GLOB.ghost_orbits.Copy()

/datum/preference/choiced/ghost_orbit/is_valid(value, datum/preferences/prefs)
	return ..() && prefs.unlock_content

// Grafika

/datum/preference/choiced/parallax
	db_key = "parallax"
	category = PREFERENCE_CATEGORY_GAME_PREFERENCES
	player_var = "parallax"

/datum/preference/choiced/parallax/init_possible_values()
	return list("Insane", "High", "Medium", "Low", "Disabled")

/datum/preference/choiced/parallax/read_value(datum/preferences/prefs)
	switch(prefs.parallax)
		if(PARALLAX_INSANE)
			return "Insane"
		if(PARALLAX_MED)
			return "Medium"
		if(PARALLAX_LOW)
			return "Low"
		if(PARALLAX_DISABLE)
			return "Disabled"
	return "High"

/datum/preference/choiced/parallax/write_value(datum/preferences/prefs, value)
	switch(value)
		if("Insane")
			prefs.parallax = PARALLAX_INSANE
		if("Medium")
			prefs.parallax = PARALLAX_MED
		if("Low")
			prefs.parallax = PARALLAX_LOW
		if("Disabled")
			prefs.parallax = PARALLAX_DISABLE
		else
			prefs.parallax = PARALLAX_HIGH

/datum/preference/choiced/parallax/on_changed(datum/preferences/prefs, client/C, old_value, new_value)
	C?.mob?.hud_used?.update_parallax_pref(C.mob)

/datum/preference/toggle/player/ambientocclusion
	db_key = "ambientocclusion"
	toggle_var = "toggles2"
	toggle_bit = PREFTOGGLE_2_AMBIENT_OCCLUSION

/datum/preference/toggle/player/ambientocclusion/on_changed(datum/preferences/prefs, client/C, old_value, new_value)
	var/atom/movable/screen/plane_master/game_world/plane_master = locate() in C?.screen
	plane_master?.backdrop(C.mob)

/datum/preference/toggle/player/auto_fit_viewport
	db_key = "auto_fit_viewport"
	toggle_var = "toggles2"
	toggle_bit = PREFTOGGLE_2_AUTO_FIT_VIEWPORT

/datum/preference/toggle/player/auto_fit_viewport/on_changed(datum/preferences/prefs, client/C, old_value, new_value)
	if(new_value)
		C?.fit_viewport()

/datum/preference/toggle/player/widescreen
	db_key = "widescreen"
	toggle_var = "toggles2"
	toggle_bit = PREFTOGGLE_2_WIDESCREEN

/datum/preference/toggle/player/widescreen/on_changed(datum/preferences/prefs, client/C, old_value, new_value)
	if(!C)
		return
	C.change_view(getScreenSize(new_value))
	C.view_size.default = new_value ? CONFIG_GET(string/default_view) : "15x15"

/datum/preference/toggle/player/fullscreen
	db_key = "fullscreen"
	toggle_var = "toggles2"
	toggle_bit = PREFTOGGLE_2_FULLSCREEN

/datum/preference/toggle/player/fullscreen/on_changed(datum/preferences/prefs, client/C, old_value, new_value)
	C?.toggle_fullscreen(new_value)

/datum/preference/choiced/pixel_size
	db_key = "pixel_size"
	category = PREFERENCE_CATEGORY_GAME_PREFERENCES
	player_var = "pixel_size"

/datum/preference/choiced/pixel_size/init_possible_values()
	return list(PIXEL_SCALING_AUTO, PIXEL_SCALING_1X, PIXEL_SCALING_1_2X, PIXEL_SCALING_2X, PIXEL_SCALING_3X)

/datum/preference/choiced/pixel_size/deserialize(input, datum/preferences/prefs)
	return istext(input) ? text2num(input) : input

/datum/preference/choiced/pixel_size/on_changed(datum/preferences/prefs, client/C, old_value, new_value)
	C?.view_size?.resetToDefault(getScreenSize(prefs.toggles2 & PREFTOGGLE_2_WIDESCREEN))

/datum/preference/choiced/scaling_method
	db_key = "scaling_method"
	category = PREFERENCE_CATEGORY_GAME_PREFERENCES
	player_var = "scaling_method"

/datum/preference/choiced/scaling_method/init_possible_values()
	return list(SCALING_METHOD_NORMAL, SCALING_METHOD_DISTORT, SCALING_METHOD_BLUR)

/datum/preference/choiced/scaling_method/on_changed(datum/preferences/prefs, client/C, old_value, new_value)
	C?.view_size?.setZoomMode()

/datum/preference/numeric/clientfps
	db_key = "clientfps"
	category = PREFERENCE_CATEGORY_GAME_PREFERENCES
	player_var = "clientfps"
	minimum = -1
	maximum = 240

/// -1 z okna to "zalecane", u nas 60 (domyślne Aquili)
/datum/preference/numeric/clientfps/deserialize(input, datum/preferences/prefs)
	. = ..()
	if(. == -1)
		return 60

/datum/preference/numeric/clientfps/on_changed(datum/preferences/prefs, client/C, old_value, new_value)
	if(C)
		C.fps = new_value

/datum/preference/numeric/clientfps/compile_constant_data()
	var/list/data = ..()
	data["recommended_fps"] = 60
	return data

/datum/preference/toggle/player/glasses_color
	db_key = "glasses_color"
	toggle_var = "toggles2"
	toggle_bit = PREFTOGGLE_2_USES_GLASSES_COLOUR

/datum/preference/toggle/player/walk_animation
	db_key = "walk_animation"
	toggle_var = "toggles2"
	toggle_bit = PREFTOGGLE_2_DISABLE_WALK_ANIMATION
	toggle_inverted = TRUE

/datum/preference/toggle/player/walk_animation/on_changed(datum/preferences/prefs, client/C, old_value, new_value)
	if(ishuman(C?.mob))
		var/mob/living/carbon/human/H = C.mob
		H.update_walk_animation()

/datum/preference/toggle/player/itemoutline_pref
	db_key = "itemoutline_pref"
	toggle_var = "toggles"
	toggle_bit = PREFTOGGLE_OUTLINE_ENABLED

/datum/preference/color/outline_color
	db_key = "outline_color"
	category = PREFERENCE_CATEGORY_GAME_PREFERENCES
	player_var = "outline_color"
	color_with_crunch = TRUE

// Interfejs

/datum/preference/choiced/ui_style
	db_key = "ui_style"
	category = PREFERENCE_CATEGORY_GAME_PREFERENCES
	player_var = "UI_style"
	should_generate_icons = TRUE

/datum/preference/choiced/ui_style/init_possible_values()
	return GLOB.available_ui_styles.Copy()

/datum/preference/choiced/ui_style/icon_for(value)
	// Okno pokazuje te ikony jako preferences64x32: dwie dłonie obok siebie
	var/icon/icons = GLOB.available_ui_styles[value]
	var/icon/hands = icon(icons, "hand_r")
	hands.Crop(1, 1, world.icon_size * 2, world.icon_size)
	hands.Blend(icon(icons, "hand_l"), ICON_OVERLAY, world.icon_size + 1, 1)
	return hands

/datum/preference/choiced/ui_style/on_changed(datum/preferences/prefs, client/C, old_value, new_value)
	C?.mob?.hud_used?.update_ui_style(ui_style2icon(new_value))

/datum/preference/toggle/player/intent_style
	db_key = "intent_style"
	toggle_var = "toggles"
	toggle_bit = PREFTOGGLE_INTENT_STYLE

/datum/preference/toggle/player/screentips
	db_key = "screentips"
	toggle_var = "toggles2"
	toggle_bit = PREFTOGGLE_2_DISABLE_SCREENTIPS
	toggle_inverted = TRUE

/datum/preference/toggle/player/enable_tips
	db_key = "enable_tips"
	toggle_var = "toggles2"
	toggle_bit = PREFTOGGLE_2_ENABLE_TIPS

/datum/preference/toggle/player/buttons_locked
	db_key = "buttons_locked"
	toggle_var = "toggles2"
	toggle_bit = PREFTOGGLE_2_LOCKED_BUTTONS

/datum/preference/toggle/player/hotkeys
	db_key = "hotkeys"
	toggle_var = "toggles2"
	toggle_bit = PREFTOGGLE_2_HOTKEYS

/datum/preference/toggle/player/hotkeys/on_changed(datum/preferences/prefs, client/C, old_value, new_value)
	if(C)
		winset(C, null, "input.focus=true input.background-color=[COLOR_INPUT_ENABLED] mainwindow.macro=[new_value ? "default" : "old_default"]")

/datum/preference/toggle/player/windowflashing
	db_key = "windowflashing"
	toggle_var = "toggles2"
	toggle_bit = PREFTOGGLE_2_WINDOW_FLASHING

/datum/preference/toggle/player/crew_objectives
	db_key = "crew_objectives"
	toggle_var = "toggles2"
	toggle_bit = PREFTOGGLE_2_CREW_OBJECTIVES

/datum/preference/toggle/player/show_credits
	db_key = "show_credits"
	toggle_var = "toggles2"
	toggle_bit = PREFTOGGLE_2_SHOW_CREDITS

/datum/preference/toggle/player/tgui_fancy
	db_key = "tgui_fancy"
	toggle_var = "toggles2"
	toggle_bit = PREFTOGGLE_2_FANCY_TGUI

/datum/preference/toggle/player/tgui_lock
	db_key = "tgui_lock"
	toggle_var = "toggles2"
	toggle_bit = PREFTOGGLE_2_LOCKED_TGUI

/datum/preference/toggle/player/tgui_input
	db_key = "tgui_input"
	toggle_var = "toggles2"
	toggle_bit = PREFTOGGLE_2_TGUI_INPUT

/datum/preference/toggle/player/tgui_input_large
	db_key = "tgui_input_large"
	toggle_var = "toggles2"
	toggle_bit = PREFTOGGLE_2_BIG_BUTTONS

/datum/preference/toggle/player/tgui_input_swapped
	db_key = "tgui_input_swapped"
	toggle_var = "toggles2"
	toggle_bit = PREFTOGGLE_2_SWITCHED_BUTTONS

/datum/preference/toggle/player/tgui_say
	db_key = "tgui_say"
	toggle_var = "toggles2"
	toggle_bit = PREFTOGGLE_2_TGUI_SAY

/datum/preference/toggle/player/tgui_say/on_changed(datum/preferences/prefs, client/C, old_value, new_value)
	if(!C)
		return
	C.tgui_say?.close()
	C.set_macros()

/datum/preference/toggle/player/tgui_say_light_mode
	db_key = "tgui_say_light_mode"
	toggle_var = "toggles2"
	toggle_bit = PREFTOGGLE_2_SAY_LIGHT_THEME

/datum/preference/toggle/player/tgui_say_light_mode/on_changed(datum/preferences/prefs, client/C, old_value, new_value)
	C?.tgui_say?.load()

/datum/preference/toggle/player/tgui_say_show_prefix
	db_key = "tgui_say_show_prefix"
	toggle_var = "toggles2"
	toggle_bit = PREFTOGGLE_2_SAY_SHOW_PREFIX

/datum/preference/toggle/player/tgui_say_show_prefix/on_changed(datum/preferences/prefs, client/C, old_value, new_value)
	C?.tgui_say?.load()

/// PDA są u nas ustawieniem gracza, ale stare menu i Bee trzymały je przy postaci
/datum/preference/choiced/pda_theme
	db_key = "pda_theme"
	category = PREFERENCE_CATEGORY_NON_CONTEXTUAL
	player_var = "pda_theme"

/datum/preference/choiced/pda_theme/should_show_on_page(preference_tab)
	return preference_tab == PREFERENCE_TAB_CHARACTER_PREFERENCES

/datum/preference/choiced/pda_theme/init_possible_values()
	var/list/themes = list()
	for(var/name in GLOB.ntos_device_themes_default)
		themes += GLOB.ntos_device_themes_default[name]
	return themes

/datum/preference/choiced/pda_theme/get_display_names()
	var/list/names = list()
	for(var/name in GLOB.ntos_device_themes_default)
		names[GLOB.ntos_device_themes_default[name]] = name
	return names

/datum/preference/color/pda_classic_color
	db_key = "pda_classic_color"
	category = PREFERENCE_CATEGORY_NON_CONTEXTUAL
	player_var = "pda_color"
	color_with_crunch = TRUE

/datum/preference/color/pda_classic_color/should_show_on_page(preference_tab)
	return preference_tab == PREFERENCE_TAB_CHARACTER_PREFERENCES

// Rozgrywka

/datum/preference/choiced/preferred_map
	db_key = "preferred_map"
	category = PREFERENCE_CATEGORY_GAME_PREFERENCES
	player_var = "preferred_map"

/datum/preference/choiced/preferred_map/init_possible_values()
	var/list/maps = list("Default")
	for(var/map in config.maplist)
		var/datum/map_config/map_config = config.maplist[map]
		if(map_config.votable)
			maps += map_config.map_name
	return maps

/datum/preference/choiced/preferred_map/read_value(datum/preferences/prefs)
	return prefs.preferred_map || "Default"

/datum/preference/choiced/preferred_map/write_value(datum/preferences/prefs, value)
	prefs.preferred_map = value == "Default" ? null : value

/datum/preference/choiced/preferred_map/get_display_names()
	var/list/names = list()
	for(var/map in get_choices())
		names[map] = map
	if(config.defaultmap)
		names["Default"] = "Default ([config.defaultmap.map_name])"
	return names

// Admin

/datum/preference/toggle/player/sound_adminhelp
	db_key = "sound_adminhelp"
	toggle_var = "toggles"
	toggle_bit = PREFTOGGLE_SOUND_ADMINHELP
	admin_only = TRUE

/datum/preference/toggle/player/sound_prayers
	db_key = "sound_prayers"
	toggle_var = "toggles"
	toggle_bit = PREFTOGGLE_SOUND_PRAYERS
	admin_only = TRUE

/datum/preference/toggle/player/announce_login
	db_key = "announce_login"
	toggle_var = "toggles"
	toggle_bit = PREFTOGGLE_ANNOUNCE_LOGIN
	admin_only = TRUE

/datum/preference/toggle/player/combohud_lighting
	db_key = "combohud_lighting"
	toggle_var = "toggles"
	toggle_bit = PREFTOGGLE_COMBOHUD_LIGHTING
	admin_only = TRUE

/datum/preference/toggle/player/chat_dead
	db_key = "chat_dead"
	toggle_var = "chat_toggles"
	toggle_bit = CHAT_DEAD
	admin_only = TRUE

/datum/preference/toggle/player/chat_prayer
	db_key = "chat_prayer"
	toggle_var = "chat_toggles"
	toggle_bit = CHAT_PRAYER
	admin_only = TRUE

/datum/preference/toggle/player/chat_radio
	db_key = "chat_radio"
	toggle_var = "chat_toggles"
	toggle_bit = CHAT_RADIO
	admin_only = TRUE

/datum/preference/toggle/player/deadmin_always
	db_key = "deadmin_always"
	toggle_var = "toggles"
	toggle_bit = PREFTOGGLE_DEADMIN_ALWAYS
	admin_only = TRUE

/datum/preference/toggle/player/deadmin_antagonist
	db_key = "deadmin_antagonist"
	toggle_var = "toggles"
	toggle_bit = PREFTOGGLE_DEADMIN_ANTAGONIST
	admin_only = TRUE

/datum/preference/toggle/player/deadmin_position_head
	db_key = "deadmin_position_head"
	toggle_var = "toggles"
	toggle_bit = PREFTOGGLE_DEADMIN_POSITION_HEAD
	admin_only = TRUE

/datum/preference/toggle/player/deadmin_position_security
	db_key = "deadmin_position_security"
	toggle_var = "toggles"
	toggle_bit = PREFTOGGLE_DEADMIN_POSITION_SECURITY
	admin_only = TRUE

/datum/preference/toggle/player/deadmin_position_silicon
	db_key = "deadmin_position_silicon"
	toggle_var = "toggles"
	toggle_bit = PREFTOGGLE_DEADMIN_POSITION_SILICON
	admin_only = TRUE

/datum/preference/color/asay_color
	db_key = "asaycolor"
	category = PREFERENCE_CATEGORY_GAME_PREFERENCES
	player_var = "asaycolor"
	color_with_crunch = TRUE

/datum/preference/color/asay_color/is_accessible(datum/preferences/prefs)
	return ..() && prefs.parent?.holder && CONFIG_GET(flag/allow_admin_asaycolor)
