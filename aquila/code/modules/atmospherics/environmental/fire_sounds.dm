// Atmospheric fire (hotspots) crackles with our fire sound where BeeStation #13283 plays its fire sounds.
// One crackle per FIRE_SOUND_CHUNK x FIRE_SOUND_CHUNK block of tiles at a time, so a big fire sounds big without playing a sound per tile.

#define FIRE_SOUND_CHUNK 5
/// Length of aquila/sound/effects/fire.ogg
#define FIRE_SOUND_INTERVAL (2 SECONDS)

GLOBAL_LIST_EMPTY(fire_sound_cooldowns)

/// Crackles at this turf unless another fire in the same block already did within FIRE_SOUND_INTERVAL
/proc/play_fire_crackle(turf/fire_turf, volume)
	if(!fire_turf)
		return
	var/block = "[round(fire_turf.x / FIRE_SOUND_CHUNK)],[round(fire_turf.y / FIRE_SOUND_CHUNK)],[fire_turf.z]"
	if(GLOB.fire_sound_cooldowns[block] > world.time)
		return
	GLOB.fire_sound_cooldowns[block] = world.time + FIRE_SOUND_INTERVAL
	playsound(fire_turf, 'aquila/sound/effects/fire.ogg', volume, TRUE)

/obj/effect/hotspot/Initialize(mapload, starting_volume, starting_temperature)
	. = ..()
	if(!mapload)
		play_fire_crackle(get_turf(src), 25) // the fire catching

/obj/effect/hotspot/process()
	. = ..()
	if(!QDELETED(src))
		play_fire_crackle(get_turf(src), 45)

#undef FIRE_SOUND_CHUNK
#undef FIRE_SOUND_INTERVAL
