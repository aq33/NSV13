GLOBAL_LIST_INIT(mouse_comestible, typecacheof(list(
		/obj/effect/decal/cleanable/food,
		/obj/effect/decal/cleanable/greenglow,
		/obj/effect/decal/cleanable/insectguts,
		/obj/effect/decal/cleanable/vomit,
		/obj/item/trash,
		/obj/item/grown/bananapeel,
		/obj/item/grown/corncob,
		/obj/item/grown/sunflower,
		/obj/item/cigbutt
	)))
GLOBAL_VAR_INIT(food_for_next_mouse, 0)

GLOBAL_VAR_INIT(mouse_food_eaten, 0)
GLOBAL_VAR_INIT(mouse_spawned, 0)
GLOBAL_VAR_INIT(mouse_killed, 0)

#define FOODPERMOUSE 35

/mob/living/proc/handle_stomach()
	return

/mob/living/simple_animal/mouse/handle_stomach()
	if(cheesed && cheese_time < world.time)
		cheese_down()

/mob/living/simple_animal/mouse/Move()
	. = ..()
	if(stat != CONSCIOUS)
		return .

	if(!key)
		eat_cheese()
	else
		if(!(locate(/obj/structure/table) in get_turf(src)))
			for(var/obj/item/reagent_containers/glass/G in get_turf(src))
				G.throw_at(get_turf(G), 0, 1, src)
			for(var/obj/item/reagent_containers/food/drinks/D in get_turf(src))
				D.throw_at(get_turf(D), 0, 1, src)

/mob/living/simple_animal/mouse/proc/eat_cheese()
	var/obj/item/reagent_containers/food/snacks/cheesewedge/CW = locate(/obj/item/reagent_containers/food/snacks/cheesewedge) in loc
	if(!QDELETED(CW) && full == FALSE)
		say("Burp!")
		visible_message("<span class='warning'>[src] gobbles up the [CW].</span>")
		qdel(CW)
		full = TRUE
		addtimer(VARSET_CALLBACK(src, full, FALSE), 3 MINUTES)

/mob/living/simple_animal/mouse/attackby(obj/item/O, mob/user, params)
	if(istype(O, /obj/item/reagent_containers/food/snacks/cheesewedge))
		to_chat(user, "<span class='notice'>You feed [O] to [src].</span>")
		visible_message("[src] squeaks happily!")
		qdel(O)
	else
		return ..()

/mob/living/simple_animal/mouse/attack_ghost(mob/dead/observer/user)
	if(key)
		return ..()
	user.possess_mouse(src)

/mob/living/simple_animal/mouse/start_pulling(atom/movable/AM, state, force, supress_message)
	return FALSE

/mob/living/simple_animal/mouse/CtrlClickOn(atom/A)
	face_atom(A)
	if(!isturf(loc))
		return
	if(next_move > world.time)
		return
	if(!A.Adjacent(src))
		return

	if(!can_eat(A))
		return FALSE

	eating = TRUE
	layer = MOB_LAYER
	visible_message("<span class='danger'>[src] starts eating away [A]...</span>",
						 "<span class='notice'>You start eating the [A]...</span>")
	if(do_after(src, 30, FALSE, A))
		if(QDELETED(A))
			return
		visible_message("<span class='danger'>[src] finishes eating up [A]!</span>",
						 "<span class='notice'>You finish up eating [A]</span>")
		A.mouse_eat(src)
		GLOB.mouse_food_eaten++

	eating = FALSE
	layer = BELOW_OPEN_DOOR_LAYER

/mob/living/simple_animal/mouse/proc/can_eat(atom/A)
	. = FALSE

	if(eating)
		return FALSE
	if(is_type_in_list(A, GLOB.mouse_comestible))
		return TRUE
	if(istype(A, /obj/item/reagent_containers/food) && !(locate(/obj/structure/table) in get_turf(A)))
		return TRUE

/mob/living/simple_animal/mouse/proc/regen_health(amt = 5)
	var/overheal = max(health + amt - maxHealth, 0)
	adjustHealth(-amt)
	GLOB.food_for_next_mouse += overheal
	var/mice = FLOOR(GLOB.food_for_next_mouse / FOODPERMOUSE, 1)
	if(!mice)
		return

	GLOB.mouse_spawned += mice
	GLOB.food_for_next_mouse = max(GLOB.food_for_next_mouse - FOODPERMOUSE * mice, 0)
	SSminor_mapping.trigger_migration(mice)

/mob/living/simple_animal/mouse/proc/cheese_up()
	if(cheesed)
		cheese_time = cheese_time + 3 MINUTES
		return
	cheesed = TRUE
	regen_health(15)
	resize = 2
	update_transform()
	add_movespeed_modifier(MOVESPEED_ID_MOUSE_CHEESE, TRUE, 100, multiplicative_slowdown = -1)
	maxHealth = 30
	health = maxHealth
	to_chat(src, "<span class='userdanger'>You ate cheese! You are now stronger, bigger and faster!</span>")
	cheese_time = cheese_time + 3 MINUTES

/mob/living/simple_animal/mouse/proc/cheese_down()
	cheesed = FALSE
	maxHealth = 15
	health = maxHealth
	resize = 0.5
	update_transform()
	remove_movespeed_modifier(MOVESPEED_ID_MOUSE_CHEESE, TRUE)
	to_chat(src, "<span class='userdanger'>A feeling of sadness comes over you as the effects of the cheese wears off. You. Must. Get. More.</span>")

/atom/proc/mouse_eat(mob/living/simple_animal/mouse/M)
	M.regen_health()
	qdel(src)

/obj/item/reagent_containers/food/snacks/cheesewedge/mouse_eat(mob/living/simple_animal/mouse/M)
	M.cheese_up()
	qdel(src)

/obj/item/reagent_containers/food/snacks/cheesewheel/mouse_eat(mob/living/simple_animal/mouse/M)
	M.cheese_up()
	qdel(src)

/obj/item/reagent_containers/food/snacks/store/cheesewheel/mouse_eat(mob/living/simple_animal/mouse/M)
	M.cheese_up()
	qdel(src)

/obj/item/reagent_containers/food/snacks/customizable/cheesewheel/mouse_eat(mob/living/simple_animal/mouse/M)
	M.cheese_up()
	qdel(src)

/obj/item/grown/bananapeel/bluespace/mouse_eat(mob/living/simple_animal/mouse/M)
	var/teleport_radius = max(round(seed.potency / 10), 1)
	var/turf/T = get_turf(M)
	do_teleport(M, T, teleport_radius, channel = TELEPORT_CHANNEL_BLUESPACE)
	..()
