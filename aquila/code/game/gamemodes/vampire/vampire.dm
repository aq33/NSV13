/datum/game_mode
	var/list/datum/mind/vampires = list()

/mob/living/carbon/human/Stat()
	. = ..()
	var/datum/antagonist/vampire/vamp = mind.has_antag_datum(/datum/antagonist/vampire)
	if(vamp && statpanel("Status"))
		stat("Total Blood", vamp.total_blood)
		stat("Usable Blood", vamp.usable_blood)

/mob/living/carbon/human/Life()
	. = ..()
	if(is_vampire(src))
		var/datum/antagonist/vampire/vamp = mind.has_antag_datum(/datum/antagonist/vampire)
		vamp.vampire_life()


/datum/game_mode/vampire
	name = "vampire"
	config_tag = "vampire"
	antag_datum = /datum/antagonist/vampire
	role_preference = /datum/role_preference/antagonist/vampire
	false_report_weight = 1
	restricted_jobs = list("AI", "Cyborg")
	protected_jobs = list("Head of Security", "Captain", "Security Officer", "Chaplain", "Detective", "Warden", "Head of Personnel")
	required_players = 15
	required_enemies = 1
	recommended_enemies = 3

	announce_text = "There are vampires onboard the station!\n\
		+	<span class='danger'>Vampires</span>: Suck the blood of the crew and complete your objectives!\n\
		+	<span class='notice'>Crew</span>: Kill the unholy vampires!"

	var/vampires_possible = 4 //hard limit on vampires if scaling is turned off
	var/num_modifier = 0
	var/list/datum/mind/pre_vamps = list()

/datum/game_mode/vampire/pre_setup()

	if(CONFIG_GET(flag/protect_roles_from_antagonist))
		restricted_jobs += protected_jobs

	if(CONFIG_GET(flag/protect_assistant_from_antagonist))
		restricted_jobs += "Assistant"

	var/num_vamps = 1

	var/tsc = CONFIG_GET(number/traitor_scaling_coeff)
	if(tsc)
		num_vamps = max(1, min(round(num_players() / (tsc * 2)) + 2 + num_modifier, round(num_players() / tsc) + num_modifier))
	else
		num_vamps = max(1, min(num_players(), vampires_possible))

	for(var/j = 0, j < num_vamps, j++)
		if (!antag_candidates.len)
			break
		var/datum/mind/vamp = pick(antag_candidates)
		pre_vamps += vamp
		vamp.special_role = "Vampire"
		vamp.restricted_roles = restricted_jobs
		log_game("[vamp.key] (ckey) has been selected as a Vampire")
		antag_candidates.Remove(vamp)

	return pre_vamps.len > 0


/datum/game_mode/vampire/post_setup()
	for(var/datum/mind/vamp in pre_vamps)
		vamp.add_antag_datum(/datum/antagonist/vampire)
	..()
	return TRUE

/datum/game_mode/proc/auto_declare_completion_vampire()
	if(vampires.len)
		var/text = "<br><font size=3><b>The vampires were:</b></font>"
		for(var/datum/mind/vamp in vampires)
			var/vampwin = 1
			if(!vamp.current)
				vampwin = 0

			var/datum/antagonist/vampire/V = vamp.has_antag_datum(/datum/antagonist/vampire)

			if(!V)
				continue

			text += printplayer(vamp)

			//Removed sanity if(vampire) because we -want- a runtime to inform us that the vampire list is incorrect and needs to be fixed.
			text += "<br><b>Usable Blood:</b> [V.usable_blood]."
			text += "<br><b>Total Blood:</b> [V.total_blood]"

			if(V.objectives.len)
				var/count = 1
				for(var/datum/objective/objective in V.objectives)
					if(objective.check_completion())
						text += "<br><b>Objective #[count]</b>: [objective.explanation_text] <font color='green'><b>Success!</b></font>"
						SSblackbox.record_feedback("tally", "vampire_objective", 1, "[objective.type]|SUCCESS")
					else
						text += "<br><b>Objective #[count]</b>: [objective.explanation_text] <span class='danger'>Fail.</span>"
						SSblackbox.record_feedback("tally", "vampire_objective", 1, "[objective.type]|FAIL")
						vampwin = 0
					count++

			if(vampwin)
				text += "<br><font color='green'><b>The vampire was successful!</b></font>"
				SSblackbox.record_feedback("tally", "vampire_success", 1, "SUCCESS")
			else
				text += "<br><span class='boldannounce'>The vampire has failed.</span>"
				SSblackbox.record_feedback("tally", "vampire_success", 1, "FAIL")
			text += "<br>"

		to_chat(world, text)


	return 1


/proc/add_vampire(mob/living/L, full_vampire = TRUE)
    if(!L || !L.mind || is_vampire(L))
        return FALSE
    var/datum/antagonist/vampire/vamp
    if(full_vampire == TRUE)
        vamp = L.mind.add_antag_datum(/datum/antagonist/vampire)
    else
        vamp = L.mind.add_antag_datum(/datum/antagonist/vampire/new_blood)
    return vamp

/proc/remove_vampire(mob/living/L)
	if(!L || !L.mind || !is_vampire(L))
		return FALSE
	var/datum/antagonist/vamp = L.mind.has_antag_datum(/datum/antagonist/vampire)
	vamp.on_removal()
	return TRUE

/proc/is_vampire(mob/living/M)
	return M && M.mind && M.mind.has_antag_datum(/datum/antagonist/vampire)

/datum/game_mode/proc/update_vampire_icons_added(datum/mind/traitor_mind)
	var/datum/atom_hud/antag/vamphud = GLOB.huds[ANTAG_HUD_VAMPIRE]
	vamphud.join_hud(traitor_mind.current)
	set_antag_hud(traitor_mind.current, "vampire")

/datum/game_mode/proc/update_vampire_icons_removed(datum/mind/traitor_mind)
	var/datum/atom_hud/antag/vamphud = GLOB.huds[ANTAG_HUD_VAMPIRE]
	vamphud.leave_hud(traitor_mind.current)
	set_antag_hud(traitor_mind.current, null)


/datum/game_mode/vampire/generate_report()
	return "The Wizard Federation has created a new being based off ancient mythology. \
	These beings are known as vampires and are capable of sucking blood from crew members. \
	No further information is known at this time."

/datum/role_preference/antagonist/vampire
	name = "Vampire"
	antag_datum = /datum/antagonist/vampire
