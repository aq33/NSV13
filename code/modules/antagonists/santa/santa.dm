/datum/antagonist/santa
	name = "Mikołaj"
	show_in_antagpanel = FALSE
	show_name_in_check_antagonists = TRUE
	show_to_ghosts = TRUE
	banning_key = UNBANNABLE_ANTAGONIST

/datum/antagonist/santa/on_gain()
	. = ..()
	give_equipment()
	give_objective()

	ADD_TRAIT(owner, TRAIT_CANNOT_OPEN_PRESENTS, TRAIT_SANTA)
	ADD_TRAIT(owner, TRAIT_PRESENT_VISION, TRAIT_SANTA)

/datum/antagonist/santa/greet()
	. = ..()
	to_chat(owner, "<span class='boldannounce'>Jesteś Mikołajem! Twoim zadaniem jest przynieść radość ludziom na tej stacji. Masz magiczny worek, który tworzy prezenty, dopóki go masz! Możesz obejrzeć prezenty, żeby zajrzeć do środka i mieć pewność, że właściwy prezent trafi do właściwej osoby.</span>")

/datum/antagonist/santa/proc/give_equipment()
	var/mob/living/carbon/human/H = owner.current
	if(istype(H))
		H.equipOutfit(/datum/outfit/santa)
		H.dna.update_dna_identity()

	owner.AddSpell(new /obj/effect/proc_holder/spell/targeted/area_teleport/teleport/santa)

/datum/antagonist/santa/proc/give_objective()
	if(!give_objectives)
		return
	var/datum/objective/santa_objective = new()
	santa_objective.explanation_text = "Przynieś stacji radość i prezenty!"
	santa_objective.completed = TRUE //lets cut our santas some slack.
	santa_objective.owner = owner
	objectives |= santa_objective
	log_objective(owner, santa_objective.explanation_text)
