/datum/component/heirloom
	var/datum/mind/owner
	var/family_name

/datum/component/heirloom/Initialize(new_owner, new_family_name)
	if(!isitem(parent))
		return COMPONENT_INCOMPATIBLE

	owner = new_owner
	family_name = new_family_name

	RegisterSignal(parent, COMSIG_PARENT_EXAMINE, PROC_REF(examine))

/datum/component/heirloom/proc/examine(datum/source, mob/user, list/examine_list)
	SIGNAL_HANDLER

	if(user.mind == owner)
		examine_list += "<span class='notice'>To twoja cenna pamiątka rodzinna rodu [family_name]. Strzeż jej!</span>"
	else if(isobserver(user))
		examine_list += "<span class='notice'>To pamiątka rodzinna rodu [family_name], należąca do [owner].</span>"
	else
		var/datum/antagonist/obsessed/creeper = user.mind.has_antag_datum(/datum/antagonist/obsessed)
		if(creeper && creeper.trauma.obsession == owner)
			examine_list += "<span class='nicegreen'>To musi być pamiątka rodzinna [owner]! Pachnie zupełnie jak ten ktoś...</span>"
