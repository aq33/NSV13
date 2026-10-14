// AQUILA - zlecenie patrolu dla ochrony, port z tgstation (bounties/security.dm)

/// Zlecenie: przejdź wyznaczoną liczbę metrów po wskazanym obszarze statku
/datum/bounty/patrol
	name = "Patrol"
	description = "Przeprowadź rutynowy patrol: %AREA_NAME%. \
		Musisz przejść co najmniej %AREA_COVERAGE% metrów w tym obszarze. \
		Karta identyfikacyjna będzie informować cię o postępach."
	reward = 1000
	allow_duplicate = TRUE
	global_exempt = TRUE

	/// Komponent pilnujący ruchów karty, także gdy siedzi w portfelu, PDA albo w kieszeni
	var/datum/tracker
	/// Typ obszaru do patrolowania
	var/area/demanded_area
	/// Ile metrów trzeba przejść
	var/needed_coverage = -1
	/// "x,y,z" => ile razy wszedłeś na to pole
	var/list/walked_turfs
	/// Które powiadomienie o postępie już poszło (0-5)
	var/alerted = 0

/datum/bounty/patrol/New()
	var/list/possible_areas = list()
	for(var/area_type in get_patrol_area_types())
		if(GLOB.areas_by_type[area_type])
			possible_areas += area_type
	if(!length(possible_areas))
		return
	demanded_area = pick(possible_areas)

	var/total_coverage = 0
	for(var/turf/open/floor/walkable in GLOB.areas_by_type[demanded_area])
		total_coverage += 1

	needed_coverage = round(total_coverage * rand(4, 8) * 0.1, 1)

	var/area_name = initial(demanded_area.name)
	name += ": [area_name]"
	description = replacetext(description, "%AREA_NAME%", area_name)
	description = replacetext(description, "%AREA_COVERAGE%", "[needed_coverage]")

	// większe obszary płacą więcej, żeby długi patrol się opłacał
	reward = round(reward * (needed_coverage / 100))

/datum/bounty/patrol/Destroy()
	QDEL_NULL(tracker)
	return ..()

/datum/bounty/patrol/can_get()
	// tylko patrole warte zachodu
	return demanded_area && needed_coverage >= 20

/datum/bounty/patrol/proc/get_patrol_area_types()
	return typesof(
		/area/hallway,
		/area/maintenance,
		/area/crew_quarters/fitness,
		/area/crew_quarters/dorms,
		/area/crew_quarters/bar,
		/area/crew_quarters/theatre,
		/area/security/checkpoint,
		/area/security/prison,
		/area/hydroponics,
		/area/library,
		/area/chapel,
	)

/datum/bounty/patrol/proc/get_progress()
	var/progress = 0
	for(var/turf_id in walked_turfs)
		progress += walked_turfs[turf_id]
	return progress

/datum/bounty/patrol/completion_string()
	return "[get_progress()]/[needed_coverage] m"

/datum/bounty/patrol/get_total()
	return get_progress()

/datum/bounty/patrol/get_max()
	return needed_coverage

/datum/bounty/patrol/can_claim()
	return !claimed && get_progress() >= needed_coverage

/datum/bounty/patrol/on_selected(obj/item/card/id/id_card)
	start_tracking(id_card)

/datum/bounty/patrol/on_reset(obj/item/card/id/id_card)
	stop_tracking(id_card)

/datum/bounty/patrol/proc/start_tracking(obj/item/card/id/id_card)
	if(id_card.registered_account)
		contribution |= id_card.registered_account
	tracker = AddComponent(/datum/component/connect_containers, id_card, list(COMSIG_MOVABLE_MOVED = PROC_REF(on_card_moved)))
	RegisterSignal(id_card, COMSIG_MOVABLE_MOVED, PROC_REF(on_card_moved))

/datum/bounty/patrol/proc/stop_tracking(obj/item/card/id/id_card)
	QDEL_NULL(tracker)
	if(id_card)
		UnregisterSignal(id_card, COMSIG_MOVABLE_MOVED)

/datum/bounty/patrol/proc/on_card_moved(atom/movable/moving, atom/old_loc)
	SIGNAL_HANDLER

	var/turf/new_turf = get_turf(moving)
	if(!isfloorturf(new_turf) || new_turf == get_turf(old_loc) || new_turf.loc.type != demanded_area)
		return

	var/turf_id = "[new_turf.x],[new_turf.y],[new_turf.z]"
	// po tych samych polach można chodzić, ale najwyżej trzy razy - bez dreptania w kółko
	if(LAZYACCESS(walked_turfs, turf_id) >= 3)
		return

	var/obj/item/card/id/id_card
	if(isliving(moving))
		var/mob/living/living_mover = moving
		id_card = living_mover.get_idcard()
	else if(istype(moving, /obj/item/card/id))
		id_card = moving
	if(isnull(id_card))
		id_card = locate(/obj/item/card/id) in moving.GetAllContents()

	if(id_card?.registered_account?.civilian_bounty != src)
		return

	LAZYADDASSOC(walked_turfs, turf_id, 1)
	var/progress = get_progress()
	var/datum/bank_account/account = id_card.registered_account
	if(alerted == 0)
		alerted = 1
		account.bank_card_talk("Patrol rozpoczęty. Przejdź [needed_coverage] metrów w obszarze, by go ukończyć.", TRUE)
		return

	var/progress_percent = progress / needed_coverage
	if(progress >= needed_coverage && alerted < 5)
		alerted = 5
		account.bank_card_talk("Patrol ukończony. Wróć do konsoli zleceń, by odebrać nagrodę.", TRUE)
		stop_tracking(id_card)
		return

	if(progress_percent >= 0.75 && alerted < 4)
		alerted = 4
		account.bank_card_talk("Patrol ukończony w 75%.", TRUE)
		return

	if(progress_percent >= 0.5 && alerted < 3)
		alerted = 3
		account.bank_card_talk("Patrol ukończony w 50%.", TRUE)
		return

	if(progress_percent >= 0.25 && alerted < 2)
		alerted = 2
		account.bank_card_talk("Patrol ukończony w 25%.", TRUE)
