// The upstream assert macros are #undef'd at the end of code/modules/unit_tests/_unit_tests.dm, so this modular test carries its own copies
#define TEST_ASSERT(assertion, reason) if (!(assertion)) { return Fail("Assertion failed: [reason || "No reason"]") }

/// AQUILA - every product of a vendor that is not on the map (Donksoft) has a sprite in the vending spritesheet
/datum/unit_test/vending_spritesheet

/datum/unit_test/vending_spritesheet/Run()
	var/datum/asset/spritesheet/vending/sheet = get_asset_datum(/datum/asset/spritesheet/vending)
	var/obj/machinery/vending/donksofttoyvendor/vendor = allocate(/obj/machinery/vending/donksofttoyvendor)
	for(var/product in vendor.products + vendor.premium + vendor.contraband)
		var/imgid = replacetext(replacetext("[product]", "/obj/item/", ""), "/", "-")
		TEST_ASSERT(sheet.sprites[imgid], "No vending sprite for [product]")

#undef TEST_ASSERT
