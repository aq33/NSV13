// Port BeeStation #8776: okno PreferencesMenu (TGUI) na naszym /datum/preferences.
// Zastępuje stare okno HTML (ShowChoices). Dane zostają tam, gdzie były; zapis przy zamknięciu okna i przy zmianie postaci.

/datum/preferences
	/// PREFERENCE_TAB_*: która strona okna jest otwarta
	var/current_window = PREFERENCE_TAB_CHARACTER_PREFERENCES
	/// Instancje /datum/preference_middleware, tworzone przy pierwszym otwarciu okna
	var/list/datum/preference_middleware/middleware
	/// Podgląd postaci w oknie
	var/atom/movable/screen/map_view/character_preview/character_preview_view

/// Otwiera okno na danej stronie (PREFERENCE_TAB_*)
/datum/preferences/proc/open_menu(mob/user, window = PREFERENCE_TAB_CHARACTER_PREFERENCES)
	if(!user?.client || user.client != parent)
		return
	if(!length(SSjob.occupations))
		to_chat(user, "<span class='warning'>The job subsystem is still initializing, try again in a moment.</span>")
		return
	if(!middleware)
		middleware = list()
		for(var/middleware_type in subtypesof(/datum/preference_middleware))
			middleware += new middleware_type(src)
	var/datum/preference_middleware/loadout/loadout = locate() in middleware
	loadout?.refresh_balance()
	var/datum/tgui/ui = SStgui.get_open_ui(user, src)
	if(ui && current_window != window)
		current_window = window
		update_static_data(user, ui)
	current_window = window
	ui_interact(user, ui)

/datum/preferences/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		create_character_preview(user)
		ui = new(user, src, "PreferencesMenu")
		ui.set_autoupdate(FALSE)
		ui.open()

/datum/preferences/ui_state(mob/user)
	return GLOB.always_state

/// Tylko właściciel może zmieniać swoje preferencje
/datum/preferences/ui_status(mob/user, datum/ui_state/state)
	return user.client == parent ? UI_INTERACTIVE : UI_CLOSE

/datum/preferences/ui_assets(mob/user)
	var/list/assets = list(
		get_asset_datum(/datum/asset/spritesheet/preferences),
		get_asset_datum(/datum/asset/spritesheet/preferences/large),
		get_asset_datum(/datum/asset/spritesheet/preferences/huge),
		get_asset_datum(/datum/asset/json/preferences),
	)
	for(var/datum/preference_middleware/preference_middleware as anything in middleware)
		assets += preference_middleware.get_ui_assets()
	return assets

/datum/preferences/ui_data(mob/user)
	var/list/data = list()
	var/list/profiles = list()
	for(var/i in 1 to max_usable_slots)
		var/datum/character_save/save = character_saves[i]
		profiles += save?.from_db || save == active_character ? save.real_name : null
	data["character_profiles"] = profiles
	data["character_preferences"] = compile_character_preferences(user)
	data["active_slot"] = default_slot
	data["max_slot"] = max_usable_slots
	data["save_in_progress"] = FALSE
	data["is_guest"] = IS_GUEST_KEY(parent.key)
	data["is_db"] = SSdbcore.IsConnected()
	data["save_sucess"] = TRUE
	for(var/datum/preference_middleware/preference_middleware as anything in middleware)
		data += preference_middleware.get_ui_data(user)
	return data

/datum/preferences/ui_static_data(mob/user)
	var/list/data = list()
	data["character_preview_view"] = character_preview_view?.assigned_map
	data["overflow_role"] = SSjob.overflow_role
	data["window"] = current_window
	data["content_unlocked"] = unlock_content
	for(var/datum/preference_middleware/preference_middleware as anything in middleware)
		data += preference_middleware.get_ui_static_data(user)
	return data

