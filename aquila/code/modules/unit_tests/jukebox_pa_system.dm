// The upstream assert macros are #undef'd at the end of code/modules/unit_tests/_unit_tests.dm, so this modular test carries its own copies
#define TEST_ASSERT(assertion, reason) if (!(assertion)) { return Fail("Assertion failed: [reason || "No reason"]") }
#define TEST_ASSERT_EQUAL(a, b, message) if ((a) != (b)) { return Fail("Expected [isnull(a) ? "null" : a] to be equal to [isnull(b) ? "null" : b].[message ? " [message]" : ""]") }

/// AQUILA - jukebox nagłośnienie: zamknięte drzwi tłumią, otwarte nie, amp stack tłumi przez ściany mocniej,
/// podłączanie amp stacka i jego wyłączanie, wieszanie głośnika nagłośnienia, sprzątanie po zniszczeniu jukeboxa
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

	// Głośnik nagłośnienia: wisi tylko przy ścianie i nie nad zajętą kratką, gra głośnością nadawania
	var/turf/corner = run_loc_floor_top_right // róg pokoju testowego, obok ściany
	TEST_ASSERT(SSjukeboxes.ceiling_speaker_wall(corner, list()), "No wall found next to the test room corner")
	TEST_ASSERT(!SSjukeboxes.ceiling_speaker_wall(source_turf, list()), "Speaker would hang over a dense jukebox")
	var/obj/machinery/ceiling_speaker/ceiling = allocate(/obj/machinery/ceiling_speaker, corner)
	TEST_ASSERT(ceiling in SSjukeboxes.ceiling_speakers, "Ceiling speaker did not register")
	var/expected_ceiling_gain = JUKEBOX_SHIPWIDE_GAIN * jukebox.volume / 100
	TEST_ASSERT(abs(jukebox.emitter_max_gain(ceiling.emitter) - expected_ceiling_gain) < 0.001, "Ceiling speaker should play at the broadcast volume")
	TEST_ASSERT(!(ceiling.emitter in jukebox.active_emitters()), "Ceiling speaker plays without shipwide broadcast")
	qdel(ceiling)
	TEST_ASSERT(!(ceiling in SSjukeboxes.ceiling_speakers), "Destroyed ceiling speaker is still registered")

	// Głośnik Syndykatu gra też odkręcony (ciągnięty za sobą), zwykły jukebox nie
	var/obj/machinery/jukebox/nukie/nukie = allocate(/obj/machinery/jukebox/nukie, corner)
	nukie.anchored = FALSE
	TEST_ASSERT(nukie.is_secured(), "Syndicate speaker should play while unanchored")
	jukebox.anchored = FALSE
	TEST_ASSERT(!jukebox.is_secured(), "A normal jukebox should not play while unanchored")
	jukebox.anchored = TRUE

	// Zniszczony jukebox odłącza amp stacki
	qdel(jukebox)
	TEST_ASSERT(isnull(speaker.jukebox), "Amp stack still points at a destroyed jukebox")

#undef TEST_ASSERT
#undef TEST_ASSERT_EQUAL
