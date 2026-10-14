// The upstream assert macros are #undef'd at the end of code/modules/unit_tests/_unit_tests.dm, so this modular test carries its own copies
#define TEST_ASSERT(assertion, reason) if (!(assertion)) { return Fail("Assertion failed: [reason || "No reason"]") }

#define TEST_ASSERT_EQUAL(a, b, message) do { \
	var/lhs = ##a; \
	var/rhs = ##b; \
	if (lhs != rhs) { \
		return Fail("Expected [isnull(lhs) ? "null" : lhs] to be equal to [isnull(rhs) ? "null" : rhs].[message ? " [message]" : ""]"); \
	} \
} while (FALSE)

/// Zaklęcie testowe: liczy rzucenia
/datum/action/cooldown/spell/pointed/unit_test_spell
	name = "Unit test spell"
	cooldown_time = 10 SECONDS
	cast_range = 3
	resource_costs = list(ANTAG_RESOURCE_DARKSPAWN = 10)
	var/casts = 0

/datum/action/cooldown/spell/pointed/unit_test_spell/cast(atom/cast_on)
	. = ..()
	casts++

/// AQUILA - system zaklęć /datum/action/cooldown/spell: celowanie, odnowienie, koszt w Psi
/datum/unit_test/cooldown_spells
	var/datum/team/darkspawn/old_team

/datum/unit_test/cooldown_spells/Destroy()
	if(GLOB.darkspawn_team != old_team)
		QDEL_NULL(GLOB.darkspawn_team)
		GLOB.darkspawn_team = old_team
	return ..()

/datum/unit_test/cooldown_spells/Run()
	var/runtimes_before = GLOB.total_runtimes
	old_team = GLOB.darkspawn_team
	GLOB.darkspawn_team = null
	var/turf/left = run_loc_floor_bottom_left
	var/mob/living/carbon/human/caster = allocate(/mob/living/carbon/human, left)
	caster.mind_initialize()
	var/datum/antagonist/darkspawn/antag = caster.mind.add_antag_datum(/datum/antagonist/darkspawn)
	var/mob/living/carbon/human/target = allocate(/mob/living/carbon/human, get_step(left, EAST))
	var/mob/living/carbon/human/far_target = allocate(/mob/living/carbon/human, locate(left.x + 5, left.y, left.z))

	var/datum/action/cooldown/spell/pointed/unit_test_spell/spell = new(caster.mind)
	spell.Grant(caster)
	TEST_ASSERT(spell.owner == caster && (spell in caster.actions), "Mind spell not granted to the current body")

	// Przycisk włącza celowanie, kliknięcie w cel rzuca
	spell.Trigger()
	TEST_ASSERT(caster.click_intercept == spell, "Trigger did not set the click intercept")
	TEST_ASSERT(spell.is_action_active(), "Spell not shown as active while aiming")
	TEST_ASSERT(!spell.InterceptClickOn(caster, null, far_target), "Cast out of range")
	TEST_ASSERT_EQUAL(spell.casts, 0, "Out of range cast happened")
	antag.psi = 100
	TEST_ASSERT(spell.InterceptClickOn(caster, null, target), "Could not cast on a target in range")
	TEST_ASSERT_EQUAL(spell.casts, 1, "Cast did not happen")
	TEST_ASSERT(caster.click_intercept != spell, "Click intercept kept after the cast")
	TEST_ASSERT_EQUAL(antag.psi, 90, "Psi cost not paid")
	TEST_ASSERT(spell.next_use_time > world.time, "No cooldown after the cast")
	TEST_ASSERT(!spell.IsAvailable(), "Spell available during cooldown")

	// Bez Psi nie da się rzucić
	spell.reset_spell_cooldown()
	antag.psi = 5
	TEST_ASSERT(!spell.can_cast_spell(FALSE), "Cast allowed without enough Psi")
	antag.psi = 100

	// Drugie wciśnięcie wyłącza celowanie bez odnowienia
	spell.Trigger()
	spell.Trigger()
	TEST_ASSERT(caster.click_intercept != spell, "Second press did not cancel aiming")

	qdel(spell)
	caster.mind.remove_antag_datum(/datum/antagonist/darkspawn)
	TEST_ASSERT_EQUAL(GLOB.total_runtimes, runtimes_before, "Runtimes during the spell test")

