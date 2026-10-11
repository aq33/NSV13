// AQUILA - port BeeStation/BeeStation-Hornet#11415

/// Każdy członek ERT dostaje mindshield (wcześniej tylko część strojów go dawała)
/datum/antagonist/ert/equipERT()
	. = ..()
	var/mob/living/carbon/human/H = owner.current
	if(!istype(H) || (locate(/obj/item/implant/mindshield) in H.implants))
		return
	var/obj/item/implant/mindshield/mindshield = new(H)
	mindshield.implant(H, null, TRUE)

/// Oficjel CentComu jest teraz zwykłym członkiem ERT (wcześniej osobny /datum/antagonist/official)
/datum/antagonist/ert/official
	name = JOB_CENTCOM_OFFICIAL
	show_name_in_check_antagonists = TRUE
	random_names = FALSE
	outfit = /datum/outfit/centcom_official
	plasmaman_outfit = /datum/outfit/plasmaman/official
	var/datum/objective/mission

/datum/antagonist/ert/official/greet()
	to_chat(owner, "<B><font size=3 color=red>You are a CentCom Official.</font></B>")
	var/datum/objective/task = ert_team ? ert_team.mission : mission
	if(task)
		to_chat(owner, "Centralne Dowództwo wysyła Cię do: [station_name()] z następującym zadaniem: [task.explanation_text]")

/datum/antagonist/ert/official/forge_objectives()
	if(ert_team)
		return ..()
	if(mission)
		return
	var/datum/objective/missionobj = new()
	missionobj.owner = owner
	missionobj.explanation_text = "Przeprowadź rutynowy przegląd [station_name()] i jego kapitana."
	missionobj.completed = TRUE
	mission = missionobj
	objectives |= mission

/datum/antagonist/ert/intern/leader
	random_names = FALSE

/datum/antagonist/ert/intern/unarmed
	outfit = /datum/outfit/centcom_intern/unarmed

/datum/antagonist/ert/intern/leader/unarmed
	outfit = /datum/outfit/centcom_intern/leader/unarmed

/datum/antagonist/ert/bounty_armor
	role = "Armored Bounty Hunter"
	outfit = /datum/outfit/bountyarmor/ert

/datum/antagonist/ert/bounty_hook
	role = "Hookgun Bounty Hunter"
	outfit = /datum/outfit/bountyhook/ert

/datum/antagonist/ert/bounty_synth
	role = "Synthetic Bounty Hunter"
	outfit = /datum/outfit/bountysynth/ert
