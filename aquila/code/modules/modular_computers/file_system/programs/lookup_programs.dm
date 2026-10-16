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
	. = ..()
	.["recipeCatalog"] = get_recipe_catalog()

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
	. = ..()
	.["surgeries"] = get_surgery_catalog()

/datum/computer_file/program/slime_extracts
	filename = "ekstrakty"
	filedesc = "Ekstrakty"
	category = PROGRAM_CATEGORY_CREW
	program_icon_state = "generic"
	extended_desc = "Spis ekstraktów szlamów: czym je aktywować i co z tego wyjdzie."
	size = 2
	tgui_id = "NtosSlimeExtracts"
	program_icon = "vial"
	usage_flags = PROGRAM_ALL

/datum/computer_file/program/slime_extracts/ui_static_data(mob/user)
	. = ..()
	.["extracts"] = get_slime_extract_catalog()

/datum/computer_file/program/space_law
	filename = "prawo"
	filedesc = "Prawo kosmiczne"
	category = PROGRAM_CATEGORY_CREW
	program_icon_state = "generic"
	extended_desc = "Kodeks karny okrętu z wyszukiwarką i kalkulatorem wyroku."
	size = 2
	tgui_id = "NtosSpaceLaw"
	program_icon = "gavel"
	usage_flags = PROGRAM_ALL

/datum/computer_file/program/space_law/ui_static_data(mob/user)
	. = ..()
	.["categories"] = get_space_law_catalog()

// Dyski zawodowe: medyczne dostają „Operacje”, chemiczne „Receptury”, naukowe „Ekstrakty”, ochrony „Prawo kosmiczne”
/obj/item/computer_hardware/hard_drive/role/Initialize(mapload)
	. = ..()
	if(disk_flags & DISK_MED)
		store_lookup_program(new /datum/computer_file/program/surgery_lookup(src))
	if(disk_flags & DISK_CHEM)
		store_lookup_program(new /datum/computer_file/program/recipe_lookup(src))
	if(disk_flags & DISK_SIGNAL)
		store_lookup_program(new /datum/computer_file/program/slime_extracts(src))
	if(disk_flags & DISK_SEC)
		store_lookup_program(new /datum/computer_file/program/space_law(src))

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
