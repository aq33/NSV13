// The upstream assert macros are #undef'd at the end of code/modules/unit_tests/_unit_tests.dm, so this modular test carries its own copies
#define TEST_ASSERT(assertion, reason) if (!(assertion)) { return Fail("Assertion failed: [reason || "No reason"]") }

/// AQUILA - port aq33/tgstation#564: BB ammo boxes change sprite with their fill level and every stage has an icon state
/datum/unit_test/foambox_fill_sprites

/datum/unit_test/foambox_fill_sprites/Run()
	for(var/box_type in list(/obj/item/ammo_box/foambox, /obj/item/ammo_box/foambox/riot))
		var/obj/item/ammo_box/foambox/box = allocate(box_type)
		var/base = initial(box.icon_state)
		var/list/states = icon_states(box.icon)
		TEST_ASSERT(base in states, "No [base] icon state for vendor previews")
		for(var/stage in 0 to 4)
			TEST_ASSERT("[base]-[stage]" in states, "No [base]-[stage] icon state")
		TEST_ASSERT(box.icon_state == "[base]-4", "A full box shows [box.icon_state]")
		while(box.stored_ammo.len > box.max_ammo / 2)
			qdel(box.get_round())
		box.update_icon()
		TEST_ASSERT(box.icon_state == "[base]-2", "A half full box shows [box.icon_state]")
		while(box.stored_ammo.len)
			qdel(box.get_round())
		box.update_icon()
		TEST_ASSERT(box.icon_state == "[base]-0", "An empty box shows [box.icon_state]")

	var/obj/item/ammo_casing/caseless/foam_dart/dart = allocate(/obj/item/ammo_casing/caseless/foam_dart)
	TEST_ASSERT("foamdart" in icon_states(dart.icon), "No foamdart icon state")
	TEST_ASSERT("foamdart_empty" in icon_states(dart.icon), "No foamdart_empty icon state")
	TEST_ASSERT("foamdart_proj" in icon_states(dart.BB.icon), "No foamdart_proj icon state")

#undef TEST_ASSERT
