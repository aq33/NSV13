// AQUILA - pajączki (tg: spiderling.dm, spiderling_subtypes.dm)

/**
 * # Pajączek
 *
 * Małe pająki z jaj, botaniki i gruczołów abduktorów. Chodzą wentylacją,
 * uciekają przed wszystkim większym i z czasem wyrastają na młode pająki.
 */
/mob/living/simple_animal/hostile/spider/growing/spiderling
	name = "pajączek"
	desc = "Nigdy nie stoi długo w miejscu."
	icon_state = "spiderling"
	icon_living = "spiderling"
	icon_dead = "spiderling_dead"
	density = FALSE
	speed = -0.75
	move_resist = INFINITY
	speak_emote = list("syczy")
	emote_hear = list("szczebiocze.")
	mob_size = MOB_SIZE_TINY
	pass_flags = PASSTABLE | PASSMOB
	melee_damage = 1
	obj_damage = 0
	environment_smash = ENVIRONMENT_SMASH_NONE
	health = 5
	maxHealth = 5
	del_on_death = TRUE
	deathmessage = "wydaje ostatni syk..."
	player_speed_modifier = 0
	spider_growth_time = 40 SECONDS
	ventcrawler = VENTCRAWLER_ALWAYS
	retaliate_only = TRUE
	retreat_distance = 6
	minimum_distance = 6
	off_web_slowdown = SPIDER_WEB_SLOWDOWN_FAST
	butcher_results = null
	/// Wentylacja, do której AI zmierza
	var/obj/machinery/atmospherics/components/unary/vent_pump/entry_vent
	/// Czy AI właśnie podróżuje rurami
	var/travelling_in_vent = FALSE
	/// Kiedy AI może znów wejść do wentylacji
	var/next_vent_time = 0

/mob/living/simple_animal/hostile/spider/growing/spiderling/Initialize(mapload)
	. = ..()
	// Losowe przesunięcie, żeby gromadka pajączków nie zlewała się w jeden
	pixel_x = rand(-6, 6)
	pixel_y = rand(-6, 6)
	AddComponent(/datum/component/swarming)
	next_vent_time = world.time + rand(5, 15) SECONDS

/mob/living/simple_animal/hostile/spider/growing/spiderling/Destroy()
	entry_vent = null
	return ..()

/mob/living/simple_animal/hostile/spider/growing/spiderling/death(gibbed)
	if(isturf(loc))
		var/obj/item/food/spiderling/dead_spider = new(loc)
		dead_spider.name = name
		dead_spider.icon = icon
		dead_spider.icon_state = icon_dead
	return ..()

/mob/living/simple_animal/hostile/spider/growing/spiderling/start_pulling(atom/movable/AM, state, force = move_force, supress_message = FALSE)
	return // za małe

/// Nie rośniemy w rurach
/mob/living/simple_animal/hostile/spider/growing/spiderling/ready_to_grow()
	return ..() && !travelling_in_vent

/// Pajączki nie walczą, tylko uciekają przed większymi od siebie (tg: of_size/larger)
/mob/living/simple_animal/hostile/spider/growing/spiderling/ListTargets()
	. = list()
	for(var/mob/living/nearby in oview(vision_range, src))
		if(nearby.stat == DEAD || nearby.mob_size <= mob_size || faction_check_mob(nearby))
			continue
		. += nearby

/mob/living/simple_animal/hostile/spider/growing/spiderling/AttackingTarget()
	if(client)
		return ..()
	return FALSE

/// Krząta się i od czasu do czasu znika w wentylacji (tg: consider_venting)
/mob/living/simple_animal/hostile/spider/growing/spiderling/handle_automated_movement()
	if(client || stat != CONSCIOUS || travelling_in_vent)
		return
	if(entry_vent)
		if(QDELETED(entry_vent) || entry_vent.welded || get_dist(src, entry_vent) > 10)
			entry_vent = null
			stop_automated_movement = FALSE
		else if(get_dist(src, entry_vent) <= 1)
			INVOKE_ASYNC(src, PROC_REF(travel_through_vents))
			return
		else
			return
	if(world.time > next_vent_time && prob(10))
		for(var/obj/machinery/atmospherics/components/unary/vent_pump/vent in view(7, src))
			if(vent.welded)
				continue
			entry_vent = vent
			stop_automated_movement = TRUE
			SSmove_manager.move_to(src, vent, 1, move_to_delay, 10 SECONDS)
			return
	return ..()