/// Wartości wszystkich dostępnych wpisów, pogrupowane po kategoriach
/datum/preferences/proc/compile_character_preferences(mob/user)
	var/list/preferences = list(
		PREFERENCE_CATEGORY_MISC = list(),
		PREFERENCE_CATEGORY_NAMES = list(),
		PREFERENCE_CATEGORY_CLOTHING = list(),
		PREFERENCE_CATEGORY_FEATURES = list(),
		PREFERENCE_CATEGORY_NON_CONTEXTUAL = list(),
		PREFERENCE_CATEGORY_SECONDARY_FEATURES = list(),
		PREFERENCE_CATEGORY_SUPPLEMENTAL_FEATURES = list(),
		PREFERENCE_CATEGORY_GAME_PREFERENCES = list(),
	)
	for(var/preference_type in GLOB.preference_entries)
		var/datum/preference/preference = GLOB.preference_entries[preference_type]
		// Nazwy i dane podstawowe okno czyta zawsze, reszta zależy od strony
		var/always = preference.category == PREFERENCE_CATEGORY_MISC || preference.category == PREFERENCE_CATEGORY_NAMES
		if(!always && !preference.should_show_on_page(current_window))
			continue
		if(!preference.is_accessible(src))
			continue
		var/list/category = preferences[preference.category]
		category[preference.db_key] = preference.compile_ui_data(user, preference.read_value(src))
	for(var/datum/preference_middleware/preference_middleware as anything in middleware)
		var/list/append = preference_middleware.get_character_preferences(user)
		for(var/category in append)
			if(category in preferences)
				preferences[category] += append[category]
			else
				preferences[category] = append[category]
	return preferences

/datum/preferences/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return
	switch(action)
		if("change_slot")
			var/new_slot = text2num(params["slot"])
			if(!isnum(new_slot) || new_slot == default_slot || new_slot < 1 || new_slot > max_usable_slots)
				return FALSE
			var/datum/character_save/new_character = character_saves[new_slot]
			if(!new_character || new_character.slot_locked)
				return FALSE
			active_character.save(parent)
			active_character = new_character
			default_slot = new_slot
			if(!new_character.from_db)
				new_character.randomise()
				new_character.real_name = new_character.pref_species.random_name(new_character.gender, TRUE)
				new_character.save(parent)
			new_character.ensure_valid(parent)
			save_preferences()
			for(var/datum/preference_middleware/preference_middleware as anything in middleware)
				preference_middleware.on_new_character(usr)
			update_static_data(usr, ui)
			update_character_preview()
			return TRUE
		if("rotate")
			character_preview_view?.rotate(params["direction"] ? -90 : 90)
			return FALSE
		if("set_preference")
			var/datum/preference/preference = GLOB.preference_entries_by_key[params["preference"]]
			if(isnull(preference))
				return FALSE
			if(!update_preference(preference, params["value"]))
				return TRUE
			if(preference.preference_type == PREFERENCE_CHARACTER)
				update_character_preview()
			return TRUE
		if("set_color_preference")
			var/datum/preference/color/preference = GLOB.preference_entries_by_key[params["preference"]]
			if(!istype(preference) || !preference.is_accessible(src))
				return FALSE
			var/new_color = input(usr, "Select new color", "Preference Color", preference.serialize(preference.read_value(src))) as color|null
			if(!new_color || QDELETED(src))
				return FALSE
			if(!update_preference(preference, new_color))
				return TRUE
			if(preference.preference_type == PREFERENCE_CHARACTER)
				update_character_preview()
			return TRUE
		if("edit_text_preference")
			var/datum/preference/text/preference = GLOB.preference_entries_by_key[params["preference"]]
			if(!istype(preference) || !preference.is_accessible(src))
				return FALSE
			var/new_text = input(usr, preference.edit_prompt, "Character Preference", preference.read_value(src)) as message|null
			if(isnull(new_text) || QDELETED(src))
				return FALSE
			return update_preference(preference, new_text)
		if("open_game_preferences")
			open_menu(usr, PREFERENCE_TAB_GAME_PREFERENCES)
			return TRUE
		if("open_character_preferences")
			open_menu(usr, PREFERENCE_TAB_CHARACTER_PREFERENCES)
			return TRUE
		if("open_keybindings")
			open_menu(usr, PREFERENCE_TAB_KEYBINDINGS)
			return TRUE
		if("open_syndie_roles")
			parent.select_syndie_role()
			return FALSE
	for(var/datum/preference_middleware/preference_middleware as anything in middleware)
		var/delegation = preference_middleware.action_delegations[action]
		if(!isnull(delegation))
			return call(preference_middleware, delegation)(params, usr)
	return FALSE

