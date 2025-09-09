
/datum/action/innate/tutorialmenu
	name = "Tutorial"
	desc= "Naciśnij by przywołać krótki samouczek."
	button_icon_state = "tut"
	icon_icon = 'aquila/icons/mob/actions/actions_spells.dmi'
	background_icon_state = "bg_demon"
	var/datum/outfit/job/tutorialman

/datum/action/innate/tutorialmenu/New(datum/H)
	. = ..()
	button.name = name
	tutorialman = H

/datum/action/innate/tutorialmenu/Activate()
	to_chat(owner, "<span class='notice'>Tutorial nastąpi w przyszłości</span>")
	tutorialman.ui_interact(owner)

/datum/action/innate/tutorialmenu/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "Tutorial")
		ui.open()

/datum/action/innate/tutorialmenu/ui_state(mob/user)
	return GLOB.always_state

/datum/action/innate/tutorialmenu/ui_data(mob/user)
