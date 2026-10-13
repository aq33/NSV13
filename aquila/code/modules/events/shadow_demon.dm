// AQUILA - event demona cieni (port z ParadiseSS13), zastępuje event koszmara

/datum/round_event_control/shadow_demon
	name = "Spawn Shadow Demon"
	typepath = /datum/round_event/ghost_role/shadow_demon
	max_occurrences = 1
	weight = 10
	min_players = 15
	dynamic_should_hijack = TRUE
	cannot_spawn_after_shuttlecall = TRUE

/datum/round_event/ghost_role/shadow_demon
	minimum_required = 1
	role_name = "shadow demon"
	fakeable = FALSE

/datum/round_event/ghost_role/shadow_demon/spawn_role()
	var/list/candidates = get_candidates(ROLE_SHADOW_DEMON, /datum/role_preference/midround_ghost/shadow_demon)
	if(!length(candidates))
		return NOT_ENOUGH_PLAYERS

	var/list/spawn_locs = shadow_demon_spawn_locations()
	if(!length(spawn_locs))
		message_admins("No valid spawn locations found for a shadow demon, aborting...")
		return MAP_ERROR

	var/mob/dead/selected = pick(candidates)
	var/mob/living/simple_animal/shadow_demon/demon = create_shadow_demon(selected.key, pick(spawn_locs))
	message_admins("[ADMIN_LOOKUPFLW(demon)] has been made into a shadow demon by an event.")
	log_game("[key_name(demon)] was spawned as a shadow demon by an event.")
	spawned_mobs += demon
	return SUCCESSFUL_SPAWN

/// Ciemne pola na statku: najpierw spawny ksenomorfów, potem okolice spawnów eventów
/proc/shadow_demon_spawn_locations()
	. = list()
	for(var/turf/T as anything in GLOB.xeno_spawn)
		if(is_station_level(T.z) && T.get_lumcount() < SHADOW_DEMON_LIGHT_THRESHOLD)
			. += T
	if(length(.))
		return
	for(var/obj/effect/landmark/event_spawn/spawn_point as anything in GLOB.generic_event_spawns)
		var/turf/center = get_turf(spawn_point)
		if(!center || !is_station_level(center.z))
			continue
		for(var/turf/open/T in range(5, center))
			if(!isspaceturf(T) && !is_blocked_turf(T, TRUE) && T.get_lumcount() < SHADOW_DEMON_LIGHT_THRESHOLD)
				. += T

/// Tworzy demona ukrytego w cieniu na danym polu i daje mu gracza
/proc/create_shadow_demon(key, turf/spawn_loc, give_antag = TRUE)
	var/obj/effect/dummy/phased_mob/shadow_crawl/holder = new(spawn_loc)
	var/mob/living/simple_animal/shadow_demon/demon = new(holder)
	var/datum/mind/player_mind = new /datum/mind(key)
	player_mind.active = TRUE
	player_mind.transfer_to(demon)
	player_mind.assigned_role = ROLE_SHADOW_DEMON
	player_mind.special_role = ROLE_SHADOW_DEMON
	if(give_antag)
		player_mind.add_antag_datum(/datum/antagonist/shadow_demon)
	to_chat(demon, "<b>Jesteś ukryty w cieniu. Użyj cienistego pełzu na ciemnym polu, by się zmaterializować.</b>")
	SEND_SOUND(demon, sound('aquila/sound/shadowdemon/shadownode.ogg'))
	return demon
