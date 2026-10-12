/// Bieżący cel samouczka w panelu Status
/datum/component/tutorial_status
	dupe_mode = COMPONENT_DUPE_UNIQUE
	/// Lekcja, w której jest mob
	var/datum/weakref/tutorial
	/// Tekst celu
	var/tutorial_status = ""

/datum/component/tutorial_status/Initialize(datum/tutorial/owner_tutorial)
	if(!ismob(parent))
		return COMPONENT_INCOMPATIBLE
	tutorial = WEAKREF(owner_tutorial)

/datum/component/tutorial_status/RegisterWithParent()
	RegisterSignal(parent, COMSIG_MOB_TUTORIAL_UPDATE_OBJECTIVE, PROC_REF(update_objective))

/datum/component/tutorial_status/UnregisterFromParent()
	UnregisterSignal(parent, COMSIG_MOB_TUTORIAL_UPDATE_OBJECTIVE)

/datum/component/tutorial_status/proc/update_objective(datum/source, objective_text)
	SIGNAL_HANDLER

	tutorial_status = objective_text

/mob/living/carbon/human/get_stat_tab_status()
	. = ..()
	var/datum/component/tutorial_status/status = GetComponent(/datum/component/tutorial_status)
	if(status?.tutorial_status)
		.["Cel samouczka"] = GENERATE_STAT_TEXT(status.tutorial_status)

/// Napis z poleceniem samouczka u góry ekranu, pod screentipami
/atom/movable/screen/tutorial_text
	icon = null
	icon_state = null
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	screen_loc = "TOP,CENTER"
	maptext_x = -224
	maptext_y = -120
	maptext_height = 96
	maptext_width = 480
	layer = SCREENTIP_LAYER
	plane = HUD_PLANE

/atom/movable/screen/tutorial_text/proc/set_text(message)
	maptext = message ? MAPTEXT("<span style='color:#7fd98f'>[CENTER("[message]")]</span>") : ""

/// Postać w samouczku nie jest żywym graczem rundy: dynamic nie liczy jej do populacji ani nie losuje na antagonistę
/mob/add_to_current_living_players()
	if(HAS_TRAIT(src, TRAIT_IN_TUTORIAL))
		return
	return ..()
