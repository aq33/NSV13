// AQUILA - Komora testowa: osobny pokój w rezerwacji do szybkiego sprawdzania PR-ów.
// Admin wchodzi przez Debug -> "Komora testowa", a konsola w środku zrzuca zestawy z kits/.
// Jak dodać zestaw dla nowego PR - patrz aquila/code/modules/test_chamber/kits/_kit.dm

GLOBAL_DATUM(test_chamber, /datum/test_chamber)

/area/test_chamber
	name = "Komora testowa"
	icon_state = "away"
	requires_power = FALSE
	has_gravity = STANDARD_GRAVITY
	dynamic_lighting = DYNAMIC_LIGHTING_FORCED
	area_flags = HIDDEN_AREA | UNIQUE_AREA

/// Część komory, w której pojawiają się zestawy
/area/test_chamber/arena
	name = "Komora testowa - arena"

/datum/map_template/test_chamber
	name = "Komora testowa"
	mappath = 'aquila/_maps/templates/test_chamber.dmm'
	keep_cached_map = TRUE

/obj/effect/landmark/test_chamber
	name = "test chamber marker"

/// Tu ląduje admin po wejściu do komory
/obj/effect/landmark/test_chamber/arrival
	name = "test chamber arrival"

/// Środek areny, wokół którego rozkładane są zestawy
/obj/effect/landmark/test_chamber/kit_center
	name = "test chamber kit center"

/datum/test_chamber
	var/datum/map_template/test_chamber/template
	var/datum/turf_reservation/reservation
	var/turf/arrival
	var/turf/kit_center

/// Zwraca komorę, ładując ją przy pierwszym użyciu w rundzie
/proc/get_test_chamber()
	if(!GLOB.test_chamber)
		var/datum/test_chamber/chamber = new
		if(!chamber.load())
			qdel(chamber)
			return null
		GLOB.test_chamber = chamber
	return GLOB.test_chamber

/datum/test_chamber/proc/load()
	template = new
	reservation = SSmapping.RequestBlockReservation(template.width, template.height)
	if(!reservation)
		log_world("Test chamber: unable to reserve space")
		return FALSE
	return place_template()

/datum/test_chamber/proc/bottom_left()
	return locate(reservation.bottom_left_coords[1], reservation.bottom_left_coords[2], reservation.bottom_left_coords[3])

/datum/test_chamber/proc/place_template()
	if(!template.load(bottom_left()))
		log_world("Test chamber: unable to load the template")
		return FALSE
	arrival = null
	kit_center = null
	for(var/turf/T as anything in reservation.reserved_turfs)
		for(var/obj/effect/landmark/test_chamber/L in T)
			if(istype(L, /obj/effect/landmark/test_chamber/arrival))
				arrival = T
			else if(istype(L, /obj/effect/landmark/test_chamber/kit_center))
				kit_center = T
			qdel(L)
	if(!arrival || !kit_center)
		log_world("Test chamber: the template is missing its landmarks")
		return FALSE
	return TRUE

/// Usuwa wszystko poza graczami (i tym, co mają przy sobie) i układa komorę od nowa
/datum/test_chamber/proc/reset()
	for(var/turf/T as anything in reservation.reserved_turfs)
		for(var/atom/movable/AM as anything in T)
			if(ismob(AM))
				var/mob/M = AM
				if(M.key || isobserver(M))
					continue
			else if(!isobj(AM))
				continue // lighting objects itp.
			qdel(AM)
	for(var/turf/T as anything in reservation.reserved_turfs)
		// Świeży turf tego samego typu: czyste powietrze, bez spalonej i rozbitej podłogi
		T.ChangeTurf(T.type, flags = CHANGETURF_FORCEOP | CHANGETURF_IGNORE_AIR)
	return place_template()

/datum/test_chamber/proc/contains(atom/A)
	var/turf/T = get_turf(A)
	return T && (T in reservation.reserved_turfs)

