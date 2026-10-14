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

/// AQUILA - moce z tg: rewenant je dostaje, Haunt Object nawiedza przedmiot, święty przedmiot to rozprasza
/datum/unit_test/revenant_haunt_object

/datum/unit_test/revenant_haunt_object/Run()
	var/turf/left = run_loc_floor_bottom_left
	var/turf/right = get_step(left, EAST)
	var/mob/living/simple_animal/revenant/rev = allocate(/mob/living/simple_animal/revenant, left)
	TEST_ASSERT(HAS_TRAIT(rev, TRAIT_SIXTHSENSE), "Revenant cannot hear the dead")
	TEST_ASSERT(!findtext(rev.name, " of "), "Revenant got an English name: [rev.name]")
	var/obj/effect/proc_holder/spell/aoe_turf/revenant/haunt_object/haunt = locate() in rev.mob_spell_list
	TEST_ASSERT(haunt, "Revenant has no Haunt Object")
	TEST_ASSERT(locate(/obj/effect/proc_holder/spell/aoe_turf/revenant/vortex) in rev.mob_spell_list, "Revenant has no Vortex")
	TEST_ASSERT(locate(/obj/effect/proc_holder/spell/aoe_turf/revenant/vortex/scatter) in rev.mob_spell_list, "Revenant has no Scatter")

	var/mob/living/carbon/human/victim = allocate(/mob/living/carbon/human, get_step(right, EAST))
	var/obj/item/wrench/wrench = allocate(/obj/item/wrench, right)
	var/old_throwforce = wrench.throwforce
	// Dalsze przedmioty ponad limit nie mogą zabrać miejsca temu obok
	var/turf/far_turf = get_step(get_step(right, EAST), EAST)
	for(var/i in 1 to haunt.max_targets + 1)
		allocate(/obj/item/screwdriver, far_turf)
	var/list/candidates = haunt.get_haunt_candidates(rev)
	TEST_ASSERT_EQUAL(length(candidates), haunt.max_targets, "Haunt Object did not cap its targets")
	TEST_ASSERT_EQUAL(candidates[1], wrench, "Haunt Object did not pick the closest item first")
	haunt.locked = FALSE
	rev.essence = 200
	haunt.cast(list(left), rev)
	TEST_ASSERT(istype(wrench.ai_controller, /datum/ai_controller/haunted), "Haunt Object did not haunt the item next to the revenant")
	TEST_ASSERT(wrench.throwforce > old_throwforce, "Haunted item did not get stronger throws")
	TEST_ASSERT(rev.essence < 200, "Haunt Object cost no essence")
	TEST_ASSERT(rev.revealed, "Haunt Object did not reveal the revenant")
	var/list/hauntee_list = wrench.ai_controller.blackboard[BB_TO_HAUNT_LIST]
	TEST_ASSERT(hauntee_list[victim] > 0, "Haunted item does not want to attack the human nearby")
	TEST_ASSERT(!hauntee_list[rev], "Haunted item wants to attack the revenant")

	var/obj/item/nullrod/rod = allocate(/obj/item/nullrod, right)
	SEND_SIGNAL(wrench, COMSIG_PARENT_ATTACKBY, rod, victim, null)
	TEST_ASSERT(!wrench.GetComponent(/datum/component/haunted_item), "Null rod did not dispel the haunting")
	TEST_ASSERT(isnull(wrench.ai_controller), "Dispelled item kept its haunted AI")
	TEST_ASSERT_EQUAL(wrench.throwforce, old_throwforce, "Dispelled item kept the throw bonus")

/// AQUILA - Vortex opróżnia pojemnik obok i przyciąga przedmioty
/datum/unit_test/revenant_vortex

/datum/unit_test/revenant_vortex/Run()
	var/turf/left = run_loc_floor_bottom_left
	var/turf/right = get_step(left, EAST)
	var/turf/further = get_step(get_step(right, EAST), EAST)
	var/mob/living/simple_animal/revenant/rev = allocate(/mob/living/simple_animal/revenant, left)
	var/obj/effect/proc_holder/spell/aoe_turf/revenant/vortex/vortex = locate() in rev.mob_spell_list
	if(istype(vortex, /obj/effect/proc_holder/spell/aoe_turf/revenant/vortex/scatter))
		for(var/obj/effect/proc_holder/spell/aoe_turf/revenant/vortex/V in rev.mob_spell_list)
			if(V.type == /obj/effect/proc_holder/spell/aoe_turf/revenant/vortex)
				vortex = V
	var/obj/item/storage/box/box = allocate(/obj/item/storage/box, right)
	var/obj/item/wrench/inside = new(box)
	var/obj/item/screwdriver/far_item = allocate(/obj/item/screwdriver, further)
	var/old_distance = get_dist(far_item, left)
	vortex.locked = FALSE
	rev.essence = 200
	vortex.cast(list(left, right), rev) // wir najpierw przyciąga pudełko pod rewenanta
	TEST_ASSERT(isturf(inside.loc), "Vortex did not dump the box next to the revenant")
	TEST_ASSERT(get_dist(far_item, left) < old_distance, "Vortex did not pull a nearby item closer")
	TEST_ASSERT_EQUAL(get_turf(rev), left, "Vortex moved the revenant itself")
	qdel(inside)

