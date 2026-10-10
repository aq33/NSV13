/datum/antagonist/survivalist
	name = "Survivalowiec"
	show_in_antagpanel = FALSE
	show_name_in_check_antagonists = TRUE
	banning_key = ROLE_SURVIVALIST
	var/greet_message = ""

/datum/antagonist/survivalist/proc/forge_objectives()
	if(!give_objectives)
		return
	var/datum/objective/survive/survive = new
	survive.owner = owner
	objectives += survive
	log_objective(owner, survive.explanation_text)

/datum/antagonist/survivalist/on_gain()
	owner.special_role = "survivalist"
	forge_objectives()
	. = ..()

/datum/antagonist/survivalist/greet()
	to_chat(owner, "<B>Jesteś survivalowcem! [greet_message]</B>")
	owner.announce_objectives()

/datum/antagonist/survivalist/apply_innate_effects(mob/living/mob_override)
	. = ..()
	var/datum/atom_hud/antag/survivalisthud = GLOB.huds[ANTAG_HUD_SURVIVALIST]
	survivalisthud.join_hud(owner.current)
	if(!owner.antag_hud_icon_state)	//Don't override traitor huds etc, they are more important.
		set_antag_hud(owner.current, "survivalist")

/datum/antagonist/survivalist/remove_innate_effects(mob/living/mob_override)
	. = ..()
	var/datum/atom_hud/antag/survivalisthud = GLOB.huds[ANTAG_HUD_SURVIVALIST]
	survivalisthud.leave_hud(owner.current)
	if(owner.antag_hud_icon_state == "survivalist")
		set_antag_hud(owner.current, null)

/datum/antagonist/survivalist/guns
	greet_message = "Twoje bezpieczeństwo jest najważniejsze, a jedynym sposobem, by je zapewnić, jest gromadzenie broni! Zgarnij jak najwięcej spluw, wszelkimi sposobami. Zabij każdego, kto stanie ci na drodze."

/datum/antagonist/survivalist/guns/forge_objectives()
	var/datum/objective/steal_five_of_type/summon_guns/guns = new
	guns.owner = owner
	objectives += guns
	log_objective(owner, guns.explanation_text)
	..()

/datum/antagonist/survivalist/magic
	name = "Magik amator"
	greet_message = "Rozwijaj swój nowo odkryty talent! Zgarnij jak najwięcej magicznych artefaktów, wszelkimi sposobami. Zabij każdego, kto stanie ci na drodze."

/datum/antagonist/survivalist/magic/greet()
	..()
	to_chat(owner, "<span class='notice'>Jako wspaniały magik pamiętaj, że zużyte księgi zaklęć nic nie znaczą.</span>")

/datum/antagonist/survivalist/magic/forge_objectives()
	var/datum/objective/steal_five_of_type/summon_magic/magic = new
	magic.owner = owner
	objectives += magic
	log_objective(owner, magic.explanation_text)
	..()
