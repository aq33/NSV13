// AQUILA - Weighted rotation, master mode "weighted".
// Game modes are split into three threat pools (WEIGHTED_POOL in game_options.txt). Every round a pool is drawn first,
// then a mode from inside it. The pools start out equal and the "Dynamika" answer of the end of round survey tilts them:
// rounds rated too boring make the high pool more likely, rounds rated too hectic the low one. The tilt is kept in a file
// between rounds. Weighted rounds also offer ghosts a midround antagonist every 30-60 minutes while most of the crew lives.

/// Where the survey tilt and the votes of the round that has not been counted yet are kept
#define WEIGHTED_PACE_FILE "data/weighted_pace.json"
/// How much the tilt moves the pools: the high pool weighs 1 + this * bias, the low one 1 - this * bias
#define WEIGHTED_SURVEY_STRENGTH 0.5
/// Share of the new tilt that comes from the last round's survey, the rest is the old tilt
#define WEIGHTED_ROUND_INFLUENCE 0.4
/// A round with fewer "Dynamika" answers than this does not vote, the old tilt only fades
#define WEIGHTED_MIN_VOTES 3

GLOBAL_DATUM_INIT(weighted_rotation, /datum/weighted_rotation, new)

/// AQUILA - weighted rotation: the most antagonists this mode may pick, null when the mode is not limited
/datum/game_mode/var/weighted_antag_cap = null

/// AQUILA - weighted rotation: returns amount, lowered to the antagonist limit of the weighted rotation if there is one
/datum/game_mode/proc/weighted_cap(amount)
	if(isnull(weighted_antag_cap))
		return amount
	return min(amount, weighted_antag_cap)

/datum/weighted_rotation
	/// From -1 (players want calmer rounds) to 1 (players want more chaos)
	var/bias = 0
	/// Sum of the "Dynamika" answers (1-5) given at the end of the current round
	var/pending_sum = 0
	/// How many "Dynamika" answers were given at the end of the current round
	var/pending_count = 0
	/// What happened to the tilt when it was loaded, shown to admins when the mode is picked
	var/load_report = ""
	/// The pool the current round was drawn from, null when the round is not weighted
	var/round_pool
	/// Offers ghost antagonists during weighted rounds
	var/datum/weighted_ghost_midround/ghost_midround
	/// The roundstart callback is already waiting
	var/roundstart_hooked = FALSE
	/// Lobby odds cache, so the stat panel does not count modes on every refresh
	var/list/cached_lobby_odds
	var/cached_lobby_players = -1
	var/cached_lobby_time = 0

/datum/weighted_rotation/New()
	load()
	count_last_round()

/datum/weighted_rotation/proc/load()
	if(!fexists(WEIGHTED_PACE_FILE))
		return
	var/list/data = json_decode(file2text(WEIGHTED_PACE_FILE))
	if(!islist(data))
		return
	bias = clamp(text2num("[data["bias"]]") || 0, -1, 1)
	pending_sum = max(text2num("[data["pending_sum"]]") || 0, 0)
	pending_count = max(text2num("[data["pending_count"]]") || 0, 0)

/datum/weighted_rotation/proc/save()
	var/list/data = list("bias" = bias, "pending_sum" = pending_sum, "pending_count" = pending_count)
	fdel(WEIGHTED_PACE_FILE)
	text2file(json_encode(data), WEIGHTED_PACE_FILE)

/// The votes in the file come from the round before this server start, they are turned into the tilt here
/datum/weighted_rotation/proc/count_last_round()
	if(pending_count <= 0)
		load_report = "brak głosów z poprzedniej rundy"
		return
	var/old_bias = bias
	if(pending_count >= WEIGHTED_MIN_VOTES)
		var/average = pending_sum / pending_count
		// 1 = too boring -> +1, 3 = fine -> 0, 5 = too hectic -> -1
		var/round_vote = (3 - average) / 2
		bias = clamp(bias * (1 - WEIGHTED_ROUND_INFLUENCE) + round_vote * WEIGHTED_ROUND_INFLUENCE, -1, 1)
		load_report = "[pending_count] głosów, średnia dynamika [round(average, 0.01)]"
	else
		bias *= (1 - WEIGHTED_ROUND_INFLUENCE)
		load_report = "tylko [pending_count] głosów (min. [WEIGHTED_MIN_VOTES]), nastawienie słabnie"
	load_report += ", nastawienie [round(old_bias, 0.01)] -> [round(bias, 0.01)]"
	pending_sum = 0
	pending_count = 0
	save()

