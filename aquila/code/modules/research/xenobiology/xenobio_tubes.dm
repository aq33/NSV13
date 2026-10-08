// AQUILA - port tgstation/tgstation#90775: konsola ksenobiologii wciąga i wypluwa szlamy, małpy i mikstury rurą zamiast teleportacji
// Szlamy obsługujemy w Entered()/Exited(), bo w core ich przenoszenie jest powielone w kilku miejscach. Małpy i mikstury mają hooki AQ EDIT w xenobio_camera.dm.

#define SUCTION_DELAY 1
#define SUCTION_TIME 2

/obj/machinery/computer/camera_advanced/xenobio
	/// The HUD for this console
	var/atom/movable/screen/xenobio_console/xeno_hud
	/// The potion shown on the HUD, to only animate it when it changes
	var/datum/weakref/hud_potion_ref
	/// The turf and time of the last tube effect, so several slimes spat out at once share one tube
	var/turf/last_tube_turf
	var/last_tube_time

/obj/machinery/computer/camera_advanced/xenobio/Initialize(mapload)
	. = ..()
	get_xeno_hud()

/obj/machinery/computer/camera_advanced/xenobio/Destroy()
	last_tube_turf = null
	remove_xeno_hud(current_user)
	QDEL_NULL(xeno_hud)
	return ..()

/obj/machinery/computer/camera_advanced/xenobio/GrantActions(mob/living/user)
	..()
	if(!user.hud_used)
		return
	user.hud_used.static_inventory |= get_xeno_hud()
	user.hud_used.show_hud(user.hud_used.hud_version)

/obj/machinery/computer/camera_advanced/xenobio/remove_eye_control(mob/living/user)
	remove_xeno_hud(user)
	..()

/obj/machinery/computer/camera_advanced/xenobio/proc/remove_xeno_hud(mob/living/user)
	if(!user?.hud_used || !xeno_hud || !(xeno_hud in user.hud_used.static_inventory))
		return
	user.hud_used.static_inventory -= xeno_hud
	user.hud_used.show_hud(user.hud_used.hud_version)

/obj/machinery/computer/camera_advanced/xenobio/attackby(obj/item/O, mob/user, params)
	. = ..()
	update_xeno_hud()
	update_xeno_potion()

/obj/machinery/computer/camera_advanced/xenobio/on_contents_del(datum/source, atom/deleted)
	..()
	update_xeno_hud()
	update_xeno_potion()

/obj/machinery/computer/camera_advanced/xenobio/Entered(atom/movable/arrived, atom/old_loc, list/atom/old_locs)
	. = ..()
	if(!isslime(arrived))
		return
	update_xeno_hud()
	if(isturf(old_loc))
		suck_up(arrived, old_loc)

/obj/machinery/computer/camera_advanced/xenobio/Exited(atom/movable/gone, direction)
	. = ..()
	if(!isslime(gone) || QDELETED(src))
		return
	update_xeno_hud()
	if(isturf(gone.loc))
		spit_out(gone, gone.loc)

/// Returns the HUD, remaking it if a mob's HUD deleted it along with its static inventory
/obj/machinery/computer/camera_advanced/xenobio/proc/get_xeno_hud()
	RETURN_TYPE(/atom/movable/screen/xenobio_console)
	if(QDELETED(xeno_hud))
		xeno_hud = new
		hud_potion_ref = null
		xeno_hud.on_update_hud(count_stored_slimes(), monkeys, max_slimes)
	return xeno_hud

/obj/machinery/computer/camera_advanced/xenobio/proc/count_stored_slimes()
	. = 0
	for(var/mob/living/simple_animal/slime/stored_slime in contents)
		if(!QDELETED(stored_slime))
			.++

/obj/machinery/computer/camera_advanced/xenobio/proc/update_xeno_hud()
	if(QDELETED(src))
		return
	get_xeno_hud().on_update_hud(count_stored_slimes(), monkeys, max_slimes)

/obj/machinery/computer/camera_advanced/xenobio/proc/update_xeno_potion()
	if(QDELETED(src))
		return
	var/obj/item/slimepotion/slime/potion = QDELETED(current_potion) ? null : current_potion
	if(potion == hud_potion_ref?.resolve())
		return
	hud_potion_ref = potion ? WEAKREF(potion) : null
	get_xeno_hud().update_potion(potion)

/// Hook: a monkey cube was turned into a monkey on the target turf
/obj/machinery/computer/camera_advanced/xenobio/proc/aquila_monkey_spat(mob/living/food)
	spit_out(food, get_turf(food))
	update_xeno_hud()

/// Hook: a dead monkey is about to be recycled
/obj/machinery/computer/camera_advanced/xenobio/proc/aquila_monkey_sucked(mob/living/target_mob)
	suck_up(target_mob, get_turf(target_mob))
	update_xeno_hud()

/// Hook: the loaded potion is about to be used on the target turf
/obj/machinery/computer/camera_advanced/xenobio/proc/aquila_potion_spat(turf/target_turf)
	spit_atom(current_potion, target_turf)

/// Shows the target being sucked up into the tube from the given turf. Called once it's already out of view (moved or about to be deleted)
/obj/machinery/computer/camera_advanced/xenobio/proc/suck_up(atom/movable/target, turf/from_turf)
	if(isnull(target) || isnull(from_turf))
		return
	new /obj/effect/abstract/xenosuction(from_turf)
	new /obj/effect/abstract/sucked_atom(from_turf, target, TRUE)
	addtimer(CALLBACK(src, PROC_REF(handle_xeno_sounds), from_turf, FALSE), SUCTION_DELAY)

