/datum/computer_file/program/crew_manifest
	filename = "crewmani"
	filedesc = "Manifest załogi"
	category = PROGRAM_CATEGORY_CREW
	program_icon_state = "id"
	extended_desc = "Program do przeglądania i drukowania aktualnego manifestu załogi"
	transfer_access = list(ACCESS_HEADS)
	requires_ntnet = FALSE
	size = 4
	tgui_id = "NtosCrewManifest"
	program_icon = "clipboard-list"



/datum/computer_file/program/crew_manifest/ui_static_data(mob/user)
	var/list/data = list()
	data["manifest"] = GLOB.data_core.get_manifest()
	return data

/datum/computer_file/program/crew_manifest/ui_data(mob/user)
	var/list/data = list()

	var/obj/item/computer_hardware/printer/printer
	if(computer)
		printer = computer.all_components[MC_PRINT]

	if(computer)
		data["have_printer"] = !!printer
	else
		data["have_printer"] = FALSE
	return data

/datum/computer_file/program/crew_manifest/ui_act(action, params, datum/tgui/ui)
	if(..())
		return

	var/obj/item/computer_hardware/printer/printer
	if(computer)
		printer = computer.all_components[MC_PRINT]

	switch(action)
		if("PRG_print")
			if(computer && printer) //This option should never be called if there is no printer
				var/contents = {"<h4>Manifest załogi</h4><br>[GLOB.data_core ? GLOB.data_core.get_manifest_html(0) : ""]
								"}
				if(!printer.print_text(contents,text("manifest załogi ([])", station_time_timestamp())))
					to_chat(usr, "<span class='notice'>Błąd sprzętu: drukarka nie mogła wydrukować pliku. Może brakuje papieru.</span>")
					return
				else
					computer.visible_message("<span class='notice'>[computer] drukuje kartkę.</span>")
