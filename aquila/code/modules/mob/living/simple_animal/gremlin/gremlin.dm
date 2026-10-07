// AQUILA - gremliny (port z HippieStation, HippieStation/HippieStationdeprecated2020#3098 + późniejsze poprawki Hippie)
// Małe potworki, które nie atakują ludzi ani zwierząt. Zamiast tego psują elektronikę, komputery i maszyny.
// Interakcje z konkretnymi maszynami są w gremlin_act.dm (npc_tamper_act())

/// Chance per Life() tick that an idle AI gremlin heads for a nearby vent
#define GREMLIN_VENT_CHANCE 1.75

/// Types gremlins found nothing to do with. Filled at runtime: once a gremlin gets bored with a type, all gremlins ignore that exact type (not its subtypes)
GLOBAL_LIST(bad_gremlin_items)

/mob/living/simple_animal/hostile/gremlin
	name = "gremlin"
	desc = "To małe stworzonko uwielbia odkrywać technologię i z niej korzystać. Nic nie cieszy go bardziej niż wciskanie losowych przycisków na komputerze, żeby zobaczyć, co się stanie."
	icon = 'aquila/icons/mob/gremlin.dmi'
	icon_state = "gremlin"
	icon_living = "gremlin"
	icon_dead = "gremlin_dead"

	ventcrawler = VENTCRAWLER_ALWAYS

	health = 20
	maxHealth = 20
	search_objects = 3 //Completely ignore mobs, even when attacked

	//Tampering is handled by the npc_tamper_act() obj proc
	wanted_objects = list(
		/obj/machinery,
		/obj/item/reagent_containers/food,
		/obj/structure/sink,
	)

	dextrous = TRUE
	possible_a_intents = list(INTENT_HELP, INTENT_GRAB, INTENT_DISARM, INTENT_HARM)
	faction = list("meme", "gremlin")
	speed = 0.5
	gold_core_spawnable = FRIENDLY_SPAWN
	unique_name = TRUE

	//Gremlins never hurt other mobs or smash things
	melee_damage = 0
	attack_sound = null
	obj_damage = 0
	environment_smash = ENVIRONMENT_SMASH_NONE

	/// Objects we never even try to tamper with, subtypes included
	var/list/unwanted_objects = list(/obj/machinery/atmospherics/pipe)

	/// Ticks spent pathing to the current target. Past max_time_chasing_target we assume it is unreachable and drop it
	var/time_chasing_target = 0
	/// Raise this if gremlins get slower, otherwise they give up on targets too early
	var/max_time_chasing_target = 2

	/// world.time after which the gremlin is hungry again
	var/next_eat = 0

	/// Last heard messages, newest first. Used to "write" comms console announcements
	var/list/hear_memory = list()
	var/max_hear_memory = 20

	/// TRUE from the moment an AI gremlin decides to use a vent until it climbs out again
	var/in_vent = FALSE
	/// Vent the gremlin is walking to / crawled into
	var/obj/machinery/atmospherics/components/unary/vent_pump/entry_vent
	/// Vent the gremlin will climb out of, set only while it is inside the ducts
	var/obj/machinery/atmospherics/components/unary/vent_pump/exit_vent
	/// world.time before which the gremlin will not ventcrawl again
	var/min_next_vent = 0
	/// world.time after which the gremlin gives up walking to entry_vent
	var/vent_give_up_time = 0

/mob/living/simple_animal/hostile/gremlin/Destroy()
	entry_vent = null
	exit_vent = null
	return ..()

/mob/living/simple_animal/hostile/gremlin/AttackingTarget()
	if(istype(target, /obj/item/reagent_containers/food))
		if(world.time >= next_eat || prob(25)) //eat food if we're hungry or bored
			eat(target)
		LoseTarget()
		return
	if(isobj(target))
		tamper(target)
		if(prob(50)) //50% chance to move on to the next machine
			LoseTarget()

/mob/living/simple_animal/hostile/gremlin/Hear(message, atom/movable/speaker, message_language, raw_message, radio_freq, list/spans, list/message_mods = list())
	. = ..()
	if(speaker == src || !raw_message || CHAT_FILTER_CHECK(raw_message))
		return
	hear_memory.Insert(1, html_decode(raw_message))
	if(length(hear_memory) > max_hear_memory)
		hear_memory.Cut(max_hear_memory + 1)

