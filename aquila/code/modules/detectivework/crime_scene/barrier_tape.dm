// AQUILA - taśma policyjna (wzór: Yogstation barriertape.dm i Baystation12 policetape.dm, AGPL;
// zerwanie zostawiające ślad - pomysł z Goonstation, kod własny).
//
// Rolka: użyj w ręce na początku linii, przejdź na koniec i użyj jeszcze raz. Klik rolką w drzwi oklei drzwi.
// Ochrona (dostęp Security) unosi taśmę, wchodząc w nią. Reszta musi się pod nią przecisnąć (klik bez combat mode),
// zerwać odcinek (combat mode) albo przeciąć całą linię ostrym przedmiotem. Każdy z tych sposobów zostawia na taśmie
// odciski i włókna, a zgnieciona albo zerwana taśma od razu pokazuje, że ktoś tędy przeszedł.

#define TAPE_MAX_LENGTH 12

/obj/item/barrier_tape_roll
	name = "rolka taśmy policyjnej"
	desc = "Rolka taśmy policyjnej do odgradzania miejsca zbrodni. Użyj w ręce na początku i na końcu odcinka albo kliknij nią drzwi."
	icon = 'aquila/icons/obj/crime_scene/barriertape.dmi'
	icon_state = "police_start"
	w_class = WEIGHT_CLASS_SMALL
	/// Typ rozciąganej taśmy
	var/tape_type = /obj/structure/barrier_tape/police
	/// Prefiks stanów ikon
	var/icon_base = "police"
	/// Kratka, na której zaczęto rozciągać taśmę
	var/turf/start

/obj/item/barrier_tape_roll/Destroy()
	start = null
	return ..()

/obj/item/barrier_tape_roll/dropped(mob/user, silent)
	. = ..()
	if(start)
		start = null
		icon_state = "[icon_base]_start"

/obj/item/barrier_tape_roll/attack_self(mob/user)
	var/turf/here = get_turf(user)
	if(!here)
		return
	if(!start)
		start = here
		icon_state = "[icon_base]_stop"
		to_chat(user, "<span class='notice'>Przyczepiasz koniec taśmy. Przejdź na drugi koniec odcinka i użyj rolki jeszcze raz.</span>")
		return
	var/turf/first = start
	start = null
	icon_state = "[icon_base]_start"
	lay_line(first, here, user)

/// Rozciąga taśmę w linii prostej od first do last (włącznie).
/obj/item/barrier_tape_roll/proc/lay_line(turf/first, turf/last, mob/user)
	if(first.z != last.z || (first.x != last.x && first.y != last.y))
		to_chat(user, "<span class='warning'>Taśmę da się rozciągnąć tylko w poziomie albo w pionie.</span>")
		return
	if(get_dist(first, last) >= TAPE_MAX_LENGTH)
		to_chat(user, "<span class='warning'>Odcinek jest za długi. Taśma ma najwyżej [TAPE_MAX_LENGTH] kratek.</span>")
		return
	var/tape_dir = (first.x == last.x) ? "v" : "h"
	var/list/turf/line = getline(first, last)
	for(var/turf/T as anything in line)
		if(T.density || isspaceturf(T))
			to_chat(user, "<span class='warning'>Nie da się przeciągnąć taśmy przez [T].</span>")
			return
		for(var/obj/O in T)
			if(O.density && !istype(O, /obj/structure/barrier_tape) && !istype(O, /obj/machinery/door))
				to_chat(user, "<span class='warning'>Na drodze taśmy stoi [O].</span>")
				return
	var/placed = 0
	var/line_id = "[REF(user)]-[world.time]"
	for(var/turf/T as anything in line)
		var/already = FALSE
		for(var/obj/structure/barrier_tape/existing in T)
			if(existing.tape_dir == tape_dir)
				already = TRUE
				break
		if(already)
			continue
		var/obj/structure/barrier_tape/tape = new tape_type(T, tape_dir)
		tape.line_id = line_id
		tape.add_hiddenprint(user)
		placed++
	playsound(user, 'sound/items/poster_being_created.ogg', 30, TRUE)
	user.visible_message("<span class='notice'>[user] rozciąga taśmę.</span>", "<span class='notice'>Rozciągasz taśmę na [placed] kratkach.</span>")

// pre_attack, a nie afterattack: inaczej klik w drzwi najpierw by je otworzył (u nas TRUE = kontynuuj atak)
/obj/item/barrier_tape_roll/pre_attack(atom/target, mob/living/user, params)
	if(!istype(target, /obj/machinery/door) || user.combat_mode)
		return ..()
	INVOKE_ASYNC(src, PROC_REF(tape_door), target, user)
	return FALSE

