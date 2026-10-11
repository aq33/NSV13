// Port BeeStation #13247: nasze głosowania jako datumy. Zasady dla niegłosujących i efekty są takie jak w starym SSvote.

// ===== Restart =====
#define CHOICE_RESTART "Restart Round"
#define CHOICE_CONTINUE "Continue Playing"

/datum/vote/restart_vote
	name = "Restart"
	default_choices = list(
		CHOICE_RESTART,
		CHOICE_CONTINUE,
	)
	default_message = "Vote to restart the ongoing round. Only works if there are no non-AFK admins online."

/// Whether an admin with +SERVER is online and not AFK, then the restart does not happen on its own
/datum/vote/restart_vote/proc/admins_present()
	for(var/client/online_admin in GLOB.admins + GLOB.deadmins)
		if(online_admin.is_afk() || !check_rights_for(online_admin, R_SERVER))
			continue
		return TRUE
	return FALSE

/datum/vote/restart_vote/toggle_votable()
	CONFIG_SET(flag/allow_vote_restart, !CONFIG_GET(flag/allow_vote_restart))

/datum/vote/restart_vote/is_config_enabled()
	return CONFIG_GET(flag/allow_vote_restart)

/datum/vote/restart_vote/get_vote_result(list/non_voters)
	if(!CONFIG_GET(flag/default_no_vote))
		// Default no votes will add non-voters to "Continue Playing"
		choices[CHOICE_CONTINUE] += length(non_voters)
	return ..()

/datum/vote/restart_vote/finalize_vote(winning_option)
	if(winning_option != CHOICE_RESTART)
		return
	if(admins_present())
		to_chat(world, "<span class='boldannounce'>Notice: Restart vote will not restart the server automatically because there are active admins on.</span>")
		message_admins("A restart vote has passed, but there are active admins on with +server, so it has been canceled. If you wish, you may restart the server.")
		return
	SSticker.Reboot("Restart vote successful.", "restart vote")

#undef CHOICE_RESTART
#undef CHOICE_CONTINUE

// ===== Crew transfer =====
#define CHOICE_TRANSFER "Initiate Crew Transfer"
#define CHOICE_CONTINUE "Continue Playing"

/datum/vote/transfer
	name = "Transfer"
	default_choices = list(
		CHOICE_TRANSFER,
		CHOICE_CONTINUE,
	)
	default_message = "Vote to end the round with a crew transfer."

/datum/vote/transfer/can_be_initiated(forced)
	. = ..()
	if(. != VOTE_AVAILABLE)
		return
	if(!forced)
		return "Only admins and the server can start a transfer vote."

/datum/vote/transfer/get_vote_result(list/non_voters)
	if(!CONFIG_GET(flag/default_no_vote))
		// Non-voters lean towards the transfer as the round goes on
		var/factor = 1
		switch(world.time / (1 MINUTES))
			if(0 to 60)
				factor = 0.5
			if(61 to 120)
				factor = 0.8
			if(121 to 240)
				factor = 1
			if(241 to 300)
				factor = 1.2
			else
				factor = 1.4
		choices[CHOICE_TRANSFER] += round(length(non_voters) * factor)
	return ..()

/datum/vote/transfer/finalize_vote(winning_option)
	if(winning_option != CHOICE_TRANSFER)
		return
	SSshuttle.requestEvac(null, "Crew Transfer Requested.")
	SSshuttle.emergencyNoRecall = TRUE //Prevent Recall.
	var/obj/machinery/computer/communications/C = locate() in GLOB.machines
	if(C)
		C.post_status("shuttle")

#undef CHOICE_TRANSFER
#undef CHOICE_CONTINUE

// ===== Game mode =====
/datum/vote/gamemode
	name = "Gamemode"
	default_message = "Vote for the game mode of the next round."

/datum/vote/gamemode/is_accessible_vote()
	return TRUE

/datum/vote/gamemode/toggle_votable()
	CONFIG_SET(flag/allow_vote_mode, !CONFIG_GET(flag/allow_vote_mode))

/datum/vote/gamemode/is_config_enabled()
	return CONFIG_GET(flag/allow_vote_mode)

/datum/vote/gamemode/can_be_initiated(forced)
	. = ..()
	if(. != VOTE_AVAILABLE)
		return
	if(SSticker.HasRoundStarted())
		return "The round has already started."

/datum/vote/gamemode/create_vote(mob/vote_creator)
	default_choices = config.votable_modes.Copy()
	return ..()

/datum/vote/gamemode/get_vote_result(list/non_voters)
	if(!CONFIG_GET(flag/default_no_vote) && (GLOB.master_mode in choices))
		choices[GLOB.master_mode] += length(non_voters)
	return ..()

/datum/vote/gamemode/finalize_vote(winning_option)
	if(winning_option && GLOB.master_mode != winning_option && !SSticker.HasRoundStarted())
		GLOB.master_mode = winning_option

// ===== Map (NSV13) =====
/datum/vote/map
	name = "Map"
	default_message = "Vote for next round's map!"

