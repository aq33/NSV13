// Teren i bossowie domen, których nie było u nas: urwiska z tg i Wendigo.

/**
 * Urwisko (tg /turf/open/cliff). Kto na nie wejdzie z góry, zjeżdża w dół aż do końca stoku.
 * tg ma do tego osobny subsystem i bitmask smoothing; u nas zjazd to prosta pętla, a wygląd liczymy przy Initialize.
 */
/turf/open/cliff
	name = "urwisko"
	desc = "Strome zbocze. Lepiej nie wchodzić na nie od góry."
	icon = 'aquila/icons/turf/cliff.dmi'
	icon_state = "icerock_wall-0"
	density = TRUE
	baseturfs = /turf/open/cliff
	/// Skąd trzeba przyjść, żeby spaść
	var/can_fall_from_direction = NORTH
	/// W którą stronę spadamy
	var/fall_direction = SOUTH
	/// Czas jednego kroku zjazdu
	var/fall_speed = 0.2 SECONDS
	/// Bazowa nazwa stanów ikony (bitmask)
	var/smooth_base_state = "icerock_wall"
	/// Turf rysowany pod spodem (krawędzie urwiska są półprzezroczyste)
	var/turf/underlay_tile = /turf/open/floor/plating/asteroid/snow
	/// Kto już zjeżdża
	var/static/list/falling = list()

/turf/open/cliff/Initialize(mapload)
	. = ..()
	if(underlay_tile)
		var/image/underlay = image(icon = initial(underlay_tile.icon), icon_state = initial(underlay_tile.icon_state))
		underlay.pixel_x = 4
		underlay.pixel_y = 4
		underlays += underlay
	return INITIALIZE_HINT_LATELOAD

/turf/open/cliff/LateInitialize()
	update_cliff_smoothing()

/// Bitmask jak w tg: N=1 S=2 E=4 W=8, NE=16 SE=32 SW=64 NW=128 (skos tylko gdy oba sąsiednie boki są urwiskiem)
/turf/open/cliff/proc/update_cliff_smoothing()
	var/junction = 0
	if(is_cliff_neighbor(NORTH))
		junction |= 1
	if(is_cliff_neighbor(SOUTH))
		junction |= 2
	if(is_cliff_neighbor(EAST))
		junction |= 4
	if(is_cliff_neighbor(WEST))
		junction |= 8
	if((junction & 1) && (junction & 4) && is_cliff_neighbor(NORTHEAST))
		junction |= 16
	if((junction & 2) && (junction & 4) && is_cliff_neighbor(SOUTHEAST))
		junction |= 32
	if((junction & 2) && (junction & 8) && is_cliff_neighbor(SOUTHWEST))
		junction |= 64
	if((junction & 1) && (junction & 8) && is_cliff_neighbor(NORTHWEST))
		junction |= 128
	icon_state = "[smooth_base_state]-[junction]"

/turf/open/cliff/proc/is_cliff_neighbor(direction)
	var/turf/neighbor = get_step(src, direction)
	if(!neighbor)
		return TRUE // krawędź mapy liczymy jako urwisko (tg SMOOTH_BORDER)
	return istype(neighbor, /turf/open/cliff)

/turf/open/cliff/CanAllowThrough(atom/movable/mover, turf/target)
	. = ..()
	if(!can_fall(mover))
		return TRUE
	// wejść da się tylko od strony, z której się spada
	if(get_dir(src, mover) & can_fall_from_direction)
		return TRUE
	return FALSE

/turf/open/cliff/Entered(atom/movable/arrived, atom/old_loc)
	. = ..()
	if(can_fall(arrived))
		INVOKE_ASYNC(src, PROC_REF(start_falling), arrived)

/turf/open/cliff/proc/can_fall(atom/movable/arrived)
	if(isnull(arrived) || arrived.anchored || arrived.throwing)
		return FALSE
	if(iseffect(arrived) || isobserver(arrived) || istype(arrived, /obj/item/projectile))
		return FALSE
	if(arrived.movement_type & (FLYING|FLOATING))
		return FALSE
	if(arrived in falling)
		return FALSE
	if(!arrived.has_gravity(src))
		return FALSE
	return TRUE

