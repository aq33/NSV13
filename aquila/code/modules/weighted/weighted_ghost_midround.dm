// AQUILA - Weighted rotation: every 30-60 minutes ghosts are offered a midround antagonist,
// as long as at least 75% of the crew is still alive. Every eligible antagonist has the same chance.
// The heavy ones (slaughter demon, space dragon, blob, wizard, nuclear assault) are only offered in rounds from the high pool.
// Regular random events keep running next to this.

#define WEIGHTED_MIDROUND_MIN_DELAY (30 MINUTES)
#define WEIGHTED_MIDROUND_MAX_DELAY (60 MINUTES)
/// Share of the crew that has to be alive for a midround antagonist to be offered
#define WEIGHTED_MIDROUND_ALIVE_RATIO 0.75
/// Offers that are not a random event, spawned here instead
#define WEIGHTED_MIDROUND_WIZARD "wizard"
#define WEIGHTED_MIDROUND_NUCLEAR "nuclear"

/datum/weighted_ghost_midround
	/// Custom offers (wizard, nuclear) that already ran this round, each one runs once
	var/list/used_offers = list()

/// Ghost antagonist events offered in every weighted round
/datum/weighted_ghost_midround/proc/common_events()
	var/static/list/events = list(
		/datum/round_event_control/abductor,
		/datum/round_event_control/alien_infestation,
		/datum/round_event_control/aquila_chrono_legionnaire,
		/datum/round_event_control/aquila_rogue_drone,
		/datum/round_event_control/aquila_teratoma,
		/datum/round_event_control/fugitives,
		/datum/round_event_control/horror,
		/datum/round_event_control/infiltrators,
		/datum/round_event_control/morph,
		/datum/round_event_control/ninja,
		/datum/round_event_control/operative,
		/datum/round_event_control/paradox_clone,
		/datum/round_event_control/pirates,
		/datum/round_event_control/revenant,
		/datum/round_event_control/sentient_disease,
		/datum/round_event_control/sinfuldemon,
		/datum/round_event_control/spawn_swarmer,
		/datum/round_event_control/wizard/imposter,
	)
	// Antagoniści z osobnych PR-ów (i koszmar, którego event zastąpił demon cieni) po ścieżce tekstowej,
	// żeby tryb kompilował się w każdej kolejności merge'ów i brał tylko te, które istnieją
	var/static/list/optional_events
	if(isnull(optional_events))
		optional_events = list()
		for(var/path_text in list(
			"/datum/round_event_control/nightmare",
			"/datum/round_event_control/pulse_demon",
			"/datum/round_event_control/shadow_demon",
			"/datum/round_event_control/voidwalker",
		))
			var/event_path = text2path(path_text)
			if(event_path)
				optional_events += event_path
	return events + optional_events

/// Ghost antagonist events offered only in rounds from the high pool
/datum/weighted_ghost_midround/proc/heavy_events()
	var/static/list/events = list(
		/datum/round_event_control/blob,
		/datum/round_event_control/slaughter,
		/datum/round_event_control/space_dragon,
	)
	return events

/datum/weighted_ghost_midround/proc/schedule()
	addtimer(CALLBACK(src, PROC_REF(try_offer)), rand(WEIGHTED_MIDROUND_MIN_DELAY, WEIGHTED_MIDROUND_MAX_DELAY))

/datum/weighted_ghost_midround/proc/try_offer()
	if(SSticker.current_state != GAME_STATE_PLAYING || EMERGENCY_ESCAPED_OR_ENDGAMED)
		return
	schedule()
	if(!(GLOB.ghost_role_flags & GHOSTROLE_MIDROUND_EVENT))
		log_game("WEIGHTED: midround antagonist skipped, ghost roles are disabled")
		return
	var/ratio = crew_alive_ratio()
	if(ratio < WEIGHTED_MIDROUND_ALIVE_RATIO)
		log_game("WEIGHTED: midround antagonist skipped, only [round(ratio * 100)]% of the crew is alive")
		return
	var/list/offers = eligible_offers()
	if(!length(offers))
		log_game("WEIGHTED: midround antagonist skipped, nothing can spawn right now")
		return
	var/offer = pick(offers)
	message_admins("Weighted: duchom proponowany jest antagonista midround: [istext(offer) ? offer : "[offer]"].")
	log_game("WEIGHTED: offering midround antagonist [istext(offer) ? offer : "[offer]"] ([round(ratio * 100)]% of the crew alive)")
	INVOKE_ASYNC(src, PROC_REF(run_offer), offer)

/// Living crew members compared to everyone who got a station job this round
/datum/weighted_ghost_midround/proc/crew_alive_ratio()
	var/crew = 0
	var/alive = 0
	for(var/datum/mind/crew_mind as anything in SSticker.minds)
		if(!crew_mind.assigned_role || !SSjob.GetJob(crew_mind.assigned_role))
			continue
		crew++
		var/mob/living/body = crew_mind.current
		if(istype(body) && body.stat != DEAD)
			alive++
	return crew ? alive / crew : 0

