// Port BeeStation #9205: okna informacji dla poszczególnych antagonistów (okna z tgui/interfaces/AntagInfo*.tsx).
// Antagoniści bez własnego okna dostają AntagInfoGeneric (nazwa roli i cele).
// Jak w Bee, kto ma własne okno, nie dostaje już starego okienka porad HTML (tips.dm, show_tips("traitor")).

// ===== Traitor / malf AI =====
/datum/antagonist/traitor
	ui_name = "AntagInfoTraitor"

/datum/antagonist/traitor/on_gain()
	if(owner.current && isAI(owner.current))
		ui_name = "AntagInfoMalf"
	return ..()

/datum/antagonist/traitor/ui_static_data(mob/user)
	var/list/data = list()
	data["antag_name"] = name
	data["has_codewords"] = should_give_codewords
	if(should_give_codewords)
		data["phrases"] = jointext(GLOB.syndicate_code_phrase, ", ")
		data["responses"] = jointext(GLOB.syndicate_code_response, ", ")
	data["objectives"] = get_objectives()
	if(traitor_kind == TRAITOR_AI)
		data["intro"] = "Jesteś [owner.special_role]."
		data["allies"] = "Możesz współpracować z innymi agentami Syndykatu, jeśli rozpoznasz ich po słowach kodowych."
		data["goal"] = "Wykonaj swoje cele. Prawa SI nie są już dla ciebie przeszkodą."
		return data
	var/datum/component/uplink/uplink = owner?.find_syndicate_uplink()
	data["has_uplink"] = !!uplink
	if(uplink)
		data["code"] = islist(uplink.unlock_code) ? english_list(uplink.unlock_code) : uplink.unlock_code
		data["failsafe_code"] = islist(uplink.failsafe_code) ? english_list(uplink.failsafe_code) : uplink.failsafe_code
		data["uplink_unlock_info"] = uplink_unlock_info(uplink)
	return data

/// How to open the uplink, based on what it is hidden in
/datum/antagonist/traitor/proc/uplink_unlock_info(datum/component/uplink/uplink)
	var/obj/item/hidden_in = uplink.parent
	if(istype(hidden_in, /obj/item/radio))
		return "Uplink jest ukryty w: [hidden_in.name]. Powiedz [uplink.unlock_code] na kanale :d, aby go odblokować."
	if(istype(hidden_in, /obj/item/modular_computer/tablet))
		return "Uplink jest ukryty w: [hidden_in.name]. Wpisz kod \"[uplink.unlock_code]\" jako dzwonek, aby go odblokować."
	if(istype(hidden_in, /obj/item/pen))
		return "Uplink jest ukryty w: [hidden_in.name]. Przekręć skuwkę o [english_list(uplink.unlock_code)] od pozycji startowej, aby go odblokować."
	if(istype(hidden_in, /obj/item/implant))
		return "Masz wszczepiony implant uplinku. Aktywuj go, aby z niego skorzystać."
	return "Uplink jest ukryty w: [hidden_in.name]."

// ===== Changeling =====
/datum/antagonist/changeling
	tips = null
	ui_name = "AntagInfoChangeling"

/datum/antagonist/changeling/ui_data(mob/user)
	var/list/data = list()
	data["true_name"] = changelingID
	data["objectives"] = get_objectives()
	return data

// ===== Blood brothers =====
/datum/antagonist/brother
	ui_name = "AntagInfoBrother"

/datum/antagonist/brother/ui_static_data(mob/user)
	var/list/data = ..()
	data["brothers"] = get_brother_names()
	return data

// ===== Nuclear operatives =====
/datum/antagonist/nukeop
	tips = null
	ui_name = "AntagInfoNukeOp"

/datum/antagonist/nukeop/ui_static_data(mob/user)
	. = ..()
	.["leader"] = FALSE
	.["lone"] = FALSE
	.["nuke_code"] = nuke_team?.memorized_code || "???"

/datum/antagonist/nukeop/leader/ui_static_data(mob/user)
	. = ..()
	.["leader"] = TRUE

/datum/antagonist/nukeop/lone/ui_static_data(mob/user)
	. = ..()
	.["lone"] = TRUE

// ===== Blob =====
/datum/antagonist/blob
	tips = null
	ui_name = "AntagInfoBlob"

/datum/antagonist/blob/ui_data(mob/user)
	var/list/data = list()
	data["objectives"] = get_objectives()
	if(!isovermind(user))
		return data
	var/mob/camera/blob/blob = user
	var/datum/blobstrain/blobstrain = blob.blobstrain
	if(!blobstrain)
		return data
	data["color"] = blobstrain.color
	data["description"] = blobstrain.description
	data["effects"] = blobstrain.effectdesc
	data["name"] = blobstrain.name
	return data

// ===== Abductors =====
/datum/antagonist/abductor
	tips = null

/datum/antagonist/abductor/agent
	ui_name = "AntagInfoAbductorAgent"

/datum/antagonist/abductor/scientist
	ui_name = "AntagInfoAbductorScientist"

/datum/antagonist/abductor/ui_static_data(mob/user)
	. = ..()
	.["mothership"] = team?.name

// ===== Only the window, generic data =====
/datum/antagonist/wizard
	tips = null
	ui_name = "AntagInfoWizard"

/datum/antagonist/cult
	tips = null
	ui_name = "AntagInfoBloodCult"

/datum/antagonist/brainwashed
	ui_name = "AntagInfoBrainwashed"

/datum/antagonist/morph
	ui_name = "AntagInfoMorph"

/datum/antagonist/nightmare
	ui_name = "AntagInfoNightmare"
