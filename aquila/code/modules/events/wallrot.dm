// AQUILA - Wallrot (port of the Paradise event): a nasty fungus eats into a patch of walls somewhere on the ship.
// A rotting wall crumbles when pushed by hand (reinforced walls only groan), breaks to any hulk and to light explosions.
// Engineering burns the fungus off with a welder, Plant-B-Gone dissolves it.

/datum/round_event_control/aquila_wallrot
	name = "Wallrot"
	typepath = /datum/round_event/aquila_wallrot
	weight = 10
	max_occurrences = 2
	earliest_start = 10 MINUTES

/datum/round_event/aquila_wallrot
	announceWhen = 30
	/// Wall the rot spreads out from
	var/turf/closed/wall/center

/datum/round_event/aquila_wallrot/setup()
	var/list/station_levels = SSmapping.levels_by_trait(ZTRAIT_STATION)
	if(!length(station_levels))
		kill()
		return
	for(var/i in 1 to 100)
		var/turf/candidate = locate(rand(1, world.maxx), rand(1, world.maxy), pick(station_levels))
		if(!istype(candidate, /turf/closed/wall))
			continue
		var/area/candidate_area = get_area(candidate)
		if(!(candidate_area.type in GLOB.the_station_areas))
			continue
		center = candidate
		break
	if(!center) // kill() from setup() does not stop the event, New() re-adds it, so announce() and start() check this too
		kill()

/datum/round_event/aquila_wallrot/start()
	if(!center)
		return kill()
	center.aquila_rot()
	var/rot_left = rand(10, 20)
	for(var/turf/closed/wall/W in range(5, center))
		if(W == center || !prob(50))
			continue
		W.aquila_rot()
		if(--rot_left <= 0)
			break
	announce_to_ghosts(center)
	log_game("Wallrot started at [AREACOORD(center)].")

/datum/round_event/aquila_wallrot/announce(fake)
	if(!fake && !center)
		return
	var/area/rot_area = fake ? (length(GLOB.generic_event_spawns) ? get_area(pick(GLOB.generic_event_spawns)) : null) : get_area(center)
	if(!rot_area)
		return
	priority_announce("Czujniki wykryły szkodliwy grzyb na ścianach w rejonie: [rot_area.name]. Zaatakowane ściany mogą się kruszyć. \
		Inżynieria proszona jest o wypalenie grzyba spawarką albo zneutralizowanie go środkiem Plant-B-Gone.", "Zagrożenie biologiczne")

/turf/closed/wall
	/// AQUILA - TRUE while wallrot fungus grows on this wall
	var/aquila_rotting = FALSE
	/// AQUILA - fungus overlay effects sitting on this wall
	var/list/aquila_rot_effects

/// Makes the wall rot, does nothing if it already does
/turf/closed/wall/proc/aquila_rot()
	if(aquila_rotting)
		return
	aquila_rotting = TRUE
	for(var/i in 1 to rand(2, 3))
		LAZYADD(aquila_rot_effects, new /obj/effect/overlay/aquila_wallrot(src))

/// Clears the fungus off the wall
/turf/closed/wall/proc/aquila_clear_rot()
	aquila_rotting = FALSE
	QDEL_LAZYLIST(aquila_rot_effects)

/turf/closed/wall/ChangeTurf(path, list/new_baseturfs, flags)
	if(aquila_rotting)
		aquila_clear_rot()
	return ..()

/turf/closed/wall/examine(mob/user)
	. = ..()
	if(aquila_rotting)
		. += "<span class='warning'>Na ścianie rośnie grzyb, wygląda na mocno nadgniłą.</span>"

/turf/closed/wall/attack_hand(mob/user)
	if(!aquila_rotting)
		return ..()
	user.changeNext_move(CLICK_CD_MELEE)
	add_fingerprint(user)
	if(hardness <= 10)
		user.visible_message("<span class='warning'>[user] napiera na ścianę, która wydaje niepokojący metaliczny jęk!</span>", \
			"<span class='warning'>Napierasz na ścianę. Jest wyraźnie niestabilna i wydaje niepokojący metaliczny jęk!</span>", \
			"<span class='warning'>Słyszysz niepokojący metaliczny jęk!</span>")
		return TRUE
	user.visible_message("<span class='warning'>[user] napiera na ścianę, a ta kruszy się pod [user.p_their()] dotykiem!</span>", \
		"<span class='warning'>Napierasz na ścianę, a ta kruszy się pod twoim dotykiem!</span>", \
		"<span class='warning'>Słyszysz, jak coś się kruszy!</span>")
	dismantle_wall()
	return TRUE

/turf/closed/wall/attack_hulk(mob/user, does_attack_animation = 0)
	if(!aquila_rotting)
		return ..()
	user.do_attack_animation(src)
	playsound(src, 'sound/effects/meteorimpact.ogg', 100, 1)
	user.say(pick(GLOB.hulk_scream_phrases), forced = "hulk")
	dismantle_wall(1)
	return TRUE

/turf/closed/wall/attack_animal(mob/living/simple_animal/M)
	if(aquila_rotting && M.melee_damage >= 10)
		M.changeNext_move(CLICK_CD_MELEE)
		M.do_attack_animation(src)
		playsound(src, 'sound/effects/meteorimpact.ogg', 100, 1)
		dismantle_wall(1)
		return
	return ..()

/turf/closed/wall/ex_act(severity, target)
	if(aquila_rotting && severity == EXPLODE_LIGHT && target != src)
		dismantle_wall(0, 1)
		return
	return ..()

/turf/closed/wall/try_clean(obj/item/W, mob/user, turf/T)
	if(!aquila_rotting || W.tool_behaviour != TOOL_WELDER)
		return ..()
	if(!W.tool_start_check(user, amount = 0))
		return FALSE
	balloon_alert(user, "Wypalasz grzyb...")
	if(W.use_tool(src, user, 2 SECONDS, volume = 100) && aquila_rotting)
		aquila_clear_rot()
		to_chat(user, "<span class='notice'>Wypalasz grzyb ze ściany [W].</span>")
	return TRUE

/datum/reagent/toxin/plantbgone/reaction_turf(turf/T, volume)
	. = ..()
	var/turf/closed/wall/W = T
	if(istype(W) && W.aquila_rotting)
		W.aquila_clear_rot()
		W.visible_message("<span class='warning'>Roztwór całkowicie rozpuszcza grzyb!</span>")

/obj/effect/overlay/aquila_wallrot
	name = "grzyb ścienny"
	desc = "Fuj..."
	icon = 'aquila/icons/effects/wallrot.dmi'
	icon_state = ""
	layer = ABOVE_OBJ_LAYER
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	anchored = TRUE

/obj/effect/overlay/aquila_wallrot/Initialize(mapload)
	. = ..()
	pixel_x = rand(-10, 10)
	pixel_y = rand(-10, 10)
