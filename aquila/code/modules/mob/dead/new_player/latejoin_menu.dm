// Okno wyboru profesji przy dołączaniu w trakcie rundy w TGUI (JobSelection) zamiast tabelki HTML z LateChoices().
// Kliknięcie roli idzie tą samą drogą co dawny link SelectedJob, więc kolejka i limity graczy działają jak wcześniej.

GLOBAL_DATUM_INIT(latejoin_menu, /datum/latejoin_menu, new)

/datum/latejoin_menu

/datum/latejoin_menu/ui_state(mob/user)
	return GLOB.always_state

/datum/latejoin_menu/ui_status(mob/user, datum/ui_state/state)
	return isnewplayer(user) ? UI_INTERACTIVE : UI_CLOSE

/datum/latejoin_menu/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "JobSelection", "Wybierz profesję")
		ui.set_autoupdate(TRUE)
		ui.open()

/datum/latejoin_menu/ui_assets(mob/user)
	return list(get_asset_datum(/datum/asset/spritesheet/job_icons))

/// Działy w kolejności wyświetlania: nazwa, kolor, lista ról
/datum/latejoin_menu/proc/get_departments()
	var/static/list/departments
	if(departments)
		return departments
	departments = list(
		list("name" = "Dowództwo", "color" = "#9db5ff", "jobs" = GLOB.command_positions),
		list("name" = "Ochrona", "color" = "#ff7a7a", "jobs" = GLOB.security_positions),
		list("name" = "Amunicja", "color" = "#ffa94d", "jobs" = GLOB.munitions_positions),
		list("name" = "Inżynieria", "color" = "#f5c04a", "jobs" = GLOB.engineering_positions),
		list("name" = "Medyczny", "color" = "#5fd1c4", "jobs" = GLOB.medical_positions),
		list("name" = "Nauka", "color" = "#d48cff", "jobs" = GLOB.science_positions),
		list("name" = "Zaopatrzenie", "color" = "#c9a173", "jobs" = GLOB.supply_positions),
		list("name" = "Cywile", "color" = "#9ed672", "jobs" = GLOB.civilian_positions),
		list("name" = "Specjalne", "color" = "#bbbbbb", "jobs" = GLOB.gimmick_positions),
		list("name" = "Syntetyki", "color" = "#ff8fd0", "jobs" = GLOB.nonhuman_positions - JOB_NAME_PAI),
	)
	return departments

/datum/latejoin_menu/ui_static_data(mob/user)
	var/list/departments = list()
	for(var/list/department as anything in get_departments())
		var/list/jobs = list()
		for(var/job_title in department["jobs"])
			jobs += list(list(
				"title" = job_title,
				"hud" = get_hud_by_jobname(job_title),
				"command" = (job_title in GLOB.command_positions),
			))
		departments += list(list(
			"name" = department["name"],
			"color" = department["color"],
			"jobs" = jobs,
		))
	return list("departments" = departments)

/datum/latejoin_menu/ui_data(mob/user)
	var/mob/dead/new_player/player = user
	var/list/data = list()
	data["round_duration"] = DisplayTimeText(world.time - SSticker.round_start_time)
	var/evacuation
	if(SSshuttle.emergency)
		switch(SSshuttle.emergency.mode)
			if(SHUTTLE_ESCAPE)
				evacuation = "Statek został ewakuowany."
			if(SHUTTLE_CALL)
				if(!SSshuttle.canRecall())
					evacuation = "Na statku trwa ewakuacja."
	data["evacuation"] = evacuation

	for(var/datum/job/prioritized_job in SSjob.prioritized_jobs)
		if(prioritized_job.current_positions >= prioritized_job.total_positions)
			SSjob.prioritized_jobs -= prioritized_job

	// title -> [obsadzone, miejsca (-1 = bez limitu), priorytet, powód niedostępności]
	var/list/jobs = list()
	if(istype(player))
		for(var/list/department as anything in get_departments())
			for(var/job_title in department["jobs"])
				if(jobs[job_title])
					continue
				var/datum/job/job = SSjob.GetJob(job_title)
				if(!job || job.total_positions == 0)
					continue
				var/unavailable = player.IsJobUnavailable(job_title, TRUE)
				// Ogólna niedostępność (np. rola wyłączona dla dołączających) ukrywa rolę jak w starym oknie
				if(unavailable == JOB_UNAVAILABLE_GENERIC)
					continue
				jobs[job_title] = list(
					"current" = job.current_positions,
					"total" = job.total_positions,
					"prioritized" = (job in SSjob.prioritized_jobs),
					"unavailable" = unavailable == JOB_AVAILABLE ? null : get_job_unavailable_error_message(unavailable, job_title),
				)
	data["jobs"] = jobs
	return data

/datum/latejoin_menu/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return
	if(action != "select_job")
		return
	var/mob/dead/new_player/player = ui.user
	if(!istype(player) || !SSjob.GetJob(params["job"]))
		return
	player.Topic(null, list("SelectedJob" = params["job"]))
	return TRUE
