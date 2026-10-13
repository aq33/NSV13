// AQUILA - Crystal Invasion, port of tgstation#52941 (ZK-Lambda-Class Remade) with the follow-up fixes up to tgstation#53718,
// i.e. the random event version from before it became a delamination event and was removed upstream.
// The supermatter destabilizes into a shielded crystal, huge portals open around the ship and pour out crystal monsters.
// The crew closes the huge portals (anomaly neutralizer or the portal's own signal), harvests an otherworld crystal from a portal,
// loads it into a supermatter stabilizer (Anomaly Research) and injects the crystal. If they run out of time, a ZK-class event hits.
// Unlike upstream it also runs on ships without a supermatter: the destabilized crystal then tears into the ship at a random spot.

/// The 4 kinds of waves and the portals each one can spawn
GLOBAL_LIST_INIT(crystal_invasion_waves, list(
	"small wave" = list(
		/obj/structure/crystal_portal/small = 4,
		/obj/structure/crystal_portal/medium = 1,
	),
	"medium wave" = list(
		/obj/structure/crystal_portal/small = 4,
		/obj/structure/crystal_portal/medium = 3,
		/obj/structure/crystal_portal/big = 1,
	),
	"big wave" = list(
		/obj/structure/crystal_portal/small = 5,
		/obj/structure/crystal_portal/medium = 3,
		/obj/structure/crystal_portal/big = 2,
	),
	"huge wave" = list(
		/obj/structure/crystal_portal/small = 7,
		/obj/structure/crystal_portal/medium = 5,
		/obj/structure/crystal_portal/big = 3,
	),
))
/// Polish names of the waves, for announcements
GLOBAL_LIST_INIT(crystal_invasion_wave_names, list(
	"small wave" = "małą falę",
	"medium wave" = "średnią falę",
	"big wave" = "dużą falę",
	"huge wave" = "ogromną falę",
))
/// Every crystal portal on the ship, closed when the crystal is stabilized
GLOBAL_LIST_EMPTY(crystal_portals)
/// The huge portals from the start of the event, they keep the shield on the destabilized crystal up
GLOBAL_LIST_EMPTY(huge_crystal_portals)

/// Generic event spawn landmarks on the ship
/proc/crystal_invasion_spawners()
	. = list()
	for(var/obj/effect/landmark/event_spawn/spawner as anything in GLOB.generic_event_spawns)
		if(is_station_level(spawner.z))
			. += spawner

/*
This section is for the event controller
*/
/datum/round_event_control/crystal_invasion
	name = "Crystal Invasion"
	typepath = /datum/round_event/crystal_invasion
	weight = 8
	min_players = 25
	max_occurrences = 1
	earliest_start = 25 MINUTES

/datum/round_event_control/crystal_invasion/canSpawnEvent(players_amt, gamemode)
	if(length(crystal_invasion_spawners()) < 6) // the portals are placed on event spawn landmarks, a map without enough of them cannot run this
		return FALSE
	return ..()

/datum/round_event/crystal_invasion
	startWhen = 5
	announceWhen = 1
	endWhen = 460
	fakeable = FALSE
	/// Name of the wave, decides which portals spawn
	var/wave_name
	/// Number of huge portals for this wave
	var/portal_numbers
	/// The destabilized crystal
	var/obj/machinery/destabilized_crystal/dest_crystal
	/// Type of the supermatter that got destabilized, restored at the end. Null if the crystal appeared without one
	var/supermatter_type
	/// TRUE until the crew stabilizes the crystal
	var/is_zk_scenario = TRUE
	/// Ticks before the second wave of portals
	var/second_wave = 310
	/// Areas of the huge portals
	var/list/center_areas = list()

/datum/round_event/crystal_invasion/start()
	choose_wave_type()
	destabilize_crystal()
	if(!dest_crystal)
		return
	addtimer(CALLBACK(src, PROC_REF(create_random_portals)), 2 SECONDS)

/// Destabilizes the supermatter (or tears a crystal into the ship if there is none) and spawns 6 portals around it
/datum/round_event/crystal_invasion/proc/destabilize_crystal()
	var/list/sm_crystals = list()
	for(var/obj/machinery/power/supermatter_crystal/crystal in GLOB.machines)
		if(istype(crystal, /obj/machinery/power/supermatter_crystal/shard) || !is_station_level(crystal.z))
			continue
		sm_crystals += crystal
	var/turf/crystal_turf
	if(length(sm_crystals))
		var/obj/machinery/power/supermatter_crystal/crystal = pick(sm_crystals)
		supermatter_type = crystal.type
		crystal_turf = get_turf(crystal)
		qdel(crystal)
	else
		var/obj/effect/landmark/spawner = pick(crystal_invasion_spawners())
		crystal_turf = get_turf(spawner)
	if(!crystal_turf)
		kill()
		return
	explosion(crystal_turf, 0, round(portal_numbers / 5), round(portal_numbers), 1, 1, 1)
	dest_crystal = new(crystal_turf)
	RegisterSignal(dest_crystal, COMSIG_PARENT_QDELETING, PROC_REF(on_dest_crystal_qdel))

	crystallize_area(crystal_turf, 8, 325)

	var/list/crystal_spawner_turfs = list()
	for(var/turf/open/range_turf in RANGE_TURFS(6, crystal_turf))
		if(isspaceturf(range_turf))
			continue
		crystal_spawner_turfs += range_turf
	if(!length(crystal_spawner_turfs))
		return
	for(var/i in 1 to 6)
		var/pick_portal = pickweight(GLOB.crystal_invasion_waves["big wave"])
		new pick_portal(pick(crystal_spawner_turfs))

