// Makra asercji z upstreamu są #undef na końcu code/modules/unit_tests/_unit_tests.dm, więc ten test ma własne kopie
#define TEST_ASSERT(assertion, reason) if (!(assertion)) { return Fail("Assertion failed: [reason || "No reason"]") }

#define TEST_ASSERT_EQUAL(a, b, message) do { \
	var/lhs = ##a; \
	var/rhs = ##b; \
	if (lhs != rhs) { \
		return Fail("Expected [isnull(lhs) ? "null" : lhs] to be equal to [isnull(rhs) ? "null" : rhs].[message ? " [message]" : ""]"); \
	} \
} while (FALSE)

/// AQUILA - wędrowiec pustki: moce, kamuflaż, porwanie do pustki, klątwa, nurkowanie i łupy
/datum/unit_test/voidwalker

/datum/unit_test/voidwalker/Run()
	var/runtimes_before = GLOB.total_runtimes
	var/turf/left = run_loc_floor_bottom_left
	var/turf/right = get_step(left, EAST)

	TEST_ASSERT(ispath(/datum/round_event_control/voidwalker), "No voidwalker event")
	TEST_ASSERT(ispath(/datum/dynamic_ruleset/midround/from_ghosts/voidwalker), "No voidwalker ruleset")
	find_voidwalker_spawn()

	var/mob/living/simple_animal/hostile/voidwalker/walker = allocate(/mob/living/simple_animal/hostile/voidwalker, left)
	TEST_ASSERT(walker.real_name in GLOB.voidwalker_names, "Voidwalker did not get a void name")
	TEST_ASSERT(locate(/obj/effect/proc_holder/spell/pointed/unsettle) in walker.mob_spell_list, "No unsettle")
	TEST_ASSERT(locate(/obj/effect/proc_holder/spell/pointed/voidwalker_dash) in walker.mob_spell_list, "No dash")
	TEST_ASSERT(locate(/obj/effect/proc_holder/spell/targeted/telepathy/voidwalker) in walker.mob_spell_list, "No telepathy")
	TEST_ASSERT_EQUAL(walker.dash.action.button_icon, 'aquila/icons/mob/actions/actions_voidwalker.dmi', "Wrong action background file")
	TEST_ASSERT(!walker.camouflaged && walker.alpha == 255, "Voidwalker is hidden on a floor")
	TEST_ASSERT(walker.pass_flags & PASSGLASS, "Voidwalker cannot pass glass")

	// Kamuflaż działa tylko w kosmosie i znika po ciosie
	walker.home_turf = left.type
	walker.update_camo()
	TEST_ASSERT(walker.camouflaged, "Voidwalker did not hide on its home turf")
	walker.adjustBruteLoss(5)
	TEST_ASSERT(!walker.camouflaged, "Voidwalker stayed hidden after taking damage")
	walker.home_turf = initial(walker.home_turf)
	walker.reveal_until = 0
	walker.update_camo()

	// Porwanie: klątwa, kosmiczna skóra, pustka i wisp
	var/mob/living/carbon/human/victim = allocate(/mob/living/carbon/human, right)
	var/conversions = walker.conversions_remaining
	walker.take_them(victim)
	TEST_ASSERT(victim.has_trauma_type(/datum/brain_trauma/voided), "Victim was not voided")
	TEST_ASSERT(HAS_TRAIT(victim, TRAIT_PACIFISM), "Voided victim is not a pacifist")
	TEST_ASSERT(victim.void_skin_color, "Voided victim has no space skin")
	TEST_ASSERT_EQUAL(walker.conversions_remaining, conversions + 1, "Kidnap did not refill wall conversions")
	var/obj/effect/wisp_mobile/wisp = victim.loc
	TEST_ASSERT(istype(wisp), "Victim is not riding a wisp")
	TEST_ASSERT(istype(get_area(wisp), /area/centcom/voidwalker_void), "Wisp is not in the void")
	TEST_ASSERT(HAS_TRAIT(victim, TRAIT_NODEATH), "Wisp driver can die")
	TEST_ASSERT(locate(/obj/effect/wisp_food) in world, "No wisp food in the void")
	wisp.send_back(victim)
	TEST_ASSERT(QDELETED(wisp), "Wisp survived its driver leaving")
	TEST_ASSERT(!HAS_TRAIT(victim, TRAIT_NODEATH), "Wisp traits were not removed")
	victim.forceMove(right)

	// Oświecony nie wejdzie w kosmos, a stabilna klątwa daje odporność na próżnię
	var/datum/brain_trauma/voided/curse = locate() in victim.get_traumas()
	curse.nebula_vomit()
	TEST_ASSERT(locate(/obj/effect/decal/cleanable/vomit/nebula) in right, "No nebula vomit")
	TEST_ASSERT(length(GLOB.nebula_vomits), "Nebula vomit is not tracked")
	victim.cure_trauma_type(/datum/brain_trauma/voided, TRAUMA_RESILIENCE_LOBOTOMY)
	TEST_ASSERT(!victim.void_skin_color && !HAS_TRAIT(victim, TRAIT_PACIFISM), "Curing the curse left its effects")
	victim.gain_trauma(/datum/brain_trauma/voided/stable, TRAUMA_RESILIENCE_LOBOTOMY)
	TEST_ASSERT(HAS_TRAIT(victim, TRAIT_RESISTLOWPRESSURE) && !HAS_TRAIT(victim, TRAIT_PACIFISM), "Stable curse has wrong traits")
	victim.cure_trauma_type(/datum/brain_trauma/voided, TRAUMA_RESILIENCE_LOBOTOMY)
	// Z wymiocin dałoby się wynurzyć, więc sprzątamy je przed nurkowaniem
	for(var/obj/effect/decal/cleanable/vomit/nebula/vomit in right)
		qdel(vomit)

	// Nurkowanie: wchodzi pod pokład i porusza się przez wszystko
	walker.dive(left)
	var/obj/effect/dummy/phased_mob/voidwalker/holder = walker.loc
	TEST_ASSERT(istype(holder), "Voidwalker did not dive")
	holder.next_move = 0
	holder.relaymove(walker, EAST)
	TEST_ASSERT_EQUAL(get_turf(walker), right, "Space dive did not move")
	walker.surface(left)
	TEST_ASSERT(isturf(walker.loc) && QDELETED(holder), "Voidwalker did not surface")

	// Okno pustki i tymczasowe rozbijanie szkła
	var/obj/structure/window/fulltile/voidwalker/window = allocate(/obj/structure/window/fulltile/voidwalker, right)
	TEST_ASSERT(window.spooky_particles?.particles, "Void window has no particles")
	// Okno za wędrowcem przepuszcza ludzi, ale nie powietrze
	walker.deform_glass(right)
	TEST_ASSERT(!window.density && window.void_deformed, "Window was not deformed")
	TEST_ASSERT(!window.CanAtmosPass(left), "Deformed window lets air through")
	voidwalker_undeform_glass(window)
	TEST_ASSERT(window.density && !window.void_deformed, "Window did not harden back")
	voidwalker_temporary_shatter(right, 1)
	TEST_ASSERT(!window.density, "Window was not shattered")
	voidwalker_unshatter(window)
	TEST_ASSERT(window.density, "Window did not grow back")
	qdel(window)

	// Śmierć zostawia kosmiczną czaszkę
	walker.death()
	TEST_ASSERT(QDELETED(walker), "Voidwalker was not deleted on death")
	var/obj/item/clothing/head/helmet/skull/cosmic/skull = locate() in left
	TEST_ASSERT(skull, "No cosmic skull after death")
	qdel(skull)
	for(var/obj/item/shard/shard in left)
		qdel(shard)

	TEST_ASSERT_EQUAL(GLOB.total_runtimes, runtimes_before, "Voidwalker test caused runtimes")

#undef TEST_ASSERT
#undef TEST_ASSERT_EQUAL
