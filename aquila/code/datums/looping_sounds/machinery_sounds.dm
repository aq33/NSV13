/datum/looping_sound/generator
	volume = 15

/datum/looping_sound/grill
	volume = 20

/datum/looping_sound/microwave
	volume = 70

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

/datum/looping_sound/thermal
	mid_length = 2
	mid_sounds = list('aquila/sound/machines/thermal/thermal_mid.ogg'=1)
	volume = 10

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

/datum/looping_sound/computer
	start_sound = 'aquila/sound/machines/electronics/computer_start.ogg'
	start_length = 5
	mid_sounds = list('aquila/sound/machines/electronics/computer_mid1.ogg'=1, 'aquila/sound/machines/electronics/computer_mid2.ogg'=1, 'aquila/sound/machines/electronics/computer_mid3.ogg'=1, 'aquila/sound/machines/electronics/computer_mid4.ogg'=1, 'aquila/sound/machines/electronics/computer_mid5.ogg'=1)
	mid_length = 5
	end_sound = 'aquila/sound/machines/electronics/computer_stop.ogg'
	volume = 10

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

/datum/looping_sound/lathe
	start_sound = 'aquila/sound/machines/electronics/lathe_start.ogg'
	start_length = 2
	mid_sounds = list('aquila/sound/machines/electronics/lathe_idle.ogg'=10, 'aquila/sound/machines/electronics/lathe_working.ogg'=1, 'aquila/sound/machines/electronics/lathe_working2.ogg'=1, 'aquila/sound/machines/electronics/lathe_working3.ogg'=1, 'aquila/sound/machines/electronics/lathe_working4.ogg'=1)
	mid_length = 2
	end_sound = 'aquila/sound/machines/electronics/computer_stop.ogg'
	volume = 30
	extra_range = 1

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

/datum/looping_sound/smes
	start_sound = 'aquila/sound/machines/electronics/transformator_start.ogg'
	start_length = 2
	mid_sounds = list('aquila/sound/machines/electronics/transformator_mid.ogg'=1)
	mid_length = 2
	end_sound = 'aquila/sound/machines/electronics/transformator_stop.ogg'
	volume = 20

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

/datum/looping_sound/vent
	start_sound = 'aquila/sound/machines/thermal/vent_start.ogg'
	start_length = 1
	mid_sounds = list('aquila/sound/machines/thermal/vent_mid.ogg'=1)
	mid_length = 4
	end_sound = 'aquila/sound/machines/thermal/vent_stop.ogg'
	volume = 15

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Sound settings passed to playsound() (BeeStation has them on every loop)

/datum/looping_sound
	var/vary = FALSE
	var/falloff_exponent = SOUND_FALLOFF_EXPONENT
	var/falloff_distance = SOUND_DEFAULT_FALLOFF_DISTANCE
	var/ignore_walls = TRUE

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// BeeStation #14383 - telecommunications hub

/datum/looping_sound/server
	mid_sounds = list(
		'aquila/sound/machines/tcomms/tcomms_mid1.ogg' = 1,
		'aquila/sound/machines/tcomms/tcomms_mid2.ogg' = 1,
		'aquila/sound/machines/tcomms/tcomms_mid3.ogg' = 1,
		'aquila/sound/machines/tcomms/tcomms_mid4.ogg' = 1,
		'aquila/sound/machines/tcomms/tcomms_mid5.ogg' = 1,
		'aquila/sound/machines/tcomms/tcomms_mid6.ogg' = 1,
		'aquila/sound/machines/tcomms/tcomms_mid7.ogg' = 1,
	)
	mid_length = 1.8 SECONDS
	extra_range = -8
	falloff_distance = 3
	falloff_exponent = 5
	volume = 35
	ignore_walls = FALSE

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// BeeStation #14318 - gravity generator

/datum/looping_sound/grav_gen
	start_sound = 'aquila/sound/machines/grav_gen/grav_gen_start.ogg'
	start_length = 1 SECONDS
	mid_sounds = list(
		'aquila/sound/machines/grav_gen/grav_gen_mid1.ogg' = 12,
		'aquila/sound/machines/grav_gen/grav_gen_mid2.ogg' = 1,
	)
	mid_length = 1.1 SECONDS
	end_sound = 'aquila/sound/machines/grav_gen/grav_gen_end.ogg'
	extra_range = 8
	vary = TRUE
	volume = 70
	falloff_distance = 5
	falloff_exponent = 20

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// BeeStation #14436 - cryo cell

/datum/looping_sound/cryo_cell
	mid_sounds = list(
		'aquila/sound/machines/cryo/cryo_1.ogg' = 1,
		'aquila/sound/machines/cryo/cryo_2.ogg' = 1,
		'aquila/sound/machines/cryo/cryo_3.ogg' = 1,
		'aquila/sound/machines/cryo/cryo_4.ogg' = 1,
		'aquila/sound/machines/cryo/cryo_5.ogg' = 1,
		'aquila/sound/machines/cryo/cryo_6.ogg' = 1,
		'aquila/sound/machines/cryo/cryo_7.ogg' = 1,
		'aquila/sound/machines/cryo/cryo_8.ogg' = 1,
		'aquila/sound/machines/cryo/cryo_9.ogg' = 1,
		'aquila/sound/machines/cryo/cryo_10.ogg' = 1,
	)
	mid_length = 5 SECONDS
	volume = 30
