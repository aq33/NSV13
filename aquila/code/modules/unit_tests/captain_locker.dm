// The upstream assert macros are #undef'd at the end of code/modules/unit_tests/_unit_tests.dm, so this modular test carries its own copies
#define TEST_ASSERT(assertion, reason) if (!(assertion)) { return Fail("Assertion failed: [reason || "No reason"]") }

#define TEST_ASSERT_EQUAL(a, b, message) do { \
	var/lhs = ##a; \
	var/rhs = ##b; \
	if (lhs != rhs) { \
		return Fail("Expected [isnull(lhs) ? "null" : lhs] to be equal to [isnull(rhs) ? "null" : rhs].[message ? " [message]" : ""]"); \
	} \
} while (FALSE)

/// AQUILA - the captain's locker keeps its normal contents, gets the Kapitan Bomba clothing exactly once, and keeps all of it inside when opened and closed
/datum/unit_test/captain_locker_kapitan_bomba

/datum/unit_test/captain_locker_kapitan_bomba/Run()
	var/turf/spot = locate(run_loc_floor_bottom_left.x + 2, run_loc_floor_bottom_left.y + 2, run_loc_floor_bottom_left.z)
	var/obj/structure/closet/secure_closet/captains/locker = allocate(/obj/structure/closet/secure_closet/captains, spot)

	// Normal captain's locker contents (code/game/objects/structures/crates_lockers/closets/secure/security.dm)
	var/list/expected = list(
		/obj/item/storage/box/suitbox/cap = 1,
		/obj/item/storage/backpack/captain = 1,
		/obj/item/storage/backpack/satchel/cap = 1,
		/obj/item/storage/backpack/duffelbag/captain = 1,
		/obj/item/clothing/suit/armor/vest/capcarapace/jacket = 1,
		/obj/item/clothing/suit/armor/vest/capcarapace = 1,
		/obj/item/clothing/suit/armor/vest/capcarapace/alt = 1,
		/obj/item/clothing/suit/hooded/wintercoat/captain = 1,
		/obj/item/clothing/suit/captunic = 1,
		/obj/item/clothing/gloves/color/captain = 1,
		/obj/item/clothing/glasses/sunglasses/advanced/gar/supergar = 1,
		/obj/item/radio/headset/heads/captain/alt = 1,
		/obj/item/radio/headset/heads/captain = 1,
		/obj/item/clothing/neck/petcollar = 1,
		/obj/item/pet_carrier = 1,
		/obj/item/storage/photo_album/Captain = 1,
		/obj/item/storage/box/radiokey/com = 1,
		/obj/item/storage/box/command_keys = 1,
		/obj/item/megaphone/command = 1,
		/obj/item/computer_hardware/hard_drive/role/captain = 1,
		/obj/item/storage/box/silver_ids = 1,
		/obj/item/restraints/handcuffs/cable/zipties = 1,
		/obj/item/storage/box/engimp = 1,
		/obj/item/card/id/departmental_budget/civ = 1,
		/obj/item/clothing/neck/cloak/cap = 1,
		/obj/item/door_remote/captain = 1,
		/obj/item/storage/belt/sabre = 1,
		/obj/item/gun/ballistic/automatic/pistol/glock/command = 1,
		// Kapitan Bomba, exactly once each
		/obj/item/clothing/head/helmet/space/kapitanbomba = 1,
		/obj/item/clothing/suit/kapitanbomba = 1,
		/obj/item/clothing/shoes/aquila/kapitanbomba = 1,
	)
	var/expected_total = 0
	for(var/path in expected)
		expected_total += expected[path]

	var/fail = check_contents(locker.contents, expected, expected_total)
	if(fail)
		return Fail("Fresh locker: [fail]")
	TEST_ASSERT(!(locate(/obj/item/gun/ballistic/automatic/l6_saw/blaster) in locker), "The Kapitan Bomba blaster must stay admin-only")

	// Access and security are unchanged
	TEST_ASSERT(locker.locked, "Captain's locker does not start locked")
	TEST_ASSERT_EQUAL(length(locker.req_access), 1, "Captain's locker access list")
	TEST_ASSERT(ACCESS_CAPTAIN in locker.req_access, "Captain's locker no longer needs captain access")

	// Opening and closing keeps everything inside the locked locker
	locker.locked = FALSE
	locker.open()
	TEST_ASSERT(locker.opened, "Captain's locker did not open")
	TEST_ASSERT_EQUAL(length(locker.contents), 0, "Items stayed inside the open locker")
	locker.close()
	TEST_ASSERT(!locker.opened, "Captain's locker did not close")
	fail = check_contents(locker.contents, expected, expected_total)
	if(fail)
		return Fail("After open/close: [fail]")
	for(var/obj/item/left_behind in spot)
		return Fail("[left_behind] was left outside the closed captain's locker")

	for(var/obj/item/item as anything in locker.contents)
		qdel(item)

/// Returns a failure message if contents do not match the expected type counts exactly
/datum/unit_test/captain_locker_kapitan_bomba/proc/check_contents(list/contents, list/expected, expected_total)
	var/list/found = list()
	for(var/atom/movable/thing as anything in contents)
		found[thing.type] += 1
	for(var/path in expected)
		if(found[path] != expected[path])
			return "expected [expected[path]] of [path], found [found[path] || 0]"
	for(var/path in found)
		if(!(path in expected))
			return "unexpected [path] in the locker"
	if(length(contents) != expected_total)
		return "expected [expected_total] items, found [length(contents)]"

#undef TEST_ASSERT
#undef TEST_ASSERT_EQUAL
