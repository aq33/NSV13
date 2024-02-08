/obj/item/circuitboard/machine/bluespace_miner
	name = "bluespace miner (Machine Board)"
	icon_state = "science"
	build_path = /obj/machinery/mineral/bluespace_miner
	req_components = list(
		/obj/item/stock_parts/capacitor/quadratic = 1,
		/obj/item/stock_parts/matter_bin = 3,
		/obj/item/stock_parts/micro_laser = 1,
		/obj/item/stock_parts/manipulator/femto = 3,
		/obj/item/stock_parts/scanning_module = 1,
		/obj/item/stack/ore/bluespace_crystal = 11)
	needs_anchored = FALSE

/obj/item/circuitboard/machine/autodoc
	name = "Autodoc (Machine Board)"
	build_path = /obj/machinery/autodoc
	req_components = list(/obj/item/scalpel/advanced = 1,
		/obj/item/retractor/advanced = 1,
		/obj/item/surgicaldrill/advanced = 1,
		/obj/item/stock_parts/manipulator = 1,
		/obj/item/stock_parts/micro_laser = 3,
		/obj/item/stock_parts/matter_bin = 1)
