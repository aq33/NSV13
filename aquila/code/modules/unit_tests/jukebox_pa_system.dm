// The upstream assert macros are #undef'd at the end of code/modules/unit_tests/_unit_tests.dm, so this modular test carries its own copies
#define TEST_ASSERT(assertion, reason) if (!(assertion)) { return Fail("Assertion failed: [reason || "No reason"]") }
#define TEST_ASSERT_EQUAL(a, b, message) if ((a) != (b)) { return Fail("Expected [isnull(a) ? "null" : a] to be equal to [isnull(b) ? "null" : b].[message ? " [message]" : ""]") }

/// AQUILA - jukebox nagłośnienie: zamknięte drzwi tłumią, otwarte nie, amp stack tłumi przez ściany mocniej,
/// podłączanie amp stacka i jego wyłączanie, sprzątanie połączeń po zniszczeniu jukeboxa
/datum/unit_test/jukebox_pa_system

/datum/unit_test/jukebox_pa_system/Run()
	var/turf/source_turf = run_loc_floor_bottom_left
	var/turf/door_turf = locate(source_turf.x + 1, source_turf.y, source_turf.z)
	var/turf/listener_turf = locate(source_turf.x + 2, source_turf.y, source_turf.z)
	TEST_ASSERT(listener_turf.x <= run_loc_floor_top_right.x, "Test room is too narrow")

	var/obj/machinery/jukebox/jukebox = allocate(/obj/machinery/jukebox, source_turf)
	var/obj/machinery/jukebox_speaker/speaker = allocate(/obj/machinery/jukebox_speaker, source_turf)
	var/obj/machinery/door/airlock/door = allocate(/obj/machinery/door/airlock, door_turf)
	var/mob/living/carbon/human/listener = allocate(/mob/living/carbon/human, listener_turf)

	// Zamknięte drzwi tłumią
	door.density = TRUE
	jukebox.emitter.dampening_cache_time = 0
	var/closed_muffle = jukebox.emitter.muffle_amount(listener)
	TEST_ASSERT_EQUAL(closed_muffle, door.sound_dampening, "Closed door should dampen by its sound_dampening")

	// Amp stack przebija ściany słabiej (podwójne wygłuszenie)
	speaker.emitter.dampening_cache_time = 0
	TEST_ASSERT_EQUAL(speaker.emitter.muffle_amount(listener), min(1, closed_muffle * 2), "Amp stack should dampen twice as much")

	// Otwarte drzwi nie tłumią
	door.density = FALSE
	jukebox.emitter.dampening_cache_time = 0
	TEST_ASSERT_EQUAL(jukebox.emitter.muffle_amount(listener), 0, "Open door should not dampen")

	// Podłączenie i wyłączanie amp stacka
	speaker.link_to(jukebox)
	TEST_ASSERT(speaker in jukebox.speakers, "Linked amp stack is missing from the jukebox")
	speaker.machine_stat = NONE
	speaker.enabled = TRUE
	TEST_ASSERT(speaker.emitter in jukebox.active_emitters(), "Enabled amp stack does not play")
	speaker.enabled = FALSE
	TEST_ASSERT(!(speaker.emitter in jukebox.active_emitters()), "Disabled amp stack still plays")
	var/expected_gain = jukebox.emitter_max_gain(jukebox.emitter) * speaker.max_gain
	TEST_ASSERT(abs(jukebox.emitter_max_gain(speaker.emitter) - expected_gain) < 0.001, "Amp stack should be quieter than the jukebox")

	// Nadawanie w maincie: odległość do najbliższego pomieszczenia (kratka obok to pokój testowy)
	var/area/room = get_area(listener_turf)
	var/area/maintenance/maint = new
	maint.contents += listener_turf
	SSjukeboxes.maint_distance_cache_time = 0
	var/maint_distance = SSjukeboxes.broadcast_area_distance(listener_turf)
	room.contents += listener_turf // pokój testowy musi zostać nietknięty dla kolejnych testów
	TEST_ASSERT(!SSjukeboxes.is_broadcast_area(maint), "Maintenance should not hear the broadcast normally")
	TEST_ASSERT(SSjukeboxes.is_broadcast_area(room), "A normal room should hear the broadcast")
	TEST_ASSERT_EQUAL(maint_distance, 1, "Maintenance next to a room should be 1 tile from it")
	SSjukeboxes.maint_distance_cache_time = 0

	// Zniszczony jukebox odłącza amp stacki
	qdel(jukebox)
	TEST_ASSERT(isnull(speaker.jukebox), "Amp stack still points at a destroyed jukebox")

#undef TEST_ASSERT
#undef TEST_ASSERT_EQUAL
