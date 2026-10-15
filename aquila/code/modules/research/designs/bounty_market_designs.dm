// AQUILA - płytki zleceń cywilnych i rynku materiałów

/datum/design/board/bountypad_control
	name = "Computer Design (Civilian Bounty Pad Control)"
	desc = "Płytka konsoli zleceń cywilnych."
	id = "bountypad_control"
	build_path = /obj/item/circuitboard/computer/bountypad
	category = list("Computer Boards")
	departmental_flags = DEPARTMENTAL_FLAG_CARGO

/datum/design/board/bountypad
	name = "Machine Design (Civilian Bounty Pad)"
	desc = "Płytka padu zleceń cywilnych."
	id = "bountypad"
	build_path = /obj/item/circuitboard/machine/bountypad
	category = list("Misc. Machinery")
	departmental_flags = DEPARTMENTAL_FLAG_CARGO

/datum/design/board/materials_market
	name = "Machine Design (Galactic Materials Market)"
	desc = "Płytka galaktycznego rynku materiałów."
	id = "materials_market"
	build_path = /obj/item/circuitboard/machine/materials_market
	category = list("Misc. Machinery")
	departmental_flags = DEPARTMENTAL_FLAG_CARGO

/datum/techweb_node/comptech/New() // dopisane, żeby zmiany upstreamu w tym węźle nadal działały
	. = ..()
	design_ids += list("bountypad_control", "bountypad", "materials_market")