/// Called by the end of round survey for every "Dynamika" answer of a player who had a character this round
/datum/weighted_rotation/proc/add_pace_vote(pace)
	pending_sum += pace
	pending_count++
	save()

/// Weight of every pool before empty pools are dropped
/datum/weighted_rotation/proc/pool_weights()
	return list(
		WEIGHTED_POOL_LOW = 1 - WEIGHTED_SURVEY_STRENGTH * bias,
		WEIGHTED_POOL_MEDIUM = 1,
		WEIGHTED_POOL_HIGH = 1 + WEIGHTED_SURVEY_STRENGTH * bias,
	)

/// Percent chance of every pool, given which pools have something to pick from
/datum/weighted_rotation/proc/pool_odds(list/available_pools)
	var/list/weights = pool_weights()
	var/total = 0
	for(var/pool in weights)
		if(pool in available_pools)
			total += weights[pool]
	. = list()
	for(var/pool in weights)
		.[pool] = (total && (pool in available_pools)) ? round(weights[pool] / total * 100, 1) : 0

/datum/weighted_rotation/proc/pool_name(pool)
	switch(pool)
		if(WEIGHTED_POOL_LOW)
			return "Łagodne"
		if(WEIGHTED_POOL_MEDIUM)
			return "Umiarkowane"
		if(WEIGHTED_POOL_HIGH)
			return "Poważne"

/// Picks the game mode of a weighted round, or returns null when no listed mode can start
/datum/weighted_rotation/proc/pick_mode()
	var/list/pool_config = CONFIG_GET(keyed_list/weighted_pool)
	var/list/max_antags = CONFIG_GET(keyed_list/weighted_max_antags)
	var/list/min_pop = CONFIG_GET(keyed_list/min_pop)
	var/list/max_pop = CONFIG_GET(keyed_list/max_pop)
	var/list/repeated_mode_adjust = CONFIG_GET(number_list/repeated_mode_adjust)

	// pool -> list(mode instance -> weight)
	var/list/pools = list()
	for(var/mode_type in config.gamemode_cache)
		var/datum/game_mode/mode = new mode_type()
		var/pool = lowertext(pool_config[mode.config_tag])
		if(!pool)
			qdel(mode)
			continue
		if(min_pop[mode.config_tag])
			mode.required_players = min_pop[mode.config_tag]
		if(max_pop[mode.config_tag])
			mode.maximum_players = max_pop[mode.config_tag]
		if(max_antags[mode.config_tag])
			// Blood brothers only come in pairs
			var/smallest = istype(mode, /datum/game_mode/traitor/bros) ? 2 : 1
			mode.weighted_antag_cap = rand(smallest, max(smallest, max_antags[mode.config_tag]))
			// "Up to N" also means the mode has to start with just the smallest amount
			mode.required_enemies = min(mode.required_enemies, smallest)
		if(!mode.can_start())
			qdel(mode)
			continue
		// Same penalty for recently played modes as the secret rotation
		var/weight = 1
		if(SSpersistence.saved_modes.len == 3 && repeated_mode_adjust.len == 3)
			var/recent_round = min(SSpersistence.saved_modes.Find(mode.config_tag), 3)
			var/adjustment = 0
			while(recent_round)
				adjustment += repeated_mode_adjust[recent_round]
				recent_round = SSpersistence.saved_modes.Find(mode.config_tag, recent_round + 1, 0)
			weight *= (100 - adjustment) / 100
		LAZYINITLIST(pools[pool])
		pools[pool][mode] = weight

	if(!length(pools))
		return null

	var/list/odds = pool_odds(pools)
	var/list/pool_draw = list()
	for(var/pool in odds)
		if(odds[pool] > 0)
			pool_draw[pool] = odds[pool]
	round_pool = pickweight(pool_draw)
	var/datum/game_mode/picked = pickweight(pools[round_pool])

	var/list/pool_lines = list()
	for(var/pool in pools)
		var/list/mode_names = list()
		for(var/datum/game_mode/mode as anything in pools[pool])
			mode_names += mode.config_tag
			if(mode != picked)
				qdel(mode)
		pool_lines += "[pool_name(pool)] [odds[pool]]% ([mode_names.Join(", ")])"

	var/cap_text = isnull(picked.weighted_antag_cap) ? "bez limitu" : "max [picked.weighted_antag_cap]"
	message_admins("Weighted: ankiety - [load_report]. Szanse: [pool_lines.Join("; ")]. Wylosowano pulę [pool_name(round_pool)], tryb [picked.config_tag] (antagoniści: [cap_text]).")
	log_game("WEIGHTED: [load_report]. Odds: [pool_lines.Join("; ")]. Picked pool [round_pool], mode [picked.config_tag], antag cap [cap_text].")

	// pre_setup runs again when the round fails to start, the callback is only needed once
	if(!roundstart_hooked)
		roundstart_hooked = TRUE
		SSticker.OnRoundstart(CALLBACK(src, PROC_REF(on_round_start)))
	return picked

