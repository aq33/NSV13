// The upstream assert macros are #undef'd at the end of code/modules/unit_tests/_unit_tests.dm, so this modular test carries its own copies
#define TEST_ASSERT(assertion, reason) if (!(assertion)) { return Fail("Assertion failed: [reason || "No reason"]") }

/// AQUILA - BeeStation#13707: slots the mob can't use right now are dimmed, and light up again once they become usable
/datum/unit_test/aquila_locked_slots

/datum/unit_test/aquila_locked_slots/Run()
	var/mob/living/carbon/human/dummy = allocate(/mob/living/carbon/human)
	dummy.hud_used = new dummy.hud_type(dummy)
	var/datum/hud/hud = dummy.hud_used
	var/atom/movable/screen/inventory/id_slot = hud.inv_slots[TOBITSHIFT(ITEM_SLOT_ID) + 1]
	var/atom/movable/screen/inventory/suit_storage = hud.inv_slots[TOBITSHIFT(ITEM_SLOT_SUITSTORE) + 1]
	TEST_ASSERT(id_slot && suit_storage, "The human HUD has no ID or suit storage slot")

	hud.update_locked_slots()
	TEST_ASSERT(id_slot.alpha == 128, "The ID slot is not dimmed without a jumpsuit")
	TEST_ASSERT(suit_storage.alpha == 128, "Suit storage is not dimmed without a suit")

	var/obj/item/clothing/under/jumpsuit = allocate(/obj/item/clothing/under/color/grey)
	TEST_ASSERT(dummy.equip_to_slot_if_possible(jumpsuit, ITEM_SLOT_ICLOTHING), "Could not equip a jumpsuit")
	TEST_ASSERT(id_slot.alpha == initial(id_slot.alpha), "The ID slot stayed dimmed after equipping a jumpsuit")

	dummy.dropItemToGround(jumpsuit)
	TEST_ASSERT(id_slot.alpha == 128, "The ID slot was not dimmed again after taking the jumpsuit off")

#undef TEST_ASSERT
