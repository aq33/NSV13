// Engine sounds of ridden vehicles: the engine plays on the vehicle's own sound channel while someone drives,
// so it can be cut off as soon as the vehicle stops instead of finishing the whole recording.

/obj/vehicle/ridden
	/// Looping engine sound, null for silent vehicles
	var/drive_sound
	/// Length of drive_sound, the loop restarts after it
	var/drive_sound_length
	var/drive_sound_volume = 60
	/// Channel reserved for the engine on first drive
	var/drive_channel
	var/drive_loop_timer
	var/driving = FALSE

/obj/vehicle/ridden/Moved(atom/OldLoc, Dir, Forced)
	. = ..()
	if(!drive_sound || Forced || !has_buckled_mobs())
		return
	if(!driving)
		start_drive_sound()
	addtimer(CALLBACK(src, PROC_REF(stop_drive_sound)), 0.8 SECONDS, TIMER_UNIQUE | TIMER_OVERRIDE)

/obj/vehicle/ridden/proc/start_drive_sound()
	if(!drive_channel)
		drive_channel = SSsounds.reserve_sound_channel(src)
		if(!drive_channel)
			return
	driving = TRUE
	play_drive_sound()

/obj/vehicle/ridden/proc/play_drive_sound()
	if(!driving || QDELETED(src))
		return
	// A new sound on the same channel replaces the old one, so this also moves the engine to where the vehicle is now
	playsound(src, drive_sound, drive_sound_volume, FALSE, -2, channel = drive_channel)
	drive_loop_timer = addtimer(CALLBACK(src, PROC_REF(play_drive_sound)), drive_sound_length, TIMER_STOPPABLE)

/obj/vehicle/ridden/proc/stop_drive_sound()
	if(!driving)
		return
	driving = FALSE
	deltimer(drive_loop_timer)
	drive_loop_timer = null
	var/turf/our_turf = get_turf(src)
	if(!our_turf || !drive_channel)
		return
	var/sound/silence = sound(null, channel = drive_channel)
	for(var/z in get_zs_in_range(our_turf.z, 1))
		for(var/mob/listener as anything in SSmobs.clients_by_zlevel[z])
			if(get_dist(listener, our_turf) <= SOUND_RANGE + 2)
				SEND_SOUND(listener, silence)

/obj/vehicle/ridden/Destroy()
	stop_drive_sound()
	return ..()

/obj/vehicle/ridden/janicart
	drive_sound = 'aquila/sound/vehicles/pussywagon_loop.ogg'
	drive_sound_length = 2.6 SECONDS

/obj/vehicle/ridden/secway
	drive_sound = 'aquila/sound/vehicles/secway_loop.ogg'
	drive_sound_length = 1.5 SECONDS
	drive_sound_volume = 50