/datum/weighted_rotation/proc/on_round_start()
	if(GLOB.master_mode != "weighted")
		return
	ghost_midround = new
	ghost_midround.schedule()
	if(SSticker.mode.config_tag == "wizard")
		addtimer(CALLBACK(src, PROC_REF(warn_about_wizard)), rand(3 MINUTES, 6 MINUTES))

/// Wizard is allowed from 10 players in weighted rounds, so the crew gets a heads up
/datum/weighted_rotation/proc/warn_about_wizard()
	priority_announce("Czujniki dalekiego zasięgu wykryły zaburzenia bluespace typowe dla teleportów Federacji Czarodziejów. Na pokładzie [station_name()] może pojawić się czarodziej. Zachowajcie ostrożność.", "Anomalia magiczna", ANNOUNCER_SPANOMALIES)

/// Lobby chances of every pool for the players that are ready now (who has the antagonist enabled is only known at roundstart)
/datum/weighted_rotation/proc/lobby_odds()
	var/players = SSticker.totalPlayersReady
	if(cached_lobby_odds && cached_lobby_players == players && world.time < cached_lobby_time + 10 SECONDS)
		return cached_lobby_odds
	var/list/pool_config = CONFIG_GET(keyed_list/weighted_pool)
	var/list/min_pop = CONFIG_GET(keyed_list/min_pop)
	var/list/max_pop = CONFIG_GET(keyed_list/max_pop)
	var/list/available_pools = list()
	for(var/datum/game_mode/mode_type as anything in config.gamemode_cache)
		var/tag = initial(mode_type.config_tag)
		var/pool = lowertext(pool_config[tag])
		if(!pool)
			continue
		var/needed = min_pop[tag] || initial(mode_type.required_players)
		var/most = max_pop[tag] || initial(mode_type.maximum_players)
		if(players < needed || (most >= 0 && players > most))
			continue
		available_pools |= pool
	cached_lobby_odds = pool_odds(available_pools)
	cached_lobby_players = players
	cached_lobby_time = world.time
	return cached_lobby_odds

/mob/dead/get_stat_tab_status()
	var/list/tab_data = ..()
	if(GLOB.master_mode != "weighted" || SSticker.HasRoundStarted())
		return tab_data
	var/list/odds = GLOB.weighted_rotation.lobby_odds()
	for(var/pool in odds)
		tab_data["Szansa: [lowertext(GLOB.weighted_rotation.pool_name(pool))]"] = GENERATE_STAT_TEXT("[odds[pool]]%")
	return tab_data

#undef WEIGHTED_PACE_FILE
#undef WEIGHTED_SURVEY_STRENGTH
#undef WEIGHTED_ROUND_INFLUENCE
#undef WEIGHTED_MIN_VOTES