/// Turns the turfs around center into crystal, more of them closer to the center
/datum/round_event/crystal_invasion/proc/crystallize_area(turf/center, range, chance)
	for(var/turf/turf_loc as anything in RANGE_TURFS(range, center))
		if(isspaceturf(turf_loc) || istype(turf_loc, /turf/open/indestructible) || istype(turf_loc, /turf/closed/indestructible))
			continue
		if(!prob(chance / max(get_dist(turf_loc, center), 1)))
			continue
		if(isopenturf(turf_loc))
			turf_loc.ChangeTurf(/turf/open/indestructible/crystal_floor, flags = CHANGETURF_INHERIT_AIR)
		else
			turf_loc.ChangeTurf(/turf/closed/indestructible/crystal_wall)

/// Picks random event spawns for the huge portals and spawns 6 more portals around each of them
/datum/round_event/crystal_invasion/proc/create_random_portals()
	if(QDELETED(dest_crystal))
		return
	var/list/center_finder = crystal_invasion_spawners()
	for(var/j in 1 to portal_numbers)
		if(!length(center_finder))
			break
		var/obj/center = pick_n_take(center_finder)
		var/turf/center_turf = get_turf(center)
		center_areas += get_area(center_turf)

		explosion(center_turf, 0, 0, 5, 7)
		new /obj/structure/crystal_portal/huge(center_turf)
		crystallize_area(center_turf, 5, 250)

		var/list/portal_spawner_turfs = list()
		for(var/turf/open/range_turf in RANGE_TURFS(6, center_turf))
			if(isspaceturf(range_turf))
				continue
			portal_spawner_turfs += range_turf
		for(var/i in 1 to 6)
			if(!length(portal_spawner_turfs))
				break
			var/pick_portal = pickweight(GLOB.crystal_invasion_waves[wave_name])
			new pick_portal(pick_n_take(portal_spawner_turfs))
	dest_crystal.icon_state = "psy_shielded"
	dest_crystal.changed_icon = FALSE
	addtimer(CALLBACK(src, PROC_REF(announce_locations)), 8 SECONDS)

/// 8 seconds after the explosions CentCom announces where the huge portals are
/datum/round_event/crystal_invasion/proc/announce_locations()
	var/list/area_names = list()
	for(var/area/A as anything in center_areas)
		area_names += A.name
	priority_announce("OSTRZEŻENIE - Po namierzeniu skoków mocy na waszym statku ustaliliśmy, że ogromne portale otworzyły się w następujących miejscach: [area_names.Join(", ")]. \
		Zamknijcie je, zanim spróbujecie ustabilizować kryształ.", "Alarm")
	sound_to_playing_players('sound/misc/notice1.ogg')

/datum/round_event/crystal_invasion/announce(fake)
	priority_announce("OSTRZEŻENIE - Wykryto destabilizację macierzy kryształu supermaterii. Czekajcie na dalsze instrukcje.", "Alarm")
	sound_to_playing_players('sound/misc/notice1.ogg')

/// Picks the wave and announces what the crew has to do
/datum/round_event/crystal_invasion/proc/choose_wave_type()
	if(!wave_name)
		wave_name = pickweight(list(
			"small wave" = 35,
			"medium wave" = 45,
			"big wave" = 15,
			"huge wave" = 5))
	switch(wave_name)
		if("small wave")
			portal_numbers = 2
		if("medium wave")
			portal_numbers = rand(2, 3)
		if("big wave")
			portal_numbers = rand(3, 4)
		if("huge wave")
			portal_numbers = rand(4, 5)
		else
			kill()
			CRASH("Wave name of [wave_name] not recognised.")

	priority_announce("OSTRZEŻENIE - Wykryliśmy liczne fluktuacje energii pochodzące z kryształu. Szacujemy [GLOB.crystal_invasion_wave_names[wave_name]] krystalicznych istot \
		przybywających z \[UTAJNIONO]; na statku otworzy się [portal_numbers] głównych portali, które musicie zamknąć. Pozyskajcie kryształ \[UTAJNIONO] \
		z portalu za pomocą neutralizatora anomalii, umieśćcie go w stabilizatorze supermaterii i wstrzyknijcie go w kryształ, aby zapobiec Scenariuszowi Kosmicznej Fragmentacji klasy ZK-Lambda.", "Alarm")
	sound_to_playing_players('sound/misc/notice1.ogg')