/mob/living/simple_animal/hostile/spider/growing/spiderling/proc/travel_through_vents()
	var/obj/machinery/atmospherics/components/unary/vent_pump/start_vent = entry_vent
	entry_vent = null
	stop_automated_movement = FALSE
	next_vent_time = world.time + 20 SECONDS
	if(QDELETED(start_vent) || !length(start_vent.parents))
		return
	var/datum/pipeline/vent_network = start_vent.parents[1]
	if(!vent_network)
		return
	var/list/exits = list()
	for(var/obj/machinery/atmospherics/components/unary/vent_pump/other_vent in vent_network.other_atmos_machines)
		if(other_vent != start_vent && !other_vent.welded)
			exits += other_vent
	if(!length(exits))
		return
	var/obj/machinery/atmospherics/components/unary/vent_pump/exit_vent = pick(exits)
	if(prob(50))
		visible_message("<b>[src] wpełza do kanałów wentylacyjnych!</b>", blind_message = span_italics("Słyszysz, jak coś drobi po kanałach wentylacyjnych."))
	SSmove_manager.stop_looping(src)
	travelling_in_vent = TRUE
	forceMove(start_vent)
	var/travel_time = max(1 SECONDS, round(get_dist(start_vent, exit_vent) / 2) SECONDS)
	sleep(travel_time)
	if(QDELETED(src))
		return
	travelling_in_vent = FALSE
	if(stat == DEAD)
		return
	if(QDELETED(exit_vent) || exit_vent.welded)
		if(QDELETED(start_vent))
			forceMove(get_turf(src))
		else
			forceMove(get_turf(start_vent))
		return
	if(prob(50))
		audible_message(span_italics("Słyszysz, jak coś drobi po kanałach wentylacyjnych."))
	forceMove(get_turf(exit_vent))

/// Wyrośnie na losowego młodego pająka zwykłego typu (np. pajączki z botaniki)
/mob/living/simple_animal/hostile/spider/growing/spiderling/grow_up()
	if(isnull(grow_as))
		grow_as = pick(
			/mob/living/simple_animal/hostile/spider/growing/young/guard,
			/mob/living/simple_animal/hostile/spider/growing/young/ambush,
			/mob/living/simple_animal/hostile/spider/growing/young/hunter,
			/mob/living/simple_animal/hostile/spider/growing/young/scout,
			/mob/living/simple_animal/hostile/spider/growing/young/nurse,
			/mob/living/simple_animal/hostile/spider/growing/young/tangle,
		)
	return ..()

/mob/living/simple_animal/hostile/spider/growing/spiderling/guard
	grow_as = /mob/living/simple_animal/hostile/spider/growing/young/guard
	name = "pajączek strażnik"
	desc = "Włochaty i brązowy, wygląda na bezbronnego. Ten ma iskrzące czerwone oczy."

/mob/living/simple_animal/hostile/spider/growing/spiderling/ambush
	grow_as = /mob/living/simple_animal/hostile/spider/growing/young/ambush
	name = "pajączek zasadzkowy"
	desc = "Włochaty i biały, wygląda na bezbronnego. Ten ma iskrzące różowe oczy."
	icon_state = "ambush_spiderling"
	icon_living = "ambush_spiderling"
	icon_dead = "ambush_spiderling_dead"

