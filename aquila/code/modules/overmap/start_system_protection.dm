/// AQUILA - Keeps the players' starting system from coming back occupied after a restart.
/// A fleet sitting in a system sets its alignment; the save used to persist that, and on load a "syndicate" aligned system spawns
/// a Syndicate fleet 15 seconds in (apply_system_effects()), which then got saved as occupied again on every restart.
/// See also the save() edit in nsv13/code/controllers/subsystem/starsystem.dm, which stops occupations being saved at all.

/// Used before the overmap mode is picked; every overmap mode starts the players here
#define DEFAULT_PLAYER_START_SYSTEM "Argo"

/// The name of the system the players start in
/datum/controller/subsystem/star_system/proc/player_start_system_name()
	return SSovermap_mode?.mode?.starting_system || DEFAULT_PLAYER_START_SYSTEM

/// Puts the starting system back under its owner if it was loaded occupied with no fleet in it. Returns TRUE if it changed anything.
/datum/controller/subsystem/star_system/proc/clear_start_system_occupation(datum/star_system/S)
	if(!S || S.name != player_start_system_name())
		return FALSE
	if(length(S.fleets) || S.alignment == S.owner)
		return FALSE
	log_game("Starting system [S.name] was loaded occupied by [S.alignment] with no fleet in it; restoring it to its owner [S.owner].")
	S.alignment = S.owner
	return TRUE

/datum/controller/subsystem/star_system/instantiate_systems(_source_path = SSmapping.config.starmap_path)
	. = ..()
	// Before generate_anomaly() fires and before the first send_fleet(), both of which go by alignment
	clear_start_system_occupation(system_by_id(player_start_system_name()))

/// The hardcoded fallback systems only set alignment, leaving owner at "unaligned"; since save() writes owner for systems with fleets,
/// a save after a fallback load would have turned them all unaligned. Give them the owner their alignment implies.
/datum/controller/subsystem/star_system/instantiate_systems_backup()
	. = ..()
	assign_owners_from_alignment(systems)

/// Systems still on the default owner take the owner their alignment implies
/datum/controller/subsystem/star_system/proc/assign_owners_from_alignment(list/systems_to_fix)
	for(var/datum/star_system/S as anything in systems_to_fix)
		if(S.owner == "unaligned" && S.alignment != "unaligned" && S.alignment != "random") // "random" picks both later
			S.owner = S.alignment

#undef DEFAULT_PLAYER_START_SYSTEM
