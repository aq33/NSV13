// AQUILA - objectives that make the traitor bring a device somewhere.
// bomb: TauCetiStation/TauCetiClassic objective "bomb", bug: tgstation progression traitors bug_room (via DaedalusDock),
// tide bug: tgstation progression traitors tide_bug_department (via Monkestation), telecomms data: TauCetiStation/TauCetiClassic,
// communications console hack: tgstation progression traitors hack_comm_console, with NSV threats.

/// Base for "plant this device in that area" objectives
/datum/objective/plant_device
	name = "podłóż urządzenie"
	martyr_compatible = TRUE
	/// Area types the target area can be picked from
	var/list/candidate_area_types = list()
	/// How many of the candidate areas count as targets
	var/target_area_count = 1
	/// Areas where the device has to be planted
	var/list/area/target_areas = list()
	/// Device given to the traitor
	var/device_type = /obj/item/traitor_device
	/// The device we gave out, planted or not
	var/obj/item/device
	/// TRUE once the device is planted in a target area
	var/planted = FALSE

/datum/objective/plant_device/traitor_roll_setup(datum/antagonist/traitor/rolling)
	if(!pick_target_areas())
		return FALSE
	update_explanation_text()
	give_device()
	return TRUE

/datum/objective/plant_device/proc/pick_target_areas()
	var/list/possible_areas = get_station_areas_of_types(candidate_area_types)
	target_areas = list()
	while(length(possible_areas) && length(target_areas) < target_area_count)
		target_areas += pick_n_take(possible_areas)
	return length(target_areas)

/datum/objective/plant_device/proc/give_device()
	var/datum/mind/receiver = owner || pick(get_owners())
	if(!receiver?.current)
		return
	device = new device_type(get_turf(receiver.current))
	if(istype(device, /obj/item/traitor_device))
		var/obj/item/traitor_device/traitor_device = device
		traitor_device.objective = src
	if(ishuman(receiver.current))
		var/mob/living/carbon/human/H = receiver.current
		H.equip_in_one_of_slots(device, list("backpack" = ITEM_SLOT_BACKPACK, "left pocket" = ITEM_SLOT_LPOCKET, "right pocket" = ITEM_SLOT_RPOCKET, "hands" = ITEM_SLOT_HANDS))

/datum/objective/plant_device/proc/target_area_names()
	var/list/names = list()
	for(var/area/A as anything in target_areas)
		names += A.name
	return english_list(names, and_text = " lub ")

/datum/objective/plant_device/proc/is_target_area(area/A)
	return A in target_areas

/// Called by the device when it got planted in a target area
/datum/objective/plant_device/proc/on_planted(obj/item/traitor_device/planted_device)
	planted = TRUE

/datum/objective/plant_device/check_completion()
	if(completed)
		return TRUE
	return planted && !QDELETED(device) && device.anchored && is_target_area(get_area(device))

/datum/objective/plant_device/admin_edit(mob/admin)
	if(!length(target_areas) && pick_target_areas())
		update_explanation_text()
	if(!device)
		give_device()

/// A device planted with a short do_after while standing in the target area
/obj/item/traitor_device
	name = "urządzenie Syndykatu"
	desc = "Małe urządzenie z czerwoną diodą."
	icon = 'icons/obj/device.dmi'
	icon_state = "syndbeacon"
	w_class = WEIGHT_CLASS_SMALL
	/// The objective this device belongs to
	var/datum/objective/plant_device/objective
	/// How long planting takes
	var/plant_time = 5 SECONDS
	/// TRUE once planted
	var/planted = FALSE

/obj/item/traitor_device/Destroy()
	objective = null
	return ..()

/obj/item/traitor_device/examine(mob/user)
	. = ..()
	if(objective && user.mind && (user.mind in objective.get_owners()))
		. += "<span class='notice'>Trzeba je podłożyć w: [objective.target_area_names()]. Użyj go w ręce na miejscu.</span>"

/obj/item/traitor_device/attack_self(mob/user)
	if(planted)
		return
	if(!objective || !objective.is_target_area(get_area(user)))
		balloon_alert(user, "to nie to miejsce!")
		return
	balloon_alert(user, "podkładasz...")
	if(!do_after(user, plant_time, target = user))
		return
	if(planted || !objective.is_target_area(get_area(user)))
		return
	plant(user)

/obj/item/traitor_device/proc/plant(mob/user)
	if(!user.transferItemToLoc(src, get_turf(user)))
		return
	planted = TRUE
	anchored = TRUE
	alpha = 120
	layer = LOW_OBJ_LAYER
	balloon_alert(user, "podłożone")
	log_game("[key_name(user)] planted [src] in [AREACOORD(src)].")
	objective?.on_planted(src)

