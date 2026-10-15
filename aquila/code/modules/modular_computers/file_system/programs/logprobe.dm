// AQUILA - "Czytnik logów dostępu" (LogProbe z SS14).
// Gdy program działa, kliknięcie tabletem w drzwi albo zamykaną szafkę kopiuje ich log dostępu
// (zamiast otwierać drzwi). Log można wydrukować. Dane zbierają drzwi, patrz detectivework/access_log.dm.

/datum/computer_file/program/logprobe
	filename = "logprobe"
	filedesc = "Czytnik logów dostępu"
	category = PROGRAM_CATEGORY_CREW
	program_icon_state = "generic"
	program_icon = "fingerprint"
	extended_desc = "Odczytuje pamięć czytników ID w drzwiach i szafkach: kto i kiedy użył dostępu. Gdy program działa, kliknij tabletem w drzwi albo szafkę."
	size = 4
	usage_flags = PROGRAM_TABLET
	required_access = list(ACCESS_FORENSICS_LOCKERS, ACCESS_ARMORY)
	transfer_access = list(ACCESS_FORENSICS_LOCKERS, ACCESS_ARMORY)
	tgui_id = "NtosLogProbe"
	/// Komputer, na którym nasłuchujemy kliknięć.
	var/obj/item/modular_computer/hooked_computer
	/// Nazwa ostatnio odczytanego urządzenia.
	var/scanned_device
	/// Obszar ostatnio odczytanego urządzenia.
	var/scanned_area
	/// Czas stacji w chwili odczytu.
	var/scanned_time
	/// Kopia logu (od najnowszego).
	var/list/scanned_entries
	/// Czytnik ID odcięty (przewód) w chwili odczytu.
	var/scanned_disabled = FALSE
	/// Czytnik ID nosi ślady zwarcia (emag).
	var/scanned_damaged = FALSE
	COOLDOWN_DECLARE(print_cooldown)

/datum/computer_file/program/logprobe/on_start(mob/living/user)
	. = ..()
	if(!. || !computer)
		return
	unhook()
	hooked_computer = computer
	RegisterSignal(hooked_computer, COMSIG_ITEM_PRE_ATTACK, PROC_REF(on_pre_attack))
	RegisterSignal(hooked_computer, COMSIG_PARENT_QDELETING, PROC_REF(unhook))

/datum/computer_file/program/logprobe/kill_program(forced = FALSE)
	unhook()
	return ..()

/datum/computer_file/program/logprobe/Destroy()
	unhook()
	return ..()

/datum/computer_file/program/logprobe/proc/unhook()
	SIGNAL_HANDLER
	if(!hooked_computer)
		return
	UnregisterSignal(hooked_computer, list(COMSIG_ITEM_PRE_ATTACK, COMSIG_PARENT_QDELETING))
	hooked_computer = null

/datum/computer_file/program/logprobe/proc/on_pre_attack(datum/source, atom/target, mob/user, params)
	SIGNAL_HANDLER
	if(!isobj(target) || program_state == PROGRAM_STATE_KILLED)
		return
	var/obj/device = target
	if(!device.aq_has_access_log())
		return
	scan_device(device, user)
	return COMPONENT_NO_ATTACK

/datum/computer_file/program/logprobe/proc/scan_device(obj/device, mob/user)
	scanned_damaged = !!device.aq_access_log_wiped()
	scanned_disabled = !!device.aq_access_log_disabled()
	scanned_entries = device.aq_read_access_log()
	scanned_device = "[device.name]"
	scanned_area = get_area_name(device, TRUE)
	scanned_time = station_time_timestamp()
	playsound(hooked_computer, 'sound/machines/ping.ogg', 30, TRUE)
	user.visible_message("<span class='notice'>[user] przykłada [hooked_computer] do czytnika ID [device].</span>", \
		"<span class='notice'>Kopiujesz log dostępu [device]: [length(scanned_entries)] wpisów.</span>")
	SStgui.update_uis(hooked_computer)

/datum/computer_file/program/logprobe/ui_data(mob/user)
	var/list/data = list()
	data["device"] = scanned_device
	data["area"] = scanned_area
	data["scan_time"] = scanned_time
	data["entries"] = scanned_entries || list()
	data["logging_disabled"] = scanned_disabled
	data["damaged"] = scanned_damaged
	return data

/datum/computer_file/program/logprobe/ui_act(action, list/params, datum/tgui/ui)
	. = ..()
	if(.)
		return
	switch(action)
		if("print")
			print_log(usr)
			return TRUE
		if("clear")
			scanned_device = null
			scanned_area = null
			scanned_time = null
			scanned_entries = null
			scanned_disabled = FALSE
			scanned_damaged = FALSE
			return TRUE

/datum/computer_file/program/logprobe/proc/build_report()
	var/list/text = list()
	text += "<h3>Log dostępu</h3>"
	text += "<b>Urządzenie:</b> [scanned_device]<br>"
	text += "<b>Miejsce:</b> [scanned_area]<br>"
	text += "<b>Odczyt:</b> [scanned_time]<br>"
	if(scanned_disabled)
		text += "<i>Uwaga: czytnik ID był odłączony, logowanie nie działało.</i><br>"
	if(scanned_damaged)
		text += "<i>Uwaga: czytnik ID nosi ślady zwarcia, pamięć jest pusta.</i><br>"
	text += "<hr>"
	if(!length(scanned_entries))
		text += "Brak wpisów.<br>"
	var/index = 0
	for(var/list/entry as anything in scanned_entries)
		index++
		text += "[index]. [entry["time"]] - [entry["name"]] ([entry["action"]])<br>"
	return text.Join()

/datum/computer_file/program/logprobe/proc/print_log(mob/user)
	if(!computer || !scanned_device)
		return
	if(!COOLDOWN_FINISHED(src, print_cooldown))
		to_chat(user, "<span class='warning'>Drukowanie jeszcze trwa.</span>")
		return
	COOLDOWN_START(src, print_cooldown, 5 SECONDS)
	var/title = "log dostępu - [scanned_device]"
	var/obj/item/computer_hardware/printer/printer = computer.all_components[MC_PRINT]
	if(printer)
		if(!printer.print_text(build_report(), title))
			to_chat(user, "<span class='warning'>Drukarka nie mogła wydrukować logu. Może brakuje papieru.</span>")
			return
	else
		// Jak w SS14: PDA bez drukarki wydaje mały wydruk termiczny.
		var/obj/item/paper/printout = new(computer.drop_location())
		printout.name = title
		printout.add_raw_text(build_report())
		printout.update_icon()
		user?.put_in_hands(printout)
	playsound(computer, 'sound/machines/terminal_on.ogg', 50, FALSE)
	computer.visible_message("<span class='notice'>[computer] drukuje log dostępu.</span>")

// ---- Dyski ról: detektyw i HoS mają program od razu. Warden może go pobrać z NTNet. ----

/obj/item/computer_hardware/hard_drive/role
	/// AQUILA - preinstalowany czytnik logów dostępu
	var/aq_logprobe = FALSE

/obj/item/computer_hardware/hard_drive/role/detective
	aq_logprobe = TRUE

/obj/item/computer_hardware/hard_drive/role/hos
	aq_logprobe = TRUE

/obj/item/computer_hardware/hard_drive/role/Initialize(mapload)
	. = ..()
	if(!aq_logprobe)
		return
	var/datum/computer_file/program/logprobe/probe = new(src)
	probe.required_access = list()
	probe.transfer_access = list()
	store_file(probe)