/mob/living/simple_animal/hostile/spider/growing/spiderling/scout
	grow_as = /mob/living/simple_animal/hostile/spider/growing/young/scout
	name = "pajączek zwiadowca"
	desc = "Włochaty i czarny, wygląda na bezbronnego. Ten ma iskrzące niebieskie oczy."
	icon_state = "scout_spiderling"
	icon_living = "scout_spiderling"
	icon_dead = "scout_spiderling_dead"
	sight = SEE_SELF | SEE_MOBS

/mob/living/simple_animal/hostile/spider/growing/spiderling/hunter
	grow_as = /mob/living/simple_animal/hostile/spider/growing/young/hunter
	name = "pajączek łowca"
	desc = "Włochaty i czarny, wygląda na bezbronnego. Ten ma iskrzące fioletowe oczy."
	icon_state = "hunter_spiderling"
	icon_living = "hunter_spiderling"
	icon_dead = "hunter_spiderling_dead"

/mob/living/simple_animal/hostile/spider/growing/spiderling/nurse
	grow_as = /mob/living/simple_animal/hostile/spider/growing/young/nurse
	name = "pajączek pielęgniarz"
	desc = "Włochaty i czarny, wygląda na bezbronnego. Ten ma iskrzące zielone oczy."
	icon_state = "nurse_spiderling"
	icon_living = "nurse_spiderling"
	icon_dead = "nurse_spiderling_dead"

/mob/living/simple_animal/hostile/spider/growing/spiderling/tangle
	grow_as = /mob/living/simple_animal/hostile/spider/growing/young/tangle
	name = "pajączek splątujący"
	desc = "Włochaty i brązowy, wygląda na bezbronnego. Ten ma przygaszone brązowe oczy."
	icon_state = "tangle_spiderling"
	icon_living = "tangle_spiderling"
	icon_dead = "tangle_spiderling_dead"

/mob/living/simple_animal/hostile/spider/growing/spiderling/tank
	grow_as = /mob/living/simple_animal/hostile/spider/growing/young/tank
	name = "pajączek czołg"
	desc = "Włochaty i fioletowy, wygląda na bezbronnego. Ten ma przygaszone żółte oczy."
	icon_state = "tank_spiderling"
	icon_living = "tank_spiderling"
	icon_dead = "tank_spiderling_dead"

/mob/living/simple_animal/hostile/spider/growing/spiderling/breacher
	grow_as = /mob/living/simple_animal/hostile/spider/growing/young/breacher
	name = "pajączek wyłamywacz"
	desc = "Włochaty i beżowy, wygląda na bezbronnego. Ten ma przygaszone czerwone oczy."
	icon_state = "breacher_spiderling"
	icon_living = "breacher_spiderling"
	icon_dead = "breacher_spiderling_dead"

/mob/living/simple_animal/hostile/spider/growing/spiderling/midwife
	grow_as = /mob/living/simple_animal/hostile/spider/growing/young/midwife
	name = "pajączek matka"
	desc = "Włochaty i czarny, wygląda na bezbronnego. Ten ma migotliwie zielone oczy. Może też chować gdzieś prawdziwy nóż."
	icon_state = "midwife_spiderling"
	icon_living = "midwife_spiderling"
	icon_dead = "midwife_spiderling_dead"

/mob/living/simple_animal/hostile/spider/growing/spiderling/viper
	grow_as = /mob/living/simple_animal/hostile/spider/growing/young/viper
	name = "pajączek żmija"
	desc = "Włochaty i czarny, wygląda na bezbronnego. Ten ma iskrzące purpurowe oczy."
	icon_state = "viper_spiderling"
	icon_living = "viper_spiderling"
	icon_dead = "viper_spiderling_dead"

/mob/living/simple_animal/hostile/spider/growing/spiderling/tarantula
	grow_as = /mob/living/simple_animal/hostile/spider/growing/young/tarantula
	name = "pajączek tarantula"
	desc = "Włochaty i czarny, wygląda na bezbronnego. Ten ma otchłannie czerwone oczy."
	icon_state = "tarantula_spiderling"
	icon_living = "tarantula_spiderling"
	icon_dead = "tarantula_spiderling_dead"
