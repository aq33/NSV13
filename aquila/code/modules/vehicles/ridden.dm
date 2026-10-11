// Engine sounds of ridden vehicles: a loop that runs while someone drives and fades out shortly after they stop

/datum/looping_sound/vehicle_pussywagon
	mid_sounds = list('aquila/sound/vehicles/pussywagon_loop.ogg' = 1)
	mid_length = 4.5 SECONDS
	volume = 30

/datum/looping_sound/vehicle_secway
	mid_sounds = list('aquila/sound/vehicles/secway_loop.ogg' = 1)
	mid_length = 3 SECONDS
	volume = 30

/obj/vehicle/ridden
	/// Type of the looping engine sound, null for silent vehicles
	var/drive_sound_type
	var/datum/looping_sound/drive_sound

/obj/vehicle/ridden/Moved(atom/OldLoc, Dir, Forced)
	. = ..()
	if(!drive_sound_type || Forced || !has_buckled_mobs())
		return
	if(!drive_sound)
		drive_sound = new drive_sound_type(src)
	drive_sound.start()
	addtimer(CALLBACK(src, PROC_REF(stop_drive_sound)), 1.5 SECONDS, TIMER_UNIQUE | TIMER_OVERRIDE)

/obj/vehicle/ridden/proc/stop_drive_sound()
	drive_sound?.stop()

/obj/vehicle/ridden/Destroy()
	QDEL_NULL(drive_sound)
	return ..()

/obj/vehicle/ridden/janicart
	drive_sound_type = /datum/looping_sound/vehicle_pussywagon

/obj/vehicle/ridden/secway
	drive_sound_type = /datum/looping_sound/vehicle_secway
