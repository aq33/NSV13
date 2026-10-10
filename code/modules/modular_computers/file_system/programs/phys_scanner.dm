/datum/computer_file/program/phys_scanner
	filename = "phys_scanner"
	filedesc = "Skaner fizyczny"
	program_icon_state = "generic"
	category = PROGRAM_CATEGORY_MISC
	extended_desc = "Ten program pozwala tabletowi skanować obiekty fizyczne i wyświetlać dane."
	size = 8
	usage_flags = PROGRAM_TABLET
	available_on_ntnet = FALSE
	tgui_id = "NtosPhysScanner"
	program_icon = "barcode"
	// Process attack calls from the computer
	use_attack = TRUE
	use_attack_obj = TRUE

	var/current_mode = 0
	var/available_modes = 0

	var/last_record = ""

/datum/computer_file/program/phys_scanner/proc/mode_to_names(mode_holder, use_list = FALSE)
	var/reads = list()
	if(mode_holder & DISK_CHEM)
		reads += "Reagent"
	if(mode_holder & DISK_MED)
		reads += "Health"
	if(mode_holder & DISK_POWER)
		reads += "Radiation"
	if(mode_holder & DISK_ATMOS)
		reads += "Gas"
	if(!length(reads))
		return
	return use_list ? reads : reads[1]

/datum/computer_file/program/phys_scanner/proc/ReadModes()
	return mode_to_names(available_modes, use_list = TRUE)

/datum/computer_file/program/phys_scanner/proc/ReadCurrent()
	return mode_to_names(current_mode)

/datum/computer_file/program/phys_scanner/attack(atom/target, mob/living/user, params)
	switch(current_mode)
		if(DISK_CHEM)
			var/mob/living/carbon/carbon = target
			if(istype(carbon))
				user.visible_message("<span class='notice'>[user] analyzes [carbon]'s vitals.</span>", "<span class='notice'>Analizujesz funkcje życiowe [carbon].</span>")
				last_record = chemscan(user, carbon)
				return FALSE
			else if(!istype(target, /obj/item/reagent_containers/pill/floorpill) && !istype(target, /obj/item/reagent_containers/glass/chem_heirloom))
				if(!isnull(target.reagents))
					if(target.reagents.reagent_list.len > 0)
						var/reagents_length = target.reagents.reagent_list.len
						last_record = "Znaleziono substancje chemiczne: [reagents_length].\n"
						for (var/re in target.reagents.reagent_list)
							last_record += "\t [re]\n"
					else
						last_record = "Nie znaleziono aktywnych substancji chemicznych w [target]."
				else
					last_record = "Nie znaleziono istotnych substancji chemicznych w [target]."
				return FALSE
		if(DISK_MED)
			var/mob/living/carbon/carbon = target
			if(istype(carbon))
				user.visible_message("<span class='notice'>[user] analyzes [carbon]'s vitals.</span>", "<span class='notice'>Analizujesz funkcje życiowe [carbon].</span>")
				last_record = healthscan(user, carbon, 1)
				return FALSE
		if(DISK_POWER)
			var/mob/living/carbon/carbon = target
			if(istype(carbon))
				user.visible_message("<span class='notice'>[user] analizuje poziom promieniowania [carbon].</span>", "<span class='notice'>Analizujesz poziom promieniowania [carbon].</span>")
				last_record = "Wyniki analizy dla [carbon]:\n"
				if(carbon.radiation)
					last_record += "Poziom promieniowania: [carbon.radiation]%"
				else
					last_record += "Nie wykryto promieniowania."
				return FALSE
	return ..()

/datum/computer_file/program/phys_scanner/attack_obj(obj/target, mob/living/user)
	switch(current_mode)
		if(DISK_ATMOS)
			var/scan_result = atmosanalyzer_scan(user, target, silent = TRUE)
			if(scan_result)
				user.visible_message("[user] analizuje zawartość gazów [icon2html(target, viewers(user))] [target].", "<span class='notice'>Analizujesz zawartość gazów [icon2html(target, user)] [target].</span>")
				last_record = scan_result
				return FALSE
	return ..()

/datum/computer_file/program/phys_scanner/ui_act(action, list/params, datum/tgui/ui)
	. = ..()
	if(.)
		return

	switch(action)
		if("selectMode")
			switch(params["newMode"])
				if("Reagent")
					current_mode = DISK_CHEM
				if("Health")
					current_mode = DISK_MED
				if("Radiation")
					current_mode = DISK_POWER
				if("Gas")
					current_mode = DISK_ATMOS

	return UI_UPDATE


/datum/computer_file/program/phys_scanner/ui_data(mob/user)
	var/list/data = list()

	data["set_mode"] = ReadCurrent()
	data["last_record"] = last_record
	data["available_modes"] = ReadModes()

	return data