/// AQUILA - darkspawn (port z Yogstation, po przeróbce): klasy, Psi Web, Divulge, thralle, cienie
/datum/unit_test/darkspawn
	var/datum/team/darkspawn/old_team

/datum/unit_test/darkspawn/Destroy()
	if(GLOB.darkspawn_team != old_team)
		QDEL_NULL(GLOB.darkspawn_team)
		GLOB.darkspawn_team = old_team
	GLOB.sacrament_done = FALSE
	return ..()

/datum/unit_test/darkspawn/Run()
	var/runtimes_before = GLOB.total_runtimes
	old_team = GLOB.darkspawn_team
	GLOB.darkspawn_team = null
	var/turf/left = run_loc_floor_bottom_left
	var/turf/right = get_step(left, EAST)

	// Nowy darkspawn: w drużynie, z celem, z Divulge, bez klasy
	var/mob/living/carbon/human/dark = allocate(/mob/living/carbon/human, left)
	dark.mind_initialize()
	var/datum/antagonist/darkspawn/antag = dark.mind.add_antag_datum(/datum/antagonist/darkspawn)
	TEST_ASSERT(antag, "No darkspawn datum")
	TEST_ASSERT(antag.team == GLOB.darkspawn_team && (dark.mind in antag.team.members), "Darkspawn is not in the team")
	TEST_ASSERT(locate(/datum/objective/darkspawn) in antag.objectives, "No Sacrament objective")
	TEST_ASSERT(locate(/datum/action/cooldown/spell/divulge) in dark.actions, "No Divulge button")
	TEST_ASSERT(dark.has_language(/datum/language/darkspawn), "No Darkspeak")
	TEST_ASSERT(is_team_darkspawn(dark), "Darkspawn not on the darkspawn team")

	// Okno: lista klas i wybór
	var/list/static_data = antag.ui_static_data(dark)
	TEST_ASSERT_EQUAL(length(static_data["classData"]), 3, "Wrong number of selectable classes")
	antag.select_class(/datum/component/darkspawn_class/warlock)
	TEST_ASSERT(istype(antag.picked_class, /datum/component/darkspawn_class/warlock), "Class not selected")
	TEST_ASSERT(locate(/datum/action/cooldown/spell/touch/devour_will) in dark.actions, "No Devour Will from the class")
	TEST_ASSERT(locate(/datum/action/cooldown/spell/touch/thrall_mind) in dark.actions, "No Thrall Mind for the warlock")
	TEST_ASSERT_EQUAL(antag.psi_cap, 200, "Warlock did not double the psi cap")
	TEST_ASSERT_EQUAL(antag.team.max_thralls, 3, "Warlock did not add thrall slots")
	antag.select_class(/datum/component/darkspawn_class/fighter)
	TEST_ASSERT(istype(antag.picked_class, /datum/component/darkspawn_class/warlock), "Class changed after picking one")

	// Przed zrzuceniem skóry sklep nic nie sprzedaje
	var/willpower_before = antag.willpower
	antag.purchase(/datum/psi_web/psi_cap)
	TEST_ASSERT_EQUAL(antag.willpower, willpower_before, "Bought something before Divulge")

	// Divulge: gatunek, Divulge znika
	antag.divulge()
	TEST_ASSERT(istype(dark.dna.species, /datum/species/darkspawn), "Divulge did not change the species")
	TEST_ASSERT_EQUAL(antag.darkspawn_state, DARKSPAWN_DIVULGED, "Wrong state after Divulge")
	TEST_ASSERT(!(locate(/datum/action/cooldown/spell/divulge) in dark.actions), "Divulge kept after use")
	TEST_ASSERT(LAZYLEN(antag.picked_class.applied_overlays), "No class eyes and sigils after Divulge")

	// Psi Web: zakup, zakup wielokrotny, brak woli, zwrot
	var/list/data = antag.ui_data(dark)
	var/total_entries = 0
	for(var/list/category in data["categories"])
		total_entries += length(category["knowledgeData"])
	TEST_ASSERT(total_entries >= 20, "Psi Web lists too few warlock entries ([total_entries])")
	antag.willpower = 10
	antag.purchase(/datum/psi_web/psi_cap)
	antag.purchase(/datum/psi_web/psi_cap)
	TEST_ASSERT_EQUAL(antag.psi_cap, 400, "Infinite upgrade not stacked")
	TEST_ASSERT_EQUAL(antag.willpower, 6, "Wrong willpower after two purchases")
	antag.purchase(/datum/psi_web/mindblast)
	TEST_ASSERT(locate(/datum/action/cooldown/spell/pointed/mindblast) in dark.actions, "Bought ability not granted")
	antag.purchase(/datum/psi_web/shadow_crash)
	TEST_ASSERT(!(locate(/datum/action/cooldown/spell/pointed/shadow_crash) in dark.actions), "Warlock bought a fighter ability")
	antag.willpower = 0
	antag.purchase(/datum/psi_web/extract)
	TEST_ASSERT(!(locate(/datum/action/cooldown/spell/pointed/extract) in dark.actions), "Bought an ability without willpower")
	var/datum/psi_web/blast_power = locate(/datum/psi_web/mindblast) in antag.picked_class.learned_abilities
	antag.picked_class.lose_power(blast_power, TRUE)
	TEST_ASSERT(!(locate(/datum/action/cooldown/spell/pointed/mindblast) in dark.actions), "Refund kept the ability")
	TEST_ASSERT_EQUAL(antag.willpower, 2, "Refund did not return willpower")

	// Ulepszenie laski przez sygnał
	antag.willpower = 5
	antag.purchase(/datum/psi_web/ability_upgrade/efficiency)
	var/datum/action/cooldown/spell/toggle/dark_staff/staff_spell = locate() in dark.actions
	TEST_ASSERT(staff_spell && (staff_spell.effect_flags & STAFF_UPGRADE_EFFICIENCY), "Staff upgrade not applied")
	staff_spell.Trigger()
	var/obj/item/gun/magic/darkspawn/staff = locate() in dark
	TEST_ASSERT(staff && staff.get_psi_cost() == 20, "Staff missing or upgrade not passed to it")
	staff_spell.Trigger()
	TEST_ASSERT(QDELETED(staff), "Staff not removed")

	// Psi: koszt, blokada odnawiania
	antag.psi = 100
	TEST_ASSERT(antag.spend_psi(30), "Could not spend Psi")
	TEST_ASSERT_EQUAL(antag.psi, 70, "Psi not spent")
	TEST_ASSERT(!antag.spend_psi(500), "Spent more Psi than owned")
	antag.block_psi(5 SECONDS, "unit_test")
	TEST_ASSERT(HAS_TRAIT(antag, TRAIT_DARKSPAWN_PSIBLOCK), "Psi block not applied")
	antag.unblock_psi("unit_test")

	// Thrall: guz, zdolności, Mindlink, implant uwalnia
	var/mob/living/carbon/human/victim = allocate(/mob/living/carbon/human, right)
	victim.mind_initialize()
	TEST_ASSERT(victim.add_thrall(), "Could not thrall the victim")
	TEST_ASSERT(isthrall(victim) && (victim.mind in antag.team.thralls), "Thrall not in the team")
	TEST_ASSERT(get_shadow_tumor(victim), "Thrall has no shadow tumor")
	TEST_ASSERT(locate(/datum/action/cooldown/spell/toggle/nightvision) in victim.actions, "Thrall has no nightvision")
	TEST_ASSERT(is_team_darkspawn(victim), "Thrall not on the darkspawn team")
	var/obj/item/implant/mindshield/shield = new
	shield.implant(victim, null, TRUE)
	TEST_ASSERT(!isthrall(victim), "Mindshield did not free the thrall")
	TEST_ASSERT(!get_shadow_tumor(victim), "Tumor kept after freeing the thrall")
	TEST_ASSERT(!(victim.mind in antag.team.thralls), "Freed thrall still in the team")

	// Pożarcie woli: paciorek, wola i jasność tylko raz
	var/mob/living/carbon/human/meal = allocate(/mob/living/carbon/human, right)
	meal.mind_initialize()
	var/obj/item/organ/shadowtumor/bead = new
	bead.Insert(meal, FALSE, FALSE)
	TEST_ASSERT(get_shadow_tumor(meal), "Shadow bead not inserted")
	antag.team.grant_lucidity(1)
	TEST_ASSERT_EQUAL(antag.team.lucidity, 1, "Lucidity not granted")

	// Pełzające cienie: umysł i zaklęcia idą do cienia i wracają
	antag.willpower = 5
	antag.purchase(/datum/psi_web/crawling_shadows)
	var/datum/action/cooldown/spell/crawling_shadows/shadows_spell = locate() in dark.actions
	TEST_ASSERT(shadows_spell, "No Crawling Shadows")
	var/datum/mind/dark_mind = dark.mind
	antag.psi = 100
	shadows_spell.Trigger()
	var/mob/living/simple_animal/hostile/crawling_shadows/shadows = dark_mind.current
	TEST_ASSERT(istype(shadows), "Mind did not move into the crawling shadows")
	TEST_ASSERT(dark.loc == shadows && (dark.status_flags & GODMODE), "Body not stored in the shadows")
	TEST_ASSERT(shadows_spell.owner == shadows, "Spell did not follow the mind")
	TEST_ASSERT(locate(/datum/action/cooldown/spell/touch/devour_will) in shadows.actions, "Abilities did not follow into the shadows")
	shadows_spell.reset_spell_cooldown()
	shadows_spell.Trigger()
	TEST_ASSERT(QDELETED(shadows), "Crawling shadows survived returning")
	TEST_ASSERT(dark_mind.current == dark && dark.mind == dark_mind, "Mind did not return to the body")
	TEST_ASSERT(isturf(dark.loc) && !(dark.status_flags & GODMODE), "Body not released")
	TEST_ASSERT(locate(/datum/action/cooldown/spell/touch/devour_will) in dark.actions, "Abilities did not come back to the body")

	// Macki wojownika (przez klasę admina, która ma wszystko)
	var/mob/living/carbon/human/fighter = allocate(/mob/living/carbon/human, right)
	fighter.mind_initialize()
	var/datum/antagonist/darkspawn/fighter_antag = fighter.mind.add_antag_datum(/datum/antagonist/darkspawn)
	fighter_antag.picked_class = fighter.mind.AddComponent(/datum/component/darkspawn_class/fighter)
	fighter_antag.divulge()
	var/datum/action/cooldown/spell/toggle/shadow_tendril/tendril_spell = locate() in fighter.actions
	TEST_ASSERT(tendril_spell, "Fighter has no tendrils")
	tendril_spell.Trigger()
	var/obj/item/umbral_tendrils/tendrils = locate() in fighter
	TEST_ASSERT(tendrils, "Tendrils not created")
	tendril_spell.Trigger()
	TEST_ASSERT(QDELETED(tendrils), "Tendrils not removed")
	TEST_ASSERT_EQUAL(length(antag.team.members), 2, "Second darkspawn not in the same team")

	// Potomek ma swoją klątwę
	var/mob/living/simple_animal/hostile/darkspawn_progenitor/progenitor = allocate(/mob/living/simple_animal/hostile/darkspawn_progenitor, right)
	TEST_ASSERT(locate(/datum/action/cooldown/spell/pointed/progenitor_curse) in progenitor.actions, "Progenitor has no curse")
	var/image/progenitor_hud = progenitor.hud_list[ANTAG_HUD]
	TEST_ASSERT(progenitor_hud && progenitor_hud.pixel_x == 48 && progenitor_hud.pixel_y == 32, "Progenitor HUD icons are not moved back over its tile")
	var/datum/action/innate/progenitor_view/view = locate() in progenitor.actions
	TEST_ASSERT(view, "Progenitor has no view toggle")
	progenitor.show_small_self()
	TEST_ASSERT(progenitor.alternate_appearances?["smolgenitor"], "No small self view")
	view.Trigger()
	TEST_ASSERT(progenitor.full_view && !progenitor.alternate_appearances?["smolgenitor"], "Toggle did not show the full sprite")
	view.Trigger()
	TEST_ASSERT(!progenitor.full_view && progenitor.alternate_appearances?["smolgenitor"], "Toggle did not bring back the small view")

	// Zdjęcie roli sprząta przyciski i klasę
	dark.mind.remove_antag_datum(/datum/antagonist/darkspawn)
	TEST_ASSERT(!(locate(/datum/action/cooldown/spell/touch/devour_will) in dark.actions), "Ability buttons left after removing the role")
	TEST_ASSERT(!dark.mind.GetComponent(/datum/component/darkspawn_class), "Class kept after removing the role")
	fighter.mind.remove_antag_datum(/datum/antagonist/darkspawn)

	TEST_ASSERT_EQUAL(GLOB.total_runtimes, runtimes_before, "Runtimes during the darkspawn test")

#undef TEST_ASSERT
#undef TEST_ASSERT_EQUAL
