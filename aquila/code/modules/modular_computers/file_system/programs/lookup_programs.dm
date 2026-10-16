// AQUILA - programy PDA z wyszukiwarkami: „Receptury” (chemia i drinki) oraz „Operacje” (chirurgia)

/datum/computer_file/program/recipe_lookup
	filename = "receptury"
	filedesc = "Receptury"
	category = PROGRAM_CATEGORY_CREW
	program_icon_state = "generic"
	extended_desc = "Katalog receptur chemicznych i drinków z wyszukiwarką po produkcie albo składniku."
	size = 2
	tgui_id = "NtosRecipeLookup"
	program_icon = "flask"
	usage_flags = PROGRAM_ALL

/datum/computer_file/program/recipe_lookup/ui_static_data(mob/user)
	var/list/data = list()
	data["recipeCatalog"] = get_recipe_catalog()
	return data

/datum/computer_file/program/surgery_lookup
	filename = "operacje"
	filedesc = "Operacje"
	category = PROGRAM_CATEGORY_CREW
	program_icon_state = "generic"
	extended_desc = "Spis wszystkich operacji: do czego służą, jakie mają kroki i jakimi narzędziami je wykonać."
	size = 2
	tgui_id = "NtosSurgeryLookup"
	program_icon = "user-md"
	usage_flags = PROGRAM_ALL

/datum/computer_file/program/surgery_lookup/ui_static_data(mob/user)
	var/list/data = list()
	data["surgeries"] = get_surgery_catalog()
	return data

// Dyski zawodowe: medyczne dostają „Operacje”, chemiczne „Receptury”
/obj/item/computer_hardware/hard_drive/role/Initialize(mapload)
	. = ..()
	if(disk_flags & DISK_MED)
		store_lookup_program(new /datum/computer_file/program/surgery_lookup(src))
	if(disk_flags & DISK_CHEM)
		store_lookup_program(new /datum/computer_file/program/recipe_lookup(src))

/obj/item/computer_hardware/hard_drive/role/proc/store_lookup_program(datum/computer_file/program/program)
	program.usage_flags = PROGRAM_ALL
	program.required_access = list()
	program.transfer_access = list()
	store_file(program)

// Barman i kucharz nie mają dysku zawodowego, więc „Receptury” trafiają prosto na dysk PDA
/obj/item/modular_computer/tablet/pda/bartender/Initialize(mapload)
	. = ..()
	install_recipe_lookup()

/obj/item/modular_computer/tablet/pda/cook/Initialize(mapload)
	. = ..()
	install_recipe_lookup()

/obj/item/modular_computer/tablet/pda/proc/install_recipe_lookup()
	var/obj/item/computer_hardware/hard_drive/hdd = all_components[MC_HDD]
	hdd?.store_file(new /datum/computer_file/program/recipe_lookup(hdd))