/// Spawns one portal at a random event spawn
/datum/round_event/crystal_invasion/proc/spawn_portal(list/wave_type, list/spawners)
	if(!length(spawners))
		CRASH("No landmarks on the station map, aborting")
	var/pick_portal = pickweight(wave_type)
	var/obj/spawner = pick(spawners)
	new pick_portal(get_turf(spawner))

/// If the crystal is not stabilized in time, more portals open and the event escalates
/datum/round_event/crystal_invasion/proc/more_portals()
	priority_announce("OSTRZEŻENIE - Wykryto kolejny skok mocy zdestabilizowanego kryształu. Na całym statku otwierają się nowe portale. Następny skok może \
		wywołać zdarzenie klasy \[UTAJNIONO]; zakładamy, że macie jeszcze pięć minut do całkowitej anihilacji kryształu.", "Alarm")
	sound_to_playing_players('sound/misc/notice1.ogg')
	var/list/spawners = crystal_invasion_spawners()
	for(var/i in 1 to rand(10, 15))
		spawn_portal(GLOB.crystal_invasion_waves["medium wave"], spawners)

/datum/round_event/crystal_invasion/tick()
	if(QDELETED(dest_crystal))
		return
	if(activeFor == second_wave)
		more_portals()
	if(dest_crystal.is_stabilized)
		processing = FALSE
		is_zk_scenario = FALSE
		finish_event()
	else if(activeFor == endWhen - 10)
		processing = FALSE
		finish_event()

/// Ends the event well or badly
/datum/round_event/crystal_invasion/proc/finish_event()
	if(is_zk_scenario)
		zk_event_announcement()
	else
		restore()
	kill()

/// Announces the worst ending
/datum/round_event/crystal_invasion/proc/zk_event_announcement()
	dest_crystal.active = FALSE
	priority_announce("OSTRZEŻENIE - Kryształ osiągnął punkt krytycznej niestabilności. Nadchodzi zdarzenie klasy ZK. Prosimy nie panikować, każdy panikujący \
		zostanie zlikwidowany na miejscu. Miłego dnia.", "Alarm")
	sound_to_playing_players('sound/machines/alarm.ogg')
	addtimer(CALLBACK(src, PROC_REF(do_zk_event)), 10 SECONDS)

/// The ZK-class event itself: portals everywhere and a huge explosion
/datum/round_event/crystal_invasion/proc/do_zk_event()
	if(QDELETED(dest_crystal))
		return
	var/list/spawners = crystal_invasion_spawners()
	for(var/i in 1 to rand(15, 25))
		spawn_portal(GLOB.crystal_invasion_waves["huge wave"], spawners)
	var/turf/crystal_turf = get_turf(dest_crystal)
	UnregisterSignal(dest_crystal, COMSIG_PARENT_QDELETING)
	QDEL_NULL(dest_crystal)
	explosion(crystal_turf, 15, 26, 33, 35, 1, 1) //a bit smaller than max supermatter explosion
	priority_announce("OSTRZEŻENIE - Portale otwierają się wszędzie, nie udało się wam opanować zdarzenia. Powinniście się wstydzić!", "Alarm")

/// Puts the crystal back the way it was
/datum/round_event/crystal_invasion/proc/restore()
	priority_announce("Kryształ został przywrócony i jest znowu stabilny. Wasz sektor jest bezpieczny od Scenariusza klasy ZK-Lambda. \
		Zabijcie pozostałe krystaliczne potwory i wracajcie do pracy.")
	sound_to_playing_players('sound/misc/notice2.ogg')
	var/turf/loc_turf = get_turf(dest_crystal)
	if(supermatter_type)
		new supermatter_type(loc_turf)
	else
		loc_turf.visible_message("<span class='notice'>[dest_crystal] rozpada się w lśniący pył.</span>")
	for(var/obj/structure/crystal_portal/portal as anything in GLOB.crystal_portals)
		portal.closed = TRUE
		qdel(portal)
	UnregisterSignal(dest_crystal, COMSIG_PARENT_QDELETING)
	QDEL_NULL(dest_crystal)

/// Aborts the event if an admin deletes the destabilized crystal
/datum/round_event/crystal_invasion/proc/on_dest_crystal_qdel()
	SIGNAL_HANDLER
	UnregisterSignal(dest_crystal, COMSIG_PARENT_QDELETING)
	processing = FALSE
	message_admins("Deleted Destabilized crystal, aborting")
	dest_crystal = null
	kill()

/turf/open/indestructible/crystal_floor
	name = "krystaliczna podłoga"
	desc = "Skrystalizowana podłoga."
	icon_state = "noslip-damaged1"

/turf/open/indestructible/crystal_floor/examine(mob/user)
	. = ..()
	. += "<span class='notice'>Podłoga jest z twardych kryształów. Spawarka mogłaby je rozgrzać.</span>"

