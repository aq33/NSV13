// Port BeeStation #13247: nasze głosowania jako datumy. Zasady dla niegłosujących i efekty są takie jak w starym SSvote.

// ===== Restart =====
#define CHOICE_RESTART "Zrestartuj rundę"
#define CHOICE_CONTINUE "Gramy dalej"

/datum/vote/restart_vote
	name = "Restart"
	default_choices = list(
		CHOICE_RESTART,
		CHOICE_CONTINUE,
	)
	default_message = "Głosowanie o restart trwającej rundy. Działa tylko, gdy nie ma aktywnych adminów."

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
		// Default no votes will add non-voters to "Gramy dalej"
		choices[CHOICE_CONTINUE] += length(non_voters)
	return ..()

/datum/vote/restart_vote/finalize_vote(winning_option)
	if(winning_option != CHOICE_RESTART)
		return
	if(admins_present())
		to_chat(world, "<span class='boldannounce'>Uwaga: głosowanie nie zrestartuje serwera automatycznie, bo są aktywni admini.</span>")
		message_admins("A restart vote has passed, but there are active admins on with +server, so it has been canceled. If you wish, you may restart the server.")
		return
	SSticker.Reboot("Restart vote successful.", "restart vote")

#undef CHOICE_RESTART
#undef CHOICE_CONTINUE

// ===== Crew transfer =====
#define CHOICE_TRANSFER "Rozpocznij transfer załogi"
#define CHOICE_CONTINUE "Gramy dalej"

/datum/vote/transfer
	name = "Transfer"
	default_choices = list(
		CHOICE_TRANSFER,
		CHOICE_CONTINUE,
	)
	default_message = "Głosowanie o zakończenie rundy transferem załogi."

/datum/vote/transfer/can_be_initiated(forced)
	. = ..()
	if(. != VOTE_AVAILABLE)
		return
	if(!forced)
		return "Głosowanie o transfer mogą rozpocząć tylko admini i serwer."

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
	SSshuttle.requestEvac(null, "Zażądano transferu załogi.")
	SSshuttle.emergencyNoRecall = TRUE //Prevent Recall.
	var/obj/machinery/computer/communications/C = locate() in GLOB.machines
	if(C)
		C.post_status("shuttle")

#undef CHOICE_TRANSFER
#undef CHOICE_CONTINUE

// ===== Game mode =====
/datum/vote/gamemode
	name = "Gamemode"
	default_message = "Głosowanie o tryb gry następnej rundy."

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
		return "Runda już się zaczęła."

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
	default_message = "Głosowanie o mapę następnej rundy!"

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
		to_chat(vote_creator, "<span class='warning'>Nie ma map, na które można głosować.</span>")
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
#define CHOICE_OBJECTIVES "Poproś o dodatkowe cele"

/datum/vote/round_extension
	name = "Press On Or Return Home?"
	contains_vote_in_name = TRUE
	default_message = "Głosowanie: prośba o dodatkowe cele albo powrót do domu."

/datum/vote/round_extension/is_accessible_vote()
	return TRUE

/datum/vote/round_extension/can_be_initiated(forced)
	. = ..()
	if(. != VOTE_AVAILABLE)
		return
	if(!forced)
		return "To głosowanie może rozpocząć tylko Centrala."
	if(!SSstar_system.return_system)
		return "Nie ma układu, do którego można wrócić."

/datum/vote/round_extension/proc/return_choice()
	return "Powrót do [SSstar_system.return_system.name]"

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
		priority_announce("Dodatkowe cele") //TEMP
		SSovermap_mode.round_extended = TRUE
		SSovermap_mode.request_additional_objectives()
		SSovermap_mode.already_ended = FALSE
		SSovermap_mode.objectives_completed = FALSE
		return
	priority_announce("Powrót do [SSstar_system.return_system.name]") //TEMP
	var/obj/structure/overmap/OM = SSstar_system.find_main_overmap()
	OM.force_return_jump()

#undef CHOICE_OBJECTIVES

// ===== Hardmode (NSV13) =====
#define CHOICE_HARDMODE "DAWAJ, IDZIEMY NA TO"
#define CHOICE_NORMAL "Zwykła runda"

/datum/vote/hardmode
	name = "Hardmode"
	default_choices = list(
		CHOICE_HARDMODE,
		CHOICE_NORMAL,
	)
	default_message = "Głosowanie o trudniejszą rundę."

/datum/vote/hardmode/can_be_initiated(forced)
	. = ..()
	if(. != VOTE_AVAILABLE)
		return
	if(!forced)
		return "Głosowanie o tryb trudny mogą rozpocząć tylko admini."

/datum/vote/hardmode/get_vote_result(list/non_voters)
	if(!CONFIG_GET(flag/default_no_vote))
		choices[CHOICE_NORMAL] += length(non_voters) // You need an absolute majority
	return ..()

/datum/vote/hardmode/finalize_vote(winning_option)
	if(winning_option == CHOICE_HARDMODE)
		SSovermap_mode.toggle_hardmode()

#undef CHOICE_HARDMODE
#undef CHOICE_NORMAL
