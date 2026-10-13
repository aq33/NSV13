// The upstream assert macros are #undef'd at the end of code/modules/unit_tests/_unit_tests.dm, so this modular test carries its own copies
#define TEST_ASSERT(assertion, reason) if (!(assertion)) { return Fail("Assertion failed: [reason || "No reason"]") }

#define TEST_ASSERT_EQUAL(a, b, message) do { \
	var/lhs = ##a; \
	var/rhs = ##b; \
	if (lhs != rhs) { \
		return Fail("Expected [isnull(lhs) ? "null" : lhs] to be equal to [isnull(rhs) ? "null" : rhs].[message ? " [message]" : ""]"); \
	} \
} while (FALSE)

/// AQUILA - demon impulsu (port z Paradise): ruch po kablach, zdolności, ulepszenia, cele i serce
/datum/unit_test/pulse_demon

/datum/unit_test/pulse_demon/Run()
	var/runtimes_before = GLOB.total_runtimes
	var/turf/left = run_loc_floor_bottom_left
	var/turf/right = get_step(left, EAST)
	var/turf/far_right = get_step(right, EAST)

	TEST_ASSERT(ispath(/datum/round_event_control/pulse_demon), "No pulse demon event")
	TEST_ASSERT(ispath(/datum/dynamic_ruleset/midround/from_ghosts/pulse_demon), "No pulse demon ruleset")
	pulse_demon_spawn_locations()

	// Demon na kablu siedzi w kablu i ma wszystkie zdolności z własnym tłem
	var/obj/structure/cable/left_cable = allocate(/obj/structure/cable, left)
	var/mob/living/simple_animal/pulse_demon/demon = allocate(/mob/living/simple_animal/pulse_demon, left)
	demon.can_exit_cable = FALSE
	TEST_ASSERT_EQUAL(demon.current_cable, left_cable, "Demon does not know it is in a cable")
	TEST_ASSERT_EQUAL(length(demon.pulse_actions), 12, "Wrong number of pulse demon abilities")
	var/datum/action/cooldown/pulse_demon/emp/emp_action = locate() in demon.pulse_actions
	TEST_ASSERT(emp_action, "No EMP ability")
	TEST_ASSERT_EQUAL(emp_action.button_icon, 'aquila/icons/mob/actions/actions_pulse_demon.dmi', "Wrong action background file")
	TEST_ASSERT(emp_action.locked, "EMP should start locked")
	TEST_ASSERT(!emp_action.IsAvailable(), "Locked ability is available")
	var/datum/action/cooldown/pulse_demon/toggle/do_drain/drain_action = locate() in demon.pulse_actions
	TEST_ASSERT_EQUAL(drain_action.background_icon_state, "bg_pulsedemon", "Drain toggle does not show it is on")
	if(left.intact)
		TEST_ASSERT(demon.invisibility > SEE_INVISIBLE_LIVING && demon.invisibility <= demon.see_invisible, "Demon under tiles is visible to the crew or hidden from itself")

	// Na kablu z prądem się leczy, bez prądu traci zdrowie
	if(!left_cable.powernet)
		var/datum/powernet/test_net = new
		test_net.add_cable(left_cable)
	TEST_ASSERT(left_cable.powernet, "Test cable has no powernet")
	var/old_avail = left_cable.powernet.avail
	left_cable.powernet.avail = 1000
	demon.health = 10
	demon.Life(2, 1)
	TEST_ASSERT(demon.health > 10, "Demon on a powered cable did not heal")
	left_cable.powernet.avail = 0
	var/health_before = demon.health
	demon.Life(2, 1)
	TEST_ASSERT(demon.health < health_before, "Demon on a dead cable did not lose health")
	left_cable.powernet.avail = old_avail
	demon.revive(full_heal = TRUE, admin_revive = TRUE)

	// Bez kabla nie ma dokąd iść, po kablu idzie dalej
	demon.Move(right, EAST)
	TEST_ASSERT_EQUAL(demon.loc, left, "Demon left the cable without self-sustaining")
	var/obj/structure/cable/right_cable = allocate(/obj/structure/cable, right)
	demon.Move(right, EAST)
	TEST_ASSERT_EQUAL(demon.loc, right, "Demon could not move along the cable")
	TEST_ASSERT_EQUAL(demon.current_cable, right_cable, "Demon did not switch cables")
	demon.can_exit_cable = TRUE
	demon.Move(far_right, EAST)
	TEST_ASSERT_EQUAL(demon.loc, far_right, "Self-sustaining demon could not leave the cable")
	TEST_ASSERT(!demon.current_cable, "Demon still thinks it is in a cable")
	demon.can_exit_cable = FALSE

	// Energia nie przekracza zapasu, a wyssana liczy się do celu
	demon.charge = 0
	demon.charge_drained = 0
	demon.adjust_charge(demon.maxcharge * 2)
	TEST_ASSERT_EQUAL(demon.charge, demon.maxcharge, "Charge went over the maximum")
	TEST_ASSERT_EQUAL(demon.charge_drained, demon.maxcharge, "Drained energy not counted")

	// Kupowanie zdolności w menu: przycisk pojawia się dopiero po zakupie
	TEST_ASSERT(!(emp_action in demon.actions), "Locked ability already has a button")
	var/datum/pulse_demon_menu/menu = new(demon)
	var/list/menu_data = menu.ui_data(demon)
	TEST_ASSERT_EQUAL(length(menu_data["abilities"]), 11, "Menu does not list every ability")
	demon.apcs_remaining = emp_action.unlock_cost
	TEST_ASSERT(emp_action.buy(demon), "Buying did not work")
	TEST_ASSERT(!emp_action.locked, "Buying did not unlock the ability")
	TEST_ASSERT(emp_action in demon.actions, "Bought ability has no button")
	TEST_ASSERT_EQUAL(demon.apcs_remaining, 0, "Unlocking did not cost APCs")
	TEST_ASSERT(!emp_action.buy(demon), "Ability bought twice")
	demon.apcs_remaining = emp_action.upgrade_cost
	TEST_ASSERT(emp_action.upgrade(demon), "Upgrading did not work")
	TEST_ASSERT_EQUAL(emp_action.level, 1, "Upgrading did not raise the level")
	TEST_ASSERT(emp_action.cooldown_time < emp_action.base_cooldown, "Upgrade did not shorten the cooldown")
	TEST_ASSERT_EQUAL(menu.calc_body_cost("Pojemność"), 1, "Capacity upgrade should cost one APC")
	demon.apcs_remaining = 1
	var/old_maxcharge = demon.maxcharge
	TEST_ASSERT(menu.buy_body_upgrade("Pojemność"), "Body upgrade failed")
	TEST_ASSERT(demon.maxcharge > old_maxcharge, "Capacity upgrade did nothing")
	qdel(menu)

	// Zdolności z obszarem działają tylko po przejęciu APC
	demon.adjust_charge(emp_action.cast_cost, TRUE)
	TEST_ASSERT(!emp_action.IsAvailable(), "Area ability available without a hijacked APC")
	demon.controlling_area = get_area(left)
	TEST_ASSERT(emp_action.IsAvailable(), "Area ability unavailable in a controlled area")
	var/obj/machinery/recharger/machine = allocate(/obj/machinery/recharger, left)
	TEST_ASSERT(demon.has_remote_machine_access(machine), "Demon cannot reach machines in its area")
	demon.controlling_area = null
	TEST_ASSERT(!demon.has_remote_machine_access(machine), "Demon reaches machines without an area")

	// Mówi tylko przez radio
	var/obj/item/radio/radio = allocate(/obj/item/radio, left)
	demon.forceMove(radio)
	TEST_ASSERT_EQUAL(demon.remote_control, demon, "Movement inside an item is not relayed to the demon")
	demon.send_speech("test", spans = list(), message_mods = list())
	demon.forceMove(far_right)
	TEST_ASSERT(!demon.remote_control, "Movement still relayed on a turf")

	// Cele
	demon.mind_initialize()
	var/datum/mind/demon_mind = demon.mind
	var/datum/antagonist/pulse_demon/antag = demon_mind.add_antag_datum(/datum/antagonist/pulse_demon)
	TEST_ASSERT_EQUAL(length(antag.objectives), 3, "Demon did not get three objectives")
	var/datum/objective/pulse_demon/drain/drain_objective = locate() in antag.objectives
	demon.charge_drained = 0
	TEST_ASSERT(!drain_objective.check_completion(), "Drain objective completed with nothing drained")
	demon.charge_drained = drain_objective.amount
	TEST_ASSERT(drain_objective.check_completion(), "Drain objective not completed")
	var/datum/objective/pulse_demon/tamper/tamper_objective = locate() in antag.objectives
	TEST_ASSERT(!tamper_objective.check_completion(), "Tamper objective completed without hijacked APCs")
	demon_mind.remove_antag_datum(/datum/antagonist/pulse_demon)

	// Śmierć zostawia rozrusznik na podłodze, także gdy demon siedział w przedmiocie
	demon.forceMove(radio)
	demon.charge = 0
	demon.death()
	TEST_ASSERT(QDELETED(demon), "Demon was not deleted on death")
	var/obj/item/organ/heart/pulse_demon/heart = locate() in left
	TEST_ASSERT(heart, "Perpetual pacemaker did not drop on the floor")

	// Rozrusznik daje odporność na prąd i ładuje ogniwa
	var/mob/living/carbon/human/eater = allocate(/mob/living/carbon/human, right)
	var/obj/item/stock_parts/cell/cell = allocate(/obj/item/stock_parts/cell)
	cell.charge = 0
	eater.put_in_hands(cell)
	heart.Insert(eater)
	TEST_ASSERT(HAS_TRAIT(eater, TRAIT_SHOCKIMMUNE), "Pacemaker did not give shock immunity")
	heart.on_life()
	TEST_ASSERT(cell.charge > 0, "Pacemaker did not charge the cell")
	heart.Remove(eater)
	TEST_ASSERT(!HAS_TRAIT(eater, TRAIT_SHOCKIMMUNE), "Removing the pacemaker did not take shock immunity")

	TEST_ASSERT_EQUAL(GLOB.total_runtimes, runtimes_before, "Runtimes during the pulse demon test")

#undef TEST_ASSERT
#undef TEST_ASSERT_EQUAL
