// The upstream assert macros are #undef'd at the end of code/modules/unit_tests/_unit_tests.dm, so this modular test carries its own copies
#define TEST_ASSERT(assertion, reason) if (!(assertion)) { return Fail("Assertion failed: [reason || "No reason"]") }

#define TEST_ASSERT_EQUAL(a, b, message) do { \
	var/lhs = ##a; \
	var/rhs = ##b; \
	if (lhs != rhs) { \
		return Fail("Expected [isnull(lhs) ? "null" : lhs] to be equal to [isnull(rhs) ? "null" : rhs].[message ? " [message]" : ""]"); \
	} \
} while (FALSE)

/// AQUILA - tgstation#90775: the xenobio console sucks slimes up and spits them out through a tube, and its HUD follows the counts
/datum/unit_test/aquila_xenobio_tubes

/datum/unit_test/aquila_xenobio_tubes/Run()
	var/turf/slime_turf = run_loc_floor_top_right
	var/obj/machinery/computer/camera_advanced/xenobio/console = allocate(/obj/machinery/computer/camera_advanced/xenobio)
	var/mob/living/simple_animal/slime/slime = allocate(/mob/living/simple_animal/slime, slime_turf)
	TEST_ASSERT(console.xeno_hud, "Xenobio console has no HUD")
	TEST_ASSERT(findtext(console.xeno_hud.maptext, "0/[console.max_slimes]"), "Empty console HUD does not show 0 slimes: [console.xeno_hud.maptext]")

	slime.forceMove(console)
	console.stored_slimes += slime
	TEST_ASSERT(findtext(console.xeno_hud.maptext, "1/[console.max_slimes]"), "Console HUD did not count the stored slime: [console.xeno_hud.maptext]")
	TEST_ASSERT(locate(/obj/effect/abstract/xenosuction) in slime_turf, "No tube appeared where the slime was sucked up")

	console.monkeys = 3
	console.aquila_monkey_spat(allocate(/mob/living/carbon/monkey, run_loc_floor_bottom_left))
	TEST_ASSERT(findtext(console.xeno_hud.maptext, "3\n1/[console.max_slimes]"), "Console HUD does not show the monkey count: [console.xeno_hud.maptext]")
	TEST_ASSERT(locate(/obj/effect/abstract/xenosuction) in run_loc_floor_bottom_left, "No tube appeared where the monkey was spat out")

	slime.forceMove(slime_turf)
	console.stored_slimes -= slime
	TEST_ASSERT(findtext(console.xeno_hud.maptext, "0/[console.max_slimes]"), "Console HUD still counts the placed slime: [console.xeno_hud.maptext]")
	TEST_ASSERT_EQUAL(slime.invisibility, INVISIBILITY_MAXIMUM, "Spat out slime is visible before the tube animation ends")
	console.restore_visibility(slime, 0)
	TEST_ASSERT_EQUAL(slime.invisibility, 0, "Spat out slime did not become visible again")

	var/obj/machinery/monkey_recycler/recycler = allocate(/obj/machinery/monkey_recycler)
	COMPILE_OVERLAYS(recycler) // overlays are queued for SSoverlays, which does not fire inside the test
	TEST_ASSERT(length(recycler.overlays), "Monkey recycler has no stripes overlay")

#undef TEST_ASSERT
#undef TEST_ASSERT_EQUAL