/mob/living/simple_animal/hostile/gremlin/proc/generate_markov_input()
	return jointext(hear_memory, " ")

/mob/living/simple_animal/hostile/gremlin/proc/generate_markov_chain()
	return markov_chain(generate_markov_input(), rand(2, 5), rand(100, 700)) //The numbers are chosen arbitrarily

/mob/living/simple_animal/hostile/gremlin/proc/eat(obj/item/food)
	visible_message("<span class='danger'>[src] łapczywie pożera [food]!</span>", "<span class='danger'>Łapczywie pożerasz [food]!</span>")
	playsound(src, 'sound/items/eatfood.ogg', 50, TRUE)
	qdel(food)
	next_eat = world.time + rand(70 SECONDS, 5 MINUTES)

/mob/living/simple_animal/hostile/gremlin/proc/tamper(obj/M)
	switch(M.npc_tamper_act(src))
		if(NPC_TAMPER_ACT_FORGET)
			visible_message(pick(
				"<span class='notice'>[src] bawi się przez chwilę [M], ale szybko się nudzi.</span>",
				"<span class='notice'>[src] próbuje wymyślić, jak jeszcze mógłby zepsuć [M], ale nic nie przychodzi mu do głowy.</span>",
				"<span class='notice'>[src] olewa [M] i rozgląda się za czymś ciekawszym.</span>"))
			LAZYOR(GLOB.bad_gremlin_items, M.type)
			return FALSE
		if(NPC_TAMPER_ACT_NOMSG)
			return TRUE
		else
			visible_message(pick(
				"<span class='danger'>[src] z błyskiem w oku zaczyna grzebać w [M].</span>",
				"<span class='danger'>[src] przekręca jakieś gałki w [M] i wybucha śmiechem!</span>",
				"<span class='danger'>[src] wciska kilka przycisków na [M] i złośliwie chichocze.</span>",
				"<span class='danger'>[src] diabelsko zaciera łapki i zaczyna majstrować przy [M].</span>",
				"<span class='danger'>[src] przekręca mały zawór w [M].</span>"))
	return TRUE

/mob/living/simple_animal/hostile/gremlin/CanAttack(atom/the_target)
	if(LAZYFIND(GLOB.bad_gremlin_items, the_target.type))
		return FALSE
	if(is_type_in_list(the_target, unwanted_objects))
		return FALSE
	if(istype(the_target, /obj/machinery))
		var/obj/machinery/M = the_target
		if(M.machine_stat) //Unpowered or broken
			return FALSE
		if(istype(M, /obj/machinery/door/firedoor) && !M.density) //Only bother with closed firelocks, opening them
			return FALSE
	return ..()

/mob/living/simple_animal/hostile/gremlin/death(gibbed)
	SSmove_manager.stop_looping(src)
	if(!exit_vent) //still walking to the vent, forget about it. If we died inside the ducts, exit_vents() drops the body out
		stop_venting()
	return ..()

/mob/living/simple_animal/hostile/gremlin/Life()
	. = ..()
	if(!. || stat == DEAD)
		return
	if(!client) //players can ventcrawl on their own
		handle_vent_ai()
	//Don't path to one target for too long. If it takes too long, assume it can't be reached and find a new one
	if(!target)
		time_chasing_target = 0
	else if(++time_chasing_target > max_time_chasing_target)
		LoseTarget()
		time_chasing_target = 0

/mob/living/simple_animal/hostile/gremlin/handle_automated_action()
	if(in_vent) //busy crawling to or through the vents
		return FALSE
	return ..()

/mob/living/simple_animal/hostile/gremlin/handle_automated_movement()
	if(in_vent)
		return FALSE
	return ..()

/mob/living/simple_animal/hostile/gremlin/proc/handle_vent_ai()
	if(exit_vent) //already in the ducts, exit_vents() takes it from here
		return
	if(entry_vent)
		if(QDELETED(entry_vent) || entry_vent.welded || world.time > vent_give_up_time)
			stop_venting()
		else if(isturf(loc) && get_dist(src, entry_vent) <= 1)
			enter_vents()
		return
	if(world.time < min_next_vent || !isturf(loc) || !prob(GREMLIN_VENT_CHANCE)) //small chance to go into a vent
		return
	for(var/obj/machinery/atmospherics/components/unary/vent_pump/vent in view(7, src))
		if(vent.welded)
			continue
		LoseTarget()
		entry_vent = vent
		in_vent = TRUE
		vent_give_up_time = world.time + 20 SECONDS
		SSmove_manager.move_to(src, entry_vent, 1, move_to_delay)
		return

