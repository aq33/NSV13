// AQUILA - Stray Cargo Pod (port of the tgstation event): a lost supply pod with a random cargo pack drops somewhere on the ship.
// The rare syndicate variant brings a crate of random uplink gear instead.

/datum/round_event_control/aquila_stray_cargo
	name = "Stray Cargo Pod"
	typepath = /datum/round_event/aquila_stray_cargo
	weight = 20
	max_occurrences = 4
	earliest_start = 10 MINUTES

/datum/round_event/aquila_stray_cargo
	announceWhen = 1
	/// Area the pod lands in, picked in setup()
	var/area/impact_area
	/// Turf the pod lands on, picked in setup() so the announced area always has room for it
	var/turf/landing_zone
	/// Supply packs the pod can carry, if empty any orderable cargo pack is used
	var/list/possible_pack_types = list()
	/// Cargo packs a stray pod may carry, filtered once from SSshuttle.supply_packs
	var/static/list/stray_spawnable_supply_packs

/datum/round_event/aquila_stray_cargo/setup()
	startWhen = rand(10, 20) // 20-40 seconds, like upstream
	if(!stray_spawnable_supply_packs)
		stray_spawnable_supply_packs = list()
		for(var/pack_type in SSshuttle.supply_packs)
			var/datum/supply_pack/pack = SSshuttle.supply_packs[pack_type]
			if(pack.special || pack.hidden || pack.dangerous || pack.admin_spawned)
				continue
			stray_spawnable_supply_packs += pack_type
	impact_area = find_event_area()
	landing_zone = get_landing_zone()
	if(!landing_zone) // kill() from setup() does not stop the event, New() re-adds it, so announce() and start() check this too
		log_game("Stray Cargo Pod: no area with free floor found, cancelling the event.")
		kill()

/datum/round_event/aquila_stray_cargo/announce(fake)
	if(fake)
		impact_area = find_event_area()
	else if(!landing_zone)
		return
	priority_announce("Skanery dalekiego zasięgu wykryły zabłąkaną kapsułę zaopatrzeniową. Przewidywane miejsce uderzenia: [impact_area?.name || "nieznane"].", "Ostrzeżenie przed kolizją")

/datum/round_event/aquila_stray_cargo/start()
	if(!landing_zone)
		return kill()
	if(is_blocked_turf(landing_zone, TRUE)) // something was built there in the meantime
		landing_zone = get_landing_zone() || landing_zone
	var/obj/structure/closet/supplypod/pod = new
	var/obj/container = get_contents()
	if(container)
		container.forceMove(pod)
	var/obj/effect/pod_landingzone/landing_marker = new(landing_zone, pod)
	announce_to_ghosts(landing_marker)

/// Picks a random free floor turf in the impact area
/datum/round_event/aquila_stray_cargo/proc/get_landing_zone()
	if(!impact_area)
		return null
	var/list/valid_turfs = list()
	for(var/turf/open/T in impact_area)
		if(isspaceturf(T) || is_blocked_turf(T, TRUE))
			continue
		valid_turfs += T
	if(!length(valid_turfs))
		return null
	return pick(valid_turfs)

/// Builds the crate that rides in the pod
/datum/round_event/aquila_stray_cargo/proc/get_contents()
	var/pack_type = length(possible_pack_types) ? pick(possible_pack_types) : pick(stray_spawnable_supply_packs)
	var/datum/supply_pack/pack = SSshuttle.supply_packs[pack_type]
	if(!pack)
		return null
	var/obj/structure/closet/crate/crate = pack.generate(null)
	if(istype(crate))
		crate.locked = FALSE // A stray pod has no one to deliver it to, so secure crates come unlocked
		crate.update_icon()
	return crate

/// Picks a station area with free floor where a pod impact cannot wreck anything vital
/datum/round_event/aquila_stray_cargo/proc/find_event_area()
	var/static/list/unsafe_area_types = typecacheof(list(
		/area/ai_monitored/turret_protected,
		/area/engine,
		/area/nsv/engine,
		/area/nsv/magazine,
		/area/nsv/weapons,
		/area/nsv/hanger,
		/area/nsv/shuttle,
		/area/nsv/boarding_pod,
		/area/shuttle,
	))
	var/static/list/safe_subtypes = typecacheof(list(/area/engine/break_room))
	var/list/possible_areas = list()
	for(var/area/A as anything in GLOB.sortedAreas)
		if(!(A.type in GLOB.the_station_areas))
			continue
		if(is_type_in_typecache(A, unsafe_area_types) && !is_type_in_typecache(A, safe_subtypes))
			continue
		possible_areas += A
	while(length(possible_areas))
		var/area/candidate = pick_n_take(possible_areas)
		for(var/turf/open/T in candidate)
			if(!isspaceturf(T) && !is_blocked_turf(T, TRUE))
				return candidate

/datum/round_event_control/aquila_stray_cargo/syndicate
	name = "Stray Syndicate Cargo Pod"
	typepath = /datum/round_event/aquila_stray_cargo/syndicate
	weight = 6
	max_occurrences = 1
	earliest_start = 30 MINUTES

/datum/round_event/aquila_stray_cargo/syndicate

/// Instead of a cargo pack, the syndicate pod carries 30 TC worth of random uplink items
/datum/round_event/aquila_stray_cargo/syndicate/get_contents()
	var/obj/structure/closet/crate/crate = new /obj/structure/closet/crate/internals
	crate.name = "skrzynia awaryjna"
	var/crate_value = 30
	var/list/uplink_items = get_uplink_items(UPLINK_TRAITORS)
	var/attempts = 0
	while(crate_value > 0 && attempts++ < 200)
		var/category = pick(uplink_items)
		var/datum/uplink_item/item = uplink_items[category][pick(uplink_items[category])]
		if(!item.surplus_nullcrates || prob(100 - item.surplus_nullcrates))
			continue
		if(crate_value < item.cost)
			continue
		crate_value -= item.cost
		new item.item(crate)
	message_admins("A stray syndicate cargo pod is landing in [impact_area].")
	log_game("A stray syndicate cargo pod is landing in [impact_area].")
	return crate
