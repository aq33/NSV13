// AQUILA - katalog wszystkich operacji do programu PDA „Operacje”.
// Generowany z /datum/surgery i ich kroków, więc nowe operacje pojawiają się w nim same.

GLOBAL_LIST(surgery_catalog)

/// Polskie nazwy typów narzędzi z implements
GLOBAL_LIST_INIT(surgery_tool_names, list(
	TOOL_SCALPEL = "skalpel",
	TOOL_HEMOSTAT = "hemostat",
	TOOL_RETRACTOR = "retraktor",
	TOOL_CAUTERY = "kauter",
	TOOL_DRILL = "wiertarka chirurgiczna",
	TOOL_SAW = "piła chirurgiczna",
	TOOL_BLOODFILTER = "filtr krwi",
	TOOL_SCREWDRIVER = "śrubokręt",
	TOOL_WRENCH = "klucz",
	TOOL_CROWBAR = "łom",
	TOOL_WIRECUTTER = "przecinak",
	TOOL_WELDER = "spawarka",
	TOOL_MULTITOOL = "multitool",
	TOOL_KNIFE = "nóż",
	TOOL_ANALYZER = "analizator",
	TOOL_MINING = "kilof",
	TOOL_SHOVEL = "łopata",
	TOOL_ROLLINGPIN = "wałek",
	TOOL_RUSTSCRAPER = "skrobaczka do rdzy",
))

/// Zwraca listę wszystkich operacji w formacie dla TGUI (NtosSurgeryLookup)
/proc/get_surgery_catalog()
	if(GLOB.surgery_catalog)
		return GLOB.surgery_catalog

	var/list/catalog = list()
	for(var/surgery_type in subtypesof(/datum/surgery))
		var/datum/surgery/surgery = new surgery_type
		if(surgery.replaced_by != /datum/surgery && length(surgery.steps))
			catalog += list(surgery_catalog_entry(surgery))
		qdel(surgery)
	GLOB.surgery_catalog = catalog
	return catalog

/proc/surgery_catalog_entry(datum/surgery/surgery)
	var/list/locations = list()
	for(var/zone in surgery.possible_locs)
		locations += strefa_pl(zone)

	var/list/targets = list()
	for(var/mob_type in surgery.target_mobtypes)
		targets += surgery_catalog_mob_name(mob_type)

	var/list/steps = list()
	for(var/step_type in surgery.steps)
		var/datum/surgery_step/step = new step_type
		steps += list(surgery_catalog_step(step))
		qdel(step)

	var/replaced_by
	if(surgery.replaced_by)
		var/datum/surgery/better = surgery.replaced_by
		replaced_by = initial(better.name)

	var/bodypart_kind = "dowolna"
	if(surgery.requires_bodypart_type == BODYTYPE_ORGANIC)
		bodypart_kind = "organiczna"
	else if(surgery.requires_bodypart_type == BODYTYPE_ROBOTIC)
		bodypart_kind = "robotyczna"

	return list(
		"id" = "[surgery.type]",
		"name" = capitalize(surgery.name),
		"desc" = (surgery.desc && surgery.desc != "surgery description") ? surgery.desc : null,
		"locations" = locations,
		"targets" = targets,
		"bodypart" = bodypart_kind,
		"missingLimb" = !surgery.requires_bodypart,
		"requiresTech" = !!surgery.requires_tech,
		"replacedBy" = replaced_by,
		"condition" = surgery.catalog_condition,
		"lying" = !!surgery.lying_required,
		"selfOperable" = !!surgery.self_operable,
		"ignoreClothes" = !!surgery.ignore_clothes,
		"steps" = steps,
	)

/proc/surgery_catalog_step(datum/surgery_step/step)
	var/list/tools = list()
	if(step.accept_hand)
		tools += list(list("name" = "pusta ręka", "speed" = 100))
	if(step.accept_any_item)
		tools += list(list("name" = "dowolny przedmiot", "speed" = 100))
	if(!step.accept_any_item)
		for(var/implement in step.implements)
			var/tool_name
			if(implement == /obj/item)
				tool_name = step.catalog_any_item
			else if(ispath(implement))
				var/atom/tool_type = implement
				tool_name = initial(tool_type.name)
			else
				tool_name = GLOB.surgery_tool_names[implement] || "[implement]"
			if(implement == TOOL_WELDER && step.catalog_hot_welder)
				tool_name += " (zapalona)"
			tools += list(list("name" = tool_name, "speed" = step.implements[implement]))

	var/list/chems = list()
	for(var/reagent_type in step.chems_needed)
		var/datum/reagent/reagent = GLOB.chemical_reagents_list[reagent_type]
		chems += reagent ? reagent.name : "[reagent_type]"

	return list(
		"name" = capitalize(step.name),
		"tools" = tools,
		"time" = step.time / 10,
		"repeatable" = !!step.repeatable,
		"chems" = chems,
		"allChems" = !!step.require_all_chems,
	)

