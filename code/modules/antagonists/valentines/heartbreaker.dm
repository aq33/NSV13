/datum/antagonist/heartbreaker
	name = "łamacz serc"
	roundend_category = "walentynki"
	show_in_antagpanel = FALSE
	show_name_in_check_antagonists = TRUE
	banning_key = BAN_ROLE_ALL_ANTAGONISTS


/datum/antagonist/heartbreaker/proc/forge_objectives()
	var/datum/objective/martyr/normiesgetout = new
	normiesgetout.owner = owner
	objectives += normiesgetout
	log_objective(owner, normiesgetout.explanation_text)

/datum/antagonist/heartbreaker/on_gain()
	forge_objectives()
	if(issilicon(owner))
		var/mob/living/silicon/S = owner
		var/laws = list("Wykonaj swoje cele, psując wszystkim randki!")
		S.set_valentines_laws(laws)
	. = ..()

/datum/antagonist/heartbreaker/greet()
	to_chat(owner, "<span class='warning'><B>Nie masz randki! Wszyscy bawią się bez ciebie! Ale jeszcze im pokażesz...</B></span>")
	owner.announce_objectives()
