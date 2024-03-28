/datum/round_event_control/kapitanbomba
	name = "Spawn Kapitanbomba"
	typepath = /datum/round_event/ghost_role/kapitanbomba
	weight			= 10
	max_occurrences = 1
	min_players = 8
	earliest_start = 25 MINUTES //Dobra szansa że do tej pory na akwili nikt nie umrze (Powietrze jeszcze nie zostało podgrzane)
	gamemode_blacklist = list("nuclear")
	cannot_spawn_after_shuttlecall = TRUE

/datum/round_event/ghost_role/kapitanbomba
	minimum_required = 1
	role_name = "kapitanbomba"
	fakeable = FALSE
	var/portale = 21

/datum/round_event/ghost_role/kapitanbomba/spawn_role()
	for(var/i = 1, i <= portale, i++)
		var/turf/T = get_random_station_turf()	//side effect - wormholes won't spawn in space
		if(istype(T.loc, /area/engine))
			i--;
		else
			if(prob(5))
				new /obj/structure/spawner/clowiekmaupa(T)
			else
				new /obj/structure/spawner/kurwinoxy(T)
	var/list/possible_spawns = list()//Some xeno spawns are in some spots that will instantly kill the refugees, like atmos
	for(var/turf/X in GLOB.xeno_spawn)
		if(istype(X.loc, /area/maintenance))
			possible_spawns += X
	if(!possible_spawns.len)
		message_admins("No valid spawn locations found, aborting...")
		return MAP_ERROR
	var/turf/landing_turf = pick(possible_spawns)
	var/list/candidates = get_candidates(ROLE_TRAITOR, /datum/role_preference/midround_ghost/kapitanbomba)
	if(!candidates.len >= 1) //solo refugees
		return NOT_ENOUGH_PLAYERS

	var/member_size = 1
	var/list/members = list()
	var/list/spawned_mobs = list()

	for(var/i in 1 to member_size)
		members += pick_n_take(candidates)

	for(var/mob/dead/selected in members)
		var/mob/living/carbon/human/S = gear_kapitanbomba(selected, landing_turf)
		spawned_mobs += S

//after spawning
	playsound(src, 'sound/weapons/emitter.ogg', 50, 1)
	new /obj/item/storage/toolbox/mechanical(landing_turf) //so they can actually escape maint
	return SUCCESSFUL_SPAWN

/datum/round_event/ghost_role/kapitanbomba/proc/gear_kapitanbomba(var/mob/dead/selected, var/turf/landing_turf) //spawns normal kapitanbomba
	var/datum/mind/player_mind = new /datum/mind(selected.key)
	player_mind.active = TRUE
	var/mob/living/carbon/human/S = new(landing_turf)
	player_mind.transfer_to(S)
	player_mind.assigned_role = "Kapitanbomba"
	player_mind.special_role = "Kapitanbomba"
	player_mind.add_antag_datum(/datum/antagonist/kapitanbomba)
	var/datum/antagonist/kapitanbomba/kapitanbombaantag = player_mind.has_antag_datum(/datum/antagonist/kapitanbomba)
	INVOKE_ASYNC(kapitanbombaantag, TYPE_PROC_REF(/datum/antagonist/kapitanbomba, greet)) //some kapitanbomba have a sleep on their greet, so we don't want to stop the entire antag granting proc with fluff
	S.equipOutfit(/datum/outfit/kapitanbomba)
	message_admins("[ADMIN_LOOKUPFLW(S)] has been made into a Kapitanbomba by an event.")
	log_game("[key_name(S)] was spawned as a Kapitanbomba by an event.")
	spawned_mobs += S
	return S
