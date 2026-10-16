#define SPAWN_ALWAYS 100
#define SPAWN_LIKELY 85
#define SPAWN_UNLIKELY 35
#define SPAWN_RARE 10


/// Handles spawning mobs for this landmark. Sends a signal when done.
/obj/effect/landmark/bitrunning/mob_segment/proc/spawn_mobs(turf/origin, datum/modular_mob_segment/segment)
	var/list/mob/living/spawned_mobs = list()

	spawned_mobs += segment.spawn_mobs(origin)

	SEND_SIGNAL(src, COMSIG_BITRUNNING_MOB_SEGMENT_SPAWNED, spawned_mobs)

	var/list/datum/weakref/mob_refs = list()
	for(var/mob/living/spawned as anything in spawned_mobs)
		if(QDELETED(spawned))
			continue

		mob_refs += WEAKREF(spawned)

	return mob_refs


/**
 * A list for mob spawning landmarks to use.
 */
/datum/modular_mob_segment
	/// Set this to false if you want explicitly what's in the list to spawn
	var/exact = FALSE
	/// The list of mobs to spawn
	var/list/mobs = list()
	/// Spawn no more than this amount
	var/max = 4
	/// Chance this will spawn (1 - 100)
	var/probability = SPAWN_LIKELY


/// Spawns mobs in a circle around the location
/datum/modular_mob_segment/proc/spawn_mobs(turf/origin)
	if(!prob(probability))
		return list()

	var/list/mob/living/spawned_mobs = list()

	var/total_amount = exact ? length(mobs) : rand(1, max)

	shuffle_inplace(mobs)

	var/list/turf/nearby = list()
	for(var/turf/tile as anything in RANGE_TURFS(2, origin))
		if(!is_blocked_turf(tile))
			nearby += tile

	if(!length(nearby))
		stack_trace("Couldn't find any valid turfs to spawn on")
		return list()

	for(var/index in 1 to total_amount)
		if(!length(nearby))
			break
		// For each of those, we need to find an open space
		var/turf/destination = pick(nearby)

		var/path // Either a random mob or the next mob in the list
		if(exact)
			path = mobs[index]
		else
			path = pick(mobs)

		var/mob/living/mob = new path(destination)
		nearby -= destination
		spawned_mobs += mob

	return spawned_mobs


// Some generic mob segments. If you want to add generic ones for any map, add them here

/datum/modular_mob_segment/gondolas
	mobs = list(
		/mob/living/simple_animal/pet/gondola,
	)


/datum/modular_mob_segment/corgis
	max = 2
	mobs = list(
		/mob/living/simple_animal/pet/dog/corgi,
	)


/datum/modular_mob_segment/monkeys
	mobs = list(
		/mob/living/carbon/monkey,
	)


/datum/modular_mob_segment/syndicate_team
	mobs = list(
		/mob/living/carbon/human/ai_boarder/syndicate/pistol,
		/mob/living/carbon/human/ai_boarder/syndicate/smg,
		/mob/living/carbon/human/ai_boarder/syndicate/shotgun,
	)


/datum/modular_mob_segment/abductor_agents
	mobs = list(
		/mob/living/carbon/human/ai_boarder/abductor/melee,
		/mob/living/carbon/human/ai_boarder/abductor/ranged,
	)


/datum/modular_mob_segment/syndicate_elite
	mobs = list(
		/mob/living/simple_animal/hostile/syndicate/melee/sword/space/stormtrooper,
		/mob/living/simple_animal/hostile/syndicate/ranged/space/stormtrooper,
	)


/datum/modular_mob_segment/bears
	max = 2
	mobs = list(
		/mob/living/simple_animal/hostile/bear,
	)


/datum/modular_mob_segment/bees
	exact = TRUE
	mobs = list(
		/mob/living/simple_animal/hostile/poison/bees,
		/mob/living/simple_animal/hostile/poison/bees,
		/mob/living/simple_animal/hostile/poison/bees,
		/mob/living/simple_animal/hostile/poison/bees,
		/mob/living/simple_animal/hostile/poison/bees/queen,
	)


/datum/modular_mob_segment/bees_toxic
	mobs = list(
		/mob/living/simple_animal/hostile/poison/bees/toxin,
	)


/datum/modular_mob_segment/blob_spores
	mobs = list(
		/mob/living/simple_animal/hostile/blob/blobspore,
	)


/datum/modular_mob_segment/carps
	mobs = list(
		/mob/living/simple_animal/hostile/carp,
	)


/datum/modular_mob_segment/hivebots
	mobs = list(
		/mob/living/simple_animal/hostile/hivebot,
		/mob/living/simple_animal/hostile/hivebot/range,
	)


/datum/modular_mob_segment/hivebots_strong
	mobs = list(
		/mob/living/simple_animal/hostile/hivebot/strong,
		/mob/living/simple_animal/hostile/hivebot/range,
	)


/datum/modular_mob_segment/lavaland_assorted
	mobs = list(
		/mob/living/simple_animal/hostile/asteroid/basilisk/watcher,
		/mob/living/simple_animal/hostile/asteroid/goliath/beast,
		/mob/living/simple_animal/hostile/asteroid/hivelord/legion,
	)


/datum/modular_mob_segment/spiders
	mobs = list(
		/mob/living/simple_animal/hostile/spider/giant/ambush,
		/mob/living/simple_animal/hostile/spider/giant/hunter,
		/mob/living/simple_animal/hostile/spider/giant/nurse,
		/mob/living/simple_animal/hostile/spider/giant/tangle,
		/mob/living/simple_animal/hostile/spider/giant/midwife,
	)


/datum/modular_mob_segment/venus_trap
	mobs = list(
		/mob/living/simple_animal/hostile/venus_human_trap,
	)


/datum/modular_mob_segment/xenos
	mobs = list(
		/mob/living/simple_animal/hostile/alien,
		/mob/living/simple_animal/hostile/alien/sentinel,
		/mob/living/simple_animal/hostile/alien/drone,
	)


/datum/modular_mob_segment/deer
	max = 1
	mobs = list(
		/mob/living/simple_animal/deer,
	)


/datum/modular_mob_segment/revolutionary
	mobs = list(
		/mob/living/carbon/human/ai_boarder/revolutionary,
	)


#undef SPAWN_ALWAYS
#undef SPAWN_LIKELY
#undef SPAWN_UNLIKELY
#undef SPAWN_RARE
