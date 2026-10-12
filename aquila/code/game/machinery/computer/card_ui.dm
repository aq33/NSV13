// Okno konsoli kart ID w TGUI (zamiast HTML z code/game/machinery/computer/card.dm), także działowe konsole szefów.
// Wszystkie przyciski idą przez dawny Topic(), więc uprawnienia działów, logi id, limity wakatów i wypłat zostają bez zmian.
// Numery działów jak w card.dm (tam są #undef): 0 wszystkie, 1 ogólny, 2 ochrona, 3 medyczny, 4 nauka, 5 inżynieria, 6 zaopatrzenie, 7 amunicja

/obj/machinery/computer/card/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "IdentificationConsole", name)
		ui.set_autoupdate(TRUE)
		ui.open()

/obj/machinery/computer/card/ui_data(mob/user)
	var/list/data = list()
	data["mode"] = mode
	data["authenticated"] = authenticated
	data["department_console"] = !!target_dept
	data["centcom"] = istype(src, /obj/machinery/computer/card/centcom)
	data["scan_name"] = inserted_scan_id?.name
	data["modify_name"] = inserted_modify_id?.name
	data["modify_owner"] = inserted_modify_id?.registered_name
	data["modify_rank"] = inserted_modify_id?.assignment || "Unassigned"
	data["printing"] = !!printing
	switch(mode)
		if(1)
			data["manifest"] = card_manifest_data()
		if(2)
			data["jobs"] = card_jobs_data()
		if(3)
			data["accounts"] = card_accounts_data()
		else
			if(authenticated && inserted_modify_id)
				data["regions"] = card_regions_data()
				if(authenticated == 2)
					data["assignable_jobs"] = card_assignable_jobs()
	return data

/obj/machinery/computer/card/proc/card_manifest_data()
	var/list/crew = list()
	for(var/datum/data/record/record in sortRecord(GLOB.data_core.general))
		crew += list(list("name" = record.fields["name"], "rank" = record.fields["rank"]))
	return crew

/obj/machinery/computer/card/proc/card_jobs_data()
	var/list/jobs = list()
	var/can_edit = inserted_scan_id && (ACCESS_CHANGE_IDS in inserted_scan_id.access) && !target_dept
	var/cooldown = max(0, round(change_position_cooldown - ((world.time / 10) - GLOB.time_last_changed_position), 1))
	for(var/datum/job/job in SSjob.occupations)
		if(job.title in blacklisted)
			continue
		jobs += list(list(
			"title" = job.title,
			"current" = job.current_positions,
			"total" = job.total_positions,
			"can_open" = can_open_job(job),
			"can_close" = can_close_job(job),
			"prioritized" = (job in SSjob.prioritized_jobs),
		))
	return list("can_edit" = can_edit, "cooldown" = cooldown, "prioritized_count" = length(SSjob.prioritized_jobs), "list" = jobs)

/obj/machinery/computer/card/proc/card_accounts_data()
	var/list/departments = list()
	if(inserted_scan_id)
		if((ACCESS_HOP in inserted_scan_id.access) && (target_dept == 1 || !target_dept))
			departments |= list(ACCOUNT_SRV, ACCOUNT_CIV, ACCOUNT_CAR)
		if((ACCESS_HOS in inserted_scan_id.access) && (target_dept == 2 || !target_dept))
			departments |= ACCOUNT_SEC
		if((ACCESS_CMO in inserted_scan_id.access) && (target_dept == 3 || !target_dept))
			departments |= ACCOUNT_MED
		if((ACCESS_RD in inserted_scan_id.access) && (target_dept == 4 || !target_dept))
			departments |= ACCOUNT_SCI
		if((ACCESS_CE in inserted_scan_id.access) && (target_dept == 5 || !target_dept))
			departments |= ACCOUNT_ENG
	var/list/accounts = list()
	for(var/datum/bank_account/account as anything in SSeconomy.bank_accounts)
		if(!(account.account_department in departments))
			continue
		accounts += list(list(
			"holder" = account.account_holder,
			"job" = account.account_job?.title,
			"pay" = account.paycheck_amount,
			"bonus" = account.paycheck_bonus,
		))
	return accounts

