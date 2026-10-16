// AQUILA - Recovered Crew delivery: now and then Central Command sends a body bag (with the instruction card) by pod
// to the cargo bay, free of charge. Reuses the stray cargo pod event, only the landing area and the contents differ.

/datum/round_event_control/aquila_stray_cargo/lost_crew
	name = "Recovered Crew Delivery"
	typepath = /datum/round_event/aquila_stray_cargo/lost_crew
	weight = 10
	max_occurrences = 2
	earliest_start = 20 MINUTES
	min_players = 5

/datum/round_event/aquila_stray_cargo/lost_crew

/datum/round_event/aquila_stray_cargo/lost_crew/announce(fake)
	if(fake)
		impact_area = find_event_area()
	else if(!landing_zone)
		return
	priority_announce("Centrala przesyła kapsułą zwłoki członka załogi odzyskane z wraku. Miejsce lądowania: [impact_area?.name || "nieznane"]. Dział medyczny proszony o odbiór i reanimację, za sukces przewidziano premię.", "Dział Odzysku Załogi")

/datum/round_event/aquila_stray_cargo/lost_crew/get_contents()
	return new /obj/structure/closet/body_bag/lost_crew/with_body()

/// Lands in the cargo bay, or anywhere safe if the map has no free cargo floor
/datum/round_event/aquila_stray_cargo/lost_crew/find_event_area()
	var/static/list/cargo_area_types = typecacheof(list(
		/area/quartermaster/storage,
		/area/quartermaster/office,
		/area/quartermaster/sorting,
		/area/quartermaster/warehouse,
		/area/cargo/lobby,
	))
	var/list/cargo_areas = list()
	for(var/area/A as anything in GLOB.sortedAreas)
		if((A.type in GLOB.the_station_areas) && is_type_in_typecache(A, cargo_area_types))
			cargo_areas += A
	while(length(cargo_areas))
		var/area/candidate = pick_n_take(cargo_areas)
		for(var/turf/open/T in candidate)
			if(!isspaceturf(T) && !is_blocked_turf(T, TRUE))
				return candidate
	return ..()