/turf/open/indestructible/crystal_floor/welder_act(mob/living/user, obj/item/I)
	if(!I.tool_start_check(user, amount = 0))
		return FALSE
	to_chat(user, "<span class='notice'>Zaczynasz rozgrzewać kryształ...</span>")
	if(I.use_tool(src, user, 2.5 SECONDS, volume = 100))
		to_chat(user, "<span class='notice'>Kryształ rozsypuje się w pył.</span>")
		ScrapeAway(flags = CHANGETURF_INHERIT_AIR)
	return TRUE

/turf/closed/indestructible/crystal_wall
	name = "krystaliczna ściana"
	desc = "Skrystalizowana ściana."
	icon = 'icons/turf/mining.dmi'
	icon_state = "rock_highchance"

/turf/closed/indestructible/crystal_wall/examine(mob/user)
	. = ..()
	. += "<span class='notice'>Ściana jest z twardych kryształów. Spawarka mogłaby je rozgrzać.</span>"

// Upstream defined the welder proc twice on the floor by mistake, so the walls could never be removed
/turf/closed/indestructible/crystal_wall/welder_act(mob/living/user, obj/item/I)
	if(!I.tool_start_check(user, amount = 0))
		return FALSE
	to_chat(user, "<span class='notice'>Zaczynasz rozgrzewać kryształ...</span>")
	if(I.use_tool(src, user, 5 SECONDS, volume = 100))
		to_chat(user, "<span class='notice'>Kryształ rozsypuje się w pył.</span>")
		ScrapeAway()
	return TRUE

/*
This section is for the destabilized crystal
*/
/obj/machinery/destabilized_crystal
	name = "zdestabilizowany kryształ"
	desc = "Dziwnie przejrzysty, mieniący się kryształ."
	icon = 'aquila/icons/obj/crystal_invasion.dmi'
	icon_state = "psy"
	density = TRUE
	anchored = TRUE
	flags_1 = PREVENT_CONTENTS_EXPLOSION_1
	light_range = 4
	use_power = NO_POWER_USE
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF | FREEZE_PROOF
	/// If not active the crystal does not emit radiation and gases
	var/active = TRUE
	/// Set once the crew stabilizes the crystal
	var/is_stabilized = FALSE
	/// Our sound loop
	var/datum/looping_sound/destabilized_crystal/soundloop
	/// FALSE while the shielded icon is shown
	var/changed_icon = TRUE

/obj/machinery/destabilized_crystal/Initialize(mapload)
	. = ..()
	soundloop = new(src, TRUE)

/obj/machinery/destabilized_crystal/Destroy()
	QDEL_NULL(soundloop)
	return ..()

/obj/machinery/destabilized_crystal/process()
	if(!active)
		return
	if(prob(75))
		radiation_pulse(src, 250, 6)
	if(prob(30))
		playsound(loc, 'sound/weapons/emitter2.ogg', 100, TRUE, extrarange = 10)
	if(prob(15))
		fire_nuclear_particle()
	if(!length(GLOB.huge_crystal_portals) && !changed_icon)
		icon_state = "psy"
		changed_icon = TRUE

	var/turf/loc_turf = loc
	if(!isturf(loc_turf) || isspaceturf(loc_turf))
		return
	var/datum/gas_mixture/env = loc_turf.return_air()
	if(!env)
		return
	var/datum/gas_mixture/removed = env.remove_ratio(0.5)
	if(!removed)
		return
	removed.adjust_moles(GAS_BZ, 15.5)
	removed.adjust_moles(GAS_MIASMA, 5.5)
	env.merge(removed)
	air_update_turf()

/obj/machinery/destabilized_crystal/attackby(obj/item/W, mob/living/user, params)
	if(!istype(user) || !istype(W, /obj/item/crystal_stabilizer))
		return ..()
	if(!active)
		to_chat(user, "<span class='warning'>Na stabilizację [src] jest już za późno!</span>")
		return TRUE
	if(length(GLOB.huge_crystal_portals))
		to_chat(user, "<span class='notice'>Tarcza chroniąca kryształ wciąż działa! Zamknij wszystkie główne portale i spróbuj ponownie!</span>")
		return TRUE
	var/obj/item/crystal_stabilizer/injector = W
	if(!injector.filled)
		to_chat(user, "<span class='notice'>[W] jest pusty!</span>")
		return TRUE
	to_chat(user, "<span class='notice'>Ostrożnie zaczynasz wstrzykiwać [W] w [src]... nie ruszaj się, dopóki nie skończysz wszystkich kroków!</span>")
	if(!W.use_tool(src, user, 1 SECONDS, volume = 100))
		return TRUE
	to_chat(user, "<span class='notice'>Wewnętrzny rezonans [src] słabnie pod wpływem płynu!</span>")
	playsound(get_turf(src), 'sound/effects/supermatter.ogg', 35, TRUE)
	if(!W.use_tool(src, user, 1.5 SECONDS, volume = 100))
		return TRUE
	to_chat(user, "<span class='notice'>[src] gwałtownie reaguje z płynem!</span>")
	fire_nuclear_particle()
	radiation_pulse(src, 1000, 6)
	if(!W.use_tool(src, user, 2 SECONDS, volume = 100))
		return TRUE
	to_chat(user, "<span class='notice'>[src] został przywrócony i ustabilizowany!</span>")
	playsound(get_turf(src), 'sound/effects/supermatter.ogg', 35, TRUE)
	injector.filled = FALSE
	injector.update_icon()
	active = FALSE
	is_stabilized = TRUE
	return TRUE

