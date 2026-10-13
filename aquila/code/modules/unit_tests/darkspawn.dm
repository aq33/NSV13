// The upstream assert macros are #undef'd at the end of code/modules/unit_tests/_unit_tests.dm, so this modular test carries its own copies
#define TEST_ASSERT(assertion, reason) if (!(assertion)) { return Fail("Assertion failed: [reason || "No reason"]") }

#define TEST_ASSERT_EQUAL(a, b, message) do { \
	var/lhs = ##a; \
	var/rhs = ##b; \
	if (lhs != rhs) { \
		return Fail("Expected [isnull(lhs) ? "null" : lhs] to be equal to [isnull(rhs) ? "null" : rhs].[message ? " [message]" : ""]"); \
	} \
} while (FALSE)

/// AQUILA - darkspawn (port z Yogstation): rola, Objawienie, Sieć Psi, Psi, welony, macki i Pełzające cienie
/datum/unit_test/darkspawn

/datum/unit_test/darkspawn/Run()
	var/runtimes_before = GLOB.total_runtimes
	var/datum/team/darkspawn/old_team = GLOB.darkspawn_team
	GLOB.darkspawn_team = null
	var/turf/left = run_loc_floor_bottom_left
	var/turf/right = get_step(left, EAST)

	// Nowy darkspawn wygląda jak człowiek i ma tylko Objawienie
	var/mob/living/carbon/human/dark = allocate(/mob/living/carbon/human, left)
	dark.mind_initialize()
	var/datum/antagonist/darkspawn/antag = dark.mind.add_antag_datum(/datum/antagonist/darkspawn)
	TEST_ASSERT(antag, "No darkspawn datum")
	TEST_ASSERT(antag.team == GLOB.darkspawn_team && (dark.mind in antag.team.members), "Darkspawn is not in the team")
	TEST_ASSERT(locate(/datum/objective/darkspawn) in antag.objectives, "No Sacrament objective")
	TEST_ASSERT(antag.has_ability("divulge"), "No Divulge ability")
	TEST_ASSERT(locate(/datum/action/innate/darkspawn/divulge) in dark.actions, "Divulge button not granted")
	TEST_ASSERT(dark.has_language(/datum/language/darkspawn), "No Darkspeak")
	TEST_ASSERT(!dark.hud_used || dark.hud_used.psi_counter, "Human HUD has no psi counter")

	// Objawienie: nowy gatunek, nowe zdolności, Divulge znika
	antag.divulge()
	TEST_ASSERT(istype(dark.dna.species, /datum/species/darkspawn), "Divulge did not change the species")
	TEST_ASSERT_EQUAL(antag.darkspawn_state, DARKSPAWN_DIVULGED, "Wrong state after Divulge")
	for(var/id in list("psi_web", "sacrament", "devour_will", "pass"))
		TEST_ASSERT(antag.has_ability(id), "Missing [id] after Divulge")
	TEST_ASSERT(!antag.has_ability("divulge"), "Divulge kept after use")
	TEST_ASSERT(!(locate(/datum/action/innate/darkspawn/divulge) in dark.actions), "Divulge button kept after use")
	dark.update_body()
	var/obj/item/bodypart/chest/darkspawn/chest = dark.get_bodypart(BODY_ZONE_CHEST)
	TEST_ASSERT(istype(chest), "Darkspawn has no darkspawn chest")
	TEST_ASSERT(icon_exists(chest.static_icon, "darkspawn_chest"), "No darkspawn chest sprite")

	// Sieć Psi: katalog i zakup za lucidity
	var/list/data = antag.psi_web.ui_data(dark)
	TEST_ASSERT(length(data["abilities"]) >= 8, "Psi Web lists too few abilities")
	TEST_ASSERT_EQUAL(length(data["upgrades"]), 6, "Psi Web lists wrong number of upgrades")
	for(var/list/entry in data["abilities"])
		TEST_ASSERT(entry["id"] != "divulge" && entry["id"] != "psi_web", "Blacklisted ability in Psi Web")
	var/lucidity_before = antag.lucidity
	antag.psi_web.try_unlock("creep")
	TEST_ASSERT(antag.has_ability("creep"), "Could not buy Creep")
	TEST_ASSERT_EQUAL(antag.lucidity, lucidity_before - 2, "Creep did not cost 2 lucidity")
	antag.psi_web.try_unlock("time_dilation")
	TEST_ASSERT(!antag.has_ability("time_dilation"), "Bought an ability without enough lucidity")
	antag.psi_web.try_upgrade("psi_regen")
	TEST_ASSERT(antag.has_upgrade("psi_regen") && antag.psi_regen == 25, "Recovery sigil did not apply")

	// Psi
	antag.psi = 100
	TEST_ASSERT(antag.use_psi(30), "Could not spend Psi")
	TEST_ASSERT_EQUAL(antag.psi, 70, "Psi not spent")
	TEST_ASSERT(!antag.use_psi(500), "Spent more Psi than owned")

	// Całun zżera Psi i znika, gdy go zabraknie
	var/datum/status_effect/darkspawn_creep/creep = dark.apply_status_effect(/datum/status_effect/darkspawn_creep, antag)
	TEST_ASSERT(creep, "No Creep status effect")
	antag.psi = 1
	creep.tick()
	creep.tick()
	TEST_ASSERT(!dark.has_status_effect(/datum/status_effect/darkspawn_creep), "Creep kept without Psi")
	antag.psi = 100

	// Przejście: macki w wolnej ręce
	var/datum/action/innate/darkspawn/pass/pass = antag.has_ability("pass")
	pass.Activate()
	var/obj/item/umbral_tendrils/tendrils = locate() in dark
	TEST_ASSERT(tendrils && tendrils.darkspawn == antag, "Pass did not make tendrils")
	pass.Deactivate()
	TEST_ASSERT(QDELETED(tendrils), "Pass did not remove tendrils")

	// Ofiara z wyssaną wolą staje się welonem, implant ochrony umysłu ją uwalnia
	var/mob/living/carbon/human/victim = allocate(/mob/living/carbon/human, right)
	victim.mind_initialize()
	TEST_ASSERT(!victim.add_veil() || isveil(victim), "add_veil inconsistent")
	victim.mind.remove_antag_datum(/datum/antagonist/veil)
	victim.apply_status_effect(/datum/status_effect/broken_will)
	TEST_ASSERT(victim.has_status_effect(/datum/status_effect/broken_will), "No Broken Will")
	TEST_ASSERT(victim.add_veil(), "Could not veil the victim")
	TEST_ASSERT(isveil(victim) && (victim.mind in antag.team.veils), "Veil not in the team")
	TEST_ASSERT(is_darkspawn_or_veil(victim) && is_darkspawn_or_veil(dark), "Mindlink check failed")
	var/obj/item/implant/mindshield/shield = new
	shield.implant(victim, null, TRUE)
	TEST_ASSERT(!isveil(victim), "Mindshield did not free the veil")
	TEST_ASSERT(!victim.add_veil(), "Mindshielded victim was veiled")
	TEST_ASSERT(!(victim.mind in antag.team.veils), "Freed veil still in the team")

	// Pełzające cienie: umysł idzie do cienia i wraca do ciała
	var/datum/mind/dark_mind = dark.mind
	var/datum/action/innate/darkspawn/crawling_shadows/shadows_ability = new
	shadows_ability.darkspawn = antag
	shadows_ability.Grant(dark)
	shadows_ability.Activate()
	var/mob/living/simple_animal/hostile/crawling_shadows/shadows = dark_mind.current
	TEST_ASSERT(istype(shadows), "Mind did not move into the crawling shadows")
	TEST_ASSERT(dark.loc == shadows && (dark.status_flags & GODMODE), "Body not stored in the shadows")
	TEST_ASSERT(locate(/datum/action/innate/darkspawn/devour_will) in shadows.actions, "Abilities did not follow into the shadows")
	shadows.return_to_body()
	TEST_ASSERT(QDELETED(shadows), "Crawling shadows survived returning")
	TEST_ASSERT(dark_mind.current == dark && dark.mind == dark_mind, "Mind did not return to the body")
	TEST_ASSERT(isturf(dark.loc) && !(dark.status_flags & GODMODE), "Body not released")
	TEST_ASSERT(locate(/datum/action/innate/darkspawn/devour_will) in dark.actions, "Abilities did not come back to the body")
	qdel(shadows_ability)

	// Potomek ma Rozszarpanie umysłu
	var/mob/living/simple_animal/hostile/darkspawn_progenitor/progenitor = allocate(/mob/living/simple_animal/hostile/darkspawn_progenitor, right)
	TEST_ASSERT(locate(/datum/action/innate/progenitor_curse) in progenitor.actions, "Progenitor has no curse")

	// Zdjęcie roli sprząta przyciski
	dark.mind.remove_antag_datum(/datum/antagonist/darkspawn)
	TEST_ASSERT(!(locate(/datum/action/innate/darkspawn) in dark.actions), "Ability buttons left after removing the role")

	QDEL_NULL(GLOB.darkspawn_team)
	GLOB.darkspawn_team = old_team
	TEST_ASSERT_EQUAL(GLOB.total_runtimes, runtimes_before, "Runtimes during the darkspawn test")

#undef TEST_ASSERT
#undef TEST_ASSERT_EQUAL