/datum/vote/map/is_accessible_vote()
	return TRUE

/datum/vote/map/toggle_votable()
	CONFIG_SET(flag/allow_vote_map, !CONFIG_GET(flag/allow_vote_map))

/datum/vote/map/is_config_enabled()
	return CONFIG_GET(flag/allow_vote_map)

/datum/vote/map/can_mob_vote(mob/voter)
	// Dead players may vote for the map, map vote bans still apply
	return !is_banned_from(voter.ckey, "Mapvote")

/datum/vote/map/create_vote(mob/vote_creator)
	// Randomized so the first map is not always the same, NSV13: no forced map rotation
	var/list/maps = list()
	for(var/map in global.config.maplist)
		var/datum/map_config/VM = config.maplist[map]
		if(!VM.is_votable())
			continue
		maps += VM.map_name
	shuffle_inplace(maps)
	default_choices = maps
	if(!length(default_choices))
		to_chat(vote_creator, "<span class='warning'>There are no maps to vote for.</span>")
		return FALSE
	return ..()

/datum/vote/map/get_vote_result(list/non_voters)
	if(!CONFIG_GET(flag/default_no_vote))
		// Non-voters vote for their preferred map, or the default one
		for(var/non_voter_ckey in non_voters)
			var/client/C = non_voters[non_voter_ckey]
			var/preferred_map = C?.prefs?.preferred_map
			if(preferred_map && (preferred_map in choices))
				choices[preferred_map] += 1
			else if(global.config.defaultmap && (global.config.defaultmap.map_name in choices))
				choices[global.config.defaultmap.map_name] += 1
	return ..()

/datum/vote/map/finalize_vote(winning_option)
	// NSV13 - record who voted for what during the map vote
	var/list/ckeys_by_choice = list()
	for(var/ckey in choices_by_ckey)
		LAZYADD(ckeys_by_choice[choices_by_ckey[ckey]], ckey)
	for(var/choice in ckeys_by_choice)
		log_vote("[choice]: [english_list(ckeys_by_choice[choice])]")
	SSpersistence.SaveMapVoters(SSvote.voted.Copy())
	if(!winning_option)
		return
	SSmapping.changemap(global.config.maplist[winning_option])
	SSmapping.map_voted = TRUE

// ===== Round extension (NSV13) =====
#define CHOICE_OBJECTIVES "Request Additional Objectives"

/datum/vote/round_extension
	name = "Press On Or Return Home?"
	contains_vote_in_name = TRUE
	default_message = "Vote to request more objectives or to return home."

/datum/vote/round_extension/is_accessible_vote()
	return TRUE

/datum/vote/round_extension/can_be_initiated(forced)
	. = ..()
	if(. != VOTE_AVAILABLE)
		return
	if(!forced)
		return "Only Central Command can start this vote."
	if(!SSstar_system.return_system)
		return "There is no system to return to."

/datum/vote/round_extension/proc/return_choice()
	return "Return to [SSstar_system.return_system.name]"

/datum/vote/round_extension/create_vote(mob/vote_creator)
	default_choices = list(return_choice(), CHOICE_OBJECTIVES)
	return ..()

/datum/vote/round_extension/get_vote_result(list/non_voters)
	if(!CONFIG_GET(flag/default_no_vote))
		choices[return_choice()] += length(non_voters)
	return ..()

/datum/vote/round_extension/finalize_vote(winning_option)
	if(!winning_option)
		return
	if(winning_option == CHOICE_OBJECTIVES)
		priority_announce("Additional Objectives") //TEMP
		SSovermap_mode.round_extended = TRUE
		SSovermap_mode.request_additional_objectives()
		SSovermap_mode.already_ended = FALSE
		SSovermap_mode.objectives_completed = FALSE
		return
	priority_announce("Returning to [SSstar_system.return_system.name]") //TEMP
	var/obj/structure/overmap/OM = SSstar_system.find_main_overmap()
	OM.force_return_jump()

#undef CHOICE_OBJECTIVES

// ===== Hardmode (NSV13) =====
#define CHOICE_HARDMODE "Let's GO FOR IT"
#define CHOICE_NORMAL "Play a normal round"

/datum/vote/hardmode
	name = "Hardmode"
	default_choices = list(
		CHOICE_HARDMODE,
		CHOICE_NORMAL,
	)
	default_message = "Vote for a harder round."

/datum/vote/hardmode/can_be_initiated(forced)
	. = ..()
	if(. != VOTE_AVAILABLE)
		return
	if(!forced)
		return "Only admins can start a hardmode vote."

/datum/vote/hardmode/get_vote_result(list/non_voters)
	if(!CONFIG_GET(flag/default_no_vote))
		choices[CHOICE_NORMAL] += length(non_voters) // You need an absolute majority
	return ..()

/datum/vote/hardmode/finalize_vote(winning_option)
	if(winning_option == CHOICE_HARDMODE)
		SSovermap_mode.toggle_hardmode()

#undef CHOICE_HARDMODE
#undef CHOICE_NORMAL
