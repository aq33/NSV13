// AQUILA - Chrono Legionnaire midround ghost antagonist event.
// Only possible while a living player's character is named after a historical tyrant (see GLOB.aquila_chrono_historical_names).
// A ghost becomes a time agent with the chronosuit and T.E.D., whose only goal is to eliminate that player.

/datum/round_event_control/aquila_chrono_legionnaire
	name = "Spawn Chrono Legionnaire"
	typepath = /datum/round_event/ghost_role/aquila_chrono_legionnaire
	// Can only roll while someone is named after a tyrant, so it may as well be likely when it can
	weight = 25
	max_occurrences = 2
	min_players = 5
	earliest_start = 10 MINUTES
	cannot_spawn_after_shuttlecall = TRUE
	/// Target an admin picked when forcing the event, used once by the next spawn
	var/datum/weakref/forced_target

/datum/round_event_control/aquila_chrono_legionnaire/canSpawnEvent(players_amt, gamemode)
	if(!length(aquila_chrono_find_targets()))
		return FALSE
	return ..()

/datum/round_event_control/aquila_chrono_legionnaire/admin_setup()
	if(!check_rights(R_FUN))
		return
	forced_target = null
	var/list/choices = list()
	for(var/mob/living/carbon/human/H in GLOB.alive_mob_list)
		if(!H.client && !H.mind) // skip random corpses and NPC bodies nobody plays
			continue
		var/figure = aquila_chrono_historical_figure(H.real_name)
		choices["[H.real_name][figure ? " ([figure])" : ""][H.client ? "" : " (bez gracza)"]"] = H
	var/choice = tgui_input_list(usr, "Kogo ma ścigać legionista? Brak wyboru = losowy gracz o imieniu tyrana.", "Chrono Legionnaire", sortList(choices))
	var/mob/living/carbon/human/picked = choices[choice]
	if(picked)
		forced_target = WEAKREF(picked)

/datum/round_event/ghost_role/aquila_chrono_legionnaire
	minimum_required = 1
	role_name = "Chrono Legionnaire"
	fakeable = FALSE

/datum/round_event/ghost_role/aquila_chrono_legionnaire/spawn_role()
	var/datum/round_event_control/aquila_chrono_legionnaire/chrono_control = control
	var/mob/living/carbon/human/forced = chrono_control?.forced_target?.resolve()
	if(chrono_control)
		chrono_control.forced_target = null
	if(!forced && !length(aquila_chrono_find_targets()))
		message_admins("Chrono Legionnaire event found nobody named after a tyrant, nothing was spawned.")
		return NOT_ENOUGH_PLAYERS

	var/list/candidates = get_candidates(ROLE_CHRONO_LEGIONNAIRE, /datum/role_preference/midround_ghost/chrono_legionnaire)
	if(!length(candidates))
		return NOT_ENOUGH_PLAYERS

	// The poll takes a while, pick the target afterwards so they are still around
	var/mob/living/carbon/human/target
	if(forced && !QDELETED(forced) && forced.stat != DEAD)
		target = forced
	else
		var/list/targets = aquila_chrono_find_targets()
		if(!length(targets))
			message_admins("Chrono Legionnaire event lost its target during the ghost poll, nothing was spawned.")
			return NOT_ENOUGH_PLAYERS
		target = pick(targets)

	var/turf/location = get_safe_random_station_turfs(typesof(/area/hallway))
	if(!location)
		location = get_safe_random_station_turfs()
	if(!location)
		message_admins("No valid spawn locations found for Chrono Legionnaire event, aborting...")
		return MAP_ERROR

	var/mob/dead/selected = pick(candidates)
	var/mob/living/carbon/human/legionnaire = create_chrono_legionnaire(selected.key, target, location)
	spawned_mobs += legionnaire

	priority_announce("Wykryto zaburzenie linii czasu na pokładzie statku. Centrala zaleca nie wchodzić w drogę osobom podróżującym w czasie.", "Anomalia temporalna", ANNOUNCER_SPANOMALIES)
	return SUCCESSFUL_SPAWN
