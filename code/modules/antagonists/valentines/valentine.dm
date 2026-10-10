/datum/antagonist/valentine
	name = "walentynka"
	roundend_category = "walentynki" //there's going to be a ton of them so put them in separate category
	show_in_antagpanel = FALSE
	prevent_roundtype_conversion = FALSE
	var/datum/mind/date
	count_against_dynamic_roll_chance = FALSE
	banning_key = UNBANNABLE_ANTAGONIST

/datum/antagonist/valentine/proc/forge_objectives()
	var/datum/objective/protect/protect_objective = new /datum/objective/protect
	protect_objective.owner = owner
	protect_objective.set_target(date)
	if(!ishuman(date.current))
		protect_objective.human_check = FALSE
	protect_objective.explanation_text = "Chroń [date.name], swoją randkę."
	objectives += protect_objective
	log_objective(owner, protect_objective.explanation_text)

/datum/antagonist/valentine/on_gain()
	forge_objectives()
	if(isliving(owner))
		var/mob/living/L = owner
		L.apply_status_effect(STATUS_EFFECT_INLOVE, date)
		//Faction assignation
		L.faction |= "[REF(date.current)]"
		L.faction |= date.current.faction
	if(issilicon(owner))
		var/mob/living/silicon/S = owner
		var/laws = list("Chroń swoją randkę i nie pozwól, by stała jej się krzywda.", "Dopilnuj, by twoja randka dobrze się bawiła.")
		S.set_valentines_laws(laws)
	. = ..()

/datum/antagonist/valentine/on_removal()
	. = ..()
	if(isliving(owner))
		var/mob/living/L = owner
		L.remove_status_effect(STATUS_EFFECT_INLOVE)
		L.faction -= "[REF(date.current)]"

/datum/antagonist/valentine/greet()
	to_chat(owner, "<span class='clown'><B>Masz randkę z [date.name]! Chroń tę osobę za wszelką cenę. To ważniejsze niż jakakolwiek inna lojalność.</B></span>")
	owner.current.client?.tgui_panel?.give_antagonist_popup("Masz randkę z [date.name]",
		"Chroń swoją randkę bez względu na koszty. Twoja lojalność nic nie znaczy wobec prawdziwej miłości - możesz zrobić wszystko, by jej pomóc i ją chronić!")

//Squashed up a bit
/datum/antagonist/valentine/roundend_report()
	var/objectives_complete = TRUE
	if(objectives.len)
		for(var/datum/objective/objective in objectives)
			if(!objective.check_completion())
				objectives_complete = FALSE
				break

	if(objectives_complete)
		return "<span class='greentext big'>[owner.name] [plec(owner.current, "ochronił", "ochroniła")] swoją randkę</span>"
	else
		return "<span class='redtext big'>Randka [owner.name] się nie udała!</span>"