/// Removing a planted device takes some effort
/obj/item/traitor_device/attack_hand(mob/user)
	if(planted && anchored)
		user.visible_message("<span class='warning'>[user] zaczyna odczepiać [src].</span>", "<span class='notice'>Zaczynasz odczepiać [src]...</span>")
		if(!do_after(user, 3 SECONDS, target = src))
			return TRUE
		anchored = FALSE
		planted = FALSE
		alpha = initial(alpha)
		layer = initial(layer)
		if(objective)
			objective.planted = FALSE
	return ..()

// Bug a head's office

/datum/objective/plant_device/bug
	name = "podsłuch"
	device_type = /obj/item/traitor_device/bug
	candidate_area_types = list(
		/area/crew_quarters/heads/captain,
		/area/crew_quarters/heads/hop,
		/area/crew_quarters/heads/chief,
		/area/crew_quarters/heads/hor,
		/area/crew_quarters/heads/cmo,
		/area/crew_quarters/heads/hos,
		/area/nsv/crew_quarters/heads/maa,
	)

/datum/objective/plant_device/bug/update_explanation_text()
	explanation_text = "Podłóż podsłuch w [target_area_names()] i dopilnuj, by przetrwał do końca zmiany. Uważaj na odciski palców i włókna."

/obj/item/traitor_device/bug
	name = "pluskwa"
	desc = "Malutki nadajnik podsłuchowy."
	icon = 'icons/obj/device.dmi'
	icon_state = "camera_bug"
	w_class = WEIGHT_CLASS_TINY

// Tide bug - messes with all doors of a department a minute after being planted

/datum/objective/plant_device/tide
	name = "wirus T1de"
	device_type = /obj/item/traitor_device/tide
	/// Department name = its area types
	var/static/list/departments = list(
		"zaopatrzenie" = list(/area/quartermaster),
		"medyczny" = list(/area/medical),
		"naukowy" = list(/area/science),
		"inżynieria" = list(/area/engine),
		"amunicja" = list(/area/nsv/weapons, /area/nsv/magazine),
	)
	var/department_name

/datum/objective/plant_device/tide/pick_target_areas()
	var/list/shuffled = shuffle(departments.Copy())
	for(var/name in shuffled)
		var/list/areas = get_station_areas_of_types(departments[name])
		if(length(areas))
			department_name = name
			target_areas = areas
			return TRUE
	return FALSE

/datum/objective/plant_device/tide/target_area_names()
	return "dziale: [department_name]"

/datum/objective/plant_device/tide/update_explanation_text()
	explanation_text = "Zakłóć pracę działu ([department_name]), podkładając w nim wirusa T1de. Minutę po podłożeniu losowo otworzy, zablokuje albo naelektryzuje wszystkie drzwi działu. Nie daj go znaleźć przed czasem."

/datum/objective/plant_device/tide/on_planted(obj/item/traitor_device/planted_device)
	..()
	addtimer(CALLBACK(src, PROC_REF(trigger), planted_device), 1 MINUTES)

/datum/objective/plant_device/tide/proc/trigger(obj/item/traitor_device/planted_device)
	if(QDELETED(planted_device) || !planted_device.anchored)
		planted = FALSE
		return
	for(var/obj/machinery/door/airlock/airlock as anything in GLOB.airlocks)
		if(!is_target_area(get_area(airlock)))
			continue
		switch(rand(1, 3))
			if(1)
				INVOKE_ASYNC(airlock, TYPE_PROC_REF(/obj/machinery/door, open))
			if(2)
				airlock.bolt()
			if(3)
				airlock.set_electrified(MACHINE_ELECTRIFIED_PERMANENT)
	do_sparks(3, FALSE, planted_device)
	completed = TRUE
	qdel(planted_device)

/obj/item/traitor_device/tide
	name = "wirus T1de"
	desc = "Pudełko z kablami i anteną. Na boku ktoś wydrapał: T1DE."
	icon = 'icons/obj/device.dmi'
	icon_state = "shield0"

// Bomb in a vital compartment (TauCeti)

/datum/objective/plant_device/bomb
	name = "bomba w przedziale"
	device_type = /obj/item/sbeacondrop/bomb/objective
	target_area_count = 3
	candidate_area_types = list(
		/area/ai_monitored/security/armory,
		/area/bridge,
		/area/tcommsat,
		/area/engine/atmos,
		/area/nsv/magazine,
		/area/nsv/engine/engine_room,
		/area/crew_quarters/heads/captain,
		/area/ai_monitored/storage/eva,
	)