/obj/machinery/destabilized_crystal/examine(mob/user)
	. = ..()
	. += "<span class='notice'>Kryształ wygląda na mocno zdestabilizowany. Może dałoby się go naprawić, wstrzykując w niego coś z innego świata.</span>"
	if(length(GLOB.huge_crystal_portals))
		. += "<span class='notice'>Zdestabilizowany kryształ chroni jakaś tarcza.</span>"
	else
		. += "<span class='notice'>Tarcza chroniąca kryształ zniknęła, czas go przywrócić.</span>"

/obj/machinery/destabilized_crystal/Bumped(atom/movable/movable_atom)
	if(!isliving(movable_atom))
		return
	var/mob/living/user = movable_atom
	if(isnull(user.mind))
		return
	movable_atom.visible_message("<span class='danger'>[movable_atom] uderza w [src], wywołując rezonans... ciało zaczyna jarzyć się i stanąć w płomieniach, po czym rozsypuje się w pył!</span>", \
		"<span class='userdanger'>Uderzasz w [src], a w uszach rozbrzmiewa nieziemskie dzwonienie. Twoja ostatnia myśl to: \"O kurwa.\"</span>", \
		"<span class='italics'>Słyszysz nieziemski dźwięk, a przez ciebie przetacza się fala gorąca.</span>")
	playsound(get_turf(src), 'sound/effects/supermatter.ogg', 50, TRUE)
	consume(movable_atom)

/// Dusts whoever touches the crystal; the sacrifice slows down the portals
/obj/machinery/destabilized_crystal/proc/consume(atom/movable/movable_atom)
	if(isliving(movable_atom))
		var/mob/living/user = movable_atom
		if(user.status_flags & GODMODE || isnull(user.mind))
			return
		message_admins("[src] has consumed [key_name_admin(user)] [ADMIN_JMP(src)].")
		investigate_log("has consumed [key_name(user)].", INVESTIGATE_ENGINES)
		user.dust(force = TRUE)
	for(var/obj/structure/crystal_portal/portal as anything in GLOB.crystal_portals)
		portal.slow_down()
	priority_announce("Poświęcenie członka załogi (miejmy nadzieję, że klauna) najwyraźniej osłabiło portale i spowolniło napływ potworów!")
	sound_to_playing_players('sound/misc/notice2.ogg')

/datum/looping_sound/destabilized_crystal
	mid_sounds = list('sound/machines/sm/loops/delamming.ogg' = 1)
	mid_length = 60
	volume = 55
	extra_range = 15

/*
This section is for the crystal stabilizer and the crystals from closed portals
*/
/obj/item/crystal_stabilizer
	name = "stabilizator supermaterii"
	desc = "Używany, gdy macierz supermaterii zbliża się do punktu zniszczenia."
	icon = 'aquila/icons/obj/crystal_invasion.dmi'
	icon_state = "stabilizer"
	slot_flags = ITEM_SLOT_BACK
	w_class = WEIGHT_CLASS_HUGE
	/// The stabilizer is single use
	var/filled = FALSE

/obj/item/crystal_stabilizer/examine(user)
	. = ..()
	. += "<span class='notice'>Ma komorę na coś małego... na przykład kryształ...</span>"
	if(!filled)
		. += "<span class='notice'>[src] jest pusty.</span>"
	else
		. += "<span class='notice'>[src] jest pełny i może posłużyć do ustabilizowania kryształu.</span>"

/obj/item/crystal_stabilizer/attackby(obj/item/W, mob/living/user, params)
	if(!istype(W, /obj/item/stack/sheet/otherworld_crystal) || !istype(user))
		return ..()
	if(filled)
		to_chat(user, "<span class='notice'>[src] jest już pełny.</span>")
		return TRUE
	var/obj/item/stack/sheet/otherworld_crystal/crystals = W
	if(!crystals.use(1))
		return TRUE
	to_chat(user, "<span class='notice'>Napełniasz [src].</span>")
	playsound(src, 'sound/effects/spray2.ogg', 100, TRUE)
	filled = TRUE
	return TRUE

/obj/item/stack/sheet/otherworld_crystal
	name = "kryształy z innego świata"
	desc = "Nieznany kryształ z nieznanego wymiaru."
	singular_name = "kryształ z innego świata"
	icon = 'aquila/icons/obj/crystal_invasion.dmi'
	icon_state = "otherworld-crystal"
	novariants = TRUE
	merge_type = /obj/item/stack/sheet/otherworld_crystal