/proc/surgery_catalog_mob_name(mob_type)
	if(ispath(mob_type, /mob/living/carbon/human))
		return "ludzie"
	if(ispath(mob_type, /mob/living/carbon/monkey))
		return "małpy"
	if(ispath(mob_type, /mob/living/carbon/alien))
		return "ksenomorfy"
	if(ispath(mob_type, /mob/living/simple_animal/slime))
		return "szlamy"
	var/mob/named_type = mob_type
	return initial(named_type.name)

// Opisy warunków, których katalog nie wyczyta z kodu (can_start i tool_check potrzebują konkretnego pacjenta i narzędzia)

/datum/surgery
	/// Opis dodatkowego warunku z can_start(), pokazywany w programie „Operacje”
	var/catalog_condition

/datum/surgery_step
	/// Jak w katalogu nazywa się /obj/item z implements (zależy od tool_check() kroku)
	var/catalog_any_item = "dowolny przedmiot"
	/// tool_check() przyjmuje spawarkę tylko zapaloną
	var/catalog_hot_welder = FALSE

/datum/surgery_step/incise
	catalog_any_item = "dowolny ostry przedmiot"

/datum/surgery_step/mechanic_incise
	catalog_any_item = "dowolny ostry przedmiot"

/datum/surgery_step/mechanic_close
	catalog_any_item = "dowolny ostry przedmiot"

/datum/surgery_step/lobotomize
	catalog_any_item = "dowolny ostry przedmiot"

/datum/surgery_step/close
	catalog_any_item = "dowolny gorący przedmiot"
	catalog_hot_welder = TRUE

/datum/surgery_step/viral_bond
	catalog_any_item = "dowolny gorący przedmiot"
	catalog_hot_welder = TRUE

/datum/surgery_step/handle_cavity
	catalog_any_item = "dowolny przedmiot, który nie jest gorący"

/datum/surgery/advanced/bioware
	catalog_condition = "pacjent nie może mieć już tej modyfikacji"

/datum/surgery/advanced/bioware/cortex_folding
	catalog_condition = "pacjent musi mieć mózg i nie mieć już tej modyfikacji"

/datum/surgery/advanced/bioware/cortex_imprint
	catalog_condition = "pacjent musi mieć mózg i nie mieć już tej modyfikacji"

/datum/surgery/advanced/experimental_dissection
	catalog_condition = "tylko na zwłokach, raz na ciało; cyborg nie może jej wykonać"

/datum/surgery/advanced/brainwashing
	catalog_condition = "pacjent musi mieć mózg"

/datum/surgery/advanced/lobotomy
	catalog_condition = "pacjent musi mieć mózg"

/datum/surgery/advanced/pacify
	catalog_condition = "pacjent musi mieć mózg"

/datum/surgery/brain_recalibration
	catalog_condition = "pacjent musi mieć mózg"

/datum/surgery/advanced/necrotic_revival
	catalog_condition = "pacjent nie może mieć już infekcji zombie"

/datum/surgery/advanced/revival
	catalog_condition = "tylko na zwłokach z mózgiem; nie na samobójcy ani wysuszonym ciele (husk)"

/datum/surgery/advanced/viral_bonding
	catalog_condition = "pacjent musi być chory (mieć wirusa)"

/datum/surgery/blood_filter
	catalog_condition = "pacjent musi mieć chemikalia we krwi; nie na wysuszonym ciele (husk)"

/datum/surgery/core_removal
	catalog_condition = "tylko na martwym szlamie"

/datum/surgery/coronary_bypass
	catalog_condition = "serce uszkodzone w ponad 60% i jeszcze nieoperowane"

/datum/surgery/lobectomy
	catalog_condition = "płuca uszkodzone w ponad 60% i jeszcze nieoperowane"

/datum/surgery/gastrectomy
	catalog_condition = "żołądek uszkodzony w ponad 50%, ale jeszcze działający"

/datum/surgery/hepatectomy
	catalog_condition = "wątroba uszkodzona w ponad 50%, ale jeszcze działająca"

/datum/surgery/eye_surgery
	catalog_condition = "pacjent musi mieć oczy"

/datum/surgery/ear_surgery
	catalog_condition = "pacjent musi mieć uszy"

/datum/surgery/lipoplasty
	catalog_condition = "pacjent musi być otyły"

/datum/surgery/augmentation
	catalog_condition = "nie na oozelingach"

/datum/surgery/prosthetic_replacement
	catalog_condition = "w miejscu brakującej kończyny; nie na oozelingach"

/datum/surgery/autopsy
	catalog_condition = "tylko na zwłokach, raz na ciało"

/datum/surgery/stomach_pump
	catalog_condition = "pacjent musi mieć żołądek; nie na wysuszonym ciele (husk)"
