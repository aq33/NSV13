// The upstream assert macros are #undef'd at the end of code/modules/unit_tests/_unit_tests.dm, so this modular test carries its own copies
#define TEST_ASSERT(assertion, reason) if (!(assertion)) { return Fail("Assertion failed: [reason || "No reason"]") }

#define TEST_ASSERT_EQUAL(a, b, message) do { \
	var/lhs = ##a; \
	var/rhs = ##b; \
	if (lhs != rhs) { \
		return Fail("Expected [isnull(lhs) ? "null" : lhs] to be equal to [isnull(rhs) ? "null" : rhs].[message ? " [message]" : ""]"); \
	} \
} while (FALSE)

/// AQUILA - Revenant (#245): sees ghosts, recall spell only off the station, orbit rules
/datum/unit_test/revenant_ghost_sight_and_recall

/datum/unit_test/revenant_ghost_sight_and_recall/Run()
	var/mob/living/simple_animal/revenant/rev = allocate(/mob/living/simple_animal/revenant)
	TEST_ASSERT(rev.see_invisible >= INVISIBILITY_OBSERVER, "Revenant cannot see ghosts")
	TEST_ASSERT(rev.see_invisible >= INVISIBILITY_REVENANT, "Revenant cannot see other revenants")
	TEST_ASSERT(rev.see_invisible < INVISIBILITY_ABSTRACT, "Revenant sees abstract things")
	rev.update_sight()
	TEST_ASSERT(rev.see_invisible >= INVISIBILITY_OBSERVER, "update_sight took the ghost sight away")

	// The unit test room is not a station level
	TEST_ASSERT(!is_station_level(rev.z), "The test room counts as the station")
	TEST_ASSERT(locate(/obj/effect/proc_holder/spell/self/rev_teleport) in rev.mob_spell_list, "No recall spell off the station")
	var/turf/station_turf = get_safe_random_station_turfs()
	TEST_ASSERT(station_turf, "No station turf to move to")
	rev.forceMove(station_turf)
	TEST_ASSERT(!(locate(/obj/effect/proc_holder/spell/self/rev_teleport) in rev.mob_spell_list), "Recall spell kept on the station")
	rev.forceMove(run_loc_floor_bottom_left)
	TEST_ASSERT(locate(/obj/effect/proc_holder/spell/self/rev_teleport) in rev.mob_spell_list, "Recall spell not given back after leaving the station")
	var/spells = 0
	for(var/obj/effect/proc_holder/spell/self/rev_teleport/S in rev.mob_spell_list)
		spells++
	TEST_ASSERT_EQUAL(spells, 1, "Recall spell given more than once")

/datum/unit_test/revenant_orbit

/datum/unit_test/revenant_orbit/Run()
	var/turf/left = run_loc_floor_bottom_left
	var/turf/right = get_step(left, EAST)
	var/turf/further = get_step(right, EAST)
	var/mob/living/simple_animal/revenant/rev = allocate(/mob/living/simple_animal/revenant, left)
	var/mob/living/simple_animal/revenant/other_rev = allocate(/mob/living/simple_animal/revenant, right)

	// Never another revenant
	rev.check_orbitable(other_rev)
	TEST_ASSERT(!rev.orbiting, "Revenant orbited another revenant")
	qdel(other_rev)

	// Something living next to it is fine, something far away is not
	var/mob/living/carbon/human/far = allocate(/mob/living/carbon/human, get_step(further, EAST))
	rev.check_orbitable(far)
	TEST_ASSERT(!rev.orbiting, "Revenant orbited something that is not next to it")
	var/mob/living/carbon/human/host = allocate(/mob/living/carbon/human, right)
	rev.check_orbitable(host)
	TEST_ASSERT(rev.orbiting, "Revenant could not orbit a human next to it")

	// The orbited human walks onto salt: the revenant lets go and stays behind
	var/obj/effect/decal/cleanable/food/salt/salt = allocate(/obj/effect/decal/cleanable/food/salt, further)
	host.forceMove(further)
	TEST_ASSERT(!rev.orbiting, "Revenant kept orbiting onto salt")
	TEST_ASSERT(get_turf(rev) != further, "Revenant was carried onto salt")
	TEST_ASSERT(!rev.incorporeal_move_check(salt), "Salt does not block a revenant")
	TEST_ASSERT(rev.incorporeal_move_check(left), "A plain floor blocks a revenant")

	// Revealed revenants cannot orbit
	rev.unreveal_time = 0
	rev.revealed = TRUE
	host.forceMove(get_step(get_turf(rev), EAST))
	rev.check_orbitable(host)
	TEST_ASSERT(!rev.orbiting, "Revealed revenant orbited")

#undef TEST_ASSERT
#undef TEST_ASSERT_EQUAL
