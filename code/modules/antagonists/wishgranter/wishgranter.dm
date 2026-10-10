/datum/antagonist/wishgranter
	name = "Awatar Spełniacza Życzeń"
	show_in_antagpanel = FALSE
	show_name_in_check_antagonists = TRUE
	can_elimination_hijack = ELIMINATION_ENABLED
	banning_key = BAN_ROLE_ALL_ANTAGONISTS

/datum/antagonist/wishgranter/proc/forge_objectives()
	var/datum/objective/elimination/highlander/elimination_objective = new
	elimination_objective.owner = owner
	objectives += elimination_objective
	log_objective(owner, elimination_objective.explanation_text)

/datum/antagonist/wishgranter/on_gain()
	owner.special_role = "Avatar of the Wish Granter"
	forge_objectives()
	. = ..()
	give_powers()

/datum/antagonist/wishgranter/greet()
	to_chat(owner, "<B>Twoje zahamowania znikają, więzy lojalności pękają - możesz mordować, kogo chcesz!</B>")
	owner.announce_objectives()
	owner.current.client?.tgui_panel?.give_antagonist_popup("Awatar Spełniacza Życzeń",
		"Twoje zahamowania znikają, więzy lojalności pękają - możesz mordować, kogo chcesz!")

/datum/antagonist/wishgranter/proc/give_powers()
	var/mob/living/carbon/C = owner.current
	if(!C.has_dna())
		return
	C.dna.add_mutation(HULK)
	C.dna.add_mutation(XRAY)
	C.dna.add_mutation(SPACEMUT)
	C.dna.add_mutation(TK)
