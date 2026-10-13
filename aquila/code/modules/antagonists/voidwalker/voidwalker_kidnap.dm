// AQUILA - pustka, do której trafiają porwani (tg: voidwalker_kidnap.dm)
// U tg to lazy template z mapą 32x32. Tu pustka powstaje w rezerwacji przy pierwszym porwaniu.

/// Pola pustki, na które trafiają porwani
GLOBAL_LIST_EMPTY(voidwalker_void)
/// Rezerwacja z pustką, tworzona raz na rundę
GLOBAL_DATUM(voidwalker_void_reservation, /datum/turf_reservation)

/// Wielkość pustki razem ze ścianami dookoła
#define VOIDWALKER_VOID_SIZE 34
/// Ile świecących kulek-jedzenia pływa po pustce
#define VOIDWALKER_VOID_FOOD 6

/area/centcom/voidwalker_void
	name = "Pustka"
	icon_state = "away"
	has_gravity = STANDARD_GRAVITY
	ambience_index = AMBIENCE_SPOOKY
	sound_environment = SOUND_ENVIRONMENT_CAVE
	area_flags = HIDDEN_AREA | BLOCK_SUICIDE | UNIQUE_AREA
	teleport_restriction = TELEPORT_ALLOW_NONE
	requires_power = FALSE
	dynamic_lighting = DYNAMIC_LIGHTING_FORCED

/turf/open/indestructible/voidwalker_void
	name = "pustka"
	desc = "Nic. Zupełnie nic."
	icon = 'icons/turf/floors.dmi'
	icon_state = "black"
	initial_gas_mix = OPENTURF_DEFAULT_ATMOS
	footstep = null
	barefootstep = null
	clawfootstep = null
	heavyfootstep = null

/turf/closed/indestructible/voidwalker_void
	name = "pustka"
	desc = "Nic. Zupełnie nic, i to bardzo twarde."
	icon = 'icons/turf/floors.dmi'
	icon_state = "black"
	opacity = TRUE // za ścianą nic nie widać, pustka wygląda na nieskończoną

/// Zwraca losowe pole pustki, w razie potrzeby najpierw ją tworząc
/proc/get_voidwalker_void_turf()
	if(!length(GLOB.voidwalker_void))
		create_voidwalker_void()
	if(!length(GLOB.voidwalker_void))
		return null
	return pick(GLOB.voidwalker_void)

/proc/create_voidwalker_void()
	if(GLOB.voidwalker_void_reservation)
		return
	var/datum/turf_reservation/reservation = SSmapping.RequestBlockReservation(VOIDWALKER_VOID_SIZE, VOIDWALKER_VOID_SIZE)
	if(!reservation)
		return
	GLOB.voidwalker_void_reservation = reservation
	var/area/centcom/voidwalker_void/void_area = GLOB.areas_by_type[/area/centcom/voidwalker_void] || new
	var/list/coords = reservation.bottom_left_coords
	var/list/floors = list()
	for(var/turf/T as anything in block(locate(coords[1], coords[2], coords[3]), locate(coords[1] + VOIDWALKER_VOID_SIZE - 1, coords[2] + VOIDWALKER_VOID_SIZE - 1, coords[3])))
		var/edge = T.x == coords[1] || T.y == coords[2] || T.x == coords[1] + VOIDWALKER_VOID_SIZE - 1 || T.y == coords[2] + VOIDWALKER_VOID_SIZE - 1
		var/turf/new_turf = T.ChangeTurf(edge ? /turf/closed/indestructible/voidwalker_void : /turf/open/indestructible/voidwalker_void)
		var/area/old_area = new_turf.loc
		old_area.contents -= new_turf
		void_area.contents += new_turf
		new_turf.change_area(old_area, void_area)
		if(!edge)
			floors += new_turf
	// Porwani lądują daleko od krawędzi
	for(var/turf/T as anything in floors)
		if(T.x > coords[1] + 2 && T.y > coords[2] + 2 && T.x < coords[1] + VOIDWALKER_VOID_SIZE - 3 && T.y < coords[2] + VOIDWALKER_VOID_SIZE - 3)
			GLOB.voidwalker_void += T
	for(var/i in 1 to VOIDWALKER_VOID_FOOD)
		new /obj/effect/wisp_food(pick(floors))

