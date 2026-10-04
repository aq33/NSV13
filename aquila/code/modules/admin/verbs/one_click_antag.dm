
/// Extra Aquila buttons appended to the end of the core one_click_antag() panel; the makeAntag topics are handled in aquila/code/modules/admin/topic.dm
/datum/admins/proc/aquila_one_click_antag_links()
	return {"<a href='?src=[REF(src)];[HrefToken()];makeAntag=infiltrator'>Make Infiltration Team (Requires Ghosts)</a>
		<a href='?src=[REF(src)];[HrefToken()];makeAntag=vampire'>Make Vampire (Requires Ghosts)</a>
		"}

/datum/admins/proc/makeInfiltratorTeam()
	var/datum/game_mode/infiltration/temp = new
	var/list/mob/dead/observer/candidates = pollGhostCandidates("Do you wish to be considered for a infiltration team being sent in?", ROLE_INFILTRATOR, temp)
	var/list/mob/dead/observer/chosen = list()
	var/mob/dead/observer/theghost = null

	if(LAZYLEN(candidates))
		var/numagents = 5
		var/agentcount = 0

		for(var/i = 0, i<numagents,i++)
			shuffle_inplace(candidates) //More shuffles means more randoms
			for(var/mob/j in candidates)
				if(!j || !j.client)
					candidates.Remove(j)
					continue

				theghost = j
				candidates.Remove(theghost)
				chosen += theghost
				agentcount++
				break
		//Making sure we have atleast 3 Nuke agents, because less than that is kinda bad
		if(agentcount < 3)
			return FALSE

		//Let's find the spawn locations
		var/datum/team/infiltrator/TI = new/datum/team/infiltrator/
		for(var/mob/c in chosen)
			var/mob/living/carbon/human/new_character=makeBody(c)
			new_character.mind.add_antag_datum(/datum/antagonist/infiltrator, TI)
		TI.update_objectives()
		return TRUE
	return FALSE

/datum/admins/proc/makeVampire()
	var/datum/game_mode/vampire/temp = new
	if(CONFIG_GET(flag/protect_roles_from_antagonist))
		temp.restricted_jobs += temp.protected_jobs
	if(CONFIG_GET(flag/protect_assistant_from_antagonist))
		temp.restricted_jobs += "Assistant"
	var/list/mob/living/carbon/human/candidates = list()
	var/mob/living/carbon/human/H
	for(var/mob/living/carbon/human/applicant in GLOB.player_list)
		//if((ROLE_VAMPIRE in applicant.client.prefs.be_special) && !applicant.stat && applicant.mind && !applicant.mind.special_role)
			//if(!jobban_isbanned(applicant, "vampire") && !jobban_isbanned(applicant, "Syndicate"))
				//if(temp.age_check(applicant.client) && !(applicant.job in temp.restricted_jobs) && !is_vampire(applicant))
		candidates += applicant // Odpowiednie odstępy jeśli chcecie przywrócić czeki
	if(LAZYLEN(candidates))
		H = pick(candidates)
		add_vampire(H)
		return TRUE
	return FALSE