/datum/design/crystal_stabilizer
	name = "Supermatter Matrix Stabilizer"
	desc = "Narzędzie przywracające stabilność macierzy kryształu przez wstrzyknięcie w nią płynu z anomalii."
	id = "crystal_stabilizer"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 3000, /datum/material/glass = 4500, /datum/material/silver = 2500)
	build_path = /obj/item/crystal_stabilizer
	category = list("Equipment")
	departmental_flags = DEPARTMENTAL_FLAG_SCIENCE | DEPARTMENTAL_FLAG_ENGINEERING

/datum/techweb_node/anomaly/New() // appended so upstream changes to this node's designs still apply
	. = ..()
	design_ids += "crystal_stabilizer"

/*
This section is for the signaler part of the crystal portals
*/
/obj/item/assembly/signaler/crystal_anomaly
	name = "Nic tu nie ma"
	desc = "Nie ma tu nic do oglądania."

/obj/item/assembly/signaler/crystal_anomaly/attack_self()
	return

/obj/item/assembly/signaler/crystal_anomaly/receive_signal(datum/signal/signal)
	if(!signal)
		return FALSE
	if(signal.data["code"] != code)
		return FALSE
	if(suicider)
		manual_suicide(suicider)
	for(var/obj/structure/crystal_portal/portal in get_turf(src))
		portal.closed = TRUE
		qdel(portal)
	return TRUE

/*
This section is for the crystal portals
*/
/obj/structure/crystal_portal
	name = "krystaliczny portal"
	desc = "To nie powinno tu być."
	icon = 'icons/effects/effects.dmi'
	icon_state = "anom"
	color = COLOR_SILVER
	anchored = TRUE
	light_range = 3
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF | FREEZE_PROOF
	/// Max amount of mobs alive from this portal at once
	var/max_mobs = 5
	/// Time between spawns
	var/spawn_time = 0
	/// Mobs the portal can spawn
	var/mob_types = list(/mob/living/simple_animal/hostile/carp)
	/// Fluff text for each spawned mob
	var/spawn_text = "wyłania się z"
	/// Faction of the spawned mobs
	var/faction = list("hostile")
	/// Set when the portal was closed properly, so it does not explode
	var/closed = FALSE
	/// Explosion when the portal is destroyed without being closed: devastation, heavy, light
	var/list/collapse_explosion = list(0, 1, 3)
	/// Signaler that lets the portal be closed with a matching signal
	var/obj/item/assembly/signaler/crystal_anomaly/a_signal

/obj/structure/crystal_portal/Initialize(mapload)
	. = ..()
	mob_types = typelist("crystal_portal mob_types", mob_types)
	faction = typelist("crystal_portal faction", faction)
	AddComponent(/datum/component/spawner, mob_types, spawn_time, faction, spawn_text, max_mobs)
	GLOB.crystal_portals += src
	a_signal = new(src)
	a_signal.code = rand(1, 100)
	var/frequency = rand(MIN_FREE_FREQ, MAX_FREE_FREQ)
	if(ISMULTIPLE(frequency, 2)) //signaller frequencies are always uneven!
		frequency++
	a_signal.set_frequency(frequency)

/obj/structure/crystal_portal/Destroy()
	GLOB.crystal_portals -= src
	QDEL_NULL(a_signal)
	if(!closed)
		explosion(loc, collapse_explosion[1], collapse_explosion[2], collapse_explosion[3])
	new /obj/item/stack/sheet/otherworld_crystal(loc)
	return ..()

/obj/structure/crystal_portal/examine(user)
	. = ..()
	. += "<span class='notice'>[src] zdaje się emitować jakąś falę o wysokiej częstotliwości. Może dałoby się go zamknąć, odsyłając sygnał z powrotem albo używając na nim odpowiedniego urządzenia.</span>"

/obj/structure/crystal_portal/attack_animal(mob/living/simple_animal/M)
	if(faction_check(faction, M.faction, FALSE) && !M.client)
		return
	return ..()

/obj/structure/crystal_portal/attackby(obj/item/W, mob/living/user, params)
	if((W.item_flags & ABSTRACT) || !istype(user))
		return ..()
	if(istype(W, /obj/item/anomaly_neutralizer))
		to_chat(user, "<span class='notice'>Zaczynasz zamykać [src]...</span>")
		if(W.use_tool(src, user, 5.5 SECONDS, volume = 100))
			to_chat(user, "<span class='notice'>Udaje ci się zamknąć [src]!</span>")
			closed = TRUE
			qdel(src)
		return TRUE
	if(W.tool_behaviour == TOOL_ANALYZER)
		to_chat(user, "<span class='notice'>Analizowanie... niestabilne pole [src] oscyluje na częstotliwości [format_frequency(a_signal.frequency)], kod [a_signal.code].</span>")
		return TRUE
	return ..()

/// Makes the portal spawn monsters more slowly
/obj/structure/crystal_portal/proc/slow_down()
	var/datum/component/spawner/spawner = GetComponent(/datum/component/spawner)
	if(spawner)
		spawner.spawn_time += 5

