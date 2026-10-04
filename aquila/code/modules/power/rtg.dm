// Aquila RTGs can be wrenched loose and moved; an unanchored RTG drops off its powernet until it is bolted down again.
// The matching `if(anchored)` check in Initialize() is an AQ EDIT in code/modules/power/rtg.dm.
/obj/machinery/power/rtg
	can_be_unanchored = TRUE

/obj/machinery/power/rtg/process()
	if(anchored)
		connect_to_network()
	else
		disconnect_from_network()
	..()

/obj/machinery/power/rtg/wrench_act(mob/living/user, obj/item/I)
	default_unfasten_wrench(user, I)

	playsound(src, 'sound/items/deconstruct.ogg', 50, TRUE)
	return TRUE