/// Wolne turfy areny, od środka na zewnątrz
/datum/test_chamber/proc/free_arena_turfs()
	. = list()
	var/max_range = max(reservation.width, reservation.height)
	for(var/r in 0 to max_range)
		for(var/turf/open/T in block(locate(kit_center.x - r, kit_center.y - r, kit_center.z), locate(kit_center.x + r, kit_center.y + r, kit_center.z)))
			if(get_dist(T, kit_center) != r || !istype(T.loc, /area/test_chamber/arena) || is_blocked_turf(T, TRUE))
				continue
			. += T

/datum/test_chamber/proc/spawn_kit(datum/test_chamber_kit/kit, mob/user)
	var/list/turfs = free_arena_turfs()
	if(!length(turfs))
		to_chat(user, "<span class='warning'>Na arenie nie ma już miejsca, zresetuj komorę.</span>")
		return
	kit.spawn_kit(turfs, kit_center, user)
	log_admin("[key_name(user)] spawned test chamber kit \"[kit.name]\"[kit.pr ? " ([kit.pr])" : ""]")
	if(kit.description)
		to_chat(user, "<span class='notice'><b>[kit.name]</b>[kit.pr ? " ([kit.pr])" : ""]: [kit.description]</span>")

/// Lista zestawów do wyboru: nazwa do wyświetlenia -> datum
/proc/test_chamber_kits()
	var/static/list/kits
	if(!kits)
		kits = list()
		for(var/path in subtypesof(/datum/test_chamber_kit))
			var/datum/test_chamber_kit/kit = new path
			if(!kit.name)
				continue
			kits["[kit.name][kit.pr ? " ([kit.pr])" : ""]"] = kit
		kits = sortList(kits)
	return kits

/// Wspólne menu dla czasownika admina i konsoli w komorze
/datum/test_chamber/proc/menu(mob/user)
	var/list/kits = test_chamber_kits()
	var/list/options = list("Zresetuj komorę") + kits
	var/choice = tgui_input_list(user, "Zestawy z PR-ów pojawiają się na środku areny.", "Komora testowa", options)
	if(!choice || QDELETED(user))
		return
	if(choice == "Zresetuj komorę")
		if(tgui_alert(user, "Usunąć wszystko z komory (poza graczami) i ułożyć ją od nowa?", "Komora testowa", list("Tak", "Nie")) != "Tak")
			return
		log_admin("[key_name(user)] reset the test chamber")
		if(reset())
			to_chat(user, "<span class='notice'>Komora wyczyszczona.</span>")
		return
	spawn_kit(kits[choice], user)

/client/proc/test_chamber()
	set category = "Debug"
	set name = "Komora testowa"
	set desc = "Przenosi do komory testowej, gdzie można zrzucić zestawy przedmiotów z PR-ów."

	if(!check_rights(R_DEBUG))
		return
	var/datum/test_chamber/chamber = get_test_chamber()
	if(!chamber)
		to_chat(src, "<span class='warning'>Nie udało się załadować komory testowej, szczegóły w logu.</span>")
		return
	if(chamber.contains(mob))
		chamber.menu(mob)
		return
	log_admin("[key_name(src)] jumped to the test chamber")
	message_admins("[key_name_admin(src)] wszedł do komory testowej.")
	mob.forceMove(chamber.arrival)

/obj/machinery/computer/test_chamber
	name = "konsola komory testowej"
	desc = "Zrzuca zestawy przedmiotów z testowanych PR-ów i sprząta po testach."
	icon_screen = "comm_logs"
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF

/obj/machinery/computer/test_chamber/interact(mob/user)
	. = ..()
	var/datum/test_chamber/chamber = GLOB.test_chamber
	if(!chamber?.contains(src))
		to_chat(user, "<span class='warning'>Konsola działa tylko w komorze testowej.</span>")
		return
	chamber.menu(user)
