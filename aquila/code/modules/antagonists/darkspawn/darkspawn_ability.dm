// AQUILA - darkspawn: baza zdolności, ulepszeń i Sieć Psi

/datum/action/innate/darkspawn
	name = "darkspawn ability"
	desc = "To nie powinno istnieć."
	icon_icon = 'aquila/icons/mob/darkspawn/actions_darkspawn.dmi'
	background_icon_state = "bg_alien"
	buttontooltipstyle = "alien"
	/// ID zdolności do dawania i zabierania
	var/id
	/// Ile Psi kosztuje użycie
	var/psi_cost = 0
	/// Dopisek po koszcie w Sieci Psi
	var/psi_addendum = ""
	/// Ile lucidity kosztuje zakup; 0 = nie ma jej w katalogu
	var/lucidity_price = 0
	/// Nie da się jej kupić w Sieci Psi
	var/blacklisted = FALSE
	/// Dla zdolności z czasem rzucania
	var/in_use = FALSE
	var/datum/antagonist/darkspawn/darkspawn

/datum/action/innate/darkspawn/New(Target)
	..()
	START_PROCESSING(SSfastprocess, src)

/datum/action/innate/darkspawn/Destroy()
	STOP_PROCESSING(SSfastprocess, src)
	if(owner)
		Remove(owner)
	darkspawn = null
	return ..()

/datum/action/innate/darkspawn/process()
	UpdateButtonIcon() // koszt Psi i warunki się zmieniają, przycisk ma to pokazywać

/datum/action/innate/darkspawn/Trigger()
	if(!IsAvailable())
		if(owner && darkspawn && !darkspawn.has_psi(psi_cost))
			owner.balloon_alert(owner, "za mało Psi!")
		else if(owner && in_use)
			owner.balloon_alert(owner, "już w użyciu!")
		return FALSE
	if(SEND_SIGNAL(src, COMSIG_ACTION_TRIGGER, src) & COMPONENT_ACTION_BLOCK_TRIGGER)
		return FALSE
	var/activated
	if(!active)
		activated = Activate()
	else
		activated = Deactivate()
	if(darkspawn && activated)
		darkspawn.use_psi(psi_cost)
	return TRUE

/datum/action/innate/darkspawn/IsAvailable()
	if(!darkspawn)
		return FALSE
	if(!darkspawn.has_psi(psi_cost))
		return FALSE
	if(in_use)
		return FALSE
	return ..()

/datum/action/innate/darkspawn/proc/reset()
	in_use = FALSE

/// Pasywne ulepszenia. Działają od razu po zakupie i się usuwają.
/datum/darkspawn_upgrade
	var/name = "darkspawn upgrade"
	var/desc = "To jest ulepszenie."
	var/id
	/// Ile lucidity kosztuje zakup
	var/lucidity_price = 0
	var/datum/antagonist/darkspawn/darkspawn

/datum/darkspawn_upgrade/New(darkspawn_datum)
	..()
	darkspawn = darkspawn_datum

/datum/darkspawn_upgrade/proc/unlock()
	if(!darkspawn)
		return FALSE
	apply_effects()
	qdel(src)
	return TRUE

/datum/darkspawn_upgrade/proc/apply_effects()
	return

/datum/darkspawn_upgrade/Destroy()
	darkspawn = null
	return ..()

/// Sieć Psi: sklep, w którym darkspawn kupuje zdolności i ulepszenia za lucidity
/datum/psi_web
	var/datum/antagonist/darkspawn/darkspawn

/datum/psi_web/New(datum/antagonist/darkspawn/new_darkspawn)
	. = ..()
	darkspawn = new_darkspawn

/datum/psi_web/Destroy()
	darkspawn = null
	return ..()

/datum/psi_web/ui_state(mob/user)
	return GLOB.always_state

/datum/psi_web/ui_status(mob/user, datum/ui_state/state)
	if(!darkspawn || user != darkspawn.owner?.current)
		return UI_CLOSE
	return ..()

