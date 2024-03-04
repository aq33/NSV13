/datum/component/uplink/implanting(datum/source, list/arguments)
	var/mob/target = arguments[1]
	var/mob/user = arguments[2] // YOGS START -- Fix runtime when implanting infiltrators
	owner = "[user ? user.key : target.key]" // YOGS END
	.=..()