/obj/machinery/computer/card/proc/card_regions_data()
	var/list/regions = list()
	if(istype(src, /obj/machinery/computer/card/centcom))
		var/list/accesses = list()
		for(var/access in get_all_centcom_access())
			accesses += list(list("id" = access, "desc" = get_centcom_access_desc(access), "granted" = (access in inserted_modify_id.access)))
		regions += list(list("name" = "Central Command", "accesses" = accesses))
		return regions
	for(var/region in 1 to 8)
		if(authenticated == 1 && !(region in region_access))
			continue
		var/list/accesses = list()
		for(var/access in get_region_accesses(region))
			accesses += list(list("id" = access, "desc" = get_access_desc(access), "granted" = (access in inserted_modify_id.access)))
		regions += list(list("name" = get_region_accesses_name(region), "accesses" = accesses))
	return regions

/// Stanowiska do przypisania pogrupowane jak w dawnym oknie
/obj/machinery/computer/card/proc/card_assignable_jobs()
	var/static/list/group_starts = list(
		JOB_NAME_ASSISTANT = "Serwis",
		JOB_NAME_QUARTERMASTER = "Zaopatrzenie",
		JOB_NAME_CHIEFENGINEER = "Inżynieria",
		JOB_NAME_RESEARCHDIRECTOR = "Nauka",
		JOB_NAME_CHIEFMEDICALOFFICER = "Medyczny",
		JOB_NAME_HEADOFSECURITY = "Ochrona",
		JOB_NAME_MASTERATARMS = "Amunicja",
	)
	var/list/groups = list()
	var/list/current = list("name" = "Dowództwo", "jobs" = list("Unassigned"))
	var/list/all_jobs = istype(src, /obj/machinery/computer/card/centcom) ? get_all_centcom_jobs() : get_all_jobs()
	for(var/job in all_jobs)
		if(group_starts[job])
			groups += list(current)
			current = list("name" = group_starts[job], "jobs" = list())
		current["jobs"] += job
	groups += list(current)
	groups += list(list("name" = "Inne", "jobs" = list("Custom")))
	return groups

/obj/machinery/computer/card/ui_act(action, list/params)
	. = ..()
	if(.)
		return
	switch(action)
		if("scan_slot")
			Topic(null, list("choice" = "inserted_scan_id"))
		if("modify_slot")
			Topic(null, list("choice" = "inserted_modify_id"))
		if("login")
			Topic(null, list("choice" = "auth"))
		if("logout")
			Topic(null, list("choice" = "logout"))
		if("mode")
			var/new_mode = text2num(params["mode"])
			if(!(new_mode in list(0, 1, 2, 3)))
				return
			if(new_mode == 2 && target_dept)
				return
			Topic(null, list("choice" = new_mode ? "mode" : "return", "mode_target" = new_mode))
		if("access")
			Topic(null, list("choice" = "access", "access_target" = params["access"], "allowed" = params["allowed"] ? 1 : 0))
		if("assign")
			Topic(null, list("choice" = "assign", "assign_target" = params["job"]))
		if("demote")
			Topic(null, list("choice" = "demote"))
		if("rename")
			if(!authenticated || !inserted_modify_id)
				return
			var/new_name = stripped_input(usr, "Nowe nazwisko na karcie:", "Zmiana nazwiska", inserted_modify_id.registered_name, MAX_NAME_LEN)
			if(!new_name)
				return
			Topic(null, list("choice" = "reg", "reg" = new_name))
		if("open_job", "close_job", "prioritize_job")
			var/static/list/choices = list("open_job" = "make_job_available", "close_job" = "make_job_unavailable", "prioritize_job" = "prioritize_job")
			Topic(null, list("choice" = choices[action], "job" = params["job"]))
		if("adjust_pay", "adjust_bonus")
			Topic(null, list("choice" = action, "account" = params["account"]))
		if("print")
			Topic(null, list("choice" = "print"))
		else
			return
	return TRUE
