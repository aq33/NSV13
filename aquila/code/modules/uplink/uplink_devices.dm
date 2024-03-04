/obj/item/uplink/nuclear/infiltrator
	uplink_flag = UPLINK_INFILTRATORS

/obj/item/uplink/nuclear/infiltrator/debug/Initialize(mapload, owner, tc_amount = 9001)
	. = ..()
	var/datum/component/uplink/hidden_uplink = GetComponent(/datum/component/uplink)
	hidden_uplink.allow_restricted = FALSE
