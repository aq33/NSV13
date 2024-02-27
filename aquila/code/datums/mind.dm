/datum/mind
	if(!uplink_exists && !(locate(/datum/action/special_equipment_fallback) in current.actions))
		var/datum/action/special_equipment_fallback/fallback = new(src)
		fallback.Grant(current)
	.=..()