/datum/psi_web/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "PsiWeb", "Sieć Psi")
		ui.open()

/datum/psi_web/ui_data(mob/user)
	var/list/data = list()
	data["lucidity"] = darkspawn.lucidity
	data["lucidity_drained"] = darkspawn.lucidity_drained
	data["required_succs"] = darkspawn.team?.required_succs

	var/list/abilities = list()
	for(var/datum/action/innate/darkspawn/ability as anything in subtypesof(/datum/action/innate/darkspawn))
		if(initial(ability.blacklisted))
			continue
		var/owned = !!darkspawn.has_ability(initial(ability.id))
		abilities += list(list(
			"name" = initial(ability.name),
			"id" = initial(ability.id),
			"desc" = initial(ability.desc),
			"psi_cost" = "[initial(ability.psi_cost)][initial(ability.psi_addendum)]",
			"lucidity_cost" = initial(ability.lucidity_price),
			"owned" = owned,
			"can_purchase" = !owned && darkspawn.lucidity >= initial(ability.lucidity_price),
		))
	data["abilities"] = abilities

	var/list/upgrades = list()
	for(var/datum/darkspawn_upgrade/upgrade as anything in subtypesof(/datum/darkspawn_upgrade))
		var/owned = !!darkspawn.has_upgrade(initial(upgrade.id))
		upgrades += list(list(
			"name" = initial(upgrade.name),
			"id" = initial(upgrade.id),
			"desc" = initial(upgrade.desc),
			"lucidity_cost" = initial(upgrade.lucidity_price),
			"owned" = owned,
			"can_purchase" = !owned && darkspawn.lucidity >= initial(upgrade.lucidity_price),
		))
	data["upgrades"] = upgrades
	return data

/datum/psi_web/ui_act(action, params)
	if(..())
		return
	switch(action)
		if("unlock")
			return try_unlock(params["id"])
		if("upgrade")
			return try_upgrade(params["id"])

/// Kupuje zdolność z katalogu, jeśli stać na nią darkspawna
/datum/psi_web/proc/try_unlock(id)
	var/datum/action/innate/darkspawn/ability_type = ability_type_by_id(id)
	if(!ability_type || initial(ability_type.blacklisted) || darkspawn.lucidity < initial(ability_type.lucidity_price))
		return FALSE
	return darkspawn.add_ability(id)

/// Kupuje ulepszenie, jeśli stać na nie darkspawna
/datum/psi_web/proc/try_upgrade(id)
	var/datum/darkspawn_upgrade/upgrade_type = upgrade_type_by_id(id)
	if(!upgrade_type || darkspawn.lucidity < initial(upgrade_type.lucidity_price))
		return FALSE
	return darkspawn.add_upgrade(id)

/datum/psi_web/proc/ability_type_by_id(id)
	for(var/datum/action/innate/darkspawn/ability_type as anything in subtypesof(/datum/action/innate/darkspawn))
		if(initial(ability_type.id) == id)
			return ability_type

/datum/psi_web/proc/upgrade_type_by_id(id)
	for(var/datum/darkspawn_upgrade/upgrade_type as anything in subtypesof(/datum/darkspawn_upgrade))
		if(initial(upgrade_type.id) == id)
			return upgrade_type

/datum/action/innate/darkspawn/psi_web
	name = "Sieć Psi"
	id = "psi_web"
	desc = "Sięgnij wprost do Mindlinka, żeby odblokować i ulepszyć swoje nadprzyrodzone moce."
	button_icon_state = "psi_web"
	check_flags = AB_CHECK_CONSCIOUS
	blacklisted = TRUE

/datum/action/innate/darkspawn/psi_web/Activate()
	if(!darkspawn?.psi_web)
		return FALSE
	to_chat(owner, "<span class='velvet bold'>Zagłębiasz się w siebie i dotykasz Mindlinka...</span>")
	darkspawn.psi_web.ui_interact(owner)
	return FALSE // bez kosztu i bez przełączania stanu
