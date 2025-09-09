/datum/antagonist/kapitanbomba
	name = "Fugitive"
	roundend_category = "Fugitive"
	banning_key = ROLE_KAPITANBOMBA
	silent = TRUE //greet called by the event
	show_in_antagpanel = FALSE
	prevent_roundtype_conversion = FALSE
	count_against_dynamic_roll_chance = FALSE
	var/datum/team/kapitanbomba/kapitanbomba_team
	var/is_captured = FALSE
	var/backstory = "error"

/datum/antagonist/kapitanbomba/apply_innate_effects(mob/living/mob_override)
	var/mob/living/M = mob_override || owner.current
	update_kapitanbomba_icons_added(M)

/datum/antagonist/kapitanbomba/remove_innate_effects(mob/living/mob_override)
	var/mob/living/M = mob_override || owner.current
	update_kapitanbomba_icons_removed(M)

/datum/antagonist/kapitanbomba/on_gain()
	forge_objectives()
	. = ..()
	for(var/datum/objective/O in objectives)
		log_objective(owner, O.explanation_text)

/datum/antagonist/kapitanbomba/proc/forge_objectives() //this isn't the actual survive objective because it's about who in the team survives
	var/datum/objective/survive = new /datum/objective
	survive.owner = owner
	survive.explanation_text = "Avoid capture from the fugitive hunters."
	objectives += survive

/datum/antagonist/kapitanbomba/greet()
	to_chat(owner, "<span class='boldannounce'>You are the Fugitive!</span>")
	to_chat(src, "<span class='danger'>You also sense other silicon life on the station. Escaping would allow notifying S.E.L.F. to intervene... or you could free them yourself...</span>")

	to_chat(owner, "<span class='boldannounce'>You are not an antagonist in that you may kill whomever you please, but you can do anything to avoid capture.</span>")
	owner.announce_objectives()

/datum/antagonist/kapitanbomba/create_team(datum/team/kapitanbomba/new_team)
	if(!new_team)
		for(var/datum/antagonist/kapitanbomba/H in GLOB.antagonists)
			if(!H.owner)
				continue
			if(H.kapitanbomba_team)
				kapitanbomba_team = H.kapitanbomba_team
				return
		kapitanbomba_team = new /datum/team/kapitanbomba
		return
	if(!istype(new_team))
		stack_trace("Wrong team type passed to [type] initialization.")
	kapitanbomba_team = new_team

/datum/antagonist/kapitanbomba/get_team()
	return kapitanbomba_team

/datum/team/kapitanbomba/roundend_report() //shows the number of fugitives, but not if they won in case there is no security
	var/list/kapitanbombas = list()
	for(var/datum/antagonist/kapitanbomba/kapitanbomba_antag in GLOB.antagonists)
		if(!kapitanbomba_antag.owner)
			continue
		kapitanbombas += kapitanbomba_antag
	if(!kapitanbombas.len)
		return

	var/list/result = list()

	result += "<div class='panel redborder'><B>[kapitanbombas.len]</B> [kapitanbombas.len == 1 ? "fugitive" : "fugitives"] took refuge on [station_name()]!"

	for(var/datum/antagonist/kapitanbomba/antag in kapitanbombas)
		if(antag.owner)
			result += "<b>[printplayer(antag.owner)]</b>"

	return result.Join("<br>")

/datum/antagonist/kapitanbomba/proc/update_kapitanbomba_icons_added(var/mob/living/carbon/human/kapitanbomba)
	var/datum/atom_hud/antag/fughud = GLOB.huds[ANTAG_HUD_KAPITANBOMBA]
	fughud.join_hud(kapitanbomba)
	set_antag_hud(kapitanbomba, "kapitanbomba")

/datum/antagonist/kapitanbomba/proc/update_kapitanbomba_icons_removed(var/mob/living/carbon/human/kapitanbomba)
	var/datum/atom_hud/antag/fughud = GLOB.huds[ANTAG_HUD_KAPITANBOMBA]
	fughud.leave_hud(kapitanbomba)
	set_antag_hud(kapitanbomba, null)
