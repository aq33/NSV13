// The upstream assert macros are #undef'd at the end of code/modules/unit_tests/_unit_tests.dm, so this modular test carries its own copies
#define TEST_ASSERT(assertion, reason) if (!(assertion)) { return Fail("Assertion failed: [reason || "No reason"]") }

#define TEST_ASSERT_EQUAL(a, b, message) do { \
	var/lhs = ##a; \
	var/rhs = ##b; \
	if (lhs != rhs) { \
		return Fail("Expected [isnull(lhs) ? "null" : lhs] to be equal to [isnull(rhs) ? "null" : rhs].[message ? " [message]" : ""]"); \
	} \
} while (FALSE)

/// A human whose player picked the legacy intent controls (the real check reads the client's preferences)
/mob/living/carbon/human/legacy_intents_test

/mob/living/carbon/human/legacy_intents_test/uses_legacy_intents()
	return TRUE

/// AQUILA - port Bee #11899: intent hotkeys only toggle combat mode, unless the player picked the legacy controls
/datum/unit_test/combat_mode_intent_keys

/datum/unit_test/combat_mode_intent_keys/Run()
	var/mob/living/carbon/human/user = allocate(/mob/living/carbon/human)
	TEST_ASSERT(!user.uses_legacy_intents(), "A mob without a client uses the legacy controls")
	TEST_ASSERT(!user.combat_mode, "Combat mode is on by default")

	user.a_intent_change(INTENT_HARM)
	TEST_ASSERT(user.combat_mode, "The harm key did not turn combat mode on")
	TEST_ASSERT_EQUAL(user.a_intent, INTENT_HARM, "a_intent does not follow combat mode")
	user.a_intent_change(INTENT_DISARM)
	TEST_ASSERT(user.combat_mode, "The disarm key changed combat mode")
	user.a_intent_change(INTENT_HELP)
	TEST_ASSERT(!user.combat_mode, "The help key did not turn combat mode off")
	TEST_ASSERT_EQUAL(user.a_intent, INTENT_HELP, "a_intent does not follow combat mode")
	user.a_intent_change(INTENT_HOTKEY_RIGHT)
	TEST_ASSERT(user.combat_mode, "The cycle key did not toggle combat mode")
	user.a_intent_change(INTENT_HOTKEY_LEFT)
	TEST_ASSERT(!user.combat_mode, "The cycle key did not toggle combat mode back")

/// AQUILA - port Bee #11899: in the legacy controls the intent drives combat mode (harm = on)
/datum/unit_test/combat_mode_legacy_intents

/datum/unit_test/combat_mode_legacy_intents/Run()
	var/mob/living/carbon/human/legacy_intents_test/user = allocate(/mob/living/carbon/human/legacy_intents_test)

	user.a_intent_change(INTENT_DISARM)
	TEST_ASSERT_EQUAL(user.a_intent, INTENT_DISARM, "The disarm intent was not picked")
	TEST_ASSERT(!user.combat_mode, "Disarm turned combat mode on")
	user.a_intent_change(INTENT_HARM)
	TEST_ASSERT(user.combat_mode, "Harm did not turn combat mode on")
	user.a_intent_change(INTENT_GRAB)
	TEST_ASSERT_EQUAL(user.a_intent, INTENT_GRAB, "The grab intent was not picked")
	TEST_ASSERT(!user.combat_mode, "Leaving harm did not turn combat mode off")

	// Something else turning combat mode on and off moves the intent with it
	user.set_combat_mode(TRUE)
	TEST_ASSERT_EQUAL(user.a_intent, INTENT_HARM, "Combat mode on did not pick harm")
	user.set_combat_mode(FALSE)
	TEST_ASSERT_EQUAL(user.a_intent, INTENT_HELP, "Combat mode off did not leave harm")

/// AQUILA - port Bee #11899: disarm clicks become right clicks, grab clicks with an empty hand become ctrl clicks
/datum/unit_test/combat_mode_legacy_clicks

/datum/unit_test/combat_mode_legacy_clicks/Run()
	var/mob/living/carbon/human/legacy_intents_test/user = allocate(/mob/living/carbon/human/legacy_intents_test)
	var/mob/living/carbon/human/victim = allocate(/mob/living/carbon/human)
	var/obj/item/toy/crayon/held = allocate(/obj/item/toy/crayon)

	user.a_intent_change(INTENT_DISARM)
	var/list/modifiers = list(LEFT_CLICK = "1", "button" = LEFT_CLICK)
	TEST_ASSERT(user.translate_legacy_intent_click(victim, modifiers), "A disarm click was not translated")
	TEST_ASSERT(LAZYACCESS(modifiers, RIGHT_CLICK), "A disarm click did not become a right click")
	TEST_ASSERT(!LAZYACCESS(modifiers, LEFT_CLICK), "A disarm click kept the left click")
	TEST_ASSERT_EQUAL(modifiers["button"], RIGHT_CLICK, "The clicked button was not changed")

	modifiers = list(LEFT_CLICK = "1", SHIFT_CLICK = "1")
	TEST_ASSERT(!user.translate_legacy_intent_click(victim, modifiers), "A shift click (examine) was translated")

	user.a_intent_change(INTENT_GRAB)
	modifiers = list(LEFT_CLICK = "1")
	TEST_ASSERT(user.translate_legacy_intent_click(victim, modifiers), "A grab click on a mob was not translated")
	TEST_ASSERT(LAZYACCESS(modifiers, CTRL_CLICK), "A grab click did not become a ctrl click")

	modifiers = list(LEFT_CLICK = "1")
	TEST_ASSERT(!user.translate_legacy_intent_click(held, modifiers), "A grab click on an item was translated")
	TEST_ASSERT(!user.translate_legacy_intent_click(user, modifiers), "A grab click on yourself was translated")

	user.put_in_active_hand(held)
	TEST_ASSERT(!user.translate_legacy_intent_click(victim, modifiers), "A grab click with an item in hand was translated")

	user.a_intent_change(INTENT_HARM)
	TEST_ASSERT(!user.translate_legacy_intent_click(victim, modifiers), "A harm click was translated")

	// Players on the combat mode controls never get their clicks changed
	victim.a_intent = INTENT_DISARM
	modifiers = list(LEFT_CLICK = "1")
	TEST_ASSERT(!victim.translate_legacy_intent_click(user, modifiers), "A combat mode player's click was translated")

#undef TEST_ASSERT
#undef TEST_ASSERT_EQUAL
