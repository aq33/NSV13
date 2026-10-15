/// Mapa Pętli
#define EXILE_LOOP_MAP "_maps/templates/bitrunning/exile_loop.dmm"
/// Wygnańcy mają nieograniczone punkty, ale pokazujemy tę liczbę w konsoli
#define EXILE_LOOP_POINTS 99

/// Pętla ładuje się przy pierwszym wygnaniu i zostaje do końca rundy
/datum/controller/subsystem/bitrunning/var/datum/exile_loop/exile_loop

/datum/controller/subsystem/bitrunning/proc/get_exile_loop()
	if(exile_loop && !QDELETED(exile_loop) && exile_loop.loaded)
		return exile_loop
	exile_loop = new()
	if(!exile_loop.load())
		QDEL_NULL(exile_loop)
		return null
	return exile_loop

/**
 * Pętla: stała cyfrowa cela wygnańców z własnym serwerem kwantowym.
 */
/datum/exile_loop
	/// Czy mapa już stoi
	var/loaded = FALSE
	/// Rezerwacja z mapą
	var/datum/turf_reservation/reservation
	/// Miejsca, gdzie pojawiają się wygnańcy
	var/list/turf/spawn_turfs = list()
	/// Serwer Pętli
	var/obj/machinery/quantum_server/exile_loop/server

/datum/exile_loop/Destroy(force)
	spawn_turfs.Cut()
	server = null
	return ..()

/datum/exile_loop/proc/load()
	if(!fexists(EXILE_LOOP_MAP))
		stack_trace("exile loop: brak mapy [EXILE_LOOP_MAP]")
		return FALSE
	var/datum/map_template/template = new(EXILE_LOOP_MAP, "Pętla")
	reservation = SSmapping.RequestBlockReservation(template.width, template.height)
	if(!reservation)
		return FALSE
	var/turf/bottom_left = locate(reservation.bottom_left_coords[1], reservation.bottom_left_coords[2], reservation.bottom_left_coords[3])
	if(!template.load(bottom_left))
		return FALSE

	for(var/turf/tile as anything in reservation.reserved_turfs)
		for(var/obj/effect/landmark/bitrunning/exile_spawn/landmark in tile)
			spawn_turfs += tile
			qdel(landmark)
		if(!server)
			server = locate(/obj/machinery/quantum_server/exile_loop) in tile

	if(!length(spawn_turfs))
		stack_trace("exile loop: brak miejsc odrodzenia")
		return FALSE
	loaded = TRUE
	return TRUE

/datum/exile_loop/proc/get_spawn_turf()
	if(!length(spawn_turfs))
		return
	return pick(spawn_turfs)

/// Tworzy awatara wygnańca wyglądającego jak podany człowiek
/datum/exile_loop/proc/create_exile_avatar(mob/living/carbon/human/template_body)
	var/turf/destination = get_spawn_turf()
	if(!destination)
		return
	var/mob/living/carbon/human/avatar = new(destination)
	if(istype(template_body))
		template_body.dna.transfer_identity(avatar, transfer_SE = FALSE)
		avatar.real_name = template_body.real_name
		avatar.name = template_body.real_name
		avatar.gender = template_body.gender
		avatar.updateappearance(mutcolor_update = TRUE)
	avatar.equipOutfit(/datum/outfit/digital_exile)
	var/obj/item/card/id/exile_id = avatar.wear_id
	if(istype(exile_id))
		exile_id.registered_name = avatar.real_name
		exile_id.update_label()
	// cyfrowe ciało nie głoduje - wygnaniec siedzi tu do końca rundy
	ADD_TRAIT(avatar, TRAIT_NOHUNGER, BITRUNNING_TRAIT)
	avatar.AddComponent(/datum/component/simple_bodycam, "kamera wygnańca", "Wygnaniec [avatar.real_name]", BITRUNNER_CAMERA_NET)
	avatar.create_digital_aura()
	playsound(destination, 'sound/magic/blink.ogg', 40, TRUE)
	return avatar

