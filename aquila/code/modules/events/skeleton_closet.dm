// AQUILA - Skeleton in the Closet: a hostile skeleton waits in a random locker on the ship.
// It sits still until someone opens the locker (or it gets broken), then jumps out and attacks.

/datum/round_event_control/aquila_skeleton_closet
	name = "Skeleton in the Closet"
	typepath = /datum/round_event/aquila_skeleton_closet
	weight = 10
	max_occurrences = 2
	earliest_start = 10 MINUTES

/datum/round_event/aquila_skeleton_closet
	fakeable = FALSE

/datum/round_event/aquila_skeleton_closet/start()
	var/list/closets = aquila_skeleton_closet_candidates()
	if(!length(closets))
		message_admins("Skeleton in the Closet event found no closed locker on the ship, nothing was spawned.")
		log_game("Skeleton in the Closet event found no closed locker on the ship, nothing was spawned.")
		return
	var/obj/structure/closet/closet = pick(closets)
	var/mob/living/simple_animal/hostile/skeleton/closet_lurker/skeleton = new(closet)
	announce_to_ghosts(closet)
	message_admins("Skeleton in the Closet event hid [skeleton] in [closet] at [ADMIN_VERBOSEJMP(closet)].")
	log_game("Skeleton in the Closet event hid [skeleton] in [closet] at [AREACOORD(closet)].")

/// Closed lockers on the ship that a skeleton can hide in, crates, body bags and other odd containers are left out
/proc/aquila_skeleton_closet_candidates()
	var/static/list/excluded_closets = typecacheof(list(
		/obj/structure/closet/crate,
		/obj/structure/closet/body_bag,
		/obj/structure/closet/cardboard,
		/obj/structure/closet/supplypod,
		/obj/structure/closet/stasis,
		/obj/structure/closet/abductor,
		/obj/structure/closet/infinite,
		/obj/structure/closet/decay,
	))
	. = list()
	for(var/obj/structure/closet/closet in world)
		if(closet.opened || closet.welded || !isturf(closet.loc) || !is_station_level(closet.z))
			continue
		if(is_type_in_typecache(closet, excluded_closets))
			continue
		if(locate(/mob/living) in closet) // someone is already hiding there
			continue
		. += closet
		CHECK_TICK

/// A skeleton that keeps its AI off while it waits in a locker and wakes up once it is let out
/mob/living/simple_animal/hostile/skeleton/closet_lurker
	name = "trup z szafy"
	desc = "Ktoś bardzo długo czekał w tej szafie. Chyba nie jest zadowolony, że to tyle trwało."
	gold_core_spawnable = NO_SPAWN

/mob/living/simple_animal/hostile/skeleton/closet_lurker/Initialize(mapload)
	. = ..()
	if(istype(loc, /obj/structure/closet))
		toggle_ai(AI_OFF) // a wandering AI would push the door open by itself

/mob/living/simple_animal/hostile/skeleton/closet_lurker/Moved(atom/OldLoc, Dir, Forced = FALSE)
	. = ..()
	if(AIStatus != AI_OFF || client || stat != CONSCIOUS)
		return
	if(!istype(OldLoc, /obj/structure/closet) || istype(loc, /obj/structure/closet))
		return
	visible_message("<span class='userdanger'>[src] wyskakuje z szafy!</span>")
	playsound(src, 'sound/hallucinations/growl1.ogg', 75, TRUE)
	toggle_ai(AI_ON)
