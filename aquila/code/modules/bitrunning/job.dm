/datum/job/bitrunner
	title = JOB_NAME_BITRUNNER
	flag = BITRUNNER
	department_head = list(JOB_NAME_QUARTERMASTER)
	department_flag = CIVILIAN
	faction = "Station"
	total_positions = 3
	spawn_positions = 3
	supervisors = JOB_NAME_QUARTERMASTER
	selection_color = "#dcba97"

	outfit = /datum/outfit/job/bitrunner

	access = list(ACCESS_BIT_DEN, ACCESS_CARGO, ACCESS_MAINT_TUNNELS, ACCESS_MECH_MINING, ACCESS_MINERAL_STOREROOM, ACCESS_MAILSORTING, ACCESS_MINING, ACCESS_MINING_STATION)
	minimal_access = list(ACCESS_BIT_DEN, ACCESS_CARGO, ACCESS_MAINT_TUNNELS, ACCESS_MECH_MINING, ACCESS_MINERAL_STOREROOM)
	paycheck = PAYCHECK_EASY
	paycheck_department = ACCOUNT_CAR

	display_order = JOB_DISPLAY_ORDER_BITRUNNER
	departments = DEPARTMENT_BITFLAG_CARGO
	rpg_title = "Pustelnik"

	species_outfits = list(
		SPECIES_PLASMAMAN = /datum/outfit/plasmaman/bitrunner
	)
	biohazard = 10

/datum/outfit/job/bitrunner
	name = JOB_NAME_BITRUNNER
	jobtype = /datum/job/bitrunner

	id = /obj/item/card/id/job/bitrunner
	uniform = /obj/item/clothing/under/rank/cargo/bitrunner
	belt = /obj/item/modular_computer/tablet/pda/bitrunner
	ears = /obj/item/radio/headset/headset_cargo
	shoes = /obj/item/clothing/shoes/sneakers/black

/datum/outfit/plasmaman/bitrunner
	name = "Bitrunner Plasmaman"

	uniform = /obj/item/clothing/under/plasmaman/bitrunner
	head = /obj/item/clothing/head/helmet/space/plasmaman/bitrunner

/obj/item/modular_computer/tablet/pda/bitrunner
	name = "bitrunner PDA"
	default_disk = /obj/item/computer_hardware/hard_drive/role/cargo_technician
	icon_state = "pda-cargo"

/// Strój zastępczy awatarów, gdy domena nic nie wymusza, a ktoś grzebał w netpodzie
/datum/outfit/bit_avatar
	name = "Bit Avatar"
	uniform = /obj/item/clothing/under/rank/cargo/bitrunner
	shoes = /obj/item/clothing/shoes/sneakers/black
	id = /obj/item/card/id

/obj/item/clothing/under/rank/cargo/bitrunner
	name = "kombinezon bitrunnera"
	desc = "Skórzany kombinezon bitrunnera. Tandetny, ale wygodny, gdy się długo siedzi."
	icon = 'aquila/icons/obj/clothing/bitrunning.dmi'
	worn_icon = 'aquila/icons/mob/clothing/bitrunning.dmi'
	icon_state = "bitrunner"
	item_state = "w_suit"
	can_adjust = FALSE

/obj/item/clothing/under/plasmaman/bitrunner
	name = "kombinezon ochronny bitrunnera"
	desc = "Kombinezon ochronny dla plazmaludzi ze złą postawą."
	icon = 'aquila/icons/obj/clothing/bitrunning.dmi'
	worn_icon = 'aquila/icons/mob/clothing/bitrunning.dmi'
	icon_state = "bitrunner_envirosuit"
	item_state = "bitrunner_envirosuit"

/obj/item/clothing/head/helmet/space/plasmaman/bitrunner
	name = "hełm ochronny bitrunnera"
	desc = "Hełm ochronny z dodatkowymi filtrami niebieskiego światła dla grających plazmaludzi."
	greyscale_colors = "#3A3A3A#6BC906#3A3A3A"

/obj/item/clothing/glasses/sunglasses/oval
	name = "owalne okulary przeciwsłoneczne"
	desc = "Klasyczne okulary owijające. Trochę chronią."
	icon = 'aquila/icons/obj/clothing/bitrunning.dmi'
	worn_icon = 'aquila/icons/mob/clothing/bitrunning.dmi'
	icon_state = "jensenshades"
	item_state = "jensenshades"

/obj/item/clothing/suit/jacket/leather_trenchcoat
	name = "skórzany trencz"
	desc = "Długi, czarny trencz. Czujesz się w nim Wybrańcem, choć nim nie jesteś."
	icon = 'aquila/icons/obj/clothing/bitrunning.dmi'
	worn_icon = 'aquila/icons/mob/clothing/bitrunning.dmi'
	icon_state = "leather_trenchcoat"
	item_state = "leather_trenchcoat"
	flags_inv = HIDEBELT

