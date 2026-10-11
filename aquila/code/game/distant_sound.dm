// Distant sounds: past the normal sound range a sound can still be heard as a dull, quieter echo from its direction.
// Walls, windows and closed doors in the way (sound_dampening) make it quieter still.

/**
 * Plays a muffled copy of the sound to everyone between SOUND_RANGE and max_range tiles away.
 * Listeners closer than that already hear the normal sound from playsound().
 */
/proc/play_distant_sound(atom/source, soundin, volume, max_range = DISTANT_GUNSHOT_RANGE)
	var/turf/source_turf = get_turf(source)
	if(!source_turf || !soundin)
		return
	var/datum/gas_mixture/source_air = source_turf.return_air()
	if(!source_air || source_air.return_pressure() < SOUND_MINIMUM_PRESSURE)
		return // nothing carries it in a vacuum

	var/sound_file = get_sfx(soundin)
	var/list/listeners = list()
	for(var/z in get_zs_in_range(source_turf.z, 1))
		listeners += SSmobs.clients_by_zlevel[z]
	for(var/mob/listener as anything in listeners)
		var/turf/listener_turf = get_turf(listener)
		if(!listener_turf || !listener.can_hear())
			continue
		var/distance = get_dist(listener_turf, source_turf) + abs(listener_turf.z - source_turf.z) * MULTI_Z_DISTANCE
		if(distance <= SOUND_RANGE || distance > max_range)
			continue
		var/datum/gas_mixture/listener_air = listener_turf.return_air()
		if(!listener_air || listener_air.return_pressure() < SOUND_MINIMUM_PRESSURE)
			continue
		var/falloff = 1 - (distance - SOUND_RANGE) / (max_range - SOUND_RANGE)
		var/dampening = listener_turf.z == source_turf.z ? min(distant_sound_dampening(source_turf, listener_turf), 0.8) : 0.5
		var/listener_volume = volume * falloff * (1 - dampening)
		if(listener_volume < 3)
			continue

		var/sound/echo = sound(sound_file)
		echo.volume = listener_volume
		echo.channel = SSsounds.random_available_channel()
		echo.frequency = rand(88, 96) / 100 // a little deeper, as from far away
		echo.echo = get_distant_sound_echo()
		// Only the direction matters here, the volume is already set
		var/dx = source_turf.x - listener_turf.x
		var/dy = source_turf.y - listener_turf.y
		var/length = max(sqrt(dx * dx + dy * dy), 1)
		echo.x = dx / length * 2
		echo.z = dy / length * 2
		echo.y = 1
		echo.falloff = 2
		var/area/listener_area = get_area(listener_turf)
		echo.environment = listener_area ? listener_area.sound_environment : SOUND_ENVIRONMENT_NONE
		SEND_SOUND(listener, echo)

/// Sum of the sound_dampening of everything on the line between two turfs, up to 1
/proc/distant_sound_dampening(turf/source_turf, turf/listener_turf)
	. = 0
	for(var/turf/line_turf as anything in getline(source_turf, listener_turf))
		if(line_turf == source_turf)
			continue
		. += line_turf.get_sound_dampening()
		for(var/obj/O in line_turf)
			if(O.sound_dampening)
				. += O.get_sound_dampening()
		if(. >= 1)
			return 1

/proc/get_distant_sound_echo()
	var/static/list/distant_echo = list(
		0, // Direct
		DISTANT_SOUND_DIRECT_HF, // DirectHF
		0, // Room
		0, // RoomHF
		0, // Obstruction
		0, // ObstructionLFRatio
		0, // Occlusion
		0.25, // OcclusionLFRatio
		1.5, // OcclusionRoomRatio
		1.0, // OcclusionDirectRatio
		0, // Exclusion
		1.0, // ExclusionLFRatio
		0, // OutsideVolumeHF
		0, // DopplerFactor
		0, // RolloffFactor
		0, // RoomRolloffFactor
		1.0, // AirAbsorptionFactor
		0, // Flags
	)
	return distant_echo.Copy()

/obj/item/gun
	/// Last time this gun sent a distant echo, so automatic fire does not flood far listeners
	var/last_distant_shot = 0

/obj/item/gun/shoot_live_shot(mob/living/user, pointblank = 0, atom/pbtarget = null, message = 1)
	. = ..()
	if(suppressed || !fire_sound || world.time < last_distant_shot + 0.3 SECONDS)
		return
	last_distant_shot = world.time
	play_distant_sound(src, fire_sound, fire_sound_volume)
