// The upstream assert macros are #undef'd at the end of code/modules/unit_tests/_unit_tests.dm, so this modular test carries its own copies
#define TEST_ASSERT(assertion, reason) if (!(assertion)) { return Fail("Assertion failed: [reason || "No reason"]") }

/// AQUILA - light wounds: applying, effects, healing
/datum/unit_test/aquila_wounds

/datum/unit_test/aquila_wounds/Run()
	var/mob/living/carbon/human/patient = allocate(/mob/living/carbon/human)
	var/obj/item/bodypart/leg = patient.get_bodypart(BODY_ZONE_L_LEG)

	TEST_ASSERT(!patient.check_wounding(leg, WOUND_MINIMUM_DAMAGE - 1, WOUND_BLUNT), "A scratch caused a wound")

	var/datum/wound/fracture = new /datum/wound/blunt/fracture()
	fracture.apply_wound(leg, silent = TRUE)
	TEST_ASSERT(leg.get_wound(WOUND_BLUNT) == fracture, "The fracture is not on the leg")
	TEST_ASSERT(LAZYACCESS(patient.movespeed_modification, "aq_wounds"), "A broken leg does not slow down")
	TEST_ASSERT(length(patient.get_wound_scan_lines()) == 1, "The analyzer does not see the fracture")

	var/obj/item/stack/medical/gauze/gauze = allocate(/obj/item/stack/medical/gauze)
	TEST_ASSERT(patient.get_treatable_wound(leg, gauze) == fracture, "Gauze cannot splint a fracture")

	var/datum/wound/compound = patient.check_wounding(leg, 200, WOUND_BLUNT)
	if(compound)
		TEST_ASSERT(QDELETED(fracture), "A worse fracture did not replace the old one")
		TEST_ASSERT(length(leg.wounds) == 1, "Two blunt wounds on one leg")

	var/obj/item/bodypart/arm = patient.get_bodypart(BODY_ZONE_R_ARM)
	var/datum/wound/artery = new /datum/wound/slash/artery()
	artery.apply_wound(arm, silent = TRUE)
	TEST_ASSERT(patient.is_bleeding(), "A torn artery does not bleed")
	var/obj/item/stack/medical/suture/suture = allocate(/obj/item/stack/medical/suture)
	TEST_ASSERT(patient.get_treatable_wound(arm, suture) == artery, "Sutures cannot close a torn artery")
	var/datum/wound/sutured = artery.replace_with(/datum/wound/slash/deep)
	TEST_ASSERT(arm.get_wound(WOUND_SLASH) == sutured && QDELETED(artery), "A sutured artery did not become a deep cut")

	var/obj/item/bodypart/chest = patient.get_bodypart(BODY_ZONE_CHEST)
	var/datum/wound/burn/burn = new /datum/wound/burn/third_degree()
	burn.apply_wound(chest, silent = TRUE)
	burn.wound_effects(100)
	TEST_ASSERT(patient.getToxLoss() > 0, "An infected burn does not poison")

	patient.fully_heal()
	TEST_ASSERT(!length(leg.wounds) && !length(arm.wounds) && !length(chest.wounds), "Full heal left wounds")
	TEST_ASSERT(!LAZYACCESS(patient.movespeed_modification, "aq_wounds"), "Full heal left the limp")

/// AQUILA - every medkit and the tgstation dressings have a sprite
/datum/unit_test/aquila_medkit_icons

/datum/unit_test/aquila_medkit_icons/Run()
	var/list/types = subtypesof(/obj/item/storage/firstaid) + typesof(/obj/item/stack/medical/suture) + typesof(/obj/item/stack/medical/mesh)
	for(var/obj/item/path as anything in types)
		var/state = initial(path.icon_state)
		var/icon_file = initial(path.icon)
		if(!icon_file || !state)
			continue
		TEST_ASSERT(state in icon_states(icon_file), "[path] has no sprite '[state]' in [icon_file]")

/// AQUILA - the health analyzer window (AuriStation#15) sees damage, wounds and bleeding
/datum/unit_test/aquila_health_analyzer_ui