/datum/objective/plant_device/bomb/give_device()
	..()
	var/obj/item/sbeacondrop/bomb/objective/beacon = device
	if(istype(beacon))
		beacon.objective = src

/datum/objective/plant_device/bomb/update_explanation_text()
	explanation_text = "Zdetonuj dostarczoną bombę w jednym z przedziałów: [target_area_names()]. Licznik nie zejdzie poniżej 2 minut, więc pilnuj jej albo dobrze ukryj."

/datum/objective/plant_device/bomb/check_completion()
	return completed

/obj/item/sbeacondrop/bomb/objective
	droptype = /obj/machinery/syndicatebomb/objective
	var/datum/objective/plant_device/bomb/objective

/obj/item/sbeacondrop/bomb/objective/attack_self(mob/user)
	if(!user)
		return
	to_chat(user, "<span class='notice'>Namierzono.</span>")
	var/obj/machinery/syndicatebomb/objective/bomb = new droptype(user.loc)
	bomb.objective = objective
	playsound(src, 'sound/effects/pop.ogg', 100, 1, 1)
	qdel(src)

/obj/machinery/syndicatebomb/objective
	minimum_timer = 120
	timer_set = 120
	var/datum/objective/plant_device/bomb/objective

/obj/machinery/syndicatebomb/objective/try_detonate(ignore_active = FALSE)
	var/area/bomb_area = get_area(src)
	. = ..()
	if(. && objective && objective.is_target_area(bomb_area))
		objective.completed = TRUE

// Telecomms data (TauCeti)

/datum/objective/tcomms_data
	name = "dane telekomunikacyjne"
	explanation_text = "Zgraj ważne dane z huba telekomunikacji na dostarczony dysk i miej go przy sobie do końca zmiany."
	martyr_compatible = FALSE

/datum/objective/tcomms_data/traitor_roll_setup(datum/antagonist/traitor/rolling)
	var/hub_found = FALSE
	for(var/obj/machinery/telecomms/hub/hub in GLOB.telecomms_list)
		if(is_station_level(hub.z))
			hub_found = TRUE
			break
	if(!hub_found)
		return FALSE
	give_special_equipment(list(/obj/item/disk/tcomms_data))
	return TRUE

/datum/objective/tcomms_data/check_completion()
	if(completed)
		return TRUE
	for(var/datum/mind/owner_mind as anything in get_owners())
		if(!isliving(owner_mind.current))
			continue
		for(var/obj/item/disk/tcomms_data/disk in owner_mind.current.GetAllContents())
			if(disk.has_data)
				return TRUE
	return FALSE

/obj/item/disk/tcomms_data
	name = "dysk danych"
	desc = "Dysk z wgranym programem do zrzutu danych. Wystarczy przyłożyć go do huba telekomunikacji."
	icon_state = "datadisk1"
	var/has_data = FALSE
	var/busy = FALSE

/obj/item/disk/tcomms_data/examine(mob/user)
	. = ..()
	. += has_data ? "<span class='notice'>Dioda świeci na zielono - dane są zgrane.</span>" : "<span class='notice'>Dioda świeci na czerwono - dysk jest pusty.</span>"

/obj/item/disk/tcomms_data/pre_attack(atom/A, mob/living/user, params)
	if(!istype(A, /obj/machinery/telecomms/hub))
		return ..()
	if(has_data || busy)
		balloon_alert(user, has_data ? "dane już zgrane" : "trwa zgrywanie")
		return FALSE
	var/obj/machinery/telecomms/hub/hub = A
	busy = TRUE
	balloon_alert(user, "zgrywanie danych...")
	hub.AI_notify_hack()
	if(do_after(user, 20 SECONDS, target = hub))
		has_data = TRUE
		balloon_alert(user, "dane zgrane")
		log_game("[key_name(user)] downloaded telecomms data from [AREACOORD(hub)].")
	busy = FALSE
	return FALSE

// Communications console hack (tgstation) calling a threat on the ship

#define HACK_FLEET "fleet"
#define HACK_PIRATES "pirates"
#define HACK_THREAT "threat"

/datum/objective/hack_comms
	name = "włamanie do łączności"
	explanation_text = "Włam się do konsoli łączności dostarczonym przechwytywaczem i ściągnij na statek zagrożenie. SI zostanie zaalarmowana, gdy zaczniesz."
	martyr_compatible = TRUE