/// Zjazd w dół zbocza aż do pierwszego pola, które nie jest urwiskiem
/turf/open/cliff/proc/start_falling(atom/movable/faller)
	falling |= faller
	var/steps = 0
	while(!QDELETED(faller) && istype(faller.loc, /turf/open/cliff) && steps < 50)
		var/turf/open/cliff/current = faller.loc
		if(isliving(faller))
			var/mob/living/living_faller = faller
			living_faller.Knockdown(current.fall_speed * 2)
			living_faller.spin(current.fall_speed, 1)
		sleep(current.fall_speed)
		if(QDELETED(faller) || faller.loc != current)
			break
		var/turf/next = get_step(current, current.fall_direction)
		if(!next || !faller.Move(next, current.fall_direction))
			if(next)
				faller.forceMove(next)
			else
				break
		steps++
	falling -= faller

/turf/open/cliff/snowrock
	name = "lodowe urwisko"
	smooth_base_state = "icerock_wall"

/turf/open/cliff/snowrock/virtual_domain
	initial_gas_mix = "o2=22;n2=82;TEMP=180"

/turf/open/lava/plasma/virtual_domain
	name = "jezioro plazmy"
	initial_gas_mix = "o2=22;n2=82;TEMP=180"
	baseturfs = /turf/open/lava/plasma/virtual_domain


#define WENDIGO_ENRAGED (health <= maxHealth * 0.5)

/**
 * Wendigo z tg (lodowy księżyc). U nas bez systemu mob_cooldown: ataki to zwykłe procedury jak u kolosa.
 */
/mob/living/simple_animal/hostile/megafauna/wendigo
	name = "wendigo"
	desc = "Mityczny ludożerca z legend. Puste oczodoły śledzą cię z nienasyconym głodem."
	health = 2500
	maxHealth = 2500
	icon = 'aquila/icons/mob/wendigo.dmi'
	icon_state = "wendigo"
	icon_living = "wendigo"
	icon_dead = "wendigo_dead"
	attacktext = "drapie"
	attack_sound = 'sound/magic/demon_attack1.ogg'
	speak_emote = list("ryczy")
	armour_penetration = 40
	melee_damage = 40
	vision_range = 9
	aggro_vision_range = 18
	speed = 6
	move_to_delay = 6
	ranged = TRUE
	ranged_cooldown_time = 4 SECONDS
	pixel_x = -16
	base_pixel_x = -16
	gps_name = "Berserk Signal"
	loot = list()
	butcher_results = list()
	wander = FALSE
	del_on_death = FALSE
	deathmessage = "pada na ziemię w krwawej kupie, aż drży cała arena."
	deathsound = 'sound/effects/gravhit.ogg'
	/// Gdzie się pojawił (wraca tu na ataki falą)
	var/turf/starting
	/// Zasięg tupnięcia przy ruchu
	var/stomp_range = 1
	/// Kiedy znowu może krzyczeć
	COOLDOWN_DECLARE(scream_cooldown)

/mob/living/simple_animal/hostile/megafauna/wendigo/Initialize(mapload)
	. = ..()
	starting = get_turf(src)

/mob/living/simple_animal/hostile/megafauna/wendigo/Moved(atom/old_loc, movement_dir, forced = FALSE)
	. = ..()
	if(stat == DEAD)
		return
	INVOKE_ASYNC(GLOBAL_PROC, GLOBAL_PROC_REF(wendigo_slam), src, stomp_range, 1, 8)

/mob/living/simple_animal/hostile/megafauna/wendigo/OpenFire()
	if(WENDIGO_ENRAGED)
		speed = 4
		move_to_delay = 4
	else
		speed = initial(speed)
		move_to_delay = initial(move_to_delay)

	if(client)
		return

	var/mob/living/living_target = target
	if(istype(living_target) && living_target.stat == DEAD)
		return

	ranged_cooldown = world.time + ranged_cooldown_time
	var/attack = COOLDOWN_FINISHED(src, scream_cooldown) ? rand(1, 4) : rand(1, 3)
	switch(attack)
		if(1)
			INVOKE_ASYNC(GLOBAL_PROC, GLOBAL_PROC_REF(wendigo_slam), src, 4, 2, 8)
		if(2)
			teleport_to_target()
			if(WENDIGO_ENRAGED)
				shotgun_blast()
		if(3)
			do_teleport(src, starting, 0, channel = TELEPORT_CHANNEL_BLUESPACE, forced = TRUE)
			if(WENDIGO_ENRAGED && prob(50))
				INVOKE_ASYNC(src, PROC_REF(spiral_shots), TRUE)
			else
				INVOKE_ASYNC(src, PROC_REF(spiral_shots), FALSE)
			ranged_cooldown = world.time + 3 SECONDS
		if(4)
			COOLDOWN_START(src, scream_cooldown, 10 SECONDS)
			INVOKE_ASYNC(GLOBAL_PROC, GLOBAL_PROC_REF(wendigo_scream), src)

