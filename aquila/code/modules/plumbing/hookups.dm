// Machines from other modules that can be fed by plumbing, like on tg

/obj/machinery/hydroponics/Initialize(mapload)
	. = ..()
	if(!reagents)
		create_reagents(MACHINE_REAGENT_TRANSFER * 2, NO_REACT)
	AddComponent(/datum/component/plumbing/fixture/hydroponics)

/obj/machinery/limbgrower/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/plumbing/simple_demand)