/datum/outfit/digital_exile
	name = "Digital Exile"
	uniform = /obj/item/clothing/under/rank/prisoner
	shoes = /obj/item/clothing/shoes/sneakers/orange
	id = /obj/item/card/id/prisoner
	belt = /obj/item/bitrunning_host_monitor
	back = /obj/item/storage/backpack
	backpack_contents = list(
		/obj/item/storage/box/survival = 1,
		/obj/item/storage/firstaid/regular = 1,
		/obj/item/flashlight = 1,
	)

/obj/item/paper/fluff/exile_loop
	name = "kartka: witaj w Pętli"
	default_raw_text = {"<h2>Witaj w Pętli</h2>
<p>Twoje ciało zostało rozłożone na dane. Nie ma już dokąd wrócić.</p>
<ul>
<li><b>Terminal</b> obok serwera ładuje domeny. Nie płacisz za nie punktami.</li>
<li><b>Brama</b> na środku przenosi do załadowanej domeny.</li>
<li>Skrzynia dostarczona do kryjówki w domenie trafia na statek jako przesyłka z Pętli. Może ktoś tam o tobie pamięta.</li>
<li>Drabina w domenie odeśle cię tylko tutaj. Śmierć też.</li>
</ul>
<p><i>Odsiadka trwa do końca zmiany. Powodzenia.</i></p>"}

/obj/effect/landmark/bitrunning/exile_spawn
	name = "Exile loop spawn"
	icon_state = "hololadder"


/**
 * Serwer Pętli. Działa jak zwykły, ale:
 * - wygnańcy wchodzą do domeny bramą, a nie netpodem,
 * - przed wyczyszczeniem domeny wszyscy wygnańcy wracają do Pętli,
 * - nagrody lecą do byteforge'a na statku (praca karna).
 */
/obj/machinery/quantum_server/exile_loop
	name = "serwer Pętli"
	desc = "Serwer kwantowy, który nigdy się nie wyłącza. Wykuwa kolejne domeny dla tych, którzy stąd nie wyjdą."
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF
	flags_1 = NODECONSTRUCT_1
	points = EXILE_LOOP_POINTS
	server_cooldown_time = 1 MINUTES
	use_power = NO_POWER_USE

/obj/machinery/quantum_server/exile_loop/emag_act(mob/user)
	return

/obj/machinery/quantum_server/exile_loop/can_afford_domain(datum/lazy_template/virtual_domain/domain)
	return is_exile_domain(domain)

/// Które domeny są dostępne dla wygnańców
/proc/is_exile_domain(datum/lazy_template/virtual_domain/domain)
	if(domain.domain_flags & (DOMAIN_TEST_ONLY|DOMAIN_NO_EXILE))
		return FALSE
	if(domain.mission_min_candidates || domain.announce_to_ghosts)
		return FALSE
	if(domain.cost >= BITRUNNER_COST_EXTREME)
		return FALSE
	return TRUE

/obj/machinery/quantum_server/exile_loop/get_random_domain_id()
	var/list/random_domains = list()
	for(var/datum/lazy_template/virtual_domain/available as anything in SSbitrunning.all_domains)
		if(is_exile_domain(available) && available.cost > BITRUNNER_COST_NONE)
			random_domains += available
	if(!length(random_domains))
		return
	var/datum/lazy_template/virtual_domain/selected = pick(random_domains)
	domain_randomized = TRUE
	return selected.key

/obj/machinery/quantum_server/exile_loop/cold_boot_map(map_key, was_random_selection)
	. = ..()
	points = EXILE_LOOP_POINTS

/obj/machinery/quantum_server/exile_loop/can_generate_tech_disk(grade)
	return FALSE

/obj/machinery/quantum_server/exile_loop/calculate_rewards()
	return ..() * 0.5

/// Nagrody idą do byteforge'a na statku, jeśli jakiś działa
/obj/machinery/quantum_server/exile_loop/get_random_nearby_forge()
	var/list/station_forges = list()
	for(var/obj/machinery/byteforge/forge in GLOB.machines)
		if(forge.is_operational && is_station_level(forge.z))
			station_forges += forge
	if(length(station_forges))
		return pick(station_forges)
	return ..()

/obj/machinery/quantum_server/exile_loop/label_reward(obj/reward)
	reward.name = "[reward.name] (przesyłka z Pętli)"
	reward.desc += " Skompilowana przez cyfrowych wygnańców."

/obj/machinery/quantum_server/exile_loop/generate_loot(obj/cache, obj/machinery/byteforge/chosen_forge)
	. = ..()
	if(is_station_level(chosen_forge.z))
		bitrunning_announce("Byteforge odbiera przesyłkę z Pętli: wygnańcy ukończyli domenę \"[generated_domain.name]\".")
	for(var/mob/living/exile in get_exiles_in_domain())
		exile.playsound_local(exile, 'sound/machines/terminal_success.ogg', 50, TRUE)
		exile.throw_alert(ALERT_BITRUNNER_COMPLETED, /atom/movable/screen/alert/bitrunning/qserver_domain_complete)

/// Wygnańcy obecnie przebywający w załadowanej domenie
/obj/machinery/quantum_server/exile_loop/proc/get_exiles_in_domain()
	. = list()
	if(isnull(generated_domain) || !length(generated_domain.reservations))
		return
	for(var/datum/mind/exile_mind as anything in GLOB.digital_exiles)
		var/mob/living/exile = exile_mind?.current
		if(!isliving(exile))
			continue
		var/turf/exile_turf = get_turf(exile)
		for(var/datum/turf_reservation/reservation as anything in generated_domain.reservations)
			if(exile_turf in reservation.reserved_turfs)
				. += exile
				break

/obj/machinery/quantum_server/exile_loop/sever_connections()
	recall_exiles()
	return ..()

/obj/machinery/quantum_server/exile_loop/scrub_vdom()
	recall_exiles()
	return ..()

/// Zabiera wszystkich wygnańców z domeny z powrotem do Pętli
/obj/machinery/quantum_server/exile_loop/proc/recall_exiles()
	for(var/mob/living/exile as anything in get_exiles_in_domain())
		var/datum/component/digital_exile/exile_comp = exile.GetComponent(/datum/component/digital_exile)
		if(exile_comp)
			exile_comp.return_to_loop()
		else
			exile.forceMove(SSbitrunning.exile_loop?.get_spawn_turf())

/obj/machinery/quantum_server/exile_loop/attackby(obj/item/tool, mob/living/user, params)
	if(tool.tool_behaviour == TOOL_CROWBAR || tool.tool_behaviour == TOOL_SCREWDRIVER)
		return TRUE
	return ..()


/// Konsola w Pętli - bez wymaganego dostępu
/obj/machinery/computer/quantum_console/exile_loop
	name = "terminal Pętli"
	desc = "Terminal, z którego wygnańcy wybierają kolejne domeny. Klawisze są wytarte do połysku."
	req_access = null
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF
	flags_1 = NODECONSTRUCT_1
	use_power = NO_POWER_USE

/obj/machinery/computer/quantum_console/exile_loop/ui_static_data(mob/user)
	var/list/data = ..()
	var/list/available = list()
	for(var/list/domain_data as anything in data["available_domains"])
		var/datum/lazy_template/virtual_domain/domain = SSbitrunning.get_domain(domain_data["id"])
		if(domain && is_exile_domain(domain))
			available += list(domain_data)
	data["available_domains"] = available
	return data


/// Brama, przez którą wygnańcy wchodzą do domeny załadowanej na serwerze Pętli
/obj/structure/exile_gate
	name = "brama Pętli"
	desc = "Migotliwe przejście do domeny wirtualnej. Wejdź, gdy domena jest załadowana."
	icon = 'aquila/icons/effects/bitrunning.dmi'
	icon_state = "perm_exit"
	anchored = TRUE
	density = FALSE
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF
	light_range = 2
	light_power = 1
	light_color = LIGHT_COLOR_GREEN
	/// Żeby nie spamować komunikatami
	COOLDOWN_DECLARE(message_cooldown)

/obj/structure/exile_gate/Initialize(mapload)
	. = ..()
	add_atom_colour("#6BC906", FIXED_COLOUR_PRIORITY)
	RegisterSignal(loc, COMSIG_ATOM_ENTERED, PROC_REF(on_enter))

/obj/structure/exile_gate/Destroy()
	if(loc)
		UnregisterSignal(loc, COMSIG_ATOM_ENTERED)
	return ..()

/obj/structure/exile_gate/proc/on_enter(datum/source, atom/movable/arrived, atom/old_loc)
	SIGNAL_HANDLER
	if(isliving(arrived))
		INVOKE_ASYNC(src, PROC_REF(try_enter), arrived)

/obj/structure/exile_gate/attack_hand(mob/living/user)
	. = ..()
	if(.)
		return
	INVOKE_ASYNC(src, PROC_REF(try_enter), user)
	return TRUE

/obj/structure/exile_gate/proc/try_enter(mob/living/user)
	var/obj/machinery/quantum_server/exile_loop/server = SSbitrunning.exile_loop?.server
	if(isnull(server) || isnull(server.generated_domain) || !server.is_ready)
		if(COOLDOWN_FINISHED(src, message_cooldown))
			COOLDOWN_START(src, message_cooldown, 3 SECONDS)
			balloon_alert(user, "nic nie załadowano")
		return

	var/atom/entry = server.get_exile_entry()
	if(isnull(entry))
		balloon_alert(user, "brak wejścia do domeny")
		return

	if(!do_after(user, 1 SECONDS, target = src))
		return
	var/datum/lazy_template/virtual_domain/domain = server.generated_domain
	if(QDELETED(domain))
		return
	var/turf/entry_turf = get_turf(entry)
	if(!istype(entry, /obj/effect/mob_spawn) && !(locate(/obj/structure/hololadder) in entry_turf))
		new /obj/structure/hololadder(entry_turf, server)
	playsound(user, 'sound/magic/blink.ogg', 40, TRUE)
	user.forceMove(entry_turf)
	if(domain.forced_outfit && ishuman(user))
		apply_exile_outfit(user, domain.forced_outfit)
	for(var/datum/action/avatar_domain_info/old_action in user.actions)
		qdel(old_action)
	if(domain.help_text)
		var/datum/action/avatar_domain_info/action = new(new /datum/avatar_help_text(domain.help_text))
		action.Grant(user)

/// Przebiera wygnańca w strój wymagany przez domenę albo z powrotem w strój więźnia
/proc/apply_exile_outfit(mob/living/carbon/human/exile, datum/outfit/outfit_path)
	for(var/obj/item/worn in exile.get_equipped_items(TRUE) + exile.held_items)
		if(istype(worn, /obj/item/card/id))
			continue
		qdel(worn)
	var/datum/component/echolocation/echo = exile.GetComponent(/datum/component/echolocation)
	if(echo)
		qdel(echo)
	var/datum/outfit/to_wear = new outfit_path()
	if(outfit_path != /datum/outfit/digital_exile)
		to_wear.id = null
		to_wear.belt = /obj/item/bitrunning_host_monitor
	exile.equipOutfit(to_wear)

/// Gdzie wygnaniec wchodzi do domeny (drabiny nie są zużywane, bo nie tworzą nowych awatarów)
/obj/machinery/quantum_server/exile_loop/proc/get_exile_entry()
	if(length(generated_domain.custom_spawns))
		for(var/atom/spawner as anything in generated_domain.custom_spawns)
			if(!QDELETED(spawner))
				return spawner
	if(length(exit_turfs))
		return pick(exit_turfs)

#undef EXILE_LOOP_MAP
#undef EXILE_LOOP_POINTS
