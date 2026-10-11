// Port BeeStation #9205: okno informacji o roli antagonisty i przycisk, który je otwiera.
// Haki w core: antag_datum.dm (on_gain, on_body_transfer, on_removal).

/// Makes the action button that opens the info window, if this antag has one
/datum/antagonist/proc/make_info_button()
	if(!ui_name || !owner?.current)
		return
	var/datum/action/antag_info/info_button = new(src)
	info_button.Grant(owner.current)
	info_button_ref = WEAKREF(info_button)
	return info_button

/datum/antagonist/ui_assets(mob/user)
	return list(
		get_asset_datum(/datum/asset/simple/bee_antags),
		get_asset_datum(/datum/asset/simple/aquila_antag_info),
	)

/// Pictures used by the BeeStation antag info windows that bee_antags does not have
/datum/asset/simple/aquila_antag_info
	assets = list(
		"apistol.png" = 'aquila/html/img/apistol.png',
		"atool.png" = 'aquila/html/img/atool.png',
		"cult-altar.gif" = 'aquila/html/img/cult-altar.gif',
		"cult-archives.gif" = 'aquila/html/img/cult-archives.gif',
		"cult-carve.png" = 'aquila/html/img/cult-carve.png',
		"cult-comms.png" = 'aquila/html/img/cult-comms.png',
		"cult-forge.gif" = 'aquila/html/img/cult-forge.gif',
		"cult-pylon.gif" = 'aquila/html/img/cult-pylon.gif',
	)

/// Button for antags to review their role description and objectives
/datum/action/antag_info
	name = "Informacje o roli"
	button_icon_state = "round_end"

/datum/action/antag_info/New(Target)
	. = ..()
	name = "Informacje o roli: [target]"

/datum/action/antag_info/Trigger()
	. = ..()
	if(!.)
		return
	target.ui_interact(owner)

/datum/action/antag_info/IsAvailable()
	if(!target)
		stack_trace("[type] was used without a target antag datum!")
		return FALSE
	. = ..()
	if(!.)
		return
	if(!owner.mind || !(target in owner.mind.antag_datums))
		return FALSE
	return TRUE