/obj/item/barrier_tape_roll/proc/tape_door(obj/machinery/door/target, mob/user)
	var/turf/T = get_turf(target)
	for(var/obj/structure/barrier_tape/existing in T)
		if(existing.tape_dir == "door")
			to_chat(user, "<span class='warning'>Te drzwi są już oklejone taśmą.</span>")
			return
	user.visible_message("<span class='notice'>[user] zaczyna oklejać drzwi taśmą.</span>", "<span class='notice'>Oklejasz drzwi taśmą...</span>")
	if(!do_after(user, 1 SECONDS, target = target))
		return
	var/obj/structure/barrier_tape/tape = new tape_type(T, "door")
	tape.add_hiddenprint(user)
	playsound(user, 'sound/items/poster_being_created.ogg', 30, TRUE)

/obj/structure/barrier_tape
	name = "taśma odgradzająca"
	desc = "Taśma odgradzająca. Lepiej jej nie przekraczać."
	icon = 'aquila/icons/obj/crime_scene/barriertape.dmi'
	icon_state = "police_h"
	anchored = TRUE
	density = TRUE
	layer = ABOVE_OBJ_LAYER
	max_integrity = 10
	req_access = list(ACCESS_SECURITY)
	/// Prefiks stanów ikon
	var/icon_base = "police"
	/// "h", "v" albo "door"
	var/tape_dir = "h"
	/// Taśma uniesiona (można przejść)
	var/lifted = FALSE
	/// Zgnieciona - ktoś się pod nią przecisnął
	var/crumpled = FALSE
	/// Zerwana - nie blokuje przejścia
	var/torn = FALSE
	/// Typ strzępu zostawianego po przecięciu
	var/scrap_type = /obj/item/barrier_tape_scrap
	/// Odcinki rozciągnięte jednym ruchem mają ten sam identyfikator; przecięcie usuwa tylko je
	var/line_id

/obj/structure/barrier_tape/police
	name = "taśma policyjna"
	desc = "Taśma policyjna: MIEJSCE ZBRODNI - NIE PRZEKRACZAĆ. Ochrona może ją unieść, reszta zostawi na niej ślady."

/obj/structure/barrier_tape/Initialize(mapload, new_dir)
	. = ..()
	if(new_dir)
		tape_dir = new_dir
	update_tape_icon()
	var/static/list/loc_connections = list(
		COMSIG_ATOM_ENTERED = PROC_REF(on_entered),
	)
	AddElement(/datum/element/connect_loc, loc_connections)

/obj/structure/barrier_tape/proc/update_tape_icon()
	icon_state = "[icon_base]_[tape_dir][(crumpled || torn) ? "_c" : ""]"
	if(tape_dir == "door")
		layer = ABOVE_OBJ_LAYER
	else
		layer = initial(layer)

/obj/structure/barrier_tape/examine(mob/user)
	. = ..()
	if(torn)
		. += "<span class='warning'>Jest zerwana.</span>"
	else if(crumpled)
		. += "<span class='notice'>Jest pognieciona, jakby ktoś się pod nią przeciskał.</span>"

/obj/structure/barrier_tape/CanAllowThrough(atom/movable/mover, turf/target)
	. = ..()
	if(.)
		return
	if(lifted || torn)
		return TRUE
	if(!isliving(mover))
		return TRUE
	var/mob/living/L = mover
	if(issilicon(L) || L.stat || !(L.mobility_flags & MOBILITY_STAND))
		return TRUE // nieprzytomnych da się przeciągnąć, a czołgający się mieszczą się pod taśmą
	return FALSE

/obj/structure/barrier_tape/proc/on_entered(datum/source, atom/movable/AM)
	SIGNAL_HANDLER
	if(!ishuman(AM))
		return
	var/mob/living/carbon/human/H = AM
	if(H.stat || allowed(H))
		return
	add_fingerprint(H)
	if(!torn && !crumpled)
		crumple()

/obj/structure/barrier_tape/Bumped(atom/movable/AM)
	. = ..()
	if(!isliving(AM) || lifted || torn)
		return
	var/mob/living/L = AM
	if(allowed(L))
		lift_tape(2 SECONDS)
		to_chat(L, "<span class='notice'>Unosisz taśmę i przechodzisz pod spodem.</span>")
		return
	add_fingerprint(L)
	if(L.combat_mode)
		tear(L)
		return
	if(L.client && !TIMER_COOLDOWN_CHECK(L, "barrier_tape_warning"))
		TIMER_COOLDOWN_START(L, "barrier_tape_warning", 3 SECONDS)
		to_chat(L, "<span class='warning'>Nie wolno przekraczać tej taśmy. Możesz się pod nią przecisnąć (kliknij ją), zerwać ją w combat mode albo przeciąć czymś ostrym.</span>")

