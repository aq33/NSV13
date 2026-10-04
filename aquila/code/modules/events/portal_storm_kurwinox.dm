// AQUILA - Kurwinoxy z galaktyki Kurwix wypadają z portali (mobki z aq33/NSV13#304)
// Osobny event na mechanice Portal Storm; zwykłe Portal Storm i jego pula mobów zostają bez zmian.
// Kurwinoxy się nie rozmnażają i nie spawnią niczego, więc liczba mobów to dokładnie suma list poniżej.

/datum/round_event_control/portal_storm_kurwinox
	name = "Portal Storm: Kurwinoxy"
	typepath = /datum/round_event/portal_storm/kurwinox
	// połowa wagi zwykłego Portal Storm (10), raz na rundę, później i przy większej załodze niż on
	weight = 5
	min_players = 18
	earliest_start = 25 MINUTES
	max_occurrences = 1
	cannot_spawn_after_shuttlecall = TRUE

/datum/round_event/portal_storm/kurwinox
	boss_types = list(/mob/living/simple_animal/hostile/kurwinoxy/czerwony = 2)
	hostile_types = list(/mob/living/simple_animal/hostile/kurwinoxy = 8)
	/// No safe turf for a portal was found: nothing spawns and the event ends silently
	var/aborted = FALSE

// Same as the base setup, but portals only open on safe, breathable station floors.
// The base get_random_station_turf() can return walls, and loops forever if it returns nothing.
/datum/round_event/portal_storm/kurwinox/setup()
	storm = mutable_appearance('icons/obj/tesla_engine/energy_ball.dmi', "energy_ball_fast", FLY_LAYER)
	storm.color = "#00FF00"

	number_of_bosses = 0
	for(var/boss in boss_types)
		number_of_bosses += boss_types[boss]
	number_of_hostiles = 0
	for(var/hostile in hostile_types)
		number_of_hostiles += hostile_types[hostile]

	var/list/turfs = pick_spawn_turfs(number_of_bosses + number_of_hostiles)
	if(!length(turfs))
		abort()
		return
	// if fewer safe turfs than mobs were found, some portals open twice on the same spot
	for(var/i in 1 to number_of_hostiles)
		hostiles_spawn += turfs[(i - 1) % length(turfs) + 1]
	for(var/i in 1 to number_of_bosses)
		boss_spawn += turfs[(number_of_hostiles + i - 1) % length(turfs) + 1]

	next_boss_spawn = startWhen + CEILING(2 * number_of_hostiles / number_of_bosses, 1)

/datum/round_event/portal_storm/kurwinox/announce(fake)
	set waitfor = 0
	if(aborted)
		return
	sound_to_playing_players('sound/magic/lightning_chargeup.ogg')
	sleep(80)
	priority_announce("Wykryto potężną anomalię bluespace zmierzającą w stronę [station_name()]. Skanery rejestrują sygnatury biologiczne z galaktyki Kurwix. Przygotować się na kontakt.", "Alarm: Anomalia", SSstation.announcer.get_rand_alert_sound())
	sleep(20)
	sound_to_playing_players('sound/magic/lightningbolt.ogg')

/// Nothing to spawn: end on the first process() without announcing
/datum/round_event/portal_storm/kurwinox/proc/abort()
	aborted = TRUE
	hostile_types = list()
	boss_types = list()
	hostiles_spawn = list()
	boss_spawn = list()
	number_of_hostiles = 0
	number_of_bosses = 0
	announceChance = 0
	startWhen = 0
	announceWhen = 0
	endWhen = 0
	message_admins("Kurwinox portal storm found no safe station turf, nothing was spawned.")
	log_game("Kurwinox portal storm found no safe station turf, nothing was spawned.")

/// Up to amount distinct safe turfs for portals
/datum/round_event/portal_storm/kurwinox/proc/pick_spawn_turfs(amount)
	. = list()
	// extra picks so turfs without breathable air can be thrown away
	for(var/turf/T as anything in get_safe_random_station_turfs(candidate_areas(), amount * 4))
		if(length(.) >= amount)
			break
		if(valid_turf(T))
			. += T

/// Areas the portals may open in
/datum/round_event/portal_storm/kurwinox/proc/candidate_areas()
	return GLOB.the_station_areas

/// A station floor a Kurwinox can stand and breathe on
/datum/round_event/portal_storm/kurwinox/proc/valid_turf(turf/T)
	if(!T || !is_station_level(T.z))
		return FALSE
	var/area/A = get_area(T)
	if(!(A.area_flags & VALID_TERRITORY))
		return FALSE
	return !is_blocked_turf(T) && is_turf_safe(T)