/obj/structure/crystal_portal/small
	name = "mały portal"
	desc = "Mały portal do nieznanego wymiaru!"
	color = "#2CB2E8" // COLOR_BRIGHT_BLUE upstream
	max_mobs = 2
	spawn_time = 5 SECONDS
	collapse_explosion = list(0, 1, 3)
	mob_types = list(
		/mob/living/simple_animal/hostile/crystal_monster/minion,
		/mob/living/simple_animal/hostile/crystal_monster/thug,
	)

/obj/structure/crystal_portal/medium
	name = "średni portal"
	desc = "Średni portal do nieznanego wymiaru!"
	color = COLOR_GREEN
	max_mobs = 3
	spawn_time = 15 SECONDS
	collapse_explosion = list(0, 3, 5)
	mob_types = list(
		/mob/living/simple_animal/hostile/crystal_monster/minion,
		/mob/living/simple_animal/hostile/crystal_monster/thug,
		/mob/living/simple_animal/hostile/crystal_monster/recruit,
	)

/obj/structure/crystal_portal/big
	name = "duży portal"
	desc = "Duży portal do nieznanego wymiaru!"
	color = COLOR_RED
	max_mobs = 4
	spawn_time = 15 SECONDS
	collapse_explosion = list(1, 3, 5)
	mob_types = list(
		/mob/living/simple_animal/hostile/crystal_monster/minion,
		/mob/living/simple_animal/hostile/crystal_monster/thug,
		/mob/living/simple_animal/hostile/crystal_monster/recruit,
		/mob/living/simple_animal/hostile/crystal_monster/killer,
	)

/obj/structure/crystal_portal/huge
	name = "ogromny portal"
	desc = "Ogromny portal do nieznanego wymiaru!"
	color = COLOR_BLACK
	max_mobs = 2
	spawn_time = 40 SECONDS
	collapse_explosion = list(2, 5, 7)
	mob_types = list(
		/mob/living/simple_animal/hostile/crystal_monster/boss,
	)

/obj/structure/crystal_portal/huge/Initialize(mapload)
	. = ..()
	GLOB.huge_crystal_portals += src

/obj/structure/crystal_portal/huge/Destroy()
	GLOB.huge_crystal_portals -= src
	return ..()

/*
This section is for the crystal monsters
*/
/mob/living/simple_animal/hostile/crystal_monster
	name = "krystaliczny potwór"
	desc = "Potwór z kryształów podobnych do supermaterii."
	icon = 'aquila/icons/mob/crystal_mobs.dmi'
	icon_state = "crystal_minion"
	icon_living = "crystal_minion"
	icon_dead = "crystal_minion"
	gender = NEUTER
	mob_biotypes = list(MOB_INORGANIC, MOB_HUMANOID)
	turns_per_move = 1
	speak_emote = list("rezonuje")
	emote_see = list("rezonuje")
	a_intent = INTENT_HARM
	minbodytemp = 0
	maxbodytemp = 1500
	healable = 0 //they're crystals how would bruise packs help them??
	attacktext = "rozbija"
	attack_sound = 'sound/effects/supermatter.ogg'
	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	unsuitable_atmos_damage = 10
	robust_searching = 1
	stat_attack = UNCONSCIOUS
	faction = list("crystal")
	see_in_dark = 8
	lighting_alpha = LIGHTING_PLANE_ALPHA_MOSTLY_INVISIBLE
	deathmessage = "rozsypuje się w pył!"
	del_on_death = 1
	stop_automated_movement = FALSE
	stop_automated_movement_when_pulled = FALSE
	wander = TRUE

/mob/living/simple_animal/hostile/crystal_monster/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_SHOCKIMMUNE, INNATE_TRAIT)
	flags_1 |= TESLA_IGNORE_1

/// Upstream turf Melt(): crystal monsters smash through the walls they bump into
/mob/living/simple_animal/hostile/crystal_monster/proc/melt_turf(turf/T)
	if(!isclosedturf(T) || istype(T, /turf/closed/indestructible))
		return
	if(iswallturf(T))
		var/turf/closed/wall/W = T
		W.dismantle_wall(TRUE)
	else
		T.ScrapeAway()
	playsound(T, 'sound/effects/supermatter.ogg', 35, TRUE)

/mob/living/simple_animal/hostile/crystal_monster/minion
	name = "krystaliczny sługa"
	icon_state = "crystal_minion"
	icon_living = "crystal_minion"
	icon_dead = "crystal_minion"
	maxHealth = 20
	health = 20
	speed = 0.8
	melee_damage = 9
	move_force = MOVE_FORCE_WEAK
	move_resist = MOVE_FORCE_WEAK
	pull_force = MOVE_FORCE_WEAK
	/// Radius of the lexorin cloud left when it shatters
	var/death_cloud_size = 2

/mob/living/simple_animal/hostile/crystal_monster/minion/Destroy()
	if(isturf(loc))
		var/datum/effect_system/smoke_spread/chem/smoke = new
		create_reagents(4)
		reagents.add_reagent(/datum/reagent/toxin/lexorin, 4)
		smoke.attach(loc)
		smoke.set_up(reagents, death_cloud_size, loc, silent = TRUE)
		smoke.start()
	return ..()

