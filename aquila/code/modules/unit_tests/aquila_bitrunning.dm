// The upstream assert macros are #undef'd at the end of code/modules/unit_tests/_unit_tests.dm, so this modular test carries its own copy
#define TEST_ASSERT(assertion, reason) if (!(assertion)) { return Fail("Assertion failed: [reason || "No reason"]") }

/// AQUILA - bitrunning (port z tg): ustawienia domen, mapy, łupy
/datum/unit_test/aquila_bitrunning_domains

/datum/unit_test/aquila_bitrunning_domains/Run()
	var/obj/structure/closet/crate/secure/bitrunning/decrypted/cache = allocate(/obj/structure/closet/crate/secure/bitrunning/decrypted)
	var/list/keys = list()

	for(var/path in subtypesof(/datum/lazy_template/virtual_domain))
		var/datum/lazy_template/virtual_domain/vdom = new path
		TEST_ASSERT(vdom.key, "[path] should have a key")
		TEST_ASSERT(vdom.map_name, "[path] should have a map name")
		TEST_ASSERT(!keys[vdom.key], "[path] has a duplicate key [vdom.key]")
		keys[vdom.key] = TRUE
		var/map_path = vdom.get_map_path()
		TEST_ASSERT(fexists(map_path), "[path] has no map file [map_path]")
		var/datum/map_template/template = new(map_path, "unit test [vdom.key]")
		TEST_ASSERT(template.width && template.height, "[map_path] could not be parsed")

		if(length(vdom.completion_loot))
			TEST_ASSERT(cache.spawn_loot(vdom.completion_loot), "[path] didn't spawn loot. Completion loot should be an associative list")
		qdel(vdom)

	TEST_ASSERT(length(SSbitrunning.all_domains) == length(keys), "SSbitrunning has [length(SSbitrunning.all_domains)] domains, expected [length(keys)]")

/// AQUILA - serwer kwantowy ładuje domenę testową, tworzy awatara i czyści ją po resecie
/datum/unit_test/aquila_bitrunning_server

/datum/unit_test/aquila_bitrunning_server/Run()
	var/obj/machinery/quantum_server/server = allocate(/obj/machinery/quantum_server)
	var/obj/machinery/byteforge/forge = allocate(/obj/machinery/byteforge, locate(run_loc_floor_bottom_left.x + 1, run_loc_floor_bottom_left.y, run_loc_floor_bottom_left.z))
	TEST_ASSERT(forge, "No byteforge")

	TEST_ASSERT(!server.cold_boot_map("test_only_expensive"), "Server loaded a domain it cannot afford")
	TEST_ASSERT(server.cold_boot_map("test_only"), "Server failed to load the test domain")
	TEST_ASSERT(server.generated_domain, "No generated domain after load")
	TEST_ASSERT(length(server.exit_turfs), "Test domain has no exit turfs")
	TEST_ASSERT(length(server.goal_turfs), "Test domain has no goal turfs")

	var/datum/turf_reservation/reservation = server.generated_domain.reservations[1]
	var/obj/structure/closet/crate/secure/bitrunning/encrypted/crate
	for(var/turf/tile as anything in reservation.reserved_turfs)
		crate = locate() in tile
		if(crate)
			break
	if(!crate) // domena testowa z tg nie ma miejsca na skrzynię, więc kładziemy ją sami
		crate = new(get_step(server.exit_turfs[1], NORTH))

	var/mob/living/carbon/human/neo = allocate(/mob/living/carbon/human)
	var/mob/living/carbon/human/avatar = server.start_new_connection(neo, /datum/outfit/job/bitrunner)
	TEST_ASSERT(avatar, "Server failed to generate an avatar")
	TEST_ASSERT(locate(/obj/structure/hololadder) in get_turf(avatar), "Avatar did not spawn on a hololadder")
	TEST_ASSERT(istype(avatar.belt, /obj/item/bitrunning_host_monitor), "Avatar has no host monitor")

	// Dostarczenie skrzyni daje nagrodę na byteforge'u
	var/old_points = server.points
	crate.forceMove(server.goal_turfs[1])
	TEST_ASSERT(server.domain_complete, "Delivering the cache did not complete the domain")
	TEST_ASSERT(server.points > old_points, "Completing the domain gave no points")

	server.reset(fast = TRUE)
	TEST_ASSERT(isnull(server.generated_domain), "Domain was not scrubbed on reset")
	TEST_ASSERT(QDELETED(avatar), "Avatar survived the domain scrub")

/// AQUILA - Pętla wygnańców się ładuje i wygnaniec nie może z niej wyjść
/datum/unit_test/aquila_bitrunning_exile

/datum/unit_test/aquila_bitrunning_exile/Run()
	var/datum/exile_loop/loop = SSbitrunning.get_exile_loop()
	TEST_ASSERT(loop, "Exile loop failed to load")
	TEST_ASSERT(length(loop.spawn_turfs), "Exile loop has no spawn turfs")
	TEST_ASSERT(loop.server, "Exile loop has no server")
	var/obj/machinery/computer/quantum_console/exile_loop/console = locate() in range(1, loop.server)
	TEST_ASSERT(console, "Exile loop has no console next to the server")
	TEST_ASSERT(console.find_server() == loop.server, "Exile console is not connected to the loop server")

	var/mob/living/carbon/human/template = allocate(/mob/living/carbon/human)
	var/mob/living/carbon/human/exile = loop.create_exile_avatar(template)
	TEST_ASSERT(exile, "Exile loop failed to create an avatar")
	var/datum/mind/exile_mind = new("exile_test")
	exile_mind.current = exile
	exile.mind = exile_mind
	exile.AddComponent(/datum/component/digital_exile, exile_mind)
	TEST_ASSERT(HAS_TRAIT(exile, TRAIT_DIGITAL_EXILE), "Exile component did not add the trait")

	// Wygnaniec poza Pętlą wraca do niej przez drabinę
	exile.forceMove(run_loc_floor_bottom_left)
	SEND_SIGNAL(exile, COMSIG_BITRUNNER_LADDER_SEVER)
	sleep(1)
	TEST_ASSERT(get_turf(exile) in loop.spawn_turfs, "Ladder sever did not send the exile back to the loop")
	qdel(exile.GetComponent(/datum/component/digital_exile))
	GLOB.digital_exiles -= exile_mind
	qdel(exile)

#undef TEST_ASSERT
