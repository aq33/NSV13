// The upstream assert macros are #undef'd at the end of code/modules/unit_tests/_unit_tests.dm, so this modular test carries its own copies
#define TEST_ASSERT(assertion, reason) if (!(assertion)) { return Fail("Assertion failed: [reason || "No reason"]") }

#define TEST_ASSERT_EQUAL(a, b, message) do { \
	var/lhs = ##a; \
	var/rhs = ##b; \
	if (lhs != rhs) { \
		return Fail("Expected [isnull(lhs) ? "null" : lhs] to be equal to [isnull(rhs) ? "null" : rhs].[message ? " [message]" : ""]"); \
	} \
} while (FALSE)

/// AQUILA - hitscan laser balance values (moved from core laser.dm / beams.dm / automatic.dm into aquila/code/modules/projectiles)
/datum/unit_test/aquila_laser_balance

/datum/unit_test/aquila_laser_balance/Run()
	var/obj/item/gun/energy/laser/laser = /obj/item/gun/energy/laser
	TEST_ASSERT_EQUAL(initial(laser.fire_rate), 1, "Laser gun fire rate")
	var/obj/item/gun/energy/laser/captain/captain = /obj/item/gun/energy/laser/captain
	TEST_ASSERT_EQUAL(initial(captain.fire_rate), 0.7, "Captain's laser fire rate")
	TEST_ASSERT_EQUAL(initial(captain.charge_delay), 12, "Captain's laser charge delay")
	var/obj/item/gun/energy/lasercannon/cannon = /obj/item/gun/energy/lasercannon
	TEST_ASSERT_EQUAL(initial(cannon.fire_rate), 1, "Laser cannon fire rate")
	var/obj/item/gun/energy/xray/xray = /obj/item/gun/energy/xray
	TEST_ASSERT_EQUAL(initial(xray.fire_rate), 0.8, "X-ray laser fire rate")

	var/obj/item/gun/ballistic/automatic/laser/rifle = /obj/item/gun/ballistic/automatic/laser
	TEST_ASSERT(initial(rifle.empty_alarm), "Laser rifle has no empty alarm")
	TEST_ASSERT_EQUAL(initial(rifle.empty_alarm_sound), 'sound/weapons/smg_empty_alarm.ogg', "Laser rifle empty alarm sound")

	for(var/beam_type in list(/obj/item/projectile/beam/laser, /obj/item/projectile/beam/weak, /obj/item/projectile/beam/practice, /obj/item/projectile/beam/xray, /obj/item/projectile/beam/emitter))
		var/obj/item/projectile/beam/beam = beam_type
		TEST_ASSERT(initial(beam.hitscan), "[beam_type] is not hitscan")
	var/obj/item/projectile/beam/emitter/emitter = /obj/item/projectile/beam/emitter
	TEST_ASSERT_EQUAL(initial(emitter.impact_effect_type), /obj/effect/temp_visual/impact_effect/red_laser, "Emitter beam impact effect")
	TEST_ASSERT_EQUAL(initial(emitter.tracer_type), /obj/effect/projectile/tracer/emitter, "Emitter beam tracer")
	TEST_ASSERT_EQUAL(initial(emitter.muzzle_type), /obj/effect/projectile/muzzle/emitter, "Emitter beam muzzle")
	TEST_ASSERT_EQUAL(initial(emitter.impact_type), /obj/effect/projectile/impact/emitter, "Emitter beam impact")

#undef TEST_ASSERT
#undef TEST_ASSERT_EQUAL
