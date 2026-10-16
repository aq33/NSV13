// AQUILA - port of the tgstation autopsy (coroner, tgstation#75065, #77386, #89094), in its step-based form from before the surgery rework.
// Differences: own trait instead of TRAIT_DISSECTED, so experimental dissection still works on the same body;
// no "surgically analyzed" speed bonus, no morbid mood, no operating computer experiment (we don't have them).

/// The body has been autopsied already (cleared when it is revived)
#define TRAIT_AUTOPSIED "autopsied"
#define AUTOPSY_TRAIT "autopsy"

/datum/surgery/autopsy
	name = "autopsja"
	ignore_clothes = TRUE
	possible_locs = list(BODY_ZONE_CHEST)
	target_mobtypes = list(/mob/living/carbon/human, /mob/living/carbon/monkey)
	steps = list(
		/datum/surgery_step/incise,
		/datum/surgery_step/retract_skin,
		/datum/surgery_step/autopsy,
		/datum/surgery_step/close,
	)

/datum/surgery/autopsy/mechanic
	name = "analiza awarii systemu"
	requires_bodypart_type = BODYTYPE_ROBOTIC
	steps = list(
		/datum/surgery_step/mechanic_open,
		/datum/surgery_step/open_hatch,
		/datum/surgery_step/autopsy,
		/datum/surgery_step/mechanic_close,
	)

/datum/surgery/autopsy/can_start(mob/user, mob/living/patient)
	if(!..())
		return FALSE
	if(patient.stat != DEAD)
		return FALSE
	if(HAS_TRAIT(patient, TRAIT_AUTOPSIED))
		return FALSE
	return TRUE

/datum/surgery_step/autopsy
	name = "przeprowadź autopsję (skaner autopsyjny)"
	implements = list(/obj/item/autopsy_scanner = 100)
	time = 10 SECONDS
	success_sound = 'sound/machines/ping.ogg'