/obj/item/toy/figure/bitrunner
	name = "figurka bitrunnera"
	icon = 'aquila/icons/obj/bitrunning_items.dmi'
	icon_state = "bitrunner"
	toysay = "Jestem w środku..."

/obj/effect/mob_spawn/human/corpse/bitrunner
	name = JOB_NAME_BITRUNNER
	outfit = /datum/outfit/job/bitrunner
	icon_state = "corpsecargotech"


/obj/item/circuitboard/machine/quantum_server
	name = "Quantum Server (Machine Board)"
	icon_state = "supply"
	build_path = /obj/machinery/quantum_server
	req_components = list(
		/obj/item/stock_parts/manipulator = 2,
		/obj/item/stock_parts/scanning_module = 1,
		/obj/item/stock_parts/capacitor = 1,
	)

/obj/item/circuitboard/machine/netpod
	name = "Netpod (Machine Board)"
	icon_state = "supply"
	build_path = /obj/machinery/netpod
	req_components = list(
		/obj/item/stock_parts/manipulator = 1,
		/obj/item/stock_parts/matter_bin = 2,
	)

/obj/item/circuitboard/computer/quantum_console
	name = "Quantum Console (Computer Board)"
	icon_state = "supply"
	build_path = /obj/machinery/computer/quantum_console

/obj/item/circuitboard/machine/byteforge
	name = "Byteforge (Machine Board)"
	icon_state = "supply"
	build_path = /obj/machinery/byteforge
	req_components = list(
		/obj/item/stock_parts/micro_laser = 1,
	)

/obj/item/circuitboard/computer/order_console/bitrunning
	name = "Bitrunning Vendor Console (Computer Board)"
	icon_state = "supply"
	build_path = /obj/machinery/computer/order_console/bitrunning

/datum/design/board/quantum_console
	name = "Computer Design (Quantum Console)"
	desc = "Płytka konsoli kwantowej, którą bitrunnerzy sterują serwerem kwantowym."
	id = "quantum_console"
	build_path = /obj/item/circuitboard/computer/quantum_console
	category = list("Computer Boards")
	departmental_flags = DEPARTMENTAL_FLAG_CARGO | DEPARTMENTAL_FLAG_ENGINEERING

/datum/design/board/netpod
	name = "Machine Design (Netpod)"
	desc = "Płytka netpoda, w którym bitrunnerzy łączą się z domenami wirtualnymi."
	id = "netpod"
	build_path = /obj/item/circuitboard/machine/netpod
	category = list("Misc. Machinery")
	departmental_flags = DEPARTMENTAL_FLAG_CARGO | DEPARTMENTAL_FLAG_ENGINEERING

/datum/design/board/byteforge
	name = "Machine Design (Byteforge)"
	desc = "Płytka byteforge'a, który materializuje nagrody bitrunnerów."
	id = "byteforge"
	build_path = /obj/item/circuitboard/machine/byteforge
	category = list("Misc. Machinery")
	departmental_flags = DEPARTMENTAL_FLAG_CARGO | DEPARTMENTAL_FLAG_ENGINEERING

/datum/design/board/quantum_server
	name = "Machine Design (Quantum Server)"
	desc = "Płytka serwera kwantowego, który tworzy domeny wirtualne."
	id = "quantum_server"
	build_path = /obj/item/circuitboard/machine/quantum_server
	category = list("Misc. Machinery")
	departmental_flags = DEPARTMENTAL_FLAG_CARGO | DEPARTMENTAL_FLAG_ENGINEERING

/datum/design/board/bitrunning_vendor
	name = "Computer Design (Bitrunning Vendor)"
	desc = "Płytka konsoli NexaCache, sklepu bitrunnerów."
	id = "bitrunning_vendor"
	build_path = /obj/item/circuitboard/computer/order_console/bitrunning
	category = list("Computer Boards")
	departmental_flags = DEPARTMENTAL_FLAG_CARGO | DEPARTMENTAL_FLAG_ENGINEERING

/datum/techweb_node/bitrunning
	id = "bitrunning"
	display_name = "Technologia bitrunningu"
	description = "Technologia bluespace pozwoliła zbudować komputery kwantowe, które materializują struktury atomowe i wykonują zaawansowane programy."
	prereq_ids = list("comptech", "bluespace_basic")
	design_ids = list("byteforge", "quantum_console", "netpod", "quantum_server", "bitrunning_vendor")
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 2500)
	export_price = 5000

/datum/preference/name/custom/hacker_alias
	db_key = "hacker_alias"
	custom_name_id = "hacker_alias"
	relevant_job = /datum/job/shaft_miner

/// Bitrunner nie jest osobną rolą: bitrunningiem zajmują się górnicy (dostęp do pracowni i strój w szafce górnika).
/// Datum zostaje, bo netpod ubiera awatary w strój bitrunnera, a ID i HUD-y nadal znają tę nazwę.
/datum/job/bitrunner/map_check()
	return FALSE

/obj/structure/closet/secure_closet/miner/PopulateContents()
	..()
	new /obj/item/clothing/under/rank/cargo/bitrunner(src)
