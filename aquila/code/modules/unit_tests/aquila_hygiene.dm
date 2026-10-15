// The upstream assert macros are #undef'd at the end of code/modules/unit_tests/_unit_tests.dm, so this modular test carries its own copies
#define TEST_ASSERT(assertion, reason) if (!(assertion)) { return Fail("Assertion failed: [reason || "No reason"]") }

/// AQUILA - Hygiene: stinking people release miasma, die with a corpse budget, and get chased by hygienebots
/datum/unit_test/aquila_hygiene

/datum/unit_test/aquila_hygiene/Run()
	var/mob/living/carbon/human/stinky = allocate(/mob/living/carbon/human)
	TEST_ASSERT(isnull(stinky.miasma_emission(10)), "A clean living human releases miasma")

	// Going dirty registers with SSmiasma
	stinky.set_hygiene(HYGIENE_LEVEL_DIRTY)
	TEST_ASSERT(SSmiasma.sources[stinky], "A dirty human did not register as a miasma source")
	TEST_ASSERT(stinky.miasma_emission(10) > 0, "A dirty human does not release miasma")

	// A hygienebot goes after them and washes them back to normal
	var/mob/living/simple_animal/bot/hygienebot/bot = allocate(/mob/living/simple_animal/bot/hygienebot)
	TEST_ASSERT(bot.needs_washing(stinky), "A hygienebot ignores a dirty human")
	bot.do_wash(stinky)
	bot.do_wash(stinky)
	bot.do_wash(stinky)
	TEST_ASSERT(bot.is_clean(stinky), "A hygienebot did not wash a dirty human clean")
	TEST_ASSERT(isnull(stinky.miasma_emission(10)), "A washed human still releases miasma")

	// Dying while dirty swaps the unlimited hygiene source for a corpse budget
	stinky.set_hygiene(HYGIENE_LEVEL_DISGUSTING)
	stinky.death()
	TEST_ASSERT(SSmiasma.sources[stinky] == MIASMA_CORPSE_BUDGET, "A corpse that died dirty did not get a corpse budget")

	// Soap on the mouth washes the target, not the user
	var/mob/living/carbon/human/washer = allocate(/mob/living/carbon/human)
	var/mob/living/carbon/human/washed = allocate(/mob/living/carbon/human)
	washer.set_hygiene(HYGIENE_LEVEL_DIRTY)
	washed.set_hygiene(HYGIENE_LEVEL_DIRTY)
	var/obj/item/soap/soap = allocate(/obj/item/soap)
	washer.zone_selected = BODY_ZONE_PRECISE_MOUTH
	soap.afterattack(washed, washer, TRUE)
	TEST_ASSERT(washed.hygiene > HYGIENE_LEVEL_DIRTY, "Soap did not wash the target's mouth")
	TEST_ASSERT(washer.hygiene == HYGIENE_LEVEL_DIRTY, "Soap washed the user instead of the target")

#undef TEST_ASSERT
