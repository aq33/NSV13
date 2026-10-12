
/// Extra Aquila buttons appended to the end of the core one_click_antag() panel; the makeAntag topics are handled in aquila/code/modules/admin/topic.dm
/datum/admins/proc/aquila_one_click_antag_links()
	return {"<a href='byond://?src=[REF(src)];[HrefToken()];makeAntag=infiltrator'>Make Infiltration Team (Requires Ghosts)</a>
		<a href='byond://?src=[REF(src)];[HrefToken()];makeAntag=vampire'>Make Vampire</a>
		"}

/datum/admins/proc/makeInfiltratorTeam()
	var/datum/game_mode/infiltration/temp = new
	var/list/mob/dead/observer/candidates = pollGhostCandidates("Czy chcesz być brany pod uwagę do wysyłanego zespołu infiltracyjnego?", ROLE_INFILTRATOR, temp)
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
		temp.restricted_jobs += JOB_NAME_ASSISTANT
	if(CONFIG_GET(flag/protect_heads_from_antagonist))
		temp.restricted_jobs += GLOB.command_positions
	var/list/mob/living/carbon/human/candidates = list()
	for(var/mob/living/carbon/human/applicant in GLOB.player_list)
		if(isReadytoRumble(applicant, ROLE_VAMPIRE, /datum/role_preference/antagonist/vampire))
			if(!(applicant.job in temp.restricted_jobs) && !is_vampire(applicant))
				candidates += applicant
	if(!LAZYLEN(candidates))
		return FALSE
	return add_vampire(pick(candidates)) ? TRUE : FALSE

/// AQUILA - port BeeStation/BeeStation-Hornet#11415: admin tworzący ERT może pojawić się jako oficer odprawy w wybranym stroju
/datum/admins/proc/spawn_briefing_officer(mob/user, turf/spawnloc)
	if(!isobserver(user) || !user.client)
		to_chat(user, "<span class='warning'>Could not spawn you in as briefing officer as you are not a ghost!</span>")
		return
	var/list/outfits = list()
	for(var/datum/outfit/outfit_type as anything in subtypesof(/datum/outfit))
		outfits["[initial(outfit_type.name)] ([outfit_type])"] = outfit_type
	var/default_outfit = "[initial(/datum/outfit/centcom/commander::name)] ([/datum/outfit/centcom/commander])"
	var/picked = tgui_input_list(user, "Strój oficera odprawy", "Briefing officer", sort_list(outfits), default_outfit)
	if(!picked || !isobserver(user) || !user.client)
		return
	var/mob/living/carbon/human/admin_officer = new(spawnloc)
	user.client.prefs.active_character.copy_to(admin_officer)
	admin_officer.equipOutfit(outfits[picked])
	admin_officer.key = user.key
	log_admin("[key_name(admin_officer)] spawned as the ERT briefing officer.")