/datum/objective/hack_comms/traitor_roll_setup(datum/antagonist/traitor/rolling)
	if(taken_by_other_traitor())
		return FALSE
	var/console_found = FALSE
	for(var/obj/machinery/computer/communications/console in GLOB.machines)
		if(is_station_level(console.z))
			console_found = TRUE
			break
	if(!console_found)
		return FALSE
	give_special_equipment(list(/obj/item/comms_hacker))
	return TRUE

/datum/objective/hack_comms/admin_edit(mob/admin)
	give_special_equipment(list(/obj/item/comms_hacker))

/obj/item/comms_hacker
	name = "przechwytywacz łączności"
	desc = "Moduł z wtykiem pasującym do portu serwisowego konsoli łączności."
	icon = 'icons/obj/device.dmi'
	icon_state = "syndi_tele"
	w_class = WEIGHT_CLASS_SMALL
	var/busy = FALSE

/obj/item/comms_hacker/pre_attack(atom/A, mob/living/user, params)
	if(!istype(A, /obj/machinery/computer/communications))
		return ..()
	if(busy)
		return FALSE
	var/obj/machinery/computer/communications/console = A
	busy = TRUE
	if(console.try_hack_console(user))
		for(var/datum/antagonist/traitor/traitor in user.mind?.antag_datums)
			var/datum/objective/hack_comms/objective = locate() in traitor.objectives
			if(objective)
				objective.completed = TRUE
		qdel(src)
		return FALSE
	busy = FALSE
	return FALSE

/// Begin the process of hacking into the comms console to call in a threat.
/obj/machinery/computer/communications/proc/try_hack_console(mob/living/hacker, duration = 30 SECONDS)
	if(machine_stat & (NOPOWER|BROKEN))
		balloon_alert(hacker, "nie da się włamać!")
		return FALSE
	if(!is_station_level(z))
		balloon_alert(hacker, "za słaby sygnał!")
		return FALSE
	balloon_alert(hacker, "włamywanie...")
	AI_notify_hack()
	if(!do_after(hacker, duration, target = src))
		return FALSE
	if(machine_stat & (NOPOWER|BROKEN))
		return FALSE
	hack_console(hacker)
	return TRUE

/// Calls a threat on the ship: a hostile fleet, pirates or a dynamic midround
/obj/machinery/computer/communications/proc/hack_console(mob/living/hacker)
	var/list/hack_options = list(HACK_FLEET)
	var/num_ghosts = 0
	for(var/mob/dead/observer/ghost in GLOB.player_list)
		num_ghosts++
	if(!GLOB.pirates_spawned && SSmapping.empty_space && num_ghosts >= 4)
		hack_options += HACK_PIRATES
	if(istype(SSticker.mode, /datum/game_mode/dynamic))
		hack_options += HACK_THREAT
	var/picked_option = pick(hack_options)
	message_admins("[ADMIN_LOOKUPFLW(hacker)] hacked a [name] located at [ADMIN_VERBOSEJMP(src)], resulting in: [picked_option]!")
	log_game("[key_name(hacker)] hacked a communications console, resulting in: [picked_option].")
	switch(picked_option)
		if(HACK_FLEET)
			var/obj/structure/overmap/main_ship = SSstar_system.find_main_overmap()
			var/datum/star_system/target_system = main_ship?.current_system
			if(!target_system && main_ship)
				target_system = SSstar_system.ships[main_ship]?["target_system"]
			if(target_system)
				target_system.spawn_fleet(pick(/datum/fleet/pirate/raiding, /datum/fleet/boarding, /datum/fleet/wolfpack))
			priority_announce("Uwaga: czujniki sektora wykryły ślad skoku wrogich okrętów kierujących się do waszego systemu. Przygotować się na kontakt bojowy.", "Pilna aktualizacja dowództwa")
		if(HACK_PIRATES)
			send_pirate_threat()
		if(HACK_THREAT)
			priority_announce("Uwaga: wywiad Nanotrasenu otrzymał informacje o wzmożonej aktywności wroga w waszym sektorze, większej niż w dzisiejszym raporcie.", "Pilna aktualizacja dowództwa")
			for(var/mob/crew_member as anything in GLOB.player_list)
				if(is_station_level(crew_member.z))
					shake_camera(crew_member, 15, 1)
			var/datum/game_mode/dynamic/mode = SSticker.mode
			mode.unfavorable_situation()

#undef HACK_FLEET
#undef HACK_PIRATES
#undef HACK_THREAT
