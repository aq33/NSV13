// AQUILA - port of the Thief antagonist (tgstation#64144).

///very low level antagonist that has objectives to steal items and live, but is not allowed to kill.
/datum/antagonist/thief
	name = "Thief"
	roundend_category = "thieves"
	antagpanel_category = "Thief"
	banning_key = ROLE_THIEF
	show_in_antagpanel = TRUE
	ui_name = "AntagInfoThief"
	///assoc list of strings set up for the flavor of the thief.
	var/list/thief_flavor
	///if added by an admin, they can choose a thief flavor
	var/admin_choice_flavor

/datum/antagonist/thief/on_gain()
	owner.special_role = ROLE_THIEF
	flavor_and_objectives()
	. = ..() //greet() runs here, objectives must exist beforehand
	ui_interact(owner.current)

/datum/antagonist/thief/on_removal()
	//don't null it if we got a different one added on top, somehow.
	if(owner.special_role == ROLE_THIEF)
		owner.special_role = null
	return ..()

/datum/antagonist/thief/apply_innate_effects(mob/living/mob_override)
	var/mob/living/thief = mob_override || owner.current
	add_antag_hud(ANTAG_HUD_THIEF, "thief", thief)

/datum/antagonist/thief/remove_innate_effects(mob/living/mob_override)
	var/mob/living/thief = mob_override || owner.current
	remove_antag_hud(ANTAG_HUD_THIEF, thief)

/datum/antagonist/thief/admin_add(datum/mind/new_owner, mob/admin)
	load_strings_file(THIEF_FLAVOR_FILE)
	var/list/all_thief_flavors = GLOB.string_cache[THIEF_FLAVOR_FILE]
	var/list/all_thief_names = list("Random")
	for(var/flavorname in all_thief_flavors)
		all_thief_names += flavorname
	var/choice = tgui_input_list(admin, "Pick a thief flavor?", "Rogue's Guild", all_thief_names)
	if(choice && choice != "Random")
		admin_choice_flavor = choice
	return ..()

/datum/antagonist/thief/proc/flavor_and_objectives()
	//this list has a maximum pickweight of 100.
	//if you're adding a new type of thief, DON'T just add TOTAL pickweight. adjusting the others, numb nuts.
	var/static/list/weighted_flavors = list(
		"Thief" = 30,
		"Hoarder" = 30,
		"Black Market Outfitter" = 20,
		"Organ Market Collector" = 13,
		"Chronicler" = 5,
		"Deranged" = 2,
	)
	var/chosen_flavor = admin_choice_flavor || pickweight(weighted_flavors)
	//objective given by flavor
	var/chosen_objective
	//whether objective should call find_target()
	var/objective_needs_target
	switch(chosen_flavor)
		if("Thief")
			chosen_objective = /datum/objective/steal
			objective_needs_target = TRUE
		if("Hoarder")
			chosen_objective = /datum/objective/hoarder
			objective_needs_target = TRUE
		if("Black Market Outfitter")
			chosen_objective = /datum/objective/steal_five_of_type/summon_guns/thief
			objective_needs_target = FALSE
		if("Organ Market Collector")
			chosen_objective = /datum/objective/steal_five_of_type/organs
			objective_needs_target = FALSE
		if("Chronicler")
			chosen_objective = /datum/objective/chronicle
			objective_needs_target = FALSE
		if("Deranged")
			chosen_objective = /datum/objective/hoarder/bodies
			objective_needs_target = TRUE
	thief_flavor = strings(THIEF_FLAVOR_FILE, chosen_flavor)

	//whatever main objective this type of thief needs to accomplish
	var/datum/objective/flavor_objective = new chosen_objective
	flavor_objective.owner = owner
	if(objective_needs_target)
		flavor_objective.find_target(dupe_search_range = list(src))
	flavor_objective.update_explanation_text()
	objectives += flavor_objective
	log_objective(owner, flavor_objective.explanation_text)

	//all thieves need to escape with their loot (except hoarders, but you know.)
	var/datum/objective/escape/escape_objective = new
	escape_objective.owner = owner
	objectives += escape_objective
	log_objective(owner, escape_objective.explanation_text)

/datum/antagonist/thief/greet()
	to_chat(owner, "<span class='userdanger'>[thief_flavor["introduction"]]</span>")
	to_chat(owner, "<B>[thief_flavor["goal"]]</B>")
	to_chat(owner, "<span class='warning'><B>Pamiętaj: nie masz licencji na zabijanie, jak inni antagoniści.</B></span>")
	owner.announce_objectives()
	owner.current.client?.tgui_panel?.give_antagonist_popup(thief_flavor["introduction"], thief_flavor["goal"])

/datum/antagonist/thief/ui_static_data(mob/user)
	var/list/data = ..()
	data["goal"] = thief_flavor["goal"]
	data["intro"] = thief_flavor["introduction"]
	return data

/datum/antagonist/thief/roundend_report_header()
	return "<span class='header'>Złodziejami byli:</span><br>"