/datum/unit_test/aquila_health_analyzer_ui/Run()
	var/mob/living/carbon/human/patient = allocate(/mob/living/carbon/human)
	var/obj/item/bodypart/arm = patient.get_bodypart(BODY_ZONE_L_ARM)
	arm.receive_damage(20)
	var/datum/wound/cut = new /datum/wound/slash/deep()
	cut.apply_wound(arm, silent = TRUE)
	var/list/data = get_health_analyzer_data(patient, patient, FALSE)
	TEST_ASSERT(data["target"] == patient.name, "Wrong patient in the window")
	var/list/arm_injuries = data["injuries"][BODY_ZONE_L_ARM]
	var/list/names = list()
	for(var/list/injury as anything in arm_injuries)
		names += injury["name"]
	TEST_ASSERT("Obrażenia fizyczne" in names, "Limb damage is missing")
	TEST_ASSERT(cut.name in names, "The wound is missing")
	var/found_bleeding = FALSE
	for(var/list/injury as anything in data["injuries"]["body"])
		if(injury["name"] == "Krwawienie")
			found_bleeding = TRUE
	TEST_ASSERT(found_bleeding, "Bleeding is missing")

/// AQUILA - the advanced analyzer tells the next surgery step and its tools
/datum/unit_test/aquila_surgery_progress

/datum/unit_test/aquila_surgery_progress/Run()
	var/mob/living/carbon/human/patient = allocate(/mob/living/carbon/human)
	var/datum/surgery/surgery = new /datum/surgery/organ_manipulation(patient, BODY_ZONE_CHEST, patient.get_bodypart(BODY_ZONE_CHEST))
	var/list/progress = patient.get_surgery_progress()
	TEST_ASSERT(length(progress) == 1, "The ongoing surgery is missing")
	var/list/entry = progress[1]
	TEST_ASSERT(entry["step"] == "nacięcie" && findtext(entry["tools"], "skalpel"), "Wrong first step: [entry["step"]] / [entry["tools"]]")
	surgery.status = 3
	entry = patient.get_surgery_progress()[1]
	TEST_ASSERT(entry["step"] == "piłowanie kości", "Wrong third step: [entry["step"]]")
	var/list/data = get_health_analyzer_data(patient, patient, TRUE)
	TEST_ASSERT(length(data["surgeries"]) == 1, "The advanced analyzer window does not show the surgery")
	TEST_ASSERT(isnull(get_health_analyzer_data(patient, patient, FALSE)["surgeries"]), "The basic analyzer shows the surgery")
	qdel(surgery)

/// AQUILA - vitals monitors mapped over stasis beds are connected to their own bed
/datum/unit_test/aquila_mapped_vitals_monitors

/datum/unit_test/aquila_mapped_vitals_monitors/Run()
	var/checked = 0
	for(var/obj/machinery/vitals_reader/monitor in GLOB.machines)
		if(!findtext(monitor.id_tag, "aq_vitals_"))
			continue
		checked++
		TEST_ASSERT(istype(monitor.connected, /obj/machinery/stasis), "Monitor at [monitor.x],[monitor.y],[monitor.z] is not connected to a stasis bed")
		var/obj/machinery/stasis/bed = monitor.connected
		TEST_ASSERT(bed.id_tag == monitor.id_tag, "Monitor at [monitor.x],[monitor.y],[monitor.z] picked the wrong bed")
	log_world("aquila_mapped_vitals_monitors: [checked] mapped monitors checked")
	// One monitor per stasis bed on the maps in rotation (json map_name)
	var/static/list/expected_per_map = list("NSV Aquilas" = 3, "DLV Trawnik" = 4, "NSV Padalec" = 2)
	var/expected = expected_per_map[SSmapping.config?.map_name]
	if(!isnull(expected))
		TEST_ASSERT(checked == expected, "[SSmapping.config.map_name] has [checked] mapped vitals monitors, expected [expected]")

#undef TEST_ASSERT
