// AQUILA - nurkowanie pod statkiem z kosmosu (tg: /datum/component/space_dive)

/// Wszystkie mgławicowe wymiociny na mapie, do skakania między nimi w trakcie nurkowania
GLOBAL_LIST_EMPTY(nebula_vomits)

/// Ile trwa zanurzenie
#define VOIDWALKER_DIVE_TIME (3 SECONDS)
/// Ile trwa wynurzenie
#define VOIDWALKER_SURFACE_TIME (1 SECONDS)

/mob/living/simple_animal/hostile/voidwalker
	/// Czy trwa zanurzanie
	var/diving = FALSE

/mob/living/simple_animal/hostile/voidwalker/Bump(atom/bumped)
	. = ..()
	if(!istype(get_turf(src), home_turf) || istype(loc, /obj/effect/dummy/phased_mob/voidwalker))
		return
	if(ismovable(bumped))
		if(istype(bumped, /obj/machinery/door)) // drzwi grają lepiej bez tego
			return
		var/atom/movable/mover = bumped
		if(!mover.anchored)
			return
	else if(!isturf(bumped))
		return
	INVOKE_ASYNC(src, PROC_REF(attempt_dive), bumped)

/mob/living/simple_animal/hostile/voidwalker/proc/attempt_dive(atom/bumped)
	if(diving)
		return
	diving = TRUE
	var/success = do_after(src, VOIDWALKER_DIVE_TIME, FALSE, bumped)
	diving = FALSE
	if(success)
		dive(get_turf(bumped))

/mob/living/simple_animal/hostile/voidwalker/proc/try_dive_into_decal(obj/effect/decal/cleanable/vomit/nebula/decal)
	if(!do_after(src, 1 SECONDS, FALSE, decal))
		return
	var/turf/decal_turf = get_turf(decal)
	new /obj/effect/temp_visual/voidwalker_wave(decal_turf)
	qdel(decal)
	dive(decal_turf)

/// Wchodzi pod pokład na wskazanym polu
/mob/living/simple_animal/hostile/voidwalker/proc/dive(turf/target)
	if(!target || istype(loc, /obj/effect/dummy/phased_mob/voidwalker))
		return
	drop_all_held_items()
	var/obj/effect/dummy/phased_mob/voidwalker/holder = new(target, src)
	forceMove(holder)
	playsound(target, 'sound/magic/ethereal_enter.ogg', 30, TRUE, -1)

/// Wynurza się na wskazanym polu
/mob/living/simple_animal/hostile/voidwalker/proc/surface(turf/target)
	var/obj/effect/dummy/phased_mob/voidwalker/holder = loc
	if(!istype(holder))
		return
	var/obj/effect/decal/cleanable/vomit/nebula/decal = locate() in target
	if(decal)
		var/obj/effect/abstract/voidwalker_particles/particles = new(target, /particles/void_vomit)
		QDEL_IN(particles, 60 SECONDS)
	forceMove(target || get_turf(holder))
	qdel(holder)
	playsound(src, 'sound/magic/ethereal_exit.ogg', 30, TRUE, -1)
	update_camo()

/// Uchwyt, w którym wędrowiec porusza się pod statkiem
/obj/effect/dummy/phased_mob/voidwalker
	name = "void"
	icon = 'icons/effects/effects.dmi'
	icon_state = "nothing"
	density = FALSE
	anchored = TRUE
	invisibility = 60
	resistance_flags = LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF
	/// Odstęp między krokami
	var/move_delay = 1
	/// Kiedy można się znowu ruszyć
	var/next_move = 0
	/// Kogo niesiemy, żeby wiedzieć komu pokazać obrazek pozycji
	var/mob/living/simple_animal/hostile/voidwalker/walker
	/// Obrazek pozycji widoczny tylko dla wędrowca
	var/image/position_image
	/// Czy trwa wynurzanie
	var/surfacing = FALSE

/obj/effect/dummy/phased_mob/voidwalker/Initialize(mapload, mob/living/simple_animal/hostile/voidwalker/new_walker)
	. = ..()
	walker = new_walker
	if(walker)
		position_image = image(walker.icon, src, "[walker.icon_state]_stealthed", ABOVE_LIGHTING_LAYER)
		position_image.plane = ABOVE_LIGHTING_PLANE
		position_image.alpha = 120
		walker.client?.images |= position_image

/obj/effect/dummy/phased_mob/voidwalker/Destroy()
	if(walker)
		walker.client?.images -= position_image
		walker = null
	position_image = null
	for(var/atom/movable/thing as anything in contents)
		thing.forceMove(get_turf(src))
	return ..()

/obj/effect/dummy/phased_mob/voidwalker/Exited(atom/movable/gone, direction)
	. = ..()
	if(gone == walker && !QDELETED(src))
		qdel(src)

/obj/effect/dummy/phased_mob/voidwalker/relaymove(mob/user, direction)
	if(user != walker || next_move > world.time)
		return
	next_move = world.time + move_delay
	var/turf/new_turf = get_step(src, direction)
	if(!new_turf)
		return
	if(istype(new_turf, walker.home_turf) || (locate(walker.kidnapping_decal) in new_turf))
		INVOKE_ASYNC(src, PROC_REF(attempt_surface), new_turf)
		return
	forceMove(new_turf)

/obj/effect/dummy/phased_mob/voidwalker/proc/attempt_surface(turf/new_turf)
	if(surfacing)
		return
	var/turf/start_turf = get_turf(src)
	surfacing = TRUE
	var/success = do_after(walker, VOIDWALKER_SURFACE_TIME, FALSE, new_turf, TRUE, CALLBACK(src, PROC_REF(check_not_moved), start_turf))
	surfacing = FALSE
	if(success && !QDELETED(src))
		walker.surface(new_turf)

/obj/effect/dummy/phased_mob/voidwalker/proc/check_not_moved(turf/start_turf)
	return get_turf(src) == start_turf

/obj/effect/dummy/phased_mob/voidwalker/ex_act()
	return

/obj/effect/dummy/phased_mob/voidwalker/bullet_act()
	return BULLET_ACT_FORCE_PIERCE

/obj/effect/dummy/phased_mob/voidwalker/singularity_act()
	return

#undef VOIDWALKER_DIVE_TIME
#undef VOIDWALKER_SURFACE_TIME