/// Shoots the target mob out of the console
/obj/machinery/computer/camera_advanced/xenobio/proc/spit_out(mob/living/shot_mob, turf/target_turf)
	if(isnull(shot_mob) || isnull(target_turf))
		return
	if(last_tube_turf != target_turf || last_tube_time != world.time)
		last_tube_turf = target_turf
		last_tube_time = world.time
		new /obj/effect/abstract/xenosuction(target_turf)
		addtimer(CALLBACK(src, PROC_REF(handle_xeno_sounds), target_turf, TRUE), SUCTION_DELAY)
	new /obj/effect/abstract/sucked_atom(target_turf, shot_mob, FALSE)
	/// Make the mob invisible so it doesn't get seen during the animation
	if(shot_mob.invisibility < INVISIBILITY_MAXIMUM)
		var/old_invisibility = shot_mob.invisibility
		shot_mob.invisibility = INVISIBILITY_MAXIMUM
		addtimer(CALLBACK(src, PROC_REF(restore_visibility), shot_mob, old_invisibility), SUCTION_DELAY + SUCTION_TIME)

/obj/machinery/computer/camera_advanced/xenobio/proc/restore_visibility(atom/movable/hidden, old_invisibility)
	if(!QDELETED(hidden) && hidden.invisibility == INVISIBILITY_MAXIMUM)
		hidden.invisibility = old_invisibility

/// Shoots the target atom out of the tube. Used for anything that isn't a mob (I.e. potions)
/obj/machinery/computer/camera_advanced/xenobio/proc/spit_atom(atom/movable/target_atom, turf/target_turf)
	if(isnull(target_atom) || isnull(target_turf))
		return
	new /obj/effect/abstract/xenosuction(target_turf)
	var/ispot = istype(target_atom, /obj/item/slimepotion/slime)
	new /obj/effect/abstract/sucked_atom(target_turf, target_atom, FALSE, ispot)
	addtimer(CALLBACK(src, PROC_REF(handle_xeno_sounds), target_turf, TRUE), SUCTION_DELAY)
	if(ispot)
		addtimer(CALLBACK(src, PROC_REF(handle_shatter_sound), target_turf), SUCTION_DELAY + SUCTION_TIME)

///Plays the sound in the given location. Easier to call w/ addtimer()
/obj/machinery/computer/camera_advanced/xenobio/proc/handle_xeno_sounds(turf/target_turf, spitting)
	var/tubesound = 'aquila/sound/effects/compressed_air/air_suck.ogg'
	if(spitting)
		tubesound = 'aquila/sound/effects/compressed_air/air_shoot.ogg'
	playsound(target_turf, tubesound, 50, TRUE, SHORT_RANGE_SOUND_EXTRARANGE)

///The sound that plays when a potion shatters. Easier to call w/ addtimer()
/obj/machinery/computer/camera_advanced/xenobio/proc/handle_shatter_sound(turf/target_turf)
	playsound(target_turf, "shatter", 35, TRUE, MEDIUM_RANGE_SOUND_EXTRARANGE)

/// An abstract effect to simulate sucking the atom up or spitting it out
/obj/effect/abstract/sucked_atom
	layer = MOB_LAYER
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	/// The initial alpha of the atom, because slimes can be semi-transparent
	var/mob_initial_alpha = 255

/obj/effect/abstract/sucked_atom/Initialize(mapload, atom/movable/copying, sucking = FALSE, shatter = FALSE)
	. = ..()
	if(!ismovable(copying))
		return INITIALIZE_HINT_QDEL
	appearance = copying.appearance
	mob_initial_alpha = copying.alpha
	layer = MOB_LAYER
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	invisibility = 0
	if(sucking)
		suck_up()
	else
		pixel_y = 64
		alpha = 0
		shoot_out(shatter)

/// Shoots the mob visual upwards into the pipe then deletes it
/obj/effect/abstract/sucked_atom/proc/suck_up()
	QDEL_IN(src, SUCTION_DELAY + SUCTION_TIME)
	animate(src, time = SUCTION_DELAY)
	animate(time = SUCTION_TIME, easing = CUBIC_EASING | EASE_IN, pixel_y = 64, alpha = 0)

/// Shoots the mob visual out then deletes it
/obj/effect/abstract/sucked_atom/proc/shoot_out(shatter)
	QDEL_IN(src, SUCTION_DELAY + SUCTION_TIME)
	animate(src, time = SUCTION_DELAY, flags = ANIMATION_PARALLEL)
	animate(time = SUCTION_TIME, easing = (shatter ? LINEAR_EASING : BOUNCE_EASING), pixel_y = 0, flags = ANIMATION_PARALLEL)

	animate(src, time = SUCTION_DELAY, flags = ANIMATION_PARALLEL)
	animate(time = SUCTION_TIME, easing = CUBIC_EASING | EASE_OUT, alpha = mob_initial_alpha, flags = ANIMATION_PARALLEL)

/// The tube that sucks up/spits out the mob
/obj/effect/abstract/xenosuction
	icon = 'aquila/icons/effects/xenobio_tubes.dmi'
	icon_state = "xenotube_back"
	layer = BELOW_MOB_LAYER
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	pixel_y = 48
	alpha = 0

/obj/effect/abstract/xenosuction/Initialize(mapload)
	. = ..()
	add_overlay(mutable_appearance(icon, "xenotube_fore", ABOVE_MOB_LAYER))
	QDEL_IN(src, SUCTION_DELAY * 2 + SUCTION_TIME)
	animate(src, time = SUCTION_DELAY, alpha = 255, pixel_y = 32)
	animate(time = SUCTION_TIME)
	animate(time = SUCTION_DELAY, alpha = 0, pixel_y = 48)

#undef SUCTION_TIME
#undef SUCTION_DELAY