/datum/preferences/ui_close(mob/user)
	if(active_character)
		active_character.save(parent)
	save_preferences()
	if(character_preview_view)
		parent?.clear_map(character_preview_view.assigned_map)
		QDEL_NULL(character_preview_view)
	preview_gear = null

/datum/preferences/proc/create_character_preview(mob/user)
	if(character_preview_view)
		parent?.clear_map(character_preview_view.assigned_map)
		QDEL_NULL(character_preview_view)
	character_preview_view = new
	character_preview_view.assigned_map = "character_preview_[REF(character_preview_view)]_map"
	character_preview_view.screen_loc = "[character_preview_view.assigned_map]:1,1"
	parent.register_map_obj(character_preview_view)
	update_character_preview()

/datum/preferences/proc/update_character_preview()
	if(!character_preview_view || !active_character)
		return
	character_preview_view.set_body(render_preview_appearance())

/// Wygląd postaci w ubraniu pracy z najwyższym priorytetem, z loadoutem i podglądanym przedmiotem
/datum/preferences/proc/render_preview_appearance()
	var/datum/job/preview_job = active_character.get_highest_job()
	if(istype(preview_job, /datum/job/ai))
		return image('icons/mob/ai.dmi', icon_state = resolve_ai_icon(active_character.preferred_ai_core_display), dir = SOUTH)
	if(istype(preview_job, /datum/job/cyborg))
		return image('icons/mob/robots.dmi', icon_state = "robot", dir = SOUTH)

	var/mob/living/carbon/human/dummy/mannequin = generate_or_wait_for_human_dummy(DUMMY_HUMAN_SLOT_PREFERENCES)
	active_character.copy_to(mannequin)
	if(preview_job)
		mannequin.job = preview_job.title
		preview_job.equip(mannequin, TRUE, preference_source = parent)
	for(var/gear_id in active_character.equipped_gear)
		var/datum/gear/gear = GLOB.gear_datums[gear_id]
		gear?.preview_on(mannequin)
	if(preview_gear)
		var/datum/gear/gear = GLOB.gear_datums[preview_gear]
		gear?.preview_on(mannequin)
	COMPILE_OVERLAYS(mannequin)
	var/mutable_appearance/appearance = new /mutable_appearance(mannequin)
	unset_busy_human_dummy(DUMMY_HUMAN_SLOT_PREFERENCES)
	return appearance

/// Ekran z podglądem postaci w oknie preferencji.
/// Wygląd postaci nakładamy na sam obiekt ekranu, jak stare menu: mapa boczna dopasowuje
/// powiększenie do obiektów, które sama rysuje, a obiekt bez ikony (np. z postacią w vis_contents)
/// się nie liczy i mapa pokazywała cały widok gracza z malutką postacią w rogu.
/atom/movable/screen/map_view/character_preview
	name = "character_preview"
	del_on_map_removal = FALSE
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	var/facing = SOUTH

/atom/movable/screen/map_view/character_preview/proc/set_body(appearance)
	var/old_screen_loc = screen_loc
	src.appearance = appearance
	screen_loc = old_screen_loc
	dir = facing
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT

/atom/movable/screen/map_view/character_preview/proc/rotate(angle)
	facing = turn(facing, angle)
	dir = facing

/// Wejścia z kodu core (lobby, verb ustawień), który nie widzi definicji PREFERENCE_TAB_*
/datum/preferences/proc/open_character_menu(mob/user)
	open_menu(user, PREFERENCE_TAB_CHARACTER_PREFERENCES)

/datum/preferences/proc/open_game_menu(mob/user)
	open_menu(user, PREFERENCE_TAB_GAME_PREFERENCES)

/client/verb/open_keybindings_menu()
	set name = "Klawiszologia"
	set category = "Preferences"
	set desc = "Ustaw skróty klawiszowe"
	prefs.open_menu(usr, PREFERENCE_TAB_KEYBINDINGS)
