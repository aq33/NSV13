// The upstream assert macros are #undef'd at the end of code/modules/unit_tests/_unit_tests.dm, so this modular test carries its own copies
#define TEST_ASSERT(assertion, reason) if (!(assertion)) { return Fail("Assertion failed: [reason || "No reason"]") }

#define TEST_ASSERT_EQUAL(a, b, message) do { \
	var/lhs = ##a; \
	var/rhs = ##b; \
	if (lhs != rhs) { \
		return Fail("Expected [isnull(lhs) ? "null" : lhs] to be equal to [isnull(rhs) ? "null" : rhs].[message ? " [message]" : ""]"); \
	} \
} while (FALSE)

/// AQUILA - BeeStation#11521: the stamina indicator follows stamina damage
/datum/unit_test/aquila_stamina_hud

/datum/unit_test/aquila_stamina_hud/Run()
	var/mob/living/carbon/human/dummy = allocate(/mob/living/carbon/human)
	dummy.hud_used = new dummy.hud_type(dummy)
	var/datum/hud/hud = dummy.hud_used
	dummy.update_stamina_hud()
	TEST_ASSERT_EQUAL(hud.stamina.icon_state, "stamina_full", "Wrong stamina state at full stamina")

	// Thresholds, checked through the shown value
	var/list/expected = list("10" = "stamina_1", "30" = "stamina_2", "50" = "stamina_3", "70" = "stamina_4", "85" = "stamina_5")
	for(var/loss in expected)
		dummy.update_stamina_hud(text2num(loss))
		TEST_ASSERT_EQUAL(hud.stamina.icon_state, expected[loss], "Wrong stamina state at [loss] stamina damage")

	// Real stamina damage updates the indicator, healing it resets it
	dummy.adjustStaminaLoss(50)
	TEST_ASSERT(hud.stamina.icon_state != "stamina_full", "Taking stamina damage did not update the stamina indicator")
	// setStaminaLoss() heals the scaled difference raw and can leave a remainder on limbs with stam_damage_coeff, so heal with a margin
	dummy.adjustStaminaLoss(-1000)
	TEST_ASSERT_EQUAL(hud.stamina.icon_state, "stamina_full", "The stamina state did not go back after healing")

#undef TEST_ASSERT
#undef TEST_ASSERT_EQUAL