/// Teleport obok celu
/mob/living/simple_animal/hostile/megafauna/wendigo/proc/teleport_to_target()
	var/turf/target_turf = get_turf(target)
	if(!target_turf)
		return
	var/list/possible = list()
	for(var/turf/open/candidate in RANGE_TURFS(2, target_turf))
		if(!is_blocked_turf(candidate, TRUE))
			possible += candidate
	if(!length(possible))
		return
	new /obj/effect/temp_visual/small_smoke/halfsecond(get_turf(src))
	do_teleport(src, pick(possible), 0, channel = TELEPORT_CHANNEL_BLUESPACE, forced = TRUE)
	new /obj/effect/temp_visual/small_smoke/halfsecond(get_turf(src))

/// Wystrzał lodowych odłamków w stronę celu
/mob/living/simple_animal/hostile/megafauna/wendigo/proc/shotgun_blast()
	var/turf/target_turf = get_turf(target)
	if(!target_turf)
		return
	var/angle_to_target = get_angle(src, target_turf)
	playsound(src, 'sound/magic/clockwork/invoke_general.ogg', 200, TRUE, 2)
	for(var/spread in list(-30, -15, 0, 15, 30))
		shoot_wendigo_projectile(target_turf, angle_to_target + spread)

/// Spirala fal uderzeniowych
/mob/living/simple_animal/hostile/megafauna/wendigo/proc/spiral_shots(enraged = FALSE)
	var/turf/start_turf = get_step(src, pick(GLOB.alldirs))
	var/counter = 1
	for(var/i in 1 to (enraged ? 48 : 32))
		if(stat == DEAD)
			return
		counter = counter % 16 + 1
		shoot_wendigo_projectile(start_turf, counter * 22.5)
		if(enraged)
			shoot_wendigo_projectile(start_turf, 360 - counter * 22.5)
		sleep(1)

/mob/living/simple_animal/hostile/megafauna/wendigo/proc/shoot_wendigo_projectile(turf/marker, set_angle)
	var/turf/startloc = get_turf(src)
	var/obj/item/projectile/colossus/wendigo_shockwave/shockwave = new(startloc)
	shockwave.preparePixelProjectile(marker, startloc)
	shockwave.firer = src
	if(target)
		shockwave.original = target
	shockwave.fire(set_angle)

/obj/item/projectile/colossus/wendigo_shockwave
	name = "fala uderzeniowa wendigo"
	damage = 15

/proc/wendigo_scream(mob/owner)
	playsound(owner.loc, 'sound/magic/demon_dies.ogg', 600, FALSE, 10)
	var/pixel_shift = rand(5, 15)
	animate(owner, pixel_z = pixel_shift, time = 1, loop = 20, flags = ANIMATION_RELATIVE)
	animate(pixel_z = -pixel_shift, time = 1, flags = ANIMATION_RELATIVE)
	for(var/mob/living/dizzy_target in get_hearers_in_view(7, owner) - owner)
		dizzy_target.Dizzy(12)
		to_chat(dizzy_target, span_danger("[owner] przeraźliwie wrzeszczy!"))

/proc/wendigo_slam(mob/owner, range, delay, throw_range)
	var/turf/origin = get_turf(owner)
	if(!origin)
		return
	var/list/all_turfs = RANGE_TURFS(range, origin)
	for(var/sound_range = 0 to range)
		playsound(origin, 'sound/effects/bamf.ogg', 600, TRUE, 10)
		for(var/turf/stomp_turf in all_turfs)
			if(get_dist(origin, stomp_turf) > sound_range)
				continue
			new /obj/effect/temp_visual/small_smoke/halfsecond(stomp_turf)
			for(var/mob/living/hit_mob in stomp_turf)
				if(hit_mob == owner || hit_mob.throwing)
					continue
				to_chat(hit_mob, span_userdanger("Fala uderzeniowa od tupnięcia [owner] odrzuca cię!"))
				var/turf/thrownat = get_ranged_target_turf_direct(owner, hit_mob, throw_range, rand(-10, 10))
				hit_mob.throw_at(thrownat, 8, 2, null, TRUE, force = MOVE_FORCE_OVERPOWERING)
				hit_mob.apply_damage(20, BRUTE)
				shake_camera(hit_mob, 2, 1)
			all_turfs -= stomp_turf
		sleep(delay)

#undef WENDIGO_ENRAGED