/mob/living/simple_animal/hostile/crystal_monster/thug
	name = "krystaliczny zbir"
	icon_state = "crystal_thug"
	icon_living = "crystal_thug"
	icon_dead = "crystal_thug"
	maxHealth = 20
	health = 20
	speed = 0.9
	melee_damage = 10
	move_force = MOVE_FORCE_NORMAL
	move_resist = MOVE_FORCE_NORMAL
	pull_force = MOVE_FORCE_NORMAL
	dodging = TRUE
	dodge_prob = 25

/mob/living/simple_animal/hostile/crystal_monster/thug/attackby(obj/item/O, mob/user, params)
	if(prob(30))
		var/list/temp_turfs = list()
		for(var/turf/open/around_turf in view(7, src))
			if(isspaceturf(around_turf))
				continue
			temp_turfs += around_turf
		if(length(temp_turfs))
			do_teleport(src, pick(temp_turfs))
			return
	return ..()

/mob/living/simple_animal/hostile/crystal_monster/recruit
	name = "krystaliczny rekrut"
	icon_state = "crystal_recruit"
	icon_living = "crystal_recruit"
	icon_dead = "crystal_recruit"
	maxHealth = 20
	health = 20
	speed = 1.2
	melee_damage = 13
	move_force = MOVE_FORCE_STRONG
	move_resist = MOVE_FORCE_STRONG
	pull_force = MOVE_FORCE_STRONG
	obj_damage = 100
	environment_smash = ENVIRONMENT_SMASH_WALLS

/mob/living/simple_animal/hostile/crystal_monster/recruit/Bump(atom/clong)
	. = ..()
	if(isturf(clong))
		melt_turf(clong)

/mob/living/simple_animal/hostile/crystal_monster/killer
	name = "krystaliczny zabójca"
	icon_state = "crystal_killer"
	icon_living = "crystal_killer"
	icon_dead = "crystal_killer"
	maxHealth = 35
	health = 35
	speed = 0.75
	melee_damage = 18
	move_force = MOVE_FORCE_VERY_STRONG
	move_resist = MOVE_FORCE_VERY_STRONG
	pull_force = MOVE_FORCE_VERY_STRONG
	dodging = TRUE
	dodge_prob = 35
	environment_smash = ENVIRONMENT_SMASH_RWALLS
	projectiletype = /obj/item/projectile/temp/basilisk
	projectilesound = 'sound/weapons/pierce.ogg'
	ranged = 1
	ranged_message = "rzuca"
	ranged_cooldown_time = 3.5 SECONDS

/mob/living/simple_animal/hostile/crystal_monster/killer/Bump(atom/clong)
	. = ..()
	if(isturf(clong))
		melt_turf(clong)

/mob/living/simple_animal/hostile/crystal_monster/boss
	name = "krystaliczny boss"
	icon_state = "crystal_boss"
	icon_living = "crystal_boss"
	icon_dead = "crystal_boss"
	maxHealth = 150
	health = 100
	speed = 1.3
	melee_damage = 33
	move_force = MOVE_FORCE_EXTREMELY_STRONG
	move_resist = MOVE_FORCE_EXTREMELY_STRONG
	pull_force = MOVE_FORCE_EXTREMELY_STRONG
	environment_smash = ENVIRONMENT_SMASH_RWALLS
	projectiletype = /obj/item/projectile/magic/aoe/lightning/crystal
	projectilesound = 'sound/weapons/pierce.ogg'
	ranged = 1
	ranged_message = "rzuca"
	ranged_cooldown_time = 5.5 SECONDS

/// Dusts a downed victim and heals itself on it
/mob/living/simple_animal/hostile/crystal_monster/boss/proc/devour(mob/living/victim)
	victim.dust()
	if(health < maxHealth)
		health = min(health + 30, maxHealth)

/mob/living/simple_animal/hostile/crystal_monster/boss/Bump(atom/clong)
	. = ..()
	if(isliving(clong))
		var/mob/living/victim = clong
		if(victim.stat >= UNCONSCIOUS)
			devour(victim)
	else if(isturf(clong))
		melt_turf(clong)

/mob/living/simple_animal/hostile/crystal_monster/boss/AttackingTarget()
	. = ..()
	if(isliving(target))
		var/mob/living/victim = target
		if(victim.stat >= UNCONSCIOUS)
			devour(victim)
		else if(iscarbon(victim))
			var/mob/living/carbon/carbon_victim = victim
			var/obj/item/bodypart/body_part = carbon_victim.get_bodypart(pick(BODY_ZONE_R_ARM, BODY_ZONE_L_ARM, BODY_ZONE_R_LEG, BODY_ZONE_L_LEG))
			body_part?.dismember()
	else if(isturf(target))
		melt_turf(target)
	playsound(get_turf(src), 'sound/effects/supermatter.ogg', 35, TRUE)

/obj/item/projectile/magic/aoe/lightning/crystal
	tesla_power = 10000
	tesla_range = 4
	tesla_flags = TESLA_MOB_DAMAGE | TESLA_OBJ_DAMAGE
