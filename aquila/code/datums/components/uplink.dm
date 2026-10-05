/datum/component/uplink/implanting(datum/source, list/arguments)
	. = ..()
	// Core takes the owner from the implanting user, which is null when the implant is put in directly (e.g. infiltrators) - fall back to the target
	if(!owner)
		var/mob/target = arguments[1]
		owner = target?.key