/// AQUILA - rozsypana ektoplazma ucieka do lustra, rozbicie lustra ją wypuszcza
/datum/unit_test/revenant_mirror_prison

/datum/unit_test/revenant_mirror_prison/Run()
	var/turf/left = run_loc_floor_bottom_left
	var/turf/right = get_step(left, EAST)
	var/obj/structure/mirror/mirror = allocate(/obj/structure/mirror, right)
	var/datum/component/revenant_prison/roundstart_curse = mirror.GetComponent(/datum/component/revenant_prison)
	if(roundstart_curse) // allocate nie jest ładowaniem mapy, ale na wszelki wypadek
		qdel(roundstart_curse)
	var/mob/living/simple_animal/revenant/rev = allocate(/mob/living/simple_animal/revenant, left)
	var/obj/item/ectoplasm/revenant/ecto = allocate(/obj/item/ectoplasm/revenant, left)
	ecto.revenant = rev
	ecto.essence = 120
	ecto.scatter()
	TEST_ASSERT(!QDELETED(rev), "Scattering the ectoplasm killed the revenant despite a mirror nearby")
	TEST_ASSERT_EQUAL(rev.loc, mirror, "Revenant did not flee into the mirror")
	TEST_ASSERT(mirror.GetComponent(/datum/component/revenant_prison), "Mirror holds no revenant")
	TEST_ASSERT(!rev.castcheck(0), "Imprisoned revenant can use its powers")
	TEST_ASSERT(locate(/datum/action/mirror_talk) in rev.actions, "Imprisoned revenant cannot talk through the mirror")
	TEST_ASSERT(!mirror.can_hold_revenant(), "An occupied mirror takes another revenant")

	mirror.obj_break()
	TEST_ASSERT(!mirror.GetComponent(/datum/component/revenant_prison), "Broken mirror still holds the revenant")
	// W testach ankieta od razu kończy się bez chętnych, więc uwolniony rewenant rozsypuje się w bezwładny pył przy lustrze
	if(!QDELETED(rev))
		TEST_ASSERT_EQUAL(rev.loc, right, "Released revenant is not next to the mirror")
		TEST_ASSERT_EQUAL(rev.essence_regen_cap, 120, "Released revenant lost its essence cap")
		TEST_ASSERT(rev.incorporeal_move, "Released revenant cannot move through walls")
		TEST_ASSERT(!(locate(/datum/action/mirror_talk) in rev.actions), "Released revenant kept Mirror Talk")
		qdel(rev)
	else
		var/obj/item/ectoplasm/revenant/dust = locate() in right
		TEST_ASSERT(dust?.inert, "Unclaimed released revenant left no inert residue next to the mirror")
		qdel(dust)

	// Bez lustra w pobliżu rozsypanie dalej zabija rewenanta
	var/mob/living/simple_animal/revenant/doomed = allocate(/mob/living/simple_animal/revenant, left)
	var/obj/item/ectoplasm/revenant/ecto2 = allocate(/obj/item/ectoplasm/revenant, left)
	ecto2.revenant = doomed
	ecto2.scatter()
	TEST_ASSERT(QDELETED(doomed), "Revenant survived scattering next to a broken mirror")

/// AQUILA - rozebranie lustra też wypuszcza upiora, zamiast usunąć go razem z komponentem
/datum/unit_test/revenant_mirror_deconstruct

/datum/unit_test/revenant_mirror_deconstruct/Run()
	var/turf/left = run_loc_floor_bottom_left
	var/turf/right = get_step(left, EAST)
	var/obj/structure/mirror/mirror = allocate(/obj/structure/mirror, right)
	var/datum/component/revenant_prison/roundstart_curse = mirror.GetComponent(/datum/component/revenant_prison)
	if(roundstart_curse)
		qdel(roundstart_curse)
	var/mob/living/simple_animal/revenant/rev = allocate(/mob/living/simple_animal/revenant, left)
	var/obj/item/ectoplasm/revenant/ecto = allocate(/obj/item/ectoplasm/revenant, left)
	ecto.revenant = rev
	ecto.essence = 120
	ecto.scatter()
	TEST_ASSERT_EQUAL(rev.loc, mirror, "Revenant did not flee into the mirror")

	mirror.deconstruct(FALSE)
	TEST_ASSERT(QDELETED(mirror), "Mirror was not deconstructed")
	// Jak przy rozbiciu: bez chętnych w ankiecie upiór rozsypuje się w bezwładny pył przy lustrze
	if(!QDELETED(rev))
		TEST_ASSERT_EQUAL(rev.loc, right, "Revenant was not released where the mirror stood")
		TEST_ASSERT_EQUAL(rev.essence_regen_cap, 120, "Released revenant lost its essence cap")
		qdel(rev)
	else
		var/obj/item/ectoplasm/revenant/dust = locate() in right
		TEST_ASSERT(dust?.inert, "Deconstructing the mirror deleted the revenant instead of releasing it")
		qdel(dust)
	for(var/obj/item/shard/shard in right)
		qdel(shard)

#undef TEST_ASSERT
#undef TEST_ASSERT_EQUAL
