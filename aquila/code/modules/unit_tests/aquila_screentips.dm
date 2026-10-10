// The upstream assert macros are #undef'd at the end of code/modules/unit_tests/_unit_tests.dm, so this modular test carries its own copies
#define TEST_ASSERT(assertion, reason) if (!(assertion)) { return Fail("Assertion failed: [reason || "No reason"]") }

/// AQUILA - BeeStation#11938: screentip contexts are built from our interactions, the auto-tip cache is filled,
/// and the screentip lands on the HUD
/datum/unit_test/aquila_screentips

/datum/unit_test/aquila_screentips/Run()
	var/mob/living/carbon/human/user = allocate(/mob/living/carbon/human)

	// Structure context: a closed, unlocked locker can be opened
	var/obj/structure/closet/closet = allocate(/obj/structure/closet)
	var/datum/screentip_context/context = new()
	context.user = user
	closet.add_context_self(context, user)
	TEST_ASSERT(findtext(context.left_mouse_context, "Otwórz"), "A closed locker does not offer to open it: [context.left_mouse_context]")

	// Element context: dough tells you what a rolling pin makes of it
	var/obj/item/food/dough/dough = allocate(/obj/item/food/dough)
	context = new()
	context.user = user
	SEND_SIGNAL(dough, COMSIG_ATOM_ADD_CONTEXT, context, user)
	TEST_ASSERT(findtext(context.rolling_pin, "Rozwałkuj"), "Dough has no rolling pin screentip: [context.rolling_pin]")

	// Auto-tips from SCREENTIP_ATTACK_HAND are cached for the type and its subtypes
	var/datum/screentip_cache/fire_alarm_cache = GLOB.screentips_cache["[/obj/machinery/firealarm]"]
	TEST_ASSERT(fire_alarm_cache, "The fire alarm has no auto-tip")
	TEST_ASSERT(findtext(fire_alarm_cache.attack_hand, "Naciśnij"), "Wrong fire alarm auto-tip: [fire_alarm_cache.attack_hand]")

	// Hand actions are shown (upstream stored them but never displayed them)
	var/obj/machinery/iv_drip/drip = allocate(/obj/machinery/iv_drip)
	context = new()
	context.user = user
	drip.add_context_self(context, user)
	TEST_ASSERT(findtext(context.left_attack_hand_context, "Zmień tryb"), "The IV drip has no empty hand action: [context.left_attack_hand_context]")

	// Every human HUD gets a screentip holder
	user.hud_used = new user.hud_type(user)
	TEST_ASSERT(user.hud_used.screentip, "The human HUD has no screentip")
	TEST_ASSERT(user.hud_used.screentip in user.hud_used.infodisplay, "The screentip is not shown with the HUD")

#undef TEST_ASSERT