/datum/weighted_ghost_midround/proc/eligible_offers()
	. = list()
	var/heavy = (GLOB.weighted_rotation.round_pool == WEIGHTED_POOL_HIGH)
	var/list/event_types = list()
	event_types += common_events()
	if(heavy)
		event_types += heavy_events()
	var/players = get_active_player_count(alive_check = TRUE, afk_check = TRUE, human_check = TRUE)
	for(var/datum/round_event_control/event as anything in SSevents.control)
		if(!(event.type in event_types))
			continue
		if(istype(event, /datum/round_event_control/wizard/imposter))
			// A wizard event, so it skips the wizard mode check, but only makes sense while a wizard is alive
			if(event.occurrences >= event.max_occurrences || !living_wizard())
				continue
		else if(!event.canSpawnEvent(players, SSticker.mode.config_tag))
			continue
		. += event
	// The wizard and nuclear team poll ghosts through pollGhostCandidates(), which gives nobody with station sentience roles off
	if(!heavy || !(GLOB.ghost_role_flags & GHOSTROLE_STATION_SENTIENCE))
		return
	if(!(WEIGHTED_MIDROUND_WIZARD in used_offers) && length(GLOB.wizardstart) && !living_wizard())
		. += WEIGHTED_MIDROUND_WIZARD
	if(!(WEIGHTED_MIDROUND_NUCLEAR in used_offers) && !istype(SSticker.mode, /datum/game_mode/nuclear))
		. += WEIGHTED_MIDROUND_NUCLEAR

/datum/weighted_ghost_midround/proc/living_wizard()
	for(var/datum/mind/wizard as anything in SSticker.mode.wizards)
		if(isliving(wizard.current) && wizard.current.stat != DEAD)
			return TRUE
	return FALSE

/// Polling ghosts takes time, the round may have ended or the crew may have left meanwhile
/datum/weighted_ghost_midround/proc/round_still_running()
	return SSticker.current_state == GAME_STATE_PLAYING && !EMERGENCY_ESCAPED_OR_ENDGAMED

/datum/weighted_ghost_midround/proc/run_offer(offer)
	if(offer == WEIGHTED_MIDROUND_WIZARD)
		used_offers += offer
		spawn_wizard()
	else if(offer == WEIGHTED_MIDROUND_NUCLEAR)
		used_offers += offer
		spawn_nuclear_team()
	else
		var/datum/round_event_control/event = offer
		if(istype(event, /datum/round_event_control/wizard/imposter))
			// TriggerEvent's checks would refuse a wizard event outside of summon events
			event.random = TRUE
			event.runEvent()
		else
			SSevents.TriggerEvent(event)

/datum/weighted_ghost_midround/proc/spawn_wizard()
	var/list/candidates = pollGhostCandidates("Czy chcesz zostać czarodziejem Federacji Czarodziejów?", ROLE_WIZARD, /datum/role_preference/midround_ghost/wizard)
	if(!round_still_running())
		return
	if(!length(candidates))
		message_admins("Weighted: nikt nie zgłosił się na czarodzieja.")
		return
	var/mob/living/carbon/human/wizard = makeBody(pick(candidates))
	if(!wizard)
		return
	wizard.mind.make_Wizard()
	message_admins("Weighted: [ADMIN_LOOKUPFLW(wizard)] został czarodziejem midround.")
	log_game("WEIGHTED: [key_name(wizard)] was made a midround wizard")

/datum/weighted_ghost_midround/proc/spawn_nuclear_team()
	// Team size by living players, as in the dynamic Nuclear Assault ruleset
	var/static/list/operative_cap = list(2, 2, 3, 3, 4, 5, 5, 5, 5, 5)
	var/living = get_active_player_count(alive_check = TRUE, afk_check = TRUE, human_check = TRUE)
	var/team_size = operative_cap[min(length(operative_cap), round(living / 5) + 1)]
	var/list/candidates = pollGhostCandidates("Czy chcesz dołączyć do drużyny nuklearnej Syndykatu?", ROLE_OPERATIVE, /datum/role_preference/midround_ghost/nuclear_operative)
	if(!round_still_running())
		return
	for(var/mob/dead/observer/ghost as anything in candidates)
		if(!ghost.client)
			candidates -= ghost
	if(length(candidates) < 2)
		message_admins("Weighted: za mało chętnych na drużynę nuklearną ([length(candidates)]).")
		return
	shuffle_inplace(candidates)
	var/datum/team/nuclear/nuke_team
	for(var/i in 1 to min(team_size, length(candidates)))
		var/mob/living/carbon/human/operative = makeBody(candidates[i])
		if(!operative)
			continue
		operative.mind.special_role = ROLE_OPERATIVE
		operative.mind.assigned_role = ROLE_OPERATIVE
		if(!nuke_team)
			var/datum/antagonist/nukeop/leader/leader = operative.mind.add_antag_datum(/datum/antagonist/nukeop/leader)
			nuke_team = leader.nuke_team
		else
			operative.mind.add_antag_datum(/datum/antagonist/nukeop, nuke_team)
	message_admins("Weighted: wysłano drużynę nuklearną midround.")
	log_game("WEIGHTED: sent a midround nuclear team")

#undef WEIGHTED_MIDROUND_MIN_DELAY
#undef WEIGHTED_MIDROUND_MAX_DELAY
#undef WEIGHTED_MIDROUND_ALIVE_RATIO
#undef WEIGHTED_MIDROUND_WIZARD
#undef WEIGHTED_MIDROUND_NUCLEAR