/// Samochodzik z duszą: porwany jeździ nim po pustce, je kulki i się leczy, zanim wróci na statek
/obj/effect/wisp_mobile
	name = "wisp"
	desc = "Mała, ciepła iskierka."
	icon = 'aquila/icons/obj/voidwalker_items.dmi'
	icon_state = "wisp"
	light_color = COLOR_WHITE
	light_range = 4
	light_power = 1
	/// Odstęp między krokami
	var/move_delay = 0.5 SECONDS
	/// Kiedy można się znów ruszyć
	var/next_move = 0
	/// Co jemy
	var/food_type = /obj/effect/wisp_food
	/// Ile leczy jedna kulka
	var/heal_per_food = 15
	/// Cechy kierowcy
	var/list/wisp_driver_traits = list(TRAIT_NOSOFTCRIT, TRAIT_NOHARDCRIT, TRAIT_NODEATH)
	/// Po jakim czasie wraca na statek
	var/ride_time = 60 SECONDS

/obj/effect/wisp_mobile/Entered(atom/movable/arrived, atom/old_loc)
	. = ..()
	if(!isliving(arrived))
		return
	var/mob/living/driver = arrived
	for(var/trait in wisp_driver_traits)
		ADD_TRAIT(driver, trait, REF(src))
	add_atom_colour(random_color_roll(1), FIXED_COLOUR_PRIORITY)
	to_chat(driver, "<span class='purple bold'>Unosisz się w pustce. Zbieraj świecące kulki, by się wyleczyć, zanim pustka cię wypluje.</span>")
	addtimer(CALLBACK(src, PROC_REF(send_back), driver), ride_time)

/// Wypluwa kierowcę w bezpieczne miejsce na statku
/obj/effect/wisp_mobile/proc/send_back(mob/living/driver)
	if(QDELETED(driver) || driver.loc != src)
		return
	var/list/turfs = get_safe_random_station_turfs()
	var/turf/destination = length(turfs) ? turfs[1] : get_random_station_turf()
	driver.forceMove(destination)

/obj/effect/wisp_mobile/relaymove(mob/living/user, direction)
	if(next_move > world.time || !isturf(loc))
		return
	next_move = world.time + move_delay
	var/turf/next_turf = get_step(src, direction)
	if(!next_turf)
		return
	if(next_turf.density)
		loop_around(direction)
		return
	forceMove(next_turf)

/obj/effect/wisp_mobile/Moved(atom/OldLoc, Dir)
	. = ..()
	var/obj/effect/wisp_food/food = locate(food_type) in loc
	if(!food)
		return
	qdel(food)
	var/list/floors = list()
	for(var/turf/open/T in get_area_turfs(get_area(src)))
		floors += T
	if(length(floors))
		new food_type(pick(floors))
	var/mob/living/driver = locate(/mob/living) in contents
	if(driver)
		driver.heal_ordered_damage(heal_per_food, list(BRUTE, BURN, OXY))
		playsound(src, 'sound/misc/server-ready.ogg', 50, TRUE, -1)

/obj/effect/wisp_mobile/Exited(atom/movable/gone, direction)
	. = ..()
	if(!isliving(gone))
		return
	for(var/trait in wisp_driver_traits)
		REMOVE_TRAIT(gone, trait, REF(src))
	to_chat(gone, "<span class='boldwarning'>Czujesz się obserwowany.</span>")
	qdel(src)

/obj/effect/wisp_mobile/Destroy()
	for(var/atom/movable/thing as anything in contents)
		thing.forceMove(get_turf(src))
	return ..()

/// Przy ścianie przeskakuje na drugą stronę pustki
/obj/effect/wisp_mobile/proc/loop_around(movement_dir)
	var/reversed_dir = turn(movement_dir, 180)
	var/turf/check_turf = get_turf(src)
	var/safety = VOIDWALKER_VOID_SIZE
	while(check_turf && !check_turf.density && safety--)
		check_turf = get_step(check_turf, reversed_dir)
	if(!check_turf?.density)
		return
	// Ściana po drugiej stronie znaleziona, dwa kroki od niej
	check_turf = get_step(get_step(check_turf, movement_dir), movement_dir)
	if(check_turf && !check_turf.density)
		forceMove(check_turf)

/// Kulka do zjedzenia przez wispy
/obj/effect/wisp_food
	name = "wisp"
	desc = "Mała, ciepła iskierka. Wygląda smacznie."
	icon = 'aquila/icons/obj/voidwalker_items.dmi'
	icon_state = "wisp"
	color = COLOR_YELLOW
	light_color = COLOR_WHITE
	light_range = 4
	light_power = 1

#undef VOIDWALKER_VOID_SIZE
#undef VOIDWALKER_VOID_FOOD
