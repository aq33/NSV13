// The upstream assert macros are #undef'd at the end of code/modules/unit_tests/_unit_tests.dm, so this modular test carries its own copies
#define TEST_ASSERT(assertion, reason) if (!(assertion)) { return Fail("Assertion failed: [reason || "No reason"]") }

#define TEST_ASSERT_EQUAL(a, b, message) do { \
	var/lhs = ##a; \
	var/rhs = ##b; \
	if (lhs != rhs) { \
		return Fail("Expected [isnull(lhs) ? "null" : lhs] to be equal to [isnull(rhs) ? "null" : rhs].[message ? " [message]" : ""]"); \
	} \
} while (FALSE)

/// AQUILA - demon cieni (port z Paradise): moce, światło, kokon, śmierć w cieniu i zastąpienie koszmara
/datum/unit_test/shadow_demon

/datum/unit_test/shadow_demon/Run()
	var/runtimes_before = GLOB.total_runtimes
	var/turf/left = run_loc_floor_bottom_left
	var/turf/right = get_step(left, EAST)

	// Koszmar nie spawnuje się już sam, jego miejsce zajął demon
	TEST_ASSERT(!text2path("/datum/round_event_control/nightmare"), "Nightmare event still exists")
	TEST_ASSERT(!text2path("/datum/dynamic_ruleset/midround/from_ghosts/nightmare"), "Nightmare ruleset still exists")
	TEST_ASSERT(!text2path("/datum/role_preference/midround_ghost/nightmare"), "Nightmare preference still exists")
	TEST_ASSERT(ispath(/datum/round_event_control/shadow_demon), "No shadow demon event")
	shadow_demon_spawn_locations()

	// Demon stworzony w cieniu wie, że jest w cieniu, i ma swoje trzy moce z własnym tłem
	var/obj/effect/dummy/phased_mob/shadow_crawl/holder = allocate(/obj/effect/dummy/phased_mob/shadow_crawl, left)
	var/mob/living/simple_animal/shadow_demon/demon = new(holder)
	TEST_ASSERT(demon.crawl_spell?.phased, "Demon spawned in shadow does not know it is phased")
	TEST_ASSERT(locate(/obj/effect/proc_holder/spell/aimed/shadow_grapple) in demon.mob_spell_list, "No shadow grapple")
	TEST_ASSERT(locate(/obj/effect/proc_holder/spell/targeted/telepathy/shadow_demon) in demon.mob_spell_list, "No demonic whisper")
	var/datum/action/spell_action/grapple_action = demon.crawl_spell.action
	TEST_ASSERT_EQUAL(grapple_action.button_icon, 'aquila/icons/mob/actions/actions_shadow_demon.dmi', "Wrong action background file")
	TEST_ASSERT_EQUAL(grapple_action.background_icon_state, "shadow_demon_bg", "Wrong action background")

	// Pełz porusza się przez wszystko, a śmierć w cieniu zostawia serce na podłodze
	holder.relaymove(demon, EAST)
	TEST_ASSERT_EQUAL(get_turf(demon), right, "Shadow crawl did not move")
	demon.death()
	TEST_ASSERT(QDELETED(demon), "Demon was not deleted on death")
	TEST_ASSERT(QDELETED(holder), "Shadow holder survived the demon's death")
	var/obj/item/organ/heart/shadow_demon/heart = locate() in right
	TEST_ASSERT(heart, "Heart of darkness did not drop on the floor")

	// Jasność decyduje o przezroczystości i prędkości
	demon = allocate(/mob/living/simple_animal/shadow_demon, left)
	var/lum = demon.check_darkness()
	if(lum > SHADOW_DEMON_LIGHT_THRESHOLD)
		TEST_ASSERT(demon.alpha == 255 && demon.speed == 1 && demon.alerts["light"], "Demon in light is not exposed")
	else
		TEST_ASSERT(demon.alpha < 255 && demon.speed == 0.5 && !demon.alerts["light"], "Demon in darkness is not hidden")

	// Wyjście w cień: znika z pola, wejście z pola blokuje tylko w cieniu
	demon.crawl_spell.phase_out(left, demon)
	TEST_ASSERT(istype(demon.loc, /obj/effect/dummy/phased_mob/shadow_crawl), "Phase out did not hide the demon")
	TEST_ASSERT(demon.crawl_spell.phased, "Phase out did not mark the spell")
	qdel(demon.loc)
	TEST_ASSERT_EQUAL(demon.loc, left, "Deleting the shadow did not release the demon")

	// Cień-hak: obrażenia, unieruchomienie, przyciągnięcie i zgaszona latarka
	var/mob/living/carbon/human/victim = allocate(/mob/living/carbon/human, get_step(right, EAST))
	var/obj/item/flashlight/flashlight = allocate(/obj/item/flashlight)
	victim.put_in_hands(flashlight)
	flashlight.on = TRUE
	flashlight.update_brightness()
	demon.set_block_shadow_crawl()
	var/obj/item/projectile/magic/shadow_hand/hand = new(get_turf(victim))
	hand.firer = demon
	hand.on_hit(victim)
	TEST_ASSERT(victim.getBruteLoss() >= 40, "Shadow grapple did not hurt")
	TEST_ASSERT(victim.IsImmobilized(), "Shadow grapple did not immobilize")
	TEST_ASSERT(!flashlight.on, "Shadow grapple did not put out the flashlight")
	TEST_ASSERT(!demon.block_shadow_crawl, "Hitting someone did not unblock shadow crawl")
	qdel(hand)

	// Flara gaśnie tylko od haka, ciosy ją ledwo przyciemniają
	var/obj/item/flashlight/flare/flare = allocate(/obj/item/flashlight/flare, left)
	flare.on = TRUE
	flare.update_brightness()
	flare.extinguish_light()
	TEST_ASSERT(flare.on, "A soft extinguish put out a flare")
	flare.extinguish_light(TRUE)
	TEST_ASSERT(!flare.on && !flare.fuel, "A forced extinguish did not burn out the flare")

	// Lampa ścienna gaśnie i wraca dopiero po czasie, bez zasilania awaryjnego
	var/obj/machinery/light/lamp = allocate(/obj/machinery/light, left)
	lamp.extinguish_light()
	TEST_ASSERT(lamp.shadow_extinguished, "Wall light was not marked as extinguished")
	TEST_ASSERT(!lamp.on, "Wall light is still on")
	TEST_ASSERT(!lamp.has_power() && !lamp.has_emergency_power(), "Extinguished light still has power")
	lamp.power_change()
	TEST_ASSERT(!lamp.on, "Power update turned the extinguished light back on")
	lamp.restore_extinguished_light()
	TEST_ASSERT(!lamp.shadow_extinguished, "Wall light did not come back")

	// Kokon: ciało w środku, cel liczy ofiarę, zniszczenie uwalnia ciało
	var/mob/living/carbon/human/corpse = allocate(/mob/living/carbon/human, right)
	corpse.death()
	var/obj/structure/shadowcocoon/cocoon = allocate(/obj/structure/shadowcocoon, right)
	TEST_ASSERT(cocoon.light_power < 0, "Cocoon does not darken")
	corpse.forceMove(cocoon)
	cocoon.process()
	qdel(cocoon)
	TEST_ASSERT_EQUAL(corpse.loc, right, "Destroyed cocoon did not release the body")

	demon.mind_initialize()
	var/datum/mind/demon_mind = demon.mind
	var/datum/antagonist/shadow_demon/antag = demon_mind.add_antag_datum(/datum/antagonist/shadow_demon)
	TEST_ASSERT(locate(/datum/objective/shadow_demon_cocoon) in antag.objectives, "Demon got no cocoon objective")
	var/datum/objective/shadow_demon_cocoon/objective = new
	objective.owner = demon_mind
	TEST_ASSERT(!objective.check_completion(), "Cocoon objective completed with no victims")
	for(var/i in 1 to objective.target_amount)
		antag.cocooned_victims |= "victim[i]"
	TEST_ASSERT(objective.check_completion(), "Cocoon objective not completed after enough victims")
	demon_mind.remove_antag_datum(/datum/antagonist/shadow_demon)
	qdel(objective)

	// Serce ciemności daje hak, a wycięte go zabiera
	var/mob/living/carbon/human/eater = allocate(/mob/living/carbon/human, left)
	eater.mind_initialize()
	heart = allocate(/obj/item/organ/heart/shadow_demon)
	heart.Insert(eater)
	TEST_ASSERT(locate(/obj/effect/proc_holder/spell/aimed/shadow_grapple) in eater.mind.spell_list, "Eating the heart did not give the grapple")
	heart.Remove(eater)
	TEST_ASSERT(!(locate(/obj/effect/proc_holder/spell/aimed/shadow_grapple) in eater.mind.spell_list), "Removing the heart did not take the grapple")

	TEST_ASSERT_EQUAL(GLOB.total_runtimes, runtimes_before, "Runtimes during the shadow demon test")

#undef TEST_ASSERT
#undef TEST_ASSERT_EQUAL
