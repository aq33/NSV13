// The upstream assert macros are #undef'd at the end of code/modules/unit_tests/_unit_tests.dm, so this modular test carries its own copies
#define TEST_ASSERT(assertion, reason) if (!(assertion)) { return Fail("Assertion failed: [reason || "No reason"]") }

#define TEST_ASSERT_EQUAL(a, b, message) do { \
	var/lhs = ##a; \
	var/rhs = ##b; \
	if (lhs != rhs) { \
		return Fail("Expected [isnull(lhs) ? "null" : lhs] to be equal to [isnull(rhs) ? "null" : rhs].[message ? " [message]" : ""]"); \
	} \
} while (FALSE)

// Port of BeeStation code/modules/unit_tests/combat.dm (#11899). The shove test is left out, our disarm works differently.

/// AQUILA - port Bee #11899: a punch in combat mode hurts, one out of it does not
/datum/unit_test/combat_mode_punch

/datum/unit_test/combat_mode_punch/Run()
	var/mob/living/carbon/human/puncher = allocate(/mob/living/carbon/human)
	var/mob/living/carbon/human/victim = allocate(/mob/living/carbon/human)

	victim.attack_hand(puncher, list(LEFT_CLICK = "1"))
	TEST_ASSERT_EQUAL(victim.getBruteLoss(), 0, "Victim took brute damage from a touch out of combat mode")

	puncher.set_combat_mode(TRUE)
	victim.attack_hand(puncher, list(LEFT_CLICK = "1"))
	TEST_ASSERT(victim.getBruteLoss() > 0, "Victim took no brute damage after being punched")

/// AQUILA - port Bee #11899: hitting someone with an item in combat mode
/datum/unit_test/combat_mode_melee

/datum/unit_test/combat_mode_melee/Run()
	var/mob/living/carbon/human/tider = allocate(/mob/living/carbon/human)
	var/mob/living/carbon/human/victim = allocate(/mob/living/carbon/human)
	var/obj/item/storage/toolbox/toolbox = allocate(/obj/item/storage/toolbox)

	tider.put_in_active_hand(toolbox, forced = TRUE)
	tider.set_combat_mode(TRUE)
	victim.attackby(toolbox, tider)
	TEST_ASSERT(victim.getBruteLoss() > 0, "Victim took no brute damage after being hit by a toolbox")

/// AQUILA - port Bee #11899: a lit welder burns
/datum/unit_test/combat_mode_damage_type

/datum/unit_test/combat_mode_damage_type/Run()
	var/mob/living/carbon/human/attacker = allocate(/mob/living/carbon/human)
	var/mob/living/carbon/human/victim = allocate(/mob/living/carbon/human)
	var/obj/item/weldingtool/welding_tool = allocate(/obj/item/weldingtool)

	attacker.put_in_active_hand(welding_tool, forced = TRUE)
	attacker.set_combat_mode(TRUE)
	welding_tool.attack_self(attacker) // Turn it on
	victim.attackby(welding_tool, attacker)

	TEST_ASSERT_EQUAL(victim.getBruteLoss(), 0, "Victim took brute damage from a lit welding tool")
	TEST_ASSERT(victim.getFireLoss() > 0, "Victim took no burn damage after being hit by a lit welding tool")

/// AQUILA - port Bee #11899: the melee attack chain sends all three signals
/datum/unit_test/combat_mode_attack_chain
	var/attack_hit
	var/post_attack_hit
	var/pre_attack_hit

/datum/unit_test/combat_mode_attack_chain/proc/attack_hit()
	SIGNAL_HANDLER
	attack_hit = TRUE

/datum/unit_test/combat_mode_attack_chain/proc/post_attack_hit()
	SIGNAL_HANDLER
	post_attack_hit = TRUE

/datum/unit_test/combat_mode_attack_chain/proc/pre_attack_hit()
	SIGNAL_HANDLER
	pre_attack_hit = TRUE

/datum/unit_test/combat_mode_attack_chain/Run()
	var/mob/living/carbon/human/attacker = allocate(/mob/living/carbon/human)
	var/mob/living/carbon/human/victim = allocate(/mob/living/carbon/human)
	var/obj/item/storage/toolbox/toolbox = allocate(/obj/item/storage/toolbox)

	RegisterSignal(toolbox, COMSIG_ITEM_PRE_ATTACK, PROC_REF(pre_attack_hit))
	RegisterSignal(toolbox, COMSIG_ITEM_ATTACK, PROC_REF(attack_hit))
	RegisterSignal(toolbox, COMSIG_ITEM_AFTERATTACK, PROC_REF(post_attack_hit))

	attacker.put_in_active_hand(toolbox, forced = TRUE)
	attacker.set_combat_mode(TRUE)
	toolbox.melee_attack_chain(attacker, victim)

	TEST_ASSERT(pre_attack_hit, "Pre-attack signal was not fired")
	TEST_ASSERT(attack_hit, "Attack signal was not fired")
	TEST_ASSERT(post_attack_hit, "Post-attack signal was not fired")

#undef TEST_ASSERT
#undef TEST_ASSERT_EQUAL