/mob/living/simple_animal/hostile/gremlin/proc/stop_venting()
	SSmove_manager.stop_looping(src)
	entry_vent = null
	in_vent = FALSE

/mob/living/simple_animal/hostile/gremlin/proc/enter_vents()
	var/list/vents = list()
	var/datum/pipeline/entry_vent_parent = entry_vent.parents[1]
	if(entry_vent_parent)
		for(var/obj/machinery/atmospherics/components/unary/vent_pump/vent in entry_vent_parent.other_atmos_machines)
			if(vent != entry_vent && !vent.welded)
				vents += vent
	if(!length(vents))
		stop_venting()
		min_next_vent = world.time + 30 SECONDS
		return
	SSmove_manager.stop_looping(src)
	exit_vent = pick(vents)
	var/travel_time = clamp(get_dist(entry_vent, exit_vent) * 2, 2 SECONDS, 20 SECONDS)
	visible_message("<span class='notice'>[src] wczołguje się do szybu wentylacyjnego!</span>")
	forceMove(entry_vent)
	addtimer(CALLBACK(src, PROC_REF(exit_vents)), travel_time)

/mob/living/simple_animal/hostile/gremlin/proc/exit_vents()
	var/turf/destination
	if(!QDELETED(exit_vent) && !exit_vent.welded)
		destination = get_turf(exit_vent)
	else if(!QDELETED(entry_vent)) //exit got welded or destroyed on the way, crawl back
		destination = get_turf(entry_vent)
	else
		destination = get_turf(src)
	entry_vent = null
	exit_vent = null
	in_vent = FALSE
	min_next_vent = world.time + 90 SECONDS
	if(!destination)
		return
	forceMove(destination)
	if(stat != DEAD)
		visible_message("<span class='notice'>[src] wyłazi z szybu wentylacyjnego!</span>")
	log_game("[src] came out of the vents at [AREACOORD(destination)]")

/mob/living/simple_animal/hostile/gremlin/EscapeConfinement()
	if(!in_vent && isobj(loc) && CanAttack(loc)) //If we're stuck inside a machine, screw with it
		tamper(loc)
	return ..()

//Lets player-controlled gremlins tamper with machinery and eat food on harm intent
/mob/living/simple_animal/hostile/gremlin/UnarmedAttack(atom/A, proximity)
	if(a_intent == INTENT_HARM)
		if(istype(A, /obj/item/reagent_containers/food))
			eat(A)
			return
		if(istype(A, /obj/machinery) || istype(A, /obj/structure))
			tamper(A)
			return
	return ..()

/// Water makes gremlins multiply. Health is halved and reduced by 2, the new gremlin gets the same health as the parent
/mob/living/simple_animal/hostile/gremlin/proc/divide()
	//Need 7.5 health for this, otherwise the resulting health would be below 1
	if(stat == DEAD || health < 7.5)
		return

	visible_message("<span class='notice'>[src] dzieli się na dwa!</span>")
	var/mob/living/simple_animal/hostile/gremlin/G = new type(get_turf(src))

	if(mind)
		mind.transfer_to(G)

	maxHealth = round(health * 0.5) - 2
	health = maxHealth
	var/matrix/new_transform = matrix(transform)
	new_transform.Scale(0.9)
	transform = new_transform

	G.maxHealth = maxHealth
	G.health = health
	G.transform = transform

/mob/living/simple_animal/hostile/gremlin/traitor
	health = 85
	maxHealth = 85
	gold_core_spawnable = NO_SPAWN

/datum/reagent/water/reaction_turf(turf/open/T, reac_volume)
	. = ..()
	for(var/mob/living/simple_animal/hostile/gremlin/G in T)
		G.divide()

/obj/item/grenade/spawnergrenade/gremlin
	name = "Shitty EMP Grenade"
	spawner_type = /mob/living/simple_animal/hostile/gremlin/traitor
	deliveryamt = 5

#undef GREMLIN_VENT_CHANCE
