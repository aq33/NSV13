/// Okno wyboru lekcji w lobby
/datum/tutorial_menu
	/// Lekcje do pokazania: lista list z danymi typu (bez danych gracza)
	var/static/list/tutorials

/datum/tutorial_menu/New()
	if(!tutorials)
		tutorials = list()
		var/list/sorted_paths = list()
		for(var/datum/tutorial/path as anything in subtypesof(/datum/tutorial))
			if(initial(path.parent_path) == path)
				continue
			sorted_paths[path] = initial(path.order)
		sortTim(sorted_paths, GLOBAL_PROC_REF(cmp_numeric_asc), associative = TRUE)
		for(var/datum/tutorial/path as anything in sorted_paths)
			tutorials += list(list(
				"name" = initial(path.name),
				"id" = initial(path.tutorial_id),
				"description" = initial(path.desc),
				"icon" = initial(path.icon),
				"path" = "[path]",
				"required" = initial(path.required_tutorial),
			))

/datum/tutorial_menu/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "TutorialMenu")
		ui.open()

/datum/tutorial_menu/ui_state(mob/user)
	return GLOB.new_player_state

/datum/tutorial_menu/ui_static_data(mob/user)
	var/list/completed = user.client?.prefs?.get_completed_tutorials() || list()
	var/list/names_by_id = list()
	for(var/list/tutorial as anything in tutorials)
		names_by_id[tutorial["id"]] = tutorial["name"]

	var/list/entries = list()
	for(var/list/tutorial as anything in tutorials)
		var/required = tutorial["required"]
		entries += list(list(
			"name" = tutorial["name"],
			"id" = tutorial["id"],
			"description" = tutorial["description"],
			"icon" = tutorial["icon"],
			"path" = tutorial["path"],
			"completed" = (tutorial["id"] in completed),
			"locked" = (required && !(required in completed)),
			"required_name" = required ? names_by_id[required] : null,
		))
	return list(
		"tutorials" = entries,
		"round_ready" = SSticker.current_state == GAME_STATE_PLAYING,
	)

/datum/tutorial_menu/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return

	switch(action)
		if("select_tutorial")
			var/mob/dead/new_player/user = ui.user
			if(!isnewplayer(user) || !user.client)
				return
			var/datum/tutorial/path = text2path(params["tutorial_path"])
			if(!ispath(path, /datum/tutorial) || initial(path.parent_path) == path) // cmss13#5718
				return
			if(!user.can_start_tutorial())
				return
			var/required = initial(path.required_tutorial)
			if(required && !IS_TUTORIAL_COMPLETED(user.client, required))
				to_chat(user, "<span class='warning'>Najpierw ukończ poprzednią lekcję.</span>")
				return
			var/datum/tutorial/tutorial = new path
			ui.close()
			if(!tutorial.start_tutorial(user) && !QDELETED(tutorial))
				qdel(tutorial)
			return TRUE

/// Lista ID ukończonych lekcji (z bazy przychodzi JSON, więc pilnujemy typu)
/datum/preferences/proc/get_completed_tutorials()
	RETURN_TYPE(/list)
	if(!islist(completed_tutorials))
		completed_tutorials = list()
	return completed_tutorials

/datum/preferences
	/// ID ukończonych lekcji samouczka, zapisywane w bazie (PREFERENCE_TAG_COMPLETED_TUTORIALS)
	var/list/completed_tutorials = list()