/obj/structure/barrier_tape/attack_hand(mob/living/user)
	. = ..()
	if(.)
		return
	add_fingerprint(user)
	if(user.combat_mode)
		tear(user)
		return TRUE
	if(torn)
		user.visible_message("<span class='notice'>[user] zdejmuje zerwaną taśmę.</span>", "<span class='notice'>Zdejmujesz zerwaną taśmę.</span>")
		leave_scrap(user)
		qdel(src)
		return TRUE
	if(allowed(user))
		user.visible_message("<span class='notice'>[user] unosi taśmę.</span>", "<span class='notice'>Unosisz taśmę.</span>")
		lift_tape(4 SECONDS)
		return TRUE
	user.visible_message("<span class='notice'>[user] próbuje przecisnąć się pod taśmą.</span>", "<span class='notice'>Przeciskasz się pod taśmą...</span>")
	if(!do_after(user, 1.5 SECONDS, target = src))
		return TRUE
	add_fingerprint(user)
	crumple()
	lift_tape(2 SECONDS)
	return TRUE

/obj/structure/barrier_tape/attackby(obj/item/I, mob/living/user, params)
	add_fingerprint(user)
	if(I.is_sharp())
		cut_line(user, I)
		return TRUE
	if(user.combat_mode)
		tear(user)
		return TRUE
	if(allowed(user))
		lift_tape(4 SECONDS)
		to_chat(user, "<span class='notice'>Unosisz taśmę.</span>")
		return TRUE
	to_chat(user, "<span class='warning'>Tym nie przetniesz taśmy.</span>")
	return TRUE

/obj/structure/barrier_tape/proc/crumple()
	crumpled = TRUE
	update_tape_icon()

/obj/structure/barrier_tape/proc/lift_tape(duration)
	lifted = TRUE
	addtimer(VARSET_CALLBACK(src, lifted, FALSE), duration, TIMER_UNIQUE | TIMER_OVERRIDE)

/// Zerwanie jednego odcinka z rozpędu. Odcinek zostaje (z odciskami), ale nie blokuje.
/obj/structure/barrier_tape/proc/tear(mob/living/user)
	if(torn)
		return
	torn = TRUE
	update_tape_icon()
	playsound(src, 'sound/items/poster_ripped.ogg', 60, TRUE)
	user.visible_message("<span class='warning'>[user] zrywa taśmę!</span>", "<span class='warning'>Zrywasz taśmę!</span>")
	log_game("[key_name(user)] tore [src] at [AREACOORD(src)]")

/// Strzęp zostaje na podłodze i niesie odciski z taśmy.
/obj/structure/barrier_tape/proc/leave_scrap(mob/living/user)
	var/obj/item/scrap = new scrap_type(drop_location())
	transfer_fingerprints_to(scrap)
	if(user)
		scrap.add_fingerprint(user)
	return scrap

/// Przecięcie całej linii. Na miejscu cięcia zostaje strzęp z odciskami.
/obj/structure/barrier_tape/proc/cut_line(mob/living/user, obj/item/tool)
	user.visible_message("<span class='warning'>[user] przecina taśmę!</span>", "<span class='warning'>Przecinasz taśmę.</span>")
	playsound(src, 'sound/items/poster_ripped.ogg', 80, TRUE)
	log_game("[key_name(user)] cut [src] at [AREACOORD(src)]")
	var/obj/item/scrap = leave_scrap(user)
	if(tape_dir != "door" && line_id)
		var/list/dirs = (tape_dir == "h") ? list(EAST, WEST) : list(NORTH, SOUTH)
		for(var/direction in dirs)
			var/turf/T = get_step(src, direction)
			var/steps = 0
			while(T && steps < TAPE_MAX_LENGTH)
				var/obj/structure/barrier_tape/next
				for(var/obj/structure/barrier_tape/candidate in T)
					if(candidate.line_id == line_id && !QDELETED(candidate))
						next = candidate
						break
				if(!next)
					break
				// Odciski z każdego usuwanego odcinka trafiają na strzęp
				next.transfer_fingerprints_to(scrap)
				qdel(next)
				T = get_step(T, direction)
				steps++
	qdel(src)

/obj/item/barrier_tape_scrap
	name = "strzęp taśmy policyjnej"
	desc = "Strzęp zerwanej taśmy policyjnej. Może mieć na sobie ślady tego, kto ją zerwał."
	icon = 'aquila/icons/obj/crime_scene/barriertape.dmi'
	icon_state = "police_h_c"
	w_class = WEIGHT_CLASS_TINY
	resistance_flags = FLAMMABLE

#undef TAPE_MAX_LENGTH
