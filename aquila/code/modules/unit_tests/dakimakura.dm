// The upstream assert macros are #undef'd at the end of code/modules/unit_tests/_unit_tests.dm, so this modular test carries its own copies
#define TEST_ASSERT(assertion, reason) if (!(assertion)) { return Fail("Assertion failed: [reason || "No reason"]") }

/// AQUILA - Dakimakuras (#269): every print has an icon state, naming, intents, the vendor sells them
/datum/unit_test/dakimakura

/datum/unit_test/dakimakura/Run()
	var/obj/item/dakimakura/daki = allocate(/obj/item/dakimakura)
	var/list/states = icon_states(daki.icon)
	TEST_ASSERT("daki_base" in states, "No daki_base icon state")
	TEST_ASSERT("daki" in icon_states(daki.lefthand_file), "No left hand sprite")
	TEST_ASSERT("daki" in icon_states(daki.righthand_file), "No right hand sprite")
	for(var/body in daki.body_choices())
		TEST_ASSERT("daki_[body]" in states, "No icon state for the [body] print")

	TEST_ASSERT(!daki.set_body("Not a real print"), "Accepted a print that does not exist")
	TEST_ASSERT(daki.icon_state == "daki_base", "A bad print changed the icon")
	TEST_ASSERT(daki.set_body("Ian"), "Could not pick a print")
	TEST_ASSERT(daki.icon_state == "daki_Ian", "Print did not change the icon")
	daki.set_custom_name("Ian")
	TEST_ASSERT(daki.name == "Ian dakimakura", "Name not set: [daki.name]")
	TEST_ASSERT(findtext(daki.desc, "Ian"), "Description does not use the name")

	// Every intent once it has a name, none of them may runtime
	var/mob/living/carbon/human/user = allocate(/mob/living/carbon/human)
	user.put_in_hands(daki)
	var/runtimes_before = GLOB.total_runtimes
	for(var/intent in list(INTENT_HELP, INTENT_DISARM, INTENT_GRAB, INTENT_HARM))
		user.a_intent = intent
		daki.attack_self(user)
	TEST_ASSERT(GLOB.total_runtimes == runtimes_before, "Runtimes while using the dakimakura")

	var/obj/machinery/vending/donksofttoyvendor/vendor = allocate(/obj/machinery/vending/donksofttoyvendor)
	TEST_ASSERT(vendor.contraband[/obj/item/dakimakura] == 5, "The Donksoft vendor does not sell dakimakuras")
	var/found = FALSE
	for(var/datum/data/vending_product/R in vendor.hidden_records)
		if(R.product_path == /obj/item/dakimakura)
			found = TRUE
	TEST_ASSERT(found, "Dakimakura missing from the vendor's contraband stock")

#undef TEST_ASSERT