/datum/surgery_step/autopsy/preop(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	display_results(user, target, span_notice("Zaczynasz autopsję [target]..."),
		span_notice("[user] przeprowadza autopsję [target] za pomocą [tool]."),
		span_notice("[user] używa [tool] na klatce piersiowej [target]."))

/datum/surgery_step/autopsy/success(mob/living/user, mob/living/carbon/target, target_zone, obj/item/autopsy_scanner/tool, datum/surgery/surgery, default_display_results = FALSE)
	ADD_TRAIT(target, TRAIT_AUTOPSIED, AUTOPSY_TRAIT)
	tool.scan_cadaver(user, target)
	return ..()

/datum/surgery_step/autopsy/failure(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	display_results(user, target, span_warning("Partaczysz i obijasz klatkę piersiową [target]!"),
		span_warning("[user] partaczy i obija klatkę piersiową [target]!"),
		span_warning("[user] partaczy!"))
	target.adjustBruteLoss(5)

/// A revived body can be autopsied again
/mob/living/revive(full_heal = 0, admin_revive = 0)
	. = ..()
	if(.)
		REMOVE_TRAIT(src, TRAIT_AUTOPSIED, AUTOPSY_TRAIT)

/obj/item/autopsy_scanner
	name = "skaner autopsyjny"
	desc = "Służy do zbierania informacji ze zwłok podczas operacji. Potrafi też zbadać zwłoki jak zaawansowany analizator zdrowia!"
	icon = 'aquila/icons/obj/autopsy_scanner.dmi'
	icon_state = "autopsy_scanner"
	item_state = "autopsy_scanner"
	worn_icon = 'aquila/icons/mob/autopsy_scanner_belt.dmi'
	lefthand_file = 'aquila/icons/mob/inhands/autopsy_scanner_lefthand.dmi'
	righthand_file = 'aquila/icons/mob/inhands/autopsy_scanner_righthand.dmi'
	flags_1 = CONDUCT_1
	slot_flags = ITEM_SLOT_BELT
	w_class = WEIGHT_CLASS_NORMAL
	custom_materials = list(/datum/material/iron = 200)

/obj/item/autopsy_scanner/attack(mob/living/M, mob/living/carbon/human/user)
	if(!isliving(M))
		return ..()
	if(is_blind(user))
		return
	if(M.stat != DEAD && !HAS_TRAIT(M, TRAIT_FAKEDEATH)) // good job, you found a loophole
		to_chat(user, span_deadsay("[icon2html(src, user)] BŁĄD! NIE MOŻNA SKANOWAĆ ŻYWYCH ZWŁOK. UŻYJ ANALIZATORA ZDROWIA ALBO ZAKOŃCZ ŻYCIE PACJENTA."))
		return

	// Clumsiness/brain damage check
	if((HAS_TRAIT(user, TRAIT_CLUMSY) || HAS_TRAIT(user, TRAIT_DUMB)) && prob(50))
		user.visible_message(span_warning("[user] bada funkcje życiowe podłogi!"), span_notice("Głupio próbujesz zbadać funkcje życiowe podłogi!"))
		return

	user.visible_message(span_notice("[user] skanuje zwłoki [M]."))
	to_chat(user, span_deadsay("[icon2html(src, user)] ANALIZA ZWŁOK."))
	healthscan(user, M, advanced = TRUE)
	add_fingerprint(user)

/obj/item/autopsy_scanner/proc/scan_cadaver(mob/living/user, mob/living/carbon/scanned)
	if(scanned.stat != DEAD)
		return

	var/list/autopsy_information = list()
	autopsy_information += "[scanned.name] - gatunek: [scanned.dna?.species.name]<br>"
	autopsy_information += "Czas zgonu: [scanned.tod || "nieznany"]<br>"
	autopsy_information += "Czas autopsji: [station_time_timestamp()]<br>"
	autopsy_information += "Autopsję przeprowadził(a): [user.name]<br>"

	autopsy_information += "Toksyny: [CEILING(scanned.getToxLoss(), 1)]<br>"
	autopsy_information += "Niedotlenienie: [CEILING(scanned.getOxyLoss(), 1)]<br>"
	autopsy_information += "Obrażenia komórkowe: [CEILING(scanned.getCloneLoss(), 1)]<br>"

	autopsy_information += "<center>Części ciała</center>"
	for(var/obj/item/bodypart/bodypart as anything in scanned.bodyparts)
		autopsy_information += "<b>[bodypart.name]</b><br>"
		autopsy_information += "URAZY: [round(bodypart.brute_dam, 1)] | OPARZENIA: [round(bodypart.burn_dam, 1)]<br>"
		for(var/obj/item/embedded as anything in bodypart.embedded_objects)
			autopsy_information += "Ciało obce: [embedded.name]<br>"
		for(var/line in bodypart.aq_autopsy_lines()) // dziennik ran i pociski w ciele
			autopsy_information += "[line]<br>"
		for(var/datum/wound/wound as anything in bodypart.wounds)
			autopsy_information += "Obecna rana: [wound.name][wound.treated ? " (opatrzona)" : ""]<br>"

	autopsy_information += "<center>Organy</center>"
	for(var/obj/item/organ/organ as anything in scanned.internal_organs)
		autopsy_information += "[organ.name]: <b>uszkodzenia [CEILING(organ.damage, 1)]</b><br>"

	autopsy_information += "<center>Substancje chemiczne</center>"
	for(var/datum/reagent/scanned_reagent as anything in scanned.reagents?.reagent_list)
		autopsy_information += "<b>[round(scanned_reagent.volume, 0.1)] j. [scanned_reagent.name]</b><br>"
		autopsy_information += "Informacje: <i>[scanned_reagent.description]</i><br>"

	autopsy_information += "<center>Krew</center>"
	if(HAS_TRAIT(scanned, TRAIT_HUSK))
		autopsy_information += "Nie znaleziono krwi, ciało wyschło. Przyczyna: "
		if(HAS_TRAIT_FROM(scanned, TRAIT_HUSK, CHANGELING_DRAIN))
			autopsy_information += "odwodnienie, typowe dla zmiennokształtnych.<br>"
		else
			autopsy_information += "ciężkie oparzenia albo nieznana.<br>"
	else
		var/blood_id = scanned.get_blood_id()
		if(blood_id)
			var/blood_percent = round((scanned.blood_volume / BLOOD_VOLUME_NORMAL) * 100)
			var/blood_type = scanned.dna?.blood_type
			if(blood_id != /datum/reagent/blood)
				var/datum/reagent/blood_reagent = GLOB.chemical_reagents_list[blood_id]
				blood_type = blood_reagent?.name || blood_id
			autopsy_information += "Grupa krwi: [blood_type]<br>"
			autopsy_information += "Objętość krwi: [scanned.blood_volume] cl ([blood_percent]%)<br>"

	for(var/datum/disease/disease as anything in scanned.diseases)
		autopsy_information += "Choroba: [disease.name] | rodzaj: [disease.spread_text]<br>"
		if(!istype(disease, /datum/disease/advance))
			continue
		autopsy_information += "<b>Objawy:</b><br>"
		var/datum/disease/advance/advanced_disease = disease
		for(var/datum/symptom/symptom as anything in advanced_disease.symptoms)
			autopsy_information += "[symptom.name] - [symptom.desc]<br>"

	var/obj/item/paper/autopsy_report = new(user.drop_location())
	autopsy_report.name = "raport z autopsji: [scanned] ([station_time_timestamp()])"
	autopsy_report.add_raw_text(autopsy_information.Join("\n"))
	autopsy_report.color = "#99ccff"
	autopsy_report.update_icon()
	user.put_in_hands(autopsy_report)
	user.balloon_alert(user, "raport wydrukowany")
	return TRUE

/datum/design/autopsy_scanner
	name = "Autopsy Scanner"
	desc = "Skaner do autopsji zwłok."
	id = "autopsy_scanner"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 500, /datum/material/glass = 200)
	build_path = /obj/item/autopsy_scanner
	category = list("Medical Designs")
	departmental_flags = DEPARTMENTAL_FLAG_MEDICAL | DEPARTMENTAL_FLAG_SECURITY

/datum/techweb_node/biotech/New()
	. = ..()
	design_ids += "autopsy_scanner"

/obj/machinery/vending/medical/Initialize(mapload)
	products[/obj/item/autopsy_scanner] = 2
	return ..()

#undef TRAIT_AUTOPSIED
#undef AUTOPSY_TRAIT
