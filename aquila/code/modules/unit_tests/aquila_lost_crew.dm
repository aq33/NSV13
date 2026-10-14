// The upstream assert macros are #undef'd at the end of code/modules/unit_tests/_unit_tests.dm, so this modular test carries its own copies
#define TEST_ASSERT(assertion, reason) if (!(assertion)) { return Fail("Assertion failed: [reason || "No reason"]") }

/// AQUILA - Recovered Crew and Thanatorenasia (tgstation#87072, #95469)
/datum/unit_test/aquila_lost_crew

/datum/unit_test/aquila_lost_crew/Run()
	// The body bag comes with a dead, revivable crewmember a ghost can take over
	var/obj/structure/closet/body_bag/lost_crew/with_body/bag = allocate(/obj/structure/closet/body_bag/lost_crew/with_body)
	var/mob/living/carbon/human/body = locate() in bag
	TEST_ASSERT(body, "The lost crew body bag is empty")
	TEST_ASSERT(body.stat == DEAD, "The lost crewmember is alive")
	var/datum/component/ghostrole_on_revive/ghostrole = body.GetComponent(/datum/component/ghostrole_on_revive)
	TEST_ASSERT(ghostrole, "The lost crewmember cannot be taken over by a ghost")
	TEST_ASSERT(!body.has_dnr(), "The lost crewmember counts as DNR for the defibrillator")

	// Revived with nobody willing to play: the soul fails to return
	body.revive(full_heal = TRUE, admin_revive = TRUE)
	ghostrole.poll_ghosts(body)
	TEST_ASSERT(body.stat == DEAD, "A lost crewmember stayed alive without a player")

	// Thanatorenasia: choosing DNR lets a ghost take the body
	var/mob/living/carbon/human/quirky = allocate(/mob/living/carbon/human)
	var/datum/quirk/death_dnr_poll/quirk = new(quirky)
	quirky.on_dnr()
	TEST_ASSERT(quirky.GetComponent(/datum/component/ghostrole_on_revive), "DNR with Thanatorenasia did not offer the body to ghosts")
	qdel(quirk)

	// Cargo can order it
	var/datum/supply_pack/medical/lost_crew/pack = /datum/supply_pack/medical/lost_crew
	TEST_ASSERT(initial(pack.cost) > 0, "The lost crew crate has no price")

	for(var/atom/movable/thing in bag)
		qdel(thing)

#undef TEST_ASSERT
