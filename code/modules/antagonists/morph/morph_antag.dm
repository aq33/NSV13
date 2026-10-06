/datum/antagonist/morph
	name = "Morph"
	show_name_in_check_antagonists = TRUE
	show_in_antagpanel = FALSE
	banning_key = ROLE_MORPH

/datum/antagonist/morph/on_gain()
	forge_objectives()
	. = ..()

/datum/antagonist/morph/greet()
	owner.announce_objectives()

/datum/antagonist/morph/proc/forge_objectives()
	var/eat_things = TRUE
	var/eat_corpses = TRUE
	if(!prob(33)) // 33% to get both objectives, otherwise one or the other
		if(prob(50))
			eat_corpses = FALSE
		else
			eat_things = FALSE

	if(eat_things)
		var/datum/objective/morph_eat_things/eat = new
		eat.owner = owner
		eat.update_explanation_text()
		objectives += eat // Consume x objects
	if(eat_corpses)
		var/datum/objective/morph_eat_corpses/eatcorpses = new
		eatcorpses.owner = owner
		eatcorpses.update_explanation_text()
		objectives += eatcorpses // Consume x corpses

	var/datum/objective/survive/survival = new
	survival.owner = owner
	objectives += survival // Don't die, idiot

/datum/antagonist/morph/roundend_report()
	var/list/report = list()
	report += printplayer(owner)
	if(istype(owner.current, /mob/living/simple_animal/hostile/morph))
		var/mob/living/simple_animal/hostile/morph/M = owner.current
		report += "Things eaten: [M.eat_count]"
		report += "Corpses eaten: [M.corpse_eat_count]"

	var/objectives_complete = TRUE
	if(objectives.len)
		report += printobjectives(objectives)
		for(var/datum/objective/objective in objectives)
			if(!objective.check_completion())
				objectives_complete = FALSE
				break

	if(objectives.len == 0 || objectives_complete)
		report += "<span class='greentext big'>The [name] was successful!</span>"
	else
		report += "<span class='redtext big'>The [name] has failed!</span>"

	return report.Join("<br>")

// Consume x objects
/datum/objective/morph_eat_things
	name = "morph eat objective"
	explanation_text = "Eat things."
	var/target_things

/datum/objective/morph_eat_things/update_explanation_text()
	..()
	if(!target_things)
		target_things = rand(20, 60)
	explanation_text = "Eat at least [target_things] things."

/datum/objective/morph_eat_things/check_completion()
	if(..())
		return TRUE
	if(istype(owner.current, /mob/living/simple_animal/hostile/morph))
		var/mob/living/simple_animal/hostile/morph/M = owner.current
		return M.eat_count >= target_things
	return FALSE

// Consume x corpses
/datum/objective/morph_eat_corpses
	name = "morph eat corpses objective"
	explanation_text = "Eat corpses."
	var/target_corpses

/datum/objective/morph_eat_corpses/update_explanation_text()
	..()
	if(!target_corpses)
		target_corpses = rand(2, 6)
	explanation_text = "Eat at least [target_corpses] corpses."

/datum/objective/morph_eat_corpses/check_completion()
	if(..())
		return TRUE
	if(istype(owner.current, /mob/living/simple_animal/hostile/morph))
		var/mob/living/simple_animal/hostile/morph/M = owner.current
		return M.corpse_eat_count >= target_corpses
	return FALSE
